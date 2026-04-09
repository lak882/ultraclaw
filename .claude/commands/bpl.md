Create or update a BPL (Business Process Language) visual process.

Usage: /bpl <description>

The description should specify what the process does — requests it receives, calls it makes, and logic it applies.

Steps:

1. **Generate the BPL class** fulfilling the user's requirements. Save to `src/<Namespace>/<Pkg>/BPL/<ClassName>.cls`.

   BPL classes extend `Ens.BusinessProcessBPL` with XML XDATA:
   ```objectscript
   Class <Pkg>.BPL.<Name>Process Extends Ens.BusinessProcessBPL
   {
     XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
     {
       <process language='objectscript' request='EnsLib.HL7.Message' response='EnsLib.HL7.Message'>
         <context><!-- intermediate state --></context>
         <sequence><!-- BPL elements --></sequence>
       </process>
     }
   }
   ```

   Key elements: `<call>` (invoke operation/process), `<transform>` (apply DTL), `<if>`/`<switch>` (conditionals), `<foreach>` (iteration), `<code>` (inline ObjectScript), `<assign>` (set property), `<trace>` (debug), `<fork>`/`<join>` (parallel).

2. **Push and compile.**
