/// Utility to deploy InterClaw menu to all Ensemble-enabled namespaces.
/// Run from any namespace: do ##class(InterClaw.Portal.Setup).DeployAll()
Class InterClaw.Portal.Setup
{

/// Add InterClaw menu to all Ensemble-enabled namespaces.
/// Creates package mapping for EnsLib.Hub.UI -> CLAUDE database and sets ^EnsLib.Hub global.
ClassMethod DeployAll() As %Status
{
    Set tSC = $$$OK
    Set count = 0
    Set origNS = $namespace

    // Collect namespace list first (from %SYS globals)
    Set ns = "", nsList = ""
    For {
        Set ns = $order(^%SYS("Ensemble","InstalledNamespace",ns))
        Quit:ns=""
        If ns = "HSLIB" Continue
        Set nsList = nsList _ $listbuild(ns)
    }

    // Create package mappings from %SYS
    New $namespace
    Set $namespace = "%SYS"
    Set ptr = 0
    While $listnext(nsList, ptr, ns) {
        Write "Processing: ", ns, !

        Set props("Database") = "CLAUDE"
        Set sc = ##class(Config.MapPackages).Create(ns, "EnsLib.Hub.UI", .props)
        If $$$ISOK(sc) {
            Write "  Package mapping created", !
        } Else {
            Set errText = $system.Status.GetErrorText(sc)
            If errText [ "exists" {
                Write "  Package mapping already exists", !
            } Else {
                Write "  ERROR creating mapping: ", errText, !
                Continue
            }
        }

        // Set ^EnsLib.Hub global in target namespace
        New $namespace
        Set $namespace = ns
        Set ^EnsLib.Hub = 1
        Write "  ^EnsLib.Hub set", !

        Set count = count + 1
    }

    Write !, "Done. Configured ", count, " namespace(s).", !
    Quit tSC
}

/// Remove InterClaw menu from all namespaces.
ClassMethod RemoveAll() As %Status
{
    Set tSC = $$$OK

    // Collect namespace list
    Set ns = "", nsList = ""
    For {
        Set ns = $order(^%SYS("Ensemble","InstalledNamespace",ns))
        Quit:ns=""
        If ns = "HSLIB" Continue
        Set nsList = nsList _ $listbuild(ns)
    }

    // Remove from %SYS context
    New $namespace
    Set $namespace = "%SYS"
    Set ptr = 0
    While $listnext(nsList, ptr, ns) {
        // Remove package mapping
        If ##class(Config.MapPackages).Exists(ns, "EnsLib.Hub.UI") {
            Set sc = ##class(Config.MapPackages).Delete(ns, "EnsLib.Hub.UI")
            Write "Removed mapping from ", ns, !
        }

        // Remove global
        New $namespace
        Set $namespace = ns
        Kill ^EnsLib.Hub
        Write "Removed ^EnsLib.Hub from ", ns, !
    }

    Write "Done.", !
    Quit tSC
}

}
