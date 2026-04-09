Class EirSystems.BPL.ADTAdmitProcess Extends Ens.BusinessProcessBPL
{

XData BPL [ XMLNamespace = "http://www.intersystems.com/bpl" ]
{
<process language='objectscript' request='EnsLib.HL7.Message' response='Ens.Response'>
<context>
<property name='admitRequest' type='EirSystems.Msg.AdmitRequest' instantiate='0'/>
</context>
<sequence>

<transform name='HL7 to JSON AdmitRequest' class='EirSystems.DTL.ADTA01ToAdmitJSON' source='request' target='context.admitRequest'/>

<code name='Trace MSH Section'><![CDATA[
 Do context.admitRequest.msh.%JSONExportToString(.tJSON)
 $$$TRACE("[MSH] "_tJSON)
]]></code>

<code name='Trace PID Section'><![CDATA[
 Do context.admitRequest.pid.%JSONExportToString(.tJSON)
 $$$TRACE("[PID] "_tJSON)
]]></code>

<code name='Trace AL1 Entries'><![CDATA[
 For i=1:1:context.admitRequest.al1.Count() {
   Set tAL1 = context.admitRequest.al1.GetAt(i)
   Do tAL1.%JSONExportToString(.tJSON)
   $$$TRACE("[AL1-"_i_"] "_tJSON)
 }
]]></code>

<code name='Trace Full JSON'><![CDATA[
 Set tFormatter = ##class(%JSON.Formatter).%New()
 Do context.admitRequest.%JSONExportToString(.tCompact)
 Do tFormatter.FormatToString(tCompact, .tPretty)
 $$$TRACE("[Full JSON]"_$char(10)_tPretty)
]]></code>

<call name='Send to File' target='To_AdmitJSON_File' async='0'>
<request type='EirSystems.Msg.AdmitRequest'>
<assign property='callrequest' value='context.admitRequest' action='set'/>
</request>
</call>

</sequence>
</process>
}

Storage Default
{
<Type>%Storage.Persistent</Type>
}

}
