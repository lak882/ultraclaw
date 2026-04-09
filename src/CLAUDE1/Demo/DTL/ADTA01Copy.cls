/// ADT_A01 to ADT_A01 copy transformation
Class Demo.DTL.ADTA01Copy Extends Ens.DataTransformDTL [ DependsOn = EnsLib.HL7.Message ]
{

XData DTL [ XMLNamespace = "http://www.intersystems.com/dtl" ]
{
<transform sourceClass='EnsLib.HL7.Message' targetClass='EnsLib.HL7.Message' sourceDocType='2.5.1:ADT_A01' targetDocType='2.5.1:ADT_A01' create='copy'>
</transform>
}

}
