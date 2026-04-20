/// InterClaw.Reset — complete cleanup of the InterClaw IPM package.
///
/// Removes all artifacts created by InterClaw.Installer.Setup() and IPM install:
///   - InterClaw.Production (stopped + AutoStart removed)
///   - /api/interclaw/production, /api/interclaw, /ui/interop/interclaw web apps
///   - ${cspdir}interclaw/ deploy directory
///   - ${installdir}mgr/interclaw_home/ (Claude CLI home)
///   - InterClaw.* classes from the current namespace
///   - Portal favorite "InterClaw"
///   - InterClaw.Bedrock and InterClaw.User credentials
///   - ^InterClaw.* and ^Inteclaw.* globals
///
/// Usage:
///   do ##class(InterClaw.Reset).Run()       ; execute
///   do ##class(InterClaw.Reset).Run(1)      ; dry-run
Class InterClaw.Reset Extends %RegisteredObject
{

ClassMethod Run(dryRun As %Boolean = 0) As %Status
{
    set namespace = $namespace
    if dryRun { write "=== InterClaw Reset (DRY RUN) ===",!,! }
    else { write "=== InterClaw Reset ===",!,"Namespace: ", namespace,!,! }

    do ..StopProduction(dryRun)
    do ..RemoveAutoStart(dryRun)
    set sc1 = ..RemoveWebApp("/api/interclaw/production", dryRun)
    set sc2 = ..RemoveWebApp("/api/interclaw", dryRun)
    set sc3 = ..RemoveWebApp("/ui/interop/interclaw", dryRun)
    set sc4 = ..RemoveFiles(dryRun)
    do ..RemoveCLIHome(dryRun)
    set sc5 = ..RemoveClasses(dryRun)
    do ..RemovePortalFavorite(dryRun)
    do ..RemoveCredential(dryRun)
    do ..RemoveGlobals(dryRun)
    do ..TryIPMUninstall(dryRun)

    write !
    if dryRun { write "=== Dry run complete — no changes made ===",! }
    else { write "=== Reset complete ===",! }

    if $$$ISERR(sc1) return sc1
    if $$$ISERR(sc2) return sc2
    if $$$ISERR(sc3) return sc3
    if $$$ISERR(sc4) return sc4
    if $$$ISERR(sc5) return sc5
    return $$$OK
}

ClassMethod RemoveWebApp(appName As %String, dryRun As %Boolean = 0) As %Status
{
    new $namespace
    set $namespace = "%SYS"
    if '##class(Security.Applications).Exists(appName) {
        write "  [SKIP] Web app ", appName, " does not exist",!
        return $$$OK
    }
    if dryRun { write "  [WOULD DELETE] Web app: ", appName,! return $$$OK }
    set sc = ##class(Security.Applications).Delete(appName)
    if $$$ISERR(sc) {
        write "  [ERROR] Failed to delete ", appName, ": ", $system.Status.GetErrorText(sc),!
        return sc
    }
    write "  [DELETED] Web app: ", appName,!
    return $$$OK
}

ClassMethod RemoveFiles(dryRun As %Boolean = 0) As %Status
{
    set cspDir = ##class(%File).NormalizeDirectory(##class(%File).SubDirectoryName($system.Util.InstallDirectory(), "csp"))
    set icDir = ##class(%File).NormalizeDirectory(##class(%File).SubDirectoryName(cspDir, "interclaw"))
    if '##class(%File).DirectoryExists(icDir) {
        write "  [SKIP] Directory does not exist: ", icDir,!
        return $$$OK
    }
    if dryRun { write "  [WOULD DELETE] Directory: ", icDir,! return $$$OK }
    set ok = ##class(%File).RemoveDirectoryTree(icDir)
    if 'ok { write "  [ERROR] Failed to remove: ", icDir,! return $$$ERROR($$$GeneralError, "Failed to remove " _ icDir) }
    write "  [DELETED] Directory: ", icDir,!
    return $$$OK
}

ClassMethod RemoveCLIHome(dryRun As %Boolean = 0)
{
    set paths = $listbuild(##class(%File).NormalizeDirectory(##class(%File).SubDirectoryName(##class(%File).SubDirectoryName($system.Util.InstallDirectory(), "mgr"), "interclaw_home")))
    try {
        set irisUserHome = ##class(InterClaw.Installer).ResolveIrisUserHome()
        if irisUserHome '= "" {
            set claudeDir = ##class(%File).NormalizeDirectory(##class(%File).SubDirectoryName(irisUserHome, ".claude"))
            if '$listfind(paths, claudeDir) set paths = paths _ $listbuild(claudeDir)
        }
    } catch ex {}

    set ptr = 0, removed = 0
    while $listnext(paths, ptr, dirPath) {
        if '##class(%File).DirectoryExists(dirPath) { write "  [SKIP] Does not exist: ", dirPath,! continue }
        if dryRun { write "  [WOULD DELETE] CLI home: ", dirPath,! continue }
        set ok = ##class(%File).RemoveDirectoryTree(dirPath)
        if 'ok { write "  [WARNING] Could not remove: ", dirPath,! }
        else { write "  [DELETED] CLI home: ", dirPath,! set removed = removed + 1 }
    }
    if (removed = 0) && 'dryRun { write "  [SKIP] No CLI home directories found",! }
}

ClassMethod RemoveClasses(dryRun As %Boolean = 0) As %Status
{
    set sc = $$$OK, count = 0
    set stmt = ##class(%SQL.Statement).%New()
    set qsc = stmt.%Prepare("SELECT Name FROM %Dictionary.ClassDefinition WHERE Name %STARTSWITH 'InterClaw.'")
    if $$$ISERR(qsc) {
        write "  [ERROR] Could not query class list: ", $system.Status.GetErrorText(qsc),!
        return qsc
    }
    set rs = stmt.%Execute()
    while rs.%Next() {
        set className = rs.Name, count = count + 1
        if dryRun { write "  [WOULD DELETE] Class: ", className,! }
        else {
            set delSc = $system.OBJ.Delete(className, "/nodisplay")
            if $$$ISERR(delSc) {
                write "  [ERROR] Failed to delete ", className, ": ", $system.Status.GetErrorText(delSc),!
                if $$$ISOK(sc) set sc = delSc
            } else {
                write "  [DELETED] Class: ", className,!
            }
        }
    }
    if count = 0 { write "  [SKIP] No InterClaw.* classes found",! }
    return sc
}

ClassMethod StopProduction(dryRun As %Boolean = 0)
{
    try {
        set sc = ##class(Ens.Director).GetProductionStatus(.prodName, .prodState)
        if ($get(prodName) = "InterClaw.Production") && ($get(prodState) '= 2) {
            if dryRun { write "  [WOULD STOP] Production: ", prodName,! }
            else {
                set sc = ##class(Ens.Director).StopProduction(30, 1)
                if $$$ISERR(sc) { write "  [WARNING] Stop error: ", $system.Status.GetErrorText(sc),! }
                else { write "  [STOPPED] Production: ", prodName,! }
            }
        } else {
            write "  [SKIP] No InterClaw production running",!
        }
    } catch ex {
        write "  [WARNING] Could not check production: ", ex.DisplayString(),!
    }
}

ClassMethod RemoveAutoStart(dryRun As %Boolean = 0)
{
    if dryRun { write "  [WOULD REMOVE] AutoStart for InterClaw.Production",! quit }
    try {
        set current = $get(^Ens.AutoStart)
        if current [ "InterClaw.Production" {
            set newList = ""
            for i = 1:1:$length(current, ",") {
                set item = $zstrip($piece(current, ",", i), "<>W")
                if (item '= "InterClaw.Production") && (item '= "") {
                    set newList = newList _ $select(newList'="":",", 1:"") _ item
                }
            }
            set sc = ##class(Ens.Director).SetAutoStart(newList)
            if $$$ISERR(sc) { write "  [WARNING] Could not remove AutoStart: ", $system.Status.GetErrorText(sc),! }
            else { write "  [REMOVED] AutoStart entry for InterClaw.Production",! }
        } else {
            write "  [SKIP] No InterClaw production in AutoStart",!
        }
    } catch ex {
        write "  [WARNING] AutoStart removal failed: ", ex.DisplayString(),!
    }
}

ClassMethod RemovePortalFavorite(dryRun As %Boolean = 0)
{
    set favName = "InterClaw"
    if dryRun { write "  [WOULD REMOVE] Portal favorite: ", favName,! quit }
    try {
        new $namespace
        set $namespace = "%SYS"
        set sc = ##class(%SYS.Portal.Users).%RemoveFavorite(favName)
        if $$$ISERR(sc) { write "  [WARNING] Could not remove favorite: ", $system.Status.GetErrorText(sc),! }
        else { write "  [REMOVED] Portal favorite: ", favName,! }
    } catch ex {
        write "  [SKIP] Portal favorite removal failed: ", ex.DisplayString(),!
    }
}

ClassMethod RemoveCredential(dryRun As %Boolean = 0)
{
    set names = $listbuild("InterClaw.Bedrock", "InterClaw.User")
    set ptr = 0
    while $listnext(names, ptr, credName) {
        try {
            if dryRun { write "  [WOULD DELETE] Credential: ", credName,! continue }
            if ##class(Ens.Config.Credentials).%ExistsId(credName) {
                set sc = ##class(Ens.Config.Credentials).%DeleteId(credName)
                if $$$ISERR(sc) { write "  [WARNING] Could not delete ", credName, ": ", $system.Status.GetErrorText(sc),! }
                else { write "  [DELETED] Credential: ", credName,! }
            } else {
                write "  [SKIP] Credential ", credName, " does not exist",!
            }
        } catch ex {
            write "  [SKIP] Credential cleanup failed: ", ex.DisplayString(),!
        }
    }
}

ClassMethod RemoveGlobals(dryRun As %Boolean = 0)
{
    set globals = $listbuild(
        "^InterClaw.Config", "^InterClaw.ChatEvents", "^InterClaw.ChatPending",
        "^Inteclaw.ChatEvents", "^Inteclaw.SessionD", "^Inteclaw.SessionI",
        "^Inteclaw.SessionS", "^Inteclaw.SessionPerm", "^Inteclaw.PlanTrace",
        "^Inteclaw.ChatPending", "^Inteclaw.Config")
    set ptr = 0, found = 0
    while $listnext(globals, ptr, globalName) {
        if $data(@globalName) {
            set found = found + 1
            if dryRun { write "  [WOULD DELETE] Global: ", globalName,! }
            else { kill @globalName  write "  [DELETED] Global: ", globalName,! }
        }
    }
    if found = 0 { write "  [SKIP] No InterClaw/Inteclaw globals found",! }
}

ClassMethod TryIPMUninstall(dryRun As %Boolean = 0)
{
    if dryRun { write "  [WOULD RUN] zpm ""uninstall interclaw""",! quit }
    write "  [INFO] To fully unregister from IPM, run: zpm ""uninstall interclaw""",!
}

}
