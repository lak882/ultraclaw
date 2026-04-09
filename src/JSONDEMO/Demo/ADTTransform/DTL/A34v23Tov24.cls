Class Demo.ADTTransform.DTL.A34v23Tov24 Extends Ens.DataTransformDTL [ DependsOn = (EnsLib.HL7.Message, EnsLib.HL7.Message) ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='2.3:ADT_A43' targetDocType='2.4:ADT_A05' create='new' language='objectscript' >
<annotation>Transform HL7 2.3 ADT^A34 (Merge Patient) to HL7 2.4 ADT^A34 using ADT_A05 structure</annotation>

<!-- Copy MSH segment with version update -->
<code>
<![CDATA[
  // Copy entire MSH segment
  set target = ##class(EnsLib.HL7.Message).%New()
  set target.DocType = "2.4:ADT_A05"

  // MSH segment - copy most fields, update version
  do target.SetValueAt(source.GetValueAt("MSH:1"),"MSH:1")
  do target.SetValueAt(source.GetValueAt("MSH:2"),"MSH:2")
  do target.SetValueAt(source.GetValueAt("MSH:3"),"MSH:3")
  do target.SetValueAt(source.GetValueAt("MSH:4"),"MSH:4")
  do target.SetValueAt(source.GetValueAt("MSH:5"),"MSH:5")
  do target.SetValueAt(source.GetValueAt("MSH:6"),"MSH:6")
  do target.SetValueAt(source.GetValueAt("MSH:7"),"MSH:7")
  do target.SetValueAt(source.GetValueAt("MSH:8"),"MSH:8")
  do target.SetValueAt("ADT","MSH:9.1")
  do target.SetValueAt("A34","MSH:9.2")
  do target.SetValueAt(source.GetValueAt("MSH:10"),"MSH:10")
  do target.SetValueAt(source.GetValueAt("MSH:11"),"MSH:11")
  do target.SetValueAt("2.4","MSH:12")
  do target.SetValueAt(source.GetValueAt("MSH:13"),"MSH:13")
  do target.SetValueAt(source.GetValueAt("MSH:14"),"MSH:14")
  do target.SetValueAt(source.GetValueAt("MSH:15"),"MSH:15")
  do target.SetValueAt(source.GetValueAt("MSH:16"),"MSH:16")
  do target.SetValueAt(source.GetValueAt("MSH:17"),"MSH:17")
  do target.SetValueAt(source.GetValueAt("MSH:18"),"MSH:18")

  // EVN segment - copy all fields
  for i=1:1:source.GetValueAt("EVN:*") {
    do target.SetValueAt(source.GetValueAt("EVN:"_i),"EVN:"_i)
  }

  // PID segment - copy all fields
  for i=1:1:source.GetValueAt("PID:*") {
    do target.SetValueAt(source.GetValueAt("PID:"_i),"PID:"_i)
  }

  // PD1 segment if exists
  if source.GetValueAt("PD1") '= "" {
    for i=1:1:source.GetValueAt("PD1:*") {
      do target.SetValueAt(source.GetValueAt("PD1:"_i),"PD1:"_i)
    }
  }

  // NK1 segments (repeating)
  set nk1Count = source.GetValueAt("NK1(*)")
  for k=1:1:nk1Count {
    for i=1:1:source.GetValueAt("NK1("_k_"):*") {
      do target.SetValueAt(source.GetValueAt("NK1("_k_"):"_i),"NK1("_k_"):"_i)
    }
  }

  // PV1 segment
  for i=1:1:source.GetValueAt("PV1:*") {
    do target.SetValueAt(source.GetValueAt("PV1:"_i),"PV1:"_i)
  }

  // PV2 segment if exists
  if source.GetValueAt("PV2") '= "" {
    for i=1:1:source.GetValueAt("PV2:*") {
      do target.SetValueAt(source.GetValueAt("PV2:"_i),"PV2:"_i)
    }
  }

  // DB1 segments (repeating)
  set db1Count = source.GetValueAt("DB1(*)")
  for k=1:1:db1Count {
    for i=1:1:source.GetValueAt("DB1("_k_"):*") {
      do target.SetValueAt(source.GetValueAt("DB1("_k_"):"_i),"DB1("_k_"):"_i)
    }
  }

  // OBX segments (repeating)
  set obxCount = source.GetValueAt("OBX(*)")
  for k=1:1:obxCount {
    for i=1:1:source.GetValueAt("OBX("_k_"):*") {
      do target.SetValueAt(source.GetValueAt("OBX("_k_"):"_i),"OBX("_k_"):"_i)
    }
  }

  // AL1 segments (repeating)
  set al1Count = source.GetValueAt("AL1(*)")
  for k=1:1:al1Count {
    for i=1:1:source.GetValueAt("AL1("_k_"):*") {
      do target.SetValueAt(source.GetValueAt("AL1("_k_"):"_i),"AL1("_k_"):"_i)
    }
  }

  // DG1 segments (repeating)
  set dg1Count = source.GetValueAt("DG1(*)")
  for k=1:1:dg1Count {
    for i=1:1:source.GetValueAt("DG1("_k_"):*") {
      do target.SetValueAt(source.GetValueAt("DG1("_k_"):"_i),"DG1("_k_"):"_i)
    }
  }

  // DRG segment if exists
  if source.GetValueAt("DRG") '= "" {
    for i=1:1:source.GetValueAt("DRG:*") {
      do target.SetValueAt(source.GetValueAt("DRG:"_i),"DRG:"_i)
    }
  }

  // GT1 segments (repeating)
  set gt1Count = source.GetValueAt("GT1(*)")
  for k=1:1:gt1Count {
    for i=1:1:source.GetValueAt("GT1("_k_"):*") {
      do target.SetValueAt(source.GetValueAt("GT1("_k_"):"_i),"GT1("_k_"):"_i)
    }
  }

  // ACC segment if exists
  if source.GetValueAt("ACC") '= "" {
    for i=1:1:source.GetValueAt("ACC:*") {
      do target.SetValueAt(source.GetValueAt("ACC:"_i),"ACC:"_i)
    }
  }

  // UB1 segment if exists
  if source.GetValueAt("UB1") '= "" {
    for i=1:1:source.GetValueAt("UB1:*") {
      do target.SetValueAt(source.GetValueAt("UB1:"_i),"UB1:"_i)
    }
  }

  // UB2 segment if exists
  if source.GetValueAt("UB2") '= "" {
    for i=1:1:source.GetValueAt("UB2:*") {
      do target.SetValueAt(source.GetValueAt("UB2:"_i),"UB2:"_i)
    }
  }
]]>
</code>

</transform>
}

}
