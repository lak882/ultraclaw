# Rule Elements Reference

`<rule>`, `<constraint>`, `<when>`, `<send>`, `<return>`, `<delegate>` reference. Load when writing the body of a rule.

## `<rule>` — Named rule block

```xml
<rule name="ADT Messages" disabled="false">
  <!-- constraints, then when blocks -->
</rule>
```

| Attribute | Description |
|-----------|-------------|
| `name` | Display name in the rule editor |
| `disabled` | Set `"true"` to disable without deleting |

## `<constraint>` — Pre-filter before condition evaluation

Constraints narrow which messages the rule evaluates at all. They are evaluated before `<when>` conditions and are more efficient than equivalent condition expressions.

```xml
<constraint name="msgClass" value="EnsLib.HL7.Message"/>
<constraint name="docCategory" value="2.5.1"/>
<constraint name="docName" value="ADT_A01"/>
<constraint name="docName" value="ADT_A01,ADT_A04,ADT_A08"/>
```

| Constraint name | Filters on |
|-----------------|-----------|
| `msgClass` | Message object class |
| `docCategory` | HL7 schema category (e.g., `2.5.1`) |
| `docName` | HL7 message structure name (e.g., `ADT_A01`); comma-separated for multiple |

Use `<constraint>` for message type filtering, not `HL7.{MSH:MessageType...}` conditions. See pitfalls.

## `<when>` — Conditional test

```xml
<when condition="1">
  <!-- actions executed when condition is true -->
  <comment text="Describe why this branch exists"/>
  <send transform="..." target="..."/>
  <return/>
</when>
```

Use `condition="1"` when the constraint already filters to the exact message type needed. Add a `<comment>` inside every `<when>` block — these appear in the visual rule editor and document intent.

## `<send>` — Route to a target

```xml
<send transform="MyApp.DTL.ADTTransform" target="ADTProcessor"/>
<send transform="" target="ArchiveFileOp"/>
```

| Attribute | Description |
|-----------|-------------|
| `transform` | DTL class to apply before sending (empty string for pass-through) |
| `target` | Production config item name to send to |

## `<return>` — Stop processing after this rule

```xml
<return/>
```

Place after `<send>` for exclusive routing (one target only). Omit when the message should fan out to multiple targets across subsequent rules.

## `<delegate>` — Hand off to another rule class

```xml
<delegate target="MyApp.Rule.SpecialCaseRule"/>
```

Transfers evaluation to another `Ens.Rule.Definition` subclass. Useful for decomposing large rule sets.

## `<comment>` — Inline documentation

```xml
<comment text="Route all ADT A01 admissions to the hub"/>
```

Appears in the visual rule editor. Add one inside every `<when>` block.
