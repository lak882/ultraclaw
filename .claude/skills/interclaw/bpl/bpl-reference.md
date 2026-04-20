# BPL (Business Process Language) Reference

BPL is an XML-based visual programming language for defining business process orchestrations in InterSystems IRIS/HealthShare productions. BPL processes coordinate message flow between services, operations, and other processes — handling async calls, transformations, conditional logic, error handling, and parallel execution.

## Class Structure

A BPL process is an ObjectScript class that extends `Ens.BusinessProcessBPL`. The process logic is defined in an `XData BPL` block containing XML.

```objectscript
Class MyPkg.BPL.MyProcess Extends Ens.BusinessProcessBPL
{

/// Optional class-level properties accessible via process.PropertyName
Property TargetConfigName As %String(MAXLEN = 128) [ InitialExpression = "DefaultTarget" ];

/// Expose properties as production settings
Parameter SETTINGS = "TargetConfigName:Basic";

XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='EnsLib.HL7.Message' response='EnsLib.HL7.Message'>
<context>
  <property name='tempMsg' type='EnsLib.HL7.Message' instantiate='0'/>
  <property name='errorCount' type='%Integer' initialExpression='0'/>
</context>
<sequence>
  <!-- Activities go here -->
</sequence>
</process>
}

}
```

### Key Rules

- The `XData BPL` block MUST have `XMLNamespace = "http://www.intersystems.com/bpl"`
- The `<process>` element is the root — it defines request/response types and contains `<context>` + `<sequence>`
- All process logic lives inside the `<sequence>` (or `<flow>` for parallel execution)
- The class can define ObjectScript properties and parameters alongside the BPL XDATA

## The `<process>` Element

Root element of every BPL definition.

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `language` | string | No | `objectscript` | Language for code/expressions: `objectscript` or `python` |
| `request` | string | Yes | — | Fully qualified class name of the input request message |
| `response` | string | Yes | — | Fully qualified class name of the output response message |
| `includes` | string | No | — | Comma-separated list of ObjectScript include files for `<code>` blocks |
| `version` | integer | No | — | Version number (managed by the BPL editor) |
| `layout` | string | No | `automatic` | Diagram layout: `automatic` or `manual` |

### Common Request/Response Types

| Pattern | Request | Response |
|---------|---------|----------|
| HL7 pass-through | `EnsLib.HL7.Message` | `EnsLib.HL7.Message` |
| HL7 with no reply | `EnsLib.HL7.Message` | `Ens.Response` |
| Custom messages | `MyPkg.Msg.OrderRequest` | `MyPkg.Msg.OrderResponse` |
| Stream container | `Ens.StreamContainer` | `Ens.Response` |
| Generic | `Ens.Request` | `Ens.Response` |

## Context Properties

The `<context>` element declares variables that persist across the entire BPL execution — including across async call suspension/resume cycles. Context is how BPL maintains state.

```xml
<context>
  <property name='transformedMsg' type='EnsLib.HL7.Message' instantiate='0'/>
  <property name='patientMRN' type='%String' initialExpression='""'/>
  <property name='retryCount' type='%Integer' initialExpression='0'/>
  <property name='isValid' type='%Boolean' initialExpression='1'/>
  <property name='itemList' type='%ListOfDataTypes' collection='list' instantiate='1'/>
  <property name='lookupMap' type='%String' collection='array'/>
</context>
```

### `<property>` Attributes

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `name` | string | Yes | — | Property name, referenced as `context.name` in expressions |
| `type` | string | Yes | — | Data type class (e.g., `%String`, `%Integer`, `EnsLib.HL7.Message`) |
| `collection` | string | No | — | `list` or `array` for collection properties |
| `initialExpression` | string | No | — | Initial value expression for data types (e.g., `'0'`, `'""'`) |
| `instantiate` | boolean | No | `0` | If `1`, auto-creates a new object instance (`##class(Type).%New()`) at process start. Use for object types. |

### When to Use `instantiate` vs `initialExpression`

- **`initialExpression`** — for simple data types (`%String`, `%Integer`, `%Boolean`). Value is an ObjectScript expression.
- **`instantiate='1'`** — for object types (`EnsLib.HL7.Message`, `Ens.StreamContainer`, custom objects). Creates a `%New()` instance automatically.
- For object types you plan to assign from a call response or transform, use `instantiate='0'` (the default) — the value will come from the activity.

## Available Variables in Expressions

BPL expressions can reference these variables:

| Variable | Description |
|----------|-------------|
| `request` | The incoming request message |
| `response` | The outgoing response message (writable) |
| `context` | The context object (your declared properties) |
| `process` | The business process instance itself (access class properties/settings) |
| `status` | The current `%Status` value from the last operation |
| `request.{HL7Path}` | Virtual document field access for HL7 messages |
| `context.propName` | Context property access |
| `process.PropertyName` | Class property / setting access |
| `..MethodName()` | Call a method on the business process class |
| `##class(ClassName).Method()` | Call any class method |
| `$PIECE(...)`, `$LENGTH(...)` | ObjectScript functions |

### Expression Syntax Notes

- String literals must be in double quotes within single-quoted XML attributes: `value='"literal string"'`
- To concatenate: `value='context.firstName_" "_context.lastName'`
- HL7 virtual document paths use curly braces: `request.{MSH:MessageType.MessageCode}`, `context.transformedMsg.{PID:PatientIdentifierList.IDNumber}`
- For settings on the process class: `process.TargetConfigName`
- For dynamic target routing: `target='@process.TargetConfigName'` (the `@` prefix evaluates the expression at runtime)

---

## Activities Reference

Every activity supports these common attributes (inherited from `Ens.BPL.Activity`):

| Attribute | Type | Default | Description |
|-----------|------|---------|-------------|
| `name` | string | — | Human-readable activity name (shows in trace and BPL editor) |
| `disabled` | boolean | `0` | If `1`, the activity is skipped at runtime |
| `xpos`, `ypos` | integer | — | Visual editor position (auto-managed; do not set manually) |
| `xend`, `yend` | integer | — | Visual editor end position (auto-managed) |

### Container Activities

#### `<sequence>` — Sequential Execution

Executes child activities in order, one after another. The top-level container inside `<process>`.

```xml
<sequence name='Process ORM'>
  <assign name='GetMsgType' .../>
  <call name='SendToTarget' .../>
  <transform name='Apply DTL' .../>
</sequence>
```

**Always name every `<sequence>`** — the `name` attribute appears in Visual Trace and the BPL editor. Unnamed sequences show as blank nodes, making debugging harder.

**Avoid unnecessary nested `<sequence>` wrappers.** The top-level `<sequence>` inside `<process>` is sufficient for simple linear BPLs. Only nest additional `<sequence>` elements when:
- Inside `<flow>` branches (each parallel branch needs its own `<sequence>`)
- Inside `<scope>` blocks (grouping activities under error handling)
- Inside `<if>`/`<switch>` branches with multiple activities
- When the BPL exceeds ~10 activities and logical grouping aids readability

**Wrong** — unnecessary wrapper:
```xml
<sequence name='Main'>
  <sequence name='Do Stuff'>   <!-- redundant — only one sequence needed -->
    <assign .../>
    <call .../>
  </sequence>
</sequence>
```

**Right** — flat when simple:
```xml
<sequence name='Main'>
  <assign .../>
  <call .../>
</sequence>
```

#### `<flow>` — Parallel Execution

Executes child activities concurrently. Each direct child of `<flow>` runs as an independent thread. The flow completes when ALL threads complete.

```xml
<flow name='Parallel Send'>
  <sequence name='Archive Branch'>
    <call name='Archive' target='ArchiveFileOp' async='0'>
      <request type='EnsLib.HL7.Message'>
        <assign property="callrequest" value="request" action="set" />
      </request>
      <response type='Ens.Response' />
    </call>
  </sequence>
  <sequence name='Transform Branch'>
    <transform name='Apply DTL' class='MyPkg.DTL.MyTransform'
      source='request' target='context.transformedMsg'/>
    <call name='Send Transformed' target='OutboundOp' async='0'>
      <request type='EnsLib.HL7.Message'>
        <assign property="callrequest" value="context.transformedMsg" action="set" />
      </request>
      <response type='Ens.Response' />
    </call>
  </sequence>
</flow>
```

**Important**: Each branch in a `<flow>` should be wrapped in a `<sequence>` if it contains multiple activities.

#### `<scope>` — Error Handling Block

Groups activities with fault handlers (try/catch). If any activity inside the scope throws a fault, execution transfers to the matching `<catch>` or `<catchall>` handler.

```xml
<scope name='Protected Block'>
  <sequence>
    <call name='Risky Call' target='ExternalService' async='0'>
      <request type='Ens.Request' value='request'/>
      <response type='Ens.Response' value='callresponse'/>
    </call>
  </sequence>
  <faulthandlers>
    <catch fault='"MyCustomFault"' name='Handle Custom Fault'>
      <trace value='"Caught custom fault"'/>
      <assign value='1' property='context.errorCount' action='set'/>
    </catch>
    <catchall name='Handle Any Error'>
      <trace value='"Unexpected error occurred"'/>
      <alert value='"BPL process encountered an error"'/>
    </catchall>
  </faulthandlers>
  <compensationhandlers>
    <compensationhandler name='UndoRiskyCall'>
      <sequence>
        <call name='Rollback' target='RollbackOp' async='0'>
          <request type='Ens.Request' value='request'/>
          <response type='Ens.Response' value='callresponse'/>
        </call>
      </sequence>
    </compensationhandler>
  </compensationhandlers>
</scope>
```

### Call Activities

#### `<call>` — Invoke a Business Host

The most important BPL activity. Sends a request to a business operation, process, or service and optionally waits for a response.

```xml
<call name='Send to Lab' target='LabSystemOperation' async='0' timeout='30'>
  <request type='EnsLib.HL7.Message'>
    <assign property="callrequest" value="request" action="set" />
  </request>
  <response type='EnsLib.HL7.Message' />
</call>
```

**IMPORTANT — HL7 `<call>` syntax**: For `EnsLib.HL7.Message` requests, always use `<assign property="callrequest" value="...">` inside `<request>` instead of putting `value=` directly on `<request>`. The `value=` attribute on `<request>` causes "Invalid BPL" compile errors in some IRIS versions. Similarly, omit `value=` on `<response>` — the response is stored via the BPL framework automatically. For enriched/cloned messages, use `value="context.enrichedMsg"` in the inner `<assign>`.

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `target` | string | Yes | — | Config item name of the target business host |
| `async` | boolean | No | `1` | `0` = synchronous (waits for response), `1` = asynchronous (fire-and-forget or use with `<sync>`) |
| `timeout` | string | No | `-1` | Timeout in seconds for sync calls. `-1` = no timeout. |

**Child elements:**

- `<request>` — defines the outgoing request message
  - `type` (required): class of the request message
  - `value` (required): expression that provides the request object (e.g., `request`, `context.myMsg`)
  - Can contain `<assign>` elements to set properties on the request before sending
- `<response>` — defines where to store the incoming response
  - `type` (required): class of the response message
  - `value` (required): expression for where to store the response (e.g., `response`, `context.labResponse`)
  - Can contain `<assign>` elements to extract values from the response after receiving

##### Sync vs Async Calls

| `async` | Behavior | Response Available? | Use When |
|---------|----------|-------------------|----------|
| `0` | Process suspends until response arrives (or timeout) | Yes, immediately after `<call>` | Need the response for subsequent logic |
| `1` | Process continues immediately | No (use `<sync>` to wait later) | Fire-and-forget, or scatter-gather pattern |

##### Dynamic Targets

Use `@` prefix to evaluate a property as the target name at runtime:

```xml
<call name='Dynamic Route' target='@process.TargetConfigName' async='0'>
  <request type='EnsLib.HL7.Message'>
    <assign property="callrequest" value="request" action="set" />
  </request>
  <response type='Ens.Response' />
</call>
```

##### Request/Response with Inline Assignments

Set properties on the request before sending, or extract from response after receiving:

```xml
<call name='Validate Order' target='ValidationService' async='0'>
  <request type='MyPkg.Msg.ValidateRequest'>
    <assign property='callrequest.OrderId' value='context.orderId' action='set'/>
    <assign property='callrequest.PatientMRN' value='request.{PID:PatientIdentifierList.IDNumber}' action='set'/>
  </request>
  <response type='MyPkg.Msg.ValidateResponse'>
    <assign property='context.isValid' value='callresponse.IsValid' action='set'/>
    <assign property='context.errorMessage' value='callresponse.ErrorText' action='set'/>
  </response>
</call>
```

**Note**: Inside `<request>`, reference properties via `callrequest` (a temporary object created automatically). Inside `<response>`, reference properties via `callresponse`. Do NOT put `value=` on the `<request>` or `<response>` elements — use `<assign>` children instead.

#### `<transform>` — Apply a DTL

Invokes a Data Transformation Language (DTL) class to transform a source message into a target message.

```xml
<transform name='Apply ADT Transform' class='MyPkg.DTL.ADTToSDA3'
  source='request' target='context.sdaContainer'/>
```

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `class` | string | Yes | Fully qualified DTL class name |
| `source` | string | Yes | Source object expression (e.g., `request`, `context.myMsg`) |
| `target` | string | Yes | Target object expression (e.g., `response`, `context.transformedMsg`) |
| `aux` | string | No | Auxiliary value passed to the DTL `Transform()` method |

**Important**: The target context property must have the correct type matching the DTL's target class. For `create='new'` DTLs, the target object is created fresh. For `create='copy'`, the target starts as a clone of the source.

#### `<rule>` — Invoke a Business Rule

Executes a business rule and stores the result.

```xml
<rule name='Evaluate Routing' rule='MyPkg.Rule.OrderRoutingRule'
  resultLocation='context.routingTarget'
  reasonLocation='context.routingReason'/>
```

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `rule` | string | Yes | Fully qualified rule class name |
| `resultLocation` | string | No | Context property to receive the rule's return value |
| `reasonLocation` | string | No | Context property to receive which specific rule fired |
| `ruleContext` | string | No | Expression providing context object to the rule engine (default: BPL context) |

### Data Activities

#### `<assign>` — Set a Property Value

Assigns a value to a property on request, response, context, or any accessible object.

```xml
<assign name='Set Status' value='"PROCESSED"' property='context.status' action='set'/>
<assign name='Copy MRN' value='request.{PID:PatientIdentifierList.IDNumber}' property='context.patientMRN' action='set'/>
<assign name='Set Event' value='"A08"' property='response.{MSH:MessageType.TriggerEvent}' action='set'/>
<assign name='Increment' value='context.retryCount + 1' property='context.retryCount' action='set'/>
```

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `property` | string | Yes | — | Target property path |
| `value` | string | Yes | — | Expression to evaluate and assign |
| `action` | string | No | `set` | Assignment action: `set`, `append`, `insert`, `remove`, `clear` |
| `key` | string | No | — | Key for collection operations (array key or list index) |

**Actions for collections:**

| Action | Use With | Description |
|--------|----------|-------------|
| `set` | Any property | Set the value (default) |
| `append` | List properties | Add to end of list |
| `insert` | List properties | Insert at position (requires `key`) |
| `remove` | List/Array properties | Remove element (requires `key`) |
| `clear` | List/Array properties | Clear the entire collection |

#### `<code>` — Inline ObjectScript

Execute arbitrary ObjectScript (or Python) code. Use CDATA sections for XML safety.

```xml
<code name='Build JSON'>
<![CDATA[
  Set tJSON = {"resourceType": "Patient", "id": (context.patientMRN)}
  Set tStream = ##class(%Stream.GlobalCharacter).%New()
  Do tStream.Write(tJSON.%ToJSON())
  Set context.Container = ##class(Ens.StreamContainer).%New(tStream)
]]>
</code>
```

**Important**: Inside `<code>` blocks, you access context/request/response directly as local variables — NOT with `..` method syntax. The variables `request`, `response`, `context`, `process`, and `status` are all in scope.

#### `<sql>` — Execute SQL

Execute embedded SQL inline. Use CDATA for the SQL body.

```xml
<sql name='Lookup Patient'>
<![CDATA[
  SELECT Name, DOB INTO :context.patientName, :context.patientDOB
  FROM MyApp.PatientTable
  WHERE MRN = :context.patientMRN
]]>
</sql>
```

- Use `:context.propName` for host variable binding (input and output)
- Use `:request.{FieldPath}` for HL7 virtual document values
- The SQL executes in the current namespace
- SQLCODE is available after execution in ObjectScript via the `SQLCODE` variable

### Control Flow Activities

#### `<if>` — Conditional Branch

Evaluates a condition and executes the `<true>` or `<false>` branch.

```xml
<if name='Check Message Type' condition='request.{MSH:MessageType.MessageCode}="ADT"'>
  <true>
    <transform name='Transform ADT' class='MyPkg.DTL.ADTTransform'
      source='request' target='context.transformedMsg'/>
  </true>
  <false>
    <trace value='"Non-ADT message, skipping transform"'/>
  </false>
</if>
```

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `condition` | string | Yes | ObjectScript expression that evaluates to true (nonzero) or false (0/"") |

**Child elements:**
- `<true>` — activities to execute when condition is true (contains activity list)
- `<false>` — activities to execute when condition is false (contains activity list)

Both `<true>` and `<false>` are optional, but at least one should be present.

##### Condition Expression Examples

```xml
<!-- String comparison -->
condition='request.{MSH:MessageType.MessageCode}="ADT"'

<!-- Not equals -->
condition='request.{PID:PatientIdentifierList.IDNumber}'=""'

<!-- Numeric comparison -->
condition='context.retryCount < 3'

<!-- Boolean context property -->
condition='context.isValid'

<!-- Contains (ObjectScript [ operator) -->
condition='request.{MSH:SendingApplication.NamespaceID}["EPIC"'

<!-- Utility function -->
condition='..Contains(request.{PID:PatientAddress.StateorProvince}, "AZ")'

<!-- Lookup existence -->
condition='..Lookup("FacilityMap", request.{MSH:SendingFacility.NamespaceID})'=""'

<!-- Combined with AND -->
condition='(request.{MSH:MessageType.MessageCode}="ADT")&amp;&amp;(request.{MSH:MessageType.TriggerEvent}="A01")'

<!-- Combined with OR -->
condition='(request.{MSH:MessageType.TriggerEvent}="A01")||(request.{MSH:MessageType.TriggerEvent}="A04")'

<!-- Status check -->
condition='$$$ISOK(status)'

<!-- Empty check -->
condition='request.{PID:PatientIdentifierList.IDNumber}'=""'
```

**Note**: In XML, `&&` must be written as `&amp;&amp;`, `"` as `&quot;` when inside attribute values, and `<` as `&lt;`. However, inside single-quoted attributes, double quotes can be used directly.

#### `<switch>` — Multi-way Branch

Evaluates multiple conditions in order and executes the first matching case.

```xml
<switch name='Route by Event'>
  <case name='Admit' condition='request.{MSH:MessageType.TriggerEvent}="A01"'>
    <call name='Send to Admit' target='AdmitProcessor' async='0'>
      <request type='EnsLib.HL7.Message'>
        <assign property="callrequest" value="request" action="set" />
      </request>
      <response type='Ens.Response' />
    </call>
  </case>
  <case name='Discharge' condition='request.{MSH:MessageType.TriggerEvent}="A03"'>
    <call name='Send to Discharge' target='DischargeProcessor' async='0'>
      <request type='EnsLib.HL7.Message'>
        <assign property="callrequest" value="request" action="set" />
      </request>
      <response type='Ens.Response' />
    </call>
  </case>
  <default name='Unknown Event'>
    <trace value='"Unhandled event: "_request.{MSH:MessageType.TriggerEvent}'/>
  </default>
</switch>
```

**Child elements:**
- `<case>` — one or more conditional branches
  - `name` (required): label for the case
  - `condition` (required): expression to evaluate
  - Contains an activity list
- `<default>` — optional catch-all branch (no condition)
  - Contains an activity list

Cases are evaluated top-to-bottom; the first matching case executes and the switch ends.

#### `<foreach>` — Iteration

Loops over a collection (list, array, or repeating HL7 segments).

```xml
<!-- Loop over HL7 repeating groups -->
<foreach name='Process Orders' property='request.{ORCgrp()}' key='k1'>
  <assign name='Get Order ID' value='request.{ORCgrp(k1).ORC:PlacerOrderNumber.EntityIdentifier}'
    property='context.currentOrderId' action='set'/>
  <trace value='"Processing order: "_context.currentOrderId'/>
</foreach>

<!-- Loop over a collection property -->
<foreach name='Process Items' property='context.itemList' key='idx'>
  <assign name='Get Item' value='context.itemList.GetAt(idx)'
    property='context.currentItem' action='set'/>
</foreach>
```

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `property` | string | Yes | Collection/repeating element to iterate over |
| `key` | string | Yes | Variable name for the loop index/key |

For HL7 messages, use the `()` suffix to get the count of repeating elements: `request.{ORCgrp()}`, `request.{PID:PatientIdentifierList()}`.

#### `<while>` — Conditional Loop

Repeats activities while a condition is true.

```xml
<while name='Retry Loop' condition='(context.retryCount &lt; 3)&amp;&amp;(context.isValid = 0)'>
  <call name='Retry Validation' target='ValidationService' async='0'>
    <request type='Ens.Request' value='request'/>
    <response type='Ens.Response' value='callresponse'/>
  </call>
  <assign name='Increment' value='context.retryCount + 1'
    property='context.retryCount' action='set'/>
</while>
```

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `condition` | string | Yes | Loop continues while this expression is true |

**Warning**: Ensure the condition will eventually become false to avoid infinite loops. Always include a counter or state change inside the loop.

### Synchronization Activities

#### `<sync>` — Wait for Async Calls

Waits for one or more previously made async calls to complete.

```xml
<!-- Fire two async calls -->
<call name='Call A' target='ServiceA' async='1'>
  <request type='Ens.Request' value='request'/>
  <response type='Ens.Response' value='context.responseA'/>
</call>
<call name='Call B' target='ServiceB' async='1'>
  <request type='Ens.Request' value='request'/>
  <response type='Ens.Response' value='context.responseB'/>
</call>

<!-- Wait for both -->
<sync name='Wait for A and B' calls='Call A,Call B' type='all' timeout='60'/>
```

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `calls` | string | Yes | — | Comma-separated list of async call `name` values to wait for |
| `type` | string | No | `all` | `all` = wait for every listed call; `any` = wait for the first one |
| `timeout` | string | No | — | Timeout in seconds |
| `allowResync` | boolean | No | `0` | If `1`, allows re-synchronizing on calls that already completed |

After `<sync>`, the responses from completed calls are available in the locations specified by each call's `<response>` element.

#### `<delay>` — Pause Execution

Suspends the process for a duration or until a specific time. The process is persisted to disk during the delay.

```xml
<!-- Delay for 30 seconds -->
<delay name='Wait 30s' duration='30'/>

<!-- Delay until a specific datetime (xsd:dateTime format) -->
<delay name='Wait Until' until='2024-01-15T08:00:00'/>

<!-- Delay using a context expression -->
<delay name='Dynamic Wait' duration='context.waitSeconds'/>
```

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `duration` | string | No | Seconds to delay (can be an expression) |
| `until` | string | No | xsd:dateTime to delay until (can be an expression) |

One of `duration` or `until` must be specified. The process suspends and frees its thread during the delay.

### Communication Activities

#### `<reply>` — Send Early Response

Forces an immediate reply to the original caller while the process continues executing additional activities. Useful for long-running processes that need to acknowledge receipt quickly.

```xml
<sequence>
  <!-- Validate and prepare response -->
  <assign name='Set ACK' value='"AA"' property='response.{MSH:MessageType.TriggerEvent}' action='set'/>

  <!-- Send response back to caller NOW -->
  <reply name='Send ACK'/>

  <!-- Continue with additional processing (caller doesn't wait) -->
  <transform name='Transform' class='MyPkg.DTL.MyTransform'
    source='request' target='context.transformedMsg'/>
  <call name='Archive' target='ArchiveOp' async='1'>
    <request type='EnsLib.HL7.Message' value='context.transformedMsg'/>
    <response type='Ens.Response' value='callresponse'/>
  </call>
</sequence>
```

No attributes beyond the common activity attributes. An implicit reply happens when the process completes — `<reply>` is only needed for early response.

#### `<alert>` — Send Alert Notification

Sends an alert notification to the production's alert handler (configured as `Ens.Alert`).

```xml
<alert name='Send Alert' value='"Critical: Patient lookup failed for MRN "_context.patientMRN'/>
```

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `value` | string | Yes | Expression that produces the alert text |

### Error Handling Activities

#### `<throw>` — Raise a Fault

Throws a named fault that can be caught by a `<catch>` handler in an enclosing `<scope>`.

```xml
<throw name='Validation Failed' fault='"VALIDATION_ERROR"'/>
```

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `fault` | string | Yes | Expression that evaluates to the fault string identifier |

#### `<catch>` — Handle a Specific Fault

Inside a `<scope>`'s `<faulthandlers>`, catches a specific named fault.

```xml
<catch fault='"VALIDATION_ERROR"' name='Handle Validation'>
  <assign value='context.errorCount + 1' property='context.errorCount' action='set'/>
  <trace value='"Validation error caught"'/>
</catch>
```

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `fault` | string | Yes | Fault string to match (must match the value thrown by `<throw>`) |

Contains an activity list to execute when the fault is caught.

#### `<catchall>` — Handle Any Fault

Inside a `<scope>`'s `<faulthandlers>`, catches any fault not caught by a specific `<catch>`.

```xml
<catchall name='Handle Any Error'>
  <alert value='"Unexpected error in BPL process"'/>
  <assign value='"ERROR"' property='context.status' action='set'/>
</catchall>
```

Contains an activity list. Only one `<catchall>` is allowed per scope.

#### `<compensate>` — Invoke Compensation

Calls a named compensation handler defined in the enclosing `<scope>`.

```xml
<compensate name='Undo Order' target='UndoOrderHandler'/>
```

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `target` | string | Yes | Name of the `<compensationhandler>` to invoke |

#### `<compensationhandler>` — Define Compensation Logic

Defines rollback/undo logic that can be invoked by `<compensate>` from within a fault handler.

```xml
<compensationhandlers>
  <compensationhandler name='UndoOrderHandler'>
    <sequence>
      <call name='Cancel Order' target='OrderCancelOp' async='0'>
        <request type='MyPkg.Msg.CancelRequest' value='callrequest'>
          <assign property='callrequest.OrderId' value='context.orderId' action='set'/>
        </request>
        <response type='Ens.Response' value='callresponse'/>
      </call>
    </sequence>
  </compensationhandler>
</compensationhandlers>
```

### Diagnostic Activities

#### `<trace>` — Write Trace Message

Writes a message to the IRIS event log / message trace. Visible in the Management Portal trace viewer.

```xml
<trace name='Log Start' value='"Processing message: "_request.{MSH:MessageControlID}'/>
<trace name='Log MRN' value='"Patient MRN: "_request.{PID:PatientIdentifierList.IDNumber}'/>
```

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `value` | string | Yes | Expression that produces the trace message text |

Trace messages appear as UserTrace entries in the event log. Essential for debugging BPL execution flow.

#### `<milestone>` — Record a Milestone

Records a named milestone in the process execution for auditing/tracking.

```xml
<milestone name='Order Validated' value='"Order "_context.orderId_" validated successfully"'/>
```

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `value` | string | Yes | Expression for the milestone value |

### Navigation Activities

#### `<label>` — Define a Jump Target

Defines a named label that can be the target of a `<branch>` activity.

```xml
<label name='RetryPoint'/>
```

No attributes beyond `name`. Used with `<branch>` for goto-style control flow.

#### `<branch>` — Conditional Goto

Transfers execution to a named `<label>` if a condition is true.

```xml
<branch name='Retry if Failed' condition='context.retryCount &lt; 3' label='RetryPoint'/>
```

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `condition` | string | Yes | Expression to evaluate |
| `label` | string | Yes | Name of the target `<label>` to jump to |

**Warning**: Use sparingly — `<branch>`/`<label>` creates goto-style control flow that can make processes hard to follow. Prefer `<while>`, `<if>`, or `<switch>` for structured control flow.

### XML/XSLT Activities

#### `<xpath>` — Evaluate XPath

Evaluates an XPath expression against an XML source.

```xml
<xpath name='Extract Patient' source='context.xmlStream'
  context='/root/patient' expression='@id'
  property='context.patientId'/>
```

| Attribute | Type | Required | Description |
|-----------|------|----------|-------------|
| `source` | string | Yes | Source XML stream/document |
| `context` | string | Yes | XPath context node |
| `expression` | string | Yes | XPath expression to evaluate |
| `property` | string | Yes | Context property to store the result |
| `schemaSpec` | string | No | Schema specification |
| `prefixMappings` | string | No | Namespace prefix mappings |

#### `<xslt>` — Apply XSLT Transformation

Applies an XSLT stylesheet to a source stream, producing a target stream.

```xml
<xslt name='Apply Stylesheet' source='context.inputXML'
  target='context.outputXML' xslurl='/csp/xslt/myTransform.xsl'/>
```

| Attribute | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `source` | string | Yes | — | Source stream expression |
| `target` | string | Yes | — | Target stream expression |
| `xslurl` | string | Yes | — | URL of the XSLT stylesheet |
| `xsltVersion` | string | No | `1.0` | XSLT version: `1.0` or `2.0` |

Can include `<parameter>` child elements for XSLT parameters.

### Utility Activities

#### `<empty>` — No-Op

A placeholder activity that does nothing. Useful in conditional branches where one path requires no action.

```xml
<if name='Check Valid' condition='context.isValid'>
  <true>
    <call name='Process' target='ProcessOp' async='0'>
      <request type='Ens.Request' value='request'/>
      <response type='Ens.Response' value='callresponse'/>
    </call>
  </true>
  <false>
    <empty name='Skip Processing'/>
  </false>
</if>
```

---

## Common Patterns

### Pattern 1: Request-Response (Synchronous Pipeline)

Receive a message, transform it, send to an operation, and return the response.

```objectscript
Class MyPkg.BPL.ADTProcessor Extends Ens.BusinessProcessBPL
{

XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='EnsLib.HL7.Message' response='EnsLib.HL7.Message'>
<context>
  <property name='transformedMsg' type='EnsLib.HL7.Message'/>
</context>
<sequence>

  <trace name='Log Input' value='"Received: "_request.{MSH:MessageType.MessageCode}_"^"_request.{MSH:MessageType.TriggerEvent}'/>

  <transform name='Apply DTL' class='MyPkg.DTL.ADTTransform'
    source='request' target='context.transformedMsg'/>

  <call name='Send to Target' target='OutboundHL7Op' async='0'>
    <request type='EnsLib.HL7.Message'>
      <assign property="callrequest" value="context.transformedMsg" action="set" />
    </request>
    <response type='EnsLib.HL7.Message' />
  </call>

</sequence>
</process>
}

}
```

### Pattern 2: Fire-and-Forget

Send a message to an operation without waiting for a response.

```objectscript
Class MyPkg.BPL.AsyncSender Extends Ens.BusinessProcessBPL
{

XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='EnsLib.HL7.Message' response='Ens.Response'>
<context/>
<sequence>

  <call name='Send to Archive' target='ArchiveFileOp' async='1'>
    <request type='EnsLib.HL7.Message'>
      <assign property="callrequest" value="request" action="set" />
    </request>
    <response type='Ens.Response' />
  </call>

  <trace name='Log Sent' value='"Message sent to archive"'/>

</sequence>
</process>
}

}
```

### Pattern 3: Scatter-Gather (Parallel Fan-Out)

Send a message to multiple targets in parallel, then wait for all responses.

```objectscript
Class MyPkg.BPL.FanOut Extends Ens.BusinessProcessBPL
{

XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='EnsLib.HL7.Message' response='Ens.Response'>
<context>
  <property name='responseA' type='Ens.Response'/>
  <property name='responseB' type='Ens.Response'/>
</context>
<sequence>

  <!-- Fire async calls -->
  <call name='Send to System A' target='SystemAOperation' async='1'>
    <request type='EnsLib.HL7.Message'>
      <assign property="callrequest" value="request" action="set" />
    </request>
    <response type='Ens.Response' />
  </call>

  <call name='Send to System B' target='SystemBOperation' async='1'>
    <request type='EnsLib.HL7.Message'>
      <assign property="callrequest" value="request" action="set" />
    </request>
    <response type='Ens.Response' />
  </call>

  <!-- Wait for all responses -->
  <sync name='Wait for All' calls='Send to System A,Send to System B' type='all' timeout='60'/>

  <trace name='All Done' value='"Both systems responded"'/>

</sequence>
</process>
}

}
```

### Pattern 4: Conditional Routing with Transform

Route HL7 messages to different targets based on message content, applying different transforms.

**Always use `<switch>` for multi-way message type branching** — not nested `<if>` chains. `<switch>` is clearer, evaluates cases top-to-bottom, and maps directly to the branching logic. Nested `<if>` creates deeply indented XML that is harder to read and debug.

```objectscript
Class MyPkg.BPL.ConditionalRouter Extends Ens.BusinessProcessBPL
{

XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='EnsLib.HL7.Message' response='Ens.Response'>
<context>
  <property name='transformedMsg' type='EnsLib.HL7.Message'/>
</context>
<sequence>

  <switch name='Route by Message Type'>
    <case name='ADT' condition='request.{MSH:MessageType.MessageCode}="ADT"'>
      <transform name='ADT Transform' class='MyPkg.DTL.ADTTransform'
        source='request' target='context.transformedMsg'/>
      <call name='Send ADT' target='ADTTarget' async='0'>
        <request type='EnsLib.HL7.Message'>
          <assign property="callrequest" value="context.transformedMsg" action="set" />
        </request>
        <response type='Ens.Response' />
      </call>
    </case>
    <case name='ORM' condition='request.{MSH:MessageType.MessageCode}="ORM"'>
      <call name='Send ORM' target='OrderTarget' async='0'>
        <request type='EnsLib.HL7.Message'>
          <assign property="callrequest" value="request" action="set" />
        </request>
        <response type='Ens.Response' />
      </call>
    </case>
    <default name='Unhandled'>
      <call name='Send to Bad Message' target='BadMessageFileOp' async='1'>
        <request type='EnsLib.HL7.Message'>
          <assign property="callrequest" value="request" action="set" />
        </request>
        <response type='Ens.Response' />
      </call>
    </default>
  </switch>

</sequence>
</process>
}

}
```

### Pattern 5: Error Handling with Scope/Catch

Protect risky operations with error handling and compensation.

```objectscript
Class MyPkg.BPL.SafeProcessor Extends Ens.BusinessProcessBPL
{

XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='EnsLib.HL7.Message' response='Ens.Response'>
<context>
  <property name='errorMessage' type='%String'/>
</context>
<sequence>

  <scope name='Protected Processing'>
    <sequence>

      <!-- Validate the message -->
      <if name='Check PID' condition='request.{PID:PatientIdentifierList.IDNumber}=""'>
        <true>
          <throw name='Missing MRN' fault='"MISSING_MRN"'/>
        </true>
      </if>

      <!-- Process the validated message -->
      <call name='Send to Target' target='OutboundOp' async='0'>
        <request type='EnsLib.HL7.Message'>
          <assign property="callrequest" value="request" action="set" />
        </request>
        <response type='Ens.Response' />
      </call>

    </sequence>
    <faulthandlers>
      <catch fault='"MISSING_MRN"' name='Handle Missing MRN'>
        <assign value='"Patient MRN is missing from PID-3"'
          property='context.errorMessage' action='set'/>
        <alert value='"Missing MRN: "_request.{MSH:MessageControlID}'/>
        <call name='Send to Error Queue' target='ErrorQueueOp' async='1'>
          <request type='EnsLib.HL7.Message'>
            <assign property="callrequest" value="request" action="set" />
          </request>
          <response type='Ens.Response' />
        </call>
      </catch>
      <catchall name='Handle Unknown Error'>
        <alert value='"Unexpected error processing message: "_request.{MSH:MessageControlID}'/>
      </catchall>
    </faulthandlers>
  </scope>

</sequence>
</process>
}

}
```

### Pattern 6: Sequential Processing with Iteration

Loop over repeating HL7 groups and process each.

```objectscript
Class MyPkg.BPL.OrderIterator Extends Ens.BusinessProcessBPL
{

XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='EnsLib.HL7.Message' response='Ens.Response'>
<context>
  <property name='orderCount' type='%Integer' initialExpression='0'/>
  <property name='currentOrderId' type='%String'/>
</context>
<sequence>

  <foreach name='Process Each Order' property='request.{ORCgrp()}' key='k1'>
    <assign name='Get Order ID' value='request.{ORCgrp(k1).ORC:PlacerOrderNumber.EntityIdentifier}'
      property='context.currentOrderId' action='set'/>

    <trace value='"Processing order #"_k1_": "_context.currentOrderId'/>

    <if name='Check Order Type' condition='request.{ORCgrp(k1).ORC:OrderControl}="NW"'>
      <true>
        <call name='New Order' target='NewOrderOp' async='0'>
          <request type='EnsLib.HL7.Message'>
            <assign property="callrequest" value="request" action="set" />
          </request>
          <response type='Ens.Response' />
        </call>
      </true>
      <false>
        <trace value='"Skipping non-new order: "_request.{ORCgrp(k1).ORC:OrderControl}'/>
      </false>
    </if>

    <assign name='Increment Count' value='context.orderCount + 1'
      property='context.orderCount' action='set'/>
  </foreach>

  <trace name='Summary' value='"Processed "_context.orderCount_" orders"'/>

</sequence>
</process>
}

}
```

### Pattern 7: Early Reply with Background Processing

Send an acknowledgment immediately, then continue processing in the background.

```objectscript
Class MyPkg.BPL.EarlyReplyProcess Extends Ens.BusinessProcessBPL
{

XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='EnsLib.HL7.Message' response='EnsLib.HL7.Message'>
<context>
  <property name='transformedMsg' type='EnsLib.HL7.Message'/>
</context>
<sequence>

  <!-- Build and send ACK immediately -->
  <code name='Build ACK'>
<![CDATA[
  Set tSC = request.NewReplyDocument(.tReply)
  Set response = tReply
]]>
  </code>
  <reply name='Send ACK Now'/>

  <!-- Continue with background processing -->
  <transform name='Transform' class='MyPkg.DTL.MyTransform'
    source='request' target='context.transformedMsg'/>
  <call name='Send to Hub' target='HubOperation' async='1'>
    <request type='EnsLib.HL7.Message' value='context.transformedMsg'/>
    <response type='Ens.Response' value='callresponse'/>
  </call>

</sequence>
</process>
}

}
```

### Pattern 8: Retry with Backoff

Retry a failing operation with a counter limit.

```xml
<process language='objectscript' request='Ens.Request' response='Ens.Response'>
<context>
  <property name='retryCount' type='%Integer' initialExpression='0'/>
  <property name='success' type='%Boolean' initialExpression='0'/>
</context>
<sequence>

  <label name='RetryPoint'/>

  <scope name='Try Call'>
    <sequence>
      <call name='External Call' target='ExternalService' async='0' timeout='10'>
        <request type='Ens.Request'>
          <assign property="callrequest" value="request" action="set" />
        </request>
        <response type='Ens.Response' />
      </call>
      <assign value='1' property='context.success' action='set'/>
    </sequence>
    <faulthandlers>
      <catchall name='Handle Failure'>
        <assign value='context.retryCount + 1' property='context.retryCount' action='set'/>
        <trace value='"Attempt "_context.retryCount_" failed"'/>
      </catchall>
    </faulthandlers>
  </scope>

  <if name='Should Retry' condition='(context.success = 0)&amp;&amp;(context.retryCount &lt; 3)'>
    <true>
      <delay name='Backoff' duration='context.retryCount * 5'/>
      <branch name='Go Retry' condition='1' label='RetryPoint'/>
    </true>
    <false>
      <if name='Final Check' condition='context.success = 0'>
        <true>
          <alert value='"External call failed after 3 retries"'/>
        </true>
      </if>
    </false>
  </if>

</sequence>
</process>
```

---

## BPL and Production Architecture

### How BPL Relates to Other Components

```
Business Service  ──request──>  BPL Process  ──call──>  Business Operation
                                    │
                                    ├── <transform> invokes DTL classes
                                    ├── <rule> invokes Routing Rules
                                    ├── <call> invokes Operations or other Processes
                                    └── <code> runs inline ObjectScript
```

- **DTLs** are invoked from BPL via `<transform>`. BPL orchestrates when/which DTL runs; the DTL handles field-level mapping.
- **Routing Rules** can be invoked from BPL via `<rule>` to get routing decisions. Alternatively, use `EnsLib.HL7.MsgRouter.RoutingEngine` directly (not BPL) for pure rule-based routing.
- **Productions** wire BPL processes as Items with `ClassName="MyPkg.BPL.MyProcess"`. The process receives messages from services (or other processes) via its configured input.

### When to Use BPL vs Routing Engine vs Code-Based Process

**BPL is the DEFAULT for all orchestration.** Code-based processes are the rare exception.

| Scenario | Use |
|----------|-----|
| Simple message routing by content (HL7 field values) | Routing Engine + Routing Rule |
| Transform + send to one target | **BPL** (simple sequence) |
| Conditional transforms/routing with multiple branches | **BPL** with `<if>`/`<switch>` |
| Parallel fan-out to multiple systems | **BPL** with `<flow>` or async `<call>` + `<sync>` |
| Long-running process with delays/timers | **BPL** with `<delay>` |
| Complex error handling/compensation | **BPL** with `<scope>`/`<catch>` |
| SQL lookups, enrichment, context extraction | **BPL** with `<sql>`, `<assign>`, `<code>` |
| Validate + transform + route conditionally | **BPL** with `<if>` + `<transform>` + `<call>` |
| >100 lines of dense ObjectScript with no decomposition possible | Code-based process (RARE — document why) |
| Performance-critical >10K msg/sec tight loop | Code-based process (RARE) |

**Why BPL is preferred:** Every BPL activity is a named, visible step in Visual Trace. Non-developers can read and validate the flow. Error handling (`<scope>`/`<catch>`) renders visually. The XML itself is the documentation. Code-based processes appear as a single opaque "OnRequest" block in traces — invisible to anyone who can't read ObjectScript.

**Before choosing code-based BP, ask:** Can the heavy ObjectScript live in a utility class method called from a `<code>` block inside a BPL? If yes, use BPL — you get traceability AND ObjectScript power.

### Production XML for a BPL Host

```xml
<Item Name="MyPkg.BPL.ADTProcessor" Category="Processing"
      ClassName="MyPkg.BPL.ADTProcessor" PoolSize="1" Enabled="true">
  <Setting Target="Host" Name="TargetConfigName">OutboundHL7Op</Setting>
</Item>
```

BPL processes are referenced in production XML by their class name, just like any other business process.

---

## Important Gotchas

### Request Immutability

The `request` object in BPL is **read-only** — you cannot call `SetValueAt()` on it. If you need to modify the incoming message (e.g., enrich an HL7 field), you must clone it first:

```xml
<context>
  <property name='enrichedMsg' type='EnsLib.HL7.Message' instantiate='0'/>
</context>
...
<code name='Clone and Enrich'>
<![CDATA[
  ; Clone the request to make it mutable
  Set context.enrichedMsg = request.%ConstructClone(1)
  Set tSC = context.enrichedMsg.SetValueAt("NewValue", "PID:PatientAccountNumber.IDNumber")
  Set tSC = context.enrichedMsg.%Save()
]]>
</code>
<!-- Send the modified clone, NOT the original request -->
<call name='Send Enriched' target='TargetOp' async='0'>
  <request type='EnsLib.HL7.Message' value='context.enrichedMsg'/>
  <response type='Ens.Response' value='callresponse'/>
</call>
```

**Key points:**
- Always use `%ConstructClone(1)` (the `1` means deep clone — required for HL7 messages)
- Store the clone in a context property
- Call `%Save()` after `SetValueAt()` to persist changes
- Send the context property in `<call>`, not `request`

### Alert Operation Class

When using `<alert>` in BPL, the production must have an alert handler configured with the config name `Ens.Alert`. The correct class is:

```xml
<Item Name="Ens.Alert" Category="Utility" ClassName="Ens.Alerting.NotificationOperation" PoolSize="0" Enabled="true"/>
```

**Common mistake**: `Ens.Alert.Operation.Log` does not exist. Use `Ens.Alerting.NotificationOperation`.

### OBRunion Schema Quirk (ORM_O01)

In HL7 version 2.3.1 and some 2.5 schemas, the `ORM_O01` message structure uses an `OBRunion` union type for the OBR segment group.

**ALWAYS use `<assign>` with the full union group path.** This works in the vast majority of cases and is the correct BPL-native approach:

```xml
<!-- Navigate through the full OBRunion group hierarchy -->
<assign name="Get Service ID" property="context.ServiceIdentifier"
  value="request.{ORCgrp(1).OBRuniongrp.OBRunion.OBR:UniversalServiceIdentifier.Identifier}" action="set"/>
```

The path `ORCgrp(1).OBRuniongrp.OBRunion.OBR:FieldName` navigates through the union type correctly. There are two common path variants — try both with `<assign>`:

```xml
<!-- Variant 1: OBRuniongrp.OBRunion.OBR (most schemas) -->
<assign name="GetOBR_v1" property="context.ServiceIdentifier"
  value="request.{ORCgrp(1).OBRuniongrp.OBRunion.OBR:UniversalServiceIdentifier.Identifier}" action="set"/>

<!-- Variant 2: OBRgrp.OBRunion.OBR (some older schemas) -->
<if name="CheckEmpty" condition='context.ServiceIdentifier=""'>
<true>
<assign name="GetOBR_v2" property="context.ServiceIdentifier"
  value="request.{ORCgrp(1).OBRgrp.OBRunion.OBR:UniversalServiceIdentifier.Identifier}" action="set"/>
</true>
</if>
```

**Do NOT use `<code>` with `GetSegmentAt()`/`GetValueAt()` for OBRunion.** The `<assign>` approach above works and keeps the BPL fully native. Agents that used `<code>` loops to find OBR segments were doing unnecessary work — `<assign>` with the full path is simpler and more reliable.

### Named Field Paths in BPL

**ALWAYS use named field paths** in BPL expressions, just as in DTL:
- **RIGHT**: `request.{MSH:MessageType.MessageCode}`, `request.{PID:PatientIdentifierList.IDNumber}`
- **WRONG**: `request.{MSH:9.1}`, `request.{PID:3.1}` — positional numbers are NEVER acceptable

This applies to `<assign>`, `<if condition>`, `<switch>/<case>`, `<trace>`, and `GetValueAt()` calls in `<code>` blocks.

### Verify Spec Field Numbers Against Schema

When a spec references fields by positional number (e.g., "PV1:18", "SCH:7.2", "OBR:4"), **always pull the segment schema** with ``get_schema` tool --segment <SEG>` and verify the positional number maps to the correct named path before using it.

**Why**: Specs often use positional numbers, but agents must use named paths. Mismatches are common:
- PV1:18 = `PatientType`, NOT `PreadmitNumber` (which is PV1:5)
- PV1:19 = `VisitNumber`, NOT `PatientType`
- SCH:7.2 = `AppointmentReason.Text`, NOT `AppointmentReason.Identifier` (which is SCH:7.1)

**Workflow**: Spec says "store ORC:2" → run ``get_schema` tool --segment ORC --fields` → confirm field 2 = `PlacerOrderNumber` → use `ORC:PlacerOrderNumber.EntityIdentifier` in BPL.

**Never assume** a positional number matches a field name that "sounds right." Always verify with the schema output.

### %Persistent Class Global Naming

When creating `%Persistent` classes for SQL tables in BPL exercises, keep global names short. IRIS global names have a 31-character limit. Use abbreviated `DataLocation` values:

```objectscript
Storage Default
{
<DataLocation>^Pkg.Short.TableD</DataLocation>
<IdLocation>^Pkg.Short.TableD</IdLocation>
<IndexLocation>^Pkg.Short.TableI</IndexLocation>
<StreamLocation>^Pkg.Short.TableS</StreamLocation>
<Type>%Storage.Persistent</Type>
}
```

**Common mistake**: Long package names like `^Very.Long.Package.Name.TableD` exceed 31 characters and cause compile errors.

### `<sql>` Is the Preferred BPL Element for SQL Operations

**Always use `<sql>` for INSERT, SELECT INTO, and DELETE operations in BPL.** It is a native BPL element that binds context properties directly with `:context.PropertyName` syntax:

```xml
<!-- INSERT -->
<sql name='Insert Row'>
<![CDATA[INSERT INTO SQLUser.MyTable (MRN, OrderNum, ServiceIdentifier) 
VALUES (:context.MRN, :context.OrderNum, :context.ServiceIdentifier)]]>
</sql>

<!-- SELECT INTO -->
<sql name='Get Service Identifier'>
<![CDATA[SELECT ServiceIdentifier INTO :context.ServiceIdentifier 
FROM SQLUser.MyTable WHERE MRN = :context.MRN AND OrderNum = :context.OrderNum]]>
</sql>

<!-- DELETE -->
<sql name='Delete Row'>
<![CDATA[DELETE FROM SQLUser.MyTable 
WHERE MRN = :context.MRN AND OrderNum = :context.OrderNum]]>
</sql>
```

Only fall back to utility class + `<code>` when `<sql>` truly cannot express the operation (e.g., complex multi-statement transactions, dynamic SQL). Using `<code>` for simple INSERT/SELECT/DELETE when `<sql>` would work is a quality failure (B7).

### BPL Compilation via Atelier API

The Atelier REST API's compile operation (``put_class` tool`) may not fully generate BPL code classes (Thread1, Context) in all IRIS versions. If the BPL compiles but fails at runtime with missing class errors, use `$system.OBJ.Compile()` as a fallback:

```bash
(use the equivalent tool; see the surrounding text)
```

This is the one legitimate exception to the "never use `exec` tool" rule — BPL compilation sometimes requires the full ObjectScript compiler.

### `<call>` Request/Response Assignment — ALWAYS Use `<assign>` for HL7

**NEVER use `value=` on `<request>` or `<response>` for HL7 messages.** It causes "Invalid BPL" compile errors. Always use `<assign property="callrequest">` inside `<request>`:

```xml
<!-- RIGHT — always use this pattern for HL7 -->
<call name='Send Message' target='TargetOp' async='1'>
<request type='EnsLib.HL7.Message'>
<assign property="callrequest" value="request" action="set" />
</request>
<response type='EnsLib.HL7.Message' />
</call>

<!-- WRONG — causes "Invalid BPL" compile error -->
<call name='Send Message' target='TargetOp' async='1'>
<request type='EnsLib.HL7.Message' value='request'/>
<response type='EnsLib.HL7.Message' value='response'/>
</call>
```

For enriched/cloned messages, change the `<assign>` value: `value="context.enrichedMsg"`. For custom message classes (`Ens.Request`, `MyPkg.Msg.*`), the `value=` attribute on `<request>` works — but using `<assign>` is still preferred for consistency.

## BPL Execution Model

### State Persistence

BPL processes are **persistent** — their state (context, position in the flow, pending async calls) is saved to disk after every suspension point. This means:

1. The process can survive server restarts
2. Async calls don't hold a thread while waiting for responses
3. `<delay>` activities free the process thread during the wait
4. Long-running processes (hours, days) are supported without resource consumption

### Suspension Points

A BPL process suspends (saves state and releases its thread) at:
- `<call async='1'>` — after sending the async request
- `<call async='0'>` — after sending the sync request (waits for response)
- `<sync>` — while waiting for async calls to complete
- `<delay>` — during the delay period

### Thread Model

- Each `<flow>` branch runs on its own logical thread
- The `%Thread` property tracks the current execution thread
- Async calls create completions that resume the correct thread when responses arrive

## Testing BPL Processes

### Workflow

1. **Push and compile** the BPL class using ``put_class` tool`
2. **Start the production** with `an `exec` call to `##class(Ens.Director).StartProduction(<Production>)` after stopping the current one`
3. **Send a test message** using ``exec` tool (HTTP POST to the CSP HL7 service URL)` (for HL7) or ``exec` tool (HTTP POST to the JSON service URL)` (for JSON)
4. **Check the trace** to verify the BPL execution path:
   ```bash
   <python> .claude/skills/interclaw/scripts/documents/`run_sql` tool --server <server> --namespace <ns> \
     --sql "SELECT TOP 5 ID, TimeCreated, SessionId, SourceConfigName, TargetConfigName, MessageBodyClassName FROM Ens.MessageHeader ORDER BY ID DESC"
   ```
5. **Check the event log** for trace messages and errors:
   ```bash
   <python> .claude/skills/interclaw/scripts/documents/`run_sql` tool --server <server> --namespace <ns> \
     --sql "SELECT TOP 10 ID, TimeLogged, Type, SourceClass, Text FROM Ens_Util.Log ORDER BY ID DESC"
   ```

### Debugging Tips

- Use `<trace>` liberally during development — trace messages appear in the event log and help track which branch was taken
- Check the visual trace in the Management Portal (Message Viewer > Visual Trace) to see the full call chain
- For HL7 processes, ensure the test message exercises the BPL's conditional logic (e.g., if checking `MSH:9.2`, send messages with the specific trigger events)
- After pushing a BPL, use `/goto-reload <ClassName>` to view it in the BPL editor

## Best Practices

### Design

1. **Keep BPL processes focused** — each BPL should handle one logical workflow. Don't combine unrelated message processing in a single BPL.
2. **Use context properties for intermediate state** — never try to use local variables across suspension points.
3. **Prefer `<transform>` over `<code>` for data mapping** — DTLs are testable, visual, and reusable. Use `<code>` only when DTL cannot express the logic.
4. **Name every activity** — names appear in traces and the BPL editor. Descriptive names make debugging much easier.
5. **Use `<scope>` for error handling around external calls** — external systems can fail; always handle the error case.

### Performance

6. **Use `async='1'` for fire-and-forget calls** — don't wait for responses you don't need.
7. **Use `<flow>` or async+sync for parallel operations** — don't serialize calls that can run in parallel.
8. **Avoid `<code>` blocks that do heavy processing** — if you need complex logic, put it in a code-based process or a utility class method and call it.
9. **Set appropriate timeouts on sync calls** — prevent processes from hanging indefinitely.

### Reliability

10. **Always include a `<catchall>` in `<scope>` blocks** — ensures unexpected errors don't leave the process stuck.
11. **Use `<reply>` for long-running processes** — if the caller expects a quick ACK, reply early and continue in the background.
12. **Log milestones for auditing** — use `<milestone>` or `<trace>` at key decision points.
13. **Validate inputs early** — check required fields at the start and `<throw>` faults for invalid messages.

### XML Authoring

14. **Always include the BPL namespace**: `XMLNamespace = "http://www.intersystems.com/bpl"` on the XData block.
15. **Use CDATA in `<code>` blocks**: `<![CDATA[ ... ]]>` prevents XML parsing issues with ObjectScript operators like `<`, `>`, `&`.
16. **Escape XML entities in attributes**: `&amp;` for `&`, `&lt;` for `<`, `&gt;` for `>`, `&quot;` for `"` inside double-quoted attributes. Inside single-quoted attributes, double quotes can be used directly.
17. **String literals in expressions** need double quotes inside single-quoted XML attributes: `value='"literal"'`.
18. **Do not set `xpos`/`ypos`/`xend`/`yend` manually** — these are managed by the BPL visual editor. When authoring BPL XML programmatically, omit them and let the editor lay them out.

## Complete XML Schema Summary

```
<process language request response [includes] [version] [layout]>
  <context>
    <property name type [collection] [initialExpression] [instantiate]/>*
  </context>
  <sequence | flow>
    <assign name property value [action] [key]/>
    <call name target [async] [timeout]>
      <request type value>
        <assign .../>*
      </request>
      <response type value>
        <assign .../>*
      </response>
    </call>
    <code name> CDATA </code>
    <sql name> CDATA </sql>
    <transform name class source target [aux]/>
    <rule name rule [resultLocation] [reasonLocation] [ruleContext]/>
    <if name condition>
      <true> activities </true>
      <false> activities </false>
    </if>
    <switch name>
      <case name condition> activities </case>*
      <default name> activities </default>
    </switch>
    <foreach name property key> activities </foreach>
    <while name condition> activities </while>
    <scope name>
      <sequence> activities </sequence>
      <faulthandlers>
        <catch fault name> activities </catch>*
        <catchall name> activities </catchall>
      </faulthandlers>
      <compensationhandlers>
        <compensationhandler name> activities </compensationhandler>*
      </compensationhandlers>
    </scope>
    <throw name fault/>
    <compensate name target/>
    <trace name value/>
    <alert name value/>
    <milestone name value/>
    <delay name [duration] [until]/>
    <sync name calls [type] [timeout] [allowResync]/>
    <reply name/>
    <label name/>
    <branch name condition label/>
    <xpath name source context expression property [schemaSpec] [prefixMappings]/>
    <xslt name source target xslurl [xsltVersion]/>
    <empty name/>
    <sequence name> activities </sequence>
    <flow name> activities </flow>
  </sequence | flow>
</process>
```
