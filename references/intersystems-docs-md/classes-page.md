Using the Classes Page
                           Version 2026.1
                            2026-04-20




InterSystems Corporation One Congress Street Boston MA 02114 www.intersystems.com
Using the Classes Page
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
        Using the Classes Page........................................................................................................................... 1
            1 Introduction to the Classes Page ................................................................................................... 1
            2 Compiling Classes ......................................................................................................................... 2
            3 Exporting Classes .......................................................................................................................... 2
            4 Importing Classes .......................................................................................................................... 2
            5 Deleting Classes ............................................................................................................................ 3




Using the Classes Page                                                                                                                                          iii
Using the Classes Page
This page describes how to use the Management Portal tools for viewing and managing classes.




1 Introduction to the Classes Page
The Management Portal includes the Classes page, which allows you to manage classes. On this page, you can:
•    Select Documentation in the row for a class to display documentation for that class in the right pane.
•    Select Compile to compile classes.
•    Select Export to export classes.
•    Select Import to import classes.
•    Select Delete to delete classes.
•    Select Routines to view routines.
•    Select Globals to view globals.

To access this page from the Management Portal home page:
1.   Select System Explorer > Classes.
2.   Select the namespace or database of interest:
     •   In the left pane, select either Namespaces or Databases from the Lookin list.
     •   Select the desired namespace or database from the second drop-down list.

     Selecting a namespace or database updates the page to display its classes.
3.   If you are looking for a particular class and do not initially see its name:
     •   Optionally select System items, Generated items, or Mapped items to include classes of the selected type in the
         search.
     •   Optionally specify a search mask. To do so, enter a value into the Class name field. If you end the string with an
         asterisk “*”, the asterisk is treated as a wildcard, and the page displays each class whose name begins with the
         string before the asterisk.
         After entering a value, press Enter.
     •   Optionally specify a Begin date and an End date to specify the range of dates to search on. The Date column
         specifies when the class was last modified.
     •   Optionally enter a value for Maximum Rows, which determines the maximum number of rows to return.
     •   In the center pane, optionally enter a value for Page size, which controls the number of classes to list on any page.


To display SQL table names, select the SQL table name check box. This includes the link View SQL related globals in the
rows for any classes that have projections to SQL tables.




Using the Classes Page                                                                                                      1
Compiling Classes




2 Compiling Classes
The Compile Classes wizard provides several options for compiling classes.
To access and use this wizard:
1.   Display the Classes page.
2.   Specify the classes to compile. To do so, see steps 2 and 3 in Introduction to the Classes Page. Select their check boxes.
3.   Click the Compile button, which displays the Compile Classes wizard.
4.   In the Compile Classes wizard, specify the Compiler Flags that you would like to use by selecting the corresponding
     check box, or by entering them manually under Flags. By default, Flags is set to cuk.
5.   Select the Run compile in the background check box if you are compiling many or large files.
6.   Click the Compile button. The Compile Classes wizard will display information regarding the status of the compilation.
7.   To dismiss the wizard, click Done.




3 Exporting Classes
The Export Classes wizard enables you to export classes.
To access and use this wizard:
1.   Display the Classes page.
2.   Specify the classes to work with. To do so, see steps 2 and 3 in Introduction to the Classes Page. Select their check
     boxes.
3.   Click the Export button to display the Export Classes wizard.
4.   In the Export Classes wizard, specify the file into which you wish to export the classes. To do this, either enter a file
     name (including its absolute or relative pathname) in the Enter the path and name of the export file field or click Browse
     and navigate to the file.
5.   Select the export file’s character set with the Character set list.
6.   Select the Run export in the background... check box if you are exporting many or large files.
7.   Click Export.
8.   If the file already exists, select OK to overwrite it with a new version.
9.   To dismiss the wizard, click Done.




4 Importing Classes
The Import Classes wizard enables you to import classes.
To access and use this page:
1.   Display the Classes page.



2                                                                                                     Using the Classes Page
                                                                                                                  Deleting Classes


2.   Click the Import button to display the Import Classes wizard.
3.   In the Import Classes wizard, choose to import from a file or a directory by selecting the corresponding radio button
     under Import from a File or a Directory.
4.   Specify the import file or directory. To do this, either enter a file or directory (including its absolute or relative pathname)
     in the Enter the path and name of the import file field or click Browse and navigate to the file or directory.
5.   If importing from a directory, select or clear Include subdirectories.
6.   Select or clear Compile imported items, and enter any Compile Flags.
7.   Select Run import in the background if importing large files.
8.   Click Import. The Import Classes wizard will display information regarding the status of the import.
9.   To dismiss the wizard, click Done.

Note:     This page enables you to import classes that have been exported in XML format. It does not support older formats.




5 Deleting Classes
CAUTION:          A deleted class cannot be restored. There is no undo option.

The Classes page enables you to delete classes. To access and use this page:
1.   Display the Classes page.
2.   Select the classes to work with. To do so, see steps 2 and 3 in Introduction to the Classes Page. Select their check
     boxes.
3.   Click the Delete button.
4.   Click OK to confirm this action.




Using the Classes Page                                                                                                             3
