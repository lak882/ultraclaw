/// Custom Management Portal home page that adds InterClaw
/// menu items to the Interoperability section without modifying system classes.
/// Configure your CSP application homepage to point to InterClaw.Portal.Home.zen
Class InterClaw.Portal.Home Extends %CSP.Portal.Home
{

/// Override to inject InterClaw items after the stock Interoperability menu.
Method GetEnsembleArray(Output pData) As %Status
{
    // Call the original to get all stock Interoperability items
    Set tSC = ##super(.pData)
    If $$$ISERR(tSC) Quit tSC

    // Find the highest index used so far
    Set tIndex = 0
    Set k = $order(pData(""))
    While (k '= "") {
        If k > tIndex Set tIndex = k
        Set k = $order(pData(k))
    }

    // Only add our items if there are existing items (i.e., we're in an Ensemble namespace)
    If tIndex > 0 {
        Set tSC = ##class(InterClaw.Portal.MenuItems).AddMenuItems(.tIndex, .pData)
    }

    Quit tSC
}

}
