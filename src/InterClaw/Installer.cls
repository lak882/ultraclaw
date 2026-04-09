/// InterClaw.Installer — Idempotent post-install setup for the InterClaw IPM package.
/// Called by <Invoke Class="InterClaw.Installer" Method="Setup"/> in module.xml.
///
/// IPM deploys the repo root to ${cspdir}interclaw/ as a single CSPApplication.
/// This installer then:
///   1. Fixes the frontend web app path to only serve the frontend/ subdirectory
///   2. Cleans dev-only directories from the deploy root (if present)
///   3. Writes ^InterClaw.Config global with dynamic paths
///   4. Creates the /api/interclaw REST dispatch web app
///   5. Creates a writable HOME directory for the Claude CLI
///   6. Installs Python dependencies
///   7. Creates %Wallet collection for secure API key storage
///   8. Creates IC-TESTING Foundation namespace (sandbox for new users)
///   9. Deploys portal menu integration (EnsLib.Hub + HS.HC.UI.Home)
///  10. Configures AutoStart for InterClaw.Pipeline.Production
///  11. Starts the production
///  12. Verifies the deployment
///
/// Deployed layout on IRIS:
///   ${cspdir}interclaw/
///     frontend/          — Angular editors + chatbot sidebar (web-served)
///     .claude/           — Skills, scripts, commands (not web-served)
///     config/            — Runtime configuration (not web-served)
///     filedrop/          — HL7 message drop directories (not web-served)
Class InterClaw.Installer Extends %RegisteredObject
{

/// Deployment root: ${cspdir}interclaw/
ClassMethod DeployRoot() As %String
{
    return $system.Util.InstallDirectory() _ "csp/interclaw/"
}

/// Main entry point — called by IPM post-install.
/// All operations are idempotent — safe to re-run on upgrades.
ClassMethod Setup() As %Status
{
    set sc = $$$OK
    write "=== InterClaw Post-Install Setup ===",!
    write "  Namespace: ", $namespace,!
    write "  Deploy root: ", ..DeployRoot(),!,!

    // Step 1: Fix frontend web app path (point to frontend/ subdirectory)
    set sc = ..FixFrontendWebApp()
    if $$$ISERR(sc) {
        write "WARNING: Could not fix frontend web app path: ", $system.Status.GetErrorText(sc),!
    }

    // Step 2: Clean dev-only directories from deploy root (safe for zpm "load /local/path")
    do ..CleanDeployRoot()

    // Step 3: Write ^InterClaw.Config global with dynamic paths
    do ..WriteConfigGlobal()

    // Step 4: Create REST dispatch web app (/api/interclaw)
    set sc = ..CreateRESTWebApp()
    if $$$ISERR(sc) {
        write "WARNING: Could not create REST web app: ", $system.Status.GetErrorText(sc),!
    }

    // Step 5: Create Claude CLI home directory for the CSP process user
    set sc = ..CreateCLIHome()
    if $$$ISERR(sc) {
        write "WARNING: Could not create CLI home directory: ", $system.Status.GetErrorText(sc),!
    }

    // Step 6: Install Python dependencies
    set sc = ..InstallPythonDeps()
    if $$$ISERR(sc) {
        write "WARNING: Could not install Python deps: ", $system.Status.GetErrorText(sc),!
    }

    // Step 7: Create %Wallet collection for secure API key storage
    set sc = ..CreateWalletCollection()
    if $$$ISERR(sc) {
        write "WARNING: Could not create wallet collection: ", $system.Status.GetErrorText(sc),!
        write "         Run /authenticate after install to configure API keys.",!
    }

    // Step 8: Create IC-TESTING Foundation namespace (sandbox for new users)
    set sc = ..CreateTestingNamespace()
    if $$$ISERR(sc) {
        write "WARNING: Could not create IC-TESTING namespace: ", $system.Status.GetErrorText(sc),!
    }

    // Step 9: Deploy portal menu integration
    set sc = ..DeployPortalMenu()
    if $$$ISERR(sc) {
        write "WARNING: Could not deploy portal menu: ", $system.Status.GetErrorText(sc),!
    }

    // Step 10: Configure environment-specific production settings (WebSocket URL, ports)
    set sc = ..ConfigureProductionSettings()
    if $$$ISERR(sc) {
        write "WARNING: Could not configure production settings: ", $system.Status.GetErrorText(sc),!
    }

    // Step 11: Configure AutoStart so IRIS starts InterClaw.Pipeline.Production on instance boot
    set sc = ..ConfigureAutoStart()
    if $$$ISERR(sc) {
        write "WARNING: Could not configure AutoStart: ", $system.Status.GetErrorText(sc),!
    }

    // Step 12: Start the interoperability production
    set sc = ..StartProduction()
    if $$$ISERR(sc) {
        write "WARNING: Could not start production: ", $system.Status.GetErrorText(sc),!
    }

    // Step 13: Verify
    do ..Verify()

    write !,"=== Setup Complete ===",!
    write "Frontend: /ui/interop/interclaw/interop-editor/index.html",!
    write "REST API: /api/interclaw/api/health",!
    write "Production: InterClaw.Pipeline.Production (managed by IRIS)",!
    return $$$OK
}

/// Verify the /ui/interop/interclaw web app's physical path.
///
/// With <WebApplication Path="${cspDir}interclaw/frontend/">, the web app should
/// already point to the correct path. This step verifies and fixes if needed
/// (backwards compatibility with <CSPApplication> installs).
ClassMethod FixFrontendWebApp() As %Status
{
    set appName = "/ui/interop/interclaw"
    set correctPath = ..DeployRoot() _ "frontend/"
    set origNS = $namespace

    try {
        set $namespace = "%SYS"

        if '##class(Security.Applications).Exists(appName) {
            set $namespace = origNS
            write "  [SKIP] Frontend web app not found — nothing to fix",!
            return $$$OK
        }

        set app = ##class(Security.Applications).%OpenId(appName)
        if app = "" {
            set $namespace = origNS
            return $$$ERROR($$$GeneralError, "Could not open web app: " _ appName)
        }

        if app.Path = correctPath {
            set $namespace = origNS
            write "  [OK] Frontend path correct: ", correctPath,!
            return $$$OK
        }

        write "  Fixing frontend path: ", app.Path, " -> ", correctPath,!
        set app.Path = correctPath
        set sc = app.%Save()
        set $namespace = origNS
        if $$$ISERR(sc) {
            write "  [!!] Failed to save: ", $system.Status.GetErrorText(sc),!
            return sc
        }
        write "  [OK] Frontend path fixed",!
    } catch ex {
        set $namespace = origNS
        write "  [!!] Error: ", ex.DisplayString(),!
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

    // Whitelist: only these directories should exist in the deploy root
    set keepDirs = $listbuild("frontend/",".claude/","config/","filedrop/")
    // Whitelist: only these files should exist in the deploy root
    set keepFiles = $listbuild("CLAUDE.md","requirements.txt","module.xml")

    // Clean unwanted directories
    set rs = ##class(%ResultSet).%New("%File:FileSet")
    do rs.Execute(root, "*", "", 1)
    while rs.Next() {
        set name = rs.Get("Name")
        set itemName = rs.Get("ItemName")
        set type = rs.Get("Type")
        if type = "D" {
            set dirName = itemName _ "/"
            if '$listfind(keepDirs, dirName) {
                set ok = ##class(%File).RemoveDirectoryTree(name)
                if ok { write "  [OK] Cleaned dir: ", itemName,! set cleaned = cleaned + 1 }
            }
        } else {
            if '$listfind(keepFiles, itemName) {
                do ##class(%File).Delete(name)
                write "  [OK] Cleaned file: ", itemName,!
                set cleaned = cleaned + 1
            }
        }
    }

    // Always remove credentials file — never ship secrets in the deploy root.
    // Users should authenticate via /authenticate (stores in %Wallet).
    set envFile = root _ "config/.env"
    if ##class(%File).Exists(envFile) {
        do ##class(%File).Delete(envFile)
        write "  [OK] Removed config/.env (credentials must be set via /authenticate)",!
        set cleaned = cleaned + 1
    }

    if cleaned {
        write "  [OK] Cleaned ", cleaned, " items from deploy root",!
    } else {
        write "  [OK] Deploy root clean — nothing to remove",!
    }
}

/// Write ^InterClaw.Config global with dynamic paths resolved at install time.
/// All other components (REST.Dispatch, scripts, frontend) read from this global
/// instead of using hardcoded paths.
ClassMethod WriteConfigGlobal()
{
    set root = ..DeployRoot()
    set installDir = $system.Util.InstallDirectory()

    set ^InterClaw.Config("DeployRoot") = root
    set ^InterClaw.Config("CWD") = root
    set ^InterClaw.Config("CLIHOME") = installDir _ "mgr/interclaw_home/"
    set ^InterClaw.Config("Namespace") = $namespace
    set ^InterClaw.Config("Version") = "0.1.0"
    set ^InterClaw.Config("InstalledAt") = $zdatetime($horolog, 3)

    write "  [OK] ^InterClaw.Config written",!
    write "       CWD: ", root,!
    write "       CLIHOME: ", installDir, "mgr/interclaw_home/",!
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

    new $namespace
    set $namespace = "%SYS"

    if ##class(Security.Applications).Exists(appName) {
        write "  [OK] REST web app already exists: ", appName,!
        // Update dispatch class in case it changed
        set app = ##class(Security.Applications).%OpenId(appName)
        if app '= "" {
            set app.DispatchClass = "InterClaw.REST.Dispatch"
            set app.NameSpace = namespace
            set sc = app.%Save()
            if $$$ISERR(sc) {
                write "  [!!] Could not update REST app: ", $system.Status.GetErrorText(sc),!
                return sc
            }
            write "  [OK] REST dispatch class updated",!
        }
        return $$$OK
    }

    write "  Creating REST web app: ", appName,!
    set props("NameSpace") = namespace
    set props("DispatchClass") = "InterClaw.REST.Dispatch"
    set props("MatchRoles") = ":%All"
    set props("AutheEnabled") = 64  // Unauthenticated
    set props("IsNameSpaceDefault") = 0
    set props("CookiePath") = "/api/interclaw/"
    set props("UseCookies") = 2

    set sc = ##class(Security.Applications).Create(appName, .props)
    if $$$ISERR(sc) {
        write "  [!!] Failed to create REST web app: ", $system.Status.GetErrorText(sc),!
        return sc
    }
    write "  [OK] REST web app created: ", appName,!

    // Also create /api/interclaw/production for the chat pipeline dispatch
    set pipelineApp = "/api/interclaw/production"
    if '##class(Security.Applications).Exists(pipelineApp) {
        write "  Creating pipeline web app: ", pipelineApp,!
        kill props
        set props("NameSpace") = namespace
        set props("DispatchClass") = "InterClaw.Pipeline.REST.Dispatch"
        set props("MatchRoles") = ":%All"
        set props("AutheEnabled") = 64  // Unauthenticated
        set props("IsNameSpaceDefault") = 0
        set props("CookiePath") = "/api/interclaw/production/"
        set props("UseCookies") = 2
        set sc = ##class(Security.Applications).Create(pipelineApp, .props)
        if $$$ISERR(sc) {
            write "  [!!] Failed to create pipeline web app: ", $system.Status.GetErrorText(sc),!
        } else {
            write "  [OK] Pipeline web app created: ", pipelineApp,!
        }
    } else {
        write "  [OK] Pipeline web app already exists: ", pipelineApp,!
        // Update dispatch class and namespace
        set app = ##class(Security.Applications).%OpenId(pipelineApp)
        if app '= "" {
            set app.DispatchClass = "InterClaw.Pipeline.REST.Dispatch"
            set app.NameSpace = namespace
            do app.%Save()
            write "  [OK] Pipeline dispatch class updated",!
        }
    }

    // Create /api/ws for WebSocket connections (used by InterClaw.WS.Chat)
    // MatchRoles=:%All is required so the CSP gateway process can access the namespace database
    set wsApp = "/api/ws"
    if '##class(Security.Applications).Exists(wsApp) {
        write "  Creating WebSocket web app: ", wsApp,!
        kill props
        set props("NameSpace") = namespace
        set props("Type") = 2  // CSP application
        set props("CSPZENEnabled") = 1
        set props("AutheEnabled") = 64  // Unauthenticated
        set props("MatchRoles") = ":%All"
        set props("Enabled") = 1
        set props("IsNameSpaceDefault") = 0
        set props("InbndWebServicesEnabled") = 1
        set props("Description") = "WebSocket endpoint for InterClaw chat"
        set sc = ##class(Security.Applications).Create(wsApp, .props)
        if $$$ISERR(sc) {
            write "  [!!] Failed to create WebSocket web app: ", $system.Status.GetErrorText(sc),!
        } else {
            write "  [OK] WebSocket web app created: ", wsApp,!
        }
    } else {
        write "  [OK] WebSocket web app already exists: ", wsApp,!
        // Ensure namespace and MatchRoles are correct
        kill props
        set sc = ##class(Security.Applications).Get(wsApp, .props)
        if $$$ISOK(sc) {
            set props("NameSpace") = namespace
            set props("MatchRoles") = ":%All"
            set sc = ##class(Security.Applications).Modify(wsApp, .props)
            if $$$ISOK(sc) { write "  [OK] WebSocket web app updated for ", namespace,! }
        }
    }

    return $$$OK
}

/// Create a writable HOME directory for the Claude CLI binary.
///
/// The Claude Agent SDK spawns the Claude CLI as a subprocess. The CLI needs to
/// write session state, backups, and config to ~/.claude/. When running from a
/// CSP web gateway request, the process runs as the IRIS system user (typically
/// "irisusr", uid 3000) which does not have a writable home directory.
///
/// Without a writable HOME, the CLI binary hangs silently during initialization —
/// no error, no stderr, just a 65-second timeout ("Control request timeout: initialize").
///
/// This method creates a dedicated home directory at ${installdir}mgr/interclaw_home/
/// owned by the IRIS system user, which InterClaw.REST.Dispatch sets as HOME before
/// calling the SDK.
ClassMethod CreateCLIHome() As %Status
{
    set installDir = $system.Util.InstallDirectory()
    set cliHome = installDir _ "mgr/interclaw_home/"

    write "Creating Claude CLI home directory: ", cliHome,!

    if '##class(%File).DirectoryExists(cliHome) {
        set ok = ##class(%File).CreateDirectoryChain(cliHome)
        if 'ok {
            write "  [!!] Failed to create directory: ", cliHome,!
            return $$$ERROR($$$GeneralError, "Cannot create CLI home directory: " _ cliHome)
        }
    }

    // Create .claude subdirectory (CLI creates the rest on first run)
    set claudeDir = cliHome _ ".claude/"
    if '##class(%File).DirectoryExists(claudeDir) {
        do ##class(%File).CreateDirectoryChain(claudeDir)
    }

    write "  [OK] CLI home directory ready: ", cliHome,!
    return $$$OK
}

/// Install Python dependencies from requirements.txt at deploy root.
///
/// Uses IRIS embedded Python's pip to install into the default site-packages.
/// Idempotent — pip handles already-installed packages gracefully.
ClassMethod InstallPythonDeps() As %Status
{
    set reqFile = ..DeployRoot() _ "requirements.txt"

    if '##class(%File).Exists(reqFile) {
        write "  [SKIP] No requirements.txt found at: ", reqFile,!
        return $$$OK
    }

    write "  Installing Python dependencies from: ", reqFile,!
    try {
        set builtins = ##class(%SYS.Python).Import("builtins")
        set code = "import subprocess, sys; result = subprocess.run([sys.executable, '-m', 'pip', 'install', '-r', '" _ reqFile _ "', '--quiet'], capture_output=True, text=True); print(result.stdout); print(result.stderr) if result.returncode else None"
        do ##class(%SYS.Python).Run(code)
        write "  [OK] Python dependencies installed",!
    } catch ex {
        write "  [!!] pip install failed: ", ex.DisplayString(),!
        return ex.AsStatus()
    }
    return $$$OK
}

/// Create the InterClaw %Wallet collection for secure API key storage.
///
/// The %Wallet stores secrets in the encrypted IRISSECURITY database with
/// resource-based access control and audit logging. This creates:
///   1. An "InterClawWallet" security resource (in %SYS)
///   2. An "InterClaw" wallet collection bound to that resource
///
/// The Bedrock API key is stored at runtime via /api/authenticate as
/// "InterClaw.BedrockKey" (a %Wallet.KeyValue secret).
ClassMethod CreateWalletCollection() As %Status
{
    write "Creating InterClaw wallet collection...",!
    set ns = $namespace

    // Create the security resource in %SYS
    new $namespace
    set $namespace = "%SYS"

    if '##class(Security.Resources).Exists("InterClawWallet") {
        set res = ##class(Security.Resources).%New()
        set res.Name = "InterClawWallet"
        set res.Description = "Protects InterClaw API key storage in %Wallet"
        set res.PublicPermission = "RU"
        set sc = res.%Save()
        if $$$ISERR(sc) {
            write "  [!!] Could not create resource: ", $system.Status.GetErrorText(sc),!
            set $namespace = ns
            return sc
        }
        write "  [OK] Resource InterClawWallet created",!
    } else {
        write "  [OK] Resource InterClawWallet already exists",!
    }
    set $namespace = ns

    // Create the wallet collection
    try {
        if ##class(%Wallet.Collection).Exists("InterClaw") {
            write "  [OK] Wallet collection InterClaw already exists",!
            return $$$OK
        }
        set config = {"Resource": "InterClawWallet"}
        set sc = ##class(%Wallet.Collection).Create("InterClaw", config)
        if $$$ISERR(sc) {
            write "  [!!] Could not create wallet collection: ", $system.Status.GetOneStatusText(sc),!
            return sc
        }
        write "  [OK] Wallet collection InterClaw created",!
    } catch ex {
        write "  [!!] Wallet creation failed: ", ex.DisplayString(),!
        return ex.AsStatus()
    }
    return $$$OK
}

/// Deploy InterClaw menu to the Management Portal via EnsLib.Hub hook.
///
/// Creates package mapping for EnsLib.Hub.UI pointing to the install namespace
/// database, then sets ^EnsLib.Hub=1 in every Ensemble-enabled namespace.
/// This adds an "InterClaw" section to the Interoperability finder menu.
///
/// For HealthShare instances, HS.HC.UI.Home is patched automatically:
/// copies classes from HSLIB via package mapping, injects InterClaw menu.
ClassMethod DeployPortalMenu() As %Status
{
    set origNS = $namespace
    set installDB = $namespace  // convention: DB name matches namespace
    write "Deploying portal menu integration...",!

    // --- Mechanism 1: EnsLib.Hub hook ---
    // Collect Ensemble-enabled namespaces
    set nsList = ""
    set ns = ""
    for {
        set ns = $order(^%SYS("Ensemble","InstalledNamespace",ns))
        quit:ns=""
        if ns = "HSLIB" continue
        set nsList = nsList _ $listbuild(ns)
    }

    // Create package mappings from %SYS
    set hubCount = 0
    try {
        new $namespace
        set $namespace = "%SYS"

        set ptr = 0
        while $listnext(nsList, ptr, ns) {
            // Create EnsLib.Hub.UI package mapping -> install DB
            if '##class(Config.MapPackages).Exists(ns, "EnsLib.Hub.UI") {
                set props("Database") = installDB
                set sc = ##class(Config.MapPackages).Create(ns, "EnsLib.Hub.UI", .props)
                if $$$ISERR(sc) {
                    write "  [!!] EnsLib.Hub mapping failed for ", ns, ": ", $system.Status.GetErrorText(sc),!
                    continue
                }
                kill props
            }

            // Set ^EnsLib.Hub in the target namespace
            new $namespace
            set $namespace = ns
            set ^EnsLib.Hub = 1
            set hubCount = hubCount + 1
        }
    } catch ex {
        write "  [!!] EnsLib.Hub deployment error: ", ex.DisplayString(),!
    }
    set $namespace = origNS
    write "  [OK] EnsLib.Hub menu deployed to ", hubCount, " namespace(s)",!

    // --- Mechanism 2: HS.HC.UI.Home tab (HealthShare only) ---
    // Copies HS.HC.UI classes from HSLIB, injects InterClaw menu branch.
    set sc = ..PatchHSHome()
    if $$$ISERR(sc) {
        write "  [!!] HS.HC.UI.Home patching failed: ", $system.Status.GetErrorText(sc),!
        write "       Fallback: run setup_interclaw_portal.py --server <name> --namespace ", origNS,!
    }

    return $$$OK
}

/// Patch HS.HC.UI.Home to add InterClaw menu items.
///
/// Strategy:
///   1. Create HS.HC.UI package mapping so writes go to the install DB (not HSLIB)
///   2. Export HS.HC.UI classes from HSLIB → import into current namespace
///   3. Add AddInterClawMenu + GetInterClawItems methods via %Dictionary
///   4. Inject the menu call into GetFinderArray
///   5. Compile
///
/// Idempotent — skips if already patched or if not a HealthShare instance.
ClassMethod PatchHSHome() As %Status
{
    // Note: do NOT use "new $namespace" inside "do {} while 0" blocks —
    // ObjectScript new is method-scoped, not block-scoped, so $namespace
    // would stay changed after the block ends.

    set origNS = $namespace
    set installDB = origNS

    // Detect HealthShare by checking HSLIB namespace existence
    set isHS = 0
    set $namespace = "%SYS"
    set isHS = ##class(Config.Namespaces).Exists("HSLIB")
    set $namespace = origNS
    if 'isHS {
        write "  [SKIP] HSLIB namespace not found (not HealthShare)",!
        return $$$OK
    }

    // Check patch state: method existence + injection in GetFinderArray
    set hasMethod = ##class(%Dictionary.MethodDefinition).%ExistsId("HS.HC.UI.Home||AddInterClawMenu")
    set hasInjection = 0
    if hasMethod {
        set mDef = ##class(%Dictionary.MethodDefinition).%OpenId("HS.HC.UI.Home||GetFinderArray")
        if $IsObject(mDef) {
            do mDef.Implementation.Rewind()
            while 'mDef.Implementation.AtEnd {
                if mDef.Implementation.ReadLine() [ "AddInterClawMenu" { set hasInjection = 1 quit }
            }
        }
    }
    if hasMethod && hasInjection {
        write "  [OK] HS.HC.UI.Home already patched",!
        return $$$OK
    }

    // Step 1: Create package mapping HS.HC.UI → install database
    set $namespace = "%SYS"
    if '##class(Config.MapPackages).Exists(origNS, "HS.HC.UI") {
        set props("Database") = installDB
        set sc = ##class(Config.MapPackages).Create(origNS, "HS.HC.UI", .props)
        if $$$ISERR(sc) {
            set $namespace = origNS
            write "  [!!] HS.HC.UI package mapping failed: ", $system.Status.GetErrorText(sc),!
            return sc
        }
        kill props
        write "  Created HS.HC.UI package mapping → ", installDB,!
    } else {
        write "  HS.HC.UI package mapping already exists",!
    }
    set $namespace = origNS

    // Step 2: Export from HSLIB, import into current namespace (skip if already imported)
    if 'hasMethod {
        set exportFile = ##class(%File).TempFilename("xml")
        set classList = "HS.HC.UI.Home.cls,HS.HC.UI.Home.inc,HS.HC.UI.Template.cls,HS.HC.UI.Util.cls,HS.HC.UI.AssigningAuthorities.cls,HS.HC.UI.Installer.Welcome.cls"

        set $namespace = "HSLIB"
        set sc = $system.OBJ.Export(classList, exportFile, "/nodisplay")
        set $namespace = origNS
        if $$$ISERR(sc) {
            write "  [!!] Export from HSLIB failed: ", $system.Status.GetErrorText(sc),!
            return sc
        }

        // Load without compiling (k = keep source only); we compile in Step 5
        set sc = $system.OBJ.Load(exportFile, "k/nodisplay")
        do ##class(%File).Delete(exportFile)
        if $$$ISERR(sc) {
            write "  [!!] Import into ", origNS, " failed: ", $system.Status.GetErrorText(sc),!
            return sc
        }
        write "  Copied HS.HC.UI classes + include from HSLIB",!
    }

    // Step 3: Add InterClaw menu methods via %Dictionary (skip if already added)
    if 'hasMethod {
        set classDef = ##class(%Dictionary.ClassDefinition).%OpenId("HS.HC.UI.Home")
        if '$IsObject(classDef) return $$$ERROR($$$GeneralError, "Cannot open HS.HC.UI.Home")

        set t = $char(9)

        // AddInterClawMenu — creates a collapsible panel
        set m1 = ##class(%Dictionary.MethodDefinition).%New()
        set m1.Name = "AddInterClawMenu"
        set m1.Description = "Add the InterClaw menu branch to the finder array."
        set m1.FormalSpec = "&pData"
        set m1.parent = classDef
        do m1.Implementation.WriteLine(t_"Set n = $Order(pData(""""),-1) + 1")
        do m1.Implementation.WriteLine(t_"Do ..AddMenuBranch(""InterClaw"",""AI Development Assistant"",,""GetInterClawItems"",,,.pData,.n)")

        // GetInterClawItems — populates the sub-menu
        set m2 = ##class(%Dictionary.MethodDefinition).%New()
        set m2.Name = "GetInterClawItems"
        set m2.Description = "Populate the InterClaw sub-menu items."
        set m2.FormalSpec = "pN1,&pData"
        set m2.parent = classDef
        do m2.Implementation.WriteLine(t_"Set tURLPrefix = $Select($IsObject($Get(%request)): %request.URLPrefix, 1: """")")
        do m2.Implementation.WriteLine(t_"Set tLink = tURLPrefix _ ""/ui/interop/interclaw/interop-editor/index.html""")
        do m2.Implementation.WriteLine(t_"Do ..AddOption(""Copilot"",""AI-powered interoperability copilot"",,tLink,,,,.pData,.n2,pN1)")
        do m2.Implementation.WriteLine(t_"Set tLink = tURLPrefix _ ""/ui/interop/interclaw/interop-editor/index.html?view=chat""")
        do m2.Implementation.WriteLine(t_"Do ..AddOption(""Chat"",""Conversational AI assistant"",,tLink,,,,.pData,.n2,pN1)")
        do m2.Implementation.WriteLine(t_"Set tLink = tURLPrefix _ ""/ui/interop/interclaw/skills-editor/index.html""")
        do m2.Implementation.WriteLine(t_"Do ..AddOption(""Skill Editor"",""Edit and manage InterClaw skills"",,tLink,,,,.pData,.n2,pN1)")
        do m2.Implementation.WriteLine(t_"Set tLink = tURLPrefix _ ""/ui/interop/interclaw/message-viewer/index.html""")
        do m2.Implementation.WriteLine(t_"Do ..AddOption(""Traces"",""Message trace viewer"",,tLink,,,,.pData,.n2,pN1)")

        set sc = classDef.%Save()
        if $$$ISERR(sc) {
            write "  [!!] Failed to save InterClaw methods: ", $system.Status.GetErrorText(sc),!
            return sc
        }
        write "  Added AddInterClawMenu + GetInterClawItems methods",!
    }

    // Step 4: Inject call into GetFinderArray (before last "Quit sc")
    set sc = ..InjectHSHomeMenuCall()
    if $$$ISERR(sc) return sc

    // Step 5: Compile all imported classes
    set compileList = "HS.HC.UI.Home,HS.HC.UI.Template,HS.HC.UI.Util,HS.HC.UI.AssigningAuthorities,HS.HC.UI.Installer.Welcome"
    set sc = $system.OBJ.Compile(compileList, "ck/nodisplay")
    if $$$ISERR(sc) {
        write "  [!!] Compile failed: ", $system.Status.GetErrorText(sc),!
        return sc
    }
    write "  [OK] HS.HC.UI.Home compiled with InterClaw menu",!

    return $$$OK
}

/// Inject "Do ..AddInterClawMenu(.pData)" into HS.HC.UI.Home:GetFinderArray
/// before the last "Quit sc" line. Uses %Dictionary stream manipulation.
ClassMethod InjectHSHomeMenuCall() As %Status
{
    // Open class def and find GetFinderArray in its Methods collection
    // (must modify the method through the parent's collection for %Save to persist)
    set classDef = ##class(%Dictionary.ClassDefinition).%OpenId("HS.HC.UI.Home")
    if '$IsObject(classDef) return $$$ERROR($$$GeneralError, "Cannot open HS.HC.UI.Home")

    set methodDef = ""
    for i=1:1:classDef.Methods.Count() {
        set m = classDef.Methods.GetAt(i)
        if m.Name = "GetFinderArray" { set methodDef = m quit }
    }
    if '$IsObject(methodDef) {
        return $$$ERROR($$$GeneralError, "GetFinderArray method not found")
    }

    // Read all lines from Implementation stream
    set stream = methodDef.Implementation
    do stream.Rewind()
    set lineCount = 0
    while 'stream.AtEnd {
        set lineCount = lineCount + 1
        set lines(lineCount) = stream.ReadLine()
    }

    // Already injected?
    for i=1:1:lineCount {
        if lines(i) [ "AddInterClawMenu" {
            write "  Menu call already present in GetFinderArray",!
            return $$$OK
        }
    }

    // Find last "Quit sc" line
    set insertBefore = 0
    for i=lineCount:-1:1 {
        set trimmed = $zstrip(lines(i), "<>W")
        if trimmed = "Quit sc" {
            set insertBefore = i
            quit
        }
    }
    if insertBefore = 0 {
        return $$$ERROR($$$GeneralError, "Cannot find 'Quit sc' in GetFinderArray")
    }

    // Rebuild stream with injected call
    do stream.Clear()
    for i=1:1:lineCount {
        if i = insertBefore {
            do stream.WriteLine($char(9)_"Do ..AddInterClawMenu(.pData)")
        }
        do stream.WriteLine(lines(i))
    }

    // Save parent class definition (persists the modified method stream)
    set sc = classDef.%Save()
    if $$$ISERR(sc) {
        write "  [!!] Failed to save GetFinderArray injection: ", $system.Status.GetErrorText(sc),!
        return sc
    }
    write "  Injected menu call into GetFinderArray",!
    return $$$OK
}

/// Configure environment-specific production settings.
///
/// The production XDATA has generic defaults. This method detects the deployment
/// environment (by matching the IRIS install directory against servers.json entries)
/// and updates runtime settings that differ per instance:
///   - WebSocketURL: ws://localhost/{pathPrefix}/api/ws/InterClaw.WS.Chat.cls
///   - Analytics/Audit ports: derived from base port + offset
///   - SessionForward: disabled by default (irishealth-specific)
///
/// Uses embedded Python to parse servers.json and apply settings via Ens.Config.Production.
ClassMethod ConfigureProductionSettings() As %Status [ Language = python ]
{
    import iris, os, json

    deploy_root = iris.cls('InterClaw.Installer').DeployRoot()
    servers_file = os.path.join(deploy_root, 'config', 'servers.json')
    prod_name = 'InterClaw.Pipeline.Production'

    print('Configuring production settings for', prod_name, '...')

    # Detect path prefix from servers.json
    path_prefix = ''
    install_dir = iris.cls('%SYSTEM.Util').InstallDirectory().lower().rstrip('/')
    dir_name = install_dir.split('/')[-1]  # e.g., "irishealth", "claude-dev"

    if os.path.exists(servers_file):
        with open(servers_file) as f:
            data = json.load(f)
        servers = data.get('intersystems.servers', {})
        for name, cfg in servers.items():
            ws = cfg.get('webServer', {})
            pp = ws.get('pathPrefix', '')
            # Match by install dir name (case-insensitive, dash-insensitive)
            norm_name = name.lower().replace('-', '')
            norm_dir = dir_name.lower().replace('-', '')
            if norm_name == norm_dir:
                path_prefix = pp
                print('  Matched server:', name, '-> pathPrefix:', pp)
                break

    if not path_prefix:
        # Fallback: use install dir name as path prefix
        path_prefix = '/' + dir_name
        print('  No server match; using fallback pathPrefix:', path_prefix)

    # Store in config global for other components
    g = iris.gref('^InterClaw.Config')
    g['PathPrefix'] = path_prefix

    # Build the settings to apply
    ws_url = 'ws://localhost' + path_prefix + '/api/ws/InterClaw.WS.Chat.cls'

    # Open the production config
    prod = iris.cls('Ens.Config.Production')._OpenId(prod_name)
    if prod is None:
        print('  [SKIP] Production', prod_name, 'not found in config — settings will apply on first start')
        return iris.cls('%SYSTEM.Status').OK()

    changed = False
    for i in range(1, prod.Items.Count() + 1):
        item = prod.Items.GetAt(i)
        name = str(item.Name)

        for j in range(1, item.Settings.Count() + 1):
            s = item.Settings.GetAt(j)
            sname = str(s.Name)
            sval = str(s.Value)

            # Update WebSocketURL with correct path prefix
            if name == 'InterClaw.Pipeline.BO.WebSocketOperation' and sname == 'WebSocketURL':
                if sval != ws_url:
                    print('  WebSocketURL:', sval, '->', ws_url)
                    s.Value = ws_url
                    changed = True

    if changed:
        sc = prod._Save()
        if iris.cls('%SYSTEM.Status').IsOK(sc):
            print('  [OK] Production settings updated')
        else:
            print('  [!!] Failed to save production settings')
            return sc
    else:
        print('  [OK] Production settings already correct')

    return iris.cls('%SYSTEM.Status').OK()
}

/// Configure AutoStart so IRIS starts InterClaw.Pipeline.Production automatically on instance boot.
/// Uses Ens.Director.SetAutoStart which persists across restarts.
ClassMethod ConfigureAutoStart() As %Status
{
    write "Configuring AutoStart for InterClaw.Pipeline.Production...",!
    try {
        set sc = ##class(Ens.Director).SetAutoStart("InterClaw.Pipeline.Production")
        if $$$ISERR(sc) {
            write "  [!!] Failed to set AutoStart: ", $system.Status.GetErrorText(sc),!
            return sc
        }
        write "  [OK] AutoStart configured — InterClaw.Pipeline.Production will start on instance boot",!
    } catch ex {
        write "  [!!] Error: ", ex.DisplayString(),!
        return ex.AsStatus()
    }
    return $$$OK
}

/// Start the InterClaw.Pipeline.Production interoperability production.
/// Handles all production states: stopped, suspended, troubled.
ClassMethod StartProduction() As %Status
{
    write "Starting InterClaw.Pipeline.Production...",!
    try {
        set sc = ##class(Ens.Director).GetProductionStatus(.prodName, .prodState)

        // State constants: 1=Running, 2=Stopped, 3=Suspended, 4=Troubled, 5=NetworkStopped
        if $get(prodName) = "InterClaw.Pipeline.Production" && ($get(prodState) = 1) {
            write "  [OK] InterClaw.Pipeline.Production is already running",!
            return $$$OK
        }

        // If a different production is running, stop it first
        if $get(prodName) '= "" && ($get(prodState) = 1) {
            write "  Stopping ", prodName, " to make way for InterClaw.Pipeline.Production...",!
            set sc = ##class(Ens.Director).StopProduction(30, 1)
            if $$$ISERR(sc) {
                write "  [!!] Could not stop: ", $system.Status.GetErrorText(sc),!
            }
        }

        // If InterClaw.Pipeline.Production is suspended or troubled, recover it first
        if $get(prodName) = "InterClaw.Pipeline.Production" && ($get(prodState) = 3 || ($get(prodState) = 4)) {
            write "  Production is ", $select($get(prodState)=3:"Suspended", 1:"Troubled"), " — recovering...",!
            set sc = ##class(Ens.Director).RecoverProduction(30)
            if $$$ISERR(sc) {
                write "  [!!] Recover failed, attempting clean: ", $system.Status.GetErrorText(sc),!
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

        set sc = ##class(Ens.Director).StartProduction("InterClaw.Pipeline.Production")
        if $$$ISERR(sc) {
            write "  [!!] Failed to start: ", $system.Status.GetErrorText(sc),!
            return sc
        }
        write "  [OK] InterClaw.Pipeline.Production started",!
    } catch ex {
        write "  [!!] Error: ", ex.DisplayString(),!
        return ex.AsStatus()
    }
    return $$$OK
}

/// Verify the deployment is correct.
ClassMethod Verify()
{
    set deployRoot = ..DeployRoot()
    set ok = 1
    set origNS = $namespace

    write !,"--- Verification ---",!

    // Check frontend
    set frontendIndex = deployRoot _ "frontend/interop-editor/index.html"
    if ##class(%File).Exists(frontendIndex) {
        write "  [OK] Frontend: interop-editor/index.html",!
    } else {
        write "  [!!] Frontend missing: ", frontendIndex,!
        set ok = 0
    }

    // Check Claude skill files and scripts
    set skillDir = deployRoot _ ".claude/skills/interclaw/"
    if ##class(%File).DirectoryExists(skillDir) {
        write "  [OK] Skill: .claude/skills/interclaw/",!
    } else {
        write "  [!!] Skill files missing: ", skillDir,!
        set ok = 0
    }

    // Check CLAUDE.md (marker that CWD is valid for Claude Code)
    set claudeMd = deployRoot _ "CLAUDE.md"
    if ##class(%File).Exists(claudeMd) {
        write "  [OK] CLAUDE.md present",!
    } else {
        write "  [!!] CLAUDE.md missing: ", claudeMd,!
        set ok = 0
    }

    // Check ^InterClaw.Config global
    if $data(^InterClaw.Config("CWD")) {
        write "  [OK] Config: ^InterClaw.Config written",!
    } else {
        write "  [!!] Config: ^InterClaw.Config not found",!
        set ok = 0
    }

    // Check REST web app (requires %SYS)
    try {
        set $namespace = "%SYS"
        if ##class(Security.Applications).Exists("/api/interclaw") {
            write "  [OK] REST web app: /api/interclaw",!
        } else {
            write "  [!!] REST web app missing: /api/interclaw",!
            set ok = 0
        }
        set $namespace = origNS
    } catch ex {
        set $namespace = origNS
        write "  [!!] REST web app check failed: ", ex.DisplayString(),!
        set ok = 0
    }

    // Check wallet collection
    try {
        if ##class(%Wallet.Collection).Exists("InterClaw") {
            write "  [OK] Wallet: InterClaw collection accessible",!
        } else {
            write "  [!!] Wallet: InterClaw collection not found",!
            set ok = 0
        }
    } catch ex {
        write "  [!!] Wallet: could not check — ", ex.DisplayString(),!
        set ok = 0
    }

    // Check IC-TESTING namespace exists (non-fatal — some instances may not support Foundation)
    try {
        set $namespace = "%SYS"
        if ##class(Config.Namespaces).Exists("IC-TESTING") {
            write "  [OK] Namespace: IC-TESTING",!
        } else {
            write "  [--] Namespace IC-TESTING not created (optional)",!
        }
        set $namespace = origNS
    } catch ex {
        set $namespace = origNS
        write "  [--] IC-TESTING check skipped: ", ex.DisplayString(),!
    }

    // Check portal menu (EnsLib.Hub)
    if $data(^EnsLib.Hub) {
        write "  [OK] Portal: EnsLib.Hub menu active in ", origNS,!
    } else {
        write "  [--] Portal: EnsLib.Hub not set (portal menu not active)",!
    }

    // Check HS.HC.UI.Home patch (HealthShare only)
    if ##class(%Dictionary.MethodDefinition).%ExistsId("HS.HC.UI.Home||AddInterClawMenu") {
        write "  [OK] Portal: HS.HC.UI.Home patched with InterClaw tab",!
    } elseif ##class(%Dictionary.ClassDefinition).%ExistsId("HS.HC.UI.Home") {
        write "  [--] Portal: HS.HC.UI.Home not patched (optional)",!
    }

    // Check production is running
    try {
        set sc = ##class(Ens.Director).GetProductionStatus(.prodName, .prodState)
        if $get(prodName) = "InterClaw.Pipeline.Production" && ($get(prodState) = 1) {
            write "  [OK] Production: InterClaw.Pipeline.Production running",!
        } else {
            write "  [!!] Production InterClaw.Pipeline.Production not running",!
            set ok = 0
        }
    } catch ex {
        write "  [!!] Production check failed: ", ex.DisplayString(),!
        set ok = 0
    }

    if ok {
        write !,"  All checks passed.",!
    } else {
        write !,"  Some checks failed — see above.",!
    }
}

/// Create the IC-TESTING Foundation namespace.
///
/// This gives new users a ready-to-use sandbox namespace for building
/// productions with InterClaw. Uses HS.Util.Installer.Foundation which
/// creates the namespace, database, HSLIB/HSCUSTOM mappings, and enables
/// Interoperability — the same setup as /new-namespace.
///
/// Idempotent: skips if IC-TESTING already exists.
/// Graceful: skips if HS.Util.Installer.Foundation is not available (non-HS instances).
ClassMethod CreateTestingNamespace() As %Status
{
    set nsName = "IC-TESTING"
    set origNS = $namespace
    write "Creating ", nsName, " Foundation namespace...",!

    // Check if HS.Util.Installer.Foundation is available
    if '##class(%Dictionary.ClassDefinition).%ExistsId("HS.Util.Installer.Foundation") {
        write "  [SKIP] HS.Util.Installer.Foundation not available (non-HealthShare instance)",!
        return $$$OK
    }

    // Check if it already exists
    try {
        set $namespace = "%SYS"
        set exists = ##class(Config.Namespaces).Exists(nsName)
        set $namespace = origNS
        if exists {
            write "  [OK] ", nsName, " namespace already exists",!
            return $$$OK
        }
    } catch ex {
        set $namespace = origNS
    }

    // Create via HS.Util.Installer.Foundation (runs in current namespace context)
    try {
        set sc = ##class(HS.Util.Installer.Foundation).Install(nsName)
        if $$$ISERR(sc) {
            write "  [!!] Foundation.Install failed: ", $system.Status.GetErrorText(sc),!
            return sc
        }
        write "  [OK] ", nsName, " Foundation namespace created",!
        write "       Database, HSLIB/HSCUSTOM mappings, Interoperability enabled",!

        // Record in config for frontend default namespace
        set ^InterClaw.Config("DefaultNamespace") = nsName
        write "  [OK] Default namespace set to ", nsName,!
    } catch ex {
        write "  [!!] Error creating namespace: ", ex.DisplayString(),!
        return ex.AsStatus()
    }
    return $$$OK
}

}
