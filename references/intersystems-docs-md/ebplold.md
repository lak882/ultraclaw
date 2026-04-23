Using the Legacy BPL Editor
                              Version 2026.1
                               2026-04-20




   InterSystems Corporation One Congress Street Boston MA 02114 www.intersystems.com
Using the Legacy BPL Editor
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
        1 Introduction to the Legacy BPL Editor ............................................................................................ 1
            1.1 Accessing the Editor ................................................................................................................... 1
            1.2 Areas of the Page ........................................................................................................................ 1
            1.3 The BPL Diagram ...................................................................................................................... 2
            1.4 See Also ...................................................................................................................................... 3
        2 Creating BPL Business Processes (Legacy UI) ................................................................................ 5
            2.1 Creating a BPL Business Process ............................................................................................... 5
            2.2 Opening a BPL Business Process ............................................................................................... 5
            2.3 Setting General Properties of the BPL Business Process ........................................................... 6
            2.4 Defining the context Object ....................................................................................................... 6
            2.5 Adding an Activity ...................................................................................................................... 7
            2.6 Undoing a Change ...................................................................................................................... 8
            2.7 Saving a BPL .............................................................................................................................. 8
            2.8 Compiling a BPL ........................................................................................................................ 8
            2.9 See Also ...................................................................................................................................... 8
        3 Editing a BPL Diagram (Legacy UI) ................................................................................................ 9
            3.1 Basics ......................................................................................................................................... 9
            3.2 Color Indicators .......................................................................................................................... 9
            3.3 Specifying Diagram Preferences .............................................................................................. 10
            3.4 Adding an Activity .................................................................................................................... 10
                 3.4.1 Adding a Call Activity .................................................................................................... 10
            3.5 Editing Properties of an Activity .............................................................................................. 11
            3.6 Removing an Activity ............................................................................................................... 11
            3.7 Adding a Connection ................................................................................................................ 11
            3.8 Drilling Down and Back ........................................................................................................... 12
            3.9 Adjusting the Layout ................................................................................................................ 12
            3.10 See Also .................................................................................................................................. 13




Using the Legacy BPL Editor                                                                                                                                          iii
1
Introduction to the Legacy BPL Editor
This page introduces the legacy BPL Editor (the Business Process Designer page), which enables you to create BPL business
processes for interoperability productions.

Note:     Starting with 2026.1, the product includes a new BPL Editor. To access this application, click Open in the new
          UI on the existing BPL Editor. See Introduction to the BPL Editor.




1.1 Accessing the Editor
To access this page:
1.   Log in to the Management Portal.
2.   Click Interoperability > Build > Business Processes.

Important:       After a period of inactivity, the Management Portal may log you out and discard any unsaved changes.
                 Inactivity is the time between calls to the InterSystems IRIS server. Not all actions constitute a call to the
                 server. For example, clicking Save constitutes a call to the server, but typing in a text field does not. Con-
                 sequently, if you are editing a business process, but have not clicked Save for longer than Session Timeout
                 threshold, your session will expire and your unsaved changes will be discarded. After a logout, the login
                 page appears or the current page is refreshed. For more information, see Automatic Logout Behavior in
                 the Management Portal.




1.2 Areas of the Page
When you display the BPL Editor, it shows the last BPL you opened in this namespace, if any. This page has the following
areas:
•    The ribbon bar at the top displays options you can use to create and open BPL processes, compile the currently displayed
     BPL, change the zoom display of the diagram, add activities to the diagram, and so on.
•    The left area displays the BPL diagram.
•    The right area displays the following tabs:




Using the Legacy BPL Editor                                                                                                  1
Introduction to the Legacy BPL Editor


    –    General—contains settings for the overall definition of the BPL business process. See Setting General Properties
         of the BPL Business Process.
    –    Context—enables you to define the context object for this BPL business process.

    –    Activity—contains settings for the selected item in the BPL diagram; see Adding Activities to a BPL Diagram.

    –    Preferences—contains settings pertaining to the appearance of the BPL diagram. See Setting BPL Diagram Pref-
         erences.

    You can expand and collapse the right area using the double arrow icons.




1.3 The BPL Diagram
A BPL diagram is the editable, graphical representation of the logic defined by the business process. The following is an
example.




A BPL business process consists of a connected set of activities, shown as different shapes in the diagram. Activities can
use values received by the BPL and make decisions based on them, they call other business components, they can manipulate
data, and they can call custom code. The process of creating a BPL business process consists primarily of defining the
activities it includes and connecting those activities.




2                                                                                            Using the Legacy BPL Editor
                                      See Also




1.4 See Also
•   Creating BPL Business Processes
•   Editing a BPL Diagram




Using the Legacy BPL Editor                 3
2
Creating BPL Business Processes (Legacy
UI)
This page describes at a high level how to use the legacy BPL Editor to create and edit BPL business processes for interop-
erability productions.
For information on performing these tasks with the new UI, see Creating BPL Business Processes.




2.1 Creating a BPL Business Process
To create a BPL business process, do the following in the BPL Editor:
1.   Click New.
     This displays a dialog box.
2.   Specify some or all of the following information:
     •   Package (required)—Enter a package name or click the arrow to select a package in the current namespace.

         Do not use a reserved package name; see Reserved Package Names.
     •   Name (required)—Enter a name for your BPL business process class.

     •   Description—Enter a description for your BPL business process class; this becomes the class description.


3.   Click OK.

The start and end points of the BPL diagram display in the BPL Editor, ready for you to add activities to your BPL business
process.




2.2 Opening a BPL Business Process
To open a BPL business process, do the following in the BPL Editor:
1.   Click Open.




Using the Legacy BPL Editor                                                                                              5
Creating BPL Business Processes (Legacy UI)


     If you are currently viewing a BPL and you have made changes but have not yet saved them, InterSystems IRIS prompts
     you to confirm that you want to proceed (which will discard those changes).
2.   Click the package that contains the BPL.
     Then click the subpackage as needed.
3.   Click the BPL class.
4.   Click OK.




2.3 Setting General Properties of the BPL Business
Process
Each BPL business process has a small set of properties that apply to the process as a whole. To set these properties, do
the following in the BPL Editor
1.   Click the General tab.
2.   Modify the following settings:
     •   Language—Can be Python or ObjectScript.

     •   Layout—Select either Automatic or Manual for the size of the diagram. If you select Manual you can enter a Width
         and Height.
     •   Annotation—Enter text to include in the class description.

     •   Includes—An optional comma-delimited list of include file names, so that you can use macros in your <code>
         segments.
     •   Version—Enter an optional version number of the BPL diagram

     •   Is component—If true, include this process in the component library where it can be called by other processes.


     See <process> for details on these properties.




2.4 Defining the context Object
Each BPL business process has a context object that provides information available for use in the BPL logic. To define this
object, do the following in the BPL Editor:
1.   Click the Context tab.
2.   Modify the following settings:
     •   Request Class—Choose the class of the incoming request for this process.

     •   Response Class—Choose the class of the response returned by this process.

     •   Context Superclass—Use this option to provide custom context properties, in a different way than adding to the
         Context properties list, described next. To use Context Superclass, create a custom subclass of Ens.BP.Context.
         In this subclass, define class properties to use as context properties. Use the name of this class as the value of




6                                                                                               Using the Legacy BPL Editor
                                                                                                              Adding an Activity


         Context Superclass in the business process. Then when you create <assign> actions, for example, you can choose
         these custom properties in addition to the standard properties of the context object.

3.   To add a property, click the plus sign next to Context properties.
     Then enter values in the following fields:
     •   Property Name—Must be a valid identifier.

     •   Choose if the property data is one of the following: Single Value, List Collection, or Array Collection
     •   Property Type—Type of this property including parameters.

         Enter a data type class name in the Type field or click the magnifying glass to browse for a class you want to use
         as a data type.
     •   Default Value (ignored for collections)—Enter an initial expression for a single value data type.

     •   Instantiate—Select this check box for object-valued properties if you want the object to be instantiated when it is
         created.
     •   Description—Enter an optional description of the context property.


4.   Click OK to save your changes or click Cancel to discard them.

To set property parameters such as MINVAL, MAXVAL, MINLEN, MAXLEN, or others, add data type parameters to a
context property when you first add the property, or at any subsequent time, by inserting a comma-separated list of
parameters enclosed in parentheses after the data type class name. That is, rather than simply entering %String or %Integer,
you can enter data types such as:
%String(MAXLEN=256)
%Integer(MINVAL=0,MAXVAL=100)
%String(VALUELIST=",Buy,Sell,Hold")

Once you have defined properties of the context object, you can refer to them anywhere in BPL using ordinary dot syntax
and the property name, as in: context.MyData
For reference details, see the following resources:
•    Typically you choose the property type from types described in Data Types. These include %String, %Integer, %Boolean,
     and so on.
•    System data types have optional parameters. For details, see Parameters. These include the MINLEN and MAXLEN
     parameters that set the minimum and maximum allowed lengths of a %String property. The default maximum %String
     length is 50 characters; you can reset this by setting the MAXLEN for that %String property to another value.

By default, the ruleContext passed to the rule is the business process execution context. If you specify a different object as
a context, there are some restrictions on this object: It must have a property called %Process of type Ens.BusinessProcess;
this is used to pass the business process calling context to the rules engine. You do not need to set the value of this property,
but it must be present. Also, the object must match what is expected by the rule itself. No checking is done to ensure this;
it is up to the developer to set this up correctly.




2.5 Adding an Activity
Each BPL business process consists of a set of connected activities. In general, to add an activity to a BPL business process,
do the following in the BPL Editor:
1.   Click Add Activity in the ribbon bar.



Using the Legacy BPL Editor                                                                                                    7
Creating BPL Business Processes (Legacy UI)


     This adds a new shape to the BPL diagram.
2.   Edit the activity details in the Activity tab on the right.
3.   Use drag and drop options to modify how this activity is connected to others.

For details, see Adding Activities to BPL and Editing a BPL Diagram.




2.6 Undoing a Change
To undo the previous change in the BPL Editor, click the Undo button      .




2.7 Saving a BPL
To save a BPL while in the BPL Editor, do one of the following:
•    Click Save.
•    Click Save As. Then specify a new package, class name, and description and click OK.
•    Click Compile. This option saves the BPL and then compiles it.




2.8 Compiling a BPL
To compile a BPL while in the BPL Editor, click Compile. This option saves the BPL and then compiles it.




2.9 See Also
•    Editing a BPL Diagram




8                                                                                           Using the Legacy BPL Editor
3
Editing a BPL Diagram (Legacy UI)
Each BPL business process consists of a set of connected activities, represented by shapes in the BPL diagram. This page
describes how to make changes in a BPL diagram, within the legacy BPL Editor.
For information on performing these tasks with the new UI, see Editing a BPL Diagram.




3.1 Basics
•   To select an activity, click it. When you do so, its attributes display in the Activity tab, where you can edit their values.
•   To select multiple activities, hold down the Ctrl key while clicking.
•   To clear the selection of a selected activity, click it again.
•   You can connect activities via drag and drop actions.
•   The toolbar provides options for adding activities; cutting, copying, pasting, deleting activities; and undoing changes.
•   The BPL Editor automatically validate activities as you add them to the diagram. If it detects an element with a logical
    error, it displays a red warning on the Activity tab for the element along with the reason for the error.
•   Several kinds of BPL activities are displayed as their own subdiagrams. To see them in detail, it is necessary to drill
    down into them.




3.2 Color Indicators
The BPL Editor provides the following color indicators for shapes in the diagram:
•   Typically the interior color of a BPL diagram shape is white, with a blue outline. If you select the shape, its interior
    color changes to yellow and the outline becoes bolder.
•   If the shape is in error, its outline is red.
•   If the shape is disabled, its interior color is gray, with a gray outline. When you select a disabled shape it shows a
    dotted outline.

Also, when a shape represents a complex activity such as <if> or <switch> that has multiple branches, joins, or other types
of related shapes elsewhere in the BPL diagram, clicking on one of these shapes highlights the related shapes in green with
a purple outline.



Using the Legacy BPL Editor                                                                                                    9
Editing a BPL Diagram (Legacy UI)




3.3 Specifying Diagram Preferences
The Preferences tab contains the following settings that apply to the appearance of the BPL diagram:
•    Gridlines—Select one of the following choices for the appearance of the grid lines on the diagram: None, Light, Medium,
     or Dark.
•    Show annotations—Reveal or hide the text notes that explain each shape. When you reveal annotations, they appear
     to the upper right of each shape that has an <annotation> element in the BPL document.
•    Auto arrange—Cause each new shapes in the diagram to automatically conform to a structured arrangement without

     needing to select     after adding each shape.
     Changing the position of shapes does not change the underlying BPL code.




3.4 Adding an Activity
To add an activity to a BPL diagram, do the following:
1.   Select an option from the Add Activity list.
     This immediately places a new, unconnected activity to the diagram.
2.   While the new activity is still selected, specify values as needed on the Activity tab:
     •   Name—Enter a name for the caption inside the shape.

     •   Disabled—Optionally select this check box to disable the activity; clear it to enable. The default is enabled.

     •   Annotation—Optionally enter text to appear as comments next to the shape in the diagram.


     Other details depend on the type of activity. See the BPL Reference.
3.   Connect this activity to other activities as needed.

Or if this activity should be inserted between two existing activities, do the following:
1.   Select the connector that connects those two activities.
2.   Select an option from the Add Activity list.
     This immediately inserts the new activity between the two other activities, connected to both of them.
3.   While the new activity is still selected, specify values as needed on the Activity tab, as described above.


3.4.1 Adding a Call Activity
A common task in a BPL business process is to add a Call activity. The following information is necessary to properly
create a new <call> to one of the available business processes or business operations in the production:
•    Input
•    Output
•    Name
•    Target



10                                                                                              Using the Legacy BPL Editor
                                                                                               Editing Properties of an Activity


•    Request




3.5 Editing Properties of an Activity
To edit properties of an activity, do the following:
1.   Click the activity.
2.   Specify values as needed on the Activity tab:
     •   Name—Enter a name for the caption inside the shape.

     •   Disabled—Optionally select this check box to disable the activity; clear it to enable. The default is enabled.

     •   Annotation—Optionally enter text to appear as comments next to the shape in the diagram.


     Other details depend on the type of activity. See the BPL Reference.




3.6 Removing an Activity
To remove an activity from a BPL diagram, do the following:
1.   Select the activity.
2.
     Click the Remove       button in the toolbar.




3.7 Adding a Connection
Each activity is displayed with one triangular input point and one output circle. You use these when connecting activities.
To add a connection from one activity to another, do the following:
1.   Click the output circle of one activity.
2.   Drag the cursor to input triangle of the other activity and then release.
     Equivalently, you can click the input triangle of one activity and drag to the output circle of the other activity.
3.   Optionally select the connector, and enter a name for it on the Activity tab.

The tool does not allow you to make an illegal connection.
Once two shapes are connected, the connection is preserved no matter where you drag the respective shapes. You can drag
shapes to any layout position you wish, within the same diagram.




Using the Legacy BPL Editor                                                                                                  11
Editing a BPL Diagram (Legacy UI)




3.8 Drilling Down and Back
Several kinds of BPL activities are displayed as their own subdiagrams. To see them in detail, it is necessary to drill down
into them. Examples include <foreach> and <sequence>. The main BPL diagram shows only a stub, with an indicator that
you need to click for more details.
For example, the following shows a <foreach> loop, as you would see it within the main BPL diagram:




The cyclical arrow icon at the bottom of the shape is a reminder that there are details not shown here. Another example is
<sequence>, which displays a plus sign icon to remind you that there are more details:




In all cases, to drill down, you can do either of the following:
•    Click the icon (circular arrow or plus sign).
•
     Click the activity and then click the Drill Down icon         in the toolbar.

The BPL Editor then displays the full details for that activity, from start to end.

To return to the higher logical level, lick the Drill Up icon       in the toolbar.




3.9 Adjusting the Layout
After you add shapes or create new connections, you can tidy the diagram by clicking the arrange icon       on the tool bar.
For example, if you do not have the auto arrange feature set in your preferences, when you add a shape to a BPL diagram
it looks something like the following figure.




12                                                                                            Using the Legacy BPL Editor
                                                                                                                  See Also


When you click the auto arrange tool      the shapes are aligned as shown in the following figure.




If you want your diagrams to always use this type of structured layout, select the Auto arrange check box on the Preferences
tab.
By default, when you open a BPL diagram for the first time, the auto arrange feature is enabled. This choice may or may
not be appropriate for a particular drawing. You can disable automatic arrangement to ensure that your diagram always
displays with exactly the layout you want by clearing the Auto arrange check box on the Preferences tab. This way, when
the diagram is displayed, it does not take on any layout characteristics except what you have specified.




3.10 See Also
•   Creating BPL Business Processes




Using the Legacy BPL Editor                                                                                              13
