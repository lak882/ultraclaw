Using the Globals Page
                           Version 2026.1
                            2026-04-20




InterSystems Corporation One Congress Street Boston MA 02114 www.intersystems.com
Using the Globals Page
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
        Using the Globals Page........................................................................................................................... 1
            1 General Advice .............................................................................................................................. 1
            2 Introduction to the Globals Page ................................................................................................... 1
            3 Viewing Global Data ..................................................................................................................... 2
            4 Editing Globals .............................................................................................................................. 3
            5 Exporting Globals ......................................................................................................................... 3
            6 Importing Globals ......................................................................................................................... 4
            7 Finding Values in Globals ............................................................................................................. 5
                 7.1 Performing Wholesale Replacements ................................................................................. 5
            8 Deleting Globals ............................................................................................................................ 6
            9 See Also ......................................................................................................................................... 6




Using the Globals Page                                                                                                                                               iii
Using the Globals Page
The Management Portal provides tools for viewing, modifying, and working with globals. This topic describes how to use
these tools.
For information on defining global mappings, see Configuring Namespaces.




1 General Advice
As with the ObjectScript commands SET, MERGE, KILL, and others, the tools described here provide direct access to
manipulate globals. If you delete or modify via global access, you bypass all object and SQL integrity checking and there
is no undo option. It is therefore important to be very careful when doing these tasks. (Viewing and exporting do not affect
the database and are safe activities.)

CAUTION:         Globals that are part of an extent are managed by corresponding ObjectScript and SQL code. Any changes
                 made to such a global through direct global access may corrupt the structure of the global (rendering its
                 data inaccessible) or otherwise compromise access to its data through ObjectScript or SQL.
                 To prevent this, you should avoid use the kill command on globals for tasks like dropping all the data in
                 an extent. Instead, you should use API methods such as %KillExtent() or TRUNCATE TABLE, which
                 perform important maintenance, such as resetting associated in-memory counters. However, classes that
                 use a customized storage definition to project data from globals, are fully managed by application code,
                 are exceptions to this rule. In such classes, you should consider setting either READONLY to 1 or MAN-
                 AGEDEXTENT to 0 or both.

When using the tools described in this topic, make sure of the following:
•    Be sure that you know which globals InterSystems IRIS® data platform uses. Not all of these are treated as “system”
     globals — that is, some of them are visible even when you do not select the System check box. Some of these globals
     store code, including your code.
     See Global Variable Names to Avoid.
•    Be sure that you know which globals your application uses.
     Even if your application never performs any direct global access, your application uses globals. Remember that if you
     create persistent classes, their data and any indexes are stored in globals, whose names are based on the class names
     (by default). See Data.




2 Introduction to the Globals Page
The Management Portal includes the Globals page, which allows you to view, and edit globals in different ways. To access
this page from the Management Portal home page:
1.   Select System Explorer > Globals.
2.   Select the namespace or database of interest:
     •   Select either Namespaces or Databases from the Lookin list.



Using the Globals Page                                                                                                    1
Viewing Global Data


     •   Select the desired namespace or database from the displayed list.

     Selecting a namespace or database updates the page to display its globals.
3.   If you are looking for a particular global and do not initially see its name:
     •   Optionally specify a search mask. To do so, enter a value into the Globals field. If you end the string with an
         asterisk “*”, the asterisk is treated as a wildcard, and the page displays each global whose name begins with the
         string before the asterisk.
         After entering a value, press Enter.
     •   Optionally select System items to include all system globals in the search.
     •   Optionally select Show SQL Table Names to include Table and Usage columns in the globals table. If a global is
         used with an SQL table, these columns display the name of that table and its usage, such as whether it is a
         data/master map or a type of index.
     •   Optionally select a value from Page size, which controls the number of globals to list on any page.




3 Viewing Global Data
The View Global Data page lists nodes of the given global. In the table, the first column displays the row number, the next
column lists the nodes, and the right column shows the values. This page initially shows the first hundred nodes in the
global.
To access this page, display the Globals page and select the View link next to the name of a global. Or click the View button.
On this page, you can do the following:
•    Specify a search mask. To do so, edit the value in Global Search Mask as follows:
     –   To display a single node, use a complete global reference. For example: ^Sample.PersonD(9)
     –   To display a subtree, use a partial global reference without the right parenthesis. For example: ^%SYS("JOURNAL"
     –   To display all nodes that match a given subscript, include the desired subscript and leave other subscript fields
         empty. For example: ^IRIS.Msg(,"en")
     –   To display all subtrees that match a given subscript, use a value as in the previous option but also omit the right
         parenthesis. For example: ^IRIS.Msg(,"en"
     –   To display nodes that match a range of subscripts, use subscriptvalue1:subscriptvalue2 in the place of a subscript.
         For example: ^Sample.PersonD(50:60)
         As with the previous option, if you omit the right parenthesis, the system displays the subtrees.

     Then click Display or press Enter.
•    Specify a different number of nodes to display. To do so, enter an integer into Maximum Rows.
•    Repeat a previous search. To do so, select the search mask in the Search History drop-down.
•    Select Allow Edit to make the data editable; see the next topic.

To close this page, click Cancel.




2                                                                                                    Using the Globals Page
                                                                                                               Editing Globals




4 Editing Globals
CAUTION:         Before making any edits, be sure that you know which globals InterSystems IRIS uses and which globals
                 your application uses; see General Advice. There is no undo option. A modified global cannot be restored.

The Edit Global Data page enables you to edit globals. In the table, the first column displays the row number, the next column
lists the nodes, and the right column shows the values (with a blue underline to indicate that the value can be edited). This
page initially shows the first hundred nodes in the global.
To access and use this page:
1.   Display the Globals page.
2.   Select the Edit link next to the name of a global.
3.   Optionally use the Global Search Mask field to refine what is displayed. See Viewing Global Data.
4.   Optionally specify a different number of nodes to display. To do so, enter an integer into Maximum Rows.
5.   If necessary, navigate to the value you want to edit by selecting the subscripts that correspond to it.
6.   Select the value that you want to edit.
     The page then displays two editable fields:
     •   The top field contains the full global reference for the node you are editing. For example:
         ^Sample.PersonD("18")

         You can edit this to refer to a different global node. If you do so, your action affects the newly specified global
         node.
     •   The bottom field contains the current value of this node. For example:

         $lb("",43144,$lb("White","Orange"),$lb("8262 Elm Avenue","Islip","RI",57581),"Rogers,Emilio
         L.",
         $lb("7430 Washington Street","Albany","GA",66833),"650-37-4263","")


     Edit the values as needed.
7.   If you make edits, click Save to save your changes, or click Cancel.

Or, to delete a node:
1.   Optionally select Delete global subnodes during deletion
2.   Click Delete.
3.   Click OK to confirm this action.

Also see Performing Wholesale Replacements.




5 Exporting Globals
CAUTION:         Because of how easy it is to import globals (which is an irreversible change), it is good practice to export
                 only the globals you need to import. Note that if you export all globals, the export includes all the globals
                 that contain code. Be sure that you know which globals InterSystems IRIS uses and which globals your
                 application uses; see General Advice.



Using the Globals Page                                                                                                         3
Importing Globals


The Export Globals page enables you to export globals.
To access and use this page:
1.   Display the Globals page.
2.   Specify the globals to work with. To do so, see steps 2 and 3 in Introduction to the Globals Page.
3.   Click the Export button.
4.   Specify the file into which you wish to export the globals. To do this, either enter a file name (including its absolute
     or relative pathname) in the Enter the path and name of the export on server <hostname> field or click Browse and
     navigate to the file.
5.   Select the export file’s character set with the Character set list.
6.   In the page’s central box:
     •   Choose an Output format
     •   Choose a Record format

7.   Select or clear Check here to run export in the background...
8.   Click Export.
9.   If the file already exists, click OK to overwrite it with a new version.

The export creates a .gof file.




6 Importing Globals
CAUTION:            Before importing any globals, be sure that you know which globals InterSystems IRIS uses and which
                    globals your application uses; see General Advice. There is no undo option. After you import a global into
                    an existing global (thus merging the data), there is no way to restore the global to its previous state.

The Import Globals page enables you to import globals. To access and use this page:
1.   Display the Globals page.
2.   Click the Import button.
3.   Specify the import file. To do this, either enter a file (including its absolute or relative pathname) in the Enter the path
     and name of the import file field or click Browse and navigate to the file.

4.   Select the import file’s character set with the Character set list.
5.   Select Next.
6.   Choose the globals to import using the check boxes in the table.
7.   Optionally select Run import in the background. If you select this, the task is run in the background.
8.   Click Import.




4                                                                                                      Using the Globals Page
                                                                                                    Finding Values in Globals




7 Finding Values in Globals
The Find Global String page enables you to find a given string in the subscripts or in the values of selected globals.
To access and use this page:
1.   Display the Globals page.
2.   Select the globals to work with. To do so, see steps 2 and 3 in Introduction to the Globals Page.
3.   Click the Find button.
4.   For Find What, enter the string to search for.
5.   Optionally clear Match Case. By default, the search is case-sensitive.
6.   Click either Find First or Find All.
     The page then displays either the first node or all nodes whose subscripts or values contain the given string, within the
     selected globals. The table shows the node subscripts on the left and the corresponding values on the right.
7.   If you used Find First, click Find Next to see the next node, as needed.
8.   When you are done, click Close Window.


7.1 Performing Wholesale Replacements
CAUTION:         Before making any edits, be sure that you know which globals InterSystems IRIS uses and which globals
                 your application uses; see “ General Advice.” This option changes the data permanently. It is not recom-
                 mended for use in production systems.

For development purposes, the Find Global String page also provides an option to make wholesale changes to values in
global nodes. To use this option:
1.   Display the Globals page.
2.   Select the globals to work with. To do so, see steps 2 and 3 in Introduction to the Globals Page.
3.   Click the Replace button.
4.   Use this page to find values as described in the previous section.
5.   Specify a value for Replace With.
6.   Click Replace All.
7.   Click OK to confirm this action.
     The page then displays a preview of the change.
8.   If the results are acceptable, click Save.
9.   Click OK to confirm this action.




Using the Globals Page                                                                                                      5
Deleting Globals




8 Deleting Globals
CAUTION:         Before deleting any globals, be sure that you know which globals InterSystems IRIS uses and which
                 globals your application uses; see General Advice. There is no undo option. A deleted global cannot be
                 restored.

The Delete Globals page enables you to delete globals. To access and use this page:
1.   Display the Globals page.
2.   Select the globals to work with. To do so, see steps 2 and 3 in Introduction to the Globals Page.
3.   Click the Delete button.
4.   Click OK to confirm this action.




9 See Also
•    Introduction to Globals
•    Using the ^%GSIZE Routine
•    Globals (APIs)
•    Configuring Namespaces (has information on defining global mappings)




6                                                                                                  Using the Globals Page
