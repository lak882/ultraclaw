/// REST Dispatch for the Skills Editor API.
/// Serves file listings and content from the .claude/ directory.
Class InterClaw.SkillsEditor.Dispatch Extends %CSP.REST
{

Parameter HandleCorsRequest = 1;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
  <Route Url="/roots"    Method="GET"  Call="GetRoots" />
  <Route Url="/tree"     Method="GET"  Call="GetTree" />
  <Route Url="/file"     Method="GET"  Call="GetFile" />
  <Route Url="/file"     Method="PUT"  Call="PutFile" />
  <Route Url="/restore"  Method="POST" Call="RestoreFile" />
  <Route Url="/modified" Method="GET"  Call="GetModified" />
</Routes>
}

/// Project root directory (where CLAUDE.md lives).
ClassMethod ProjectRoot() As %String
{
    quit "/usr/local/InterSystems/interop-agent-orchestrator"
}

/// Allowed file extensions for browsing.
ClassMethod IsAllowedExt(ext As %String) As %Boolean
{
    set allowed = $lb(".md",".py",".json",".cls",".template",".sh",".js",".css",".html",".xml",".yaml",".yml",".txt",".cos",".hl7",".cfg",".conf",".toml")
    quit $listfind(allowed, $zconvert(ext,"L"))
}

/// GET /roots — return list of browsable root directories.
ClassMethod GetRoots() As %Status
{
    set %response.ContentType = "application/json"
    set %response.CharSet = "utf-8"
    do %response.SetHeader("Cache-Control", "no-cache")

    set root = ..ProjectRoot()
    set result = ##class(%DynamicObject).%New()
    set result."project_root" = root
    set roots = ##class(%DynamicArray).%New()

    // Browsable roots
    // CLAUDE.local.md is intentionally excluded — it contains dev-only instructions
    // that should never be visible in the frontend Skills Editor.
    set paths = $lb(".claude/commands", ".claude/skills", ".claude/hooks", ".claude/context", "CLAUDE.md")
    set i = 0
    while $listnext(paths, i, path) {
        set full = root _ "/" _ path
        set entry = ##class(%DynamicObject).%New()
        set entry.path = path
        set entry.name = $piece(path, "/", *)
        if ##class(%File).DirectoryExists(full) {
            set entry.type = "dir"
        } elseif ##class(%File).Exists(full) {
            set entry.type = "file"
        } else {
            continue
        }
        do roots.%Push(entry)
    }
    set result.roots = roots
    write result.%ToJSON()
    quit $$$OK
}

/// GET /tree?root=<path> — return directory tree as JSON.
ClassMethod GetTree() As %Status
{
    set %response.ContentType = "application/json"
    set %response.CharSet = "utf-8"
    do %response.SetHeader("Cache-Control", "no-cache")

    set rootRel = $get(%request.Data("root", 1), ".claude")
    set rootAbs = ##class(%File).NormalizeFilename(..ProjectRoot() _ "/" _ rootRel)

    // Security: ensure path is within project root
    if $extract(rootAbs, 1, $length(..ProjectRoot())) '= ..ProjectRoot() {
        set %response.Status = "400 Bad Request"
        write "{""error"":""Invalid root path""}"
        quit $$$OK
    }

    if '##class(%File).DirectoryExists(rootAbs) {
        set %response.Status = "400 Bad Request"
        write "{""error"":""Directory not found""}"
        quit $$$OK
    }

    set result = ##class(%DynamicObject).%New()
    set result.root = rootRel
    set result.tree = ..BuildTree(rootAbs, rootRel)
    write result.%ToJSON()
    quit $$$OK
}

/// Recursively build a directory tree as a %DynamicArray.
ClassMethod BuildTree(absPath As %String, relPrefix As %String) As %DynamicArray
{
    set arr = ##class(%DynamicArray).%New()

    // Use embedded Python for clean directory listing (returns newline-delimited string)
    set raw = ..ListDirectory(absPath)
    for idx = 1:1:$length(raw, $char(10)) {
        set item = $piece(raw, $char(10), idx)
        if item = "" continue
        set name = $piece(item, "|", 1)
        set isDir = $piece(item, "|", 2)
        set size = $piece(item, "|", 3)

        // Skip __pycache__ and hidden files (except .claude)
        if name = "__pycache__" continue
        if ($extract(name) = ".") && (name '[ ".claude") continue

        set relPath = relPrefix _ "/" _ name
        set fullPath = absPath _ "/" _ name

        set entry = ##class(%DynamicObject).%New()
        set entry.name = name
        set entry.path = relPath

        if isDir {
            set entry.type = "dir"
            set entry.children = ..BuildTree(fullPath, relPath)
        } else {
            set ext = "." _ $zconvert($piece(name, ".", *), "L")
            if '..IsAllowedExt(ext) {
                if name '= "CLAUDE.md" continue
            }
            // Block dev-only files from frontend browsing
            if name = "CLAUDE.local.md" continue
            set entry.type = "file"
            set entry.size = +size
            set entry.ext = ext
        }
        do arr.%Push(entry)
    }
    quit arr
}

/// List directory contents using embedded Python. Returns chr(10)-delimited "name|isDir|size" items.
ClassMethod ListDirectory(dirPath As %String) As %String [ Language = python ]
{
    import os
    items = []
    try:
        for name in sorted(os.listdir(dirPath)):
            full = os.path.join(dirPath, name)
            is_dir = 1 if os.path.isdir(full) else 0
            size = os.path.getsize(full) if not is_dir else 0
            items.append(f"{name}|{is_dir}|{size}")
    except Exception:
        pass
    return "\n".join(items)
}

/// GET /file?path=<relative-path> — return file content as JSON.
ClassMethod GetFile() As %Status
{
    set %response.ContentType = "application/json"
    set %response.CharSet = "utf-8"
    do %response.SetHeader("Cache-Control", "no-cache")

    set fileRel = $get(%request.Data("path", 1), "")
    if fileRel = "" {
        set %response.Status = "400 Bad Request"
        write "{""error"":""Missing path parameter""}"
        quit $$$OK
    }

    set fileAbs = ##class(%File).NormalizeFilename(..ProjectRoot() _ "/" _ fileRel)

    // Security: ensure path is within project root
    if $extract(fileAbs, 1, $length(..ProjectRoot())) '= ..ProjectRoot() {
        set %response.Status = "400 Bad Request"
        write "{""error"":""Invalid path""}"
        quit $$$OK
    }

    if '##class(%File).Exists(fileAbs) {
        set %response.Status = "404 Not Found"
        write "{""error"":""File not found""}"
        quit $$$OK
    }

    // Block dev-only files from frontend access
    set fileName = ##class(%File).GetFilename(fileAbs)
    if fileName = "CLAUDE.local.md" || (fileRel [ "devlogs/") || (fileRel [ "checkpoints/") {
        set %response.Status = "403 Forbidden"
        write "{""error"":""This file is not accessible from the frontend""}"
        quit $$$OK
    }

    // Read file content using embedded Python (handles encoding cleanly)
    set content = ..ReadFileContent(fileAbs)
    set ext = "." _ $zconvert($piece(fileRel, ".", *), "L")

    // Language detection
    set langMap = ##class(%DynamicObject).%New()
    do langMap.%Set(".py", "python")
    do langMap.%Set(".md", "markdown")
    do langMap.%Set(".json", "json")
    do langMap.%Set(".js", "javascript")
    do langMap.%Set(".css", "css")
    do langMap.%Set(".html", "html")
    do langMap.%Set(".xml", "xml")
    do langMap.%Set(".yaml", "yaml")
    do langMap.%Set(".yml", "yaml")
    do langMap.%Set(".sh", "bash")
    do langMap.%Set(".cls", "objectscript")
    do langMap.%Set(".cos", "objectscript")
    do langMap.%Set(".template", "objectscript")
    do langMap.%Set(".toml", "toml")
    do langMap.%Set(".cfg", "ini")
    do langMap.%Set(".conf", "ini")
    set lang = langMap.%Get(ext)
    if lang = "" set lang = "text"

    set result = ##class(%DynamicObject).%New()
    set result.path = fileRel
    set result.name = ##class(%File).GetFilename(fileAbs)
    set result.content = content
    set result.language = lang
    set result.size = $length(content)
    write result.%ToJSON()
    quit $$$OK
}

/// Read file content using embedded Python.
ClassMethod ReadFileContent(filePath As %String) As %String [ Language = python ]
{
    try:
        with open(filePath, 'r', encoding='utf-8', errors='replace') as f:
            content = f.read()
        # Limit to 1MB
        if len(content) > 1024 * 1024:
            content = content[:1024*1024] + "\n\n... (file truncated at 1MB)"
        return content
    except Exception as e:
        return f"Error reading file: {e}"
}

/// PUT /file — save file content.
ClassMethod PutFile() As %Status
{
    set %response.ContentType = "application/json"
    set %response.CharSet = "utf-8"

    set body = ##class(%DynamicObject).%FromJSON(%request.Content)
    set fileRel = body.path
    set content = body.content

    if fileRel = "" {
        set %response.Status = "400 Bad Request"
        write "{""error"":""Missing path""}"
        quit $$$OK
    }

    set fileAbs = ##class(%File).NormalizeFilename(..ProjectRoot() _ "/" _ fileRel)

    if $extract(fileAbs, 1, $length(..ProjectRoot())) '= ..ProjectRoot() {
        set %response.Status = "400 Bad Request"
        write "{""error"":""Invalid path""}"
        quit $$$OK
    }

    if '##class(%File).Exists(fileAbs) {
        set %response.Status = "404 Not Found"
        write "{""error"":""File not found""}"
        quit $$$OK
    }

    // Block dev-only files from frontend writes
    set fileName = ##class(%File).GetFilename(fileAbs)
    if fileName = "CLAUDE.local.md" || (fileRel [ "devlogs/") || (fileRel [ "checkpoints/") {
        set %response.Status = "403 Forbidden"
        write "{""error"":""This file is not accessible from the frontend""}"
        quit $$$OK
    }

    set ok = ..WriteFileContent(fileAbs, content)
    if ok '= "1" {
        set %response.Status = "500 Internal Server Error"
        write "{""error"":""Write failed""}"
        quit $$$OK
    }

    set result = ##class(%DynamicObject).%New()
    set result.ok = 1
    set result.size = $length(content)
    write result.%ToJSON()
    quit $$$OK
}

/// POST /restore — restore file to last committed version.
ClassMethod RestoreFile() As %Status
{
    set %response.ContentType = "application/json"
    set %response.CharSet = "utf-8"

    set body = ##class(%DynamicObject).%FromJSON(%request.Content)
    set fileRel = body.path

    if fileRel = "" {
        set %response.Status = "400 Bad Request"
        write "{""error"":""Missing path""}"
        quit $$$OK
    }

    set fileAbs = ##class(%File).NormalizeFilename(..ProjectRoot() _ "/" _ fileRel)

    if $extract(fileAbs, 1, $length(..ProjectRoot())) '= ..ProjectRoot() {
        set %response.Status = "400 Bad Request"
        write "{""error"":""Invalid path""}"
        quit $$$OK
    }

    set ok = ..GitRestoreFile(..ProjectRoot(), fileRel)
    if ok '= "1" {
        set %response.Status = "404 Not Found"
        write "{""error"":""No committed version found""}"
        quit $$$OK
    }

    // Re-read the restored file
    set content = ..ReadFileContent(fileAbs)

    set result = ##class(%DynamicObject).%New()
    set result.ok = 1
    set result.content = content
    set result.size = $length(content)
    write result.%ToJSON()
    quit $$$OK
}

/// GET /modified — return list of files modified from last commit.
ClassMethod GetModified() As %Status
{
    set %response.ContentType = "application/json"
    set %response.CharSet = "utf-8"
    do %response.SetHeader("Cache-Control", "no-cache")

    set raw = ..GitModifiedFiles(..ProjectRoot())
    set arr = ##class(%DynamicArray).%New()
    for i = 1:1:$length(raw, $char(10)) {
        set line = $piece(raw, $char(10), i)
        if line '= "" do arr.%Push(line)
    }
    write arr.%ToJSON()
    quit $$$OK
}

/// Write file content using embedded Python.
ClassMethod WriteFileContent(filePath As %String, content As %String) As %String [ Language = python ]
{
    try:
        with open(filePath, 'w', encoding='utf-8') as f:
            f.write(content)
        return "1"
    except Exception:
        return "0"
}

/// Return newline-delimited list of files modified from HEAD.
ClassMethod GitModifiedFiles(projectRoot As %String) As %String [ Language = python ]
{
    import subprocess
    try:
        result = subprocess.run(
            ['git', 'diff', '--name-only', 'HEAD'],
            cwd=projectRoot,
            capture_output=True, text=True, timeout=5
        )
        return result.stdout.strip() if result.returncode == 0 else ""
    except Exception:
        return ""
}

/// Restore a file to the HEAD version using git checkout.
ClassMethod GitRestoreFile(projectRoot As %String, relPath As %String) As %String [ Language = python ]
{
    import subprocess
    try:
        result = subprocess.run(
            ['git', 'checkout', 'HEAD', '--', relPath],
            cwd=projectRoot,
            capture_output=True, timeout=5
        )
        return "1" if result.returncode == 0 else "0"
    except Exception:
        return "0"
}

}
