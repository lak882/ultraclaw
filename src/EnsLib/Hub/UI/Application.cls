/// Hook into the Management Portal's Interoperability menu via the
/// EnsLib.Hub extension point in EnsPortal.Application.GetEnsembleArray.
/// Activated by setting ^EnsLib.Hub global in the target namespace.
Class EnsLib.Hub.UI.Application
{

/// Called from EnsPortal.Application.GetEnsembleArray() when ^EnsLib.Hub exists.
/// Adds InterClaw editor links to the Interoperability finder menu.
ClassMethod GetIMTArray(ByRef pIndex As %Integer, ByRef pData) As %Status
{
    // Derive the path prefix from the default CSP app for this namespace
    // e.g., "/irishealth/csp/healthshare/claude" -> "/irishealth"
    Set tApp = $system.CSP.GetDefaultApp($namespace)
    Set tPrefix = $piece(tApp, "/", 1, 2)
    Set tBase = tPrefix _ "/ui/interop/interclaw"
    Set tNS = $namespace

    Set pIndex = pIndex + 1
    Set pData(pIndex) = $LB("InterClaw",,,, ##class(EnsPortal.Application).Link("portal/software_development_48.gif"))

    Set pData(pIndex,1) = $LB("Production Editor",, tBase_"/interop-editor/index.html?$NAMESPACE="_tNS,, ##class(EnsPortal.Application).Link("portal/enttity_relationship_model_48.gif"), "Open the production in the InterClaw editor.",,, "InterClaw,AI,Production")
    Set pData(pIndex,2) = $LB("DTL Editor",, tBase_"/dtl-editor/index.html?$NAMESPACE="_tNS,, ##class(EnsPortal.Application).Link("portal/merge_cells_48.gif"), "Open data transformations in the InterClaw editor.",,, "InterClaw,AI,DTL")
    Set pData(pIndex,3) = $LB("Rule Editor",, tBase_"/rule-editor/index.html?$NAMESPACE="_tNS,, ##class(EnsPortal.Application).Link("portal/script_48.gif"), "Open routing rules in the InterClaw editor.",,, "InterClaw,AI,Rule")
    Set pData(pIndex,4) = $LB("BPL Editor",, tBase_"/bpl-editor/index.html?$NAMESPACE="_tNS,, ##class(EnsPortal.Application).Link("portal/enttity_relationship_model_48.gif"), "Open BPL processes in the InterClaw editor.",,, "InterClaw,AI,BPL")
    Set pData(pIndex,5) = $LB("Message Viewer",, tBase_"/message-viewer/index.html?$NAMESPACE="_tNS,, ##class(EnsPortal.Application).Link("portal/mail_search_48.gif"), "View message traces in the InterClaw viewer.",,, "InterClaw,AI,Message,Trace")

    Quit $$$OK
}

}
