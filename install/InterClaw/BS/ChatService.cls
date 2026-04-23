/// Inbound entry point. Called by the REST dispatch via
/// Ens.Director.CreateBusinessService. Routes the ChatRequest to
/// the agent process asynchronously so REST returns fast with a bridge id.
Class InterClaw.BS.ChatService Extends Ens.BusinessService
{

Parameter ADAPTER;

Property ProcessTarget As %String [ InitialExpression = "InterClaw.BP.ChatProcess" ];

Parameter SETTINGS = "ProcessTarget:Basic";

Method OnProcessInput(pInput As InterClaw.Msg.ChatRequest, Output pOutput As Ens.Response) As %Status
{
    Return ..SendRequestAsync(..ProcessTarget, pInput)
}

}
