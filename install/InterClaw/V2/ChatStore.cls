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
Class InterClaw.V2.ChatStore
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

}
