/// Inbound entry point. Called by the REST dispatch via
/// Ens.Director.CreateBusinessService. Routes the ChatRequest to
/// the agent process asynchronously so REST returns fast with a bridge id.
Class Inteclaw.BS.ChatService Extends Ens.BusinessService
{

Parameter ADAPTER;

Property ProcessTarget As %String [ InitialExpression = "Inteclaw.BP.ChatProcess" ];

Parameter SETTINGS = "ProcessTarget:Basic";

Method OnProcessInput(pInput As Inteclaw.Msg.ChatRequest, Output pOutput As Ens.Response) As %Status
{
    Return ..SendRequestAsync(..ProcessTarget, pInput)
}

}
