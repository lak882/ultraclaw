Create or update an HL7 Routing Rule.

Usage: /rule <description>

The description should specify conditions to match and where to route messages.

Steps:

1. **Generate the routing rule class** fulfilling the user's requirements. Save to `src/<Namespace>/<Pkg>/Rule/<ClassName>.cls`.

   **Structure:**
   - `Parameter RuleAssistClass = "EnsLib.HL7.MsgRouter.RuleAssist"` for HL7 rules
   - `context="EnsLib.HL7.MsgRouter.RoutingEngine"` and `production="<Pkg>.Production"`
   - Always set `alias` on `<ruleDefinition>`
   - Give each `<ruleSet>` a descriptive `name`

   **Message type filtering — use constraints, not conditions:**
   - `<constraint name="docCategory" value="2.5.1"/>` and `<constraint name="docName" value="ORU_R01,ORM_O01"/>`
   - Do NOT use `||`-chained conditions on `MSH:9.2`
   - Group rules by message type with their own `docName` constraints

   **Conditions and flow:**
   - Use `=` for coded values (NOT `[` which causes false matches), `!=` for not-equals
   - Use **named field paths** (e.g., `OBR:UniversalServiceIdentifier.Identifier`) not numeric
   - XML entity encoding: `"` → `&quot;`, `&` → `&amp;`
   - `<return/>` after `<send>` for exclusive routing; omit for fan-out
   - `<comment text="..."/>` inside every `<when>` block

2. **Push and compile.**

**Important**: `/rule` creates routing rules ONLY. Never create a production class — use `/production` for that.
