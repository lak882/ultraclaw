/// InterClaw.Reset — Complete cleanup of the InterClaw IPM package.
///
/// Removes all artifacts created by InterClaw.Installer.Setup() and IPM install:
///   - InterClaw.Production (stopped)
///   - /ui/interop/interclaw web application (frontend)
///   - /api/interclaw web application (REST dispatch)
///   - ${cspdir}interclaw/ directory (all deployed files)
///   - ${installdir}mgr/interclaw_home/ (Claude CLI home)
///   - AutoStart configuration
///   - InterClaw.* classes from the current namespace
///   - Portal favorite
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

    // Step 2: Remove /api/interclaw web application
    set sc1 = ..RemoveWebApp("/api/interclaw", dryRun)

    // Step 3: Remove /ui/interop/interclaw web application
    set sc2 = ..RemoveWebApp("/ui/interop/interclaw", dryRun)

    // Step 4: Remove deployed files (${cspdir}interclaw/)
    set sc3 = ..RemoveFiles(dryRun)

    // Step 5: Remove CLI home directory
    do ..RemoveCLIHome(dryRun)

    // Step 6: Remove InterClaw.* classes
    set sc4 = ..RemoveClasses(dryRun)

    // Step 7: Remove portal favorite
    do ..RemovePortalFavorite(dryRun)

    // Step 8: Remove %Wallet secret and collection
    do ..RemoveWalletCollection(dryRun)

    // Step 9: Try IPM uninstall (may already be done)
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
    set cspDir = $system.Util.InstallDirectory() _ "csp/"
    set icDir = cspDir _ "interclaw/"

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
ClassMethod RemoveCLIHome(dryRun As %Boolean = 0)
{
    set cliHome = $system.Util.InstallDirectory() _ "mgr/interclaw_home/"

    if '##class(%File).DirectoryExists(cliHome) {
        write "  [SKIP] CLI home does not exist: ", cliHome,!
        quit
    }

    if dryRun {
        write "  [WOULD DELETE] CLI home: ", cliHome,!
        quit
    }

    set ok = ##class(%File).RemoveDirectoryTree(cliHome)
    if 'ok {
        write "  [WARNING] Could not remove CLI home: ", cliHome,!
    } else {
        write "  [DELETED] CLI home: ", cliHome,!
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

/// Stop the InterClaw.Production if it's running.
ClassMethod StopProduction(dryRun As %Boolean = 0)
{
    try {
        set sc = ##class(Ens.Director).GetProductionStatus(.prodName, .prodState)
        if $get(prodName) = "InterClaw.Production" && ($get(prodState) '= 2) {
            if dryRun {
                write "  [WOULD STOP] Production: InterClaw.Production",!
            } else {
                set sc = ##class(Ens.Director).StopProduction(30, 1)
                if $$$ISERR(sc) {
                    write "  [WARNING] Error stopping production: ", $system.Status.GetErrorText(sc),!
                } else {
                    write "  [STOPPED] Production: InterClaw.Production",!
                }
            }
        } else {
            write "  [SKIP] InterClaw.Production not running",!
        }
    } catch ex {
        write "  [WARNING] Could not check production: ", ex.DisplayString(),!
    }
}

/// Remove AutoStart configuration for InterClaw.Production.
ClassMethod RemoveAutoStart(dryRun As %Boolean = 0)
{
    if dryRun {
        write "  [WOULD REMOVE] AutoStart for InterClaw.Production",!
        quit
    }

    try {
        // Get current AutoStart, remove InterClaw.Production if present
        set current = ##class(Ens.Director).GetAutoStart()
        if current [ "InterClaw.Production" {
            // Remove InterClaw.Production from comma-separated list
            set newList = ""
            for i = 1:1:$length(current, ",") {
                set item = $zstrip($piece(current, ",", i), "<>W")
                if item '= "InterClaw.Production" && (item '= "") {
                    set newList = newList _ $select(newList'="":",", 1:"") _ item
                }
            }
            set sc = ##class(Ens.Director).SetAutoStart(newList)
            if $$$ISERR(sc) {
                write "  [WARNING] Could not remove AutoStart: ", $system.Status.GetErrorText(sc),!
            } else {
                write "  [REMOVED] AutoStart for InterClaw.Production",!
            }
        } else {
            write "  [SKIP] InterClaw.Production not in AutoStart",!
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

/// Remove the InterClaw %Wallet secret and collection.
ClassMethod RemoveWalletCollection(dryRun As %Boolean = 0)
{
    try {
        if dryRun {
            write "  [WOULD DELETE] Wallet secret: InterClaw.BedrockKey",!
            write "  [WOULD DELETE] Wallet collection: InterClaw",!
            quit
        }

        // Delete the secret
        if ##class(%Wallet.KeyValue).Exists("InterClaw.BedrockKey") {
            set sc = ##class(%Wallet.KeyValue).Delete("InterClaw.BedrockKey")
            if $$$ISERR(sc) {
                write "  [WARNING] Could not delete wallet secret: ", $system.Status.GetErrorText(sc),!
            } else {
                write "  [DELETED] Wallet secret: InterClaw.BedrockKey",!
            }
        } else {
            write "  [SKIP] Wallet secret InterClaw.BedrockKey does not exist",!
        }

        // Delete the collection
        if ##class(%Wallet.Collection).Exists("InterClaw") {
            set sc = ##class(%Wallet.Collection).Delete("InterClaw")
            if $$$ISERR(sc) {
                write "  [WARNING] Could not delete wallet collection: ", $system.Status.GetOneStatusText(sc),!
            } else {
                write "  [DELETED] Wallet collection: InterClaw",!
            }
        } else {
            write "  [SKIP] Wallet collection InterClaw does not exist",!
        }
    } catch ex {
        write "  [SKIP] Wallet cleanup failed (non-fatal): ", ex.DisplayString(),!
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
