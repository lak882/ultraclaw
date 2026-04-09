/// Entry point — receives ChatRequest from the REST dispatch
/// and sends it to the ChatProcess business process asynchronously.
/// Called via Ens.Director.CreateBusinessService from the REST layer.
Class InterClaw.Pipeline.BS.ChatService Extends Ens.BusinessService
{

Parameter ADAPTER = "";

Property ProcessTarget As %String [ InitialExpression = "InterClaw.Pipeline.BP.ChatProcess" ];

Parameter SETTINGS = "ProcessTarget:Basic";

Method OnProcessInput(pInput As InterClaw.Pipeline.Msg.ChatRequest, Output pOutput As Ens.Response) As %Status
{
    // Send async — the REST dispatch already returned bridge_id to the browser
    Set sc = ..SendRequestAsync(..ProcessTarget, pInput)
    Return sc
}

}
