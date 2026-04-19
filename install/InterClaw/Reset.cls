/// InterClaw.Reset — Complete cleanup of the InterClaw IPM package.
/// 
/// Removes all artifacts created by InterClaw.Installer.Setup() and IPM install:
///   - Inteclaw.Production / InterClaw.Pipeline.Production (stopped)
///   - /api/interclaw/production, /api/interclaw, /ui/interop/interclaw web applications
///   - ${cspdir}interclaw/ directory (all deployed files)
///   - ${installdir}mgr/interclaw_home/ (Claude CLI home)
///   - AutoStart configuration
///   - InterClaw.* classes from the current namespace
///   - Portal favorite
///   - InterClaw.Bedrock credential
///   - InterClaw globals (^InterClaw.Config, ^InterClaw.ChatEvents, ^InterClaw.ChatPending)
/// 
/// Usage:
///   NAMESPACE> do ##class(InterClaw.Reset).Run()
///   NAMESPACE> do ##class(InterClaw.Reset).Run(1)   ; dry-run — show what would be removed
Class InterClaw.Reset Extends %RegisteredObject
{

/// Main entry point. Set dryRun=1 to preview without deleting.
ClassMethod Run(dryRun As %Boolean = 0) As %Status
{
    set sc = $$$OK
    set namespace = $namespace

    if dryRun {
        write "=== InterClaw Reset (DRY RUN) ===",!
        write "No changes will be made.",!,!
    } else {
        write "=== InterClaw Reset ===",!
        write "Namespace: ", namespace,!,!
    }

    // Step 0: Stop the production (if running)
    do ..StopProduction(dryRun)

    // Step 1: Remove AutoStart
    do ..RemoveAutoStart(dryRun)

    // Step 2: Remove web applications
    set sc1 = ..RemoveWebApp("/api/interclaw/production", dryRun)
    set sc1b = ..RemoveWebApp("/api/interclaw", dryRun)
    set sc2 = ..RemoveWebApp("/ui/interop/interclaw", dryRun)

    // Step 4: Remove deployed files (${cspdir}interclaw/)
    set sc3 = ..RemoveFiles(dryRun)

    // Step 5: Remove CLI home directory
    do ..RemoveCLIHome(dryRun)

    // Step 6: Remove InterClaw.* classes
    set sc4 = ..RemoveClasses(dryRun)

    // Step 7: Remove portal favorite
    do ..RemovePortalFavorite(dryRun)

    // Step 8: Remove API key credential
    do ..RemoveCredential(dryRun)

    // Step 9: Remove InterClaw globals
    do ..RemoveGlobals(dryRun)

    // Step 10: Try IPM uninstall (may already be done)
    do ..TryIPMUninstall(dryRun)

    write !
    if dryRun {
        write "=== Dry run complete — no changes made ===",!
    } else {
        write "=== Reset complete ===",!
        write "The InterClaw package has been fully removed from ", namespace, ".",!
    }

    // Return first error if any
    if $$$ISERR(sc1) return sc1
    if $$$ISERR(sc1b) return sc1b
    if $$$ISERR(sc2) return sc2
    if $$$ISERR(sc3) return sc3
    if $$$ISERR(sc4) return sc4
    return $$$OK
}

/// Remove a web application by name.
ClassMethod RemoveWebApp(appName As %String, dryRun As %Boolean = 0) As %Status
{
    new $namespace
    set $namespace = "%SYS"

    if '##class(Security.Applications).Exists(appName) {
        write "  [SKIP] Web app ", appName, " does not exist",!
        return $$$OK
    }

    if dryRun {
        write "  [WOULD DELETE] Web app: ", appName,!
        return $$$OK
    }

    set sc = ##class(Security.Applications).Delete(appName)
    if $$$ISERR(sc) {
        write "  [ERROR] Failed to delete web app ", appName, ": ", $system.Status.GetErrorText(sc),!
        return sc
    }

    write "  [DELETED] Web app: ", appName,!
    return $$$OK
}

/// Remove the ${cspdir}interclaw/ directory and all contents.
ClassMethod RemoveFiles(dryRun As %Boolean = 0) As %Status
{
    set cspDir = ##class(%File).NormalizeDirectory(##class(%File).SubDirectoryName($system.Util.InstallDirectory(), "csp"))
    set icDir = ##class(%File).NormalizeDirectory(##class(%File).SubDirectoryName(cspDir, "interclaw"))

    if '##class(%File).DirectoryExists(icDir) {
        write "  [SKIP] Directory does not exist: ", icDir,!
        return $$$OK
    }

    // Count files for reporting
    set fileCount = 0
    set rs = ##class(%ResultSet).%New("%File:FileSet")
    do rs.Execute(icDir, "*", "", 1)
    while rs.Next() { set fileCount = fileCount + 1 }
    do rs.Close()

    if dryRun {
        write "  [WOULD DELETE] Directory: ", icDir, " (", fileCount, " items)",!
        return $$$OK
    }

    set ok = ##class(%File).RemoveDirectoryTree(icDir)
    if 'ok {
        write "  [ERROR] Failed to remove directory: ", icDir,!
        return $$$ERROR($$$GeneralError, "Failed to remove directory: " _ icDir)
    }

    write "  [DELETED] Directory: ", icDir, " (", fileCount, " items)",!
    return $$$OK
}

/// Remove the Claude CLI home directory.
/// Cleans both the fallback path (${installdir}mgr/interclaw_home/) and the
/// actual IRIS process user home path resolved by the Installer.
ClassMethod RemoveCLIHome(dryRun As %Boolean = 0)
{
    // Build list of paths to check: fallback + resolved IRIS user home
    set paths = $listbuild(##class(%File).NormalizeDirectory(##class(%File).SubDirectoryName(##class(%File).SubDirectoryName($system.Util.InstallDirectory(), "mgr"), "interclaw_home")))
    try {
        set irisUserHome = ##class(InterClaw.Installer).ResolveIrisUserHome()
        if irisUserHome '= "" {
            set claudeDir = ##class(%File).NormalizeDirectory(##class(%File).SubDirectoryName(irisUserHome, ".claude"))
            if '$listfind(paths, claudeDir) {
                set paths = paths _ $listbuild(claudeDir)
            }
        }
    } catch ex {
        // Installer may already be deleted during IPM uninstall — skip
    }

    set removed = 0
    set ptr = 0
    while $listnext(paths, ptr, dirPath) {
        if '##class(%File).DirectoryExists(dirPath) {
            write "  [SKIP] Does not exist: ", dirPath,!
            continue
        }
        if dryRun {
            write "  [WOULD DELETE] CLI home: ", dirPath,!
            continue
        }
        set ok = ##class(%File).RemoveDirectoryTree(dirPath)
        if 'ok {
            write "  [WARNING] Could not remove: ", dirPath,!
        } else {
            write "  [DELETED] CLI home: ", dirPath,!
            set removed = removed + 1
        }
    }
    if removed = 0 && 'dryRun {
        write "  [SKIP] No CLI home directories found",!
    }
}

/// Remove InterClaw.* classes from the current namespace.
ClassMethod RemoveClasses(dryRun As %Boolean = 0) As %Status
{
    set sc = $$$OK
    set count = 0

    // Find all InterClaw.* classes
    set stmt = ##class(%SQL.Statement).%New()
    set qsc = stmt.%Prepare("SELECT Name FROM %Dictionary.ClassDefinition WHERE Name %STARTSWITH 'InterClaw.'")
    if $$$ISERR(qsc) {
        write "  [ERROR] Could not query class list: ", $system.Status.GetErrorText(qsc),!
        return qsc
    }

    set rs = stmt.%Execute()
    while rs.%Next() {
        set className = rs.Name
        set count = count + 1

        if dryRun {
            write "  [WOULD DELETE] Class: ", className,!
        } else {
            set delSc = $system.OBJ.Delete(className, "/nodisplay")
            if $$$ISERR(delSc) {
                write "  [ERROR] Failed to delete class ", className, ": ", $system.Status.GetErrorText(delSc),!
                if $$$ISOK(sc) set sc = delSc
            } else {
                write "  [DELETED] Class: ", className,!
            }
        }
    }

    if count = 0 {
        write "  [SKIP] No InterClaw.* classes found",!
    }
    return sc
}

/// Stop the active InterClaw production if it's running.
/// Matches both the new Inteclaw.Production and the legacy InterClaw.Pipeline.Production.
ClassMethod StopProduction(dryRun As %Boolean = 0)
{
    try {
        set sc = ##class(Ens.Director).GetProductionStatus(.prodName, .prodState)
        set isOurs = (($get(prodName) = "Inteclaw.Production") || ($get(prodName) = "InterClaw.Pipeline.Production"))
        if isOurs && ($get(prodState) '= 2) {
            if dryRun {
                write "  [WOULD STOP] Production: ", prodName,!
            } else {
                set sc = ##class(Ens.Director).StopProduction(30, 1)
                if $$$ISERR(sc) {
                    write "  [WARNING] Error stopping production: ", $system.Status.GetErrorText(sc),!
                } else {
                    write "  [STOPPED] Production: ", prodName,!
                }
            }
        } else {
            write "  [SKIP] No InterClaw production running",!
        }
    } catch ex {
        write "  [WARNING] Could not check production: ", ex.DisplayString(),!
    }
}

/// Remove AutoStart configuration for any InterClaw production (new or legacy).
ClassMethod RemoveAutoStart(dryRun As %Boolean = 0)
{
    if dryRun {
        write "  [WOULD REMOVE] AutoStart for Inteclaw.Production / InterClaw.Pipeline.Production",!
        quit
    }

    try {
        set current = $get(^Ens.AutoStart)
        if (current [ "Inteclaw.Production") || (current [ "InterClaw.Pipeline.Production") {
            set newList = ""
            for i = 1:1:$length(current, ",") {
                set item = $zstrip($piece(current, ",", i), "<>W")
                if (item '= "Inteclaw.Production") && (item '= "InterClaw.Pipeline.Production") && (item '= "") {
                    set newList = newList _ $select(newList'="":",", 1:"") _ item
                }
            }
            set sc = ##class(Ens.Director).SetAutoStart(newList)
            if $$$ISERR(sc) {
                write "  [WARNING] Could not remove AutoStart: ", $system.Status.GetErrorText(sc),!
            } else {
                write "  [REMOVED] AutoStart entry for InterClaw production",!
            }
        } else {
            write "  [SKIP] No InterClaw production in AutoStart",!
        }
    } catch ex {
        write "  [WARNING] AutoStart removal failed: ", ex.DisplayString(),!
    }
}

/// Remove the "InterClaw" portal favorite.
ClassMethod RemovePortalFavorite(dryRun As %Boolean = 0)
{
    set favName = "InterClaw"
    if dryRun {
        write "  [WOULD REMOVE] Portal favorite: ", favName,!
        quit
    }

    try {
        new $namespace
        set $namespace = "%SYS"
        set sc = ##class(%SYS.Portal.Users).%RemoveFavorite(favName)
        if $$$ISERR(sc) {
            write "  [WARNING] Could not remove favorite: ", $system.Status.GetErrorText(sc),!
        } else {
            write "  [REMOVED] Portal favorite: ", favName,!
        }
    } catch ex {
        write "  [SKIP] Portal favorite removal failed (non-fatal): ", ex.DisplayString(),!
    }
}

/// Remove the InterClaw.Bedrock credential from Ens.Config.Credentials.
ClassMethod RemoveCredential(dryRun As %Boolean = 0)
{
    set credName = "InterClaw.Bedrock"
    try {
        if dryRun {
            write "  [WOULD DELETE] Credential: ", credName,!
            quit
        }

        if ##class(Ens.Config.Credentials).%ExistsId(credName) {
            set sc = ##class(Ens.Config.Credentials).%DeleteId(credName)
            if $$$ISERR(sc) {
                write "  [WARNING] Could not delete credential: ", $system.Status.GetErrorText(sc),!
            } else {
                write "  [DELETED] Credential: ", credName,!
            }
        } else {
            write "  [SKIP] Credential ", credName, " does not exist",!
        }
    } catch ex {
        write "  [SKIP] Credential cleanup failed (non-fatal): ", ex.DisplayString(),!
    }
}

/// Remove InterClaw globals from the current namespace.
ClassMethod RemoveGlobals(dryRun As %Boolean = 0)
{
    set globals = $listbuild("^InterClaw.Config", "^InterClaw.ChatEvents", "^InterClaw.ChatPending")
    set ptr = 0
    set found = 0
    while $listnext(globals, ptr, globalName) {
        if $data(@globalName) {
            set found = found + 1
            if dryRun {
                write "  [WOULD DELETE] Global: ", globalName,!
            } else {
                kill @globalName
                write "  [DELETED] Global: ", globalName,!
            }
        }
    }
    if found = 0 {
        write "  [SKIP] No InterClaw globals found",!
    }
}

/// Try to uninstall via IPM if it's available.
ClassMethod TryIPMUninstall(dryRun As %Boolean = 0)
{
    try {
        if dryRun {
            write "  [WOULD RUN] zpm ""uninstall interclaw""",!
            quit
        }

        write "  [INFO] To fully unregister from IPM, run in terminal:",!
        write "    zpm ""uninstall interclaw""",!
    } catch ex {
        write "  [SKIP] IPM uninstall failed (non-fatal): ", ex.DisplayString(),!
    }
}

}
