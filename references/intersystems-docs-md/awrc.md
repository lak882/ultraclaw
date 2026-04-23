Installing Code from the WRC
                              Version 2026.1
                               2026-04-20




   InterSystems Corporation One Congress Street Boston MA 02114 www.intersystems.com
Installing Code from the WRC
PDF generated on 2026-04-20
InterSystems Version 2026.1
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
        Installing Code from the WRC.............................................................................................................. 1




Installing Code from the WRC                                                                                                                           iii
Installing Code from the WRC
Execution of certain InterSystems upgrade tools requires that the most recent code be installed. Although the most recent
version of the code is generally included in the latest installation kit, if you are upgrading from or to an older version, the
code included in your installation may not be the most recent code available.
1.   Go to the WRC Distribution page under Components and search for the name of the tool you wish to use.
2.   Determine whether the code included in your installation is up to date, as follows:
     a.   The upgrade tool code version will match the version of your InterSystems IRIS, IRIS for Health, or HealthConnect
          installation. You can find this version number by clicking About in the management portal. Look in the Version
          row of the System Overview table. The version number has three segments. For example, 2025.1.2. The first
          two segments are the main release number, and the third section is the maintenance release number.




     b.   Compare the main release number (the first two segments) to the value in the Version column of the InterSystems
          Components table in the WRC.

     c.   If the two version numbers are the same, compare the third segment (the maintenance release number) of the value
          from the management portal to the value in the Maint column in the WRC table.
     d.   The higher number is the more recent version. For example, if the version in the management portal is 2025.1.1
          and the WRC values are Version: 2025.1 and Maint: 3, the WRC code is more recent.

          Note:    If the version in the management portal matches or is higher than the version in the WRC, you already
                   have the most recent code, and you can skip the download and installation procedures described in this
                   article. Otherwise, proceed with downloading and installation.


3.   Download and unzip the ZIP file. Make a note of the name of the extracted file and the path to where you save it.
     Execute the remaining steps for all relevant systems. For example, for the Production Validator, execute the steps for
     the source system and the target system.
4.   Log in to the IRIS terminal associated with the relevant system, and set the namespace to HSLIB.

     Set $namespace="HSLIB"

5.   Write enable the HSLIB database to prepare for loading the code.

     write ##class(%ZHSLIB.HealthShareMgr).UpdateReadWrite("HSLIB",0)




Installing Code from the WRC                                                                                                  1
6.   Set a string variable to identify the filename and path to the code.

     set file="<filepath>\<extracted_upgrade_tool_file>"

7.   Load Production Validator code.

     do $system.OBJ.Load(file,"ck")

8.   Reset read/write permissions for the HSLIB database.

     write ##class(%ZHSLIB.HealthShareMgr).UpdateReadWrite("HSLIB",1)




2                                                                           Installing Code from the WRC
