Scanning for Deprecated Code
                              Version 2026.1
                               2026-04-20




   InterSystems Corporation One Congress Street Boston MA 02114 www.intersystems.com
Scanning for Deprecated Code
PDF generated on 2026-04-20
InterSystems IRIS Version 2026.1
Copyright © 2026 InterSystems Corporation
All rights reserved.

InterSystems®, HealthShare Care Community®, HealthShare Unified Care Record®, InterSystems IRIS® IntegratedML®, InterSystems
Caché®, InterSystems Ensemble®, InterSystems HealthShare®, InterSystems IRIS®, InterSystems IRIS® for Health, and TrakCare are
registered trademarks of InterSystems Corporation. HealthShare® Health Connect Cloud™, InterSystems® Data Fabric Studio™, and
InterSystems Supply Chain Orchestrator™ are trademarks of InterSystems Corporation. TrakCare is a registered trademark in Australia
and the European Union.

All other brand or product names used herein are trademarks or registered trademarks of their respective companies or organizations.

This document contains trade secret and confidential information which is the property of InterSystems Corporation, One Congress Street,
Boston, MA 02114, or its affiliates, and is furnished for the sole purpose of the operation and maintenance of the products of InterSystems
Corporation. No part of this publication is to be used for any other purpose, and this publication is not to be reproduced, copied, disclosed,
transmitted, stored in a retrieval system or translated into any human or computer language, in any form, by any means, in whole or in part,
without the express prior written consent of InterSystems Corporation.

The copying, use and disposition of this document and the software programs described herein is prohibited except to the limited extent
set forth in the standard software license agreement(s) of InterSystems Corporation covering such programs and related documentation.
InterSystems Corporation makes no representations and warranties concerning such software programs other than those set forth in such
standard software license agreement(s). In addition, the liability of InterSystems Corporation for any losses or damages relating to or arising
out of the use of such software programs is limited in the manner set forth in such standard software license agreement(s).

THE FOREGOING IS A GENERAL SUMMARY OF THE RESTRICTIONS AND LIMITATIONS IMPOSED BY INTERSYSTEMS
CORPORATION ON THE USE OF, AND LIABILITY ARISING FROM, ITS COMPUTER SOFTWARE. FOR COMPLETE INFORMATION
REFERENCE SHOULD BE MADE TO THE STANDARD SOFTWARE LICENSE AGREEMENT(S) OF INTERSYSTEMS CORPORATION,
COPIES OF WHICH WILL BE MADE AVAILABLE UPON REQUEST.

InterSystems Corporation disclaims responsibility for errors which may appear in this document, and it reserves the right, in its sole discretion
and without notice, to make substitutions and modifications in the products and practices described in this document.

For Support questions about any InterSystems products, contact:

                                           InterSystems Worldwide Response Center (WRC)
                                           Tel:    +1-617-621-0700
                                           Tel:    +44 (0) 844 854 2917
                                         Email:    support@InterSystems.com
        Table of Contents
        Scanning for Deprecated Code.............................................................................................................. 1
            1 ScanDocuments Query .................................................................................................................. 1
            2 ScanDocument Query ................................................................................................................... 1
            3 Example ......................................................................................................................................... 1
            4 Scanning Mapped Code ................................................................................................................ 2
            5 See Also ......................................................................................................................................... 2




Scanning for Deprecated Code                                                                                                                                         iii
Scanning for Deprecated Code
The class %SYSTEM.CodeScanner enables you to quickly find code that refers to deprecated classes and deprecated class
members. This class provides two class queries, described here.




1 ScanDocuments Query
The ScanDocuments class query returns a result set that contains the following fields:
•   Document identifies the class or routine that contains the reference. For example:

    ResearchXForms.BasicDemo.cls

•   Location identifies the location of the reference, within the given class or routine. For example:

    ClassMethod CreateOne Implementation+4

•   Message explains what is deprecated. For example:

    Class '%Library.FileBinaryStream' is deprecated.


By default, the query scans only classes and routines in the default routine database for the current namespace, although
you can pass a parameter to include mapped code. Also, the query ignores classes and routines that have names starting
with %, as well as any classes that are marked as deprecated.
The query is projected to SQL as the %SYSTEM.ScanDocuments stored procedure.




2 ScanDocument Query
The ScanDocument class query takes one argument document, which is the name of a class, MAC routine, or INT routine.
This argument includes the file extension, for example: MyPkg.MyClass.cls
This query returns a result set that contains the following fields:
•   Location indicates the line number or class keyword describing where the deprecated reference is, within the given
    code item.
•   Message string describing the deprecated reference.




3 Example
For example, you could write code as follows:




Scanning for Deprecated Code                                                                                                1
Scanning Mapped Code


Class Member
ClassMethod Check()
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%PrepareClassQuery("%SYSTEM.CodeScanner","ScanDocuments")
    if $$$ISERR(status) {quit}
    set rset = stmt.%Execute()
    if rset.%SQLCODE<0 {quit}

    while rset.%Next() {
        set Document=rset.%Get("Document")
        set Location=rset.%Get("Location")
        set Message=rset.%Get("Message")
        write !, Document_" "_Location_" "_Message
    }
}

The following shows example output:

ResearchXForms.BasicDemo.cls Property BinStream Type Class '%Library.GlobalBinaryStream' is deprecated.
ResearchXForms.BasicDemo.cls Property CharStream1 Type Class '%Library.GlobalCharacterStream' is
deprecated.
ResearchXForms.BasicDemo.cls Property CharStream2 Type Class '%Library.GlobalCharacterStream' is
deprecated.
ResearchXForms.BasicDemo.cls Property CharStream3 Type Class '%Library.GlobalCharacterStream' is
deprecated.
ResearchXForms.BasicDemo.cls ClassMethod CreateOne Implementation+4 Class '%Library.FileBinaryStream'
 is deprecated.
ResearchXForms.BasicDemo.cls ClassMethod RoundTripBin Implementation+1 Class '%Library.FileBinaryStream'
 is deprecated.




4 Scanning Mapped Code
By default, the query scans only classes and routines in the default routine database for the current namespace. To include
classes and routines from mapped databases, specify the query argument as 1, by passing that argument when executing
the class query. For example:

Class Member
ClassMethod Check()
{
    set stmt = ##class(%SQL.Statement).%New()
    set status = stmt.%PrepareClassQuery("%SYSTEM.CodeScanner","ScanDocuments")
    if $$$ISERR(status) {quit}
    set rset = stmt.%Execute(1)
    if rset.%SQLCODE<0 {quit}

    while rset.%Next() {
        set Document=rset.%Get("Document")
        set Location=rset.%Get("Location")
        set Message=rset.%Get("Message")
        write !, Document_" "_Location_" "_Message
    }
}




5 See Also
•   %SYSTEM.CodeScanner




2                                                                                          Scanning for Deprecated Code
