/// InterClaw.Installer — idempotent post-install setup for the InterClaw IPM package.
/// Called by <Invoke Class="InterClaw.Installer" Method="Setup"/> in module.xml.
///
/// Prerequisite: target namespace must exist before running zpm "load":
///     do ##class(HS.Util.Installer.Foundation).Install("INTERCLAW")
///     zn "INTERCLAW"
///     zpm "load /path/to/interclaw"
///
/// IPM deploys the repo root to ${cspdir}interclaw/ as a single CSPApplication.
/// Classes compile into the current namespace. Web apps bind to the current namespace.
/// This installer then:
///   1. Verifies / fixes the frontend web app physical path
///   2. Cleans dev-only items from the deploy root
///   3. Creates working directories (src/, filedrop/, data/, uploads/)
///   4. Writes ^InterClaw.Config global with dynamic paths
///   5. Creates /api/interclaw and /api/interclaw/production REST web apps
///   6. Installs Python deps needed for docx/pdf to Markdown conversion (pdfplumber, python-docx)
///   7. Creates an Ens.Config.Credentials entry for the Bedrock API key
///   8. Adds an InterClaw favorite to the Management Portal
///   9. Resolves path prefix into ^InterClaw.Config
///  10. Configures AutoStart for InterClaw.Production
///  11. Starts InterClaw.Production
///  12. Runs verification checks
///
/// Deployed layout:
///   ${cspdir}interclaw/
///     frontend/   — Angular editors + chatbot sidebar (web-served)
///     .claude/    — Skills, scripts, commands (not web-served)
///     config/     — Runtime configuration
///     filedrop/   — HL7 message drop directories
///     install/    — ObjectScript class source
///     data/       — Chat storage (<DeployRoot>data/chats/<user>/*.json)
///     module.xml
Class InterClaw.Installer Extends %RegisteredObject
{

/// Deployment root: ${cspdir}interclaw/ (container-safe via ISC_DATA_DIRECTORY).
ClassMethod DeployRoot() As %String
{
    set dataDir = $SYSTEM.Util.GetEnviron("ISC_DATA_DIRECTORY")
    if dataDir '= "" {
        set base = ##class(%File).NormalizeDirectory(dataDir _ "/csp")
    } else {
        set base = ##class(%File).NormalizeDirectory(##class(%File).SubDirectoryName($SYSTEM.Util.InstallDirectory(), "csp"))
    }
    quit ##class(%File).NormalizeDirectory(base _ "/interclaw")
}

/// True if IRIS major version is >= 2026 (Angular UI requires 2026.1).
ClassMethod HasNewUI() As %Boolean
{
    return ($system.Version.GetMajor() >= 2026)
}

/// Resolve the home directory of the IRIS process user. Falls back to
/// ${installdir}mgr/interclaw_home/ if it can't be determined.
ClassMethod ResolveIrisUserHome() As %String
{
    set fallback = ##class(%File).NormalizeDirectory(##class(%File).SubDirectoryName(##class(%File).SubDirectoryName($system.Util.InstallDirectory(), "mgr"), "interclaw_home"))
    try {
        set home = ..ResolveIrisUserHomePy()
        if home '= "" && ##class(%File).DirectoryExists(home) {
            return ##class(%File).NormalizeDirectory(home)
        }
    } catch ex {}
    return fallback
}

ClassMethod ResolveIrisUserHomePy() As %String [ Language = python ]
{
    import os, sys
    if sys.platform == "win32":
        return os.environ.get("USERPROFILE", "")
    import pwd
    try:
        return pwd.getpwuid(os.getuid()).pw_dir
    except Exception:
        return ""
}

/// Main entry point — called by IPM post-install. Idempotent.
ClassMethod Setup() As %Status
{
    set totalSteps = 12
    write !,"================================================================",!
    write "  InterClaw Post-Install Setup",!
    write "================================================================",!
    write "  Namespace:    ", $namespace,!
    write "  Deploy root:  ", ..DeployRoot(),!
    write "  Install dir:  ", $system.Util.InstallDirectory(),!
    write "  IRIS version: ", $zversion,!
    write "  Timestamp:    ", $zdatetime($horolog, 3),!
    write "================================================================",!,!

    set ns = $zconvert($namespace, "U")
    if (ns = "USER") || (ns = "HSLIB") || (ns = "%SYS") || (ns = "HSCUSTOM") {
        write "WARNING: Installing into ", $namespace, " is not recommended.",!
        write "         Create a dedicated namespace first:",!
        write "           do ##class(HS.Util.Installer.Foundation).Install(""INTERCLAW"")",!,!
    }

    write !,"[Step 1/", totalSteps, "] Verifying frontend web app path...",!
    set sc = ..FixFrontendWebApp()
    if $$$ISERR(sc) write "  [!!] ", $system.Status.GetErrorText(sc),!

    write !,"[Step 2/", totalSteps, "] Cleaning deploy root...",!
    do ..CleanDeployRoot()

    write !,"[Step 3/", totalSteps, "] Creating working directories...",!
    do ..CreateWorkingDirectories()

    write !,"[Step 4/", totalSteps, "] Writing configuration global...",!
    do ..WriteConfigGlobal()
    do ..WriteInstallConfigJs()
    do ..PopulateServerEntry()

    write !,"[Step 5/", totalSteps, "] Creating REST web applications...",!
    set sc = ..CreateRESTWebApps()
    if $$$ISERR(sc) write "  [!!] ", $system.Status.GetErrorText(sc),!

    write !,"[Step 6/", totalSteps, "] Installing Python dependencies (pdfplumber, python-docx)...",!
    set sc = ..InstallPythonDeps()
    if $$$ISERR(sc) {
        write "  [!!] ", $system.Status.GetErrorText(sc),!
        write "       Run manually: irispython -m pip install pdfplumber python-docx",!
    }

    write !,"[Step 7/", totalSteps, "] Creating Bedrock credential...",!
    set sc = ..CreateCredential()
    if $$$ISERR(sc) write "  [!!] ", $system.Status.GetErrorText(sc),!

    write !,"[Step 8/", totalSteps, "] Adding Management Portal favorite...",!
    do ..AddFavorites()

    write !,"[Step 9/", totalSteps, "] Configuring environment settings...",!
    do ..ConfigurePathPrefix()

    write !,"[Step 10/", totalSteps, "] Configuring AutoStart...",!
    do ..ConfigureAutoStart()

    write !,"[Step 11/", totalSteps, "] Starting production...",!
    do ..StartProduction()

    write !,"[Step 12/", totalSteps, "] Verifying...",!
    do ..Verify()

    set pathPrefix = $get(^InterClaw.Config("PathPrefix"), "")
    write !,"================================================================",!
    write "  InterClaw Setup Complete",!
    write "================================================================",!
    write "  Frontend:   ", pathPrefix, "/ui/interop/interclaw/interop-editor/index.html",!
    write "  REST API:   ", pathPrefix, "/api/interclaw/api/health",!
    write "  Chat API:   ", pathPrefix, "/api/interclaw/production/api/health",!
    write "  Production: InterClaw.Production",!
    write "================================================================",!
    return $$$OK
}

/// Verify the /ui/interop/interclaw web app's physical path.
/// On IRIS < 2026.1 the Angular UI isn't supported — remove the web app.
ClassMethod FixFrontendWebApp() As %Status
{
    set appName = "/ui/interop/interclaw"
    set correctPath = ..DeployRoot() _ "frontend/"
    set origNS = $namespace

    if '..HasNewUI() {
        write "  IRIS ", $system.Version.GetMajor(), ".", $system.Version.GetMinor(), " — Angular frontend requires 2026.1+. Removing web app.",!
        try {
            new $namespace
            set $namespace = "%SYS"
            if ##class(Security.Applications).Exists(appName) {
                do ##class(Security.Applications).Delete(appName)
                write "  [OK] Removed",!
            }
        } catch ex {
            write "  [!!] ", ex.DisplayString(),!
        }
        return $$$OK
    }

    try {
        new $namespace
        set $namespace = "%SYS"
        if '##class(Security.Applications).Exists(appName) {
            write "  [SKIP] Web app does not exist yet (IPM will create it)",!
            return $$$OK
        }
        set app = ##class(Security.Applications).%OpenId(appName)
        if app = "" return $$$ERROR($$$GeneralError, "Could not open web app: " _ appName)
        if app.Path = correctPath {
            write "  [OK] Frontend path already correct: ", correctPath,!
            return $$$OK
        }
        set app.Path = correctPath
        set sc = app.%Save()
        if $$$ISERR(sc) return sc
        write "  [OK] Frontend path updated to ", correctPath,!
    } catch ex {
        return ex.AsStatus()
    }
    return $$$OK
}

/// Whitelist-based cleanup of the deploy root so re-installs from local paths
/// leave only shipped content behind.
ClassMethod CleanDeployRoot()
{
    set root = ..DeployRoot()
    set keepDirs = $listbuild("frontend/",".claude/","config/","filedrop/","install/","src/","poc-examples/","references/","tests/","data/","uploads/")
    set keepFiles = $listbuild("requirements.txt","module.xml","README.md")
    set cleaned = 0

    set rs = ##class(%ResultSet).%New("%File:FileSet")
    do rs.Execute(root, "*", "", 1)
    while rs.Next() {
        set name = rs.Get("Name")
        set itemName = rs.Get("ItemName")
        set type = rs.Get("Type")
        if type = "D" {
            if '$listfind(keepDirs, itemName _ "/") {
                write "  Removing dir: ", itemName,!
                if ##class(%File).RemoveDirectoryTree(name) set cleaned = cleaned + 1
            }
        } else {
            set ext = $zconvert($piece(itemName, ".", *), "L")
            set isDoc = ((ext = "md") || (ext = "txt"))
            if '$listfind(keepFiles, itemName), 'isDoc {
                write "  Removing file: ", itemName,!
                do ##class(%File).Delete(name)
                set cleaned = cleaned + 1
            }
        }
    }

    // Never ship secrets — always remove config/.env
    set envFile = root _ "config/.env"
    if ##class(%File).Exists(envFile) {
        do ##class(%File).Delete(envFile)
        write "  Removed config/.env",!
        set cleaned = cleaned + 1
    }

    write "  [OK] ", $select(cleaned > 0: "Removed " _ cleaned _ " items", 1: "Deploy root is clean"),!
}

/// Create runtime directories (src/, filedrop/, data/, uploads/) under the deploy root.
/// Seed config/servers.json and config/orchestrator.json with defaults.
ClassMethod CreateWorkingDirectories()
{
    set root = ..DeployRoot()
    set dirs = $listbuild("src", "filedrop", "config", "data", "data/chats", "uploads")
    set ptr = 0
    while $listnext(dirs, ptr, dirName) {
        set dirPath = ##class(%File).NormalizeDirectory(root _ dirName)
        if '##class(%File).DirectoryExists(dirPath) {
            do ##class(%File).CreateDirectoryChain(dirPath)
            write "  Created: ", dirPath,!
        }
    }
    do ..SeedConfigFiles(root)
}

/// Seed config/servers.json and config/orchestrator.json with defaults if missing.
ClassMethod SeedConfigFiles(root As %String)
{
    set serversFile = root _ "config/servers.json"
    if '##class(%File).Exists(serversFile) {
        set file = ##class(%File).%New(serversFile)
        do file.Open("WSN")
        do file.WriteLine("{")
        do file.WriteLine("  ""default"": """",")
        do file.WriteLine("  ""intersystems.servers"": {}")
        do file.WriteLine("}")
        do file.Close()
        write "  Seeded config/servers.json",!
    }

    set orchFile = root _ "config/orchestrator.json"
    if '##class(%File).Exists(orchFile) {
        set json = {}
        do json.%Set("permissions", {"mode": "normal"})
        do json.%Set("cost", {"pricing": {"inputPerMTok": 3, "outputPerMTok": 15}})
        do json.%Set("telemetry", {"enabled": 1, "logPath": "data/telemetry"})
        do json.%Set("feedback", {"enabled": 0})
        do json.%Set("gitlab", {"url": "", "token": ""})

        set file = ##class(%File).%New(orchFile)
        do file.Open("WSN")
        set formatter = ##class(%JSON.Formatter).%New()
        set formatter.Indent = 1
        set stream = ##class(%Stream.TmpCharacter).%New()
        do formatter.FormatToStream(json, stream)
        do stream.Rewind()
        while 'stream.AtEnd { do file.Write(stream.Read(32000)) }
        do file.Close()
        write "  Seeded config/orchestrator.json",!
    }
}

/// Write ^InterClaw.Config with dynamic paths resolved at install time.
ClassMethod WriteConfigGlobal()
{
    set root = ..DeployRoot()
    set ^InterClaw.Config("DeployRoot") = root
    set ^InterClaw.Config("CWD") = root
    set ^InterClaw.Config("Namespace") = $namespace
    set ^InterClaw.Config("Version") = "0.2"
    set ^InterClaw.Config("InstalledAt") = $zdatetime($horolog, 3)

    // Resolve pathPrefix from the web gateway config (e.g. /interclaw-dev)
    set pathPrefix = ""
    set webPath = $system.CSP.GetDefaultApp($namespace)
    if webPath '= "" set pathPrefix = $piece(webPath, "/csp/", 1)
    if pathPrefix = "" {
        set urlPrefix = $get(^%SYS("WebServer","URLPrefix"), "")
        if urlPrefix '= "" set pathPrefix = "/" _ urlPrefix
    }
    if pathPrefix = "" {
        set installDir = $translate($system.Util.InstallDirectory(), "\", "/")
        set installDir = $zstrip(installDir, ">", "/")
        set pathPrefix = "/" _ $piece(installDir, "/", $length(installDir, "/"))
    }
    set ^InterClaw.Config("PathPrefix") = pathPrefix

    // DefaultServer = pathPrefix without the leading slash (matches servers.json key)
    set defaultServer = $extract(pathPrefix, 2, *)
    if defaultServer = "" set defaultServer = "localhost"
    set ^InterClaw.Config("DefaultServer") = defaultServer

    write "  PathPrefix:    ", pathPrefix,!
    write "  DefaultServer: ", defaultServer,!
    write "  [OK] ^InterClaw.Config written",!
}

/// Write frontend/install-config.js so every HTML entry can read the install
/// namespace and pathPrefix before the rest of JS loads.
ClassMethod WriteInstallConfigJs()
{
    set root = ..DeployRoot()
    set outFile = root _ "frontend/install-config.js"
    set ns = $get(^InterClaw.Config("Namespace"), $namespace)
    set pathPrefix = $get(^InterClaw.Config("PathPrefix"), "")
    try {
        set stream = ##class(%Stream.FileCharacter).%New()
        set sc = stream.LinkToFile(outFile)
        if $$$ISERR(sc) return
        do stream.Clear()
        do stream.WriteLine("// Generated by InterClaw.Installer — do not edit by hand")
        do stream.WriteLine("window._interclawConfig = {")
        do stream.WriteLine("  namespace: """ _ ns _ """,")
        do stream.WriteLine("  pathPrefix: """ _ pathPrefix _ """")
        do stream.WriteLine("};")
        do stream.%Save()
    } catch ex {}
}

/// Populate config/servers.json with this instance's actual connection details.
ClassMethod PopulateServerEntry()
{
    set root = ..DeployRoot()
    set serversFile = root _ "config/servers.json"
    if '##class(%File).Exists(serversFile) return

    set defaultServer = $get(^InterClaw.Config("DefaultServer"), "")
    set pathPrefix = $get(^InterClaw.Config("PathPrefix"), "")
    if defaultServer = "" return

    try {
        set stream = ##class(%Stream.FileCharacter).%New()
        do stream.LinkToFile(serversFile)
        set json = ##class(%DynamicAbstractObject).%FromJSON(stream)
        set servers = json.%Get("intersystems.servers")
        if servers = "" { set servers = {} do json.%Set("intersystems.servers", servers) }

        set existing = servers.%Get(defaultServer)
        if existing '= "" {
            set ws = existing.%Get("webServer")
            if ws '= "" && (ws.%Get("host") '= "") return
        }

        set hostname = $SYSTEM.INetInfo.LocalHostName()
        if hostname = "" set hostname = "localhost"
        set port = +$get(^%SYS("WebServer","Port"), 80)
        if port = 0 set port = 80

        set webServer = {}
        do webServer.%Set("scheme", "http")
        do webServer.%Set("host", hostname)
        do webServer.%Set("port", port)
        do webServer.%Set("pathPrefix", pathPrefix)

        set entry = {}
        do entry.%Set("webServer", webServer)
        do entry.%Set("username", "superuser")
        do entry.%Set("password", "SYS")

        do servers.%Set(defaultServer, entry)
        do json.%Set("default", defaultServer)

        set outStream = ##class(%Stream.FileCharacter).%New()
        do outStream.LinkToFile(serversFile)
        set formatter = ##class(%JSON.Formatter).%New()
        set formatter.Indent = 1
        do formatter.FormatToStream(json, outStream)
        do outStream.%Save()
        write "  [OK] servers.json populated for ", defaultServer,!
    } catch ex {
        write "  [!!] servers.json populate failed: ", ex.DisplayString(),!
    }
}

/// Create /api/interclaw (InterClaw.REST.Dispatch) and /api/interclaw/production
/// (InterClaw.REST.Chat) REST web apps. Also (re)verifies /ui/interop/interclaw.
ClassMethod CreateRESTWebApps() As %Status
{
    set namespace = $namespace
    new $namespace
    set $namespace = "%SYS"

    // /api/interclaw — control plane
    set ctrl = "/api/interclaw"
    if '##class(Security.Applications).Exists(ctrl) {
        kill props
        set props("NameSpace") = namespace
        set props("DispatchClass") = "InterClaw.REST.Dispatch"
        set props("MatchRoles") = ":%All"
        set props("AutheEnabled") = 64
        set props("IsNameSpaceDefault") = 0
        set props("CookiePath") = "/api/interclaw/"
        set props("UseCookies") = 2
        set sc = ##class(Security.Applications).Create(ctrl, .props)
        if $$$ISERR(sc) return sc
        write "  [OK] Created ", ctrl,!
    } else {
        set app = ##class(Security.Applications).%OpenId(ctrl)
        set app.DispatchClass = "InterClaw.REST.Dispatch"
        set app.NameSpace = namespace
        do app.%Save()
        write "  [OK] Updated ", ctrl, " (dispatch: InterClaw.REST.Dispatch)",!
    }

    // /api/interclaw/production — chat streaming pipeline
    set chatApp = "/api/interclaw/production"
    if '##class(Security.Applications).Exists(chatApp) {
        kill props
        set props("NameSpace") = namespace
        set props("DispatchClass") = "InterClaw.REST.Chat"
        set props("MatchRoles") = ":%All"
        set props("AutheEnabled") = 64
        set props("IsNameSpaceDefault") = 0
        set props("CookiePath") = "/api/interclaw/production/"
        set props("UseCookies") = 2
        set sc = ##class(Security.Applications).Create(chatApp, .props)
        if $$$ISERR(sc) return sc
        write "  [OK] Created ", chatApp,!
    } else {
        set app = ##class(Security.Applications).%OpenId(chatApp)
        set app.DispatchClass = "InterClaw.REST.Chat"
        set app.NameSpace = namespace
        do app.%Save()
        write "  [OK] Updated ", chatApp, " (dispatch: InterClaw.REST.Chat)",!
    }

    // /ui/interop/interclaw — Angular frontend
    set uiApp = "/ui/interop/interclaw"
    set uiPath = ..DeployRoot() _ "frontend/"
    if '##class(Security.Applications).Exists(uiApp) {
        kill props
        set props("NameSpace") = namespace
        set props("Path") = uiPath
        set props("MatchRoles") = ":%All"
        set props("ServeFiles") = 1
        set props("Recurse") = 1
        set props("AutheEnabled") = 64
        set props("Enabled") = 1
        set props("IsNameSpaceDefault") = 0
        set props("CookiePath") = "/ui/interop/interclaw/"
        set props("UseCookies") = 2
        do ##class(Security.Applications).Create(uiApp, .props)
        write "  [OK] Created ", uiApp,!
    } else {
        set app = ##class(Security.Applications).%OpenId(uiApp)
        if app '= "" && (app.Path '= uiPath) {
            set app.Path = uiPath
            do app.%Save()
            write "  [OK] Updated ", uiApp, " path: ", uiPath,!
        }
    }

    return $$$OK
}

/// Install pdfplumber and python-docx into mgr/python for the docx/pdf to
/// Markdown conversion flows in the upload path. Skips packages that already
/// import cleanly so re-installs don't fight existing site-packages ownership.
ClassMethod InstallPythonDeps() As %Status
{
    set installDir = $system.Util.InstallDirectory()
    set binDir = ##class(%File).SubDirectoryName(installDir, "bin")
    set irispython = ##class(%File).NormalizeFilename("irispython", binDir)
    if '##class(%File).Exists(irispython) {
        set exe = irispython _ ".exe"
        if ##class(%File).Exists(exe) { set irispython = exe }
        else { return $$$ERROR($$$GeneralError, "irispython not found: " _ irispython) }
    }

    set have = ..ProbePythonDeps()
    if have {
        write "  [OK] pdfplumber + python-docx already importable",!
        return $$$OK
    }

    set mgrPython = ##class(%File).NormalizeDirectory(##class(%File).SubDirectoryName(##class(%File).SubDirectoryName(installDir, "mgr"), "python"))
    set pkgs = "pdfplumber python-docx"
    set cmd = irispython _ " -m pip install --target " _ mgrPython _ " --no-cache-dir --quiet " _ pkgs _ " 2>&1"
    write "  Running: pip install ", pkgs,!
    set rc = $zf(-1, cmd)
    if rc '= 0 {
        return $$$ERROR($$$GeneralError, "pip install failed with exit code " _ rc _ " — run manually: " _ cmd)
    }
    write "  [OK] Python deps installed",!
    return $$$OK
}

/// Returns 1 if both pdfplumber and docx import cleanly in embedded Python.
ClassMethod ProbePythonDeps() As %Boolean [ Language = python ]
{
    try:
        import pdfplumber  # noqa: F401
        import docx        # noqa: F401
        return 1
    except Exception:
        return 0
}

/// Create the InterClaw.Bedrock credential entry in Ens.Config.Credentials.
/// The Bedrock API key JSON is stored in the Password field at runtime via
/// /api/authenticate.
ClassMethod CreateCredential() As %Status
{
    set credName = "InterClaw.Bedrock"
    try {
        if ##class(Ens.Config.Credentials).%ExistsId(credName) {
            write "  [OK] Credential ", credName, " already exists",!
            return $$$OK
        }
        set cred = ##class(Ens.Config.Credentials).%New()
        set cred.SystemName = credName
        set cred.Username = "bedrock"
        set sc = cred.%Save()
        if $$$ISERR(sc) return sc
        write "  [OK] Created credential ", credName,!
    } catch ex {
        return ex.AsStatus()
    }
    return $$$OK
}

/// Add an InterClaw favorite to the Management Portal home for the current user.
ClassMethod AddFavorites()
{
    set pathPrefix = $get(^InterClaw.Config("PathPrefix"), "")
    set linkName = "InterClaw"
    set linkUrl = pathPrefix _ "/ui/interop/interclaw/interop-editor/index.html?view=chat&$NAMESPACE=" _ $namespace
    try {
        set mgrDir = "^^" _ $zu(12)
        set username = $username
        set ^|mgrDir|SYS("Portal","UsersD", username, linkName) = $listbuild("", linkUrl)
        write "  [OK] Added favorite ", linkName, " (user ", username, ")",!
    } catch ex {
        write "  [!!] ", ex.DisplayString(),!
    }
}

/// Re-resolve ^InterClaw.Config("PathPrefix") if it wasn't set (rare fallback).
ClassMethod ConfigurePathPrefix()
{
    set pathPrefix = $get(^InterClaw.Config("PathPrefix"))
    if pathPrefix '= "" {
        write "  [OK] PathPrefix: ", pathPrefix,!
        return
    }
    // Redo the resolution from WriteConfigGlobal
    set webPath = $system.CSP.GetDefaultApp($namespace)
    if webPath '= "" set pathPrefix = $piece(webPath, "/csp/", 1)
    if pathPrefix = "" {
        set installDir = $translate($system.Util.InstallDirectory(), "\", "/")
        set installDir = $zstrip(installDir, ">", "/")
        set pathPrefix = "/" _ $piece(installDir, "/", $length(installDir, "/"))
    }
    set ^InterClaw.Config("PathPrefix") = pathPrefix
    write "  [OK] PathPrefix (re-resolved): ", pathPrefix,!
}

/// Configure AutoStart so IRIS starts InterClaw.Production on instance boot.
ClassMethod ConfigureAutoStart()
{
    try {
        set sc = ##class(Ens.Director).SetAutoStart("InterClaw.Production")
        if $$$ISERR(sc) {
            write "  [!!] ", $system.Status.GetErrorText(sc),!
            return
        }
        write "  [OK] AutoStart configured: InterClaw.Production",!
    } catch ex {
        write "  [!!] ", ex.DisplayString(),!
    }
}

/// Start InterClaw.Production. Handles stopped / suspended / troubled / another-running.
ClassMethod StartProduction()
{
    set target = "InterClaw.Production"
    try {
        set sc = ##class(Ens.Director).GetProductionStatus(.prodName, .prodState)
        set prodName = $get(prodName)
        set prodState = +$get(prodState, 0)
        // 1=Running, 2=Stopped, 3=Suspended, 4=Troubled
        if (prodName = target) && (prodState = 1) {
            write "  [OK] ", target, " is already running",!
            return
        }
        if (prodName '= "") && (prodName '= target) && (prodState = 1) {
            write "  Stopping other production ", prodName, "...",!
            do ##class(Ens.Director).StopProduction(30, 1)
        }
        if (prodName = target) && ((prodState = 3) || (prodState = 4)) {
            write "  Recovering ", target, " (", prodState, ")...",!
            do ##class(Ens.Director).RecoverProduction(30)
        }
        set sc = ##class(Ens.Director).StartProduction(target)
        if $$$ISERR(sc) {
            write "  [!!] Start failed: ", $system.Status.GetErrorText(sc),!
            return
        }
        write "  [OK] ", target, " started",!
    } catch ex {
        write "  [!!] ", ex.DisplayString(),!
    }
}

/// Verify the deployment.
ClassMethod Verify()
{
    set root = ..DeployRoot()
    set origNS = $namespace
    set checks = 0, passed = 0

    // Frontend (only on 2026.1+)
    set checks = checks + 1
    if ..HasNewUI() {
        set frontendIndex = root _ "frontend/interop-editor/index.html"
        if ##class(%File).Exists(frontendIndex) {
            write "  [OK] Frontend index.html present",!
            set passed = passed + 1
        } else {
            write "  [!!] Missing ", frontendIndex,!
        }
    } else {
        write "  [OK] Frontend skipped (requires 2026.1+)",!
        set passed = passed + 1
    }

    // Skill directory
    set checks = checks + 1
    if ##class(%File).DirectoryExists(root _ ".claude/skills/interclaw/") {
        write "  [OK] Skill directory present",!
        set passed = passed + 1
    } else {
        write "  [!!] Missing .claude/skills/interclaw/",!
    }

    // Config global
    set checks = checks + 1
    if $data(^InterClaw.Config("CWD")) {
        write "  [OK] ^InterClaw.Config is set",!
        set passed = passed + 1
    } else {
        write "  [!!] ^InterClaw.Config not written",!
    }

    // REST web apps — save/restore namespace around %SYS access so the
    // subsequent Ens.Config.Credentials check still resolves.
    set savedNS = $namespace
    try {
        set $namespace = "%SYS"
        set checks = checks + 1
        if ##class(Security.Applications).Exists("/api/interclaw") {
            write "  [OK] /api/interclaw web app present",!
            set passed = passed + 1
        } else {
            write "  [!!] /api/interclaw missing",!
        }
        set checks = checks + 1
        if ##class(Security.Applications).Exists("/api/interclaw/production") {
            write "  [OK] /api/interclaw/production web app present",!
            set passed = passed + 1
        } else {
            write "  [!!] /api/interclaw/production missing",!
        }
    } catch ex {}
    set $namespace = savedNS

    // Credential
    set checks = checks + 1
    if ##class(Ens.Config.Credentials).%ExistsId("InterClaw.Bedrock") {
        write "  [OK] Credential InterClaw.Bedrock exists",!
        set passed = passed + 1
    } else {
        write "  [!!] InterClaw.Bedrock credential missing",!
    }

    // Production
    set checks = checks + 1
    try {
        do ##class(Ens.Director).GetProductionStatus(.prodName, .prodState)
        if ($get(prodName) = "InterClaw.Production") && (+$get(prodState) = 1) {
            write "  [OK] InterClaw.Production running",!
            set passed = passed + 1
        } else {
            write "  [!!] InterClaw.Production not running (state=", $get(prodState), ", name=", $get(prodName), ")",!
        }
    } catch ex {}

    write !,"  Results: ", passed, "/", checks, " checks passed",!
}

/// IPM Unconfigure hook — called during "zpm uninstall interclaw".
/// Delegates to InterClaw.Reset for a full cleanup.
ClassMethod Teardown() As %Status
{
    write !,"================================================================",!
    write "  InterClaw Teardown",!
    write "================================================================",!
    do ##class(InterClaw.Reset).StopProduction(0)
    do ##class(InterClaw.Reset).RemoveAutoStart(0)
    do ##class(InterClaw.Reset).RemovePortalFavorite(0)
    do ##class(InterClaw.Reset).RemoveGlobals(0)
    do ##class(InterClaw.Reset).RemoveFiles(0)
    write "================================================================",!
    return $$$OK
}

}
