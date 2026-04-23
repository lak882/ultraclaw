# Portal Navigation Reference

How to construct Management Portal URLs for InterClaw components.

## URL Format

```
{origin}{pathPrefix}/ui/interop/interclaw/index.html#/portal/csp/healthshare/{namespace}/{ZenPage}
```

**Variables:**
- `{origin}` - Browser origin (e.g., `http://vmdev1.iscinternal.com`)
- `{pathPrefix}` - CSP application path (e.g., `/interclaw-test`)
- `{namespace}` - IRIS namespace (e.g., `INTERCLAW`)
- `{ZenPage}` - ZEN portal page with query parameters

## Component Types

| Component | ZEN Page Pattern | Example |
|-----------|------------------|---------|
| Production | `EnsPortal.ProductionConfig.zen?PRODUCTION={name}` | `EnsPortal.ProductionConfig.zen?PRODUCTION=Demo.Production` |
| DTL | `EnsPortal.DTLEditor.zen?DT={name}.cls` | `EnsPortal.DTLEditor.zen?DT=Demo.DTL.Transform.cls` |
| Routing Rule | `EnsPortal.RuleEditor.zen?RULE={name}` | `EnsPortal.RuleEditor.zen?RULE=Demo.Rule.RoutingRule` |
| BPL | `EnsPortal.BPLEditor.zen?BP={name}.cls` | `EnsPortal.BPLEditor.zen?BP=Demo.BPL.Process.cls` |
| HL7 Schema | `EnsPortal.HL7.SchemaDocumentStructure.zen?MS={category}:{structure}` | `EnsPortal.HL7.SchemaDocumentStructure.zen?MS=2.5.1:ADT_A01` |
| Lookup Table | `EnsPortal.LookupSettings.zen?LookupTable={name}.lut` | `EnsPortal.LookupSettings.zen?LookupTable=FacilityMap.lut` |
| Message Viewer | `EnsPortal.MessageContents.zen?HeaderId={id}` | `EnsPortal.MessageContents.zen?HeaderId=12345` |
| Visual Trace | `EnsPortal.VisualTrace.zen?SESSIONID={sessionId}` | `EnsPortal.VisualTrace.zen?SESSIONID=67890` |
| Event Log | `EnsPortal.EventLog.zen` | `EnsPortal.EventLog.zen` |
| Message Queue | `EnsPortal.Queues.zen` | `EnsPortal.Queues.zen` |

## Full Example URLs

### Production Config
```
http://vmdev1.iscinternal.com/interclaw-test/ui/interop/interclaw/index.html#/portal/csp/healthshare/INTERCLAW/EnsPortal.ProductionConfig.zen?PRODUCTION=Demo.Production
```

### DTL Editor
```
http://vmdev1.iscinternal.com/interclaw-test/ui/interop/interclaw/index.html#/portal/csp/healthshare/INTERCLAW/EnsPortal.DTLEditor.zen?DT=Demo.DTL.Transform.cls
```

### Routing Rule Editor
```
http://vmdev1.iscinternal.com/interclaw-test/ui/interop/interclaw/index.html#/portal/csp/healthshare/INTERCLAW/EnsPortal.RuleEditor.zen?RULE=Demo.Rule.RoutingRule
```

### Visual Trace
```
http://vmdev1.iscinternal.com/interclaw-test/ui/interop/interclaw/index.html#/portal/csp/healthshare/INTERCLAW/EnsPortal.VisualTrace.zen?SESSIONID=12345
```

## When to Output Portal Links

Output portal links when:
- User explicitly asks to open or navigate to a component
- After creating or updating a component (at end of response)
- When referencing a component that user should review

**Format in markdown:**
```markdown
[Component Name — Editor Type](full-url)
```

**Example:**
```markdown
[Demo.Production — Production Config](http://vmdev1.iscinternal.com/interclaw-test/ui/interop/interclaw/index.html#/portal/csp/healthshare/INTERCLAW/EnsPortal.ProductionConfig.zen?PRODUCTION=Demo.Production)
```

## Context Variables

Origin and pathPrefix typically come from session context or configuration. Namespace comes from the active namespace selection. If these values are not available in context, they must be provided by the user or inferred from environment.
