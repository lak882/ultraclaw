/// Spawn one or more sub-agents that run the Inteclaw chat loop in parallel.
/// Each sub-agent gets its own bridge id, its own ChatRequest, and its own
/// set of tools (same registry as the parent). The tool blocks until every
/// child emits `done`, then returns a concatenated summary of their final
/// text and turn counts. Intended to mirror the "spawn multiple terminals"
/// pattern — every child can run exec, get_schema, put_class, etc.
Class Inteclaw.Tools.SpawnAgent Extends Inteclaw.Tools.Base
{

Parameter ToolName = "spawn_agent";

Parameter ToolDescription = "Fork N sub-agents that each run a Claude loop with the full Inteclaw tool set. Pass an array of prompts; returns an array of final texts once all children finish. Use for map-style parallelism (e.g. author DTL in one child while authoring test message in another).";

Parameter ToolInputSchema = "{""type"":""object"",""properties"":{""prompts"":{""type"":""array"",""items"":{""type"":""string""},""description"":""One prompt per sub-agent. Each runs independently in its own bridge.""},""max_turns"":{""type"":""integer"",""default"":6,""description"":""Per-child max agent turns.""},""wait_seconds"":{""type"":""integer"",""default"":300,""description"":""Overall deadline waiting for all children.""}},""required"":[""prompts""]}";

ClassMethod Execute(inputJSON As %String) As %String
{
    Set input = ##class(%DynamicObject).%FromJSON(inputJSON)
    Set prompts = input.%Get("prompts")
    If '$IsObject(prompts) Return "Error: prompts must be an array"
    Set n = prompts.%Size()
    If n = 0 Return "Error: prompts array is empty"

    Set maxTurns = +input.%Get("max_turns")
    If maxTurns < 1 Set maxTurns = 6
    Set waitSec = +input.%Get("wait_seconds")
    If waitSec < 1 Set waitSec = 300

    // Dispatch each prompt as its own ChatRequest. Reuse the shared system prompt.
    Set systemPrompt = ##class(Inteclaw.Skill.Loader).BuildSystemPrompt()
    Set bridgeIds = ##class(%DynamicArray).%New()
    Set iter = prompts.%GetIterator()
    While iter.%GetNext(.i, .p) {
        Set bridgeId = "child-" _ $Extract($System.Util.CreateGUID(), 1, 10)
        Set ^Inteclaw.ChatEvents(bridgeId, "seq") = 0
        Set ^Inteclaw.ChatEvents(bridgeId, "done") = 0

        Set req = ##class(Inteclaw.Msg.ChatRequest).%New()
        Set req.BridgeId = bridgeId
        Set req.Prompt = p
        Set req.SystemPrompt = systemPrompt
        Set req.MaxTurns = maxTurns

        Set sc = ##class(Ens.Director).CreateBusinessService("Inteclaw.BS.ChatService", .service)
        If $$$ISERR(sc) Return "Error spawning child: " _ $System.Status.GetErrorText(sc)
        Set sc = service.ProcessInput(req)
        If $$$ISERR(sc) Return "Error dispatching child: " _ $System.Status.GetErrorText(sc)

        Do bridgeIds.%Push(bridgeId)
    }

    // Poll until all children are done or deadline expires.
    Set deadline = $ZH + waitSec
    Set pending = n
    While (pending > 0) && ($ZH < deadline) {
        Set pending = 0
        Set biter = bridgeIds.%GetIterator()
        While biter.%GetNext(.j, .bid) {
            If +$Get(^Inteclaw.ChatEvents(bid, "done"), 0) '= 1 Set pending = pending + 1
        }
        If pending > 0 Hang 0.25
    }

    // Collect final output from each child by scanning its events.
    Set out = "Spawned " _ n _ " child agents." _ $Char(10)
    Set biter = bridgeIds.%GetIterator()
    While biter.%GetNext(.j, .bid) {
        Set childIdx = j + 1
        Set finalText = ""
        Set turns = 0
        Set inTok = 0
        Set outTok = 0
        Set seq = 0
        Set topSeq = +$Get(^Inteclaw.ChatEvents(bid, "seq"), 0)
        For seq = 1:1:topSeq {
            Set raw = $Get(^Inteclaw.ChatEvents(bid, "evt", seq))
            If raw = "" Continue
            Try {
                Set evt = ##class(%DynamicObject).%FromJSON(raw)
                Set t = evt.%Get("type")
                If t = "output" Set finalText = evt.%Get("text")
                If t = "usage" {
                    Set inTok = inTok + +evt.%Get("input_tokens")
                    Set outTok = outTok + +evt.%Get("output_tokens")
                    Set turns = +evt.%Get("turn")
                }
            } Catch ex { }
        }
        Set doneFlag = +$Get(^Inteclaw.ChatEvents(bid, "done"), 0)
        Set out = out _ $Char(10) _ "=== child " _ childIdx _ " (bridge=" _ bid _ ", done=" _ doneFlag _ ", turns=" _ turns _ ", in=" _ inTok _ ", out=" _ outTok _ ") ===" _ $Char(10)
        Set out = out _ finalText _ $Char(10)
    }
    Return out
}

}
