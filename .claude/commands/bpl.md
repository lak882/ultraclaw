Create or update a BPL (Business Process Language) visual process.

Usage: /bpl <description>

**BPL is the DEFAULT process type for all orchestration.** Use BPL instead of code-based BP unless the user explicitly requests ObjectScript or the logic requires >100 lines of dense ObjectScript that cannot be decomposed.

The description should specify what the process does — requests it receives, calls it makes, and logic it applies.

## Why BPL over code-based BP

- **Visual Trace**: Every activity appears as a named step — see exactly where messages are, what failed, and why
- **Non-developer readable**: Interface analysts and project managers can validate flows without ObjectScript knowledge
- **Self-documenting**: Named activities (`<call name='Send to Lab'>`) describe intent — the BPL IS the documentation
- **Built-in error viz**: `<scope>` + `<catch>` blocks render visually in the BPL diagram
- **Consistent debugging**: `<trace>` and `<milestone>` elements emit named events visible in Visual Trace

## Steps

1. **Read the BPL reference** at `.claude/skills/interclaw-bpl/bpl-reference.md` for the full activity catalog, patterns, and gotchas.

2. **Generate the BPL class** fulfilling the user's requirements. Save to `src/<Namespace>/<Pkg>/BPL/<ClassName>.cls`.

   BPL classes extend `Ens.BusinessProcessBPL` with XML XDATA:
   ```objectscript
   Class <Pkg>.BPL.<Name>Process Extends Ens.BusinessProcessBPL
   {

   XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
   {
   <process language='objectscript' request='EnsLib.HL7.Message' response='EnsLib.HL7.Message'>
   <context>
     <property name='tempMsg' type='EnsLib.HL7.Message' instantiate='0'/>
   </context>
   <sequence>

     <!-- Apply transformation -->
     <transform name='Apply DTL' class='<Pkg>.DTL.<Name>'
       source='request' target='context.tempMsg'/>

     <!-- Send to target -->
     <call name='Send to Target' target='TargetOperation' async='0'>
       <request type='EnsLib.HL7.Message' value='context.tempMsg'/>
       <response type='EnsLib.HL7.Message' value='response'/>
     </call>

   </sequence>
   </process>
   }

   }
   ```

   Key elements: `<call>` (invoke operation/process), `<transform>` (apply DTL), `<if>`/`<switch>` (conditionals), `<foreach>` (iteration), `<code>` (inline ObjectScript), `<assign>` (set property), `<trace>` (debug), `<scope>`/`<catch>` (error handling), `<flow>` (parallel), `<sql>` (embedded SQL), `<delay>` (timers).

3. **Push and compile.**
