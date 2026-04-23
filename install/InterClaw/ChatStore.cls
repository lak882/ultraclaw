/// File-based persistence for chatbot conversation history.
/// 
/// Storage layout: <DeployRoot>data/chats/<user>/<chatId>.json
///   user    = lowercased InterClaw.User credential Username, or $Username,
///             sanitized to [A-Za-z0-9_-]. Falls back to "default".
///   chatId  = client-generated local- id, sanitized the same way.
/// 
/// File schema:
///   { "id": "...", "title": "...",
///     "createdAt": ms, "updatedAt": ms,
///     "messages": [ { "type": "user|assistant|system|tool|error", "html": "..." }, ... ] }
/// 
/// M2 shipped the Read half (List + Get). M3 adds Put/Delete + auto-title.
Class InterClaw.ChatStore
{

/// Unix-epoch milliseconds, derived from $ZTIMESTAMP (UTC).
/// Horolog 47117 = 1970-01-01, and $ZTIMESTAMP's seconds field is
/// "sssss.ffffff" — first three fractional digits give ms.
ClassMethod NowMs() As %BigInt
{
    Set h = $ZTIMESTAMP
    Set d = +$Piece(h, ",", 1)
    Set sf = $Piece(h, ",", 2)
    Set s = +$Piece(sf, ".", 1)
    Set f = $Piece(sf, ".", 2) _ "000"
    Set ms = +$Extract(f, 1, 3)
    Return (((d - 47117) * 86400) + s) * 1000 + ms
}

/// Resolve the active user for per-user chat storage. Prefer the logged-in
/// InterClaw.User credential; fall back to $Username. Empty -> "default".
ClassMethod ResolveUser() As %String
{
    Set user = ""
    Try {
        If ##class(Ens.Config.Credentials).%ExistsId("InterClaw.User") {
            Set cred = ##class(Ens.Config.Credentials).%OpenId("InterClaw.User")
            If $IsObject(cred), cred.Username '= "" Set user = cred.Username
        }
    } Catch ex {}
    If user = "" Set user = $Username
    Set user = $ZConvert(user, "L")
    // Sanitize: keep [a-z0-9_-], replace everything else with '-'
    Set out = ""
    For i = 1:1:$Length(user) {
        Set ch = $Extract(user, i)
        If ((ch?1AN) || (ch = "_") || (ch = "-")) {
            Set out = out _ ch
        } Else {
            Set out = out _ "-"
        }
    }
    If out = "" Set out = "default"
    Return out
}

/// Strict filename sanitizer for chat ids (no path traversal).
ClassMethod SafeId(id As %String) As %String
{
    Set out = ""
    For i = 1:1:$Length(id) {
        Set ch = $Extract(id, i)
        If ((ch?1ANP) && (ch '= ".") && (ch '= "/") && (ch '= "\")) || (ch = "-") || (ch = "_") {
            Set out = out _ ch
        }
    }
    Return $Extract(out, 1, 64)
}

/// Root directory for a user's chats. Creates it on demand.
ClassMethod UserDir(user As %String) As %String
{
    Set root = ##class(InterClaw.Installer).DeployRoot()
    Set dir = ##class(%File).NormalizeDirectory(root _ "data/chats/" _ user)
    If '##class(%File).DirectoryExists(dir) {
        Do ##class(%File).CreateDirectoryChain(dir)
    }
    Return dir
}

/// Read a single chat JSON file. Returns a %DynamicObject or "" when missing.
ClassMethod Read(user As %String, id As %String) As %DynamicObject
{
    Set safeId = ..SafeId(id)
    If safeId = "" Return ""
    Set path = ..UserDir(user) _ safeId _ ".json"
    If '##class(%File).Exists(path) Return ""

    Set stream = ##class(%Stream.FileCharacter).%New()
    Set stream.Filename = path
    Set raw = ""
    While 'stream.AtEnd { Set raw = raw _ stream.Read(32000) }
    Try { Return ##class(%DynamicObject).%FromJSON(raw) }
    Catch ex { Return "" }
}

/// List all chats for a user. Returns a %DynamicArray of
/// { id, title, updatedAt } sorted by updatedAt DESC.
/// Heavy fields (messages) are omitted.
ClassMethod List(user As %String) As %DynamicArray
{
    Set dir = ..UserDir(user)
    Set rs = ##class(%ResultSet).%New("%File:FileSet")
    Do rs.Execute(dir, "*.json")

    // Collect into a local array so we can sort by updatedAt.
    Kill items
    While rs.Next() {
        Set path = rs.Get("Name")
        Set name = ##class(%File).GetFilename(path)
        Set id = $Piece(name, ".json", 1)
        If id = "" Continue

        Set stream = ##class(%Stream.FileCharacter).%New()
        Set stream.Filename = path
        Set raw = ""
        While 'stream.AtEnd { Set raw = raw _ stream.Read(32000) }
        Set obj = ""
        Try { Set obj = ##class(%DynamicObject).%FromJSON(raw) }
        Catch ex {}
        If '$IsObject(obj) Continue

        Set title = obj.%Get("title")
        If title = "" Set title = "Untitled"
        Set updatedAt = +obj.%Get("updatedAt")
        Set items(updatedAt, id) = $ListBuild(id, title, updatedAt)
    }
    Do rs.Close()

    Set arr = ##class(%DynamicArray).%New()
    // Reverse-iterate updatedAt to get newest first
    Set k = ""
    For {
        Set k = $Order(items(k), -1)
        Quit:k=""
        Set sub = ""
        For {
            Set sub = $Order(items(k, sub))
            Quit:sub=""
            Set entry = items(k, sub)
            Set row = ##class(%DynamicObject).%New()
            Do row.%Set("id", $ListGet(entry, 1))
            Do row.%Set("title", $ListGet(entry, 2))
            Do row.%Set("updatedAt", $ListGet(entry, 3), "number")
            Do arr.%Push(row)
        }
    }
    Return arr
}

/// Create-or-update a chat. Merges into any existing file so partial
/// payloads (just a title rename, or append-only message additions)
/// don't clobber fields the caller didn't send. Returns the full stored
/// object, or "" on sanitize-reject.
ClassMethod Put(user As %String, id As %String, input As %DynamicObject) As %DynamicObject
{
    Set safeId = ..SafeId(id)
    If safeId = "" Return ""
    Set path = ..UserDir(user) _ safeId _ ".json"

    // Load existing record if any, otherwise seed a fresh one.
    Set existing = ..Read(user, id)
    If '$IsObject(existing) {
        Set existing = ##class(%DynamicObject).%New()
        Do existing.%Set("id", safeId)
        Do existing.%Set("createdAt", ..NowMs(), "number")
    }

    // Merge: only overwrite fields the caller actually supplied.
    If $IsObject(input) {
        If input.%IsDefined("title") {
            Set title = input.%Get("title")
            If title '= "" Do existing.%Set("title", title)
        }
        If input.%IsDefined("messages") {
            Do existing.%Set("messages", input.%Get("messages"))
        }
        If input.%IsDefined("titleLocked") {
            Do existing.%Set("titleLocked", ''input.%Get("titleLocked"), "boolean")
        }
        If input.%IsDefined("model") Do existing.%Set("model", input.%Get("model"))
        If input.%IsDefined("namespace") Do existing.%Set("namespace", input.%Get("namespace"))
    }
    Do existing.%Set("updatedAt", ..NowMs(), "number")
    Do existing.%Set("id", safeId)

    // Write atomically: write to .tmp then rename over the final path.
    Set tmp = path _ ".tmp"
    Set stream = ##class(%Stream.FileCharacter).%New()
    Set stream.Filename = tmp
    Do stream.Write(existing.%ToJSON())
    Do stream.%Save()
    Do stream.%Close()
    If ##class(%File).Exists(path) Do ##class(%File).Delete(path)
    Do ##class(%File).Rename(tmp, path)
    Return existing
}

/// Delete a chat file. Returns 1 if a file was removed, 0 otherwise.
ClassMethod Delete(user As %String, id As %String) As %Boolean
{
    Set safeId = ..SafeId(id)
    If safeId = "" Return 0
    Set path = ..UserDir(user) _ safeId _ ".json"
    If '##class(%File).Exists(path) Return 0
    Return ''##class(%File).Delete(path)
}

/// Derive a chat title from the first user message. Strips a leading
/// slash-command token so renames happen on the real prompt, not "/model".
/// Truncates to ~60 characters, trimmed on a word boundary when possible.
ClassMethod DeriveTitle(text As %String) As %String
{
    Set text = $ZStrip(text, "<>W")
    If $Extract(text) = "/" {
        Set rest = $Piece(text, " ", 2, *)
        If rest '= "" Set text = $ZStrip(rest, "<>W")
    }
    If $Length(text) <= 60 Return text
    Set cut = $Extract(text, 1, 60)
    Set sp = $Find(cut, " ", 40)
    If sp > 0 Set cut = $Extract(cut, 1, sp - 2)
    Return cut _ "..."
}

/// Summarize a chat into a short title by calling Haiku on the last 10
/// turns. Returns the new title on success or "" on failure / when the
/// chat's title is locked. Persists the title to disk when it changes.
///
/// Why Haiku: cheapest available model; a 3-6 word summary never needs
/// frontier reasoning. Why last-10: preserves topic-shift signal without
/// blowing up prompt size on long chats.
ClassMethod Retitle(user As %String, id As %String, messagesJSON As %String = "") As %String
{
    Set existing = ..Read(user, id)
    If '$IsObject(existing) Return ""
    // Respect manual renames — once a user sets a title, auto-retitle is off.
    If ''existing.%Get("titleLocked") Return ""
    // Prefer caller-supplied messages (frontend pane), fall back to disk.
    // Mirrors the V2 class behavior — see InterClaw.V2.ChatStore.Retitle.
    Set msgsSource = ""
    If messagesJSON '= "" {
        Set msgsSource = messagesJSON
    } Else {
        Set msgs = existing.%Get("messages")
        If $IsObject(msgs) { Set msgsSource = msgs.%ToJSON() }
    }
    If msgsSource = "" Return ""
    Set currentTitle = existing.%Get("title")
    Set newTitle = ..SummarizeTitle(msgsSource, currentTitle)
    If newTitle = "" Return ""
    If newTitle = currentTitle Return ""
    Do existing.%Set("title", newTitle)
    Do existing.%Set("updatedAt", ..NowMs(), "number")
    Set path = ..UserDir(user) _ ..SafeId(id) _ ".json"
    Set tmp = path _ ".tmp"
    Set stream = ##class(%Stream.FileCharacter).%New()
    Set stream.TranslateTable = "UTF8"
    Set stream.Filename = tmp
    Do stream.Write(existing.%ToJSON())
    Do stream.%Save()
    Do stream.%Close()
    If ##class(%File).Exists(path) Do ##class(%File).Delete(path)
    Do ##class(%File).Rename(tmp, path)
    Return newTitle
}

/// Python helper: build a compact prompt from the last 10 messages, call
/// Bedrock Haiku via the Anthropic Messages API, and return the raw
/// short-title string. Returns "" on any failure (logged server-side
/// but never raises — title remains unchanged on the caller).
ClassMethod SummarizeTitle(messagesJSON As %String, currentTitle As %String = "") As %String [ Language = python ]
{
    import json, urllib.request, urllib.error, re
    try:
        import iris
    except Exception:
        return ""

    # Read Bedrock credential directly — GetCredentialSecret is a BO
    # instance method and we can't easily instantiate the BO here.
    # Note: IRIS object proxies don't expose __bool__, so `if cred else ""`
    # raises AttributeError — use `cred is not None` instead.
    try:
        if not iris.cls("Ens.Config.Credentials")._ExistsId("InterClaw.Bedrock"):
            return ""
        cred = iris.cls("Ens.Config.Credentials")._OpenId("InterClaw.Bedrock")
        secret = str(cred.Password) if cred is not None else ""
    except Exception:
        return ""
    if not secret:
        return ""
    try:
        credj = json.loads(secret)
    except Exception:
        return ""
    region = credj.get("region", "us-east-1")
    key = credj.get("key", "")
    if not key:
        return ""

    # Parse messages list and strip HTML to plain text. Skip tool/system/
    # error turns — noise for title summarization.
    try:
        messages = json.loads(str(messagesJSON)) if messagesJSON else []
    except Exception:
        messages = []
    recent = []
    for entry in messages[-10:]:
        if not isinstance(entry, dict):
            continue
        mtype = str(entry.get("type") or "")
        html = str(entry.get("html") or "")
        if mtype not in ("user", "assistant"):
            continue
        text = re.sub(r"<[^>]+>", " ", html)
        text = re.sub(r"\s+", " ", text).strip()
        if not text:
            continue
        if len(text) > 600:
            text = text[:600] + "..."
        recent.append(f"{mtype}: {text}")
    if not recent:
        return ""

    convo = "\n\n".join(recent)
    current = str(currentTitle) if currentTitle else ""
    system = (
        "You label IRIS/HealthShare chat sessions with short, specific "
        "titles for a sidebar. Rules:\n"
        "- 3 to 6 words, Title Case.\n"
        "- Focus on the concrete work or subject (a class name, a "
        "production, an HL7 message type, a bug being chased, an error "
        "being diagnosed). Prefer domain nouns over generic verbs.\n"
        "- Ignore conversational filler. Never title a chat 'Hello', "
        "'Greeting', 'Test', 'Question', 'Conversation', 'Casual Chat', "
        "or similar. If the only content is a greeting with no real "
        "request yet, return 'New Chat'.\n"
        "- Ignore slash-command syntax as a topic. '/list cls' is a "
        "directive, not a subject. If everything the user did was run "
        "slash commands, describe what they were exploring or changing.\n"
        "- No quotes, emojis, trailing punctuation, or explanations.\n"
        "- When the conversation covers multiple topics, title the most "
        "recent one."
    )
    user_msg = (
        f"Current title: {current or '(none)'}\n\n"
        f"Last {len(recent)} messages:\n{convo}\n\n"
        "Return ONLY the new title on a single line."
    )
    payload = {
        "anthropic_version": "bedrock-2023-05-31",
        "max_tokens": 64,
        "system": system,
        "messages": [{"role": "user", "content": user_msg}],
    }
    model = "us.anthropic.claude-haiku-4-5-20251001-v1:0"
    url = f"https://bedrock-runtime.{region}.amazonaws.com/model/{model}/invoke"
    headers = {
        "Authorization": f"Bearer {key}",
        "Content-Type": "application/json",
        "Accept": "application/json",
    }
    try:
        req = urllib.request.Request(url, data=json.dumps(payload).encode("utf-8"), headers=headers, method="POST")
        with urllib.request.urlopen(req, timeout=20) as r:
            resp = json.loads(r.read().decode("utf-8"))
    except Exception:
        return ""
    blocks = resp.get("content", []) if isinstance(resp, dict) else []
    out = ""
    for b in blocks:
        if isinstance(b, dict) and b.get("type") == "text":
            out += b.get("text", "")
    out = out.strip().strip('"').strip("'").strip()
    # Sanitize: strip trailing punctuation, cap at 80 chars, single line.
    out = re.sub(r"\s+", " ", out).strip()
    out = out.rstrip(".!?,:;")
    if len(out) > 80:
        out = out[:80].rstrip()
    # Reject low-signal titles Haiku sometimes produces despite the
    # instructions — let the caller keep the previous title.
    if re.match(r"^(new chat|untitled|greeting|greetings|hello|hi|casual\s+chat|conversation|test|testing)$", out, re.I):
        return ""
    return out
}

}
