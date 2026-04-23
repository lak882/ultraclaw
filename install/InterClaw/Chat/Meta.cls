/// Per-session user-facing metadata stored in a dedicated global so it
/// is never at risk of being cleared by Context.Clear().
/// 
/// Layout:
///   ^InterClaw.Chat.Meta(chatId, "title")   = <6-word summary string>
///   ^InterClaw.Chat.Meta(chatId, "owner")   = <$Username of creator>
///   ^InterClaw.Chat.Meta(chatId, "deleted") = 1  (absent = not deleted)
/// 
/// Separation of concerns:
///   ^InterClaw.Context  — runtime LLM transcript cache, ephemeral
///   ^InterClaw.Chat.Meta — durable user-facing state, never auto-cleared
Class InterClaw.Chat.Meta Extends %RegisteredObject [ Abstract ]
{

/// Return the stored title for a session, or "" if none yet.
ClassMethod GetTitle(chatId As %String) As %String
{
    Return $Get(^InterClaw.Chat.Meta(chatId, "title"), "")
}

/// Store a title for a session. No-ops if a title already exists.
ClassMethod SetTitle(chatId As %String, title As %String)
{
    If chatId = "" Return
    If $Data(^InterClaw.Chat.Meta(chatId, "title")) Return
    Set ^InterClaw.Chat.Meta(chatId, "title") = title
}

/// Overwrite an existing title (e.g. from a user rename or forced retitle).
ClassMethod UpdateTitle(chatId As %String, title As %String)
{
    If chatId = "" Return
    Set ^InterClaw.Chat.Meta(chatId, "title") = title
}

/// Record the creating user. No-ops if an owner is already recorded so
/// subsequent turns on the same session do not overwrite the original owner.
ClassMethod SetOwner(chatId As %String, username As %String)
{
    If chatId = "" Return
    If $Data(^InterClaw.Chat.Meta(chatId, "owner")) Return
    Set ^InterClaw.Chat.Meta(chatId, "owner") = username
}

/// Return the owner username recorded at session creation, or "" for
/// legacy sessions created before owner tracking was added.
ClassMethod GetOwner(chatId As %String) As %String
{
    Return $Get(^InterClaw.Chat.Meta(chatId, "owner"), "")
}

/// Return 1 if the given user owns this chat or if the chat has no recorded
/// owner (legacy sessions visible to everyone). Return 0 otherwise.
ClassMethod IsOwner(chatId As %String, username As %String) As %Boolean
{
    Set owner = ..GetOwner(chatId)
    Return (owner = "") || (owner = username)
}

/// Soft-delete a chat. Sets the deleted flag and purges the runtime context
/// cache. The SQL rows in Msg.Chat.Request/Response are left untouched as
/// an audit log.
ClassMethod MarkDeleted(chatId As %String)
{
    If chatId = "" Return
    Set ^InterClaw.Chat.Meta(chatId, "deleted") = 1
    Kill ^InterClaw.Context(chatId)
}

/// Return 1 if this chat has been soft-deleted.
ClassMethod IsDeleted(chatId As %String) As %Boolean
{
    Return $Data(^InterClaw.Chat.Meta(chatId, "deleted")) > 0
}

/// Regenerate title for a chat by reading turns from the Ensemble message
/// store, stripping context prefixes, and calling Haiku. Always overwrites
/// the existing title. Returns the new title, or "" on failure.
ClassMethod RetitleFromStore(chatId As %String) As %String
{
    If chatId = "" Return ""
    Set sql = "SELECT TOP 5 req.Prompt AS Prompt, resp.ResponseText AS ResponseText"
            _ " FROM InterClaw_Msg_Chat.Response resp"
            _ " LEFT JOIN InterClaw_Msg_Chat.Request req ON req.RequestId = resp.RequestId"
            _ " WHERE resp.ChatId = ? ORDER BY resp.ID ASC"
    Set rs = ##class(%SQL.Statement).%ExecDirect(, sql, chatId)
    Set userText = ""
    Set asstText = ""
    While rs.%Next() {
        If userText = "" {
            Set p = rs.%Get("Prompt")
            // Strip context lines
            While $Extract(p, 1, 9) = "[Context:" {
                Set nl = $Find(p, $Char(10))
                If nl = 0 { Set p = "" Quit }
                Set p = $ZStrip($Extract(p, nl, *), "<W")
            }
            Set userText = $Extract(p, 1, 400)
        }
        If asstText = "" Set asstText = $Extract(rs.%Get("ResponseText"), 1, 400)
        If userText '= "" && (asstText '= "") Quit
    }
    If userText = "" && (asstText = "") Return ""
    // Read Bedrock credential
    Set secret = ""
    Try {
        If ##class(Ens.Config.Credentials).%ExistsId("InterClaw.Bedrock") {
            Set cred = ##class(Ens.Config.Credentials).%OpenId("InterClaw.Bedrock")
            If $IsObject(cred) Set secret = cred.Password
        }
    } Catch ex {}
    If secret = "" Return ""
    Set title = ..GenerateTitlePy(userText, asstText, secret, "bedrock")
    If title '= "" Set ^InterClaw.Chat.Meta(chatId, "title") = title
    Return title
}

/// Generate and store a 6-word title from the first user prompt and first
/// assistant response. Calls Claude Haiku for speed and low cost. No-ops
/// if a title already exists for this session.
ClassMethod GenerateTitle(chatId As %String, userPrompt As %String, assistantText As %String, secret As %String, provider As %String) As %String
{
    If chatId = "" Return ""
    If $Data(^InterClaw.Chat.Meta(chatId, "title")) Return $Get(^InterClaw.Chat.Meta(chatId, "title"))
    Set title = ..GenerateTitlePy(userPrompt, assistantText, secret, provider)
    If title '= "" Do ..SetTitle(chatId, title)
    Return title
}

ClassMethod GenerateTitlePy(userPrompt As %String, assistantText As %String, secret As %String, provider As %String) As %String [ Language = python ]
{
    import json, urllib.request, urllib.error

    user_text = (userPrompt or "")[:400]
    asst_text = (assistantText or "")[:400]

    instruction = (
        "Summarize this conversation in 6 words or fewer. "
        "Return only the summary — no punctuation, no quotes, no explanation.\n\n"
        "User: " + user_text + "\n\nAssistant: " + asst_text
    )

    try:
        cred = json.loads(secret) if secret else {}
        api_key = cred.get("key", "")
        region  = cred.get("region", "us-east-1")

        if provider == "bedrock" and api_key:
            model_id = "us.anthropic.claude-haiku-4-5-20251001-v1:0"
            url = f"https://bedrock-runtime.{region}.amazonaws.com/model/{model_id}/invoke"
            payload = json.dumps({
                "anthropic_version": "bedrock-2023-05-31",
                "max_tokens": 32,
                "messages": [{"role": "user", "content": instruction}]
            }).encode()

            req = urllib.request.Request(url, data=payload, method="POST")
            req.add_header("Content-Type", "application/json")
            req.add_header("Accept", "application/json")
            req.add_header("Authorization", f"Bearer {api_key}")
        else:
            url = "https://api.anthropic.com/v1/messages"
            payload = json.dumps({
                "model": "claude-haiku-4-5-20251001",
                "max_tokens": 32,
                "messages": [{"role": "user", "content": instruction}]
            }).encode()
            req = urllib.request.Request(url, data=payload, method="POST")
            req.add_header("Content-Type", "application/json")
            req.add_header("x-api-key", api_key)
            req.add_header("anthropic-version", "2023-06-01")

        with urllib.request.urlopen(req, timeout=10) as resp:
            data = json.loads(resp.read())
            text = ""
            for block in data.get("content", []):
                if block.get("type") == "text":
                    text = block.get("text", "").strip()
                    break
            return text[:80]
    except Exception:
        return ""
}

}

