Class InterClaw.REST.Skills Extends %CSP.REST
{

Parameter HandleCorsRequest = 1;

XData UrlMap [ XMLNamespace = "http://www.intersystems.com/urlmap" ]
{
<Routes>
    <Route Url="/index"     Method="GET"    Call="SkillIndex"/>
    <Route Url="/file"      Method="GET"    Call="SkillFile"/>
    <Route Url="/file"      Method="PUT"    Call="SaveSkillFile"/>
    <Route Url="/file"      Method="DELETE" Call="DeleteSkillFile"/>
    <Route Url="/rename"    Method="POST"   Call="RenameSkillFile"/>
    </Routes>
}

/// GET /index — return JSON index of all files under .agent/skills/
ClassMethod SkillIndex() As %Status
{
    Set result = ..SkillIndexPy(..GetCWD())
    Do ..WriteJSON(result)
    Return $$$OK
}

ClassMethod SkillIndexPy(cwd As %String) As %String [ Language = python ]
{
    import os, json

    skills_dir = os.path.join(cwd, ".agent", "skills")
    if not os.path.isdir(skills_dir):
        return json.dumps([])

    SKIP_NAMES = {"__pycache__", ".DS_Store", "skills-editor"}
    SKIP_EXTS = {".pyc", ".pyo"}
    entries = []

    for dirpath, dirnames, filenames in os.walk(skills_dir):
        dirnames[:] = sorted(d for d in dirnames if d not in SKIP_NAMES)
        for fname in sorted(filenames):
            if fname in SKIP_NAMES:
                continue
            ext = os.path.splitext(fname)[1]
            if ext in SKIP_EXTS:
                continue
            full_path = os.path.join(dirpath, fname)
            rel_path = os.path.relpath(full_path, skills_dir).replace(os.sep, "/")
            parts = rel_path.split("/")
            section = parts[0] if len(parts) > 1 and parts[0] in ("skills", "commands", "hooks", "context") else ""
            try:
                size = os.path.getsize(full_path)
            except OSError:
                size = 0
            entries.append(dict(path=rel_path, name=fname, section=section, ext=ext, size=size))

    return json.dumps(entries)
}

/// GET /file?path=<relative-path> — return content of a .agent/skills/ file
ClassMethod SkillFile() As %Status
{
    Set path = $get(%request.Data("path", 1))
    If path = "" {
        Do ..WriteJSON("{""error"":""missing path parameter""}", 400)
        Return $$$OK
    }

    // Build and normalize paths — NormalizeFilename strips trailing /
    Set skillsDir = ##class(%File).NormalizeFilename(..GetCWD() _ ".agent/skills") _ "/"
    Set fullPath = ##class(%File).NormalizeFilename(skillsDir _ path)

    // Path traversal guard: resolved path must start with skillsDir
    If $extract(fullPath, 1, $length(skillsDir)) '= skillsDir {
        Do ..WriteJSON("{""error"":""invalid path""}", 400)
        Return $$$OK
    }

    If '##class(%File).Exists(fullPath) {
        Do ..WriteJSON("{""error"":""file not found""}", 404)
        Return $$$OK
    }

    // Stream the file content back
    Set stream = ##class(%Stream.FileCharacter).%New()
    Set stream.Filename = fullPath
    Set stream.TranslateTable = "UTF8"
    Set %response.ContentType = "text/plain"
    Set %response.CharSet = "utf-8"
    While 'stream.AtEnd {
        Write stream.Read(32000)
    }
    Return $$$OK
}

/// PUT /file?path=<relative-path> — save content to a .agent/skills/ file
ClassMethod SaveSkillFile() As %Status
{
    Set path = $Get(%request.Data("path", 1), "")
    If path = "" {
        Do ..WriteJSON("{""error"":""missing path parameter""}", 400)
        Return $$$OK
    }

    // Read request body (allow empty for .gitkeep files)
    Set content = ..ReadBody()

    // Build and normalize paths
    Set skillsDir = ##class(%File).NormalizeFilename(..GetCWD() _ ".agent/skills") _ "/"
    Set fullPath = ##class(%File).NormalizeFilename(skillsDir _ path)

    // Path traversal guard
    If $Extract(fullPath, 1, $Length(skillsDir)) '= skillsDir {
        Do ..WriteJSON("{""error"":""invalid path""}", 400)
        Return $$$OK
    }

    // Ensure parent directory exists
    Set dir = ##class(%File).GetDirectory(fullPath)
    If '##class(%File).DirectoryExists(dir) {
        Set created = ##class(%File).CreateDirectoryChain(dir)
        If 'created {
            Do ..WriteJSON("{""error"":""could not create directory""}", 500)
            Return $$$OK
        }
    }

    // Write file
    Try {
        Set stream = ##class(%Stream.FileCharacter).%New()
        Set stream.Filename = fullPath
        Set stream.TranslateTable = "UTF8"
        Do stream.Clear()
        Do stream.Write(content)
        Set sc = stream.%Save()
        If $$$ISERR(sc) {
            Do ..WriteJSON("{""error"":""save failed: " _ $System.Status.GetErrorText(sc) _ """}", 500)
            Return $$$OK
        }
        Do ..WriteJSON("{""ok"":true,""path"":""" _ path _ """,""size"":" _ $Length(content) _ "}")
    } Catch ex {
        Do ..WriteJSON("{""error"":""" _ $Replace(ex.DisplayString(), """", "\""") _ """}", 500)
    }
    Return $$$OK
}

ClassMethod GetPermissions() As %Status
{
    Do ..WriteJSON(..GetPermissionsPy(..GetCWD()))
    Return $$$OK
}

ClassMethod GetPermissionsPy(cwd As %String) As %String [ Language = python ]
{
    import json, os
    try:
        with open(os.path.join(cwd, "config", "orchestrator.json")) as f:
            config = json.load(f)
        perm = config.get("permissions", dict())
        mode = perm.get("mode", "normal")
        modes = perm.get("modes", dict())
        mode_config = modes.get(mode, dict())
        return json.dumps(dict(
            mode=mode,
            description=mode_config.get("description", ""),
            settings=mode_config,
            guardrails=perm.get("guardrails", dict()),
            available_modes=list(modes.keys()),
        ))
    except Exception:
        return json.dumps(dict(error="Config not available"))
}

ClassMethod SetPermissions() As %Status
{
    Set body = ..ReadBody()
    Set result = ..SetPermissionsPy(..GetCWD(), body)
    Do ..WriteJSON(result, $select(result [ """error""":400, 1:200))
    Return $$$OK
}

ClassMethod SetPermissionsPy(cwd As %String, body As %String) As %String [ Language = python ]
{
    import json, os
    data = json.loads(body) if body else dict()
    new_mode = data.get("mode")
    if not new_mode:
        return json.dumps(dict(error="Missing 'mode' field"))
    config_path = os.path.join(cwd, "config", "orchestrator.json")
    try:
        with open(config_path, "r") as f:
            config = json.load(f)
        perm = config.get("permissions", dict())
        modes = perm.get("modes", dict())
        if new_mode not in modes:
            return json.dumps(dict(error="Unknown mode. Valid: " + str(list(modes.keys()))))
        perm["mode"] = new_mode
        config["permissions"] = perm
        with open(config_path, "w") as f:
            json.dump(config, f, indent=4)
            f.write("\n")
        mode_config = modes[new_mode]
        return json.dumps(dict(mode=new_mode, description=mode_config.get("description", ""), settings=mode_config))
    except Exception as e:
        return json.dumps(dict(error=str(e)))
}

ClassMethod WriteJSON(json As %String, status As %Integer = 200)
{
    Set %response.ContentType = "application/json"
    Set %response.CharSet = "utf-8"
    If status '= 200 {
        Set %response.Status = status _ " " _ $case(status, 400:"Bad Request", 404:"Not Found", 413:"Payload Too Large", 500:"Internal Server Error", 501:"Not Implemented", 502:"Bad Gateway", :"Error")
    }
    Write json
}

/// Resolve CWD dynamically: ^InterClaw.Config > env var > fallback
ClassMethod GetCWD() As %String
{
    set val = $get(^InterClaw.Config("CWD"))
    if val '= "" return val
    return ##class(%File).NormalizeDirectory(##class(%File).SubDirectoryName(##class(%File).SubDirectoryName($system.Util.InstallDirectory(), "csp"), "interclaw"))
}

/// DELETE /file?path=<relative-path> — delete a file from .agent/skills/
ClassMethod DeleteSkillFile() As %Status
{
    Set path = $Get(%request.Data("path", 1), "")
    If path = "" {
        Do ..WriteJSON("{""error"":""missing path parameter""}", 400)
        Return $$$OK
    }

    // Build and normalize paths
    Set skillsDir = ##class(%File).NormalizeFilename(..GetCWD() _ ".agent/skills") _ "/"
    Set fullPath = ##class(%File).NormalizeFilename(skillsDir _ path)

    // Path traversal guard
    If $Extract(fullPath, 1, $Length(skillsDir)) '= skillsDir {
        Do ..WriteJSON("{""error"":""invalid path""}", 400)
        Return $$$OK
    }

    // Check if file exists
    If '##class(%File).Exists(fullPath) {
        Do ..WriteJSON("{""error"":""file not found""}", 404)
        Return $$$OK
    }

    // Delete file
    Set deleted = ##class(%File).Delete(fullPath)
    If 'deleted {
        Do ..WriteJSON("{""error"":""could not delete file""}", 500)
        Return $$$OK
    }

    Do ..WriteJSON("{""ok"":true,""path"":""" _ path _ """}")
    Return $$$OK
}

/// POST /rename — rename a file in .agent/skills/
/// Body: {"oldPath": "path/to/old.md", "newPath": "path/to/new.md"}
ClassMethod RenameSkillFile() As %Status
{
    Set body = ..ReadBody()
    If body = "" {
        Do ..WriteJSON("{""error"":""empty request body""}", 400)
        Return $$$OK
    }

    // Parse JSON body
    Try {
        Set jsonObj = ##class(%DynamicAbstractObject).%FromJSON(body)
        Set oldPath = jsonObj.oldPath
        Set newPath = jsonObj.newPath
    } Catch ex {
        Do ..WriteJSON("{""error"":""invalid JSON""}", 400)
        Return $$$OK
    }

    If (oldPath = "") || (newPath = "") {
        Do ..WriteJSON("{""error"":""missing oldPath or newPath""}", 400)
        Return $$$OK
    }

    // Build and normalize paths
    Set skillsDir = ##class(%File).NormalizeFilename(..GetCWD() _ ".agent/skills") _ "/"
    Set oldFullPath = ##class(%File).NormalizeFilename(skillsDir _ oldPath)
    Set newFullPath = ##class(%File).NormalizeFilename(skillsDir _ newPath)

    // Path traversal guards
    If $Extract(oldFullPath, 1, $Length(skillsDir)) '= skillsDir {
        Do ..WriteJSON("{""error"":""invalid old path""}", 400)
        Return $$$OK
    }
    If $Extract(newFullPath, 1, $Length(skillsDir)) '= skillsDir {
        Do ..WriteJSON("{""error"":""invalid new path""}", 400)
        Return $$$OK
    }

    // Check if old file exists
    If '##class(%File).Exists(oldFullPath) {
        Do ..WriteJSON("{""error"":""old file not found""}", 404)
        Return $$$OK
    }

    // Check if new file already exists
    If ##class(%File).Exists(newFullPath) {
        Do ..WriteJSON("{""error"":""new file already exists""}", 409)
        Return $$$OK
    }

    // Ensure parent directory of new path exists
    Set newDir = ##class(%File).GetDirectory(newFullPath)
    If '##class(%File).DirectoryExists(newDir) {
        Set created = ##class(%File).CreateDirectoryChain(newDir)
        If 'created {
            Do ..WriteJSON("{""error"":""could not create target directory""}", 500)
            Return $$$OK
        }
    }

    // Rename file
    Set renamed = ##class(%File).Rename(oldFullPath, newFullPath)
    If 'renamed {
        Do ..WriteJSON("{""error"":""could not rename file""}", 500)
        Return $$$OK
    }

    Do ..WriteJSON("{""ok"":true,""oldPath"":""" _ oldPath _ """,""newPath"":""" _ newPath _ """}")
    Return $$$OK
}

ClassMethod ReadBody() As %String
{
    Set body = ""
    If $IsObject(%request.Content) {
        Set stream = %request.Content
        While 'stream.AtEnd {
            Set body = body _ stream.Read(32000)
        }
    }
    Return body
}

}

