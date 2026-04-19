# Business Processes Reference

Business Processes are the middle layer. They receive requests from services (or other processes), orchestrate logic, call operations, and return responses. Two flavors: code-based and BPL (visual XML).

## Class Hierarchy

```
Ens.BusinessProcess
  ├── Ens.BusinessProcessBPL                        (visual/XML BPL)
  ├── EnsLib.MsgRouter.RoutingEngine                (generic routing)
  │     └── EnsLib.HL7.MsgRouter.RoutingEngine      (HL7 routing)
  ├── EnsLib.MsgRouter.VDocRoutingEngine             (virtual doc routing)
  ├── HS.Hub.MsgRouter.RoutingEngine                 (HealthShare hub routing)
  └── Your.Custom.Process                            (code-based)
```

## Code-Based Process

### Key Methods

```objectscript
Method OnRequest(pRequest As Ens.Request, Output pResponse As Ens.Response) As %Status
{
    // Called when a new request arrives
    // This is where your main logic goes
    Return $$$OK
}

Method OnResponse(request As %Library.Persistent, ByRef response As %Library.Persistent, callrequest As %Library.Persistent, callresponse As %Library.Persistent, pCompletionKey As %String) As %Status
{
    // Called when an async call completes
    // callrequest = what you sent, callresponse = what came back
    // pCompletionKey = the key you passed to SendRequestAsync
    Return $$$OK
}

Method OnComplete(request As %Library.Persistent, ByRef response As %Library.Persistent) As %Status
{
    // Called after all async calls complete
    Return $$$OK
}
```

### Sending to Operations/Other Processes

```objectscript
// Synchronous — blocks until response
Set tSC = ..SendRequestSync("TargetOperation", tRequest, .tResponse)

// Asynchronous — returns immediately, response comes to OnResponse
Set tSC = ..SendRequestAsync("TargetOperation", tRequest, "myKey")
```

### Context Properties

Business processes can persist state across async calls using properties. Any property on the class is automatically saved to disk between calls:

```objectscript
Class MyApp.OrderProcess Extends Ens.BusinessProcess
{
Property OrderId As %String;
Property RetryCount As %Integer [ InitialExpression = 0 ];

Method OnRequest(pRequest As MyApp.OrderRequest, Output pResponse As MyApp.OrderResponse) As %Status
{
    Set ..OrderId = pRequest.OrderId
    Set tSC = ..SendRequestAsync("ValidationService", pRequest, "validate")
    Return tSC
}

Method OnResponse(request As %Library.Persistent, ByRef response As %Library.Persistent, callrequest As %Library.Persistent, callresponse As %Library.Persistent, pCompletionKey As %String) As %Status
{
    If pCompletionKey = "validate" {
        If callresponse.IsValid {
            Set tSC = ..SendRequestAsync("FulfillmentOp", callrequest, "fulfill")
        } Else {
            Set ..RetryCount = ..RetryCount + 1
        }
    }
    Return $$$OK
}
}
```

## BPL Process (Visual)

BPL processes use an XDATA block with XML. They're designed in the Management Portal's BPL editor but can be hand-written.

```objectscript
Class MyApp.HL7TransformProcess Extends Ens.BusinessProcessBPL
{
XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='EnsLib.HL7.Message' response='EnsLib.HL7.Message'>
<context>
  <property name='transformedMsg' type='EnsLib.HL7.Message'/>
</context>
<sequence>

  <transform name='Apply DTL' class='MyApp.HL7Transform'
    source='request' target='context.transformedMsg'/>

  <call name='Send to Target' target='OutboundHL7Op' async='0'>
    <request type='EnsLib.HL7.Message' value='context.transformedMsg'/>
    <response type='EnsLib.HL7.Message' value='response'/>
  </call>

</sequence>
</process>
}
}
```

### BPL Elements

| Element | Purpose |
|---------|---------|
| `<sequence>` | Execute steps in order |
| `<call>` | Send request to another component |
| `<transform>` | Apply a DTL transformation |
| `<if>` / `<elseif>` / `<else>` | Conditional branching |
| `<foreach>` | Loop over a collection |
| `<assign>` | Set a property value |
| `<code>` | Inline ObjectScript |
| `<switch>` / `<case>` | Multi-branch conditional |
| `<throw>` / `<catch>` | Error handling |
| `<alert>` | Send an alert |
| `<trace>` | Write a trace message |

## HL7 Routing Engine (HealthShare)

The most common BP in HealthShare productions. Routes HL7 messages based on rules.

```xml
<Item Name="HL7Router" Category="Routing" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true">
  <Setting Target="Host" Name="BusinessRuleName">MyApp.HL7RoutingRule</Setting>
  <Setting Target="Host" Name="BadMessageHandler">BadMessageFileOp</Setting>
  <Setting Target="Host" Name="Validation">$$$SOFT</Setting>
</Item>
```

Key settings:
- `BusinessRuleName` — the routing rule class to use
- `BadMessageHandler` — where to send messages that fail validation
- `Validation` — `$$$NONE`, `$$$SOFT`, `$$$FULL`
- `RuleLogging` — what to log: `a` (all), `e` (errors), `d` (delegates)

## BPL vs Code-Based Process — Decision Guide

**Default: ALWAYS use BPL.** BPL is the standard choice for all orchestration processes. Code-based BP is the rare exception, not the alternative.

### Why BPL is the default

| Advantage | Details |
|-----------|---------|
| **Visual Trace** | Every BPL activity appears as a named step in Visual Trace — you can see exactly where a message is, what it's waiting on, and where it failed. Code-based BPs show as a single opaque "OnRequest" call. |
| **Non-developer readable** | Interface analysts, project managers, and clinical informaticists can read and validate BPL flows without ObjectScript knowledge. |
| **Built-in error viz** | `<scope>` + `<catch>` + `<compensate>` render as visible error-handling blocks in the diagram. Code-based try/catch is invisible in traces. |
| **Self-documenting** | The BPL XML IS the documentation. Named activities (`<call name='Send to Lab'>`) describe intent. No separate flowcharts needed. |
| **State persistence** | Context properties survive process restarts automatically. Code-based processes require manual property management. |
| **Consistent debugging** | `<trace>` elements emit named trace messages at exact points. `<milestone>` records audit checkpoints. All visible in Visual Trace. |

### Decision flowchart

```
Need a business process?
│
├─ Pure content-based routing? (HL7 field values, message types)
│  └─ YES → Routing Engine + Routing Rule (NOT a process)
│
├─ Any orchestration needed? (transform, call, conditional, parallel, enrich)
│  └─ YES → **USE BPL** (this is the default)
│     │
│     └─ Exception — ALL of these must be true:
│        1. Requires >100 lines of dense ObjectScript logic
│        2. Heavy string manipulation, complex algorithms, or tight loops
│        3. Logic CANNOT be decomposed into DTL + simpler BPL activities
│        4. User explicitly requested a code-based process
│        └─ THEN → Code-based BP (rare — document why BPL was insufficient)
│
└─ Simple pass-through? (receive → transform → send)
   └─ **USE BPL** — even trivial flows benefit from traceability
```

### When code-based BP is appropriate (rare)

| Scenario | Why BPL falls short |
|----------|-------------------|
| >100 lines of ObjectScript string manipulation | `<code>` blocks that large become unwieldy in XML |
| Complex recursive algorithms | BPL has no recursion; deeply nested logic is clearer in ObjectScript |
| Performance-critical path (>10K msg/sec) | BPL XML parsing adds marginal overhead per message |
| Extensive %Net.HttpRequest with custom retry/backoff | Multi-step HTTP with dynamic headers/auth is verbose in BPL |

**Even in these cases**, consider: can the heavy logic live in a utility class method called from a `<code>` block in a BPL? That gives you BPL traceability with ObjectScript power. Only go full code-based BP when the entire flow is ObjectScript-heavy.

## Example: Code-Based HL7 Process

```objectscript
Class MyApp.ADTProcessor Extends Ens.BusinessProcess
{

Property TargetOperation As %String;

Parameter SETTINGS = "TargetOperation:Basic:selector?context={Ens.ContextSearch/ProductionItems?targets=1&productionName=@productionId}";

Method OnRequest(pRequest As EnsLib.HL7.Message, Output pResponse As Ens.Response) As %Status
{
    Set tSC = $$$OK

    // Get message type from MSH:9
    Set tMsgType = pRequest.GetValueAt("MSH:9.1")
    Set tEvent = pRequest.GetValueAt("MSH:9.2")

    // Route based on type
    If tMsgType = "ADT" {
        // Transform ADT messages
        Set tSC = $ClassMethod("MyApp.ADTTransform", "Transform", pRequest, .tOutput)
        If $$$ISERR(tSC) Return tSC

        Set tSC = ..SendRequestAsync(..TargetOperation, tOutput)
    }

    Return tSC
}

}
```
