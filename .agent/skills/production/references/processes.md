# Business Processes Reference

Business process class hierarchy, BPL vs code-based decision guide, HL7 routing engine, and lifecycle methods. Load when adding or writing a process.

## Class Hierarchy

```
Ens.BusinessProcess
  ├── Ens.BusinessProcessBPL                        (visual/XML BPL — default)
  ├── EnsLib.MsgRouter.RoutingEngine                (generic routing)
  │     └── EnsLib.HL7.MsgRouter.RoutingEngine      (HL7 routing — use this, not the generic)
  ├── EnsLib.MsgRouter.VDocRoutingEngine             (virtual doc routing)
  ├── HS.Hub.MsgRouter.RoutingEngine                 (HealthShare hub routing)
  └── Your.Custom.Process                            (code-based — rare)
```

## BPL vs Code-Based: Decision Guide

**Default: always use BPL.** Code-based is the rare exception.

```
Need a business process?
│
├── Pure content-based routing? (HL7 field values, message types)
│   └── YES → Routing Engine + Routing Rule (not a process)
│
├── Any orchestration? (transform, call, conditional, parallel, enrich)
│   └── YES → BPL (default)
│      └── Exception — all of these must be true:
│          1. Requires >100 lines of dense ObjectScript
│          2. Cannot be decomposed into DTL + BPL activities
│          3. User explicitly requested code-based
│          └── THEN → code-based BP (document why BPL was insufficient)
│
└── Simple pass-through? (receive → transform → send)
    └── BPL — even trivial flows benefit from traceability
```

### Why BPL is the default

| Advantage | Details |
|-----------|---------|
| Visual Trace | Every BPL activity is a named step in Visual Trace. Code-based BPs show as a single opaque "OnRequest" block. |
| Non-developer readable | Interface analysts can read and validate BPL flows without ObjectScript knowledge. |
| Built-in error viz | `<scope>` + `<catch>` render as visible error-handling blocks in the diagram. |
| Self-documenting | Named activities (`<call name='Send to Lab'>`) describe intent. |
| State persistence | Context properties survive restarts automatically. |

Heavy ObjectScript in BPL: put complex logic in a utility class method and call it from a `<code>` block. You get BPL traceability with ObjectScript power.

## BPL Process

```objectscript
Class MyApp.BPL.HL7TransformProcess Extends Ens.BusinessProcessBPL
{

XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='EnsLib.HL7.Message' response='EnsLib.HL7.Message'>
<context>
  <property name='transformedMsg' type='EnsLib.HL7.Message'/>
</context>
<sequence name='Main'>

  <transform name='Apply DTL' class='MyApp.DTL.ADTTransform'
    source='request' target='context.transformedMsg'/>

  <call name='Send to Target' target='OutboundHL7Op' async='0'>
    <request type='EnsLib.HL7.Message'>
      <assign property='callrequest' value='context.transformedMsg' action='set'/>
    </request>
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
| `<sequence name='...'>` | Execute steps in order; name is required |
| `<call>` | Send request to another component |
| `<transform>` | Apply a DTL transformation |
| `<if>` / `<elseif>` / `<else>` | Conditional branching |
| `<switch>` / `<case>` | Multi-branch conditional (prefer over nested `<if>`) |
| `<foreach>` | Loop over a collection |
| `<assign>` | Set a property value |
| `<code>` | Inline ObjectScript |
| `<sql>` | Native SQL with `:context.Property` binding |
| `<scope>` / `<catch>` | Error handling |
| `<trace>` | Write a trace message |
| `<alert>` | Send an alert |

### BPL `<call>` for HL7

Never use `value=` on `<request>`/`<response>` for `EnsLib.HL7.Message` — it causes compile errors. Always use `<assign>` inside `<request>`:

```xml
<call name='Send Message' target='TargetOperation' async='0'>
  <request type='EnsLib.HL7.Message'>
    <assign property='callrequest' value='request' action='set'/>
  </request>
  <response type='EnsLib.HL7.Message' value='response'/>
</call>
```

### Sequence naming

Every `<sequence>` must have a `name` attribute. Unnamed sequences appear as blank nodes in Visual Trace.

## HL7 Routing Engine

The most common process in HL7 productions. Routes messages based on rules.

```xml
<Item Name="HL7Router" Category="Routing" ClassName="EnsLib.HL7.MsgRouter.RoutingEngine" PoolSize="1" Enabled="true">
  <Setting Target="Host" Name="BusinessRuleName">MyApp.Rule.HL7RoutingRule</Setting>
  <Setting Target="Host" Name="BadMessageHandler">BadMessageFileOp</Setting>
  <Setting Target="Host" Name="Validation">$$$SOFT</Setting>
</Item>
```

Key settings:

| Setting | Values | Description |
|---------|--------|-------------|
| `BusinessRuleName` | class name | The routing rule class |
| `BadMessageHandler` | config item name | Where to send messages that fail validation |
| `Validation` | `$$$NONE`, `$$$SOFT`, `$$$FULL` | Validation level |
| `RuleLogging` | `a` (all), `e` (errors), `d` (delegates) | What to log |

## Code-Based Process (Rare)

### Key Methods

```objectscript
Method OnRequest(pRequest As Ens.Request, Output pResponse As Ens.Response) As %Status
{
    // Main entry point — process the incoming request
    Return $$$OK
}

Method OnResponse(request As %Library.Persistent, ByRef response As %Library.Persistent, callrequest As %Library.Persistent, callresponse As %Library.Persistent, pCompletionKey As %String) As %Status
{
    // Called when an async SendRequestAsync completes
    Return $$$OK
}

Method OnComplete(request As %Library.Persistent, ByRef response As %Library.Persistent) As %Status
{
    // Called after all async calls complete
    Return $$$OK
}
```

### Sending to Operations or Other Processes

```objectscript
// Synchronous — blocks until response
Set tSC = ..SendRequestSync("TargetOperation", tRequest, .tResponse)

// Asynchronous — response comes to OnResponse
Set tSC = ..SendRequestAsync("TargetOperation", tRequest, "myCompletionKey")
```

### Context Properties

Properties on a code-based BP are automatically persisted between async calls:

```objectscript
Class MyApp.BP.OrderProcess Extends Ens.BusinessProcess
{

Property OrderId As %String;
Property RetryCount As %Integer [ InitialExpression = 0 ];

Method OnRequest(pRequest As MyApp.Msg.OrderRequest, Output pResponse As MyApp.Msg.OrderResponse) As %Status
{
    Set ..OrderId = pRequest.OrderId
    Set tSC = ..SendRequestAsync("ValidationService", pRequest, "validate")
    Return tSC
}

}
```
