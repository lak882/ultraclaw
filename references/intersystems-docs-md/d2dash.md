   Creating Dashboards
                           Version 2026.1
                            2026-04-20




InterSystems Corporation One Congress Street Boston MA 02114 www.intersystems.com
Creating Dashboards
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
       1 Introduction to Dashboards ............................................................................................................... 1
           1.1 Displaying Business Intelligence Dashboards ........................................................................... 1
           1.2 About Dashboards ...................................................................................................................... 3
           1.3 Location of Dashboard Definitions ............................................................................................ 4
       2 Creating and Modifying Dashboards ............................................................................................... 5
           2.1 Introduction to the Autosave Feature ......................................................................................... 5
           2.2 Creating a Dashboard ................................................................................................................. 5
           2.3 Modifying Dashboard Settings ................................................................................................... 6
           2.4 Adding a Widget to a Dashboard .............................................................................................. 10
           2.5 Overview of Widget Types ....................................................................................................... 11
                2.5.1 Widget Types and Subtypes ........................................................................................... 11
                2.5.2 Comparison of Widget Types ......................................................................................... 12
           2.6 Reconfiguring a Widget ............................................................................................................ 12
                2.6.1 Toolbar Settings .............................................................................................................. 14
                2.6.2 Sidebar Settings .............................................................................................................. 14
           2.7 Specifying the Data Source for a Widget ................................................................................. 15
                2.7.1 Names of Data Sources .................................................................................................. 16
                2.7.2 Kinds of Data Sources .................................................................................................... 17
                2.7.3 Linked Widgets .............................................................................................................. 17
           2.8 Saving a Widget to the Widget Catalog .................................................................................... 18
           2.9 Removing a Widget from a Dashboard .................................................................................... 18
           2.10 Clearing the Autosave State of a Dashboard .......................................................................... 18
           2.11 Saving a Dashboard ................................................................................................................ 19
           2.12 Copying a Dashboard ............................................................................................................. 19
           2.13 Deleting a Dashboard ............................................................................................................. 20
                2.13.1 Deleting a Dashboard in the User Portal ...................................................................... 20
       3 Specifying Common Widget Options .............................................................................................. 21
           3.1 Customizing Print Settings for a Widget .................................................................................. 21
                3.1.1 Requirements for Printing .............................................................................................. 22
                3.1.2 Special Options for the Title and Subtitle ...................................................................... 22
                3.1.3 Listing Settings .............................................................................................................. 22
                3.1.4 Filter Settings ................................................................................................................. 22
           3.2 Adding Widget Properties ........................................................................................................ 23
           3.3 Managing Widget Properties .................................................................................................... 24
           3.4 Specifying Numeric Format Strings ......................................................................................... 24
                3.4.1 Selecting a Format String ............................................................................................... 24
                3.4.2 Typing a Numeric Format String ................................................................................... 25
                3.4.3 Localization of Numeric Separators .............................................................................. 26
           3.5 Specifying Table Text Styles .................................................................................................... 29
           3.6 Specifying Chart Text Styles .................................................................................................... 30
           3.7 Specifying Line Styles ............................................................................................................. 30
       4 Adding Pivot Table Widgets ............................................................................................................. 33
           4.1 Adding a Pivot Table Widget .................................................................................................... 33
           4.2 Specifying Widget Settings for a Pivot Table Widget .............................................................. 34
           4.3 Customizing the Columns (When Displaying a KPI) .............................................................. 35
           4.4 Displaying a Listing in a Pivot Table Widget ........................................................................... 35



Creating Dashboards                                                                                                                                          iii
           4.5 Customizing the Appearance of a Pivot Table .......................................................................... 35
               4.5.1 Size and Appearance Options ........................................................................................ 36
               4.5.2 Color and Style Options ................................................................................................. 38
           4.6 Removing a Pivot Table Redefinition ....................................................................................... 39
     5 Adding Chart Widgets ...................................................................................................................... 41
         5.1 Adding a Chart Widget ............................................................................................................. 41
         5.2 Customizing the Chart Type ..................................................................................................... 42
         5.3 Chart Requirements .................................................................................................................. 42
         5.4 Available Chart Types ............................................................................................................... 42
              5.4.1 Bar and Column Charts .................................................................................................. 43
              5.4.2 Line and Area Charts ...................................................................................................... 43
              5.4.3 Combo Charts ................................................................................................................ 44
              5.4.4 High Low Charts ............................................................................................................ 47
              5.4.5 Pie Charts ....................................................................................................................... 49
              5.4.6 X/Y Charts ..................................................................................................................... 50
              5.4.7 Bubble Charts ................................................................................................................. 52
              5.4.8 Time Charts .................................................................................................................... 53
              5.4.9 Tree Maps ....................................................................................................................... 54
              5.4.10 Bullseye Charts ............................................................................................................ 55
              5.4.11 Swirl Charts .................................................................................................................. 56
         5.5 Displaying a Production Business Metric ................................................................................ 58
     6 Customizing the Appearance of a Chart Widget ........................................................................... 61
         6.1 Size and Appearance Options ................................................................................................... 61
         6.2 Title and Label Options ............................................................................................................ 67
         6.3 No Data Warning ...................................................................................................................... 72
         6.4 Color and Style Options ........................................................................................................... 73
         6.5 x-Axis Options ......................................................................................................................... 78
         6.6 y-Axis or Axes Options ............................................................................................................ 80
         6.7 Series Detail Options ................................................................................................................ 81
         6.8 Chart Legend Options .............................................................................................................. 82
     7 Adding Meter Widgets ..................................................................................................................... 85
         7.1 Adding a Meter Widget ............................................................................................................ 85
              7.1.1 Data Sources, Properties, and Meters ............................................................................ 86
         7.2 Specifying Widget Settings for a Meter ................................................................................... 86
         7.3 Meter Types .............................................................................................................................. 87
         7.4 Basic Meter Options ................................................................................................................. 90
         7.5 Customizing Speedometers ...................................................................................................... 91
         7.6 Customizing Text Meters ......................................................................................................... 96
         7.7 Customizing Fuel Gauges ........................................................................................................ 97
         7.8 Customizing Traffic Lights ...................................................................................................... 98
         7.9 Customizing Light Bars ........................................................................................................... 99
         7.10 Customizing Smiley Faces ................................................................................................... 101
     8 Adding Scorecard Widgets ............................................................................................................. 103
         8.1 Overview of Scorecards ......................................................................................................... 103
              8.1.1 One-Measure Pivot Tables in Scorecards ..................................................................... 103
         8.2 Adding a Scorecard Widget .................................................................................................... 104
         8.3 Specifying Widget Settings for a Scorecard ........................................................................... 104
         8.4 Adding Columns ..................................................................................................................... 105
         8.5 Configuring a Scorecard Column ........................................................................................... 106



iv                                                                                                                                      Creating Dashboards
             8.6 Specifying a Scorecard Formula ............................................................................................ 108
             8.7 Configuring a Column of Row Numbers ............................................................................... 109
             8.8 Configuring a Column of Row Labels ................................................................................... 109
             8.9 Configuring a Column of Values ............................................................................................ 109
             8.10 Configuring Trend Lines and Trend Bars ............................................................................. 110
             8.11 Configuring Plot Boxes ........................................................................................................ 111
             8.12 Configuring Arrows .............................................................................................................. 113
             8.13 Configuring Lamps .............................................................................................................. 114
             8.14 Customizing the Appearance of a Scorecard Widget ........................................................... 115
                 8.14.1 Size & Appearance Options ....................................................................................... 115
                 8.14.2 Title Options ............................................................................................................... 116
                 8.14.3 Colors & Style Options .............................................................................................. 116
       9 Adding Other Widgets .................................................................................................................... 123
           9.1 Adding a Calendar Widget ..................................................................................................... 123
           9.2 Adding a Map Widget ............................................................................................................. 123
               9.2.1 Configuring the infoWindow Popup ............................................................................ 125
           9.3 Adding a Widget That Uses a Portlet ..................................................................................... 125
           9.4 Adding a Controls Widget ...................................................................................................... 125
       10 Defining and Using Themes ......................................................................................................... 127
           10.1 Overview of Themes ............................................................................................................ 127
           10.2 Creating a New Theme Definition ....................................................................................... 128
           10.3 Adding Style Information to a Theme .................................................................................. 128
           10.4 Applying a Theme ................................................................................................................ 128
           10.5 Deleting a Theme ................................................................................................................. 129
       11 Adding Widget Controls ............................................................................................................... 131
           11.1 Adding a Control .................................................................................................................. 131
           11.2 Reconfiguring a Control ....................................................................................................... 133
           11.3 Adding an Explicit Filter Control ......................................................................................... 133
               11.3.1 Specifying a Default Value ......................................................................................... 134
           11.4 Adding an OnClick Filter Control ........................................................................................ 135
               11.4.1 Example: Listing with OnClick Filter ........................................................................ 135
           11.5 Adding a Refresh Control ..................................................................................................... 136
           11.6 Adding a Control to Print the Dashboard ............................................................................. 137
           11.7 Adding a Control to Reload the Dashboard ......................................................................... 137
           11.8 Adding a Control to Change the Display Type ..................................................................... 138
           11.9 Adding a Control to Change the Row or Column Sort ......................................................... 138
           11.10 Adding a Control to Change the Row or Column Count ................................................... 139
           11.11 Adding a Control to Change the Row or Column Specification ........................................ 139
               11.11.1 Variation: Providing a List of Choices ..................................................................... 140
           11.12 Adding a Control to Set a Pivot Variable ............................................................................ 140
           11.13 Adding a Control to Display a Different Pivot Table ......................................................... 141
               11.13.1 Variation: Providing a List of Choices ..................................................................... 141
           11.14 Adding a Control to Display a Listing ............................................................................... 142
           11.15 Adding a Control to Display the Pivot Analysis Window .................................................. 142
           11.16 Adding a Control to Display Another Dashboard .............................................................. 143
               11.16.1 Passing Values .......................................................................................................... 143
           11.17 Adding a Control to Display a Web Page ........................................................................... 144
           11.18 Adding a Control to Perform a Custom Action .................................................................. 144
               11.18.1 Specifying the Value of a Row ................................................................................. 145



Creating Dashboards                                                                                                                                         v
     11.19 Hiding a Control ................................................................................................................. 145




vi                                                                                                                             Creating Dashboards
1
Introduction to Dashboards
This page introduces dashboards in InterSystems IRIS® data platform Business Intelligence.
Also see Accessing the BI Samples.




1.1 Displaying Business Intelligence Dashboards
To access Business Intelligence dashboards from the Management Portal, click Analytics and then click User Portal.
Or use a supported browser (see Supported Web Browsers) and go to the following URL, using the <baseURL> for your
instance:

http://<baseURL>/csp/samples/_DeepSee.UserPortal.Home.zen

In either case, the right area then lists the available dashboards in this namespace. This area initially displays the items in
Covers View, as follows:




Creating Dashboards                                                                                                           1
Introduction to Dashboards




When you hover the cursor over a cover, the system displays an arrow on the cover, as follows:




If you click the cover arrow, the system displays the dashboard. If you have permission to do so, you can then edit the
dashboard.
For more information on using the User Portal, see Using Dashboards and the User Portal.




2                                                                                                    Creating Dashboards
                                                                                                           About Dashboards




1.2 About Dashboards
A dashboard typically includes multiple widgets and controls, as in the following example:




The left area of the dashboard displays two worklists. These are configurable areas you can use to display controls (such
as the filters shown in the upper worklist) and other useful items (such as the recent items list shown in the lower worklist).
(For information on using worklists, see Using Dashboards and the User Portal. For information on configuring them, see
Implementing InterSystems Business Intelligence.)
This example dashboard also includes two widgets, which are both pivot table widgets. Note that a pivot table widget can
display any kind of data source.
Dashboards can include other kinds of widgets, including meters and scorecards. A scorecard shows multiple rows of data
in a tabular format that also includes features such as value-dependent lamps and arrows. For example:




Creating Dashboards                                                                                                          3
Introduction to Dashboards




A meter shows one or more values in graphical objects like the following:




1.3 Location of Dashboard Definitions
When you create a dashboard, its definition is available within your IDE as a generated file with the extension .dashboard.dfi.
If you are using Visual Studio Code, you can access these pivot table definitions in the following ways:
•   Client-side editing: when a namespace is opened in the ObjectScript Explorer, view the .dfi files in the Other directory.
•   Server-side editing: modify your workspace filters so that they show generated files and include the desired .dfi files.

Pivot table definitions and other Business Intelligence folder items are accessible in the same manner.
These definitions are not class definitions but can be copied and pasted into a special container class for easier deployment.
For details, see Packaging Business Intelligence Elements into Classes.




4                                                                                                       Creating Dashboards
2
Creating and Modifying Dashboards
This page describes how to create and edit Business Intelligence dashboards.
For information on customizing covers for dashboards, see Using Dashboards and the User Portal.




2.1 Introduction to the Autosave Feature
The system provides an optional autosave feature, which can automatically save the state of the User Portal for each user,
for each dashboard. If the autosave feature is enabled for the User Portal:
•    When you access the User Portal, the system displays that user interface as you last saw it.
•    When you display a dashboard, the system displays that dashboard as you last saw it.

For information on this option, see Specifying Basic Settings. Note that there is a separate autosave feature for the Analyzer.




2.2 Creating a Dashboard
To create a dashboard, use the following overall process:
1.   Log in to the User Portal in the desired namespace, as described earlier.
2.   Click Menu > New Dashboard.


     Or click the Add button       , which is above the list of dashboards, as follows:




     Then click Add Dashboard.
     Or click the < button at the left side of the User Portal, click Add, and then click Add Dashboard.
     In any case, the system then displays a dialog box that prompts you for basic information about the new dashboard.
3.   For Folder, optionally type a folder name or select an existing folder.
     Also see Preparing for Folder Item Localization.



Creating Dashboards                                                                                                          5
Creating and Modifying Dashboards


4.   For Dashboard Name, type the name of the dashboard.
     Also see Preparing for Folder Item Localization.
     Note that this name is used (along with Folder) as the logical name of the dashboard; the system displays this logical
     name when you use the Save As option, for example.
5.   Optionally provide values for the other options as given in the next section.
6.   Click OK.
     The system creates, saves, and displays the dashboard, which is initially empty.
7.   To configure the dashboard, use a combination of the following tools:
     •   The Dashboard Editor. For an introduction, see Modifying Dashboard Settings.
     •   The Menu. For an introduction, see Adding a Widget to a Dashboard.




2.3 Modifying Dashboard Settings
To modify settings of a dashboard or of the widgets in a dashboard:
1.   Display the dashboard as described in Accessing Business Intelligence Dashboards.
2.   Click the > button to the left of the dashboard. (If this button is not visible, either the dashboard is not editable or you
     do not have permission to edit it.) The following shows an example:




6                                                                                                         Creating Dashboards
                                                               Modifying Dashboard Settings




    The system then expands the Dashboard Editor as follows:




Creating Dashboards                                                                      7
Creating and Modifying Dashboards




     To hide the Dashboard Editor, click the < button.
3.   Click Dashboard Settings.
4.   Specify any of the following options as needed:
     •   Locked — Select this option to temporarily prevent changes to this dashboard. If you select this option, you cannot
         edit the dashboard again unless you first clear the Locked option again.
     •   Public — Select this option to control whether this dashboard is displayed in the User Portal main area.

         Important:       This option does not control access to the dashboard. Access is controlled instead by the Owner
                          and Resource options, discussed later in this list.

         Note that even if the dashboard is not marked as public, you can access it via Main > Open. Also, you can find it
         in the User Portal by using the Find option. See Using Dashboards and the User Portal.
     •   Page Settings > Company Name — Specify a name to display in the upper right corner. For example:




     •   Page Settings > Company Logo — Select an image to display in the upper right corner. For example:




8                                                                                                     Creating Dashboards
                                                                                                Modifying Dashboard Settings


        If you specify this option, Page Settings > Company Name is ignored.
    •   Title — Specify the title of the dashboard.

        If you specify a title, the main area of the User Portal displays the title of the dashboard. Otherwise, it displays
        the name of the dashboard.
        Also see Preparing for Folder Item Localization.
    •   Owner — Specify the InterSystems IRIS® data platform user who owns this dashboard. If a dashboard has an
        owner, then only the owner can specify the Resource option for the dashboard; see the next item.
    •   Resource — Specify the resource that is used to control access to this dashboard. See Visibility of Folders and
        Folder Items.
    •   Category — Specify the category to which this dashboard belongs. The User Portal uses this to group items in the
        Covers View. See Using Dashboards and the User Portal.
    •   Description — Briefly describe the dashboard.

    •   Keywords — List any keywords or phrases to help you find this dashboard later. Specify a comma-separated list
        of keywords or phrases.
        These keywords are displayed in the User Portal.
    •   Resize — Select this option to control whether users can move and resize the widgets on the dashboard.

    •   Modify — Select this option to control whether users can modify the widgets on the dashboard.

    •   Title Bars — Use this submenu to control the display of title bars on the widgets on this dashboard. You can also
        customize their appearance. This submenu has the following options:
        –   Title Bars — Select ON or OFF.

        –   Title Bar Color — Select a color to use for the title bar, to be used by default.

        –   Title Bar Opacity — Specify the opacity of the title bar, to be used by default. The value 1 means 100%.

        –   Text Color — Select a color for the text of the title bar, to be used by default.

        –   Selected Color — Select a color to use for the title bar, to be used when the widget is selected.

        –   Selected Opacity — Specify the opacity of the title bar, to be used when the widget is selected. The value 1
            means 100%.
        –   Selected Text Color — Select a color for the text of the title bar, to be used when the widget is selected.

        –   Font — Select the typeface to use for the text in the title bar.


    •   Widget borders — Use this option to hide or display borders on all widgets.

    •   Work Lists — Specify the number of worklists in the dashboard. Note the following defaults:

        –   In a two-worklist dashboard, by default, the top worklist is the Filters box, and the bottom worklist is the
            Favorites/Recent items box.

        –   In a one-worklist dashboard, by default, the worklist is the Filters box.

    •   Background — Use this submenu to specify the background of the dashboard. This submenu has the following
        options:
        –   Background Color — Select the background color. Note that this color is used only if

        –   Background Image — Select an optional background image. If you choose an image, the Background Color
            option is ignored.




Creating Dashboards                                                                                                            9
Creating and Modifying Dashboards


         –    Background Opacity — Specify the opacity of the background color or background image (whichever is used).
              The value 1 means 100%.

     •   Scalable Grid, Grid Rows, and Grid Columns — Use these options to specify the position and size of all widgets
         relative to a resizeable grid.
         If you enable the Scalable Grid option, when you move a widget, the upper left corner of widget aligns to the
         nearest grid point. Similarly, when you resize a widget, the lower right corner aligns to the nearest grid point. Use
         the Grid Rows and Grid Columns options to specify the grid. Note that the grid itself is not displayed.
         If you resize the dashboard, all the widgets are automatically resized. Scalable Grid is the only option that supports
         this resizing behavior.
     •   Snap Into Place — Use this option to control how widgets are placed on the dashboard. If you clear this option,
         you can position widgets freely anywhere on the dashboard, even overlapping each other. If you select this option,
         the system automatically aligns the widgets next to each other or below each other.
         This option is available only if you clear the Scalable Grid option.

     For details on the other parts of the Dashboard Editor, see the following articles:
     •   Adding Pivot Table Widgets
     •   Adding Chart Widgets
     •   Adding Meter Widgets
     •   Adding Scorecard Widgets
     •   Adding Other Widgets
     •   Adding Widget Controls

     In some cases, the changes are saved automatically.
     In other cases, the system does not save the changes automatically. In these cases, it displays an indicator like the fol-
     lowing as a reminder:




     In such cases, save the dashboard as described in Saving a Dashboard.




2.4 Adding a Widget to a Dashboard
To add a widget to a dashboard, use the following general procedure:
1.   Display the dashboard as described in Displaying Business Intelligence Dashboards.
2.   If you make unrelated changes to the dashboard, and if you want to keep those changes, save them.
     When you add a widget, the Dashboard Designer saves the dashboard with the newly added widget but discards other
     unsaved changes.
3.   Do one of the following:



10                                                                                                      Creating Dashboards
                                                                                                 Overview of Widget Types


     •   Click Menu > Add New Widget... — Use this option to add a new widget that does not include any configuration
         details.
     •   Click Menu > Add Widget from Catalog.... — Use this option to reuse a configured widget that you previously saved
         to the widget catalog.
         You can reconfigure this widget, if needed; you can change any detail except for the widget type. However, you
         generally use this option when you have saved widgets that are already configured in common ways for your
         needs.
     •   Display the Dashboard Editor, click Widgets, and then click the plus sign button.

     The system then displays a wizard where you select a widget and specify basic information for it.
4.   Navigate to a widget type and (if applicable) subtype.
5.   (For most types of widgets) Optionally specify of the following items:
     •   Data Source — Select the data source for this widget. See Names of Data Sources and Kinds of Data Sources.

     •   Link to — Select another widget on this dashboard to use as the source. See Linked Widgets.


     Or specify a data source later, as described in Specifying the Data Source for a Widget.
6.   Specify a name for Widget Name. Note that each dashboard widget must have a name.
7.   Click OK to add the widget to your dashboard.
8.   Optionally configure the widget. For information on specific types of widgets, see the following articles:
     •   Adding Pivot Table Widgets
     •   Adding Chart Widgets
     •   Adding Meter Widgets
     •   Adding Scorecard Widgets
     •   Adding Other Widgets

9.   Optionally add controls to the widget. See Adding Widget Controls.




2.5 Overview of Widget Types
This section provides an overview of widget types.


2.5.1 Widget Types and Subtypes
After you add widgets, you can reconfigure them in any way other than modifying their type. Note that you can modify
the subtype, if applicable. The system provides the following widget types and subtypes:
•    Pivot table widgets. This type of widget includes the table subtype and many chart subtypes.
     Because there are so many chart options, charts are discussed separately from tables.
•    Meter widgets. This type of widget includes many meter subtypes.
•    Scorecard widgets. This type of widget includes two subtypes: regular and big.
•    Calendar widgets. This type of widget includes one subtype.



Creating Dashboards                                                                                                    11
Creating and Modifying Dashboards


•      Map widgets. This type of widget includes one subtype.
•      Portlet widgets. The subtypes include any portlets that you define.
•      Controls widgets. This type of widget includes two subtypes: horizontal and vertical.


2.5.2 Comparison of Widget Types
For reference, the following table compares the key features of widgets, across the different widget types:

    Widget Type                  Possible Data Sources                   Print     Export to   Mini            Drilldown
                                                                         Option?   Excel       Analyzer        Option?
                                                                                   Option?     Option?
    pivot table widget           pivot table, KPI, or production         Yes       Yes         Yes
                                                                                                    *
                                                                                                               Yes
                                                                                                                    *
                                 business metric
    meter                        pivot table, KPI, or production         Yes       No          Yes
                                                                                                    *          No
                                 business metric
    scorecard                    pivot table, KPI, or production         Yes       No          Yes
                                                                                                    *          No
                                 business metric
    calendar                     none                                    No        No          No              No
    map                          pivot table, KPI, production            No        No          Yes
                                                                                                    *          No
                                 business metric, or no data
                                 source
    controls widgets             pivot table, KPI, production            No        No          No              No
                                 business metric, or no data
                                 source

*
    This option is available only if the data source is a pivot table.
For a portlet, all these details depend upon the implementation.




2.6 Reconfiguring a Widget
When you reconfigure this widget, you can change any detail except for the widget type. To select and reconfigure a widget
on a given dashboard:
1.     Display the dashboard as described in Displaying Business Intelligence Dashboards.
2.     Display the Dashboard Editor.
3.     Click Widgets.
       The system then displays a list of the widgets in the dashboard.




12                                                                                                      Creating Dashboards
                                                                                                     Reconfiguring a Widget




4.   Click the name of the widget in this list. This action selects the widget.
     The system then displays a list of settings that you can modify. In most cases, the list includes submenus. The following
     shows a partial example:




5.   Optionally specify the following settings, which all widgets have:
     •   Name — Specify a name for internal use within this dashboard. One widget can refer to other widgets (for example,
         to filter another widget). For these names, you might want to establish a set of naming conventions, for your con-
         venience.
     •   Title — Specify any text to display in the title bar of the widget.

         Note that the dashboard can be configured to hide all title bars; see Modifying Dashboard Settings.
     •   Toolbar — Configure the toolbar for this widget. See the first subsection for details on this submenu.

     •   Sidebar — Configure optional sidebar text for this widget. See the second subsection for details on this submenu.


     The other submenus list additional items, depending on the kind of widget you select. For information, see the following
     articles:
     •   Adding Pivot Table Widgets
     •   Adding Chart Widgets
     •   Adding Meter Widgets



Creating Dashboards                                                                                                        13
Creating and Modifying Dashboards


     •   Adding Scorecard Widgets
     •   Adding Other Widgets
     •   Adding Widget Controls



2.6.1 Toolbar Settings
Use this submenu to configure the toolbar for the widget. Specify the following options:
•    Toolbar — This option enables or disables the toolbar. Select ON or OFF.

     When the toolbar is enabled, the system displays it if the widget is configured with any buttons or any controls that
     require it (but see the Show Maximized option). If the widget has none of these, the system does not display the toolbar.
     When the toolbar is disabled, the system never displays the toolbar.
     InterSystems recommends that you specify Toolbar as ON.
•    Bottom Border — This option displays or hides the bottom border of the toolbar. Select ON or OFF.




•    Show Maximized — If this option is ON, the system displays the toolbar only when the widget is maximized.

•    Toolbar Color — Select the color to use for the background of the toolbar. Or click X to restore the default color.




•    Toolbar Opacity — Use this option to specify the opacity of the toolbar. The default is 1 (which is 100%).



2.6.2 Sidebar Settings
Use this submenu to configure optional sidebar text for the widget, which is displayed in a rectangle on the right side of
the widget, as in the following example:




14                                                                                                     Creating Dashboards
                                                                                   Specifying the Data Source for a Widget




Specify the following options:
•    Sidebar — This option enables or disables the sidebar. Select ON or OFF.

•    Sidebar Content — Type the text to be displayed in the sidebar. You can include simple HTML markup such as the
     <p> and </p> tags, the <br> tag, the <i> and </i> tags, and the <b> and </b> tags.
     If you enclose text in the <p> and </p> tags, that text is automatically wrapped as shown in the preceding example.
•    Sidebar Width — Specify the width of the sidebar. Specify either a number (which is interpreted as the width in pixels)
     or a number followed by % (which is interpreted as a percentage of the width of the entire widget).




2.7 Specifying the Data Source for a Widget
To specify the data source for a widget:
1.   Access the Dashboard Editor and select the widget as described in Reconfiguring a Widget.
2.   Click Type & Data Source.
     The system then displays the Type and Data submenu.




Creating Dashboards                                                                                                      15
Creating and Modifying Dashboards




3.   Specify one of the following options:
     •   Data Source — Select the data source for this widget. See Names of Data Sources and Kinds of Data Sources.

     •   Link to — Select another widget on this dashboard to use as the source. See Linked Widgets.

     •   Drilldown Target — This option enables the user to double-click a cell and access another dashboard. The newly
         opened dashboard is filtered by the context in which the user double-clicked. For example, if the user double-
         clicks in a cell that shows data for a specific city, the newly opened dashboard is filtered to that city.

         To use this option, click the Search button    , click a dashboard, and click OK.

     Note that the Widget Type option enables you to choose a different widget subtype; it does not let you choose a type.
     See Widget Types and Subtypes, earlier in this page.

The following subsections provide details.


2.7.1 Names of Data Sources
When you specify the data source for a widget, you refer to that data source by name. This logic simplifies the process of
deploying dashboards and pivot tables to end users. But it also means that if you rename items, you must update any
dashboards that use those elements.
When you open a dashboard, if the system cannot find a data source that it uses, the system displays as much of the dashboard
as possible. For example:




16                                                                                                     Creating Dashboards
                                                                                        Specifying the Data Source for a Widget




2.7.2 Kinds of Data Sources
With exceptions noted below, a dashboard widget can display data from any of the following data sources:

    Data source                                         Where created              For information, see
    Pivot tables                                        Analyzer                   Using the Analyzer
    Detail listings
    KPIs (key performance indicators)                   IDE                        Implementing InterSystems Business
                                                                                   Intelligence
    production business metrics (available only         IDE                        Developing Productions
    in an interoperability-enabled namespace)


Exceptions:
•     A detail listing can be displayed only in a pivot table widget (in table mode).

The kind of data source does not affect the appearance of the widget; for example, the user cannot tell if a given chart is
displaying data from a pivot table, a KPI, or a business metric.
Note that some kinds of widgets do not use data sources.


2.7.3 Linked Widgets
When you specify the Link to option for a widget, you configure that widget as a dependent widget that is linked to another
widget (an independent widget). The following rules govern linked widgets:
•     One independent widget can be linked to any number of dependent widgets in the same dashboard.
•     You cannot chain widgets; that is, Link to must be an independent widget rather than another dependent widget.
•     When you drill down on a row in the independent widget, the system also drills down in the dependent widgets.
•     If you filter the independent widget, the system also filters the dependent widgets. Any filters on the dependent widgets
      are ignored.
•     If you use the Mini Analyzer to redefine the independent widget, the system also redefines the dependent widgets.




Creating Dashboards                                                                                                         17
Creating and Modifying Dashboards




2.8 Saving a Widget to the Widget Catalog
You can copy a widget (including all its configuration details) to the widget catalog. To do so:
1.   Display the dashboard that contains the widget. See Displaying Business Intelligence Dashboards.
2.   Display the Dashboard Editor.
3.   Access the Dashboard Editor and select the widget as described in Reconfiguring a Widget.
4.   Click Menu > Save Widget to Catalog ... .
     The system displays a dialog box in which you specify details for the widget in the catalog.
5.   Specify Folder, Widget Name, and other options. For information, see Adding a Widget to a Dashboard.
6.   Click OK.
     If you have already saved a widget with this name, in the given folder, the system prompts you to confirm that you
     want to overwrite the previously saved widget.
7.   Click OK.
     No change is made to the dashboard itself.

The saved copy does not include any local overrides. That is, if you have customized the pivot table by using the Mini
Analyzer, those customizations are not included in the widget catalog.




2.9 Removing a Widget from a Dashboard
To remove a widget from a dashboard:
1.   Display the Dashboard Editor.
2.   If you make unrelated changes to the dashboard, and if you want to keep those changes, save them.
     When you remove a widget, the Dashboard Designer automatically saves the dashboard, now without the removed
     widget. In this step, the Dashboard Designer discards other changes that you made and did not save.
3.   Click Widgets.
4.   Click the X button next to the widget name. The change is saved automatically.




2.10 Clearing the Autosave State of a Dashboard
If the autosave feature for the User Portal is enabled, then when you display a dashboard, the User Portal displays that
dashboard with any unsaved changes that you might have made. To remove these unsaved changes, click Menu > Clear
Autosave State. Then the User Portal displays the dashboard as defined in its saved definition.

Or save the dashboard, thus saving the changes and changing the definition. See the next topic.




18                                                                                                   Creating Dashboards
                                                                                                         Saving a Dashboard




2.11 Saving a Dashboard
To save the dashboard you are working on, do one of the following:
•    Click Save.




     The system saves the dashboard immediately.
•    Click Menu > Save.
     The system saves the dashboard immediately.
•    Click Menu > Save With Options....
     Specify some or all of the following options and then click OK:
     –   Folder — Specify the folder, if any, to which the dashboard belongs. Either type a folder name or select an existing
         folder. If desired, use the slash character (/) to specify a subfolder. For example, you can enter the following for
         Folder:

         My Folder/My Subfolder

         Do not start the first folder name with a dollar sign ($); if you do, the dashboard definition is accessible only in
         your IDE.
     –   Dashboard Name — Specify the name of the dashboard.


     For information on the other options, see Modifying Dashboard Settings, earlier in this page.

Or use Menu > Save As.... See the next section.




2.12 Copying a Dashboard
To copy a dashboard, do the following:
1.   Display the dashboard as described in Displaying Business Intelligence Dashboards.
2.   Click Menu > Save As....
3.   Specify the options as described in the previous section (and in Modifying Dashboard Settings)
4.   Click OK.




Creating Dashboards                                                                                                         19
Creating and Modifying Dashboards




2.13 Deleting a Dashboard
One way to delete a dashboard is as follows:
1.   Display the dashboard as described in Displaying Business Intelligence Dashboards.
2.   Click Menu > Delete Dashboard.
     The system prompts you to confirm.
3.   Click OK.

Note:     When you delete a dashboard, the system moves it into a folder named $TRASH, which the User Portal does not
          display.


2.13.1 Deleting a Dashboard in the User Portal
You can also delete a dashboard in the User Portal.
•    If the User Portal is in Covers View, click the dashboard cover and then click the X in the dialog box. Then click OK
     to confirm.
•    If the User Portal is in List View, click the X button in the row that lists the dashboard. Then click OK to confirm.

The User Portal does not display private dashboards. To delete a private dashboard, you must change it to be public and
then delete it; see Modifying Dashboard Settings. Or delete the dashboard in the Folder Manager, which displays all items
(both public and private); see Introduction to the Business Intelligence User Interfaces.




20                                                                                                      Creating Dashboards
3
Specifying Common Widget Options
This page describes options that are used in multiple places when you configure widgets on Business Intelligence dashboards.




3.1 Customizing Print Settings for a Widget
You can print most kinds of widgets. To customize how the system prints a widget, access the Dashboard Editor, select
the widget as described in Reconfiguring a Widget, and click Print Setup and then click Page Setup. You can modify the
following options:
•   Reset — Click this to restore the default print settings for this widget.

•   Page Size — Specify the size of the pages. Choose a page size.

•   Units — (Read only) This field displays the units associated with the page size you selected.

•   Orientation — Specify the orientation of the pages.

•   Title — Specify an optional title to include in the PDF. See the first subsection for special options.

•   Subtitle — Specify an optional subtitle to include in the PDF. See the first subsection for special options.

•   Show Subtitle — Click On to include the subtitle in the PDF. Or click Off not to include the subtitle.

•   Listing Settings — Select this to access additional options that apply when the output is a detail listing. Then specify
    options as described in the subsection Listing Settings.
•   Filter Settings — Select this to access options that control the appearance of information about any filters applied to
    this pivot table. Then specify options as described in the first subsection.
•   Show Date — Click On to include the current date in the PDF, at the top of the first page. Or click Off to omit this
    information.
•   Show User — Click On to include the current user in the PDF, at the top of the first page. Or click Off to omit this
    information.
•   Page Margins options: Top, Bottom, Left, and Right — Specify the size of the top, bottom, left, and right margins,
    respectively.

Note that the Title, Subtitle, and Show Date options apply to Excel Export as well.




Creating Dashboards                                                                                                        21
Specifying Common Widget Options



3.1.1 Requirements for Printing
When a user invokes the Print option, InterSystems IRIS uses Java to call out to a third-party PDF rendering tool. This
means that Java (or specifically JRE, Java Runtime Environment) is required on the server accessed by the user’s local
machine. For information on the requirements, see Configuring InterSystems IRIS for PDF Output.


3.1.2 Special Options for the Title and Subtitle
Within the Title and Subtitle fields, you can include a combination of static text and the following tokens:
•    {@filter.filterName} where filterName is the name of a filter defined for the given widget. Use the same name
     as provided in the Filter dropdown menu in the Dashboard Designer.
     In the PDF, this token is replaced with the current value of that filter.
•    {@date.dateFormat} where dateFormat is an integer date format, with the same meaning as the dformat argument
     of $ZDATETIME.
     In the PDF, this token is replaced with the date in the given format, followed by the time in 24–hour format.
•    {@variable.variableName} where variableName is the name of a runtime variable.

     In the PDF, this token is replaced with the current value of that variable.


3.1.3 Listing Settings
For Listing Settings, specify some or all of the following options, which take effect when the output is a detail listing:
•    Show Listing Filters — Click On to include information on the context used for the detail listing (that is, which member
     or members were selected before the listing was requested, as well as any filters that were in use). Or click Off to omit
     this information.
•    Show Zebra Stripes — Click On to use different colors for alternating rows. Or click Off to use the same color for all
     rows.
•    Font Size — Specify the font size, including units, for example: 6pt



3.1.4 Filter Settings
For Filter Settings, specify some or all of the following options, which control the presentation of the filter information:
•    Show Filters — Specify the presentation of the filter information. Select By Table (to display this information as a table
     on the top of the first page), By Title (to display this information as the subtitle or appended to the subtitle), or Off (to
     not display this information).
     By default, the filter information is appended to the subtitle area to the right of any specified subtitle.
     When you display filter information as a table, the table has two columns with level names (that is, the filter names)
     on the left and member names (that is, filter item names) on the right.
•    Table Style — Specify options to control the appearance of the table that is used to display the filter information.

     These options affect both the caption column (the left column) and the item column (the right column).
•    Row Header Style — Specify options to control the appearance of the row headers. These options override the Table
     Style options.




22                                                                                                         Creating Dashboards
                                                                                                   Adding Widget Properties


•    Item Style — Specify options to control the appearance of the item column. These options override the Table Style
     options.
•    Display Format for NOW — Specify how to display the NOW member of any time level, if that member is used in the
     filter and if the filter information is shown. Specify any of the dformat options of the $ZDATE function. For example,
     specify 3 for ODBC format (for example, 2015-03-27).
     If you leave this option blank, the PDF shows the NOW member as NOW.




3.2 Adding Widget Properties
Some kinds of widgets require properties, each of which typically corresponds to a value in the configured data source.
(For example, if the data source is a pivot table, each property of the widget can be a measure in that pivot table.)
For a meter widget, each property is displayed in a separate meter within the widget. Similarly, for pivot table widgets,
each property is displayed as a separate column. Scorecards have columns, which are similar to properties and can be
configured in a similar way.
To add a property to a widget:
1.   Access the Dashboard Editor and select the widget as described in Reconfiguring a Widget.
2.   Click Data Properties.
     The system displays the Data Properties submenu, which lists any properties defined for this widget. For example:




3.   Click the plus sign + button.
     The system displays a dialog box where you specify the property.
4.   For Value, select the property of the data source to display.
     For a meter widget or a scorecard, you can instead type a numeric constant.
     If you manually edit Value, note that if Value has a numeric value, the system assumes it is a numeric constant and
     displays that. If Value has the form =[propertyname], the system assumes it is a property of the data source and thus
     displays the value of that property. When you select a property, the system automatically wraps the property with =[].
     For a scorecard, you can instead type a formula.
5.   Optionally specify the following additional items:
     •   Label — Type a label or optionally click the check box to the right of Label. If you click the check box, the system
         uses the localized name of this property as the label; this option applies only when Value is a data source property.
         If you type a label, note that you can include \n to force a line break in the label.
     •   Hidden — Select this option to hide this value.




Creating Dashboards                                                                                                         23
Specifying Common Widget Options


     •   Value Column — Select this option to configure the value in this column as the value of the row. This value is
         passed to any custom actions; see Specifying the Value of a Row.
         Select this option for only one data property of the widget.
     •   Format — Type a format string.


     Or specify these options later if you modify the property as described in the next section.
6.   Click OK.




3.3 Managing Widget Properties
For any widget that defines properties, the Data Properties submenu lists the properties defined for this widget. For example:




In addition to the specific property options documented elsewhere, you can perform the following general activities:
•    Change the order of the properties. To do so, first click the icon to the left of the property name, so that this icon is

     highlighted:
     Then drag the property up or down in the list.
•    Delete a property. To do so, click the X button in the row for that property.
•    Reconfigure a property. To do so, click the property name. The system then displays a submenu with options. For
     details on the options, see the previous section. You can also specify Name. Make changes as needed.




3.4 Specifying Numeric Format Strings
In some meters and other places that display numeric values, you can use the Format option to control the display of numbers.
In some cases, you can select an option or type a numeric format string. In other cases, you must type a numeric format
string.


3.4.1 Selecting a Format String
In some cases, the Dashboard Editor provides the following set of choices for Format:




24                                                                                                        Creating Dashboards
                                                                                            Specifying Numeric Format Strings


    Option               Example
    ###                  6609
    ###.#                6609.1
    ###.##               6609.12
    ###.###              6609.123
    #,##                 6,609
    #,##.#               6,609.1
    #,##.##              6,609.12
    #,##.###             6,609.123
    ##.##%               660912.3%



3.4.2 Typing a Numeric Format String
In all applicable places, you can instead type a numeric format string, which provides more options. You can specify a
string that consists of one to four pieces as follows:

positive_piece;negative_piece;zero_piece;missing_piece

Where positive_piece controls how a positive value is displayed, negative_piece controls how a negative value is displayed,
zero_piece controls how zero is displayed, and missing_piece controls how a missing value is displayed.
Each piece is a string that includes one of the following base units:

    Base Unit         Meaning                                                                                      Example
    #                 Display the value without the thousands separator and without decimal places.                12345
    #,#               Display the value with the thousands separator. Do not include any decimal                   12,345
                      places. This is the default display format for positive numbers.
    #.##              Display the value without the thousands separator. Include two decimal places                12345.67
                      (or one decimal place for each pound sign after the period). Specify as many
                      pound signs after the period as you need.
    #,#.##            Display the value with the thousands separator. Include two decimal places (or               12,345.67
                      one decimal place for each pound sign after the period). Specify as many pound
                      signs after the period as you need.


You can include additional characters before or after the base unit.
•       If you include a percent sign (%), the system displays the value as a percentage. That is, it multiplies the value by 100
        and it displays the percent sign (%) in the position you specify.
•       Any other characters are displayed as given, in the position you specify.

The following table shows some examples:




Creating Dashboards                                                                                                           25
Specifying Common Widget Options


 Example                                                                       Logical Value          Display Value
 #,#;(#,#)                                                                     6608.9431              6,609
 This corresponds to the default display of numbers.
                                                                               –1,234                 (1,234)
 #,#.###                                                                       6608.9431              6,608.943
 #%;                                                                           6                      600%
 $#,#;($#,#)                                                                   2195765                $2,195,765
                                                                               –3407228               ($3,407,228)



3.4.3 Localization of Numeric Separators
Conventions regarding the use of specific numeric separators vary by locale. For example, within the United States, the
comma , is used as the thousands separator, while the period . is used as the decimal separator. In many European countries,
the period . is used as the thousands separator, while the comma , is used as the decimal separator.
This localization is applied automatically by InterSystems IRIS in accordance with your chosen instance locale; consequently,
the formatting syntax for numeric strings is locale agnostic. Consider the following example.
In the bar chart widget depicted below, the Value Format in the bottom left corner is set to #,#.###, which causes the
chart to use thousands separators and show three decimal places.




26                                                                                                     Creating Dashboards
                                                                                      Specifying Numeric Format Strings




This same widget, with an identical Value Format string, will display the chart with European-style separators when the
instance locale is set to one of the relevant European locales, as seen in the following image:




Creating Dashboards                                                                                                   27
Specifying Common Widget Options




In order to leverage this automatic localization, ensure that you follow the instructions for selecting a locale described in
Locale Definitions.




28                                                                                                      Creating Dashboards
                                                                                                 Specifying Table Text Styles




3.5 Specifying Table Text Styles
In tables and chart legends, you can specify options that control the display of text. The options are as follows:
•   Color — Specify the color of the text. The following shows an example of the user interface:




    To specify a color, optionally choose the name of a color palette from the drop-down list. (For example, the list option
    Standard corresponds to the color palette shown in the preceding example.) Then click a color in the grid to choose
    that color.
    Or click the magnifying glass icon, which displays a full-range color chooser. Click a color here or use the sliders to
    specify the red, green, and blue components of your color selection.
    To clear the color selection, click the X.

    Tip:        An authorized user can add custom color palettes. See Creating Custom Color Palettes.

•   Background — Specify the color of the background, in the same way as described in the previous item.

•   Opacity — Use this option to specify the opacity of the background. The value 1 means 100%.

•   Font — Specify the typeface of the text. Select a typeface. To clear the typeface selection, click Default, at the top of
    the list.
•   Font Size — Use the slider to specify the size of the text or type a value into the input box.




    To clear the size selection, click the check box.
•   Text Style — Specify the style of the text.




    Select one or more options. The first three options make the text bold, italic, and underlined, respectively. The Cc
    option changes the text to capital letters as in the following example:
    The S option adds shadows to the text as follows:




Creating Dashboards                                                                                                        29
Specifying Common Widget Options




•    Align — Specify the alignment of the text.




     These options make the text left-aligned, centered, and right-aligned, respectively.




3.6 Specifying Chart Text Styles
In charts and other graphical elements, you can specify options that control the display of text. The options are as follows:
•    Color — Specify the color of the text. For information on specifying this option and other color options, see the Color
     option in the previous section.
•    Stroke — Specify the color of the outline of the characters in the text. The following figure shows an example where
     Color is blue and Stroke is black:




     By default, the system uses the same color for the outline as for the text itself.
•    Stroke Width — Use this option to specify the width of the outline. The following shows an example of a medium-
     width outline:




     To clear the setting, click the check box.
•    Opacity — Use this option to specify the opacity of the text (which is 100% by default).

•    Font, Text Size, Text Style — See Font, Font Size, Text Style in the previous section.




3.7 Specifying Line Styles
In numerous places, you can specify options that control the display of lines and other graphical elements. The options are
as follows:
•    Fill — Specify the color to use within the graphical element. This option applies to line markers and to parts of
     speedometers, for example. For information on specifying this option and other color options, see the Color option in
     Specifying Table Text Styles, earlier in this page.
•    Opacity — Use this option to specify the opacity of graphical element (which is 100% by default).

•    Line — Specify the color of the line that outlines the graphical element.




30                                                                                                     Creating Dashboards
                                                                                  Specifying Line Styles


•   Line Width — Use this option to specify the width of the line.

•   Line Style — Specify the style of the line. Click Solid, Dashed, or Dotted.




Creating Dashboards                                                                                  31
4
Adding Pivot Table Widgets
This page describes how to add pivot table widgets to a Business Intelligence dashboard. These widgets can display any
kind of data source, not just pivot tables.
For information on creating pivot tables, see Using the Analyzer.
Note that chart widgets are a kind of pivot table widget. For specific information on charts, see Adding Chart Widgets.




4.1 Adding a Pivot Table Widget
To add a pivot table widget:
1.   Click Menu > Add New Widget....
2.   Click Pivots and Charts.
3.   Click Table.
4.   For Data source, do one of the following:
     •
         Click the Search button       and then select a data source
     •   Use the Link to drop-down list to select another widget on the same dashboard.

     You can use any type of data source, not just pivot tables.

     Note:    If you do use a pivot table as the data source, note that pivot tables are created in the Analyzer, discussed in
              Using the Analyzer. The Analyzer provides options for changing the state of the pivot table: filtering, drilling
              down, displaying listings, and displaying in chart format. When you save a pivot table, the system saves the
              state as part of the pivot table definition. The next time the pivot table is accessed (either in the Analyzer or
              in a widget on a dashboard), the system displays the pivot table in the state in which it was saved.

5.   Optionally specify the basic settings, as described in Adding a Widget to a Dashboard.
6.   Click OK.
7.   Optionally configure the widget further as described in the rest of this page.
8.   Optionally add controls, as described in Adding Widget Controls.




Creating Dashboards                                                                                                         33
Adding Pivot Table Widgets




4.2 Specifying Widget Settings for a Pivot Table Widget
To customize the available options in a widget, access the Dashboard Editor, select the widget as described in Reconfiguring
a Widget, and then click Widget Settings. This menu primarily provides options for the user.
For a pivot table widget (including any chart widget), the Widget Settings menu has the following options:
•
     Print — Select this option to include the Print button       on the toolbar. This button enables users to print the widget
     to a PDF file. For further details and requirements, see the section Customizing Print Settings for a Widget.
•    Chart Toggle — Select this option to add buttons to the toolbar that can toggle the display to show either the chart or
     the equivalent pivot table. Select chart to set the initial state as a chart, select table to set the initial state as a pivot
     table, or select none to disable the toggle button.
•
     Drill Down — Select this option to include the Drill Down button             on the toolbar. This button enables the users to
     drill down.
     This option is supported only when the data source is a pivot table. The option is useful only when the rows of the
     pivot table display members of a higher level in a hierarchy.
•
     Analyzer — Select this option to include the Mini Analyzer button               on the toolbar. This button enables the users
     to open the data source in the Mini Analyzer.
     This option is supported only when the data source is a pivot table.
•
     Excel Export — Select this option to include the Export button               on the toolbar. This button enables the users to
     export the data in this widget to Microsoft Excel.
•    Row selection — Use this option to display check boxes on the widget; the user can use these check boxes to select
     rows to which to apply actions. Select single to enable the user to select only a single row, or multi to enable the user
     to select multiple rows.
     By default, these check boxes are not displayed, and the user cannot select rows in the widget. (The user can always
     select cells and ranges of cells in the widget.)
     This option is supported only when the data source is a KPI.
•
     Show Dimensions — Select this option to include the Dimension List button           on the toolbar. This button provides
     an extra drilling option. Users can drag and drop items from this list on the gray part of the rows in the pivot table;
     when they do, the system drills down as requested.
     This option is supported only when the data source is a pivot table and the widget is in table format.

     Note:     When you enable or disable this option, the Dashboard Designer automatically saves the dashboard.

•    Dimension Source — For advanced use, this option enables you to specify an alternative set of drill options to show
     in the dimension list.
•    Initial Execute — By default, this option is selected, which means that the system executes the query underlying this
     widget as soon as the user displays the dashboard. Clear this option if you want execute the query later. If you clear
     Initial Execute, make sure to include a refresh control on this widget. See Adding Widget Controls.




34                                                                                                             Creating Dashboards
                                                                            Customizing the Columns (When Displaying a KPI)


•    Pivot Preview — If enabled, this option uses the HEAD function to truncate the results of any query the widget makes
     involving a CROSSJOIN. Selecting the Show All button displays the full result set. By default, this option is disabled;
     users experiencing long load times can enable it.

Note:     Most of these options add a button to the toolbar. If you enable any of those options, be sure the toolbar is visible
          (its display is controlled via the Toolbar option in Settings). See Reconfiguring a Widget.




4.3 Customizing the Columns (When Displaying a KPI)
By default, when a pivot table widget displays a KPI, it displays all the columns defined in that data source. You can customize
the columns. For information, see Adding Widget Properties.




4.4 Displaying a Listing in a Pivot Table Widget
To display a listing directly in a pivot table widget:
1.   Do the following in the Analyzer:
     a.   Create a pivot table with one cell. Filter this pivot table as needed for the listing.
          See Using the Analyzer.
     b.
          Select the cell and click the listing button         to display the listing.
     c.   Save the pivot table.

2.   In the desired dashboard, add a pivot table widget that use this pivot table as its data source.
3.   Optionally add filter controls; these restrict the set of records that are shown.




4.5 Customizing the Appearance of a Pivot Table
The system provides a rich set of options that you can use to customize the appearance of a pivot table widget. To access
these options, access the Dashboard Editor, select the widget as described in Reconfiguring a Widget and click Table Settings.
This menu has two submenus:
•    Size & Appearance — Provides options to control the size of the data cells and the form of the pivot table. See the first
     subsection for details.
•    Colors & Style — Provides options to control colors, typeface, text style, and text alignment in the pivot table. See the
     second subsection for details.

Note:     The easiest way to systematically alter the appearance of dashboards is to define and use themes, which are discussed
          in Defining and Using Themes. Themes use the options described in the following subsections.




Creating Dashboards                                                                                                          35
Adding Pivot Table Widgets



4.5.1 Size and Appearance Options
To control the size of the data cells and the form of the pivot table, access the Dashboard Editor, select the widget as
described in Reconfiguring a Widget, click Table Settings, and click Size & Appearance. This menu has the following
options:
•    Cell Width — Specify the width, in pixels, of the data cells. For example:




     This example also uses Cell Height.
•    Cell Height — Specify the height, in pixels, of the data cells. See the previous example.

•    Show Empty — Use these options to control whether empty rows and columns are displayed. For example, if you
     enable the Show Empty option for rows, the system displays empty rows as follows:




•    Span Labels — Use these options to control whether row and column labels are spanned.

     When you display the table in a nested format, the labels are spanned by default. For example:



36                                                                                                     Creating Dashboards
                                                                             Customizing the Appearance of a Pivot Table




    If you enable the Span Labels option for rows, the system repeats the relevant labels, as follows:




•   Row Totals — Use this option to control whether the pivot table includes a summary row at the bottom. For example:




    This example also uses Column Totals.
•   Row Summary — Specify the form of the summary row. For example, choose Sum or Average.

•   Sum Over, choose either Page or All Rows. This option determines whether the summary row uses only the current
    page of the pivot table or all rows.
•   Column Totals — Use this option to control whether the pivot table includes a summary column at the right. See the
    example for Row Totals.
•   Row Caption — Use this option to display or hide the caption that appears above the row headers. In the following
    example. the row captions are hidden:




Creating Dashboards                                                                                                     37
Adding Pivot Table Widgets



4.5.2 Color and Style Options
To control the colors, typeface, and other such aspects of the pivot table, access the Dashboard Editor, select the widget as
described in Reconfiguring a Widget, click Table Settings, and click Colors & Style. This menu has the following options:
•    Cell Style — Use this submenu to modify the colors, typeface, text style, and text alignment used in all data cells of
     the pivot table. For example:




     For details on this and other submenus, see Specifying Table Text Styles.
•    Row Style — Use this submenu to modify the colors, typeface, text style, and text alignment used in the row headers
     of the pivot table. For example:




•    Column Style — Use this submenu to modify the colors, typeface, text style, and text alignment used in the column
     headers of the pivot table. For example:




•    Stripes — Select this option to format the pivot table with zebra stripes. If you enable Stripes, the table is formatted
     with rows in alternating colors as follows:




•    Stripe Style — Use this submenu to modify the colors, typeface, text style, and text alignment used in the even rows,
     when zebra stripes are enabled. For example:




38                                                                                                      Creating Dashboards
                                                                                           Removing a Pivot Table Redefinition




•    Background — Select the background color of the pivot table. For example:




•    Opacity — Specify the opacity of the background. The value 1 means 100%.




4.6 Removing a Pivot Table Redefinition
Via the Mini Analyzer, a user can redefine a pivot table as used in a given dashboard widget. See Using the Analyzer.
To remove any redefinition performed this way:
1.   Access the Dashboard Editor and select the widget as described in Reconfiguring a Widget.
2.   Click Type and Data Source.
3.   Click Reset Data Source.
     If the Reset Data Source option is grayed out, this widget uses the pivot table as it was originally defined in the Analyzer.
4.   Click OK.



Or click the Mini Analyzer button         , click Reset, and then click OK.




Creating Dashboards                                                                                                            39
5
Adding Chart Widgets
This page describes how to add charts to a Business Intelligence dashboard.
Also see Specifying Widget Settings for a Pivot Table Widget, as well as Customizing the Appearance of a Chart Widget.




5.1 Adding a Chart Widget
To add a chart widget:
1.   Click Menu > Add New Widget....
2.   Click Pivots and Charts.
3.   Click a chart type.
4.   For Data source, do one of the following:
     •
         Click the Search button       and then select a data source.
     •   Use the Link to drop-down list to select another widget on the same dashboard.

     Note:    If you use a pivot table as the data source, note that pivot tables are created in the Analyzer, discussed in
              Using the Analyzer. The Analyzer provides options for changing the state of the pivot table: filtering, drilling
              down, displaying listings, and displaying in chart format. When you save a pivot table, the system saves the
              state as part of the pivot table definition. The next time the pivot table is accessed (either in the Analyzer or
              in a widget on a dashboard), the system displays the pivot table in that state.

5.   Optionally specify the basic settings, as described in Adding a Widget to a Dashboard.
6.   Click OK.
7.   Optionally customize the chart type, as described in the next section.
8.   Optionally configure the widget further as described in the rest of this page.
9.   Optionally add controls, as described in Adding Widget Controls.




Creating Dashboards                                                                                                         41
Adding Chart Widgets




5.2 Customizing the Chart Type
You can reconfigure a chart widget to use a different chart type. To do so:
1.   Access the Dashboard Editor and select the widget as described in Reconfiguring a Widget.
2.   Click Chart Settings.
3.   Click Chart Type.
4.   Click a type.

You can also use these steps to reconfigure a pivot widget to display a chart.




5.3 Chart Requirements
A chart is usually more useful if the data source uses members as rows and uses measures as columns.
Notes:
•    If you use a pivot table that has a summary row or summary column, that row or column is ignored.
•    Many of the chart types are also available in the Analyzer, where you can preview them before adding them to a
     dashboard.
•    Except in the case of line charts and time charts, only the first 400 chart items are displayed.




5.4 Available Chart Types
The following subsections show examples of the available chart types:
•    Bar and column charts
•    Line and area charts
•    Combo charts
•    High low charts
•    Pie charts
•    X/Y charts
•    Bubble charts
•    Time charts
•    Tree map charts
•    Bullseye charts
•    Swirl charts




42                                                                                                      Creating Dashboards
                                                                                                        Available Chart Types



5.4.1 Bar and Column Charts
The system provides several styles of bar and column charts, both horizontal and vertical. One group of bars is created for
each row of the data source. In a group of bars, each bar displays a different measure. The following example shows a chart
with one measure:




This chart is based on the following pivot table:




5.4.2 Line and Area Charts
The system provides two line charts and an area chart. For each of these, the horizontal axis has one label for each row of
the data source. One line is created for each column of the data source. (For the area chart, the area below the line is filled
in.)
The following shows an example:



Creating Dashboards                                                                                                         43
Adding Chart Widgets




This chart is based on the following pivot table:




5.4.3 Combo Charts
Note:     Combo charts are available only in dashboards, not in the Analyzer.

The InterSystems IRIS Business Intelligence combo chart is similar to the preceding charts, but provides two unique features:
•    It can have multiple y-axes.
•    It can use different display types for different columns of the data source. The system automatically displays lines in
     the foreground, bars behind the lines, and areas behind the bars.

The following chart demonstrates both features:




44                                                                                                     Creating Dashboards
                                                                                                      Available Chart Types




Notice that the y-axis is labeled Patient Count. The filled area that displays the Patient Count measure is scaled
to match the values on this axis. In contrast, the line that displays Avg Enc Count does not correlate with the y-axis —
this line is only scaled overall to fit within the chart.
To use a combo chart, the user clicks the box next to the name of a series, in the key. If we click the box next to Avg Age,
the labels on the y-axis change as follows:




Creating Dashboards                                                                                                      45
Adding Chart Widgets




This chart is configured so that for the first series, y-Axis is 1, and for the second series, y-Axis is 2.
In contrast, if y-Axis is the same for both series, we would see the following (in which all the items are drawn to the same
scale):




46                                                                                                            Creating Dashboards
                                                                                                       Available Chart Types




5.4.4 High Low Charts
A high low chart is similar to a bar chart but instead uses each bar to display a low value and a high value. It requires at
least two columns in the data source. It displays one bar for each row of the data source. The upper and lower values are
determined by the first two columns in the data source. For example:




Creating Dashboards                                                                                                        47
Adding Chart Widgets




This chart is based on the following pivot table:




If there is a third column, the chart displays a triangle for that value. For example:




48                                                                                       Creating Dashboards
                                                                                                     Available Chart Types




In this case, the third column displays the average values.
Other columns are ignored.


5.4.5 Pie Charts
A pie chart displays one wedge for each cell of the data source. The area of each wedge is proportional to the value in the
cell. If the data source displays only one column, a pie chart might look like this:




This chart is based on the following pivot table:




Creating Dashboards                                                                                                     49
Adding Chart Widgets




If you enable the Show Multiples option, the widget displays one chart for each column of the data source. The chart displays
one wedge for each cell in that column. For example:




5.4.6 X/Y Charts
An X/Y chart plots one value on the x-axis and another value on the y-axis. The data source must have at least two columns.
The chart displays a data point for each row of the data source, and it connects these data points with lines.
The first column determines the horizontal position of the data point, and the second column determines the vertical position.
The following shows an example:




This chart is based on the following pivot table:



50                                                                                                     Creating Dashboards
                                                                                                       Available Chart Types




If the underlying pivot table contains additional columns, they are used to create additional sets of connected data points
on the chart. That is, for each additional column, the chart contains a set of data points at the same horizontal positions.
For example:




This chart is based on the following pivot table:




Creating Dashboards                                                                                                       51
Adding Chart Widgets




5.4.7 Bubble Charts
Note:     Bubble charts are available only in dashboards, not in the Analyzer.

A bubble chart is similar to the X/Y chart. It plots one value on the x-axis and another value on the y-axis. The data source
must have at least two columns. The chart displays an elliptical bubble for each row of the data source. The measures are
used as follows:
•    The first column determines the horizontal position of the bubble.
•    The second column determines the vertical position.
•    The third column, if included, determines the radius of the bubble.
•    The fourth column, if included, controls additional colorization that is added to the bubbles. All data rows that have
     the same value for the fourth measure are shown in the same color.
•    The fifth column, if included, determines the opacity of the bubble.

Other columns are ignored.
The following example shows a bubble chart that uses two columns:




52                                                                                                     Creating Dashboards
                                                                                                      Available Chart Types




This chart is based on the following pivot table:




5.4.8 Time Charts
Note:    Time charts are available only in dashboards, not in the Analyzer.

A time chart is useful for displaying values over time. For this kind of chart, the data source must have time members (such
as years) for rows. The following shows an example:




Creating Dashboards                                                                                                      53
Adding Chart Widgets




This chart is based on the following pivot table:




Time charts are supported only for levels that are based on the following time functions: DayMonthYear, MonthYear,
WeekYear, and Year. Also, time charts are not recommended for spans of time greater than approximately ten years.


5.4.9 Tree Maps
Note:    Tree maps are available only in dashboards, not in the Analyzer.

A tree map has one rectangle divided into smaller rectangles, each of which corresponds to one cell in the data source. The
area of each rectangle is proportional to the value in the cell. If the data source displays only one measure, a tree map might
look like this:




54                                                                                                      Creating Dashboards
                                                                                                      Available Chart Types




This tree map uses the following pivot table:




If the data source has multiple columns, be sure to enable the Show Multiples option. In this case, the widget displays a
subdivided rectangle for each column.


5.4.10 Bullseye Charts
Note:    Bullseye charts are available only in dashboards, not in the Analyzer.

A bullseye chart can be useful to demonstrate the size of a set relative to a larger set. The following shows an example:




This chart is based on the following pivot table:




Creating Dashboards                                                                                                         55
Adding Chart Widgets




If the data source has multiple columns, be sure to enable the Show Multiples option. In this case, the widget displays a
subdivided circle for each column in the data source.


5.4.11 Swirl Charts
Note:    Swirl charts are available only in dashboards, not in the Analyzer.

A swirl chart is similar to a pie chart. It displays one wedge (or group of wedges) for each row of the underlying pivot table.
The following shows an example:




56                                                                                                      Creating Dashboards
                                                    Available Chart Types




This chart is based on the following pivot table:




Creating Dashboards                                                   57
Adding Chart Widgets




If the underlying pivot table has multiple columns, the swirl chart includes multiple wedges for any given row. For example:




This chart is based on the following pivot table:




5.5 Displaying a Production Business Metric
This section discusses suitable ways to display production business metrics in charts. There are four general possibilities:




58                                                                                                    Creating Dashboards
                                                                                  Displaying a Production Business Metric


•   The metric defines only one instance (the default) and does not define AUTOHISTORY for any of the properties. In
    this case, when you display the metric as a pivot table, it appears with one row as follows:




    In this case, any kind of chart is suitable.
•   The metric defines multiple instances and does not define AUTOHISTORY for any of the properties. In this case, when
    you display the metric as a pivot table, it appears as follows:




    In this case, the most suitable chart types are bar and column charts and combo charts.
•   The metric defines only one instance (the default) and defines AUTOHISTORY for some or all of the properties. In
    this case, when you display the metric as a pivot table, it appears as follows:




    In this case, the most suitable chart types are bar and column charts, line charts, and combo charts.
    Or, if a given property does not specify AUTOHISTORY, the column for that property is empty except for the last row.
    You might prefer to display only the properties that specify AUTOHISTORY. To do so, you can add a filter control
    and filter the data to show only those properties. Note that you can hide this control from the user.
•   The metric defines multiple instances and defines AUTOHISTORY for some or all of the properties. In this case, when
    you display the metric as a pivot table, the AUTOHISTORY is ignored by default, and the metric appears as follows:




    In this case, the most suitable chart types are bar and column charts and combo charts.
    To force the metric to display the AUTOHISTORY, you can add a filter control and filter the data to show only one
    instance. Note that you can hide this control from the user. When filtered to display one instance, the metric appears
    as follows:




Creating Dashboards                                                                                                     59
Adding Chart Widgets




     In this case, the most suitable chart types are bar and column charts, line charts, and combo charts.




60                                                                                                     Creating Dashboards
6
Customizing the Appearance of a Chart
Widget
The system provides a rich set of options that you can use to customize the appearance of a chart widget on a Business
Intelligence dashboard. To access these options, access the Dashboard Editor, select the widget as described in Reconfig-
uring a Widget, and use the options in the Chart and Pivot section. The following submenus affect the appearance of a chart:
•   Chart Settings > Chart Type — Enables you to select a chart type.

•   Chart Settings > Size & Appearance — Provides options to control the chart overall.

•   Chart Settings > Titles & Labels — Provides options to control the text and formatting of titles and labels on the chart.

•   Chart Settings > No Data Warnings — Provides options to control an optional warning if there is no data to display.

•   Chart Settings > Colors & Style — Provides options to control colors and line styles in the chart.

•   Chart Settings > x Axis — Provides options to customize the text and formatting of the x-axis of the chart.

•   Chart Settings > y Axis — Provides options to customize the text and formatting of the y-axis or y-axes of the chart.

•   Chart Settings > Series Details — Provides options to customize how each series (row of the data source) is displayed.

•   Chart Legend — Provides options to disable, enable, and customize the chart legend.


The following subsections provide details.

Note:    The easiest way to systematically alter the appearance of dashboards is to define and use themes, which are discussed
         in Defining and Using Themes. Themes use the options described in many of the following subsections.




6.1 Size and Appearance Options
To customize the overall size and appearance of a chart, access the Dashboard Editor, select the widget as described in
Reconfiguring a Widget, click Chart Settings > Size & Appearance, and use the options listed there. The following options
are available:
•   Margins — Use this submenu to customize the margins of the chart. Use the Top, Left, Right, and Bottom sliders to
    separately control the top, left, right, and bottom margins. For each margin, use the Units setting to specify the margin
    either as a percentage of the widget size or in pixels.
    Or specify Units as Auto to use the default margins.



Creating Dashboards                                                                                                        61
Customizing the Appearance of a Chart Widget


•    Multiples — Select this option to display one chart for each series (row of the data source). For example:




     This option is recommended for pie charts and tree maps.
•    Pivot (applies only to charts that have x- and y-axes) — Select this option to switch the x- and y-axes.

•    Stacked (applies only to charts that have x- and y-axes) — Select this option to display the series (rows of the data
     source) in stacked form. For example:




     This option affects only the series that are displayed as bars.
•    Filled (applies only to line and area charts) — Select this option to control whether the system fills in the area below
     the series lines on the chart.
•    Appearance — Use this option to control whether the chart is displayed with a three-dimensional appearance. For
     example:




62                                                                                                      Creating Dashboards
                                                                                              Size and Appearance Options




•   Zoom — Enable this option to display zoom buttons on the lower left of the chart. For example:




    This option applies only to charts that have x- and y-axes.
•   Pie Height (applies only to pie charts) — Use this option to control the height of the pie chart, if Appearance is 3D. For
    example:




•   Pie Size (applies only to pie charts) — Use this option to control the radius of the pie chart.

•   Pie Hole Size (applies only to pie charts) — Use this option to control the size of the pie hole. For example:




Creating Dashboards                                                                                                        63
Customizing the Appearance of a Chart Widget




     The default hole size is zero.
•    Quadrant (applies only to bubble charts) — Select this option to divide the chart into quadrants, marked by different
     colors. For example:




•    Radius (applies only to bubble charts) — Use this option to control the basic size of the bubbles in a bubble chart.

•    Opacity (applies only to bubble charts) — Use this option to control the opacity of the bubbles in a bubble chart.

•    Regression (applies only to bubble charts) — Select this option to display a regression line on the chart. For example:




64                                                                                                    Creating Dashboards
                                                                                               Size and Appearance Options




•   Separate Series Scale (applies only to swirl charts) — Controls the scaling of the wedges, in the case when the under-
    lying pivot table has multiple columns. By default, the chart uses a single scale to determine the size of each wedge,
    and the wedge for the maximum of one column is likely to be different from the wedge for the maximum of another
    column. (For examples, see Plot By.)
    If Separate Series Scale is On, the chart uses a separate scale for each column, and the maximum wedge for any column
    is the same size, as in the following example (which uses both Patient Count and Allergy Count as columns) :




•   Invert (applies only to swirl charts) — Click On to display the labels in the outer area of the chart, rather than within
    the center. For example:




Creating Dashboards                                                                                                        65
Customizing the Appearance of a Chart Widget




•    Gap (applies only to swirl charts) — Use this to control the size of the gaps between the wedges. The following shows
     an example with a minimal gap:




•    Plot By (applies only to swirl charts) — Controls how the wedges are colored; this is particularly useful if the underlying
     pivot table displays multiple columns. If you click items, the chart uses similar colors for the all wedges that belong
     to the same row in the pivot table on which this chart is based. For example, the following swirl chart is based on a
     pivot table that uses Patient Count and Allergy Count for columns. Notice that, for example, Sunday has two wedges
     of similar color; one is for Patient Count and the other is for Allergy Count.




66                                                                                                       Creating Dashboards
                                                                                                      Title and Label Options




    If you click series, the chart uses a single color for the all wedges that belong to the same column, so that the chart has
    a separate color for each column. For example, the following swirl chart is the same as the preceding except that Plot
    By is set to series:




6.2 Title and Label Options
To customize the titles and labels of a chart, access the Dashboard Editor, select the widget as described in Reconfiguring
a Widget, click Chart Settings > Titles & Labels, and use the options listed there. The following options are available:
•   Title — Use this option to specify an optional title within the chart. For example:




Creating Dashboards                                                                                                         67
Customizing the Appearance of a Chart Widget




•    Title Style — Use this submenu to control the text style of the chart title. For example:




•    Subtitle — Use this option to specify an optional subtitle within the chart. See the example for Title.

•    Subtitle Style— Use this submenu to control the text style of the chart subtitle. See the example for Title Style.

•    Title Align — Use this option to control the alignment of the chart title and subtitle. These titles can be left-aligned,
     centered, or right-aligned.




68                                                                                                       Creating Dashboards
                                                                                                      Title and Label Options


•   Title Box — Use this submenu to add an optional box around the chart title and subtitle. For example:




•   Title Image — Use this option to add an optional image to the title. For example:




    In this example, the titles are also left-aligned (see the Title Align option).
•   Image Width, Image Height, Image Top, and Image Left — Use these options to control the size and position of the
    optional title image.
•   Labels — Enable this option to display labels for the axes of the chart. The following shows a chart with labels displayed:




Creating Dashboards                                                                                                         69
Customizing the Appearance of a Chart Widget




     This example also uses the Value Labels option (which controls the labels shown at the top of each column).
     To understand which labels are controlled by this option, recall that the axes of the chart are determined by the axes
     of the pivot table on which the chart is based. For example, the preceding chart is based on a pivot table whose x-axis
     (rows) displayed No Channel, Online, and Retail and whose y-axis (columns) displayed Revenue.
•    Label Style— Use this submenu to control the text style of the chart labels. For example:




•    Label Length— Use this option to specify the maximum length of the labels; any additional characters are truncated.
     For example:




70                                                                                                    Creating Dashboards
                                                                                                     Title and Label Options




    In this example, Label Length is 5.
•   Axis Title— Use this submenu to control the text style of the axis titles. For example:




    You can also separately control the style of the x-axis and the y-axis or y-axes.
•   Value Labels (applies only to bar charts) — Select this option to display a label above or next to each column, indicating
    the value displayed by the column. For examples, see Labels and Value Style.
•   Value Style— Use this submenu to control the text style of the value labels. For example:




Creating Dashboards                                                                                                        71
Customizing the Appearance of a Chart Widget




     This example also uses a non-default option (#.###) for Value Format. See the next item.
•    Value Format— Use this option to control the numeric formatting of the value labels. See the example for Value Style.




6.3 No Data Warning
To customize the appearance of a chart when there is no data to display, select the widget as described in Reconfiguring a
Widget, click Chart Settings > No Data Warning, and use the options listed there. The following options are available:
•    No Data Message — Type the message to display if there is no data to display in this chart.

•    Warn if no data? — Select ON to display the given message if there is no data. The message is shown in a box in the
     widget as shown after this list. The default is OFF.
•    Background opacity — Specify the opacity of the background of the box that contains the given message. The value
     1 means 100%.
•    Background color — Select the color of the box that contains the given message.

•    Message color — Select the color of the message.


The following shows an example:




72                                                                                                  Creating Dashboards
                                                                                                    Color and Style Options




6.4 Color and Style Options
To customize the colors and line styles in a chart, access the Dashboard Editor, select the widget as described in Reconfig-
uring a Widget, click Chart Settings > Colors & Style, and use the options listed there. The following options are available:
•   Series Scheme — Select a scheme, which is a set of colors to use for the series shown in this chart.

•   Background — Use this submenu to specify the style of the background that surrounds the chart. For example:




•   Plot Area — Use this submenu to specify the style of the plot area of the chart. For example:




•   Plot Style — Use this submenu to specify the style of the series that are plotted in the chart. This submenu affects only
    bar charts, area charts, and pie charts.
    For example:




Creating Dashboards                                                                                                       73
Customizing the Appearance of a Chart Widget




     The Plot Style menu treats all series in the same way. Also note that this menu overrides the options in Chart Settings
     > Series Details; see Series Details.

•    Grid Style — Use this submenu to specify the style of the grid (if any) displayed within the chart. For example:




•    Axis Line Style — Use this submenu to specify the style of the axis lines. For example:




74                                                                                                    Creating Dashboards
                                                                                                      Color and Style Options


•   Base Line Style — Use this submenu to specify the style of the base line (if any) in the chart.

    For example:




    To specify a base line, see the Base Value option in the next section.
•   Line Style — Use this submenu to specify the style of the lines (if any) displayed in the chart. For example:




•   Markers Visible — Enable this option to display markers in the chart.

•   Marker Style — Use this submenu to specify the style of the markers (if any) displayed in the chart. For example:




Creating Dashboards                                                                                                       75
Customizing the Appearance of a Chart Widget


•    Marker Size — Use this option to modify the size of the markers (if any).

•    Indicators Visible — Enable this option to display crosshairs when a user selects an item in the chart. For example:




•    Indicator Style — Use this submenu to specify the style of the indicator (if any) displayed in the chart. See the previous
     item.
•    Band Upper — Type a value to define an upper area of this axis that is styled as a band. The following example uses
     both Band Upper (specified as 60) and Band Lower (specified as 20):




•    Upper Style — Use this submenu to specify the style of the upper band, if any.

•    Band Lower — Type a value to define a lower area of this axis that is styled as a band. See the example for Band Upper.

•    Lower Style — Use this submenu to specify the style of the lower band, if any.

•    Stripes — Use this option to add stripes to this axis. For example:




76                                                                                                      Creating Dashboards
                                                                                                    Color and Style Options




    This example also uses Stripe Style.
•   Stripe Style — Use this submenu to specify the style of the stripes, if any.

•   Border Style — Use this submenu to specify the style of the border of the chart. The border surrounds the plot area,
    and is enclosed by the background. The following shows an example:




    This example also uses a non-default value for Border Radius, discussed later in this list.
•   Border Offset — Use this option to modify the position of the border, relative to the background.

•   Border Radius — Use this option to modify the radius of the corners of the border. By default, these corners are right
    angles. For a non-default example, see Border Style.
•   Data-driven Colors, Termlist option — Use this option to specify a set of CSS colors to use for specific series in this
    widget. To use this option, first use the Term List Manager (see Defining Models for InterSystems Business Intelligence)
    and define a term list as follows:
    –   The key for each item must be the exact display name of a series in this widget.
    –   The value for the item must be a CSS color value. You can use any legal CSS color name. You can find these at
        https://www.w3.org/TR/css3-color/ and other locations on the Internet.

    The following shows an example:


Creating Dashboards                                                                                                       77
Customizing the Appearance of a Chart Widget




     Then, for the Data-driven Colors, Termlist option, type the exact name of the term list.
     If this term list does not include a term for a given series in the widget, the system displays that series in gray.
     Note that this feature does not provide any support for localization.

For details on the submenus, see Specifying Line Styles.




6.5 x-Axis Options
To customize the x-axis of a chart, access the Dashboard Editor, select the widget as described in Reconfiguring a Widget,
click Chart Settings > x Axis, and use the options listed there. The following options are available:
•    Axis Title — Specify the title to use on the x-axis. By default, this title is taken from the data source.

•    Major Grid — Use this option to enable or disable lines that mark major positions on the x-axis. By default, these lines
     are on.
•    Major Style — Use this submenu to customize the style of the lines that mark major positions on the x-axis. In the fol-
     lowing example, Major Style is specified for both the x- and y-axes:




•    Minor Grid — Use this option to enable or disable lines that mark minor positions on the x-axis. By default, these lines
     are off. In the following example, these lines are on for both the x- and y-axes:




78                                                                                                        Creating Dashboards
                                                                                                                x-Axis Options




•   Minor Style — Use this submenu to customize the style of the lines that mark minor positions on the x-axis.

•   Label Position — Specifies the position (top or bottom) of the x-axis. By default, this axis is on the bottom. The following
    shows this axis at the top of the chart:




•   Label Style — Use this submenu to specify the text style of the labels of the x-axis. For example:




Creating Dashboards                                                                                                          79
Customizing the Appearance of a Chart Widget




     This example also uses the Label Angle option.
•    Label Angle — Use this option to specify the angle of the labels of the x-axis. See the example for Label Style.

•    Axis Type — Optionally select % to express the values on the x-axis as percentages. If you select this option, the system
     multiplies the values by 100 and displays % at the end of each value.
•    Min Value — Use this option to specify the minimum x value shown in the chart. If you use this option, the chart is
     rescaled to start at this minimum x value, and lower data points are ignored.
•    Max Value — Use this option to specify the maximum x value shown in the chart. If you use this option, the chart is
     rescaled to end at this maximum x value, and higher data points are ignored.
•    Base Value — Use this option to add a reference line at the given value. For example, the following chart has a reference
     line at the value of 50:




     This example also uses the Base Line Style option in Chart Settings > Colors & Style; see the previous section.

The same options are available when you customize a y-axis.




6.6 y-Axis or Axes Options
To customize the y-axis or y-axes of a chart, access the Dashboard Editor, select the widget as described in Reconfiguring
a Widget, click Chart Settings > y Axis, and use the options listed there. This menu lists the y-axes currently defined in this
chart. For example:



80                                                                                                      Creating Dashboards
                                                                                                        Series Detail Options




Here, you can do the following:
•   Add a y-axis. To do so, click the plus sign button. The system immediately adds a y-axis.
•   Remove a y-axis. To do so, click the X button in the row for that axis.
•   Rearrange the y-axes. To do so, drag the axis handles to the left of the axis names.
•   Customize a y-axis. To do so, click its name to display a submenu of options. For details on this submenu, see the
    previous section.
    Some options, include Major Grid, Major Style, Minor Grid, and Minor Style, are supported only for the primary y-axis.




6.7 Series Detail Options
The system uses a default set of colors that it uses for each series (a row in the data source). You can override these. For
line charts, you can also customize the markers used for the data points.
To customize how each series is displayed in a chart, access the Dashboard Editor, select the widget as described in
Reconfiguring a Widget, click Chart Settings > Series Details, click a series, and then use the options listed there.
For each series, you can modify the following options (depending on the chart type):
•   Color — Specify the color for this series.

    For information on specifying colors, see Specifying Table Text Styles.
•   y Axis — Specify the y-axis with which to associate this series (either 1 or 2).

    Note that both y-axes are displayed in the same position by default. To change this position; see the Label Position
    option in Chart Settings > Y Axis.
•   Plot Type (combo charts) — Specify the plot type to use for this series.

•   Marker Shape (line, area, combo, and time charts) — Specify the marker shape to use for data points displayed in this
    series.

The following shows an example:




Creating Dashboards                                                                                                        81
Customizing the Appearance of a Chart Widget




6.8 Chart Legend Options
To customize the legend of a chart, access the Dashboard Editor, select the widget as described in Reconfiguring a Widget,
click Chart Legend, and use the options listed there. The following options are available:
•    Position — Select an option to specify the location (if any) of the chart legend. Select right, left, top, bottom, or none.

•    Title — Specify the title to show in the chart legend, if you want to override the default title, which is based on the
     chart definition.
•    Show Title — Select ON to display the chart legend title. Or select OFF to hide it.

•    Border — Use this submenu to specify the border around the chart legend. The following shows an example:




•    Background — Specify the color of the background of the chart legend. See the preceding example.

•    Opacity — Specify the opacity of the chart legend. The value 1 means 100%.

•    Font — Specify the typeface of the chart legend.

•    Font Size — Specify the size of the text of the chart legend.

•    Text Color — Specify the style of the text of the chart legend. The following shows an example that uses this option
     and other style options:


82                                                                                                       Creating Dashboards
                                                                                              Chart Legend Options




•   Text Style — Specify the style of the text of the chart legend.

•   Padding — Specify the horizontal and vertical padding before and after the legend.

•   Width — Specify the width of the legend.

•   Height — Specify the height of the legend.

•   Show Box Shadow — Control whether the legend displays a faint shadow for each box in the legend. The shadow is
    displayed by default. The following magnified view shows an example:




    If Show Box Shadow is OFF, the same legend appears as follows:




Creating Dashboards                                                                                              83
7
Adding Meter Widgets
This page describes how to add meter widgets to a Business Intelligence dashboard.




7.1 Adding a Meter Widget
To add a meter widget:
1.   Click Menu > Add New Widget....
2.   Click Meter.
3.   Click a meter type.
4.   For Data source, do one of the following:
     •
         Click the Search button       and then select a data source.
     •   Use the Link to drop-down list to select another widget on the same dashboard.

     Most InterSystems IRIS Business Intelligence data sources can have multiple rows and columns. When you display
     any of these in a meter widget, the widget uses only the first row of data. Any additional rows are ignored.
5.   Optionally specify the basic settings, as described in Adding a Widget to a Dashboard.
     Also see Basic Meter Options, in this page.
6.   Click OK.
7.   Add at least one property, as described in Adding Properties.
     This property becomes a meter within the meter widget. For example, the following meter widget has three properties:




Creating Dashboards                                                                                                   85
Adding Meter Widgets


     By default, the type of each meter is the same as the type of the parent meter widget, but you can modify the type for
     individual meters.
     For additional details, see the following subsection.
8.   Optionally configure the widget further as described in the rest of this page, which discusses the following kinds of
     meters:
     •   Speedometers
     •   Text meters
     •   Fuel gauges
     •   Traffic lights
     •   Light bars
     •   Smileys

     For examples and a comparison, see the next section.
9.   Optionally add controls, as described in Adding Widget Controls.


7.1.1 Data Sources, Properties, and Meters
A meter widget has multiple properties, each of which is displayed as a separate meter within the widget. Consider the
preceding example, which shows a widget with three properties, each shown in a separate speedometer.
Most InterSystems IRIS Business Intelligence data sources can have multiple rows and columns. When you display any
of these in a meter widget, the widget uses only the first row of data. Any additional rows are ignored.
For the first row of data, each column of the data source can be displayed as a property of the meter widget, that is, as a
separate meter within the widget. In the examples shown here, all the meters in a meter widget are of the same type, but
you can configure the widget to use different types within a single widget.




7.2 Specifying Widget Settings for a Meter
For a meter, the Widget Settings menu has the following options:
•
     Print — Select this option to include the Print button       on the toolbar. This button enables users to print the widget
     to a PDF file. For further details and requirements, see the section Customizing Print Settings for a Widget.
•
     Analyzer — Select this option to include the Mini Analyzer button          on the toolbar. This button enables the users
     to open the data source in the Mini Analyzer.
     This option is supported only when the data source is a pivot table.

This menu includes additional options that control the look of the meter; the options depend on the kind of meter. The rest
of the article provides the details.

Note:     These options add a button to the toolbar. If you use these options, be sure the toolbar is visible (its display is
          controlled via the Toolbar option in Settings). See Reconfiguring a Widget.




86                                                                                                       Creating Dashboards
                                                    Meter Types




7.3 Meter Types
The system provides the following types of meter:




Creating Dashboards                                         87
Adding Meter Widgets


 Meter Type      Example   Basics   Notes




88                                          Creating Dashboards
                                                                          Meter Types


 Meter Type      Example   Basics               Notes
 Speedometer               Range options        •   The actual value is always
                           control the              shown in the box.
                           possible positions
                                                •   You can add thresholds within
                           of the needle
                                                    the scale, shown as different
                                                    color bands in the scale.
                                                •   You can add a target value
                                                    shown as a line on the scale.




 Text meter                Meter displays the
                           actual value and a
                           label


 Fuel gauge                Range options        •   The actual value is always
                           control the              shown in the box.
                           possible positions
                                                •   You can add thresholds within
                           of the needle
                                                    the scale, shown as warning
                                                    lights at the top and bottom.




 Traffic light             Threshold options    •   By default, a high value is con-
                           control the use of       sidered bad and is shown as a
                           the three lamps          red lamp.
                                                •   You can reverse the sense of
                                                    the meter by reversing the high
                                                    and low range values.




Creating Dashboards                                                                 89
Adding Meter Widgets


    Meter Type      Example                                Basics                  Notes
    Light bar                                              Range options           •   By default, a high value is con-
                                                           control the bars            sidered bad and is shown with
                                                           and their colors            all bars lit, including a red bar at
                                                                                       the top.
                                                                                   •   You can reverse the sense of
                                                                                       the meter by reversing the high
                                                                                       and low range values.
                                                                                   •   You can add thresholds within
                                                                                       the scale, shown as warning
                                                                                       lights at the top and bottom.



    Smiley face                                            Range options           •   By default, a high value is con-
                                                           control the                 sidered good and is shown as a
                                                           possible shapes of          smile.
                                                           the smile or frown
                                                                                   •   You can reverse the sense of
                                                                                       the meter by reversing the high
                                                                                       and low range values.




7.4 Basic Meter Options
For any meter widget, you can customize a set of basic options. To customize the widget, access the Dashboard Editor,
select the widget as described in Reconfiguring a Widget, click Meters, and use the options listed there. The following
submenus are available:
•     Settings — Use this submenu to customize the entire meter widget. This submenu provides the following options:

      –   Format — Select an option to control the numeric formatting of all meters in this meter widget. For example:




      –
          Analyzer — Use this option to control whether this widget displays the Mini Analyzer         button.
          This option is supported only when the data source is a pivot table.
      –   High value color — Select the color to use for the section of the meter that displays values higher than the Upper
          Threshold option, which you specify in the meter name submenu.

          This option applies only to speedometers.
      –   Low value color — Select the color to use for the section of the meter that displays values lower than the Lower
          Threshold option, which you specify in the meter name submenu.




90                                                                                                    Creating Dashboards
                                                                                                 Customizing Speedometers


         This option applies only to speedometers.
    –    Background color — Select the color to use for the background around the meter widget.

    –    Background opacity — Use this option to specify the opacity of the background. The value 1 means 100%.


•   meter name — Use this submenu to customize an individual meter (property) within the meter widget. This submenu
    provides the following options:
    –    Type — Select the meter type. The default type is the meter type that you specify in the parent widget, as described
         in the previous section.
    –    Data Property — Select the property to display in this meter.

    –    Label — Specify the label for this meter.

    –    Label Style — Use this submenu to specify the color, font size, typeface, and so on for the label of this meter. For
         example:




    –    Apply Style to All Meters — Use this option to copy the styles from this meter to all other meters within this meter
         widget.

    Other options depend on the kind of meter; see the following sections:
    –    Speedometers
    –    Text meters
    –    Fuel gauges
    –    Traffic lights
    –    Light bars
    –    Smileys


Note:    The easiest way to systematically alter the appearance of dashboards is to define and use themes, which are discussed
         in Defining and Using Themes. Themes use many of the options described in this page.




7.5 Customizing Speedometers
The speedometer is a round gauge with a needle that moves from lower left, all the way around to lower right, to indicate
a value within a specific range. The gauge has tick marks with numeric labels. In the following example, the gauge extends
from 0 to 100:




Creating Dashboards                                                                                                        91
Adding Meter Widgets




The speedometer includes an odometer box at the bottom; this box always displays the actual value from the data source,
even if that value does not fall within the range of the gauge.
To customize a speedometer, access the Dashboard Editor, select the widget as described in Reconfiguring a Widget, click
Meters, click a meter name, and use the options listed there. The following options are available:

•    Common options — See Customizing Meters, earlier in this page.
•    Upper Range and Lower Range — Use these options to specify the lowest and highest numbers displayed on the
     speedometer gauge. In the following example, these options are 20 and –20, respectively.




•    Upper Threshold — Use this option to specify the upper threshold value for the speedometer gauge; values above this
     are displayed in a contrasting color. In the following example, this option is 100:




     Use the Widget Settings menu to control the color used in the threshold area. See Customizing Meters, earlier in this
     page.




92                                                                                                   Creating Dashboards
                                                                                             Customizing Speedometers


•   Lower Threshold — Use this option to specify the lower threshold value for the speedometer gauge; values below this
    are displayed in a contrasting color. In the following example, this option is 50:




    Use the Widget Settings menu to control the color used in the threshold area. See Customizing Meters, earlier in this
    page.
•   Target Value — Use this option to add a target line to the speedometer gauge. For example:




•   Outer Circle — Use this submenu to specify the color and style of the outer circle of the speedometer. For example:




•   Mid Circle — Use this submenu to specify the color and style of the middle circle of the speedometer. For example:




Creating Dashboards                                                                                                    93
Adding Meter Widgets




•    Ring — Use this submenu to specify the color and style of the ring just within the middle circle. For example:




•    Inner Circle — Use this submenu to specify the color and style of the inner circle. For example:




•    Nub — Use this submenu to specify the color and style of the nub at the center of the speedometer. For example:




94                                                                                                      Creating Dashboards
                                                                                             Customizing Speedometers


•   Needle — Use this submenu to specify the color and style of the needle. For example:




•   Thin Needle — Use this option to display a thin needle. For example:




•   Separator — Use this submenu to specify the color and style of the separators that radially divide the speedometer.
    For example:




•   Odometer Box — Use this submenu to specify the color and style of the odometer box. For example:




•   Odometer — Use this submenu to specify the color and style of the value shown in the odometer box. For example:




•   Value Style — Use this submenu to specify the color and style of the values marked on the speedometer gauge. For
    example:




Creating Dashboards                                                                                                   95
Adding Meter Widgets




Note:    The easiest way to systematically alter the appearance of dashboards is to define and use themes, which are discussed
         in Defining and Using Themes. Themes use many of the options described in this page.




7.6 Customizing Text Meters
The text meter displays the given value as text:




To customize a text meter, access the Dashboard Editor, select the widget as described in Reconfiguring a Widget, click
Meters, click a meter name, and use the options listed there. The following options are available:

•    Common options — See Customizing Meters, earlier in this page.
•    Background — Use this submenu to customize the outline and fill of the meter. For example:




•    Fill — Use this submenu to customize the appearance of the value shown in the meter. For example:




•    Low Style — Use this submenu to customize the appearance of the value, when the value is below Lower Threshold.

•    High Style — Use this submenu to customize the appearance of the value, when the value is above Upper Threshold.


Note:    The easiest way to systematically alter the appearance of dashboards is to define and use themes, which are discussed
         in Defining and Using Themes. Themes use many of the options described in this page.




96                                                                                                     Creating Dashboards
                                                                                                 Customizing Fuel Gauges




7.7 Customizing Fuel Gauges
The fuel gauge is a narrow, vertical gauge with a needle that moves from left to right to indicate a value within a specific
range (specified by Lower Range and Upper Range). The gauge distributes marks or “ticks” proportionally across its range,
with Lower Range at left.
The fuel gauge displays its current value in a text box at the center of the gauge.




To customize a fuel gauge, access the Dashboard Editor, select the widget as described in Reconfiguring a Widget, click
Meters, click a meter name, and use the options listed there. The following options are available:

•   Common options — See Customizing Meters, earlier in this page.
•   Upper Range and Lower Range — Use these options to specify the range of values represented by tick marks on the
    fuel gauge.
•   Upper Threshold — Use this option to add a warning light to the right end of the meter. This warning light changes
    color when the meter value is equal to or greater than Upper Threshold. For example:




•   Lower Threshold — Use this option to add a warning light to the left side of the meter. This warning light changes
    color when the meter value is equal to or lower than Lower Threshold. For example:




•   Body Style — Use this submenu to control the outline and fill of the meter. For example:




Creating Dashboards                                                                                                      97
Adding Meter Widgets




Note:     The easiest way to systematically alter the appearance of dashboards is to define and use themes, which are discussed
          in Defining and Using Themes. Themes use many of the options described in this page.




7.8 Customizing Traffic Lights
The traffic light consists of three round lamps in a column. From top to bottom, the lamps are red, yellow, and green.




To customize a traffic light, access the Dashboard Editor, select the widget as described in Reconfiguring a Widget, click
Meters, click a meter name, and use the options listed there. The following options are available:

•    Common options — See Customizing Meters, earlier in this page.
•    Upper Range, Lower Range, Lower Threshold and Upper Threshold, — Use these options to control the three lamps in
     the traffic light. If Upper Range is greater than Lower Range (the default), this meter is lit as follows:
     –   When the meter value is at or below Lower Threshold, the bottom lamp shows green.
     –   When the meter value is between Lower Threshold and Upper Threshold, the center lamp shows yellow.
     –   When the meter value is at or above Upper Threshold, the top lamp shows red.

     The following figure demonstrates this logic:




98                                                                                                        Creating Dashboards
                                                                                                         Customizing Light Bars



                                               upper range
                                                        display red lamp



                                               upper...


                                                          display yellow lamp



                                               lower...


                                                          display green lamp



                                               lower...



    This system is useful when a large number indicates a condition that requires attention.
    Sometimes a low number indicates a condition that requires attention. If so, you can reverse the sense of the meter; to
    do so, set Lower Range to a larger number than Upper Range. Then the red lamp indicates low values, and the green
    lamp indicates high values. When you reverse the range values, do not also reverse the threshold values.
•   Body Style — Use this submenu to control the outline and fill of the meter. For example:




Note:     The easiest way to systematically alter the appearance of dashboards is to define and use themes, which are discussed
          in Defining and Using Themes. Themes use many of the options described in this page.




7.9 Customizing Light Bars
The light bar provides a stack of lamps arranged in a vertical bar. The light bar is similar to the traffic light, but its larger
number of lamps provide a sense of movement from one end of the scale to the other.




Creating Dashboards                                                                                                            99
Adding Meter Widgets




To customize a light bar, access the Dashboard Editor, select the widget as described in Reconfiguring a Widget, click
Meters, click a meter name, and use the options listed there. The following options are available:

•     Common options — See Customizing Meters, earlier in this page.
•     Upper Range and Lower Range — Use these options to specify the range of values represented by the light bar.

      The light bar is intended to appear “off” when the value is low, and fully lit when the value is high. The color of the
      bar shades from green (at the bottom of the scale) to yellow and red (at the top of the scale), implying that you should
      stop and address a problem when the value is high. This system is useful when a large number indicates a condition
      that requires attention.
      Sometimes a low number indicates a condition that requires attention. If so, you can reverse the sense of the meter; to
      do so, set Lower Range to a larger number than Upper Range. Then the fully lit lamp indicates low values, and the “off”
      lamp indicates high values. When you reverse the range values, do not also reverse the threshold values.
•     Upper Threshold — Use this option to add a warning light to the upper end of the meter. This warning light changes
      color when the meter value is equal to or greater than Upper Threshold. For example:




•     Lower Threshold — Use this option to add a warning light to the lower end of the meter. This warning light changes
      color when the meter value is equal to or lower than Lower Threshold. For example:




100                                                                                                     Creating Dashboards
                                                                                                  Customizing Smiley Faces




•   Body Style — Use this submenu to control the outline and fill of the meter. For example:




Note:    The easiest way to systematically alter the appearance of dashboards is to define and use themes, which are discussed
         in Defining and Using Themes. Themes use many of the options described in this page.




7.10 Customizing Smiley Faces
The smiley face is the familiar yellow circle with two eyes and a smile. The mouth line changes depending on the value.




To customize a smiley face, access the Dashboard Editor, select the widget as described in Reconfiguring a Widget, click
Meters, click a meter name, and use the options listed there. The following options are available:

•   Common options — See Customizing Meters, earlier in this page.
•   Upper Range and Lower Range — Use these options to specify the range of values represented by the face, as follows:

    –   The meter displays a smile when the meter value is near Upper Range.



Creating Dashboards                                                                                                       101
Adding Meter Widgets


      –   The mouth is a horizontal line at the midpoint within the given range.
      –   The meter displays a frown when the meter value is near Lower Range.

      This system is useful when a large number indicates a positive condition, and a small number indicates a negative
      condition.
      Sometimes a low number indicates a condition that requires attention. If so, you can reverse the sense of the meter. To
      do so, set Lower Range to a larger number than Upper Range. Then the smile occurs at low values, and the frown at
      high values.
•     Persona — Use this option to control the type of face shown in this meter. For example:




Note:      The easiest way to systematically alter the appearance of dashboards is to define and use themes, which are discussed
           in Defining and Using Themes. Themes use many of the options described in this page.




102                                                                                                      Creating Dashboards
8
Adding Scorecard Widgets
This page describes how to add scorecard widgets to a Business Intelligence dashboard.




8.1 Overview of Scorecards
A scorecard widget displays a set of rows like the following:




You configure the columns of the scorecard, which can be the following:
•   For a KPI or production business metric, you can use each property of that item as a column of the scorecard.
•   For a pivot table, you can use each column of that item as a column of the scorecard.

In any case, you select the items to use as columns of the scorecard, and you specify the order of the columns.
For information on creating pivot tables, see Using the Analyzer. For information on creating KPIs , see Implementing
InterSystems Business Intelligence. For information on creating production business metrics, see Developing Productions.


8.1.1 One-Measure Pivot Tables in Scorecards
Note that if you create a pivot table that displays only one measure, you must create that pivot table in a specific way if
you want to display that pivot table in a scorecard. Specifically, drag and drop the measure to the Columns box in the
Analyzer, rather than the Measures box.




Creating Dashboards                                                                                                      103
Adding Scorecard Widgets


    Rows           Columns             Measures            Comments
    Anything       One measure         Nothing             This pivot table can be displayed in a scorecard.
    Anything       Nothing             One measure         This pivot table cannot be displayed in a scorecard. In this
                                                           case, the measure is used as an MDX filter and cannot be
                                                           configured as a property of the scorecard.




8.2 Adding a Scorecard Widget
To add a scorecard widget:
1.    Click Menu > Add New Widget....
2.    Click ScoreCard.
3.    Click either Regular or Big.
4.    For Data source, do one of the following:
      •
           Click the Search button      and then select a data source.
      •    Use the Link to drop-down list to select another widget on the same dashboard.

5.    Optionally specify the basic settings, as described in Adding a Widget to a Dashboard.
6.    Click OK.
7.    Optionally enable or disable the Mini Analyzer. For this, access to the Widget Settings menu and use the Analyzer

      option. This option controls whether this widget displays the Mini Analyzer         button.
      This option is supported only when the data source is a pivot table.
8.    Add at least one scorecard column.
9.    Optionally configure the widget further as described in the rest of this page.
10. Optionally add widget controls.




8.3 Specifying Widget Settings for a Scorecard
For a scorecard, the Widget Settings menu has the following options:
•
      Print — Select this option to include the Print button      on the toolbar. This button enables users to print the widget
      to a PDF file. For further details and requirements, see Customizing Print Settings for a Widget.
•
      Analyzer — Select this option to include the Mini Analyzer button         on the toolbar. This button enables the users
      to open the data source in the Mini Analyzer.
      This option is supported only when the data source is a pivot table.




104                                                                                                     Creating Dashboards
                                                                                                              Adding Columns


Note:     These options add a button to the toolbar. If you use these options, be sure the toolbar is visible (its display is
          controlled via the Toolbar option in Settings). See Reconfiguring a Widget.




8.4 Adding Columns
A scorecard does not display any data until you add columns. A scorecard column is typically based on a property of the
data source. In some cases, though, a scorecard column simply displays the item name or number and does not use a property
of the data source.
To add a column to a scorecard:
1.   Access the Dashboard Editor and select the widget as described in Reconfiguring a Widget.
2.   Click Scorecard.
3.   Click Columns.
     The system displays a list of any columns defined for this scorecard. For example:




4.   Click the plus sign + button.
     The system displays a dialog box where you specify the column.
5.   For Value, select a property of the data source, type a numeric constant, or type a formula.
6.   Optionally specify the following additional items:
     •   Label — Type a label or optionally click the check box to the right of Label. If you click the check box, the system
         uses the localized name of this property as the label; this option applies only when Value is a data source property.
         If you type a label, note that you can include \n to force a line break in the label.
     •   Hidden — Select this option to hide this value.

     •   Value Column — Select this option to configure the value in this column as the value of the row. This value is
         passed to any custom actions; see Specifying the Value of a Row.
         Select this option for only one data property of the widget.
     •   Format — Type a format string.


7.   Click OK.
8.   Configure the column as described in the rest of this page.

For information on deleting and rearranging columns, see Managing Widget Properties.




Creating Dashboards                                                                                                         105
Adding Scorecard Widgets




8.5 Configuring a Scorecard Column
To configure a scorecard column:
1.    Access the Dashboard Editor and select the widget as described in Reconfiguring a Widget.
2.    Click Scorecard.
3.    Click Columns.
      The system displays a list of any columns defined for this scorecard.
4.    Select the column to configure.
5.    Specify options as described after this list.
6.    Save the dashboard.

The Display option controls most of the other choices for a property. For Display, you can choose one of the following:

    Display Option          Sample                               See
    Item Number                                                  Adding a Column of Row Numbers


    Label                                                        Adding a Column of Row Labels


    Value                                                        Adding a Column of Values


    Arrow                                                        Adding Arrows


    Lamp                                                         Adding Lamps
                                 or
    Trend Line                                                   Adding Trend Lines and Trend Bars


    Trend Bar


    Plot Box                                                     Adding Plot Boxes


    Hidden                  Not applicable; this property is
                            not visible.


The other options are as follows:
•     Value — Specifies the value, if any, to display in this column. Select a property of the data source, type a numeric
      constant, or type a formula.
      You can omit this option if Display is Item Number or Label.
•     Label — Specifies a header for this column. You can include \n to force a line break in this label.

•     Cell Caption — Specifies an optional caption to place within each cell in this column.

      For example:



106                                                                                                    Creating Dashboards
                                                                                          Configuring a Scorecard Column




•   Header Align — Specifies how to align the column header for this column.

•   Align — Specifies how to align the values in this column.

•   Width — Specifies the width of this column.

    You can also modify the widths of the columns in the Size & Appearance menu of the Dashboard Editor.
•   Show As — Controls whether you display the value itself or the value as a percentage of another value, and so on.
    Select one of the following:
    –   Value — Displays Value. This is the default setting.

    –   Conditional — Displays Value if the given property is defined. If the property is not defined, the column is not
        displayed.
    –   Sum — Displays the sum of the values given by Value.

    –   Target — Displays Target Value.

    –   % of Sum — Displays Value as a percentage of the total values given by Value.

    –   % of Target — Displays Value as a percentage of the Target Value for the same row.


•   Summary — Controls what to display, if anything, in the footer, for this column. Select one of the following:

    –   Sum — The summary value is the sum of the values in the column.

    –   Avg — The summary value is the average of the values in the column.

    –   Max — The summary value is highest value in the column.

    –   Min — The summary value is the lowest value in the column.

    –   Value — The summary value is specified in terms of the summary values for other columns. If you select this
        option, the system displays the Summary Value field. In this field, specify a formula that refers to other columns
        in the scorecard. For example:

        =Sales-Cost

        To refer to a column, use the name that you specified for the Label of the column.

•   Format — Specifies how to format numeric values in this column.

•   Style — Controls the color and line style of the graphical objects, if any, in this column. See Specifying Line Styles.

•   Min Value and Max Value — Specify the minimum and maximum values to display if the column displays plot boxes,
    described later in this page.
    Min Value also affects arrows. Max Value also affects lamps.

•   Target Value — Specifies the value to compare with the data values. Select a property of the data source, type a numeric
    constant, or type a formula.
    You can omit this if Display is Item Number or Label.
•   Lower and Upper — Control the appearance of plot boxes, described later in this page.




Creating Dashboards                                                                                                     107
Adding Scorecard Widgets


•     Value Column — Select this if this column contains the value to pass to any custom actions.




8.6 Specifying a Scorecard Formula
You can use formulas in the Value and Target Value options for a scorecard column. The rules are as follows:
•     The first character must be an equals sign (=)
•     The formula can include the following pieces:
      –   Names of data source properties (as given in the Value drop-down list)
          You must enclose the name in square brackets if it includes a space or any character that would be interpreted as
          an operator.
          For example:

          =[Total Sales]/100

      –   Numeric constants such as 100
      –   String constants such as "my string"
      –   Standard mathematical operators: + (addition), - (subtraction), / (division), and * (multiplication)
      –   Logical comparison operators: > (greater than), >= (greater than or equal to), = (equal to), < (less than), and <=
          (less than or equal to)
      –   Parentheses

      The values 0 and "0" are treated as false, and all other numeric and string values are treated as true.
•     The formula can also include the following functions:
      –   IF(test-value,value-if-test-true,value-if-test-false) evaluates a value (test-value) and returns value-if-test-true if the
          logical value is true or returns value-if-test-false if the logical value is false.
          For example, the following formula returns 25:

          =IF(1,25,99)

          The following formula returns either "abc" or "def" depending on the value of the PatCount property:

          =IF(PatCount>1130,"abc","def")

      –   AND(value1,value2,value3, ... ) returns true if all the given values are true.
      –   OR(value1,value2,value3, ... ) returns true if at least one of the given values is true.
      –   CONCAT(value1,value2,value3, ... ) and returns the concatenation of the given values.


You can use formulas in the following locations as well:
•     For a plot box, in the options Min Value, Max Value, Lower, Upper, and Base Value. See Adding Plot Boxes.
•     For a column summary, in the Summary Value option. This option expresses the summary of a column in terms of the
      summaries for other columns.
      In this case, the formula cannot refer to scorecard properties; instead it can refer to scorecard columns, using their
      names given by the Label option.


108                                                                                                         Creating Dashboards
                                                                                     Configuring a Column of Row Numbers




8.7 Configuring a Column of Row Numbers
A scorecard can include a column of row numbers, typically as the first column. The following shows an example:




To create such a column, add a column and configure it with the following options:
•   Display — Select Item Number.

    The column will contain item numbers.
•   Label — Optionally specify the text to use as the column header. You can include \n to force a line break in this label.




8.8 Configuring a Column of Row Labels
A scorecard can include a column of row labels, typically as the first or second column. The following shows an example:




To create such a column, add a column and configure it with the following options:
•   Display — Select Label.

    For a KPI, the column will contain the names of the rows, as shown on the KPI test page.
•   Label — Optionally type the text to use as the title. You can include \n to force a line break in this label.




8.9 Configuring a Column of Values
A typical scorecard includes columns that display numeric values, as in the following example:




Creating Dashboards                                                                                                     109
Adding Scorecard Widgets




To create such a column, add a column and configure it with the following options:
•     Display — Click Value. This is the default setting.

•     Value — Specify the value to display. Select a data source property, type a value, or type a formula.

•     Label — Specify the text to use as the column header. You can include \n to force a line break in this label.

•     Target Value — Optionally specify a target value for use as comparison with the given data value. Select a data source
      property, type a value, or type a formula.
•     Show As — Use any option as described in Configuring a Scorecard Column.

•     Format — Optionally specify a format string.


You use Value Column only when you configure custom actions that require row values. See Specifying the Value of a
Row.




8.10 Configuring Trend Lines and Trend Bars
A scorecard column can display trend lines or trend bars. The following shows an example of trend lines:




The following shows an example of trend bars:




110                                                                                                    Creating Dashboards
                                                                                                   Configuring Plot Boxes




To create such a column, add a column and configure it with the following options:
•   Display — Click Trend Line or Trend Bar.

•   Value — Specify the values to show in the trend line or trend bar. Select a data source property that contains a comma-
    separated list of values.
    Or type a comma-separated list of values.
•   Label — Specify the text to use as the column header. You can include \n to force a line break in this label.

•   Show As — Click Value.


Tip:   You can display trend lines and trend bars only for KPIs, because only KPIs can contain a column of comma-sep-
       arated values. In an MDX-based KPI, you can use the %LIST function to build a comma-separated list.




8.11 Configuring Plot Boxes
A scorecard column can display plot boxes, as in the following example:




To create such a column, add a column and configure it with the following options:
•   Display — Click Plot Box.

•   Value — Specify the value to show in the plot box. Select a data source property, type a value, or type a formula.

•   Label — Specify the text to use as the column header. You can include \n to force a line break in this label.

•   Min Value — Optionally specify the minimum value to display in the plot boxes. The default is zero.

    In the following example, Min Value is –5000, and Max Value is 5000:



Creating Dashboards                                                                                                      111
Adding Scorecard Widgets




•     Max Value — Optionally specify the maximum value to display in the plot boxes. The default is the highest value dis-
      played in the column. See the previous example.
•     Lower — Optionally specify a value to divide the box into lower and middle bands. In the following example, Lower
      is 1000 and Upper is 4000. These options define three bands in the plot boxes: a lower band (below 1000), a middle
      band (between 1000 and 4000), and an upper band (above 4000).




•     Upper — Optionally specify a value to divide the box into middle and upper bands. See the previous example.

•     Target Value — Optionally specify a target value for use as comparison with the given data value; the default is 0.
      Select a data source property, type a value, or type a formula.
      The plot box includes a vertical line to mark the target value, as follows:




      To remove these vertical lines, set Target Value equal to a value that is out of range for the plot boxes.
      Also see the Base Value option for an alternative way to use a comparison value.
•     Base Value — Optionally specify a value to create a visual boundary in the plot boxes. The base value is used as follows:

      –   If the actual column value is less than the base value, the bar is displayed in a contrasting color (red by default).
      –   In all cases, the bar is drawn between the actual column value and the base value.




112                                                                                                       Creating Dashboards
                                                                                                          Configuring Arrows


    The following shows an example in which the base value is 0. This example includes an additional column that shows
    the actual values used in the plot boxes:




    This plot box includes vertical lines at the value 0. The system draws these lines because Target Value is 0, the default.
    The following shows another example in which the base value is 40:




8.12 Configuring Arrows
A scorecard column can display triangular arrows, shown in the following example:




Arrows provide a quick way to see where the given value falls, in a desired range. They work as follows:
•   They use a data source property (or possibly a constant) as a source value.
•   If the Min Value setting is less than zero, then:
    –   If the source value is negative, an arrow is displayed as a downward pointing triangle.
    –   If the source value equals zero, the arrow is not displayed.



Creating Dashboards                                                                                                       113
Adding Scorecard Widgets


      –   If the source value is positive, an arrow is displayed as a upward pointing triangle.

•     If the Min Value setting is greater than or equal to zero, then:
      –   If the source value is less than Min Value, an arrow is displayed as a downward pointing triangle.
      –   If the source value equals Min Value, the arrow is not displayed.
      –   If the source value is greater than Min Value, an arrow is displayed as a upward pointing triangle.


To create such a column, add a column and configure it with the following options:
•     Display — Select Arrow.

•     Value — Specify the value to show in the arrow. Select a data source property, type a value, or type a formula.

•     Label — Specify the text to use as the column header. You can include \n to force a line break in this label.

•     Show As — Use any value as described in Configuring a Scorecard Column.

•     Min Value — Specify the value to control the direction of the arrow as described above.




8.13 Configuring Lamps
A scorecard column can display round lamps, shown in the following example:




Lamps provide a quick way to see where the given value falls, in a desired range. They work as follows:
•     They use a data source property (or possibly a constant) as a source value.
•     If the source value is negative, the lamp is displayed as a red circle.
•     If the source value equals zero, the lamp is not displayed.
•     If the source value is positive, the lamp is displayed as a green circle.
•     The opacity of the circle is determined by the absolute value of the source value, divided by the absolute value of Max
      Value. If Max Value is not specified, the lamp uses the largest value in the column.


To create such a column, add a column and configure it with the following options:
•     Display — Select Lamp or Lamp with Value.

•     Value — Specify the value to show in the lamp. Select a data source property, type a value, or type a formula.

•     Label — Specify the text to use as the column header. You can include \n to force a line break in this label.

•     Show As — Use any value as described in Configuring a Scorecard Column.

•     Max Value — Specify the maximum value to control the opacity of the lamp, as described previously.



114                                                                                                    Creating Dashboards
                                                                         Customizing the Appearance of a Scorecard Widget




8.14 Customizing the Appearance of a Scorecard Widget
The system provides a rich set of options that you can use to customize the appearance of a scorecard widget. To access
these options, access the Dashboard Editor, select the widget as described in Reconfiguring a Widget and then see the
options in the Scorecard section.
•   Scorecard > Size & Appearance — Provides options to control the scorecard overall.

•   Scorecard > Titles — Provides options to control the text and formatting of titles in the scorecard.

•   Scorecard > Colors & Style — Provides options to control colors and line styles in the scorecard.


The following subsections provide details.

Note:    The easiest way to systematically alter the appearance of dashboards is to define and use themes, which are discussed
         in Defining and Using Themes. Themes use many of the options described in the following subsections.


8.14.1 Size & Appearance Options
To customize the overall size and appearance of a scorecard, access the Dashboard Editor, select the widget as described
in Reconfiguring a Widget, click Scorecard > Size & Appearance, and use the options listed there. The following options
are available:
•   Size — Select the size of the scorecard, either Regular or Big.

•   Show Title — Use this option to show or hide the scorecard title.

•   Show Headers — Use this option to show or hide the scorecard headers.

•   Show Footers— Use this option to show or hide the scorecard footers.

•   Row Height — Use this option to control the height of the scorecard rows.

•   Arrow Size — Use this option to control the height of any arrows in the scorecard. You can override this setting and
    the following settings for any individual column in the scorecard.
•   Lamp Size — Use this option to control the height of any lamps in the scorecard.

•   TrendLine Hgt — Use this option to control the height of any trend lines in the scorecard.

•   TrendBars Hgt — Use this option to control the height of any trend bars in the scorecard.

•   Plotbox Height — Use this option to control the height of any plot boxes in the scorecard. In the following example,
    the plot boxes are slightly taller than the default:




    This example also uses Plotbox Value, which controls the height of the value boxes (shown slightly shorter than the
    default).
•   Plotbox Value — Use this option to control the height of the value boxes in any plot boxes in the scorecard. See the
    previous example.




Creating Dashboards                                                                                                       115
Adding Scorecard Widgets


•     Column 1, Column 2, Column 3, and so on — Use these options to control the widths of the respective columns. You
      can also modify the column widths in the Scorecard > Columns menu of the Dashboard Editor.


8.14.2 Title Options
To customize the titles in a scorecard, access the Dashboard Editor, select the widget as described in Reconfiguring a
Widget, click Scorecard > Titles, and use the options listed there. The following options are available:
•     Title — Use this option to specify an optional title within the scorecard.

•     Title Style— Use this submenu to control the style of the scorecard title.

      See Specifying Chart Text Styles.
•     Subtitle — Use this option to specify an optional subtitle within the scorecard.

•     Subtitle Style— Use this submenu to control the style of the scorecard subtitle.

      See Specifying Chart Text Styles.
•     Title Align — Use this option to control the alignment of the title and subtitle. These titles can be left-aligned, centered,
      or right-aligned.
•     Title Box — Use this submenu to add an optional box around the title and subtitle.

      See Specifying Line Styles.
•     Title Image — Use this option to add an optional image to the title.

•     Image Width, Image Height, Image Top, and Image Left — Use these options to control the size and position of the
      optional title image.

Charts have a similar set of options; for examples, see Titles and Labels.


8.14.3 Colors & Style Options
To customize the colors and line styles in a scorecard, access the Dashboard Editor, select the widget as described in
Reconfiguring a Widget, click Scorecard > Colors & Style, and use the options listed there. The following options are
available:
•     Background— Use this submenu to control the style of the background around the scorecard. For example:




116                                                                                                         Creating Dashboards
                                                                     Customizing the Appearance of a Scorecard Widget


•   Stripes— Use this submenu to control the style of the stripes in the scorecard. For example:




•   Separators— Use this submenu to control the style of the separators between the scorecard and the header and footer.
    For example:




•   Label Style— Use this submenu to control the text style of any labels in the scorecard. For example:




Creating Dashboards                                                                                                 117
Adding Scorecard Widgets


•     Value Style— Use this submenu to control the text style of the values in the scorecard. For example:




•     Cell Caption Style— Use this submenu to control the text style of any cell captions in the scorecard. For example:




•     Header— Use this submenu to control the text style of any column headers in the scorecard. For example:




•     TrendLine— Use this submenu to control the style of any trend lines in the scorecard. For example:




•     TrendBars Style— Use this submenu to control the style of any trend bars in the scorecard. For example:




•     Arrow Style— Use this submenu to control the style of any arrows in the scorecard. For example:




118                                                                                                   Creating Dashboards
                                                                      Customizing the Appearance of a Scorecard Widget




•   Lamp Color — Use this option to specify the color of any lamps in the scorecard, for use with positive values. For
    example:




•   Lamp Negative — Use this option to specify the color of any lamps in the scorecard, for use with negative values. See
    the previous example.
•   Lamp Value Style— Use this submenu to control the text style of the values for any lamps in the scorecard. For example:




•   Plotbox > Value Style — Use this submenu to control the style of the values within any plot boxes in the scorecard. In
    the following example, the values are displayed as blue boxes:




•   Plotbox > Below Base Style — Use this submenu to control the style of values below the configured Base Value in any
    plot boxes in the scorecard. In the following example, Base Value is 0 and Below Base Style is bright red:




Creating Dashboards                                                                                                    119
Adding Scorecard Widgets




•     Plotbox > Box Style — Use this submenu to control the style of the enclosing boxes for any plot boxes in the scorecard.
      In the following example, the boxes are purple rather than the default gray:




•     Plotbox > Lower Style — Use this submenu to control the style of the optional lower band in any plot boxes in the
      scorecard. The lower band indicates the values below the given Lower Threshold. In the following example, the lower
      band is red and the middle band is green:




•     Plotbox > Mid Style — Use this submenu to control the style of the optional middle band of any plot boxes in the
      scorecard. The middle band indicates the values above the given Lower Threshold but below the given Upper Threshold.
      See the previous example.
•     Plotbox > Target Style — Use this submenu to control the style of the target line, if any, in any plot boxes in the
      scorecard. For example:




120                                                                                                      Creating Dashboards
                                                                        Customizing the Appearance of a Scorecard Widget


    The position of the target line is controlled by the Target Value option.




Creating Dashboards                                                                                                 121
9
Adding Other Widgets
This page describes how to add other kinds of widgets to a Business Intelligence dashboard.
The Dashboard Editor also provides the Worksheet option, which is no longer documented; worksheets are now deprecated.




9.1 Adding a Calendar Widget
A dashboard can include a calendar widget like the following:




To add a calendar widget:
1.   Click Menu > Add New Widget....
2.   In the left area, click Calendar and then click Calendar.
3.   Optionally specify the basic settings, as described in Adding a Widget to a Dashboard.
4.   Click OK.

When you open a dashboard, this widget displays the current month, for informational purposes.




9.2 Adding a Map Widget
If your cube includes latitude and longitude data, you can include a map widget like the following on your dashboards:




Creating Dashboards                                                                                                 123
Adding Other Widgets




Important:        This widget uses the Google Maps API. Be sure that your usage of this API is consistent with the Terms
                  of Use, which you can access via a link in the widget, shown in the previous picture.

To add a map widget:
1.    Obtain and enter a key for the Google Maps API. See Specifying Basic Settings for more information.
2.    Optionally, in the Analyzer, define a pivot table that includes the columns Latitude and Longitude (not case-
      sensitive).
      These columns should contain latitude and longitude values in decimal format (rather than degree/minute/second format).
      For information on creating pivot tables, see Using the Analyzer.
      You do not have to provide a data source for a map widget. If you provide no data source, the widget appears without
      any pins.
3.    Display the dashboard.
4.    Click Menu > Add New Widget....
5.    In the left area, click Map and then click Map.
6.    For Data source, select the previously defined pivot table.
7.    Optionally specify the basic settings, as described in Adding a Widget to a Dashboard.
8.    Click OK.
9.    Optionally configure the widget further as follows:
      a.   Select the widget, as described in Reconfiguring a Widget.
      b.   Click Widget Settings.
      c.   Specify the following additional options:
           •   Zoom — Initial zoom setting to use. A larger number results in a closer view.

           •   Starting latitude — Initial latitude to display, in degrees.

           •   Starting longitude — Initial longitude to display, in degrees.




124                                                                                                    Creating Dashboards
                                                                                           Adding a Widget That Uses a Portlet


         •    Draggable markers — Controls whether the user can drag the map markers.




9.2.1 Configuring the infoWindow Popup
If the underlying pivot table contains data in addition to latitude and longitude, you can configure the map widget to display
that data. If the user clicks a pin in the map widget, the widget displays a popup window that displays the additional infor-
mation.
1.   Access the Dashboard Editor and select the widget as described in Reconfiguring a Widget.
2.   Click Data Properties.
     The system displays a list of any properties defined for this map widget.
3.   Click the plus sign + button.
     The system displays a dialog box where you specify the property.
4.   Specify the following options:
     •   Label — Optionally specify the text to use as the column header. (Note that you cannot force a line break in this
         label.)
     •   Data Value — Specify the value to display. Select a data source property. You cannot use a static value or a formula
         in this scenario.
     •   Format — Optionally specify a format string.


5.   Click OK.




9.3 Adding a Widget That Uses a Portlet
To add a widget that uses a custom portlet:
1.   Click Menu > Add New Widget....
2.   In the left area, click Portlet. The list expands to show a list of choices. This list shows the short class names for all
     compiled portlets in this namespace.
3.   Click the name of the portlet to add.
4.   Optionally specify the basic settings, as described in Adding a Widget to a Dashboard.
5.   Click OK.

For information on creating portlets, see Implementing InterSystems Business Intelligence.




9.4 Adding a Controls Widget
To add a controls widget:
1.   Click Menu > Add New Widget....




Creating Dashboards                                                                                                          125
Adding Other Widgets


2.    In the left area, click Controls Widget. The list expands to show a list of choices. Click the type of Controls Widget to
      add.
3.    For the Data Source, do one of the following:
      •
          Click the Search button      and then select a data source.
      •   Use the Link to drop-down list to select another widget on the same dashboard.

4.    Optionally specify the basic settings, as described in Adding a Widget to a Dashboard.
5.    Click OK.
6.    Optionally configure the widget further as described in the rest of this page.
7.    Optionally add controls, as described in Adding Widget Controls.

Note that it is not possible to hide the toolbar for a controls widget.




126                                                                                                      Creating Dashboards
10
Defining and Using Themes
The easiest way to systematically alter the appearance of Business Intelligence dashboards is to define and use themes.
This page describes how to do this.




10.1 Overview of Themes
To customize the appearance of your dashboards systematically, you can either specify a set of options for each widget in
each dashboard or you can simply specify the theme that each widget uses. In the latter case, it is necessary only to specify
the style options once, when you define the theme.
A single theme can specify the size of pivot table cells, the color and size of plot lines, background color and border, and
more. The following table summarizes how themes work:

    Widget type             Options determined by the applied theme, if any
    Pivot table widget in   All options in Table Settings; see Customizing the Appearance of a Pivot Table.
    table format
    Pivot table widget in                 *
                            Most options in Chart Settings > Titles & Labels, Chart Settings > Colors & Style, and Chart
    chart format            Settings > Series Details; see Customizing the Appearance of a Chart Widget.

    Speedometer                           *
                            Most options applicable to speedometers; see Customizing Speedometers.
    Text meter                            *
                            Most options applicable to text meters; see Customizing Text Meters.
    Fuel gauge                            *
                            Most options applicable to fuel gauges; see Customizing Fuel Gauges.
    Traffic light                         *
                            Most options applicable to traffic lights; see Customizing Traffic Lights.
    Light bar                             *
                            Most options applicable to light bars; see Customizing Light Bars.
    Smiley face                           *
                            Most options applicable to smiley faces; see Customizing Smileys.
    Scorecard                            *
                            Most options in the Scorecard section; see Customizing the Appearance of a Scorecard
                            Widget.
    Other types             Theme has no effect
*
 In general, the exceptions are options that specify numeric values (such as the Upper Range and Lower Range options for
a meter) and titles.



Creating Dashboards                                                                                                      127
Defining and Using Themes




10.2 Creating a New Theme Definition
To create a new theme definition, possibly empty:
1.    Access the Dashboard Editor and select a widget as described in Reconfiguring a Widget.
      If the dashboard contains a widget with styles that you would like to use in the theme, select that widget. Or if no
      widgets have any styles (yet) that you would like to use, select any widget.
2.    Select Menu > Save Widget to Theme ....
3.    For New Theme, type the name of the theme.
4.    Click OK.

The system creates and saves the theme. The theme contains style settings, if any, copied from the widget. It also updates
the widget to remove the local style settings and to use the theme instead, and it saves the dashboard. The system then
redisplays the dashboard.




10.3 Adding Style Information to a Theme
To add style information to a theme:
1.    Access the Dashboard Editor and select the widget that includes the styles that you want to use.
2.    Select Menu > Save Widget to Theme ....
3.    For Existing Theme, select the theme.
4.    Click OK.

The system copies style settings, if any, from the widget to the theme and saves the theme. It also updates the widget to
remove the local style settings and to use the theme instead, and it saves the dashboard. The system then redisplays the
dashboard.




10.4 Applying a Theme
To apply a theme to a different widget:
1.    Access the Dashboard Editor and select the widget as described in Reconfiguring a Widget.
2.    Click Type and Data Source.
3.    Click Widget Theme.
4.    Click the name of the theme.

The system immediately updates the widget, saves the dashboard, and redisplays the dashboard.




128                                                                                                      Creating Dashboards
                                                                                                     Deleting a Theme




10.5 Deleting a Theme
To delete a theme:
1.   Access the Dashboard Editor and select any widget as described in Reconfiguring a Widget.
2.   Click Type and Data Source.
3.   Click Widget Theme.
4.   Click the X next to the name of the theme.
5.   Click OK to confirm this change.

The system deletes the theme but does not change any dashboards. Any dashboards that use this theme now revert to their
default appearance.




Creating Dashboards                                                                                                129
11
Adding Widget Controls
This page describes how to add controls to widgets in a Business Intelligence dashboard.
For examples of controls and information on where they can be used, see Orientation to Dashboards.

Note:     The following buttons are not controls and are not discussed in this page:

           Button      Discussion
                       Opens the pivot table in the Mini Analyzer.


                       Displays the widget in table format.


                       Displays the widget in chart format.


                       Exports the currently viewed data to Microsoft Excel.


                       Displays the dimension list.


                       Drills down to a lower level in a hierarchy.


          These buttons are specified as settings of the widget, as discussed in Specifying Widget Settings.


          The print button       can be a control or can be specified as a widget setting.




11.1 Adding a Control
To add a control to a widget:
1.   Access the Dashboard Editor and select the widget as described in Reconfiguring a Widget.
2.   Click Controls.
3.   Click the plus sign + button.
     The system displays a dialog box where you specify the control.



Creating Dashboards                                                                                            131
Adding Widget Controls


4.    Specify the options as appropriate for the type of control you need, as described in the rest of this page.
5.    Click OK to add the control.
6.    Optionally save the dashboard.

For reference, this section lists the control options and describes their purposes.
•     Location — Specifies where the control is shown:

      –    Widget (the default) displays the control on the widget toolbar.

           Note:     If you add a control to the widget, be sure the toolbar is visible (its display is controlled via the Toolbar
                     option). See Reconfiguring a Widget.

      –    Dashboard displays the control in the Filters worklist.

           Do not use Dashboard if you have configured this as a zero-worklist dashboard, because the control would not be
           visible to users.
      –    Onclick Event configures the control as an onclick control. No visible indication of the control is given.


•     Target — Specifies which widgets this control affects. Specify one of the following:

      –    If this option is blank, the control affects only the widget that owns it.
      –    If this option is *, the control affects all widgets.
      –    If this option is the name of the widget, the control affects that widget. In this case, use the value given in the
           Widget Name option for that widget.


•     Action — Specifies the action. Custom actions are shown at the end of the list.

•     DataSource — Enables you to provide a control that displays a different pivot table. (Note that this option is available
      only when you reconfigure a control). See Adding a Control to Display a Different Pivot Table.
•     Filter — (if Action is Filter) Specifies the filter for this control to use.

•     Type — Specifies the visual form of the control:

      –    auto — The system chooses the suitable form based on your other selections.

      –    dropdown — The control is shown as a drop-down list.

      –    searchBox — The control is shown as a searchable drop-down list. The user can type a value and then search for
           values that match the input.
      –    radio — The control is shown as a set of radio buttons.

           Note that the radio option is available only when you reconfigure a control.
      –    button — The control is shown as a button.

      –    hidden — The control is not shown.

      –    custom — The control is based on a custom portlet.


•     Custom control — (if Type is custom) — Specifies the portlet to use.

•     Control Label or Icon — Specifies either the text to display above the control or an icon to display next to the control.
      For information on adding icons that can be used here, see Creating Icons.
•     Active When — Specifies when this control is active. Choose one of the following values:

      –    Always — This control is always active.




132                                                                                                        Creating Dashboards
                                                                                                           Reconfiguring a Control


     –   Item Selected — This control is active when the user selects one or more cells in a pivot table. The control is
         inactive otherwise.
     –   1 Listing Item Selected — This control is active when the user selects a single row of a listing. The control is
         inactive otherwise.
     –   Listing Item Selected — This control is active when the user selects one or more rows of a listing. The control is
         inactive otherwise.

•    Control Tooltip — Specifies a tooltip to display when the user hovers the cursor over the control.

•    Control Size — Specifies the width of the control.

•    Read Only — If selected, this option prevents a user from changing the value in this control.

     In this case, the purpose of the control is to indicate the state of the control. Either provide a default value (if applicable)
     or pass a value via the dashboard URL. See Accessing Dashboards from Your Application.
•    Default Value (applies only to filter controls) — Specifies the default filter value. See Adding an Explicit Filter Control.

•    Required (applies only to filter controls) — If this option is enabled, the user must specify a value for the filter. See
     Adding an Explicit Filter Control, later in this page.
     Note that you must also specify Default Value so that the dashboard always has a value for this filter.

InterSystems recommends that widgets that are the target of controls on other widgets do not have their own controls.
Additionally, where possible, you should try to avoid spreading controls among many different widgets on a dashboard.
Not all combinations of these options are suitable. This page provides recommended configurations for specific kinds of
controls.




11.2 Reconfiguring a Control
To reconfigure a control on a widget:
1.   Access the Dashboard Editor and select the widget as described in Reconfiguring a Widget.
2.   Click Controls.
3.   Click the control name.
4.   Make changes as needed. See the previous section for details.
5.   Optionally save the dashboard.




11.3 Adding an Explicit Filter Control
To add a control to filter one or more widgets, add a control as described earlier in this page and configure it as follows:
•    Location — Select either Widget (the default) or Dashboard.

•    Target — If this control is going to automatically refresh the display, do one of the following:

     –   Leave this option blank, if you want to refresh only this widget. This is the default.
     –   Specify * to refresh all widgets.




Creating Dashboards                                                                                                             133
Adding Widget Controls


      –   Specify the name of the widget to refresh (use the value given in the Widget Name option for that widget).

•     Action — Select one of the following:

      –   Apply Filter sets the filter and automatically refreshes the display.

      –   Set Filter sets the filter but does not refresh the display.


•     Filter — Select the filter for this control to use:

      –   For a pivot table created in the Analyzer, the system lists all levels available in the same subject area.
          If there are any named filters in the subject area, the list include the item Named Filters. If you select this option,
          the user will be able to select any one of those named filters.
      –   For a KPI, the system lists all filters defined in the KPI.
      –   For a production business metric, the list includes Instance (the instance to display), MaxHistory (the number of
          historical points to display for the properties that specify AUTOHISTORY), and Properties (the metric property to
          display).

•     Type — Select auto, dropdown, or searchBox.

•     Control Label or Icon — Optionally type the text that you want to display above the control. Or select an icon to display
      next to the control.
•     Read Only — Optionally select this to prevent the users from changing the filter. In this case, the purpose of the filter
      is to indicate how the data is filtered. Either provide a default value or pass a filter value via the dashboard URL. See
      Accessing Dashboards from Your Application.
•     Value Required — If the user must specify a value for this filter, enable the Required option. Also specify a value for
      Default Value so that the dashboard always has a value for this filter.

•     Control Tooltip — Optionally type a tooltip to display when the user hovers the cursor over the control.



11.3.1 Specifying a Default Value
You may optionally type a value into Default Value.
Alternatively, click the magnifying glass. The system displays the following dialog box:




Here do one of the following:
•     Click the magnifying glass under Select a filter value and select a value in the resulting dialog.
•     Type a value in the Enter an MDX Key field. See the table after this list.
•     Select a value from the Use a run-time variable drop-down list, which lists all available runtime variables. (For details
      on creating these, see Implementing InterSystems Business Intelligence.)



134                                                                                                        Creating Dashboards
                                                                                               Adding an OnClick Filter Control


Then click OK.
If you select a runtime variable, it is shown in the Default Value field with an at sign (@) at the beginning. For example:
@DefaultZipCode

Note:      The system assumes that the filter value is a member key rather than a member name. In most cases, the member
           key and member name are the same. For information on seeing the member key, see Finding the Key for a
           Member.
           Also, if a user accesses the dashboard via a URL, any filter values in the URL take precedence over the default
           value specified in this control.

If you type a value into the Enter an MDX Key field, use one of the following forms:

    Scenario                               Expression That Returns This Value
    A single member                        "&[keyval]" where keyval is the key for the member. See Key Values
                                           in the InterSystems MDX Reference.
    A range of members                     "&[keyval1]:&[keyval2]"

    A set of members                       "{&[keyval1],&[keyval2],&[keyval3]}"

    All members of the level except        "%NOT &[keyval]"
    for a specified single member
    All members of the level except        "%NOT{&[keyval1],&[keyval2],&[keyval3]}"
    for a specified subset




11.4 Adding an OnClick Filter Control
Note:      An onclick filter control is supported only in a widget that uses a pivot table as its data source.

To add an onclick filter control, add a control as described earlier in this page and configure it as follows:
•     Location — Click Onclick Event.

•     Target — Do one of the following:

      –   Specify * to refresh all widgets.
      –   Specify the name of the widget to refresh (use the value given in the Widget Name option for that widget).

•     Action — Select Apply Filter.

      Note:    You do not need to select the filter to apply. The system automatically filters based on the complete context
               in which the user selects; that is, the system considers the row and column context as well as any currently
               active filters applied to the widget. Furthermore, if you do specify a filter within the widget configuration,
               that filter is ignored.



11.4.1 Example: Listing with OnClick Filter
As an example, see the sample dashboard Listing with OnClick Filter. This dashboard is defined as follows:
•     In the dashboard definition, the upper widget has an onclick filter whose target is the lower widget.




Creating Dashboards                                                                                                        135
Adding Widget Controls


•     The pivot table shown in the top widget — Use in Dashboards/Product Info — displays product categories as rows.
•     The pivot table shown in the bottom widget — Use in Dashboards/HoleFoods Sales Listing — is defined as an unfiltered
      detail listing that does not auto-execute. To define a pivot table in this way, do the following in the Analyzer:
      1.   Create a pivot table that uses the desired cube and that has no column or row definition and that also has no filter,
           like this:




      2.   Clear the Auto-execute button.
      3.
           Click the listing button         .
           You can perform steps 2 and 3 in either order.
      4.   Save this pivot table.




11.5 Adding a Refresh Control
To add a control to refresh the dashboard (which is necessary if you have controls that set filters but that do not apply them
automatically), add a control as described earlier in this page and configure it as follows:
•     Location — Select either Widget (the default) or Dashboard.

•     Target — Do one of the following:

      –    Leave this option blank, if you want to refresh only this widget. This is the default.
      –    Specify * to refresh all widgets.
      –    Specify the name of the widget to refresh (use the value given in the Widget Name option for that widget).

•     Action — Select Refresh.

•     Type — Select auto or timer.

      –
           If you select auto, the control appears as follows:
      –    If you select timer, type a value into Time (in seconds). In this case, the refresh control will automatically run at
           the specified interval.

•     Control Tooltip — Optionally type a tooltip to display when the user hovers the cursor over the button.




136                                                                                                       Creating Dashboards
                                                                                     Adding a Control to Print the Dashboard


Tip:    To use a custom button instead of the standard icon, specify the Type as button and specify a value for Control Label
        or Icon.




11.6 Adding a Control to Print the Dashboard
You can add controls with which users can print parts or all of the dashboard. The output is a PDF file (opened in a browser
window) with one page for each widget.
To add such a control, add a control as described earlier in this page and configure it as follows:
•   Location — Select either Widget (the default) or Dashboard.

•   Target — Specify a list of the names of the widgets to print. The first widget in the list determines the print settings.

    Or, if you want to print all the widgets and do not need to control the print settings, type *.
    If you leave Target, only the current widget is printed. If you need only to print a single widget, however, it is simpler
    to just enable the print setting for that widget; see Customizing Print Settings for a Widget.
•   Action — Select Print Widget.

•   Type — Select auto, dropdown, or button, as applicable for the chosen action.

    The default type is a small button with a picture on it.
•   Control Label or Icon — Optionally type the text that you want to display on the control. Or select an icon to display
    next to the control.
•   Control Tooltip — Optionally type a tooltip to display when the user hovers the cursor over the control.


Then save the dashboard.
For further details and requirements, see the section Customizing Print Settings for a Widget.




11.7 Adding a Control to Reload the Dashboard
To add a control to reload the dashboard, add a control as described earlier in this page and configure it as follows:
•   Location — Select either Widget (the default) or Dashboard.

•   Target — Ignore this option. All widgets are refreshed.

•   Action — Select Reload Dashboard.

•   Type — Select auto or timer.

    –
         If you select auto, the control appears as follows:
    –    If you select timer, type a value into Time (in seconds). In this case, the reload control will automatically run at
         the specified interval.

•   Control Tooltip — Optionally type a tooltip to display when the user hovers the cursor over the button.


Tip:    To use a custom button instead of the standard icon, specify the Type as button and specify a value for Control Label
        or Icon.



Creating Dashboards                                                                                                        137
Adding Widget Controls




11.8 Adding a Control to Change the Display Type
You can add controls with which users can change the display type from one chart to another. You can provide two different
kinds of controls:
•     A drop-down list from which the user can choose a type.
•     A button that immediately switches to a different type. In this case, you typically provide at least two buttons, so that
      the user can easily return to the original type.

To add such a control, add a control as described earlier in this page and configure it as follows:
•     Location — Select either Widget (the default) or Dashboard.

•     Target — Leave this blank. Or type * if this control should affect all widgets in this dashboard.

•     Action — Select Set Chart Type or Choose Chart Type. The first option adds a button (which you configure later) to
      set the display type to a specific type. The second option adds a drop-down list (which you configure later) of display
      types.
•     Type — Select auto, dropdown, or button, as applicable for the chosen action.

      For Set Chart Type, the default type is dropdown, and for Choose Chart Type, the default type is a small button with a
      picture on it.
•     Control Label or Icon — Optionally type the text that you want to display on the control. Or select an icon to display
      next to the control.
•     Control Tooltip — Optionally type a tooltip to display when the user hovers the cursor over the control.


Then select the control again and display the Control menu. Select Chart Type. This displays a list of chart types, which
includes the pivot table type. Then:
•     If Action is Set Chart Type, click a single type.
•     If Action is Choose Chart Type, click multiple types and then click Apply Selection.
      To unselect a given type, click it a second time. To unselect all types, click Clear Selection.

Then save the dashboard.




11.9 Adding a Control to Change the Row or Column Sort
In a pivot table widget, if a user double-clicks a column header in a pivot table, the system automatically sorts the pivot
table by the data in that column. No configuration is needed for this.
You can also add a control that affects the row or column sort. To add such a control, add a control as described earlier in
this page and configure it as follows:
•     Location — Select either Widget (the default) or Dashboard.

•     Target — Leave this blank. Or type * if this control should affect all widgets in this dashboard.

•     Action — Select Row Sort or Column Sort.

•     Type — Select auto (which becomes a drop-down list) or dropdown.




138                                                                                                       Creating Dashboards
                                                                      Adding a Control to Change the Row or Column Count


•   Control Label or Icon — Optionally type the text that you want to display on the control. Or select an icon to display
    next to the control.
•   Control Tooltip — Optionally type a tooltip to display when the user hovers the cursor over the control.




11.10 Adding a Control to Change the Row or Column
Count
For pivot table widgets, to add a control that changes the row or column count, add a control as described earlier in this
page and configure it as follows:
•   Location — Select either Widget (the default) or Dashboard.

•   Target — Leave this blank. Or type * if this control should affect all widgets in this dashboard.

•   Action — Select Row Count or Column Count.

•   Type — Select auto (which becomes a type-in box) or dropdown.

•   Control Label or Icon — Optionally type the text that you want to display on the control. Or select an icon to display
    next to the control.
•   Control Tooltip — Optionally type a tooltip to display when the user hovers the cursor over the control.




11.11 Adding a Control to Change the Row or Column
Specification
For widgets that display pivot tables (rather than other data sources), you can add a control that enables the user to change
the specification for the rows or columns of the pivot table. To add such a control, add a control as described earlier in this
page and configure it as follows:
•   Location — Select either Widget (the default) or Dashboard.

•   Target — Leave this blank. Or type * if this control should affect all widgets in this dashboard.

•   Action — Select Set Row Spec or Set Column Spec.

•   Type — Select auto (which becomes a button) or select button.

•   Row Spec or Column Spec (as appropriate; this option is available only when you reconfigure a control) — Specify an
    MDX set expression. For example:

    [gend].[h1].[gender].MEMBERS

    For another example:

    {MEASURES.[avg test score],MEASURES.[avg allergy count]}

    Do not include the keyword NON EMPTY. Also note that the set expression does not include ON ROWS or ON COLUMNS.
    For details, see Set Expressions.




Creating Dashboards                                                                                                        139
Adding Widget Controls


      If this setting is an empty string, the system ignores the specification and uses the specification defined in the original
      data source.
•     Control Label or Icon — Optionally type the text that you want to display on the control. Or select an icon to display
      next to the control.
•     Control Tooltip — Optionally type a tooltip to display when the user hovers the cursor over the control.


Note:      Such controls are supported only for widgets that use pivot tables as the data source. Also note that it is not
           practical to use Set Column Spec or Choose Column Spec (see the subsection) with meters and scorecards because
           these options change the property names of the data source.


11.11.1 Variation: Providing a List of Choices
To provide a similar control that provides a list of choices for the row or column specification:
1.    Create a term list to hold the choices.
      For each term list item, specify Key as the name of the specification and specify Value as an MDX set expression. For
      example:




2.    Use the preceding steps, with the following changes:
      •   Action — Select Choose Row Spec or Choose Column Spec.

      •   Type — Select auto (which becomes a drop-down list), dropdown, or radio (if there is a small number of choices).
          The radio option is available only when you reconfigure a control.
      •   Row Spec List or Choose Column Spec (as appropriate; this option is available only when you reconfigure a control)
          — Select the term list that you created for this purpose.




11.12 Adding a Control to Set a Pivot Variable
Pivot variables provide another way for your end users to interact with your dashboards. A pivot table can be defined so
that its underlying query uses pivot variables in selected parts of the query. (Similarly, an MDX-based KPI can use pivot
variables in the same way.) When a dashboard includes this pivot table, that dashboard can include a pivot variable control,
with which the user can change the value of the corresponding pivot variable. The system simply substitutes the given value
into the query, executes the query, and then redisplays the pivot table.
To add a control to set a pivot variable, add a control as described earlier in this page and configure it as follows:
•     Action — Select Apply Pivot Variable.

•     Pivot Variable — Select the pivot variable.

•     Control Label or Icon — Optionally type the text that you want to display on the control. Or select an icon to display
      next to the control.


140                                                                                                       Creating Dashboards
                                                                           Adding a Control to Display a Different Pivot Table


•    Control Tooltip — Optionally type a tooltip to display when the user hovers the cursor over the control.


The control is useful only if the data source for the widget uses the given pivot variable.




11.13 Adding a Control to Display a Different Pivot Table
For a pivot table widget, you can provide a control that displays a different pivot table as the data source. The original data
source does not have to be a pivot table. To add a control to display a specific pivot table in a widget, add a control as
described earlier in this page and configure it as follows:
•    Location — Select either Widget (the default) or Dashboard.

•    Target — Leave this blank.

•    Action — Select Set Data Source.

•    DataSource (this option is available only when you reconfigure a control) — Select the pivot table.

•    Type — Select auto or button.

•    Control Tooltip — Optionally type a tooltip to display when the user hovers the cursor over the control.


Note:     Such controls are supported only for pivot table widgets.


11.13.1 Variation: Providing a List of Choices
To provide a similar control that provides a list of choices:
1.   Create a term list to hold the choices.
     For each term list item, specify Key as the name of the specification and specify Value as the name of a pivot table,
     ending with .pivot
     For example:




2.   Use the preceding steps, with the following changes:
     •   Action — Select Choose Data Source.

     •   Type — Select auto (which becomes a drop-down list), dropdown, or radio (if there is a small number of choices).

     •   DataSource List (this option is available only when you reconfigure a control) — Select the term list that you
         created for this purpose.




Creating Dashboards                                                                                                        141
Adding Widget Controls




11.14 Adding a Control to Display a Listing
You can display listings from any pivot table widget whose data source defines a listing.

Important:        A map listing uses the Google Maps API. Be sure that your usage of this API is consistent with the Terms
                  of Use, which you can access via a link displayed in this listing.

Note that in order to use the Google Maps API, you must obtain an API key. See Specifying Basic Settings for more
information.
To add a control that displays a listing, add a control as described earlier in this page and configure it as follows:
•     Location — Select either Widget (the default) or Dashboard.

•     Target — Leave this blank.

•     Action — Select Show Listing or Show Geo Listing (which shows a map listing).

      Then choose the listing from the drop-down list to the right.
•     Type — Select auto.


      For a regular listing, this control appears as follows:


      For a map listing, this control appears as follows:
•     Control Tooltip — Optionally type a tooltip to display when the user hovers the cursor over the control.


Tip:      To use a custom button instead of the standard icon, specify the Type as button and specify a value for Control Label
          or Icon.




11.15 Adding a Control to Display the Pivot Analysis
Window
For a widget that displays a pivot table, you can add a control that displays the Pivot Analysis window. To add such a
control, add a control as described earlier in this page and configure it as follows:
•     Location — Select either Widget (the default) or Dashboard.

•     Target — Leave this blank.

•     Action — Select Pivot Analysis.

•     Analysis — Select the analysis option to display, from the following:

      –    Cluster — Performs a cluster analysis.

      –    Distribution — Performs a distribution analysis.

      –    Regression — Performs a regression analysis.

      –    Content Analysis — Performs a Text Analytics content analysis. This option is available only if the pivot table is
           based on a subject area that includes unstructured data.




142                                                                                                      Creating Dashboards
                                                                              Adding a Control to Display Another Dashboard


    –    Entity Analysis — Performs a Text Analytics entity analysis. This option is available only if the pivot table is based
         on a subject area that includes unstructured data.

    For information on these options, see Using the Pivot Analysis Window.
    If you do not choose an option, the user can select any option. If you do choose an option, the user sees only that option.
•
    Type — Select auto (which is shown as the             button in this case).
•   Control Tooltip — Optionally type a tooltip to display when the user hovers the cursor over the control.




11.16 Adding a Control to Display Another Dashboard
To add a control that displays another dashboard, add a control as described earlier in this page and configure it as follows:
•   Location — Select either Widget (the default) or Dashboard.

•   Target — Leave this blank.

•   Action — Select View Dashboard.

•
    Dashboard — Click the Search button         , click the dashboard, and click OK.
•   Type — Select button or auto (which is shown as a button in this case).

•   Control Label or Icon — Optionally type the text that you want to display on the control. Or select an icon to display
    next to the control.
•   Control Tooltip — Optionally type a tooltip to display when the user hovers the cursor over the control.


Note:    You can also configure a pivot table widget so that you can double-click a cell and drill to another dashboard.
         See Adding Pivot Table Widgets.


11.16.1 Passing Values
To pass values from a dashboard to a web page, include the following tokens in the URL:

$$$VALUELIST
         The system replaces this token with a comma-separated set of values for the selected rows of the widget, as follows:
         •    For a scorecard widget, the values are taken from the property that is configured with Value Column.
         •    For a pivot table widget that displays a listing, the values are taken from the listing IDs.
         •    For a pivot table widget that displays a KPI, the values are taken from the property that is configured with
              Value Column, if any. Otherwise the values are taken from the first column.

         •    In other scenarios, $$$VALUELIST does not have values.

         The values are assumed not to contain commas.
         As a simple example, the URL could be as follows:

         http://www.google.com/search?q=$$$VALUELIST




Creating Dashboards                                                                                                        143
Adding Widget Controls


$$$CURRVALUE
          The system replaces this token with the current value of the widget, as follows:
          •    For a scorecard widget, the value is taken from the property that is configured with Value Column.
          •    For a pivot table widget that displays a detail listing, the value is taken from the first selected cell that was
               displayed before the listing was shown.
          •    For other pivot table widgets, the value is taken from the first selected cell.
          •    In other scenarios, $$$CURRVALUE does not have values.

Note:      $$$VALUELIST and $$$CURRVALUE are not macros. They are replaced at run time, not at compile time.




11.17 Adding a Control to Display a Web Page
To add a control that displays a web page, add a control as described earlier in this page and configure it as follows:
•     Location — Select either Widget (the default) or Dashboard.

•     Target — Leave this blank.

•     Action — Select Navigate.

•     URL — Type the URL.

•     Type — Select button or auto (which is shown as a button in this case).

•     Control Label or Icon — Optionally type the text that you want to display on the button. Or select an icon to display
      next to the control.
•     Control Tooltip — Optionally type a tooltip to display when the user hovers the cursor over the control.




11.18 Adding a Control to Perform a Custom Action
To add a control that performs a custom action, add a control as described earlier in this page and configure it as follows:
•     Location — Select Widget (the default), Dashboard, or Onclick Event.

•     Target — Leave this blank.

•     Action — Select the custom action. The custom actions are at the end of the list.

      For information on creating custom actions, see Implementing InterSystems Business Intelligence.
•     Type — Select an option as follows:

      –   If Location is Widget or Dashboard, select button or auto (which is shown as a button in this case).
      –   Otherwise, ignore Type.

•     Control Label or Icon — Optionally type the text that you want to display on the button. Or select an icon to display
      next to the control.
•     Control Tooltip — Optionally type a tooltip to display when the user hovers the cursor over the control.




144                                                                                                        Creating Dashboards
                                                                                                              Hiding a Control



11.18.1 Specifying the Value of a Row
In some cases, a custom action might require information about the context — that is, the row that the user selected before
launching the action. (Other actions operate the same way no matter what the context is.) When you use custom actions,
make sure that you know whether this context is required.
If a custom action requires context, do the following to specify which column contains the value to pass to the actions:
1.   Identify the column or property to use as the value.
2.   Reconfigure that column or property and select the Value Column option.

Do not select the Value Column option for more than one property or column in the same widget; if you do, the result is
indeterminate.




11.19 Hiding a Control
Sometimes it is useful to add a control, specify a default value, and hide it. To hide a control, for Type, select Hidden.




Creating Dashboards                                                                                                          145
