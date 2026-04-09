Class Demo.Nicholai.DTL.ADTA01ToADTA03 Extends Ens.DataTransformDTL [ DependsOn = (EnsLib.HL7.Message, EnsLib.HL7.Message) ]
{

Parameter IGNOREMISSINGSOURCE = 1;

Parameter REPORTERRORS = 1;

Parameter TREATEMPTYREPEATINGFIELDASNULL = 0;

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='2.5.1:ADT_A01' targetDocType='2.5.1:ADT_A03' create='new' language='objectscript' >
<annotation>Transform ADT_A01 (Admit) to ADT_A03 (Discharge)</annotation>
<assign value='source' property='target' action='set' />
<assign value='"ADT"' property='target.{MSH:9.1}' action='set' />
<assign value='"A03"' property='target.{MSH:9.2}' action='set' />
<assign value='##class(Ens.Util.FunctionSet).ConvertDateTime(##class(%Library.UTC).NowUTC(),"%q")' property='target.{MSH:7}' action='set' />
</transform>
}

}
