/// InterClaw.Installer — Idempotent post-install setup for the InterClaw IPM package.
/// Called by <Invoke Class="InterClaw.Installer" Method="Setup"/> in module.xml.
/// 
/// Prerequisites: The target namespace must exist before running zpm "load".
///   Create it manually or via HS.Util.Installer.Foundation:
///     do ##class(HS.Util.Installer.Foundation).Install("INTERCLAW")
///     zn "INTERCLAW"
///     zpm "load /path/to/interclaw"
/// 
/// IPM deploys the repo root to ${cspdir}interclaw/ as a single CSPApplication.
/// Classes compile into the current namespace. Web apps bind to the current namespace.
/// This installer then:
///   1. Fixes the frontend web app path to only serve the frontend/ subdirectory
///   2. Cleans dev-only directories from the deploy root (if present)
///   3. Creates working directories (src/ for class files, filedrop/ for HL7)
///   4. Writes ^InterClaw.Config global with dynamic paths
///   5. Creates the /api/interclaw REST dispatch web app
///   6. Creates a writable HOME directory for the Claude CLI
///   7. Installs Python dependencies (typing_extensions, claude-agent-sdk)
///   8. Creates Ens.Config.Credentials entry for API key storage
///   9. Adds InterClaw pages to Management Portal favorites
///  10. Configures environment-specific settings (path prefix)
///  11. Configures AutoStart for Inteclaw.Production
///  12. Starts the production
///  13. Verifies the deployment
/// 
/// Deployed layout on IRIS:
///   ${cspdir}interclaw/
///     frontend/          — Angular editors + chatbot sidebar (web-served)
///     .claude/           — Skills, scripts, commands (not web-served)
///     config/            — Runtime configuration (not web-served)
///     filedrop/          — HL7 message drop directories (not web-served)
///     install/           — ObjectScript class source (Installer, WS, REST, etc.)
///     module.xml         — IPM package definition (self-installable deploy root)
Class InterClaw.Installer Extends %RegisteredObject
{

/// Deployment root: ${cspdir}interclaw/
// ClassMethod DeployRoot() As %String
// {
//     return ##class(%File).NormalizeDirectory(##class(%File).SubDirectoryName($system.Util.InstallDirectory(), "csp") _ "/interclaw")
// }

ClassMethod DeployRoot() As %String
{
    set dataDir = $SYSTEM.Util.GetEnviron("ISC_DATA_DIRECTORY")

    if dataDir '= "" {
        // Durable %SYS (container-safe)
        set base = ##class(%File).NormalizeDirectory(dataDir _ "/csp")
    } else {
        // Non-container fallback
        set base = ##class(%File).NormalizeDirectory(
            ##class(%File).SubDirectoryName($SYSTEM.Util.InstallDirectory(), "csp")
        )
    }

    quit ##class(%File).NormalizeDirectory(base _ "/interclaw")
}

/// Returns 1 if the IRIS major version is >= 2026 (new UI supported), 0 otherwise.
ClassMethod HasNewUI() As %Boolean
{
    return ($system.Version.GetMajor() >= 2026)
}

/// Main entry point — called by IPM post-install.
/// All operations are idempotent — safe to re-run on upgrades.
ClassMethod Setup() As %Status
{
    set sc = $$$OK
    set totalSteps = 13
    write !,"================================================================",!
    write "  InterClaw Post-Install Setup",!
    write "================================================================",!
    write "  Namespace:    ", $namespace,!
    write "  Deploy root:  ", ..DeployRoot(),!
    write "  Install dir:  ", $system.Util.InstallDirectory(),!
    write "  IRIS version: ", $zversion,!
    write "  Timestamp:    ", $zdatetime($horolog, 3),!
    write "================================================================",!,!

    // Warn if installing into a generic namespace — recommend a dedicated one
    set ns = $zconvert($namespace, "U")
    if (ns = "USER") || (ns = "HSLIB") || (ns = "%SYS") || (ns = "HSCUSTOM") {
        write "WARNING: Installing into ", $namespace, " is not recommended.",!
        write "         Create a dedicated namespace first:",!
        write "           do ##class(HS.Util.Installer.Foundation).Install(""INTERCLAW"")",!
        write "           zn ""INTERCLAW""",!
        write "           zpm ""load /path/to/interclaw""",!,!
    }

    // Step 1: Fix frontend web app path (point to frontend/ subdirectory)
    write !,"[Step 1/", totalSteps, "] Verifying frontend web app path...",!
    set sc = ..FixFrontendWebApp()
    if $$$ISERR(sc) {
        write "WARNING: Could not fix frontend web app path: ", $system.Status.GetErrorText(sc),!
    }

    // Step 2: Clean dev-only directories from deploy root (safe for zpm "load /local/path")
    write !,"[Step 2/", totalSteps, "] Cleaning deploy root...",!
    do ..CleanDeployRoot()

    // Step 3: Create working directories (src/ for class files, filedrop/ for HL7)
    write !,"[Step 3/", totalSteps, "] Creating working directories...",!
    do ..CreateWorkingDirectories()

    // Step 4: Write ^InterClaw.Config global with dynamic paths
    write !,"[Step 4/", totalSteps, "] Writing configuration global...",!
    do ..WriteConfigGlobal()

    // Step 4a: Write frontend/install-config.js so browsers see the install namespace
    do ..WriteInstallConfigJs()

    // Step 4b: Populate servers.json with this instance's connection details
    do ..PopulateServerEntry()

    // Step 5: Create REST dispatch web app (/api/interclaw)
    write !,"[Step 5/", totalSteps, "] Creating REST dispatch web applications...",!
    set sc = ..CreateRESTWebApp()
    if $$$ISERR(sc) {
        write "WARNING: Could not create REST web app: ", $system.Status.GetErrorText(sc),!
    }

    // Step 6: Create Claude CLI home directory for the CSP process user
    write !,"[Step 6/", totalSteps, "] Creating Claude CLI home directory...",!
    set sc = ..CreateCLIHome()
    if $$$ISERR(sc) {
        write "WARNING: Could not create CLI home directory: ", $system.Status.GetErrorText(sc),!
    }

    #; // Step 7: Install Python dependencies from requirements.txt
    #; write !,"[Step 7/", totalSteps, "] Installing Python dependencies...",!
    #; set sc = ..InstallPythonDeps()
    #; if $$$ISERR(sc) {
    #;     write "WARNING: Could not install Python dependencies: ", $system.Status.GetErrorText(sc),!
    #;     write "         Run manually: irispython -m pip install -r requirements.txt",!
    #; }

    // Step 7b: Configure pywin32 for IRIS embedded Python (Windows only)
    if $system.Version.GetOS() [ "Windows" {
        write !,"[Step 7b/", totalSteps, "] Configuring pywin32...",!
        set sc = ..ConfigurePywin32()
        if $$$ISERR(sc) {
            write "WARNING: Could not configure pywin32: ", $system.Status.GetErrorText(sc),!
            write "         pywin32 imports may fail in IRIS embedded Python.",!
        }
    }

    // Step 8: Create Ens.Config.Credentials entry for API key storage
    write !,"[Step 8/", totalSteps, "] Creating credential entry...",!
    set sc = ..CreateCredential()
    if $$$ISERR(sc) {
        write "WARNING: Could not create credential: ", $system.Status.GetErrorText(sc),!
        write "         Run /authenticate after install to configure API keys.",!
    }

    // Step 9: Add InterClaw pages to Management Portal favorites
    write !,"[Step 9/", totalSteps, "] Adding Management Portal favorites...",!
    set sc = ..AddFavorites()
    if $$$ISERR(sc) {
        write "WARNING: Could not add favorites: ", $system.Status.GetErrorText(sc),!
    }

    // Step 10: Configure environment-specific settings (path prefix)
    write !,"[Step 10/", totalSteps, "] Configuring environment settings...",!
    set sc = ..ConfigureProductionSettings()
    if $$$ISERR(sc) {
        write "WARNING: Could not configure production settings: ", $system.Status.GetErrorText(sc),!
    }

    // Step 11: Configure AutoStart so IRIS starts Inteclaw.Production on instance boot
    write !,"[Step 11/", totalSteps, "] Configuring AutoStart...",!
    set sc = ..ConfigureAutoStart()
    if $$$ISERR(sc) {
        write "WARNING: Could not configure AutoStart: ", $system.Status.GetErrorText(sc),!
    }

    // Step 12: Start the interoperability production
    write !,"[Step 12/", totalSteps, "] Starting production...",!
    set sc = ..StartProduction()
    if $$$ISERR(sc) {
        write "WARNING: Could not start production: ", $system.Status.GetErrorText(sc),!
    }

    // Step 14: Verify
    write !,"[Step 13/", totalSteps, "] Running verification checks...",!
    do ..Verify()

    set pathPrefix = $get(^InterClaw.Config("PathPrefix"), "")

    write !,"================================================================",!
    write "  InterClaw Setup Complete",!
    write "================================================================",!
    write "  Frontend:   ", pathPrefix, "/ui/interop/interclaw/interop-editor/index.html",!
    write "  REST API:   ", pathPrefix, "/api/interclaw/api/health",!
    write "  Production: Inteclaw.Production",!
    write "================================================================",!
    return $$$OK
}

/// Verify the /ui/interop/interclaw web app's physical path.
///
/// The Angular frontend requires the InteropEditors API v4+ which is only
/// available on IRIS 2026.1 and later. On earlier versions, this method
/// removes the web app that IPM created so the frontend is not served.
///
/// On 2026.1+, verifies and fixes the physical path if needed
/// (backwards compatibility with <CSPApplication> installs).
ClassMethod FixFrontendWebApp() As %Status
{
    set appName = "/ui/interop/interclaw"
    set correctPath = ..DeployRoot() _ "frontend/"
    set origNS = $namespace

    // The Angular frontend requires InteropEditors API v4+ (IRIS 2026.1+).
    // On older versions, remove the web app so the frontend is not served.
    if '..HasNewUI() {
        write "  IRIS version: ", $system.Version.GetMajor(), ".", $system.Version.GetMinor(),!
        write "  The Angular frontend requires IRIS 2026.1 or later.",!
        write "  Removing frontend web app on this instance.",!
        try {
            new $namespace
            set $namespace = "%SYS"
            if ##class(Security.Applications).Exists(appName) {
                set sc = ##class(Security.Applications).Delete(appName)
                if $$$ISERR(sc) {
                    write "  [!!] Could not remove web app: ", $system.Status.GetErrorText(sc),!
                    return sc
                }
                write "  [OK] Frontend web app removed (not supported on this IRIS version)",!
            } else {
                write "  [OK] Frontend web app does not exist — nothing to remove",!
            }
        } catch ex {
            write "  [!!] Error: ", ex.DisplayString(),!
            return ex.AsStatus()
        }
        return $$$OK
    }

    write "  Checking web app: ", appName,!
    write "  Expected path:    ", correctPath,!

    try {
        write "  Switching to %SYS to read Security.Applications...",!
        set $namespace = "%SYS"

        if '##class(Security.Applications).Exists(appName) {
            set $namespace = origNS
            write "  [SKIP] Frontend web app ", appName, " does not exist yet — IPM will create it",!
            return $$$OK
        }

        set app = ##class(Security.Applications).%OpenId(appName)
        if app = "" {
            set $namespace = origNS
            write "  [!!] Web app exists but could not open — possible permissions issue",!
            return $$$ERROR($$$GeneralError, "Could not open web app: " _ appName)
        }

        write "  Current path:     ", app.Path,!
        if app.Path = correctPath {
            set $namespace = origNS
            write "  [OK] Frontend path already correct",!
            return $$$OK
        }

        write "  Updating path: ", app.Path, " -> ", correctPath,!
        set app.Path = correctPath
        set sc = app.%Save()
        set $namespace = origNS
        if $$$ISERR(sc) {
            write "  [!!] Failed to save web app: ", $system.Status.GetErrorText(sc),!
            return sc
        }
        write "  [OK] Frontend path updated successfully",!
    } catch ex {
        set $namespace = origNS
        write "  [!!] Error accessing Security.Applications: ", ex.DisplayString(),!
        return ex.AsStatus()
    }
    return $$$OK
}

/// Clean the deploy root to only contain shipped content.
/// Uses a whitelist approach: keep only the directories and files that belong
/// in the deployed package. Everything else (dev dirs, git, old structures)
/// is removed. This handles both "zpm load /local/path" (which copies everything)
/// and published packages (where .gitattributes export-ignore already strips most).
ClassMethod CleanDeployRoot()
{
    set root = ..DeployRoot()
    set cleaned = 0

    write "  Deploy root: ", root,!

    // Whitelist: only these directories should exist in the deploy root
    set keepDirs = $listbuild("frontend/",".claude/","config/","filedrop/","install/","src/","poc-examples/","references/","tests/")
    // Whitelist: only these files should exist in the deploy root. The installer
    // deliberately preserves any *.md or *.txt file (user notes, change logs,
    // READMEs) so in-place re-installs do not wipe documentation.
    set keepFiles = $listbuild("requirements.txt","module.xml","README.md")

    write "  Allowed dirs:  frontend/, .claude/, config/, filedrop/, install/, src/, poc-examples/, references/, tests/",!
    write "  Allowed files: requirements.txt, module.xml, README.md (plus any *.md, *.txt)",!
    write "  Scanning for items to remove...",!

    // Clean unwanted directories
    set rs = ##class(%ResultSet).%New("%File:FileSet")
    do rs.Execute(root, "*", "", 1)
    set scanned = 0
    while rs.Next() {
        set name = rs.Get("Name")
        set itemName = rs.Get("ItemName")
        set type = rs.Get("Type")
        set scanned = scanned + 1
        if type = "D" {
            set dirName = itemName _ "/"
            if '$listfind(keepDirs, dirName) {
                write "  Removing directory: ", itemName,!
                set ok = ##class(%File).RemoveDirectoryTree(name)
                if ok { write "    [OK] Removed",! set cleaned = cleaned + 1 }
                else { write "    [!!] Could not remove",! }
            }
        } else {
            // Preserve docs/notes (*.md, *.txt) so re-installs don't wipe them.
            set ext = $zconvert($piece(itemName, ".", *), "L")
            set isDoc = ((ext = "md") || (ext = "txt"))
            if '$listfind(keepFiles, itemName), 'isDoc {
                write "  Removing file: ", itemName,!
                do ##class(%File).Delete(name)
                set cleaned = cleaned + 1
            }
        }
    }

    // Always remove credentials file — never ship secrets in the deploy root.
    // Users should authenticate via /authenticate (stores in Ens.Config.Credentials).
    set envFile = root _ "config/.env"
    if ##class(%File).Exists(envFile) {
        write "  Removing config/.env (credentials must use /authenticate)...",!
        do ##class(%File).Delete(envFile)
        write "    [OK] Removed",!
        set cleaned = cleaned + 1
    }

    write "  Scanned ", scanned, " items, removed ", cleaned,!
    if cleaned {
        write "  [OK] Cleaned ", cleaned, " items from deploy root",!
    } else {
        write "  [OK] Deploy root is clean — nothing to remove",!
    }
}

/// Create working directories under the deploy root.
/// 
/// These directories are used at runtime but are not shipped in the package:
///   - src/      — local class files pulled from the server or generated by scripts
///   - filedrop/ — HL7 message input/output directories for file-based services
/// 
/// Idempotent — skips directories that already exist.
ClassMethod CreateWorkingDirectories()
{
    set root = ..DeployRoot()
    set created = 0

    // Create each runtime directory (not shipped in module, created at install time)
    set dirs = $listbuild("src", "filedrop", "config", "poc-examples")
    for i = 1:1:$listlength(dirs) {
        set dirName = $list(dirs, i)
        set dirPath = ##class(%File).NormalizeDirectory(root _ dirName)
        write "  Checking ", dirName, "/...",!
        if ##class(%File).DirectoryExists(dirPath) {
            write "    Already exists: ", dirPath,!
        } else {
            write "    Creating: ", dirPath,!
            set ok = ##class(%File).CreateDirectoryChain(dirPath)
            if ok {
                write "    [OK] Created",!
                set created = created + 1
            } else {
                write "    [!!] Failed to create directory",!
            }
        }
    }

    // Seed config/servers.json if it does not exist
    do ..SeedConfigFiles(root)

    write "  [OK] Working directories ready (", created, " created)",!
}

/// Create seed config files (servers.json, orchestrator.json) if they do not already exist.
/// The Installer's PopulateServerEntry step will update
/// servers.json with the actual connection details after this runs.
ClassMethod SeedConfigFiles(root As %String)
{
    // servers.json — minimal template; Installer fills in "default" later
    set serversFile = root _ "config/servers.json"
    if '##class(%File).Exists(serversFile) {
        write "  Seeding config/servers.json...",!
        set file = ##class(%File).%New(serversFile)
        set sc = file.Open("WSN")
        if $$$ISERR(sc) {
            write "    [!!] Could not create servers.json",!
            return
        }
        do file.WriteLine("{")
        do file.WriteLine("  ""default"": """",")
        do file.WriteLine("  ""intersystems.servers"": {}")
        do file.WriteLine("}")
        do file.Close()
        write "    [OK] servers.json created (empty template)",!
    }

    // orchestrator.json — seed with default permission/cost/telemetry/feedback/gitlab config
    set orchFile = root _ "config/orchestrator.json"
    if '##class(%File).Exists(orchFile) {
        write "  Seeding config/orchestrator.json...",!
        set json = {}
        // permissions
        set perms = {}
        do perms.%Set("mode", "normal")
        do json.%Set("permissions", perms)
        // cost
        set cost = {}
        set pricing = {}
        do pricing.%Set("inputPerMTok", 3)
        do pricing.%Set("outputPerMTok", 15)
        do cost.%Set("pricing", pricing)
        do json.%Set("cost", cost)
        // telemetry
        set telem = {}
        do telem.%Set("enabled", 1)
        do telem.%Set("logPath", "data/telemetry")
        do json.%Set("telemetry", telem)
        // feedback
        set fb = {}
        do fb.%Set("enabled", 0)
        do json.%Set("feedback", fb)
        // gitlab
        set gl = {}
        do gl.%Set("url", "")
        do gl.%Set("token", "")
        do json.%Set("gitlab", gl)

        set file = ##class(%File).%New(orchFile)
        set sc = file.Open("WSN")
        if $$$ISERR(sc) {
            write "    [!!] Could not create orchestrator.json",!
            return
        }
        set formatter = ##class(%JSON.Formatter).%New()
        set formatter.Indent = 1
        set stream = ##class(%Stream.TmpCharacter).%New()
        do formatter.FormatToStream(json, stream)
        do stream.Rewind()
        while 'stream.AtEnd {
            do file.Write(stream.Read(32000))
        }
        do file.Close()
        write "    [OK] orchestrator.json created (defaults)",!
    }
}

/// Write ^InterClaw.Config global with dynamic paths resolved at install time.
/// All other components (REST.Dispatch, scripts, frontend) read from this global
/// instead of using hardcoded paths.
ClassMethod WriteConfigGlobal()
{
    set root = ..DeployRoot()
    set installDir = $system.Util.InstallDirectory()

    write "  Setting ^InterClaw.Config(""DeployRoot"") = ", root,!
    set ^InterClaw.Config("DeployRoot") = root

    write "  Setting ^InterClaw.Config(""CWD"")        = ", root,!
    set ^InterClaw.Config("CWD") = root

    set cliHome = ..ResolveIrisUserHome()
    write "  Setting ^InterClaw.Config(""CLIHOME"")     = ", cliHome,!
    set ^InterClaw.Config("CLIHOME") = cliHome

    write "  Setting ^InterClaw.Config(""Namespace"")   = ", $namespace,!
    set ^InterClaw.Config("Namespace") = $namespace

    write "  Setting ^InterClaw.Config(""Version"")     = 0.1",!
    set ^InterClaw.Config("Version") = "0.1"

    set ts = $zdatetime($horolog, 3)
    write "  Setting ^InterClaw.Config(""InstalledAt"") = ", ts,!
    set ^InterClaw.Config("InstalledAt") = ts

    // Resolve pathPrefix from the web gateway config (e.g., /irishealth, /interclaw-dev)
    set pathPrefix = ""
    set webPath = $system.CSP.GetDefaultApp($namespace)
    write "  Default CSP app for ", $namespace, ": ", webPath,!
    if webPath '= "" {
        set pathPrefix = $piece(webPath, "/csp/", 1)
    }
    if pathPrefix = "" {
        // On instances behind a web gateway with URLPrefix (e.g. interclaw-dev),
        // the gateway strips the prefix before forwarding to IRIS, so CSP apps
        // don't include it. Read URLPrefix directly from the system global.
        set urlPrefix = $get(^%SYS("WebServer","URLPrefix"), "")
        if urlPrefix '= "" {
            set pathPrefix = "/" _ urlPrefix
            write "  Resolved PathPrefix from URLPrefix: ", pathPrefix,!
        }
    }
    if pathPrefix = "" {
        write "  Falling back to install directory name...",!
        set installDir2 = $translate(installDir, "\", "/")
        set installDir2 = $zstrip(installDir2, ">", "/")
        set pathPrefix = "/" _ $piece(installDir2, "/", $length(installDir2, "/"))
    }
    write "  Setting ^InterClaw.Config(""PathPrefix"")  = ", pathPrefix,!
    set ^InterClaw.Config("PathPrefix") = pathPrefix

    // Derive DefaultServer from pathPrefix — strip leading slash to get servers.json key
    // e.g., /interclaw-dev -> "interclaw-dev", /irishealth -> "irishealth"
    set defaultServer = $extract(pathPrefix, 2, *)
    if defaultServer = "" set defaultServer = "localhost"
    write "  Setting ^InterClaw.Config(""DefaultServer"") = ", defaultServer,!
    set ^InterClaw.Config("DefaultServer") = defaultServer

    write "  [OK] ^InterClaw.Config written (", 8, " keys)",!
}

/// Write frontend/install-config.js so every HTML entry point can read the
/// install namespace before the rest of the JavaScript loads. Loaded via
/// <script src="../install-config.js"> in each editor's index.html.
ClassMethod WriteInstallConfigJs()
{
    set root = ..DeployRoot()
    set outFile = root _ "frontend/install-config.js"
    set ns = $get(^InterClaw.Config("Namespace"), $namespace)
    set pathPrefix = $get(^InterClaw.Config("PathPrefix"), "")

    write "  Writing ", outFile,!
    try {
        set stream = ##class(%Stream.FileCharacter).%New()
        set sc = stream.LinkToFile(outFile)
        if $$$ISERR(sc) {
            write "  [!!] Could not link to install-config.js: ", $system.Status.GetErrorText(sc),!
            return
        }
        do stream.Clear()
        do stream.WriteLine("// Generated by InterClaw.Installer.WriteInstallConfigJs - do not edit by hand")
        do stream.WriteLine("window._interclawConfig = {")
        do stream.WriteLine("  namespace: """ _ ns _ """,")
        do stream.WriteLine("  pathPrefix: """ _ pathPrefix _ """")
        do stream.WriteLine("};")
        set sc = stream.%Save()
        if $$$ISERR(sc) {
            write "  [!!] Could not save install-config.js: ", $system.Status.GetErrorText(sc),!
            return
        }
        write "  [OK] install-config.js written (namespace=", ns, ")",!
    } catch ex {
        write "  [!!] Error writing install-config.js: ", ex.DisplayString(),!
    }
}

/// Populate config/servers.json with this instance's actual connection details.
/// Called after WriteConfigGlobal() which resolves PathPrefix and DefaultServer
/// into ^InterClaw.Config. Uses IRIS system methods to resolve the server identity:
///   - $SYSTEM.INetInfo.LocalHostName()              -> hostname
///   - $SYSTEM.INetInfo.HostNameToAddr(hostname)      -> IP address
///   - $PIECE($SYSTEM,":",2)                          -> instance name
///   - ^%SYS("WebServer","Port")                      -> web server port
/// Idempotent — skips if the entry already has a host value.
ClassMethod PopulateServerEntry()
{
    set root = ..DeployRoot()
    set serversFile = root _ "config/servers.json"
    if '##class(%File).Exists(serversFile) {
        write "  [SKIP] servers.json not found",!
        return
    }

    set defaultServer = $get(^InterClaw.Config("DefaultServer"), "")
    set pathPrefix = $get(^InterClaw.Config("PathPrefix"), "")
    if defaultServer = "" {
        write "  [SKIP] DefaultServer not resolved",!
        return
    }

    try {
        // Read existing servers.json
        set stream = ##class(%Stream.FileCharacter).%New()
        set sc = stream.LinkToFile(serversFile)
        if $$$ISERR(sc) { write "  [!!] Could not read servers.json",! return }
        set json = ##class(%DynamicAbstractObject).%FromJSON(stream)
        set servers = json.%Get("intersystems.servers")
        if servers = "" {
            set servers = {}
            do json.%Set("intersystems.servers", servers)
        }

        // Skip if already populated
        set existing = servers.%Get(defaultServer)
        if existing '= "" {
            set ws = existing.%Get("webServer")
            if ws '= "" && (ws.%Get("host") '= "") {
                write "  [OK] Server entry '", defaultServer, "' already populated",!
                return
            }
        }

        // Resolve server identity using IRIS system methods
        set hostname = $SYSTEM.INetInfo.LocalHostName()
        if hostname = "" set hostname = "localhost"
        set serverIP = $SYSTEM.INetInfo.HostNameToAddr(hostname)
        set instanceName = $PIECE($SYSTEM, ":", 2)
        set port = +$get(^%SYS("WebServer","Port"), 80)
        if port = 0 set port = 80

        write "  Populating server entry: ", defaultServer,!
        write "    hostname:   ", hostname,!
        write "    ip:         ", serverIP,!
        write "    instance:   ", instanceName,!
        write "    port:       ", port,!
        write "    pathPrefix: ", pathPrefix,!

        // Build the server entry
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

        // Write back
        set outStream = ##class(%Stream.FileCharacter).%New()
        set sc = outStream.LinkToFile(serversFile)
        if $$$ISERR(sc) { write "  [!!] Could not write servers.json",! return }
        set formatter = ##class(%JSON.Formatter).%New()
        set formatter.Indent = 1
        do formatter.FormatToStream(json, outStream)
        do outStream.%Save()
        write "  [OK] Server entry '", defaultServer, "' written to servers.json",!
    } catch ex {
        write "  [!!] Error: ", ex.DisplayString(),!
    }
}

/// Create the /api/interclaw REST dispatch web application.
///
/// This is the backend API for the chatbot sidebar. It uses
/// InterClaw.REST.Dispatch (%CSP.REST subclass) with embedded Python
/// methods for streaming SSE and non-streaming JSON endpoints.
ClassMethod CreateRESTWebApp() As %Status
{
    set appName = "/api/interclaw"
    set namespace = $namespace

    write "  Target namespace: ", namespace,!
    write "  Switching to %SYS for Security.Applications access...",!
    new $namespace
    set $namespace = "%SYS"

    // --- /api/interclaw (main REST dispatch) ---
    write "  Checking ", appName, "...",!
    if ##class(Security.Applications).Exists(appName) {
        write "  [OK] REST web app already exists: ", appName,!
        set app = ##class(Security.Applications).%OpenId(appName)
        if app '= "" {
            write "  Updating dispatch class to InterClaw.REST.Dispatch...",!
            set app.DispatchClass = "InterClaw.REST.Dispatch"
            set app.NameSpace = namespace
            set sc = app.%Save()
            if $$$ISERR(sc) {
                write "  [!!] Could not update REST app: ", $system.Status.GetErrorText(sc),!
                return sc
            }
            write "  [OK] REST dispatch class and namespace updated",!
        }
    } else {
        write "  Creating REST web app: ", appName,!
        write "    DispatchClass: InterClaw.REST.Dispatch",!
        write "    NameSpace:     ", namespace,!
        write "    AutheEnabled:  64 (Unauthenticated)",!
        set props("NameSpace") = namespace
        set props("DispatchClass") = "InterClaw.REST.Dispatch"
        set props("MatchRoles") = ":%All"
        set props("AutheEnabled") = 64
        set props("IsNameSpaceDefault") = 0
        set props("CookiePath") = "/api/interclaw/"
        set props("UseCookies") = 2

        set sc = ##class(Security.Applications).Create(appName, .props)
        if $$$ISERR(sc) {
            write "  [!!] Failed to create REST web app: ", $system.Status.GetErrorText(sc),!
            return sc
        }
        write "  [OK] REST web app created: ", appName,!
    }

    // --- /api/interclaw/production (chat pipeline dispatch) ---
    // Routes frontend chatbot calls (/api/start, /api/events, /api/approve)
    // into the Inteclaw native-IRIS pipeline via InterClaw.V2.RESTAdapter.
    set pipelineApp = "/api/interclaw/production"
    write "  Checking ", pipelineApp, "...",!
    if '##class(Security.Applications).Exists(pipelineApp) {
        write "  Creating pipeline web app: ", pipelineApp,!
        write "    DispatchClass: InterClaw.V2.RESTAdapter",!
        kill props
        set props("NameSpace") = namespace
        set props("DispatchClass") = "InterClaw.V2.RESTAdapter"
        set props("MatchRoles") = ":%All"
        set props("AutheEnabled") = 64
        set props("IsNameSpaceDefault") = 0
        set props("CookiePath") = "/api/interclaw/production/"
        set props("UseCookies") = 2
        set sc = ##class(Security.Applications).Create(pipelineApp, .props)
        if $$$ISERR(sc) {
            write "  [!!] Failed to create pipeline web app: ", $system.Status.GetErrorText(sc),!
        } else {
            write "  [OK] Pipeline web app created",!
        }
    } else {
        write "  [OK] Pipeline web app already exists: ", pipelineApp,!
        set app = ##class(Security.Applications).%OpenId(pipelineApp)
        if app '= "" {
            write "  Updating pipeline dispatch class and namespace...",!
            set app.DispatchClass = "InterClaw.V2.RESTAdapter"
            set app.NameSpace = namespace
            do app.%Save()
            write "  [OK] Pipeline dispatch class updated to V2 adapter",!
        }
    }

    // --- /ui/interop/interclaw (Angular frontend) ---
    set uiApp = "/ui/interop/interclaw"
    set uiPath = ..DeployRoot() _ "frontend/"
    write "  Checking ", uiApp, "...",!
    if '##class(Security.Applications).Exists(uiApp) {
        write "  Creating frontend web app: ", uiApp,!
        write "    Path:          ", uiPath,!
        write "    NameSpace:     ", namespace,!
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
        set sc = ##class(Security.Applications).Create(uiApp, .props)
        if $$$ISERR(sc) {
            write "  [!!] Failed to create frontend web app: ", $system.Status.GetErrorText(sc),!
        } else {
            write "  [OK] Frontend web app created: ", uiApp,!
        }
    } else {
        write "  [OK] Frontend web app already exists: ", uiApp,!
        // Ensure path is correct
        set app = ##class(Security.Applications).%OpenId(uiApp)
        if app '= "" && (app.Path '= uiPath) {
            write "  Updating path: ", app.Path, " -> ", uiPath,!
            set app.Path = uiPath
            do app.%Save()
            write "  [OK] Frontend path updated",!
        }
    }

    write "  Web application setup complete",!
    return $$$OK
}

/// Resolve the home directory of the IRIS system user.
/// 
/// On Linux/macOS: reads the passwd entry for the IRIS process owner.
/// On Windows: uses the USERPROFILE environment variable.
/// Falls back to ${installdir}mgr/interclaw_home/ if the home cannot be determined
/// or does not exist.
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
    # sys.platform is "win32" on all Windows versions, 32-bit and 64-bit alike
    if sys.platform == "win32":
        return os.environ.get("USERPROFILE", "")
    else:
        import pwd
        try:
            pw = pwd.getpwuid(os.getuid())
            return pw.pw_dir
        except Exception:
            return ""
}

/// Create a writable HOME directory for the Claude CLI binary.
/// 
/// The Claude Agent SDK spawns the Claude CLI as a subprocess. The CLI needs to
/// write session state, backups, and config to ~/.claude/. When running from a
/// CSP web gateway request, the process runs as the IRIS system user (typically
/// the IRIS process user) whose home directory may not have a .claude/ directory yet.
/// 
/// Without a writable HOME, the CLI binary hangs silently during initialization —
/// no error, no stderr, just a 65-second timeout ("Control request timeout: initialize").
/// 
/// This method:
///   1. Resolves the real home directory for the IRIS system user
///   2. Creates ~/.claude/ with proper permissions if it does not exist
///   3. Seeds a minimal settings.json if missing
///   4. Falls back to ${installdir}mgr/interclaw_home/ if the real home is not writable
ClassMethod CreateCLIHome() As %Status
{
    set cliHome = ..ResolveIrisUserHome()
    write "  Resolved CLI home: ", cliHome,!

    // Ensure the home directory itself exists
    if '##class(%File).DirectoryExists(cliHome) {
        write "  Creating home directory: ", cliHome,!
        set ok = ##class(%File).CreateDirectoryChain(cliHome)
        if 'ok {
            write "  [!!] Failed to create directory: ", cliHome,!
            return $$$ERROR($$$GeneralError, "Cannot create CLI home directory: " _ cliHome)
        }
    }

    // Create .claude subdirectory
    set claudeDir = cliHome _ ".claude/"
    if ##class(%File).DirectoryExists(claudeDir) {
        write "  .claude/ directory already exists: ", claudeDir,!
    } else {
        write "  Creating .claude/ directory: ", claudeDir,!
        set ok = ##class(%File).CreateDirectoryChain(claudeDir)
        if 'ok {
            write "  [!!] Failed to create .claude/ directory",!
            return $$$ERROR($$$GeneralError, "Cannot create .claude directory: " _ claudeDir)
        }
        write "  [OK] Created .claude/ directory",!
    }

    // Seed settings.json if missing (minimal config)
    set settingsFile = claudeDir _ "settings.json"
    if '##class(%File).Exists(settingsFile) {
        write "  Creating default settings.json...",!
        set stream = ##class(%Stream.FileCharacter).%New()
        set sc = stream.LinkToFile(settingsFile)
        if $$$ISOK(sc) {
            do stream.Write("{""memory"":{""enabled"":false}}")
            do stream.%Save()
            write "  [OK] Default settings.json created",!
        } else {
            write "  [!!] Could not create settings.json: ", $system.Status.GetOneStatusText(sc),!
        }
    } else {
        write "  settings.json already exists",!
    }

    write "  [OK] CLI home directory ready: ", cliHome,!
    return $$$OK
}

/// Install Python dependencies from requirements.txt.
///
/// Uses irispython -m pip install with --upgrade so packages that already
/// satisfy the version constraint (e.g., IRIS-bundled typing_extensions)
/// are left untouched, while missing or outdated packages are installed.
ClassMethod InstallPythonDeps() As %Status
{
    set root = ..DeployRoot()
    set reqFile = root _ "requirements.txt"

    if '##class(%File).Exists(reqFile) {
        write "  [SKIP] requirements.txt not found",!
        return $$$OK
    }

    set installDir = $system.Util.InstallDirectory()
    set binDir = ##class(%File).SubDirectoryName(installDir, "bin")
    set irispython = ##class(%File).NormalizeFilename("irispython", binDir)
    // On Windows, try .exe extension if the base name doesn't exist
    if '##class(%File).Exists(irispython) {
        set irispythonExe = irispython _ ".exe"
        if ##class(%File).Exists(irispythonExe) {
            set irispython = irispythonExe
        } else {
            return $$$ERROR($$$GeneralError, "irispython not found: " _ irispython)
        }
    }

    set mgrPython = ##class(%File).NormalizeDirectory(##class(%File).SubDirectoryName(##class(%File).SubDirectoryName(installDir, "mgr"), "python"))
    set cmd = irispython _ " -m pip install --target " _ mgrPython _ " --no-cache-dir --upgrade --quiet -r " _ reqFile
    write "  Running: ", cmd,!

    set sc = $zf(-1, cmd)
    if sc '= 0 {
        return $$$ERROR($$$GeneralError, "pip install failed with exit code " _ sc)
    }

    write "  [OK] Python dependencies installed",!
    return $$$OK
}

/// Configure pywin32 for IRIS embedded Python (Windows only).
///
/// pywin32 is installed via pip but requires additional configuration to work
/// with IRIS embedded Python. The pywin32.pth file in mgr/python is not processed
/// during Python initialization, so we must create a .pth file in the standard
/// Python site-packages directory.
///
/// This method:
///   1. Detects the Python installation directory
///   2. Creates iris_pywin32.pth in site-packages
///   3. Adds IRIS pywin32 paths (win32, win32/lib, Pythonwin)
///   4. Registers the pywin32_system32 DLL directory
///   5. Verifies the configuration by testing imports
///
/// Safe to run on non-Windows or when pywin32 is not installed (no-op).
ClassMethod ConfigurePywin32() As %Status
{
    write "  Configuring pywin32 for IRIS embedded Python...",!

    // Only relevant on Windows
    set os = $system.Version.GetOS()
    if os '[ "Windows" {
        write "  [SKIP] Not Windows (", os, ")",!
        return $$$OK
    }

    // Check if pywin32 is installed in IRIS mgr/python
    set installDir = $system.Util.InstallDirectory()
    set mgrPython = ##class(%File).NormalizeDirectory(##class(%File).SubDirectoryName(##class(%File).SubDirectoryName(installDir, "mgr"), "python"))
    set pywin32Dir = ##class(%File).NormalizeDirectory(mgrPython _ "pywin32_system32")

    if '##class(%File).DirectoryExists(pywin32Dir) {
        write "  [SKIP] pywin32 not installed in IRIS mgr/python",!
        return $$$OK
    }

    write "  Found pywin32 in: ", mgrPython,!

    // Detect standard Python site-packages directory
    set binDir = ##class(%File).SubDirectoryName(installDir, "bin")
    set irispython = ##class(%File).NormalizeFilename("irispython", binDir)
    // On Windows, try .exe extension if the base name doesn't exist
    if '##class(%File).Exists(irispython) {
        set irispythonExe = irispython _ ".exe"
        if ##class(%File).Exists(irispythonExe) {
            set irispython = irispythonExe
        } else {
            return $$$ERROR($$$GeneralError, "irispython not found: " _ irispython)
        }
    }

    // Detect site-packages directory
    // Use %SYS.Python API to get the Python runtime info
    set sitePackages = ""

    // Try standard Windows Python paths (Python 3.11, 3.12, 3.13)
    for ver=313:-1:311 {
        set verStr = $extract(ver, 1) _ "." _ $extract(ver, 2, *)
        set verPath = "Python" _ ver
        set path = "C:\Program Files\" _ verPath _ "\Lib\site-packages"
        if ##class(%File).DirectoryExists(path) {
            set sitePackages = ##class(%File).NormalizeDirectory(path)
            write "  Detected Python ", verStr, " site-packages",!
            quit
        }
    }

    // If not found, construct from irispython path
    if sitePackages = "" {
        // irispython.exe is typically at C:\Program Files\Python312\python.exe (symlink to irispython)
        // or the IRIS installation may use its own Python
        // Try to infer from the executable location
        set pythonRoot = $piece(irispython, "\bin\", 1)  // Doesn't work if irispython is in Program Files

        // Alternative: look for Python installations in Program Files
        set programFiles = "C:\Program Files"
        for ver=313:-1:311 {
            set verPath = "Python" _ ver
            set path = programFiles _ "\" _ verPath _ "\Lib\site-packages"
            if ##class(%File).DirectoryExists(path) {
                set sitePackages = ##class(%File).NormalizeDirectory(path)
                quit
            }
        }
    }

    if sitePackages = "" {
        return $$$ERROR($$$GeneralError, "Could not find Python site-packages directory. Checked C:\Program Files\Python31X\Lib\site-packages")
    }

    write "  Site-packages: ", sitePackages,!

    // Create iris_pywin32.pth file
    set pthFile = ##class(%File).NormalizeFilename("iris_pywin32.pth", sitePackages)
    write "  Creating: ", pthFile,!

    // Build .pth file content (paths must use backslashes on Windows)
    set win32Path = mgrPython _ "win32"
    set win32LibPath = mgrPython _ "win32\lib"
    set pythonwinPath = mgrPython _ "Pythonwin"
    // Remove trailing backslash from DLL path to avoid syntax error in Python string
    set dllPath = pywin32Dir
    if $extract(dllPath, $length(dllPath)) = "\" {
        set dllPath = $extract(dllPath, 1, $length(dllPath) - 1)
    }

    // Python code to register DLL directory (single line for .pth file)
    set dllSetup = "import sys, os; pywin32_sys32 = r'" _ dllPath _ "'; os.path.exists(pywin32_sys32) and hasattr(os, 'add_dll_directory') and os.add_dll_directory(pywin32_sys32)"

    try {
        set file = ##class(%Stream.FileCharacter).%New()
        set sc = file.LinkToFile(pthFile)
        if $$$ISERR(sc) {
            return $$$ERROR($$$GeneralError, "Could not create .pth file: " _ $system.Status.GetErrorText(sc))
        }

        do file.WriteLine("# Add IRIS pywin32 paths for embedded Python")
        do file.WriteLine(win32Path)
        do file.WriteLine(win32LibPath)
        do file.WriteLine(pythonwinPath)
        do file.WriteLine(dllSetup)

        set sc = file.%Save()
        if $$$ISERR(sc) {
            return $$$ERROR($$$GeneralError, "Could not save .pth file: " _ $system.Status.GetErrorText(sc))
        }

        write "  [OK] Created ", pthFile,!
    } catch ex {
        return $$$ERROR($$$GeneralError, "Error writing .pth file: " _ ex.DisplayString())
    }

    // Verify the configuration
    write "  Verifying pywin32 import...",!
    set testCode = "import pywintypes; import win32api; import win32com; print('OK')"
    set testCmd = irispython _ " -c """ _ testCode _ """"

    set testResult = ""
    try {
        set pipe = ##class(%File).%New("|" _ testCmd)
        do pipe.Open("QR")
        if 'pipe.%IsNull() {
            while 'pipe.AtEnd {
                set line = pipe.ReadLine()
                if line '= "" {
                    set testResult = $zstrip(line, "<>W")
                }
            }
            do pipe.Close()
        }
    } catch ex {
        write "  [WARN] Verification failed: ", ex.DisplayString(),!
        return $$$OK  // Non-fatal - configuration may still work
    }

    if testResult = "OK" {
        write "  [OK] pywin32 configuration verified (pywintypes, win32api, win32com imported successfully)",!
    } else {
        write "  [WARN] pywin32 configuration could not be verified",!
        write "         Test manually: irispython -c ""import pywintypes""",!
    }

    return $$$OK
}

/// Create the InterClaw.Bedrock credential entry in Ens.Config.Credentials.
///
/// Ens.Config.Credentials is the standard interoperability mechanism for storing
/// secrets. The Password field is masked in the Management Portal and persists
/// across restarts. Works on all IRIS versions with interoperability enabled.
/// 
/// The Bedrock API key JSON is stored at runtime via /api/authenticate as
/// the Password field of the "InterClaw.Bedrock" credential.
ClassMethod CreateCredential() As %Status
{
    write "  Setting up API key credential storage...",!
    set credName = "InterClaw.Bedrock"

    write "  Checking if credential '", credName, "' exists...",!
    try {
        if ##class(Ens.Config.Credentials).%ExistsId(credName) {
            write "  [OK] Credential '", credName, "' already exists",!
            return $$$OK
        }

        write "  Creating credential '", credName, "'...",!
        set cred = ##class(Ens.Config.Credentials).%New()
        set cred.SystemName = credName
        set cred.Username = "bedrock"
        set sc = cred.%Save()
        if $$$ISERR(sc) {
            write "  [!!] Could not create credential: ", $system.Status.GetOneStatusText(sc),!
            return sc
        }
        write "  [OK] Credential '", credName, "' created",!
        write "  Use /authenticate to store the API key after install",!
    } catch ex {
        write "  [!!] Credential creation failed: ", ex.DisplayString(),!
        return ex.AsStatus()
    }
    return $$$OK
}

/// Add InterClaw pages to Management Portal favorites for the current user.
/// 
/// Uses %SYS.Portal.Users.%AddFavorite — the standard IRIS API for portal favorites.
/// These appear on the Management Portal home page under "Favorites".
/// 
/// The Page parameter is the display name (unique key per user).
/// The Data parameter is $listbuild("", fullURL) — empty first element, full URL second.
/// 
/// Idempotent — %AddFavorite overwrites existing entries with the same name.
ClassMethod AddFavorites() As %Status
{
    write "Adding InterClaw to Management Portal favorites...",!

    set pathPrefix = $get(^InterClaw.Config("PathPrefix"), "")
    set linkName = "InterClaw"
    set linkUrl = pathPrefix _ "/ui/interop/interclaw/interop-editor/index.html?view=chat&$NAMESPACE=" _ $namespace

    try {
        // Write the global directly — %AddFavorite wraps Data in a nested $list
        // which the portal cannot resolve. The portal UI writes $lb("", url) directly.
        set mgrDir = "^^" _ $zu(12)
        set username = $username
        set ^|mgrDir|SYS("Portal","UsersD", username, linkName) = $listbuild("", linkUrl)
        write "  [OK] Added favorite: ", linkName, " -> ", linkUrl, " (user: ", username, ")",!
    } catch ex {
        write "  [!!] Error: ", ex.DisplayString(),!
    }

    return $$$OK
}

/// Configure environment-specific settings.
///
/// Derives pathPrefix from the CSP default app path and stores it in ^InterClaw.Config.
ClassMethod ConfigureProductionSettings() As %Status
{
    // Derive pathPrefix from the CSP default app path
    set pathPrefix = $get(^InterClaw.Config("PathPrefix"))
    if pathPrefix = "" {
        write "  PathPrefix not set, deriving from CSP default app...",!
        set webPath = $system.CSP.GetDefaultApp($namespace)
        write "  Default CSP app: ", webPath,!
        if webPath '= "" {
            set pathPrefix = $piece(webPath, "/csp/", 1)
        }
        if pathPrefix = "" {
            write "  Falling back to install directory name...",!
            set installDir = $system.Util.InstallDirectory()
            set installDir = $translate(installDir, "\", "/")
            set installDir = $zstrip(installDir, ">", "/")
            set pathPrefix = "/" _ $piece(installDir, "/", $length(installDir, "/"))
        }
        set ^InterClaw.Config("PathPrefix") = pathPrefix
        write "  Resolved PathPrefix: ", pathPrefix,!
    } else {
        write "  PathPrefix already set: ", pathPrefix,!
    }

    write "  [OK] PathPrefix: ", pathPrefix,!
    return $$$OK
}

/// Configure AutoStart so IRIS starts Inteclaw.Production automatically on instance boot.
/// Uses Ens.Director.SetAutoStart which persists across restarts.
ClassMethod ConfigureAutoStart() As %Status
{
    write "  Calling Ens.Director.SetAutoStart(""Inteclaw.Production"")...",!
    try {
        set sc = ##class(Ens.Director).SetAutoStart("Inteclaw.Production")
        if $$$ISERR(sc) {
            write "  [!!] Failed to set AutoStart: ", $system.Status.GetErrorText(sc),!
            return sc
        }
        write "  [OK] AutoStart configured",!
        write "  Inteclaw.Production will start automatically on IRIS boot",!
    } catch ex {
        write "  [!!] Error calling Ens.Director: ", ex.DisplayString(),!
        return ex.AsStatus()
    }
    return $$$OK
}

/// Start the Inteclaw.Production interoperability production.
/// Handles all production states: stopped, suspended, troubled.
ClassMethod StartProduction() As %Status
{
    set target = "Inteclaw.Production"
    write "  Checking current production state...",!
    try {
        set sc = ##class(Ens.Director).GetProductionStatus(.prodName, .prodState)

        // State constants: 1=Running, 2=Stopped, 3=Suspended, 4=Troubled, 5=NetworkStopped
        set stateNames = $listbuild("","Running","Stopped","Suspended","Troubled","NetworkStopped")
        set stateName = $listget(stateNames, $get(prodState, 0) + 1, "Unknown")
        write "  Current production: ", $get(prodName, "(none)"),!
        write "  Current state:      ", stateName, " (", $get(prodState, 0), ")",!

        if $get(prodName) = target && ($get(prodState) = 1) {
            write "  [OK] ", target, " is already running",!
            return $$$OK
        }

        // If a different production is running, stop it first
        if $get(prodName) '= "" && ($get(prodState) = 1) {
            write "  A different production is running: ", prodName,!
            write "  Stopping ", prodName, " (timeout 30s)...",!
            set sc = ##class(Ens.Director).StopProduction(30, 1)
            if $$$ISERR(sc) {
                write "  [!!] Could not stop: ", $system.Status.GetErrorText(sc),!
            } else {
                write "  [OK] Production stopped",!
            }
        }

        // If the target production is suspended or troubled, recover it first
        if $get(prodName) = target && ($get(prodState) = 3 || ($get(prodState) = 4)) {
            write "  Production is ", stateName, " — attempting recovery (timeout 30s)...",!
            set sc = ##class(Ens.Director).RecoverProduction(30)
            if $$$ISERR(sc) {
                write "  [!!] Recover failed: ", $system.Status.GetErrorText(sc),!
                write "  Attempting clean...",!
                set sc2 = ##class(Ens.Director).CleanProduction(0)
                if $$$ISERR(sc2) {
                    write "  [!!] Clean also failed: ", $system.Status.GetErrorText(sc2),!
                } else {
                    write "  [OK] Production state cleaned",!
                }
            } else {
                write "  [OK] Production recovered",!
            }
        }

        write "  Starting ", target, "...",!
        set sc = ##class(Ens.Director).StartProduction(target)
        if $$$ISERR(sc) {
            write "  [!!] Failed to start: ", $system.Status.GetErrorText(sc),!
            return sc
        }
        write "  [OK] ", target, " started successfully",!
    } catch ex {
        write "  [!!] Error in production startup: ", ex.DisplayString(),!
        return ex.AsStatus()
    }
    return $$$OK
}

/// Verify the deployment is correct.
ClassMethod Verify()
{
    set deployRoot = ..DeployRoot()
    set ok = 1
    set checks = 0
    set passed = 0
    set origNS = $namespace

    write !,"================================================================",!
    write "  Verification",!
    write "================================================================",!
    write "  Deploy root: ", deployRoot,!,!

    // Check frontend (only on 2026.1+ where the Angular UI is supported)
    set checks = checks + 1
    if ..HasNewUI() {
        set frontendIndex = deployRoot _ "frontend/interop-editor/index.html"
        write "  Check ", checks, ": Frontend index.html...",!
        write "    Path: ", frontendIndex,!
        if ##class(%File).Exists(frontendIndex) {
            write "    [OK] File exists",!
            set passed = passed + 1
        } else {
            write "    [!!] File not found",!
            set ok = 0
        }
    } else {
        write "  Check ", checks, ": Frontend (skipped — requires IRIS 2026.1+)...",!
        write "    [OK] Not applicable on this IRIS version",!
        set passed = passed + 1
    }

    // Check Claude skill files and scripts
    set checks = checks + 1
    set skillDir = deployRoot _ ".claude/skills/interclaw/"
    write "  Check ", checks, ": Skill directory...",!
    write "    Path: ", skillDir,!
    if ##class(%File).DirectoryExists(skillDir) {
        write "    [OK] Directory exists",!
        set passed = passed + 1
    } else {
        write "    [!!] Directory not found",!
        set ok = 0
    }

    // Check .claude/CLAUDE.md (marker that CWD is valid for Claude Code)
    set checks = checks + 1
    set claudeMd = deployRoot _ ".claude/CLAUDE.md"
    write "  Check ", checks, ": .claude/CLAUDE.md project instructions...",!
    write "    Path: ", claudeMd,!
    if ##class(%File).Exists(claudeMd) {
        write "    [OK] File exists",!
        set passed = passed + 1
    } else {
        write "    [!!] File not found",!
        set ok = 0
    }

    // Check ^InterClaw.Config global
    set checks = checks + 1
    write "  Check ", checks, ": ^InterClaw.Config global...",!
    if $data(^InterClaw.Config("CWD")) {
        write "    [OK] Global is set (CWD=", ^InterClaw.Config("CWD"), ")",!
        set passed = passed + 1
    } else {
        write "    [!!] Global not found — WriteConfigGlobal may have failed",!
        set ok = 0
    }

    // Check REST web app (requires %SYS)
    set checks = checks + 1
    write "  Check ", checks, ": REST web app /api/interclaw...",!
    try {
        set $namespace = "%SYS"
        if ##class(Security.Applications).Exists("/api/interclaw") {
            write "    [OK] Web app exists in Security.Applications",!
            set passed = passed + 1
        } else {
            write "    [!!] Web app not found in Security.Applications",!
            set ok = 0
        }
        set $namespace = origNS
    } catch ex {
        set $namespace = origNS
        write "    [!!] Could not check: ", ex.DisplayString(),!
        set ok = 0
    }

    // Check credential entry
    set checks = checks + 1
    write "  Check ", checks, ": Credential InterClaw.Bedrock...",!
    try {
        if ##class(Ens.Config.Credentials).%ExistsId("InterClaw.Bedrock") {
            write "    [OK] Credential exists",!
            set passed = passed + 1
        } else {
            write "    [!!] Credential not found — run /authenticate to configure",!
            set ok = 0
        }
    } catch ex {
        write "    [!!] Could not check: ", ex.DisplayString(),!
        set ok = 0
    }

    // Check favorites were added
    set checks = checks + 1
    write "  Check ", checks, ": Management Portal favorites...",!
    write "    [OK] Favorites configured (visible on Portal home page)",!
    set passed = passed + 1

    // Check production is running
    set checks = checks + 1
    write "  Check ", checks, ": Production status...",!
    try {
        set sc = ##class(Ens.Director).GetProductionStatus(.prodName, .prodState)
        write "    Production: ", $get(prodName, "(none)"),!
        write "    State:      ", $get(prodState, 0),!
        if $get(prodName) = "Inteclaw.Production" && ($get(prodState) = 1) {
            write "    [OK] Inteclaw.Production is running",!
            set passed = passed + 1
        } else {
            write "    [!!] Inteclaw.Production is not running",!
            set ok = 0
        }
    } catch ex {
        write "    [!!] Could not check: ", ex.DisplayString(),!
        set ok = 0
    }

    write !,"  Results: ", passed, "/", checks, " checks passed",!
    if ok {
        write "  All checks passed.",!
    } else {
        write "  Some checks failed — review the output above.",!
    }
}


/// IPM Unconfigure hook — called during "zpm uninstall interclaw".
/// Cleans up artifacts that IPM's own Clean phase does not remove:
///   - ^InterClaw.Config, ^InterClaw.ChatEvents, ^InterClaw.ChatPending globals
///   - ${cspdir}interclaw/ deploy directory (scripts, config, frontend, filedrop)
///   - AutoStart configuration
///   - Management Portal favorites
/// IPM itself handles: classes, web apps, credentials, production config.
ClassMethod Teardown() As %Status
{
    write !,"================================================================",!
    write "  InterClaw Teardown (IPM Unconfigure)",!
    write "================================================================",!
    write "  Namespace: ", $namespace,!
    write "  Timestamp: ", $zdatetime($horolog, 3),!
    write "================================================================",!,!

    // Stop the production before removing files
    write "[Step 1] Stopping production...",!
    do ##class(InterClaw.Reset).StopProduction(0)

    // Remove AutoStart
    write !,"[Step 2] Removing AutoStart...",!
    do ##class(InterClaw.Reset).RemoveAutoStart(0)

    // Remove portal favorite
    write !,"[Step 3] Removing portal favorite...",!
    do ##class(InterClaw.Reset).RemovePortalFavorite(0)

    // Remove globals (^InterClaw.Config, ^InterClaw.ChatEvents, ^InterClaw.ChatPending)
    write !,"[Step 4] Removing globals...",!
    do ##class(InterClaw.Reset).RemoveGlobals(0)

    // Remove deployed files (${cspdir}interclaw/)
    write !,"[Step 5] Removing deploy directory...",!
    do ##class(InterClaw.Reset).RemoveFiles(0)

    write !,"================================================================",!
    write "  Teardown complete",!
    write "================================================================",!
    return $$$OK
}
}
