      Using the Analyzer
                           Version 2026.1
                            2026-04-20




InterSystems Corporation One Congress Street Boston MA 02114 www.intersystems.com
Using the Analyzer
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
        1 Introduction to the Analyzer ............................................................................................................. 1
            1.1 Introduction ................................................................................................................................ 1
            1.2 Accessing the Analyzer .............................................................................................................. 2
                 1.2.1 Accessing the Mini Analyzer ........................................................................................... 2
            1.3 Orientation to the Analyzer and Mini Analyzer ......................................................................... 2
                 1.3.1 Model Contents Pane ....................................................................................................... 3
                 1.3.2 Pivot Builder Area ............................................................................................................ 4
                 1.3.3 Pivot Preview Area ........................................................................................................... 4
                 1.3.4 Mini Analyzer Differences ............................................................................................... 4
            1.4 Displaying a Pivot Table ............................................................................................................. 5
            1.5 Exiting the Analyzer or Mini Analyzer ...................................................................................... 5
            1.6 Location of Pivot Table Definitions ........................................................................................... 5
            1.7 Accessing the BI Samples .......................................................................................................... 5
        2 Creating Pivot Tables ......................................................................................................................... 7
            2.1 Introduction to the Autosave Feature ......................................................................................... 7
            2.2 Selecting a Subject Area ............................................................................................................. 7
            2.3 Getting Familiar with a Subject Area ......................................................................................... 7
                 2.3.1 Measures .......................................................................................................................... 8
                 2.3.2 Dimensions ....................................................................................................................... 9
                 2.3.3 Pivot Variables ................................................................................................................ 11
                 2.3.4 Plug-ins .......................................................................................................................... 11
                 2.3.5 Named Sets .................................................................................................................... 12
                 2.3.6 Named Filters ................................................................................................................. 12
                 2.3.7 Calculated Members ...................................................................................................... 12
                 2.3.8 Pivot Tables .................................................................................................................... 13
                 2.3.9 Quality Measures ........................................................................................................... 13
                 2.3.10 Detail Listings .............................................................................................................. 13
            2.4 Creating a Pivot Table .............................................................................................................. 14
            2.5 Specifying the Rows in a Pivot Table ....................................................................................... 15
                 2.5.1 Items That Can Be Used in the Rows Box ..................................................................... 15
                 2.5.2 Specifying the Rows ...................................................................................................... 17
            2.6 Specifying the Columns in a Pivot Table ................................................................................. 18
            2.7 Displaying Measures in a Pivot Table ...................................................................................... 19
                 2.7.1 Pivot Tables with One Measure ...................................................................................... 20
                 2.7.2 Pivot Tables with Multiple Measures ............................................................................. 20
                 2.7.3 Controlling the Display of the Measure Headings ......................................................... 22
            2.8 Displaying Properties in a Pivot Table ..................................................................................... 22
                 2.8.1 Displaying Both Properties and Measures ..................................................................... 23
            2.9 Transposing a Pivot Table ......................................................................................................... 23
            2.10 Changing the Order of Items .................................................................................................. 24
            2.11 Copying and Pasting Items ..................................................................................................... 24
            2.12 Adding a Summary Row or Column ...................................................................................... 24
                 2.12.1 Adding a Summary Row or Column as a Pivot Option ............................................... 24
                 2.12.2 Adding the All Member as a Summary Row or Column ............................................. 25
                 2.12.3 Adding a Summary Row or Column as a Custom Aggregation ................................... 26
            2.13 Applying 80/20 Suppression .................................................................................................. 28
            2.14 Clearing the Autosave State of a Pivot Table ......................................................................... 28


Using the Analyzer                                                                                                                                                iii
           2.15 Saving a Pivot Table ............................................................................................................... 28
     3 Filtering Pivot Tables ........................................................................................................................ 31
          3.1 About Filters ............................................................................................................................. 31
          3.2 Dragging and Dropping Filter Items ........................................................................................ 32
          3.3 Creating and Using a Drop-Down Menu ................................................................................. 32
          3.4 Adding Advanced Filters .......................................................................................................... 34
          3.5 Filtering the Base Records by Measure Value .......................................................................... 36
          3.6 Defining Named Filters ............................................................................................................ 38
          3.7 Redefining a Named Filter ....................................................................................................... 39
          3.8 Deleting a Named Filter ........................................................................................................... 39
          3.9 Using Named Filters ................................................................................................................. 39
          3.10 Disabling or Removing Filters ............................................................................................... 39
          3.11 How Business Intelligence Combines Filters ......................................................................... 40
          3.12 Finding the Key for a Member ............................................................................................... 41
     4 Defining Calculated Elements ......................................................................................................... 43
         4.1 Overview .................................................................................................................................. 43
         4.2 Defining a Calculated Measure ................................................................................................ 43
             4.2.1 Measure Expressions ...................................................................................................... 45
             4.2.2 Solve Order .................................................................................................................... 46
         4.3 Defining a Calculated Member That Is Not a Measure ............................................................ 46
         4.4 Redefining a Calculated Member ............................................................................................. 48
         4.5 Deleting a Calculated Member ................................................................................................. 48
     5 Defining and Using Pivot Variables ................................................................................................. 49
         5.1 Overview .................................................................................................................................. 49
         5.2 Defining a Pivot Variable .......................................................................................................... 49
         5.3 Defining and Using an Expression Pivot Variable ................................................................... 51
              5.3.1 Defining an Expression Pivot Variable ........................................................................... 51
              5.3.2 Values for Expression Pivot Variables ............................................................................ 52
              5.3.3 Using an Expression Pivot Variable ............................................................................... 52
              5.3.4 Example ......................................................................................................................... 52
         5.4 Literal Pivot Variables .............................................................................................................. 54
              5.4.1 Defining a Literal Pivot Variable .................................................................................... 54
              5.4.2 Values for Literal Pivot Variables ................................................................................... 54
              5.4.3 Using a Literal Pivot Variable ........................................................................................ 54
              5.4.4 Example ......................................................................................................................... 54
         5.5 Redefining a Pivot Variable ...................................................................................................... 56
         5.6 Deleting a Pivot Variable .......................................................................................................... 56
     6 Customizing Pivot Tables ................................................................................................................. 57
         6.1 Specifying Pivot Options .......................................................................................................... 57
         6.2 Customizing Pivot Table Items ................................................................................................. 59
         6.3 Displaying a Constant Row or Column .................................................................................... 60
         6.4 Specifying a Spacer Row or Column ....................................................................................... 61
         6.5 Displaying an Different Set for Rows or Columns .................................................................. 62
         6.6 Specifying New Captions ......................................................................................................... 62
         6.7 Specifying a Format String ....................................................................................................... 62
              6.7.1 Format String Field ........................................................................................................ 63
              6.7.2 Color Piece ..................................................................................................................... 64
         6.8 Specifying Cell and Header Styles ........................................................................................... 64
         6.9 Sorting and Filtering Members ................................................................................................ 65



iv                                                                                                                                           Using the Analyzer
              6.10 Specifying Alternative Aggregation Methods for a Measure ................................................. 66
              6.11 Customizing Double-Click Drilldown ................................................................................... 66
              6.12 Applying Conditional Formatting .......................................................................................... 67
                  6.12.1 Applying an Overall Color ........................................................................................... 69
                  6.12.2 Adding a Rule ............................................................................................................... 69
              6.13 Specifying the Print Settings .................................................................................................. 70
              6.14 Specifying the MDX Query Manually ................................................................................... 71
                  6.14.1 Modifying Details of the 80/20 Suppression Option ................................................... 71
        7 Working with Pivot Tables ............................................................................................................... 73
           7.1 Opening a Saved Pivot Table .................................................................................................... 73
           7.2 Disabling and Enabling Auto-Execution .................................................................................. 73
           7.3 Canceling a Running Query ..................................................................................................... 74
           7.4 Exporting Data to Microsoft Excel or CSV file ....................................................................... 74
           7.5 Printing a Pivot Table ............................................................................................................... 75
               7.5.1 Requirements for Printing .............................................................................................. 75
           7.6 Sending Email .......................................................................................................................... 75
           7.7 Displaying the Pivot Table as a Chart ...................................................................................... 76
           7.8 Deleting a Pivot Table .............................................................................................................. 78
        8 Performing Ad Hoc Analysis ............................................................................................................ 81
            8.1 Displaying a Detail Listing ...................................................................................................... 81
                 8.1.1 Displaying the Default Detail Listing ............................................................................ 81
                 8.1.2 Displaying a Different Detail Listing ............................................................................. 82
                 8.1.3 Creating a Custom Listing ............................................................................................. 82
                 8.1.4 Sorting a Listing ............................................................................................................. 83
                 8.1.5 Exiting the Listing .......................................................................................................... 84
            8.2 Drilldown via Double-Click ..................................................................................................... 84
                 8.2.1 Drilldown in a Hierarchy ............................................................................................... 84
                 8.2.2 Custom Double-Click Drilldown ................................................................................... 84
                 8.2.3 Saving the Drilldown ..................................................................................................... 85
                 8.2.4 Clearing the Drilldown ................................................................................................... 85
            8.3 Performing Arbitrary Drilldown ............................................................................................... 86
            8.4 Introduction to the Pivot Analysis Window .............................................................................. 86
        Appendix A: Configuring InterSystems IRIS for PDF Output ....................................................... 87
           A.1 Using the Built-in PDF Rendering Engine .............................................................................. 87
           A.2 Using Other Rendering Engines .............................................................................................. 88




Using the Analyzer                                                                                                                                           v
1
Introduction to the Analyzer
This page introduces the InterSystems IRIS® data platform Business Intelligence Analyzer.
You can access the Analyzer from the InterSystems launcher or from the InterSystems User Portal.




1.1 Introduction
The Analyzer enables you to create pivot tables, which display aggregated data. Each pivot table is based upon a subject
area or a cube. (In the Analyzer, the terms subject area and cube are equivalent to each other; this book uses the term subject
area.) When you access the Analyzer, you must choose the subject area to work with. The Analyzer then displays the elements
defined in that subject area, which you drag and drop to create pivot tables.
Pivot tables are central to InterSystems Business Intelligence; they select and aggregate data. The following figure shows
an example pivot table that shows the number of patients and the average allergy count per patient, grouped by age and
gender.




A level is used to group the source data. A level has members. Each member, in turn, corresponds to a specific set of records
in the source data. For example, the Age Group level has the members 0-29, 30-59, and 60+. The Gender level has
the members Female and Male.
A measure is a value displayed in the body of the pivot table; it is based on values in the source data. For a given context,
a measure aggregates the values for all applicable source records and represents them with a single value. For example, the
measure Patient Count is the number of patients, and the measure Avg Allergy Count is the average number of
allergies per patient.



Using the Analyzer                                                                                                           1
Introduction to the Analyzer


The preceding example shows a preview of a pivot table within the Analyzer, which provides a large set of tools for modi-
fying, exporting, formatting, and so on.




1.2 Accessing the Analyzer
To access the Analyzer:
1.   On your BI instance, log in to the management portal as a user with administrative privileges and ensure you are in
     your desired namespace.
2.   Navigate to Analytics > Analyzer.
     If you see the message Select a Subject Area to Display, do the following:
     a.
          Click the Change button        or click the Select Subject Area link.
     b.   Click the name of the subject area.
     c.   Click OK.



1.2.1 Accessing the Mini Analyzer
To access the Mini Analyzer, you must first display a suitable dashboard. Not all dashboards provide access to the Mini
Analyzer.


If a dashboard displays the Mini Analyzer button        in a widget, click it; the system then opens the current pivot table
in the Mini Analyzer.
The Mini Analyzer includes only the options that let you make local changes to the pivot table as displayed in this widget.
The changes do not affect other widgets, other dashboards, or other users.




1.3 Orientation to the Analyzer and Mini Analyzer
This section provides an orientation to the Analyzer and Mini Analyzer. First, consider the upper part of the Analyzer page
(which is not included in the Mini Analyzer):




The key options here are as follows:
•    Menu — This drop-down menu provides options to open and save pivot tables.

•    Home — This link accesses the User Portal.

•    Analytics — This link accesses other Analytics tools.

•    Analyzer — This link redisplays the Analyzer. This is useful if there have been changes to the definition of the subject
     area.




2                                                                                                        Using the Analyzer
                                                                              Orientation to the Analyzer and Mini Analyzer


•   Namespace — The displayed namespace name is a link that lets you switch to another InterSystems IRIS namespace.

•   View — These buttons switch the pivot table display to a chart format or to a table-and-chart format.

•   New — This button lets you create a new pivot table.

•   Open, Save, and Save As — These buttons let you open and save pivot tables.

•   Delete — This button lets you delete the current pivot table.

•   Auto-execute — This check box lets you control whether the system automatically executes the pivot table.

•   Preview Mode — This check box enables Preview Mode. If Preview Mode is enabled, any sets involved in a CROSSJOIN
    are truncated using the HEAD function. If truncation occurs, a preview pivot table is displayed in the Analyzer. You
    can use the Show All button to display full results without affecting the Preview Mode setting.

    Note:     The Analyzer automatically enables Preview Mode for a pivot table which involves a resource-intensive
              query. This avoids the need to recalculate complete results for the query every time you make an edit to the
              pivot table.


The upper left corner displays the name of the currently selected subject area (in this case, DemoMDX) or the pivot table
that you currently editing, if any.
The rest of the page is visible in both the Analyzer and the Mini Analyzer. The following subsections discuss the Model
Contents pane, the Pivot Builder area, and the Pivot Preview area. The final subsection discusses how the Mini Analyzer
is different from the full Analyzer.


1.3.1 Model Contents Pane
Both the Analyzer and the Mini Analyzer include the Model Contents pane on the left. This area lists the contents of the
subject area that you are currently viewing:




See Getting Familiar with a Subject Area for more detail.

Tip:    During development, you may find it necessary to reload the model if you have made changes in the Architect or

        an IDE. To reload the model, click the Refresh button       in this area. Note that this does not rerun the pivot table;
        it affects only the model as shown in this area.




Using the Analyzer                                                                                                            3
Introduction to the Analyzer


You can resize this area. To do so, drag the vertical divider on the right edge of this area.


1.3.2 Pivot Builder Area
To the right of the Model Contents pane, both the Analyzer and the Mini Analyzer include the Pivot Builder area, where
you define a pivot table:




You can vertically resize this area. To do so, drag the horizontal divider on the bottom edge of this area. You can also
horizontally resize each of the boxes; to do so, drag the dividers between boxes.


1.3.3 Pivot Preview Area
Both the Analyzer and the Mini Analyzer include the Pivot Preview area, which displays a preview of the actual pivot table:




The bottom area looks like this:




Cells displays the number of cells currently selected (or the total number of cells on the page if there is no selection). Total
displays the total value of all the selected cells (or of all the cells on the page if there is no selection).
If there is too much data to display on the screen, the lower right corner displays buttons for paging through the results.
You can resize this area. To do so, drag the horizontal divider on the top edge of this area.


1.3.4 Mini Analyzer Differences
The Mini Analyzer is similar to the full Analyzer but has two key differences:
•   The Mini Analyzer does not provide options for creating new pivot tables, only for changing the currently displayed
    pivot table.
•   The changes are visible only to yourself. Other users are unaffected.

For information on accessing the Mini Analyzer, see the previous topic.




4                                                                                                                Using the Analyzer
                                                                                                      Displaying a Pivot Table




1.4 Displaying a Pivot Table
To display an existing pivot table, do either of the following:
•   Click Open, expand folders as needed, select a pivot table, and click OK.
•   Select Pivots in the Model Contents area. Then expand folders as needed and select a pivot table.

The system immediately runs the query defined by the pivot table and then displays the results unless the Auto-execute

option is off. In this case, click the Refresh button   in the Pivot Builder area. The system then runs the query and displays
the table.




1.5 Exiting the Analyzer or Mini Analyzer
To exit the Analyzer and return to the User Portal, click Home. Any unsaved changes are discarded.
To exit the Mini Analyzer and return to the dashboard from which you started, click either OK or Cancel. The OK option
saves your changes, and the Cancel option discards them. Or click Reset to remove any changes created in the Mini Analyzer,
and then click OK.




1.6 Location of Pivot Table Definitions
When you create a pivot table in the Analyzer, its definition is available within your IDE as a generated .dfi file. If you are
using Visual Studio Code, you can access these pivot table definitions in the following ways:
•   Client-side editing: when a namespace is opened in the ObjectScript Explorer, view the .dfi files in the Other directory.
•   Server-side editing: modify your workspace filters so that they show generated files and include .dfi files.

A pivot table definition is not a class definition but can be copied and pasted into a special container class if needed; this
container class can contain multiple pivot tables and other items. For details, see Packaging Business Intelligence Elements
into Classes.




1.7 Accessing the BI Samples
Most of the samples shown in the BI documentation are part of the Samples-BI sample (https://github.com/intersystems/Sam-
ples-BI) or the Samples-Aviation sample (https://github.com/intersystems/Samples-Aviation).
InterSystems recommends that you create a dedicated namespace called SAMPLES (for example) and load samples into
that namespace. For the general process, see Downloading Samples for Use with InterSystems IRIS.




Using the Analyzer                                                                                                           5
2
Creating Pivot Tables
This page presents basic information on creating pivot tables in Business Intelligence.
Also see Accessing the BI Samples.




2.1 Introduction to the Autosave Feature
InterSystems IRIS® data platform Business Intelligence provides an optional autosave feature, which can automatically
save the state of the Analyzer for each user, for each pivot table. If the autosave feature is enabled for the Analyzer:
•    When you access the Analyzer, the system displays that user interface as you last saw it.
•    When you display a pivot table in the Analyzer, the system displays that pivot table as you last saw it.

For information on this option, see Specifying Basic Settings. Note that there is a separate autosave feature for the User
Portal.




2.2 Selecting a Subject Area
A subject area provides the elements that you use as the basis of any pivot table. To select the subject area to use:
1.
     Click the Change button         or click the Select Subject Area link.
2.   Click the name of the subject area.
3.   Click OK.




2.3 Getting Familiar with a Subject Area
The Model Contents area lists the contents of the subject area that you are currently viewing. For example, this area might
look like this initially:




Using the Analyzer                                                                                                           7
Creating Pivot Tables




If you have not worked with the current subject area before, it is useful to examine its contents. First, use the drop-down
list to select the kind of item to display in this area. Select one of the following:
•   Dimensions — Select this to display the basic model defined in this subject area. In this case, the Model Viewer can
    display the following sections:
    –    Measures
    –    Dimensions
    –    Pivot Variables
    –    Plug-ins
    –    Named Sets
    –    Named Filters
    –    Calculated Members

•   Pivots — Select this to display any pivot tables defined in this subject area.

•   Quality Measures — Select this to display any quality measures available in this subject area.

•   Detail Listings — Select this to display any detail listings defined in this subject area.


The purpose of the Model Content area is to enable you to create pivot tables. To do this, drag and drop items into the Pivot
Builder area on the right, as described in the next section.

Tip:    For most items, if you hover the cursor over the name of an item in the Model Content area, the system displays a
        tooltip that shows the description of the item, if any.


2.3.1 Measures
To display a list of measures, select Dimensions from the drop-down list in the Model Contents area. Then expand the
Measures folder. This folder lists all measures in the subject area. For example:




8                                                                                                        Using the Analyzer
                                                                                       Getting Familiar with a Subject Area




You can have two types of measures, indicated by icons as follows:

          Standard measures

          Calculated measures, which are defined in terms of other measures




2.3.2 Dimensions
To display a list of dimensions, select Dimensions from the drop-down list in the Model Contents area. Then expand the
Dimensions folder. This folder lists the dimensions and the levels, members, and properties that they contain; it might also
list related subject areas, with their dimensions, levels, and so on.
Click the triangle next to any dimension name to expand it. A dimension contains at least one level and may also include
a special member known as the All member. In the following example, the AgeD dimension includes an All member named
All Patients, as well as the levels Age Group, Age Bucket, and Age.




2.3.2.1 Hierarchies
Each dimension also includes at least one hierarchy, which is the actual container for levels. The following shows an
example (a modified version of the Patients subject area), with a hierarchy named H1.




Using the Analyzer                                                                                                        9
Creating Pivot Tables




`
By default, hierarchy names are not shown unless a dimension contains multiple hierarchies. Alternatively, a dimension
can be defined so that its hierarchy names are always or never shown.
In the Patients subject area, each dimension contains only one hierarchy, so the hierarchy names are not shown. Hierarchies
are purely informational; you cannot drag and drop them as you can with the other items in the Model Contents pane.

2.3.2.2 Level Members and Properties
If you expand a level, the list displays the members of that level. For example:




If a level also includes properties, this area shows the property names with a different icon. For example, the City level
includes the Population and Principal Export properties:




Variations for Data Levels with Many Members
If a data level contains more than 500 members but fewer than 10,000 members, this area displays any property names,
followed by subfolders that contain the members in groups of 100. For example:




10                                                                                                      Using the Analyzer
                                                                                       Getting Familiar with a Subject Area




In this case, the system does not access the member names until you expand one of these subfolders. Thus it is possible to
see and use the properties without waiting for the system to access all the member names.
If a level contains 10,000 members or more, this area displays only the property names, if any, of the level.
The preceding discussion applies only to data levels. In contrast, time levels are always displayed in the same way.

2.3.2.3 Related Subject Areas
The Dimensions folder might also list related subject areas, which it shows in bold italics. If you expand a related subject
area, you can access the dimensions, levels, and possibly the hierarchies of the other subject area, as follows:




2.3.3 Pivot Variables
To display a list of pivot variables, select Dimensions from the drop-down list in the Model Contents area. Then expand
the Pivot Variables folder. This folder (if included) lists any pivot variables in the subject area. For example:




Unlike most other elements in the Dimensions section, pivot variables are defined in the Analyzer; see Defining and Using
Pivot Variables.


2.3.4 Plug-ins
To display a list of plug-ins, select Dimensions from the drop-down list in the Model Contents area. Then expand the Plug-
ins folder. This folder (if included) lists any plugins in the subject area. For example:




Using the Analyzer                                                                                                        11
Creating Pivot Tables




A plug-in contains one or more properties, each of which computes a value. This particular plug-in contains two properties.
Plug-in properties can be used in the same way as measures.


2.3.5 Named Sets
To display a list of named sets, select Dimensions from the drop-down list in the Model Contents area. Then expand the
Named Sets folder. This folder (if included) lists any named sets in the subject area. For example:




A set contains one or more items; typically each item is a member of a level defined elsewhere.


2.3.6 Named Filters
To display a list of named filters, select Dimensions from the drop-down list in the Model Contents area. Then expand the
Named Filters folder. This folder (if included) lists any named filters in the subject area. For example:




Unlike most other elements in the Dimensions section, named filters are defined in the Analyzer; see Defining Named Filters.


2.3.7 Calculated Members
At the bottom of the Dimensions section, the Model Contents pane shows any special dimensions that contain calculated
members. These special dimensions include only members, not hierarchies or levels. For example:




Calculated members are typically combinations of other members. For example, the Primary Colors member is a
combination of the Red, Yellow, and Blue members of the Favorite Color level.
Other dimensions in your model might also include calculated members. If so, the member is displayed in that dimension
with a different icon than other members. For example, if we redefined the two calculated members to move them to the
ColorD dimension, we would see the following for that dimension:




12                                                                                                       Using the Analyzer
                                                                                         Getting Familiar with a Subject Area




Unlike most other elements in the Dimensions section, calculated members can be defined in the Analyzer; see Defining
Calculated Elements.


2.3.8 Pivot Tables
To display a list of pivot tables, select Pivots from the drop-down list in the Model Contents area. Then expand the Pivots
folder. This folder (if included) lists any pivot tables defined in the subject area. For example:




To use this area, expand folders and needed and click a pivot table name. The Pivot Preview area then displays that pivot
table.


2.3.9 Quality Measures
To display a list of quality measures, select Quality Measures from the drop-down list in the Model Contents area. Then
expand the Quality Measures folder. This folder (if included) lists any quality measures in the subject area. For example:




Quality measures can be used in the same way as measures.


2.3.10 Detail Listings
To display a list of detail listings, select Detail Listings from the drop-down list in the Model Contents area. This area then
lists any detail listings defined in the subject area. For example:




Using the Analyzer                                                                                                          13
Creating Pivot Tables


For information on using this area, see Displaying a Detail Listing.




2.4 Creating a Pivot Table
To create a pivot table:
1.   Click New.
2.   In the Model Contents pane, select either Dimensions or Quality Measures.
3.   Drag and drop items from the Model Contents pane to the Pivot Builder area, as described in the rest of this page.
     For example:
     a.   Expand DiagD in the Model Contents pane.
     b.   Drag and drop Diagnoses to Rows.
          Or double-click Diagnoses.
          Or click Diagnoses and then click the plus sign in the header of the Rows box.
     c.   Drag and drop Patient Count to Measures.
          Or double-click this measure.
          Or click Patient Count and then click the plus sign in the header of the Measures box.
     d.   Drag and drop Avg Allergy Count to Measures.
     e.   Expand AgeD in the Model Contents pane.
     f.   Drag and drop All Patients to Rows, below Diagnoses.

4.   Repeat steps 2 and 3 as necessary.
     Each time you make a change, the Analyzer reruns the pivot table and shows the results in the Pivot Preview area. For
     the preceding steps, the final result might be as follows (depending on the values in your data):




5.   Click Save.
     The system displays a dialog box where you specify the pivot table name.
6.   For Pivot Name, specify the name of the pivot table.
     Also see Preparing for Folder Item Localization.


14                                                                                                     Using the Analyzer
                                                                                         Specifying the Rows in a Pivot Table


     Note that this complete string is used (along with Folder) as the logical name of the pivot table; the system displays
     this logical name when you use the Save As option, for example.
7.   Optionally specify other values as follows:
     •   Folder — Type a folder name or select an existing folder.

         Also see Preparing for Folder Item Localization.
         Note that if you specify a folder name that starts with a single dollar sign, the pivot table definition is accessible
         only in your IDE.
     •   Public — Specifies whether this pivot table is displayed in the User Portal main area.

         Important:       This option does not control access to the pivot table. Access is controlled instead by the Pivot
                          Owner and Access Resource options, discussed later in this list.


         Note that even if the pivot table is not marked as public, you can access it in the Analyzer via Open. Also, you
         can find it in the User Portal by using the Find option. See Introduction to the User Portal.
     •   Locked — Select this check box to temporarily prevent changes to this pivot table. If you select this option, you
         must clear the Locked check box before any changes can be made to it.
     •   Pivot Owner — Optionally specifies the InterSystems IRIS® data platform user who owns this pivot table. If a
         pivot table has an owner, then only the owner can specify the Access Resource value for the pivot table; see the
         next item.
     •   Access Resource — Optionally specifies the resource that is used to control access to this pivot table. If you
         specify this, also specify Pivot Owner.
         See Visibility of Folders and Folder Items.
     •   Description — Type a description for this pivot table.

     •   Keywords — Type keywords to categorize this pivot table, one keyword (or phrase) per line.

         These keywords are displayed in the User Portal in List View.
     •   Category — Specify the category to which this item belongs.

         Categories control how the items are grouped in the User Portal in Covers View.

8.   Click OK.




2.5 Specifying the Rows in a Pivot Table
To specify the rows of a pivot table, you drag and drop items of various types from the Model Contents pane into different
areas of the Rows box. This section discusses, with samples, the items that can be used as rows, and provides details of
how to specify the rows.


2.5.1 Items That Can Be Used in the Rows Box
You can use any combination of the following items in the Rows box:
•    Levels. This is the most common scenario. When you drag and drop a level to Rows, the query creates a set of all the
     members of that level, and uses those members for rows. For example:




Using the Analyzer                                                                                                           15
Creating Pivot Tables


      Rows                                              Pivot Table
      Allergies level




•    Members, including calculated members. You can drag and drop individual members to Rows. For example:

      Rows                                                        Pivot Table
      10 to 19 member of Age Bucket level
      Green member of Favorite Color level

      asthma member of Allergies level




     Important:      To drag and drop a member, you must click the member name rather than the icon to its left.

     Note that you can hide the row caption; see Specifying Pivot Options. This option is especially useful when you drag
     and drop individual members, because the name of the first member is also used as the caption for the rows, and this
     is not usually a suitable caption.
•    Dimensions, including calculated dimensions. If you drag and drop a dimension to Rows, the query uses all members
     of the first level of the first hierarchy of that dimension. For example:

      Rows                                               Pivot Table
      AgeD dimension




•    Named sets. If you drag and drop a named set to Rows, the query uses each item in that set as a separate row. For
     example:

      Rows                                               Pivot Table
      Sample Set 2




16                                                                                                     Using the Analyzer
                                                                                      Specifying the Rows in a Pivot Table


•   Measures. If you drag and drop a measure to Rows, the system uses that measure as a row. For example:

      Rows                                               Pivot Table
      Avg Age measure
      Avg Allergy Count measure

      Avg Test Score measure




    If there is only one column (as in the case shown here), the data shown for the measure is the aggregate value for that
    measure across all records (or across all included records, if the pivot table is filtered).
    If the pivot table includes multiple columns corresponding to members, then the data in any column is the value for
    that measure for that member.
    If the pivot table includes columns that correspond to measures, the column definition takes precedence and the value
    shown is determined by the measure used in the column.
    Note that you can hide the row caption; see Specifying Pivot Options. This option is especially useful when you drag
    and drop measures to Rows, because the name of the first measure is also used as the caption for the rows, and this is
    not usually a suitable caption.
•   Level properties. See Displaying Properties in a Pivot Table.
•   Pivot variables. See Defining and Using Expression Pivot Variables.
•   Plugins. For example:

      Rows                                               Pivot Table
      PatientCount plug-in property
      HighScoreCount plug-in property




•   Quality measures.

You can also double-click a level, dimension, member, or named set in the Model Contents pane. If you do, the system
removes any items currently in Rows and replaces them with what you double-clicked.
If hierarchies are displayed in the Model Contents pane, they are for informational purposes only; you cannot drag and
drop them.


2.5.2 Specifying the Rows
To specify the rows in the pivot table, drag and drop items from the Model Contents pane to the Drop row here label in the
Rows box. When you do so, the Rows box looks like this:




Now there are three places into which you can drag and drop additional items:


Using the Analyzer                                                                                                       17
Creating Pivot Tables


•    If you drag and drop onto the bold item label (Age Group in this case), the Analyzer replaces the existing item with
     the new one.
•    If you drag and drop onto Drop row here, the Analyzer adds additional rows to the table. For example:

        Rows                                               Pivot Table




     Note that you can hide the row caption; see Specifying Pivot Options.
•
     If you drag and drop onto the Add Breakout button         after the bold item label, the Analyzer subdivides the existing
     rows. For example:

        Rows                                               Pivot Table




     Notice that now there are two labels called Drop row here. The non-indented one affects the outermost grouping. The
     indented one affects the inner grouping.
     When you nest levels this way, the system initially returns only the first 2,000 combinations of the levels. If there are
     more than 2,000 rows, the system displays the Show All button at the bottom of the pivot preview area. If you click
     this button, the system returns all the combinations, and you can page through them.

To remove an item from the rows, click the X button to the right of its label in the Rows box.

For information on the Advanced Options button         , see Customizing Pivot Table Items.

Note:     If you use calculated members for rows, they are always shown after the other members.




2.6 Specifying the Columns in a Pivot Table
The columns of a pivot table are controlled by Measures and Columns:




18                                                                                                        Using the Analyzer
                                                                                     Displaying Measures in a Pivot Table


•     For the Columns box, you can drag and drop any of the items that you can use for Rows. See the preceding section for
      information on the items and details on the options.
•     You can drag and drop only measures from the Model Contents pane to Measures.

Measures are always used as the innermost grouping. For example, consider the following pivot table configuration:




This pivot table looks as follows:




Note:     The system does not display more than 100 columns.




2.7 Displaying Measures in a Pivot Table
By default, the Analyzer displays the count of lowest-level records. For example:




Within the body of the pivot table, you can instead display one or more measures, quality measures, or plug-in properties,
in any combination. Note that you can use measures, quality measures, and plug-in properties (usually referred to as plug-
ins) interchangeably. This section uses the generic term measures to refer to all of these items.
To display a measure as a column, drag and drop it into the Measures box or the Columns box. For example:

    Measures                                           Pivot Table
    Avg Age measure

    Avg Test Score measure



Or double-click the measure in the Model Contents pane.
Or drag and drop a measure to the Rows box, as discussed earlier. Note that if you display a measure as a row and another
measure as a column, the system displays only the value of the measure that is used as a column.
The following subsections discuss additional topics:
•     Pivot tables with one measure
•     Pivot tables with multiple measures
•     How to control the display of the measure headings


Using the Analyzer                                                                                                     19
Creating Pivot Tables



2.7.1 Pivot Tables with One Measure
To display measures as columns, you can drag and drop them to the Measures box or to the Columns box. If the pivot table
has multiple measures, the resulting pivot table (and underlying MDX query) is identical with either technique. If the pivot
table has only a single measure, however, the two techniques generate slightly different MDX queries:

    Technique                        Comments
    Drag and drop the measure        The underlying MDX query uses the measure in its filter clause. This means
    to the Measures box              that this pivot table cannot be displayed in a scorecard (on a dashboard).
    Drag and drop the measure        The underlying MDX query uses the measure as a column. This pivot table
    to the Columns box               can be displayed in a scorecard.



2.7.2 Pivot Tables with Multiple Measures
If you drag and drop multiple measures to the Measures box, you can specify whether the measures are used as columns

(as in the default case) or as rows. To do so, click the Options button  in the Measures box. The system displays a dialog
box; for this discussion, use the options in the section Place measures on. Choose one of the following:
•     Rows — Displays the measures as rows.

•     Columns — Displays the measures as columns.


Then click OK.
This option makes it easier to redefine complex pivot tables, because you can rearrange the Rows box or Columns box and
leave the measures alone.
For example, consider the following pivot table definition:




By default, the measures are used as columns (nested within the elements listed in the Columns box), as in the following
example:




20                                                                                                      Using the Analyzer
                                                                                        Displaying Measures in a Pivot Table




If you instead use the option to display the measures as rows, the pivot table looks like this:




This pivot table is equivalent to one defined as follows:




Using the Analyzer                                                                                                       21
Creating Pivot Tables




2.7.3 Controlling the Display of the Measure Headings
By default, when a pivot table displays a level on columns and displays measures, the pivot table may or may not include
a heading for the measures, as follows:
•    If the pivot table has only one measure, the measure name is not shown. For example:




•    If the pivot table has multiple measures, the measure names are shown. For example:




You can control this behavior. To do so, click the Options button      in the Measures box. The system displays a dialog
box; for this discussion, use the options in the section Display measure headers. Choose one of the following options:
•    If More Than 1 Measure — The system displays the measure name if there is more than one measure, but does not display
     the name if there is only one measure.
•    Always — The system always displays the measure name.

•    Never — The system never displays the measure name.


These options apply only when the pivot table also displays another item on columns, as in the examples shown here.




2.8 Displaying Properties in a Pivot Table
You can display the properties of a level if you are also using that level as rows or columns. For example, if you display
City as rows, you can display Principal Export as a column by dragging the property to the Columns box:




22                                                                                                      Using the Analyzer
                                                                                                 Transposing a Pivot Table




If you display City as columns, you can display Principal Export as a row:




2.8.1 Displaying Both Properties and Measures
If you display a property as a column and you want to display a measure as another column, you must drag and drop the
measure to Columns rather than to Measures. For example:




2.9 Transposing a Pivot Table

You can transpose a pivot table; that is, switch its rows and columns. To do so, click the Transpose button    .




Using the Analyzer                                                                                                     23
Creating Pivot Tables




2.10 Changing the Order of Items
To change the order of items listed within the Rows, Columns, Measures, or Filters box:
1.   Click an item within that box. When you do so, the system enables the applicable buttons in the header of the box.
2.   Click the up or down arrows as appropriate.




2.11 Copying and Pasting Items
To copy and paste items within the Rows, Columns, Measures, or Filters box:
1.   Click an item within that box. Now it is shown with a highlight.
2.
     Click the Copy button           in the top area.
3.   Click the destination for this item. Either click another box or click an item in a box.
4.   Click one of the paste buttons:
     •
         Click          to paste the item within the box or after to the selected item.
     •
         Click          to paste the item as a breakout within the selected item.




2.12 Adding a Summary Row or Column
You can add a summary row, summary column, or both. This section describes the following approaches:
•    Adding the summary as a pivot option
•    Using the All member as a summary
•    Using a custom aggregation as a summary


2.12.1 Adding a Summary Row or Column as a Pivot Option
To add a summary row, summary column, or both:
1.
     Click the Pivot Options button         .
     The Analyzer displays the Pivot Options page, which is discussed in detail later in this book.
     This procedure discusses only the Summary option.
2.   Click the Summary check box.
3.   Select a summary option from the drop-down list. The options are as follows:




24                                                                                                    Using the Analyzer
                                                                                         Adding a Summary Row or Column


     •   Sum — Displays the sum of the values.

     •   Count — Displays the count of rows.

     •   Max — Displays the maximum of the values.

     •   Min — Displays the minimum of the values.

     •   Average — Displays the average of the values.

     •   % of Total — Displays the sum of the values of this column (or row), as a percentage of the sums of all columns
         (or rows).

     For information on overriding how the summary is computed for a given measure, see Specifying Alternative Aggre-
     gation Methods for a Measure.
4.   (For summary rows only) Optionally, to cause the summary row to summarize all rows (including rows on later pages),
     select All Rows from the second drop-down list.

For example, the following pivot table includes a total row. Notice that it displays the total only for numeric values:




The following example shows % of Total, which is useful primarily when you use a level in Columns:




In contrast to the other forms of summaries, note the following:
•    If you display the pivot table as a chart, the chart does not include the summary row or column.
•    If you export to Excel, the summary is included only if it is a sum.


2.12.2 Adding the All Member as a Summary Row or Column
Your cube may include one or more All members. Each dimension can contain a All member, which is listed within the
dimension, in the Model Contents pane, before any levels. For example:



Using the Analyzer                                                                                                        25
Creating Pivot Tables




An All member represents all records and is typically named something like All Ages or All Categories. Or, as in
the example shown here, the All member might have a truly generic name.
You can drag and drop this member to Rows or Columns to add it as a summary row or column. For example:




In contrast to using the pivot options, this approach allows each measure to be aggregated in a different manner. The
Patient Count measure is summed, and the Avg Age and Avg Allergy Count measures are averaged.

If you do not have any All members, you can add a custom aggregation.


2.12.3 Adding a Summary Row or Column as a Custom Aggregation
This section describes how to add a summary row as a custom aggregation. The technique is easily adapted for a summary
column.
1.   For the level used as the rows, add the same level again to the Rows box.




2.
     Click the Advanced Options button       next to the second level in Rows.
     The Analyzer displays the Advanced Options page, which is discussed in detail later in this book.
3.   Select Compute Aggregate and then select an aggregation function. You can use any of the following functions:
     •   SUM — For each displayed measure, display the sum of the values of the members.



26                                                                                                       Using the Analyzer
                                                                                          Adding a Summary Row or Column


     •   AVG — For each displayed measure, display the average of the values of the members.

     •   MIN — For each displayed measure, display the minimum of the values of the members.

     •   MAX — For each displayed measure, display the maximum of the values of the members.

     •   COUNT — For each displayed measure, display the count of the members.

     •   COUNT NONEMPTY — For each displayed measure, display the count of the members that have values in the
         current context.
     •   AGGREGATE — For each displayed measure, display the aggregate value of the members, using the aggregation
         method defined for that measure.
     •   MEDIAN — For each displayed measure, display the median of the values of the members.

     •   STDDEV — For each displayed measure, display the standard deviation of the values of the members.

     •   VARIANCE — For each displayed measure, display the variance of the values of the members.

     •   PERCENTILE — For the given percentile value and for each displayed measure, display the measure value that is
         at that percentile value.
         For this option, you can specify a percentile value in the Percentile field; the default is 50.

4.   Optionally type a new caption into Caption. The default caption is the name of the function.

When you use this option, the system first uses any other settings you specified on this dialog box.
For example, consider the following pivot table:




This pivot table is defined with the following items in Rows:




The second Gender item uses the following options:
•    Compute Aggregate is Aggregate

•    Caption is Subtotal




Using the Analyzer                                                                                                   27
Creating Pivot Tables




2.13 Applying 80/20 Suppression
The Analyzer provides an easy way to display the top 80% of a set (considering the count measure by default), and to group
the bottom 20% into a single unit, as in the following example.




This example demonstrates the 80/20 suppression option used for rows. The option is also available for columns. To use
this option:
1.
     Click the Advanced Options button        in the Rows or Columns box.
2.   Optionally click Sort Members.
     Then select a measure and select Ascending or Descending.
     By default, the 80/20 suppression option first sorts the members in descending order by count. Use Sort Members to
     specify a different sort order.
3.   Select Apply 80/20 Suppression.
4.   Click OK.

To modify the query to use different percentages, see the section Modifying Details of the 80/20 Suppression Option.




2.14 Clearing the Autosave State of a Pivot Table
If the autosave feature for the Analyzer is enabled, then when you display a pivot table, the Analyzer displays that pivot
table with any unsaved changes that you might have made in the Analyzer. To remove these unsaved changes, click Restore.
Then the Analyzer displays the pivot table as defined in its saved definition.
Or save the pivot table, thus saving the changes and changing the definition. See the next topic.




2.15 Saving a Pivot Table
To save a pivot table, do one of the following:


28                                                                                                     Using the Analyzer
                                                                                                       Saving a Pivot Table


•   Click Save. The Analyzer saves the pivot table immediately, if you have specified a name for it; otherwise, the Analyzer
    prompts you as if you had selected Menu > Save With Options.
•   Click Menu > Save. The Analyzer saves the pivot table immediately, if you have specified a name for it; otherwise,
    the Analyzer prompts you as if you had selected Menu > Save With Options.
•   Click Menu > Save With Options. The Analyzer displays a dialog box with the same options that are available for a
    new pivot table; see Creating a Pivot Table.
    If you specify a new folder or a new name, the Analyzer creates a copy of the original pivot table and saves it to this
    new name.
    Then click OK.
    If the pivot table already exists, the system prompts you for confirmation that you want to overwrite it.

Or click Save As to make a copy of the pivot table. The Analyzer prompts you for a new name.
To check whether or not a pivot table has unsaved changes, check its name in the upper left corner of the Analyzer banner.
An asterisk by the pivot table name indicates unsaved changes, and will disappear after saving.




Using the Analyzer                                                                                                       29
3
Filtering Pivot Tables
This page describes how to use the Business Intelligence Analyzer to include filters in a pivot table, which restricts the set
of records that the pivot table accesses.

Note:     Applying a filter to a pivot table is different from adding a filter control to a pivot table widget in a dashboard
          (see Creating Dashboards). A filter control enables another user later to filter the data. You can add filter controls
          to a widget that displays a pivot table that has its own filter.

Also see Accessing the BI Samples.




3.1 About Filters
Filters restrict the set of records that the system uses.
Use the Filters box, shown below, to add filters to your pivot table:




Filters can be either simple or advanced, and you can add any combination of filters to your pivot table.
To create simple filters, you can also drag and drop filter items to the filter bar directly above the pivot table:




Later sections describe how to create these filters in detail.




Using the Analyzer                                                                                                           31
Filtering Pivot Tables




3.2 Dragging and Dropping Filter Items
You can drag and drop an individual member to use as a filter. To do so, drag and drop a member to Drop filter here in the
Filters box or to the filter bar.

The pivot table is then filtered to show only data for that member. The Filters box displays the name of the associated level,
and the filter bar displays the name of the level and the member. For example:




3.3 Creating and Using a Drop-Down Menu
You can drag and drop a level to the Filters box or the filter bar and then use the filter drop-down menu that the system
displays. This section provides the details. (You can use expression pivot variables in the same way. See Defining and
Using Expression Pivot Variables.)
For example, if you drag and drop the Year level, you might see this in the Analyzer (depending on what else you have
done):




Use the control to select members of the Year level. When you click the Search button         , you see something like this:




32                                                                                                        Using the Analyzer
                                                                                       Creating and Using a Drop-Down Menu




Here you can:
•   Select All to see all members of this level (that is, perform no filtering with this level).
    Note that the maximum number of members that can be displayed is 2500.
•   Select one or more members to filter the pivot table to use only data for those members.
    You must press Ctrl while selecting multiple members.
•   Select one or more members and select Exclude Members to filter the pivot table to use data for all members except
    for the selected ones.
•   Click Range and then specify an inclusive range of members. When you click Range, the control changes to look like
    this:




    In each drop-down list, select a member. For a time level, the list of members includes NOW, which always refers to
    the current date.

For other options, see Filtering Data..
When you are done, click the check mark button to accept the selections. Or click the X button to discard your changes.

Note:    The filter control is part of the Pivot Builder area, not part of the Pivot Preview area. This has two implications:
         •    When you save the pivot table, the Analyzer saves any selections in the filter control. When you next open
              the pivot table, the Analyzer redisplays the filter control as you saved it.
         •    The pivot table as seen in a dashboard is filtered as you saved it and does not include the filter control. (You
              use a separate mechanism to provide filters to users of your dashboards.)




Using the Analyzer                                                                                                         33
Filtering Pivot Tables




3.4 Adding Advanced Filters
To see the filter definition for an advanced filter, click the Advanced Options button             next to that filter. The system
then displays a dialog box with information like the following:




This represents the logic of the filter, but not its literal syntax. This filter selects only products that are either of the following:
•    Candy products sold in Bangalore
•    Snack products sold in Houston

The Advanced Filter Editor enables you to easily add, modify, and remove parts of a filter expression, while seeing the
resulting expression with every change. This book does not describe this tool in detail, but instead provides a brief
demonstration.
1.
     Click the Advanced Options button            in the Filters box. The system displays a dialog box like the following:




2.   Click Add Condition.



34                                                                                                                 Using the Analyzer
                                                                                                       Adding Advanced Filters


     The dialog box now looks something like this:




     Initially, the advanced filter editor uses the first level (considering alphabetic order) defined in your subject area.
3.   If you want to use a different level:
     a.   Click YearSold, which enables you to edit this part of the expression.
     b.   Optionally type a string into the search box and then click Search. This is useful if the cube has a large number
          of levels.
     c.   Select a level from the drop-down list on the left. As soon as you do, the expression is updated. For example:




          The end of the drop-down list may include measures; if so, see Filtering the Data by Measure Value, later in this
          page.

4.   If you want to change the operator from IS to IS NOT:
     a.   Click IS, which enables you to edit this part of the expression.
     b.   In the left area, click IS NOT. As soon as you do, the expression is updated.

5.   To specify a member of the level:
     a.   Click <select a value>, which enables you to edit this part of the expression. The left area might look like the fol-
          lowing:




     b.
          In the left area, click the Search button    under Select a value to display a dialog.
     c.   The resulting dialog displays a set of members and options. Optionally type text into the search box and press
          Enter; this restricts the set of members listed in the dialog.




Using the Analyzer                                                                                                             35
Filtering Pivot Tables


          The list of values also includes all searchable measures (see the next section) and all pivot variables (see Defining
          and Using Pivot Variables).
     d.   Select members and options by selecting their check boxes.
     e.   Click the check mark button in the upper right hand corner of the dialog. As soon as you do, the expression is
          updated.
          For example:




     f.   Alternatively, you may enter an MDX key by selecting the MDX Key option.

     This advanced filter is equivalent to a simple filter. Typically you would now add another condition or a branch that
     contains other conditions.
6.   To add another condition:
     a.   Click AND, so that you can edit this item.
     b.   Optionally, in the left area, click OR. As soon as you do, the expression is updated.
     c.   Click Add condition.
          You might now see the following:




     d.   Edit this condition in the same way that you edited the first one.

7.   Click OK to close the dialog box.
     Or add another condition or a branch that contains other conditions.

Note that you can undo any change. To do so, click Undo.




3.5 Filtering the Base Records by Measure Value
If your subject area includes searchable measures, you can filter records used in a pivot table by the value of those measures.
To do so:


36                                                                                                         Using the Analyzer
                                                                                Filtering the Base Records by Measure Value


1.
     Click the Advanced Options button         in the Filters box.
2.   Click Add Condition.
     The dialog box now looks something like this:




     The advanced filter editor initially uses the first level (considering alphabetic order) defined in your subject area.
3.   Click Age Group, which allows you to edit this part of the expression.
4.   Click the drop-down list on the left and scroll to the end of the list, which may include measures. For example:




     Note that the list of values also includes all pivot variables (see Defining and Using Pivot Variables).
5.   Click the measure that you want to use.
     Now the expression is updated as follows:




6.   Click the operator, which is an equals sign (=) by default.
     Now the editor displays the following set of operators:




Using the Analyzer                                                                                                            37
Filtering Pivot Tables




     Or, if the searchable measure contains string values, the editor displays the following operators: = <> LIKE
7.   Click the comparison value, which is 0 by default.
     Now the editor displays a box into which you can type a new value.
8.   Type a value and then click Apply.
     If you enter a string value, enclose it within single quotes. For example: 'abc'
9.   Click OK to close the dialog box.
     Or add another condition or a branch that contains other conditions.

For example, consider the following filter:




This filter selects all patients whose test score is 65 or higher.




3.6 Defining Named Filters
A named filter is saved with the subject area. You can use it in multiple pivot tables and in filter controls on dashboards.
To define a named filter:
1.   Make sure that no named filter is currently selected.
2.
     Click the Named Filter button          in the Model Contents pane.
3.   For Filter Name, type a user-friendly filter name.
4.   For Description, type an optional description.
     The rest of the dialog box is the same as the Advanced Filter Editor.
5.   For details on the rest of this dialog box, see Adding Advanced Filters, earlier in this page.

When you are done, the Model Contents pane displays the filter within the Named Filters section.




38                                                                                                        Using the Analyzer
                                                                                                     Redefining a Named Filter




Because a named filter can be relatively complex, it can be useful to define appropriate named filters for use on dashboards.
If you do this, users of the dashboards can filter their data more easily.




3.7 Redefining a Named Filter
To redefine a named filter:
1.   Select the named filter in the Model Contents pane.
2.
     Click the Named Filter button          .
3.   Make changes as needed.
     For details, see Adding Advanced Filters, earlier in this page.




3.8 Deleting a Named Filter
To delete a named filter:
1.   Select the named filter in the Model Contents pane.
2.   Click the X button.
3.   Click OK to confirm this deletion.




3.9 Using Named Filters
To use a named filter, drag and drop it from the Model Contents pane to the Filters box.
Or double-click the named filter; then it is added to the Filters box.




3.10 Disabling or Removing Filters
To disable a filter, clear the check box to the left of the name of the filter in the Filters box.




Using the Analyzer                                                                                                         39
Filtering Pivot Tables




To remove a filter, click the X to the right of the name of the filter.




3.11 How Business Intelligence Combines Filters
This section describes how the system combines filters.
If you apply multiple simple filters, the system combines them as follows (but see the important note after this list):
•    The system uses a logical AND to combine all the items shown in the bar above the pivot table.

      Filter                                       Meaning
                                                   All patients whose favorite color
                                                   is green and whose favorite
                                                   color is blue (zero patients)




                                                   All patients who are allergic to
                                                   both mold and to pollen




                                                   All patients whose favorite color
                                                   is green and who are allergic to
                                                   ant bites




•    If this bar displays a level, and if you have selected one or more members of that level in the drop-down, those members
     are combined with a logical OR.




40                                                                                                       Using the Analyzer
                                                                                                Finding the Key for a Member


      Filter                                     Meaning
                                                 All patients whose favorite color
                                                 is either green or blue




                                                 All patients who are allergic to
                                                 mold, to pollen, or to both




                                                 All patients whose favorite color
                                                 is green or blue and who also
                                                 are allergic to ant bites




If you have also applied advanced filters, those are combined with the other filters via logical AND.

Important:      Depending on the form of the combined filter, the system might perform axis folding. This phrase refers
                to the process of combining multiple filters (a filter is considered to be a query axis). Axis folding means
                that if a given source record has a non-null result for each slicer axis, that record is counted multiple times.
                For details on when this occurs, see Axis Folding in How the Business Intelligence Query Engine Works.




3.12 Finding the Key for a Member
This section describes how and why to find the key identifier for a member.
Each member has two identifiers:
•   A name (shown in the Analyzer and pivot tables). For example, in the Patients sample, a member of the Doctor level
    might have the name Vivaldi, Lola
    Names are not necessarily unique.
•   A key (never displayed). This is often but not always the same as the name. For example, in the Patients sample, the
    doctor whose name is Vivaldi, Lola might have the key 12
    The keys should be unique in a well-defined cube. (The system does not force them to be unique, but the developers
    who create a cube can and should take steps to ensure their uniqueness.)
    When you create a filter by drag and drop actions, the system automatically uses the member key rather than the
    member name.

You should use the key when you specify a filter value manually, which you do in the following scenarios:
•   When you specify the default value for a filter control on a dashboard (as described in Creating Dashboards).




Using the Analyzer                                                                                                           41
Filtering Pivot Tables


•    When you specify the initial value for a filter control via a dashboard URL (as described in Implementing InterSystems
     Business Intelligence).

It is also best practice to use the key when you refer to a member in a pivot variable.
To find the key for a given member, do the following:
1.   Drag and drop the member to the Filters box in the Analyzer.
2.
     Click the Display Query button           on the toolbar.
     The system displays the current MDX query, which looks something like this:




     The %FILTER part specifies the filter. The [DocD].[H1].[Doctor].&[32] part is the complete member identifier
     for this member. The key for this member is 32.

If the level contains multiple members with the same name, and if you are not sure which member to use, try the following
technique:
1.   Drag and drop each of the members to Rows.
2.   If this level has a property, drag and drop that to Columns. The property values are typically different for each member,
     and you can use the information here to determine which member to look at.
     Or drag and drop a level to Columns. Choose a level that can give some context.
     In other cases, it might be necessary to display a detail listing in order to correctly identify the desired member.




42                                                                                                         Using the Analyzer
4
Defining Calculated Elements
This page describes how to define calculated elements in Business Intelligence.
These calculated elements can be saved as part of a pivot table definition (and are then usable only in that pivot table) or
can be saved in a shared area (and are then usable in any pivot table based on the same cube).
Also see Accessing the BI Samples.




4.1 Overview
Often it is convenient to combine existing model elements into new elements. In InterSystems IRIS Business Intelligence,
you can add two kinds of calculated elements:
•    You can define a new measure that is based on other measures. For example, you can define a measure via a formula
     like the following:

     Measure 3 = (Measure 1 + Measure 2) / Measure 2)

     This is not the exact syntax. The following sections provide more detail.
•    You can define a new member that is based on other members. For example, you could create a Primary Colors
     member that combines the red, yellow, and blue members of the Favorite Color dimension.
     The new Primary Colors member refers to all the patients who belong to the red, yellow, or blue members.

In MDX, a measure is considered to be a member, and both kinds of calculated elements are considered to be calculated
members. This book uses the phrase calculated measure to refer to a calculated member that is a measure.




4.2 Defining a Calculated Measure
To define a measure that is based on other measures:
1.   If you intend to define this measure only in a given pivot table, save that pivot table.
2.
     Click the Calculated Element button        .
     The system displays the following dialog box (partially shown here):




Using the Analyzer                                                                                                         43
Defining Calculated Elements




3.   For Member Type, click Measure.
     When you do so, the system automatically selects Measures for the Dimension option.
4.   Optionally select Shared Storage. The system uses this option as follows:
     •   If Shared Storage is not selected, the calculated measure is stored with the pivot table definition and can be used
         in this pivot table but nowhere else.
     •   If Shared Storage is selected, the calculated measure is stored in a shared area and can be used in any pivot table
         based on the same cube. In this case, the Analyzer displays the calculated measure along with the elements that
         are defined in the cube itself.

5.   For Member name, type the name of the new measure.
6.   Specify the MDX expression that defines the new member. To do so, you can do either of the following:
     •   Type the expression directly into Expression.
     •   Use the Expression Builder. This tool is intended to make it easy to obtain the correct MDX identifier for any part
         of the cube. To access this tool, click the magnifying glass next to Expression. The left area lists the contents of
         the cube, including all measures and levels. The right area displays the expression that you are creating. To add
         an item to the expression, drag and drop it from the left area to the expression. The item is added to the end of the
         expression, and you might need to move it to a different part of the expression.

     For an introduction to these expressions, see the first subsection.
7.   Optionally specify the following additional options:
     •   Format — Specify a format string to control how this measure is displayed. See Specifying a Format String.

     •   Solve Order — Use this if your pivot table has a calculated measure as a column and a conflicting calculated
         measure (or other kind of calculated member) as a row. See the second subsection.

8.   Click OK.

The new member is then displayed within the Measures section in the Model Contents pane:


44                                                                                                        Using the Analyzer
                                                                                             Defining a Calculated Measure




You can then use this measure in the same way you use any other measure.


4.2.1 Measure Expressions
The measure expression can include the following elements:
•   References to measures. The syntax is as follows:

    [MEASURES].[measure name]

    Or:

    MEASURES.[measure name]

    You can omit the square brackets around the measure name, if the measure name contains only alphanumeric characters,
    does not start with a number, and is not an MDX reserved word. (MDX statements and functions are reserved words;
    see the table of contents in the InterSystems MDX Reference.)
    The expression is not case-sensitive.
•   Numeric literals. For example: 37
•   Pivot variables. See Defining and Using Pivot Variables.
    To refer to a pivot variable, use the syntax $variable.variablename where variablename is the logical variable
    name. This syntax is not case-sensitive.
•   Mathematical operators. Business Intelligence supports the standard mathematical operators: + (addition), - (subtraction),
    / (division), and * (multiplication). It also supports the standard unary operators: + (positive) and - (negative).

    For example: MEASURES.[%COUNT] / 100
    You can also use parentheses to control precedence.
•   MDX functions that return numeric values. Many MDX functions return numeric values, including AVG, MAX,
    COUNT, and others. See the InterSystems MDX Reference for details.

For other variations and specific recipes, see Defining Calculated Members.




Using the Analyzer                                                                                                         45
Defining Calculated Elements



4.2.2 Solve Order
The Solve Order option is useful if your pivot table has a calculated member (either measure or non-measure) as a column
and a conflicting calculated member as a row.
This option affects how the system determines the value in the cell and the format applied to the cell. By default:
•    The column determines the Format.
•    If both calculated members are measures, the column determines the cell value. (In other scenarios, the logic is more
     complex and Solve Order does not apply.)

If you instead want the row to determine the format and the value, ensure that Solve Order is higher for the calculated
member used as a row.
With one exception, the calculated member with the higher Solve Order is evaluated last and thus controls the results. The
exception is that if a row or column uses the %CELL function, its implicit default Solve Order is 10.
If the row and column both use %CELL and you want the row to determine the value and format string, set the Solve Order
to 11 for the row.
If the column and row members have the same Solve Order, the column member controls the results, as in the default case.

Tip:     For calculated measures that depend on other calculated measures, the system recognizes the dependencies and
         evaluates the measures in the appropriate order. You do not need to use Solve Order for these measures.




4.3 Defining a Calculated Member That Is Not a Measure
To define a calculated member based on other members:
1.   If you intend to define this member only in a given pivot table, save that pivot table.
2.
     Click the Calculated Element button        .
3.   For Member Type, click Dimension.
4.   Optionally select Shared Storage. The system uses this option as follows:
     •   If Shared Storage is not selected, the calculated measure is stored with the pivot table definition and can be used
         in this pivot table but nowhere else.
     •   If Shared Storage is selected, the calculated measure is stored in a shared area and can be used in any pivot table
         based on the same cube. In this case, the Analyzer displays the calculated measure along with the elements that
         are defined in the cube itself.

5.   For Dimension, either select a dimension or type the name of a new dimension. For example: Calculated
     You can specify any dimension, including an existing dimension that includes non-calculated members or a new
     dimension.
6.   For Member, type the name of the new member.
7.   Specify the MDX expression that defines the new member. To do so, you can do any of the following:
     •   Select a level from Dimension level. You can choose any level from the dimension that you selected in step 3.
         Then use Existing members to select one or more members of that level.



46                                                                                                       Using the Analyzer
                                                                        Defining a Calculated Member That Is Not a Measure


           The system then creates an MDX set expression in the Expression field.
           Then edit the expression in the Expression field.
     •     Type the expression directly into Expression.
     •     Use the Expression Builder. This tool is intended to make it easy to obtain the correct MDX identifier for any part
           of the cube. To access this tool, click the magnifying glass next to Expression. The left area lists the contents of
           the cube, including all measures and levels. The right area displays the expression that you are creating. To add
           an item to the expression, drag and drop it from the left area to the expression. The item is added to the end of the
           expression, and you might need to move it to a different part of the expression.

     These expressions are discussed later in this section.
8.   Optionally specify the following additional options:
     •     Format — Specify a format string to control how numeric values are displayed for this member. See Specifying
           a Format String.
     •     Solve Order — Select a number to specify the relative order in which to evaluate this calculated member, compared
           to other calculated members that affect the same cell. See Solve Order, earlier in this page.

9.   Click OK.

The new member is then available in the Dimensions section in the Model Contents pane:
If you added the member to an existing dimension, the system lists it within every level of that dimension. If you added it
to a new dimension, that new dimension is displayed at the bottom of this pane. For example, the following shows a new
dimension with two calculated members:




You can then use these members the same way that you use other members.
In a typical case, you define a new member that combines other members. In these cases, use one of the following syntaxes:
•    If the members that you want to combine all belong to the same level, use the %OR function as follows:

     %OR({member reference, member reference, ...})

     For example:

     %OR({[colord].[h1].[favorite color].[red],
     [colord].[h1].[favorite color].[blue],
     [colord].[h1].[favorite color].[yellow]})

     The general syntax for a member reference is as follows:

     [dimension name].[hierarchy name].[level name].[member name]

     Or:

     [dimension name].[hierarchy name].[level name].&[member key]




Using the Analyzer                                                                                                           47
Defining Calculated Elements


•    As a special case of the preceding, you can define a member that combines a range of members of a time level. To do
     so, use the %TIMERANGE function, which enables you to define an open-ended range. For example, the following
     expression defines a range that starts after the 2009 member:

     %TIMERANGE(DateOfSale.YearSold.&[2009],,EXCLUSIVE)

•    Otherwise, use the AGGREGATE function as follows:

     AGGREGATE({member reference, member reference, ...})


For other variations and specific recipes, see Defining Calculated Members.




4.4 Redefining a Calculated Member
To redefine a calculated member:
1.   Select the calculated member in the Model Contents pane.
2.
     Click the Calculated Element button      .
3.   Make changes as needed.




4.5 Deleting a Calculated Member
To delete a calculated member:
1.   Select the calculated member in the Model Contents pane.
2.   Click the X button.
3.   Click OK to confirm this deletion.




48                                                                                                   Using the Analyzer
5
Defining and Using Pivot Variables
This page describes how to define pivot variables and use them in Business Intelligence pivot tables.
A pivot variable is saved with the subject area. You can use it in multiple pivot tables and in controls on dashboards.
Also see Accessing the BI Samples.




5.1 Overview
Pivot variables provide another way for your end users to interact with your dashboards.
The definition of a pivot variable includes the following elements:
•    A name, which is not case-sensitive.
•    A default value, for use when the user has not specified a value for the variable.
•    (In most cases) A set of allowed values for the user to choose from.

These values are generally MDX identifiers, MDX expressions, or literal numbers or strings, depending on precisely how
the variable is intended to be used.
Pivot variables are generally intended to be used in pivot tables. Specifically, when you create a pivot table, you can use
pivot variables in selected parts of the query that defines the pivot table. When a dashboard displays the pivot table, that
dashboard can include a pivot variable control, with which the user can change the value of the corresponding pivot variable.
The system simply substitutes the given value into the query, executes the query, and then redisplays the pivot table.
Similarly, when you access a dashboard via a URL, that URL can include parameters that specify the value for pivot variables
used in pivot tables on the dashboard. Before displaying the dashboard, the system substitutes the given value into the
queries and executes the queries.




5.2 Defining a Pivot Variable
In general, to define a pivot variable:
1.
     Click the Add Pivot Variable button       .
     The system displays the following dialog box (partially shown here):



Using the Analyzer                                                                                                        49
Defining and Using Pivot Variables




2.   For Variable Name, type the logical name of the variable, to be used internally.
     The logical name must contain only alphanumeric characters. The name is not case-sensitive; you cannot create multiple
     pivot variables whose names differ only in case.
3.   Optionally specify the following additional options:
     •   Caption — Specify the display name of the variable. The default caption is the logical name.

     •   Description — Specify a description.

     •   Default Value — Specify the default value. The best practice is to specify a default value so that the system has a
         valid MDX query for any pivot table that uses this variable.
         For information on the kinds of values to provide, see Expression Pivot Variables and Literal Pivot Variables,
         later in this page.
     •   How is this variable used — This option affects how the system handles the variable internally. Select one of the
         following:
         –    Expression — Select this if you intend to use this variable to represent an MDX expression.

         –    Literal — Select this if you intend to use this variable to represent a literal number or string, for use within an
              MDX expression.

         For details, see Expression Pivot Variables and Literal Pivot Variables, later in this page.
     •   What type of value will this variable have — This option affects the default style of the control used when you add
         a pivot variable control to a dashboard.




50                                                                                                          Using the Analyzer
                                                                             Defining and Using an Expression Pivot Variable


     •   Source of values for this variable — Specify the source of possible values for this pivot variable. Select one of the
         following:
         –    Manual — Select this if you want to provide a hardcoded list of values, if you want to display a calendar
              control, or if you want the user to type a value.
              If you select Manual, do one of the following:
              •   To specify a hardcoded list of values, specify Values and (optionally) Captions. For Values, specify one
                  value per line. For Captions, specify the corresponding captions, if any, with one caption per line. In this
                  case, the pivot variable control displays your list of options.
              •   To display a calendar control, select day for What type of value will this variable have. In this case, the
                  pivot variable control is a calendar control.
              •   To enable the user to type a value, do not specify Values or Captions. Also, for What type of value will
                  this variable have, do not select day. In this case, the pivot variable control is a simple field into which
                  the user can type a value.

         –
              Termlist — Select this to use a term list to provide the values. If you select this, click the Search button
              and then select a term list. For each item in the term list, the system uses the item value as the value and uses
              the item key as the corresponding caption. The pivot variable control displays your list of options.
         –
              KPI — Select this to use a KPI to provide the values. If you select this, click the Search button      and then
              select a KPI.
              The KPI should have a property called Value. For each series in the KPI, the system uses the Value property
              as the value and uses the series name as the corresponding caption. The pivot variable control displays your
              list of options.

         In all cases, for information on the kinds of values to provide, see Expression Pivot Variables and Literal Pivot
         Variables, later in this page.

4.   Click OK.

The new variable is then displayed within the Pivot Variables section in the Model Contents pane.




5.3 Defining and Using an Expression Pivot Variable
An expression pivot variable represents an MDX expression.


5.3.1 Defining an Expression Pivot Variable
To define an expression pivot variable:
•    For How is this variable used, select Expression.
•    For Default Value, specify an MDX expression.
•    For Source of values for this variable, either specify a hardcoded set of MDX expressions or select a term list or KPI
     that returns a set of MDX expressions. See the next subsection.




Using the Analyzer                                                                                                              51
Defining and Using Pivot Variables



5.3.2 Values for Expression Pivot Variables
A value for an expression pivot variable should be an expression of one of the following types:

 Expression           Examples
 Type
 member               [aged].[h1].[age group].&[0 to 29]
 reference
                      See the comments after this table.

 tuple                ([aged].[h1].[age group].&[0 to 29],[gend].[h1].[gender].&[female])
 expression
                      Notice that the member references are separated by commas, and the expression is
 (which
                      enclosed in parentheses.
 represents an
 AND of multiple
 members)
 set expression       {[homed].[h1].[city].&[magnolia],[homed].[h1].[city].&[pine]}
 (which
                      Notice that the member references are separated by commas, and the expression is
 represents an
                      enclosed in curly braces.
 OR of multiple
 members)


The general syntax for a member reference is as follows:

[dimension name].[hierarchy name].[level name].[member name]

Or:

[dimension name].[hierarchy name].[level name].&[member key]

You can omit the square brackets for any identifier that contains only alphanumeric characters and that does not start with
a number. Also, you can omit the hierarchy and level names if the member name or key is unique within this dimension.


5.3.3 Using an Expression Pivot Variable
To use an expression pivot variable in a pivot table, drag and drop the variable into Rows, Columns, or Filters, as applicable.
In each case, the Analyzer adds a control to the filter bar so that you can test the variable. See the example.
Or define a calculated member that uses the pivot variable. See Defining Calculated Elements.

Note:    If the Analyzer encounters an error parsing a query involving a pivot variable, full details are available in the
         Business Intelligence Logs for debugging purposes.


5.3.4 Example
The following shows the definition of an expression pivot variable:




52                                                                                                         Using the Analyzer
                                                                           Defining and Using an Expression Pivot Variable




If we create a new pivot table and then drag and drop this variable to the Rows box, the Analyzer then displays the following
simple pivot table:




To test the pivot variable, we can use the filter bar. If we click the search button for SampleExprVariable, the Analyzer
displays the possible values for this variable:




If we select a different value, the pivot table changes, for example:




Using the Analyzer                                                                                                          53
Defining and Using Pivot Variables




5.4 Literal Pivot Variables
A literal pivot variable represents a literal string or numeric value to be used within an MDX expression. Depending on
how you define a literal pivot variable, you can use it within the Advanced Filter Editor, in calculated members, or in
manually written MDX queries.


5.4.1 Defining a Literal Pivot Variable
To define a literal pivot variable:
•    For How is this variable used, select Literal.
•    For Default Value, specify a fragment suitable for use in an MDX query.
•    For Source of values for this variable, either specify a hardcoded set of values or select a term list or KPI that returns
     a set of values. See the next subsection.


5.4.2 Values for Literal Pivot Variables
A literal pivot variable has a literal string or numeric value.
In the most useful scenario, the variable is intended to represent the last part of a member identifier, and you use it in the
Advanced Filter Editor. In this scenario, any value for the variable should be a string of the form &[key] where key is a
member key. For example: &[0 to 29]. (See Finding the Key for a Member.) See the example later in this section.
In another useful scenario, the variable is intended to represent a number that is used as a multiplier or other formula element.
In this case, you would use the variable within the definition of a calculated measure.


5.4.3 Using a Literal Pivot Variable
To use a literal pivot variable in a pivot table, use the Advanced Filter Editor. When you add a condition, select a level.
For the value for that level, select the name of the literal pivot variable; see the example in the next section.
Alternatively, define a calculated member that uses the pivot variable. See Defining Calculated Elements.

Note:     If the Analyzer encounters an error parsing a query involving a pivot variable, full details are available in the
          Business Intelligence Logs for debugging purposes.


5.4.4 Example
The following shows the definition of a literal pivot variable (for use with the HoleFoods sample):




54                                                                                                          Using the Analyzer
                                                                                                     Literal Pivot Variables




Suppose that we create a new pivot table. For this pivot table, we use the Advanced Filter Editor and add a condition. For
this condition, we select the YearSold level. For the Start Time value, we can select the following items:




The item $variable.SampleLitVariable is the pivot variable. The other items are the members of the YearSold
level.




Using the Analyzer                                                                                                       55
Defining and Using Pivot Variables


Note that all the pivot variables are available in all the value drop-downs in the Advanced Filter Editor. The
$variable.SampleLitVariable variable is suitable for use only with one level in this case — the YearSold level,
because this is the only level that has members with the keys 2008, 2009, and so on.




5.5 Redefining a Pivot Variable
To redefine a pivot variable:
1.   Select the pivot variable in the Model Contents pane.
2.
     Click the Pivot Variable button      .
3.   Make changes as needed.




5.6 Deleting a Pivot Variable
To delete a pivot variable:
1.   Select the pivot variable in the Model Contents pane.
2.   Click the X button.
3.   Click OK to confirm this deletion.




56                                                                                             Using the Analyzer
6
Customizing Pivot Tables
This page describes how to further customize Business Intelligence pivot tables.
Also see Accessing the BI Samples.




6.1 Specifying Pivot Options
The Pivot Options dialog box provides many ways to customize the pivot table. To access this dialog box, click the Pivot

Options button       . The Analyzer displays the following:




Here you can do the following:
•   Format the pivot table with zebra stripes. If you select Zebra Striping, the table is formatted with rows in alternating
    colors as follows:




Using the Analyzer                                                                                                         57
Customizing Pivot Tables




•    Remove the captions for the rows. To do so, clear Row Caption.
•    Specify which listing to use for this pivot table. To do so, select a listing from the Listing drop-down menu.
•    Specify the maximum number of records to include in listings for this pivot table. To do so, specify a value for Maximum
     Listing Rows. The default is 1000.

•    Apply custom colors and font styles. To do so, use the drop-downs in Row Options, Column Options, or Cell Options.
     For example:




     This style definition specifies that the font is in 12 pt, blue Verdana on a pale green background. The text is also bold
     and center-aligned.
     If you specify a custom color for the cell background in Cell Options, the system ignores the Zebra Striping option.
•    Use the Span Labels options to control whether labels are spanned.
     When you display the table in a nested format, the labels are spanned by default. For example:




     You can instead repeat the relevant labels, as follows:




•    Use the Show Empty options to control whether empty rows and columns are displayed.
•    Control the size of the data cells. To do so, type the width in pixels into Width and the height in pixels into Height.




58                                                                                                         Using the Analyzer
                                                                                           Customizing Pivot Table Items


As you make changes, the Preview area is updated to demonstrate the changes. For example:




If you have enabled the %SQLRESTRICT dimension for a cube, you will see the SQL Restriction field. If you wish to apply
an SQL Restriction for the current pivot table, enter a valid SQL SELECT statement or WHERE clause. For more information,
see %FILTER Clause.




6.2 Customizing Pivot Table Items
The Analyzer displays an Advanced Options button         in the Rows, Columns, and Measures boxes, next to each item in
those boxes. The same button is also available for the Rows and Columns boxes.
For example:




If you click any of these buttons, you see the following dialog box—depicted here with only its top part—or a variation of
it (the details are different for measures).




Using the Analyzer                                                                                                     59
Customizing Pivot Tables




The following sections describe changes you can make.
You can specify formatting in multiple places. If you specify different formatting, the following rules control which formatting
options are used:
•    Wherever possible, all the formatting is used. For example, if you specify the typeface to use for rows and the color
     to use for columns, both format options are applied.
•    Formatting specified for a measure in a pivot table takes precedence over formatting specified elsewhere.
•    Formatting specified for columns takes precedence over formatting specified for rows or the entire pivot table.
•    Formatting specified for rows takes precedence over formatting specified for the entire pivot table.
•    Formatting specified in the pivot table takes precedence over formatting specified in a measure definition (other model
     elements do not have format options).




6.3 Displaying a Constant Row or Column
You can display a constant value rather than the selected item. To do so:



60                                                                                                          Using the Analyzer
                                                                                      Specifying a Spacer Row or Column


1.
     Click the Advanced Options button         next to the item.
     See Customizing Pivot Table Items.
2.   Click Value.
3.   Type a value into Value. For example:




4.   Click OK.

You might also want to specify a different caption; see Specifying New Captions, later in this page.




6.4 Specifying a Spacer Row or Column
You can display a spacer row or column rather than the selected item or items. To do so:
1.
     Click the Advanced Options button         next to the item.
     See Customizing Pivot Table Items.
2.   Click Space.
3.   Click OK.

The following shows an example:




For this pivot table, the Rows definition is as follows:




Using the Analyzer                                                                                                  61
Customizing Pivot Tables




6.5 Displaying an Different Set for Rows or Columns
You can display an alternative set of elements rather than the selected item or items. To do so:
1.
     Click the Advanced Options button         next to the item.
     See Customizing Pivot Table Items.
2.   Click Advanced.
3.   Type an MDX set expression into MDX Expression.
     For information, see Using InterSystems MDX.
4.   Click OK.




6.6 Specifying New Captions
To specify new captions:
1.
     Click the Advanced Options button        next to the item or in the header of the Rows or Columns box, as appropriate.
     See Customizing Pivot Table Items.
2.   Type a value into Caption.
     To include the original name in the caption, use an asterisk (*) at the appropriate position.
3.   Click OK.

For example:




In this case, Caption is Group: *




6.7 Specifying a Format String
A format string controls how numbers are displayed and can also specify colors to use. To specify the format string for an
item:
1.
     Click the Advanced Options button        next to the item or in the header of the Rows or Columns box, as appropriate.
     See Customizing Pivot Table Items.
2.
     Click the Find button     next to Format.




62                                                                                                     Using the Analyzer
                                                                                                    Specifying a Format String


     The system displays a dialog box that includes the following fields:




     Here:
     •   Positive piece specifies the format to use for positive values.

     •   Negative piece specifies the format to use for negative values.

     •   Zero piece specifies the format to use for zero.

     •   Missing piece specifies the format to use for missing values.


     In each of these, Format string specifies the numeric format, and Color specifies the color.
3.   Specify values as needed (see the details after these steps).
4.   Click OK.


6.7.1 Format String Field
The Format string field is a string that includes one of the following base units:




Using the Analyzer                                                                                                         63
Customizing Pivot Tables


    Base Unit         Meaning                                                                                       Example
    #                 Display the value without the thousands separator. Do not include any decimal                 12345
                      places.
    #,#               Display the value with the thousands separator. Do not include any decimal                    12,345
                      places. This is the default display format for positive numbers.
    #.##              Display the value without the thousands separator. Include two decimal places                 12345.67
                      (or one decimal place for each pound sign after the period). Specify as many
                      pound signs after the period as you need.
    #,#.##            Display the value with the thousands separator. Include two decimal places (or                12,345.67
                      one decimal place for each pound sign after the period). Specify as many pound
                      signs after the period as you need.


You can include additional characters before or after the base unit.
•       If you include a percent sign (%), the system displays the value as a percentage. That is, it multiplies the value by 100
        and it displays the percent sign (%) in the position you specify.
•       Any other characters are displayed as given, in the position you specify.

The following table shows some examples:

    Example formatString                                                            Logical Value         Display Value
    formatString="#,#;(#,#);"                                                       6608.9431             6,609
    Note that this corresponds to the default way in which numbers are
                                                                                    –1,234                (1,234)
    displayed.

    formatString="#,#.###;"                                                         6608.9431             6,608.943
    formatString="#%;"                                                              6                     600%
    formatString="$#,#;($#,#);"                                                     2195765               $2,195,765
                                                                                    –3407228              ($3,407,228)



6.7.2 Color Piece
For the Color field, specify either of the following:
•       A CSS color name such as MediumBlue or SeaGreen. You can find these at https://www.w3.org/TR/css3-color/
        and other locations on the Internet.
•       A hex color code such as #FF0000 (which is red).
•       An RGB value such as rgb(255,0,0) (which is red).




6.8 Specifying Cell and Header Styles
To specify the cell and header styles for an item:




64                                                                                                           Using the Analyzer
                                                                                              Sorting and Filtering Members


1.
     Click the Advanced Options button        next to the item or in the header of the Rows or Columns box, as appropriate.
     See Customizing Pivot Table Items.
2.   Select values in the Cell Style and Header Style groups. These enable you to specify the style of the cells and the
     headers, respectively:




     To use these options, click each drop-down and select a value. For example:




     This style definition specifies that the header is in 12 pt, blue Verdana on a pale green background. The header is also
     bold and center-aligned.
3.   Click OK.




6.9 Sorting and Filtering Members
You can filter and sort the members of a level or named set in various ways. To do so:
1.
     Click the Advanced Options button        next to a level or named set or in the header of the Rows or Columns box, as
     appropriate.
     See Customizing Pivot Table Items.
2.   Specify the following options as needed:
     •   Filter members — Select this to filter the members by a measure value. Then select a measure and a comparison
         operator and type a value.
     •   Sort members — Select this to sort the members. Then select the measure by which to sort them. Click Ascending
         or Descending to control how the members are sorted.
     •   Return the first n members — Select this to select a subset from the beginning of the set. Then type an integer into
         Count.

         When you use this option, the system first uses any settings you specified for the Filter members and Sort members
         options.

3.   Click OK.




Using the Analyzer                                                                                                         65
Customizing Pivot Tables




6.10 Specifying Alternative Aggregation Methods for a
Measure
For any cell in a pivot table, each measure is aggregated from the lowest-level data. Aggregation methods include sum,
average, maximum value, and others. By default, the system uses the aggregation method specified in the measure definition.
You can specify an alternative method.
Similarly, if you add a summary row or column, you specify how to aggregate the displayed values into a single number
for that summary row or column. You can specify an alternative method for this as well.
To specify alternative aggregation methods for a measure:
1.
     Click the Advanced Options button        next to the measure.
     See Customizing Pivot Table Items.
2.   Specify either or both of the following options:
     •   Measure Aggregate specifies how this measure is aggregated from a set of values in your data.

         The choices are SUM, AVG, MIN, MAX, and COUNT.
     •   Total Override specifies how the displayed measure values are aggregated for any summary rows or columns.

         The choices are Sum, Count, Min, Max, Average, % of Total, and None.

3.   Click OK.

See also Adding a Summary Row or Column.




6.11 Customizing Double-Click Drilldown
By default, when you double-click a row in a pivot table, the system drills down to the next lowest level in the hierarchy,
if any (see Drilldown via Double-Click). You can customize this behavior. To do so:
1.
     Click the Advanced Options button        in the header of the Rows box.
2.   Expand the Drilldown Options group if that is collapsed.
3.   For Drilldown Expression, specify one or more MDX set expressions, one per line. For example:

     colord.h1.[favorite color].members
     gend.h1.gender.members

     To specify MDX set expressions, you can do either of the following:
     •   Type the expression directly into Drilldown Expression. Use a line return to establish required line breaks between
         items.
     •
         Use the Expression Builder. To access this tool, click the plus sign       next to Drilldown Expression. The left
         area lists the contents of the cube, including all measures and levels. The right area displays the expression that
         you are creating. To add an item to the expression, drag and drop it from the left area to the expression. The item
         is added to the end of the expression, and you might need to move it to a different part of the expression.



66                                                                                                      Using the Analyzer
                                                                                               Applying Conditional Formatting


         Click the plus sign each time you add an item to the expression. Using the plus sign (rather than a line return)
         causes the Expression Builder to establish and preserve the required line breaks between items.

     Typically you use set expressions of the form [dimension].[hierarchy].[level].MEMBERS, where dimension is the
     logical name of a dimension, hierarchy is the logical name of a hierarchy, and level is the logical name of a level. This
     expression represents the members of the given level.
     If these identifiers do not include spaces, you can omit the square brackets. Also, the expression is not case-sensitive.
     The first set expression controls what happens when the user double-clicks the first time. Specifically, when the user
     double-clicks the first time, the system creates a new query that uses this set expression for rows and that is filtered to
     the given context.
     Similarly, the second expression controls what happens when the user double-clicks the second time, and so on.
     The Drilldown Expression option overrides any other drilldown behavior in this pivot table. That is, if a level is in a
     hierarchy, the hierarchy drilldown behavior does not occur for this pivot table.
4.   Click OK.

Disable drilldown: If you wish at any time to disable (but preserve) this drilldown expression, select the Disable drilldown
check box. Click OK. This prevents use of the drilldown expression when you double-click a row in this pivot table. It also
prevents modification of the drilldown expression. To re-activate the drilldown expression, clear the Disable drilldown
check box.
For a Drilldown Expression example, see Custom Double-Click Drilldown.

Note:
          The same option is available in the Advanced Options button           in the header of the Columns box. This option

          is ignored by default but is used if you pivot the table (via the Transpose button       ) and then perform double-
          click drilldown.




6.12 Applying Conditional Formatting
You can apply conditional formatting, which can add color, text, or graphics to pivot table cells. To do so, you create rules
that examine the values in the cells. This conditional formatting overrides any customization you added to the pivot table.


To do so, click the Conditional Formatting button          in the toolbar. The system displays a dialog box like the following
(in this example, one rule has been specified):




Using the Analyzer                                                                                                           67
Customizing Pivot Tables




Here, you can do the following:
•    Clear all conditional formatting. To do so, click Clear rules.
•    Apply an overall color, based on values in the cells. To do so, click a button in the section Color all cells proportionally
     according to value. See Applying an Overall Color.

•    Define a custom gradient for use with the option Color all cells proportionally according to value. To define a custom
     gradient, use the two buttons displayed below My Colors. Click the first one and select a color to use at the bottom of
     the range. Click the second one and select a color to use at the top of the range. When you are done, the dialog box
     displays your gradient next to the predefined gradients. For example:




•    Create formatting rules. See Adding a Rule.
•    Change the order of the rules. To do so, click the up or down arrows in the row for a rule.
•    Delete a rule. To do so, click the X button in the row for that rule.
•
     Reconfigure a rule. To do so, click the Reconfigure button        in the row for that rule.
•    Apply the existing rules while leaving this dialog box open. To do so, click Apply.
•    Apply the existing rules and exit this dialog box. To do so, click OK.
•    Close this dialog box without making changes. To do so, click Cancel.

Rules are applied in the same order that they are listed here. If a later rule contains formatting information that is inconsistent
with an earlier rule, the system uses the formatting specified in the later rule.



68                                                                                                            Using the Analyzer
                                                                                              Applying Conditional Formatting



6.12.1 Applying an Overall Color
If you click a button in the section Color all cells proportionally according to value, the cells are colored according to their
values. This works as follows: Each button displays a gradient of colors. To assign a color to a cell, the system examines
the range of values of the cells. If a value is at the bottom of this range, the system uses the color that is shown at the top
of the gradient button (a dark blue in the following example). If a value is at the top of this range, the system uses the color
that is shown at the bottom of the gradient button (a light blue in the following example). For other values, the system uses
an intermediate color. The following shows an example:




6.12.2 Adding a Rule
To add a rule, click the plus sign button. The system displays a dialog box where you can specify the rule details (in this
example, one rule has been specified):




Here you can do the following:




Using the Analyzer                                                                                                           69
Customizing Pivot Tables


•    Specify the numeric comparison for the rule to use. A rule compares the value in each cell (or in specific cells) to a
     constant, using an operator. For example:

     cell_value > 50

     For each cell where this rule is true, the rule is applied. All the display details of the rule are applied to that cell.
     To specify the numeric comparison, do the following:
     1.   Select an operator from the first drop-down menu.
     2.   Type a numeric constant into the field to the right of that.

•    Optionally specify which row, which column, or both the rule applies to. To do so, type a number into Row #, Col #,
     or both.
•    Optionally specify the text color to use when the rule is true. To do so, click a button in the Color section. If you select
     the left-most button, the system uses the default color.
•    Optionally specify the background color to use when the rule is true. To do so, click a button in the Background Color
     section. If you select the left-most button, the system uses the default color.
•    Optionally specify replacement text to display when the rule is true, instead of the actual cell value. To do so, type text
     into Replace cell contents with.
•    Optionally specify an icon to display when the rule is true, instead of the actual cell value. To do so, click a button in
     Display icon in cell. This area lists the system icons, followed by any custom icons defined by the implementers. (For
     information on adding icons that can be used here, see Creating Icons.)
     If you select the left-most button, the system does not display an icon.
     To display multiple icons, click a number from the Number of icons to display list.

The bottom of the dialog box shows a preview of the formatting.




6.13 Specifying the Print Settings
To specify the print options for a given pivot table:
1.   Display that pivot table in the Analyzer.
2.
     Click the Print Options button         .
3.   Click Page Setup.
4.   Specify options as described in Customizing Print Settings for a Widget.
5.   Click OK.
6.   Save the pivot table.

For comments on printing, see Printing Pivot Tables.
Note that when you create dashboards, you can specify print settings in the dashboards as well. See Customizing Print
Settings for a Widget.




70                                                                                                             Using the Analyzer
                                                                                         Specifying the MDX Query Manually




6.14 Specifying the MDX Query Manually
Sometimes it is useful to see and then modify the MDX query that the system generates for a pivot table. To do so:
1.
     Click the Query Text button         .
     The system then displays a dialog box that displays the query used by this pivot table.
2.   If you want to use a different query, click Manual Mode.
3.   Edit the query. See the following subsection for an example.
     If you had displayed a detail listing, the bottom area of this dialog box also displays the listing query that the system
     used:




4.   Click OK.

When the Analyzer displays a pivot table that is defined by a manually edited or manually entered MDX query, the Query

Text button changes to the following:         . Also, the Rows, Columns, and Measures boxes are grayed out. You cannot
use locally defined calculated members unless you also add the appropriate WITH clause to your query. You can, however,
drag items to the Filters box; the system applies these filters but does not modify the manual query text. That is, the base
query and its filters are stored separately within the pivot table definition.

Tip:    You can also use the Query Text option to copy and paste the query (for example, to use in the MDX shell).


6.14.1 Modifying Details of the 80/20 Suppression Option
For example, if you had used the 80/20 suppression option, the MDX query might look like this (with harmless line breaks
added):

SELECT
NON EMPTY {[Measures].[Amount Sold],[Measures].[Units Sold],[Measures].[%COUNT]}
ON 0,
NON EMPTY
{TOPPERCENT([Product].[P1].[Product Name].Members,80),
%LABEL(SUM(BOTTOMPERCENT([Product].[P1].[Product Name].Members,20)),"Other",,,,"font-style:italic;")}

ON 1
FROM [HoleFoods]

For the TOPPERCENT and BOTTOMPERCENT functions:
1.   The first argument specifies the set of members to use.
2.   The second argument specifies the percentage.
3.   The third argument (omitted in the preceding example) specifies the measure to use for ranking the members.




Using the Analyzer                                                                                                          71
Customizing Pivot Tables


To change the percentages, change the second arguments for TOPPERCENT and BOTTOMPERCENT. For example:

SELECT
NON EMPTY {[Measures].[Amount Sold],[Measures].[Units Sold],[Measures].[%COUNT]} ON 0,
NON EMPTY
{TOPPERCENT([Product].[P1].[Product Name].Members,90),
%LABEL(SUM(BOTTOMPERCENT([Product].[P1].[Product Name].Members,10)),"Other",,,,"font-style:italic;")}
ON 1
FROM [HoleFoods]

For details on MDX, see Using InterSystems MDX and InterSystems MDX Reference.




72                                                                                      Using the Analyzer
7
Working with Pivot Tables
This page discusses how to work with Business Intelligence pivot tables.
Also see Accessing the BI Samples.




7.1 Opening a Saved Pivot Table
To open a saved pivot table:
1.   Click Open. Or click Menu > Open.
     The system displays a dialog box, which shows names of folders and of pivot tables that are not in any folders.
2.   Optionally click the name of a folder.
     The dialog box then shows the contents of that folder.
     Repeat as necessary if your folders are nested.
3.   Click the name of the pivot table you want to open.
4.   Click Go.

The system closes the dialog box and then displays the selected pivot table in the Analyzer.


In most cases, the underlying query is executed automatically. If it is not, click the Refresh button   . See the next topic.




7.2 Disabling and Enabling Auto-Execution
By default, when you make any change to the pivot table, the Analyzer re-executes the query and redisplays the results.
You can disable this auto-execution. To do so, clear the Auto-execute option on the toolbar. Later, to enable auto-execution,
select the Auto-execute option.




Using the Analyzer                                                                                                        73
Working with Pivot Tables


Note:     If you disable auto-execution and save the pivot table, that change is saved as part of the pivot table definition
          and affects the behavior of any dashboards that use the pivot table. Therefore, you should be careful to make this
          change and save it only if you do not want the pivot table to run automatically in dashboards, though actions may
          still be invoked from the Analyzer with the current query described by the pivotTable object even if said
          pivotTable has not been executed. Be sure to include a refresh control in any widget that displays this pivot
          table. For more information, refer to this section on manual query editing.




7.3 Canceling a Running Query
While the Analyzer is executing a query, you can cancel it. To do so, click the Cancel Query button           .




7.4 Exporting Data to Microsoft Excel or CSV file
From the Analyzer, you can export the data in a pivot table to Microsoft Excel or to a CSV file by selecting the Export

current results button        in the Pivot Builder area. On a dashboard, you can also export data to Microsoft Excel from

a pivot table widget, but not from other types of widgets. To do so, select the Export to Excel button            in the widget.
In the Analyzer, when you export data to CSV by selecting the CSV option from the drop-down menu, the system generates
a file that includes the contents of the pivot table, including the column and row labels. The cell values for a given row are
separated by comma characters (,), and rows are separated by line breaks. When you select the CSV with Heading option
from the drop-down menu, the file includes the same contents as a file exported using the CSV option, with an additional
line at the beginning. This line is a heading that identifies the data:
•    If the data is derived from a saved pivot table, the heading contains the relative path to the pivot table and the pivot
     table’s name (for example: "Patient Pivots/Avg Score by Age")
•    If the data is not derived from a saved pivot table, the heading provides the name of the source cube or subject area

When you export data to Microsoft Excel, the system generates an Excel file that contains all the data currently displayed
in the widget. The file has the name %DeepSee.UI.MDXExcel.zen.xls, %DeepSee.UI.MDXExcel.zen-1.xls, or similar. Your
browser then does one of the following, depending on your operating system, the configured file types on your machine,
your browser, and your browser settings:
•    Opens the file with Excel (or other selected program).
     You specify the program to use by setting a browser option. For example, on Firefox, you use Tools > Options >
     Applications. This option also enables you to specify whether the browser should open the file with this program or
     prompt you to save it to the hard drive.

     Note:    The exported file, while created with an .xls extension, is formatted as an HTML spreadsheet. Excel will
              prompt you with a warning about the format and extension not matching, but this does not indicate an unusable
              or unsafe file. When prompted to open the file anyway, click Yes.

•    Prompts you to open the file with Excel (or other selected program, as described in the previous bullet).
•    Opens this file within the current browser window.




74                                                                                                         Using the Analyzer
                                                                                                        Printing a Pivot Table


     This is the default behavior for Windows operating systems earlier than Windows Vista. You can change this behavior
     on the Edit File Type dialog box (which you access via My Computer > Tools > Folder Options or My Computer > View
     > Options, depending on the operating system version).

     This option is not available on Windows Vista and later Windows operating systems.
•    Prompts you to save the file to the hard drive.
•    Automatically saves the file to the hard drive.

Exporting to Excel, does not support exporting more than 250000 rows. Also, if the cube is based on a data connector that
uses an external table, there is a limit of 1000 rows in the listing.

Note:     If no numeric formatting is specified, any numbers are formatted as integers by default. (The actual values are
          available in Excel, and you can change the formatting as needed to display them appropriately). If numeric for-
          matting is specified in the model or in the pivot table definition, that formatting is used in Excel.




7.5 Printing a Pivot Table

To print a pivot table from the Analyzer, click the Print button     . The system generates a .pdf file and opens it in your
default browser. You can then use options in the browser to print the file or to download it, for printing later.
Note that if you download the file, the browser saves the file to the default download directory for that browser; there is
no mechanism to specify a different location.
Also see Specifying the Print Settings.


7.5.1 Requirements for Printing
When a user invokes the Print option, InterSystems IRIS® data platform uses Java to call out to a third-party PDF rendering
tool. The call out operation takes place using the /api/deepsee REST interface. This means that Java (or specifically JRE,
Java Runtime Environment) is required on the user's machine.
This also means that you must configure security settings for your application appropriately. A user must hold the
%System_CallOut:Use privilege in order to invoke the Print option. Furthermore, invoking the Print option may prompt
the user to authenticate again if you have not configured the /api/deepsee web application to share a common authentication
mechanism with the /csp/ web application for your namespace, which serves the Analyzer. (Similar problems may occur
navigating between any two Management Portal pages which are served by different web applications.)
For information on the requirements, see Configuring InterSystems IRIS for PDF Output.




7.6 Sending Email
You can send email that contains a link to the pivot table, if your system is configured for this. To do so:
1.   Open a pivot table that contains the data about which you want to send a message.
2.   Click Menu > Send Email.
     If this option is not present, then your system is not configured to support email.
3.   The system then does one of the following:



Using the Analyzer                                                                                                         75
Working with Pivot Tables


     •   Displays the default email system on your machine, with a message that contains a link to the dashboard.
         Edit the message, specify one or recipients, and send it as usual.
     •   Displays a dialog box.
         Choose a recipient, type a brief message to include along with the generated link, and click OK.




7.7 Displaying the Pivot Table as a Chart
By default, the Analyzer displays the results in table format. You can use the buttons in the upper left to switch to other
formats.




To display the results as a table, click the Display As Table button          .




76                                                                                                        Using the Analyzer
                                                                                 Displaying the Pivot Table as a Chart




If you click the Chart Options button   , the Analyzer displays the following page:




Using the Analyzer                                                                                                 77
Working with Pivot Tables




Here you can do the following:
•    Specify a new title. To do so, type a value into Title.
•    Specify a chart type. To do so, click the button in the Chart Type section.
•    Control the display of grid lines. To do so, click a button in the Grid Lines section.
•    Control the text size. To do so, click a button in the Text Size section.
•    Specify the minimum value to display on the vertical axis. To do so, type a value into Minimum Axis Value.
•    Specify the maximum value to display on the vertical axis. To do so, type a value into Maximum Axis Value.

Notes that these changes do not affect the definition of the pivot table. When you add a pivot table to a dashboard, you can
choose a chart type. Furthermore, a chart displays only the first 100 items.
For information on the chart types, see Available Chart Types.




7.8 Deleting a Pivot Table
To delete a pivot table in the Analyzer, click Delete.




78                                                                                                      Using the Analyzer
                                                                                                     Deleting a Pivot Table


Note:    When you delete a pivot table, the system moves it into a folder named $TRASH. Or, if the pivot table is already
         in a folder, then $TRASH/ is prepended to the folder name. In either case, the pivot table is no longer visible in
         the web-based interfaces.




Using the Analyzer                                                                                                      79
8
Performing Ad Hoc Analysis
This page describes ways to analyze the data you see when viewing a pivot table in the Business Intelligence Analyzer.
Also see Accessing the BI Samples.




8.1 Displaying a Detail Listing
A detail listing displays fields at the lowest level, for the records associated with one or more selected cells. You can display
a default listing, select a different listing to display, or even select the fields to display. You can also sort the detail listing.
The following subsections provide the details and also describe how to exit the listing.

Note:     If you display a listing and save the pivot table, the Analyzer saves its listing state. That is, when you next open
          it, the Analyzer redisplays the pivot table as a listing. Similarly, if it is included in any dashboards, it is displayed
          there as a listing.


8.1.1 Displaying the Default Detail Listing
To display the default detail listing:
1.   Display a pivot table as usual.
2.   Click the data cells in the row or rows.
     To select multiple cells, hold the Shift key down while clicking the cells.
     To select an entire row, click the row label on the left. To click an entire column, click the column header.
     The listing option is not available for cells in a total row or a total column.
3.
     Click the Listing button            .

The Pivot Preview area displays something like the following:




Using the Analyzer                                                                                                                81
Performing Ad Hoc Analysis




If there are more than 100 rows, the bottom area displays buttons that you can use to page through all the rows.
The Pivot Builder area now displays the Custom Listing Fields box, which is for use when you select fields to display, if
possible.


8.1.2 Displaying a Different Detail Listing
To display a different listing:
1.   Display the default listing as described earlier.
2.   Select Detail Listings in the Model Contents area.
3.   Click the name of the listing to display.
     Typically each listing uses a different set of fields and is meant for a different purpose.
     If the name of a listing is italicized, that indicates that this listing is defined in a listing group and that you have the
     necessary permissions to modify the listing. See Defining Listing Groups.

Or, before you display the listing, do the following:
1.
     Click the Pivot Options button         .
2.   Select a listing from the Listing drop-down menu.
3.   Click OK.


8.1.3 Creating a Custom Listing
Depending on the subject area, you might be able to create a custom listing that uses fields that you select. To do so:
1.   Display the default listing as described earlier.
2.   Select Detail Listings in the Model Contents area.
3.   Select Custom Listing.
     The system then displays a listing that initially shows only the IDs of the records.
4.   Optionally clear the Auto-execute check box.


82                                                                                                            Using the Analyzer
                                                                                                  Displaying a Detail Listing


     This is helpful if the listing uses many records, because each time when you change the listing definition, the system
     reruns the corresponding query by default. When Auto-execute is off, the system does not rerun the query automatically.
5.   Expand the Custom Listing folder. For example:




     This folder lists the available listing fields in this subject area.
     Note that the sample Patients cube defines a listing named Custom listing. This listing is an ordinary listing defined
     with custom syntax and cannot be used as described here.
6.   Drag listing fields from this area to the Custom Listing Fields box.
7.
     If you cleared the Auto-execute check box, use the Refresh button        in the Pivot Builder area.
     The system then runs the query and displays the results. For example:




8.1.4 Sorting a Listing
By default, the definition of a listing controls the order of the rows.
You can instead sort the listing by the values shown in any data column. To do so, double-click the column header.
The first time you double-click the column header, the listing is sorted in ascending order, by the values in that column,
and the column header includes the >> characters to indicate this sorting.




Using the Analyzer                                                                                                        83
Performing Ad Hoc Analysis


If you double-click the column header again, the listing is sorted in descending order instead (and the column header
includes the << characters). If you double-click a third time, the sorting is removed and the default order is restored.
Listings on pivots based on data connectors cannot be sorted.


8.1.5 Exiting the Listing
To exit the listing and redisplay the pivot table, do either of the following:
•    Click the left arrow button
•
     Click the Display Table button:




8.2 Drilldown via Double-Click
In some cases, you can drill down by double-clicking a row (other than a total row).
In some of these cases, the system uses the hierarchy, if any, to determine how to drill down. In other cases, the system
drills down in a custom manner, as defined in the pivot table.

Note:     The drilldown action has no effect if the pivot table uses a manually entered MDX query. See Specifying the
          MDX Query Manually.


8.2.1 Drilldown in a Hierarchy
This section describes drilldown in a hierarchy. For example, in the Patients sample, The ZIP code level is the parent of
the city level. Consider the following pivot table:




If you double-click the cell 38928, the system displays the following in the upper right of the pivot builder area:




And the pivot table looks like this:




8.2.2 Custom Double-Click Drilldown
To customize how the system drills down, see Customizing Double-Click Drilldown. This section provides a demonstration.


84                                                                                                       Using the Analyzer
                                                                                                  Drilldown via Double-Click


For example, consider the following pivot table:




Suppose that for this pivot table, we specify Drilldown Expression as follows:

colord.h1.[favorite color].members
gend.h1.gender.members

If we double-click the cell 32006, the pivot table then looks like this:




If we double-click the cell None, the pivot table then looks like this:




If we double-click again, nothing further happens.


8.2.3 Saving the Drilldown
If you drill down in a pivot table and then save it, the Analyzer saves its drilldown state. That is, when you next open it,
the Analyzer redisplays the pivot table with the drilldown. Similarly, if the pivot table is included in any dashboards, they
display it in its drilldown state.


8.2.4 Clearing the Drilldown
To clear the drilldown of a pivot table, you can do any of the following:
•   Click the left arrow button in the toolbar.
•   Click the X button in the Drill down area in the toolbar, if applicable.
•   Click the << arrows in any of the rows in the pivot table.




Using the Analyzer                                                                                                        85
Performing Ad Hoc Analysis




8.3 Performing Arbitrary Drilldown
In the drilldown action, you focus on a row in the pivot table and see a different breakout for that row. To drill down in an
arbitrary way, drag and drop any level from the Model Contents pane onto the non-scrolling part of a row in the pivot table.
For example, suppose that you start with the following pivot table:




Suppose that you expand the level list in the Model Contents pane (not shown) to display the birth year 1989. Then drag
and drop 1989 onto Elm Heights. The system displays the label Drilldown: Year 1989 in the upper right of the pivot builder
area, and the pivot table looks like this:




This option is not available for a total row.
Also see Saving the Drilldown State and Clearing the Drilldown State, earlier in this page.

Note:     The drilldown action has no effect if the pivot table uses a manually entered MDX query. See Specifying the
          MDX Query Manually.




8.4 Introduction to the Pivot Analysis Window
The Analyzer also provides the Pivot Analysis window, which you can use for several specialized analyses. In each case,
you first select one or more cells, and the analysis considers the lowest-level data associated with those cells. To access
this window:
1.   Click the data cells in the row or rows.
     To select multiple cells, hold the Shift key down while clicking the cells.
     To select an entire row, click the row label on the left. To click an entire column, click the column header.
     The analysis option is not available for cells in a total row or a total column.
2.
     Click the Analysis button         .

For details, see Using the Analysis Window. (The same analysis options are also present in dashboards.)



86                                                                                                        Using the Analyzer
A
Configuring InterSystems IRIS for PDF
Output
When you print from Business Intelligence to PDF, InterSystems IRIS® data platform uses Java to call out to a third-party
PDF rendering tool. The rendering tool applies the XSLT stylesheet to the XML data and transforms the XML into XSL-
FO. Finally, the tool transforms the XSL-FO into PDF.
The InterSystems IRIS installation provides a version of Apache FOP to use as the default PDF rendering engine. You can
also use another rendering engine, such as XEP PDF from RenderX, or download and install FOP from Apache.




A.1 Using the Built-in PDF Rendering Engine
The PDF rendering process works only if you have performed the required configuration steps. This section discusses
configuration for the built-in FOP. For information on configuring alternate PDF renderers, see the section Using Other
Rendering Engines.
1.   If you do not already have a Java Virtual Machine (JVM) installed on the server, download and install this tool on your
     system. The JVM is included in the Java Runtime Environment (JRE) and the Java Developers Kit (JDK) supported
     by this version of InterSystems IRIS, so if you have either of these tools you already have a JVM. Alternatively, you
     may install and use one of the supported versions of OpenJDK.
     In order for InterSystems IRIS to find Java, you need to define the JAVA_HOME environment variable and set it to
     the location where you have installed your JDK. JAVA_HOME is described in the Java documentation. You must also
     add your JDK installation’s /bin/ directory path to your system’s PATH variable.
2.   You must ensure that user privileges are set correctly. To generate PDF output, the user must be logged in to a user
     account that has the %System_CallOut:USE privilege.
3.   You can create custom configuration files for the built-in FOP as described in materials on the Apache FOP Web site:
     http://xmlgraphics.apache.org/fop

     If you want the InterSystems IRIS callout to FOP to use a custom configuration file, you can set the global
     ^%SYS("zenreport","transformerconfig") to the path of the configuration file. Configuration files are
     important for adding fonts to FOP. You must first create font metrics, and then register them with FOP. The process
     is described on the Apache FOP web site.
     If you modify the FOP configuration file fop.xconf, then an InterSystems IRIS install does not copy over it. The FOP
     configuration file that comes with your InterSystems IRIS distribution is named fop.xconf_dist. If your fop.xconf file
     becomes corrupted for any reason (such as running RenderX, which truncates the file if the parameter USEINSTALLED-


Using the Analyzer                                                                                                          87
Configuring InterSystems IRIS for PDF Output


     FOP is not set to zero), you can revert to the file as distributed with InterSystems IRIS by copying fop.xconf_dist to
     fop.xconf.


Note:     PDF rendering can consume a lot of memory. If you run into trouble, you might want to modify the FOP.bat or
          XEP.bat file to increase the amount of memory available to the Java Virtual Machine. The respective products
          provide documentation that explains how to do this.




A.2 Using Other Rendering Engines
A version of Apache FOP is installed with InterSystems IRIS. If you chose to use another PDF rendering tool, you must
perform the following additional configuration steps.
1.   Install the XSL-FO to PDF rendering tool. Two of the available options are:
     •   An open source project from Apache called FOP. You can download it from the following Web site:
         http://xmlgraphics.apache.org/fop

         To install, simply extract the files from the kit.
     •   The XEP product from RenderX. You can download a free trial version that produces a RenderX watermark on
         each output page, or you can buy the XEP product. See this Web site for details:
         http://www.renderx.com/tools/xep.html

         To install, follow the instructions in the kit.
     •   To configure InterSystems IRIS to work with RenderX XEP, you need to define a %JAVA_HOME% and a
         %XEP_HOME% environment variable. %JAVA_HOME% is described in the Java documentation. %XEP_HOME%
         is an environment variable specifying the location where you have installed XEP.

2.   Configure InterSystems IRIS with the full pathname of the command file that invokes the rendering tool. For XEP or
     FOP on Windows or UNIX®, once you have installed the tool as instructed in Step 1, this command file is present on
     your system under the installation directory for the tool, for example C:\fop-0.95\fop.bat for Windows or /fop-0.95/fop
     on UNIX®.
     To perform this configuration, navigate to System Administration > Configuration > Report Servers > Settings, and
     make the following changes:
     •   Path and File Name For PDF Generation: — Enter the path to the executable file. Click Browse to locate and select
         the command file.
     •   Foxit / Adobe Path for Pdfprint: — Ignore this field.

     •   Configuration File For PDF Rendering Engine: — This field is optional. Select Use or None. If you select Use, enter
         the path to the FOP configuration file. If you do not specify a FOP configuration file, the FOP renderer uses the
         configuration file supplied with the built-in FOP.
         Do not enter a path in this field if you are using an XEP renderer. The XEP renderer truncates any file specified
         here to 0 length. Click Browse to locate and select the configuration file.
         You can create custom configuration files as described by the tool provider’s Web site. To provide XEP with a
         custom configuration file, you need to follow the manual for XEP.
     •   Default HotJVM Render Server Port — Enter the port number where the HotJVM Render Server is running.

     •   Verify Now — Click this button to test whether or not the rendering tool is configured correctly.




88                                                                                                        Using the Analyzer
                                                                                               Using Other Rendering Engines


     Alternatively, start the Terminal and set the corresponding global nodes. For example, to set the renderer executable:

     Set ^%SYS("zenreport","transformerpath")="/Applications/fop-0.95/fop.bat"

     Similarly, to set the configuration file, set ^%SYS("zenreport","transformerconfig") to the path of the
     configuration file.
3.   The default behavior is to use the installed FOP, unless you have set an alternative renderer on the Management Portal
     Report Settings page.


Note:     If you are using FOP version 0.94 or earlier, you must set a flag to specify that an older FOP version is the rendering
          tool. To do this, enter the following commands in the Terminal:

          set $namespace = "%SYS"
          set ^%SYS("zenreport","oldfop")=1




Using the Analyzer                                                                                                            89
