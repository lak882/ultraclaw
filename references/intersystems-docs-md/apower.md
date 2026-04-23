  Connect Data Stored in an
InterSystems Product to Power
             BI
                              Version 2026.1
                               2026-04-20




   InterSystems Corporation One Congress Street Boston MA 02114 www.intersystems.com
Connect Data Stored in an InterSystems Product to Power BI
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
        Connect Data Stored in an InterSystems Product to Power BI......................................................... 1
           1 Introduction to the Connector ....................................................................................................... 1
           2 Connect to InterSystems IRIS ....................................................................................................... 1
           3 Browse Your Data .......................................................................................................................... 2
           4 Publish Reports and Dashboards Using Your Data ....................................................................... 2
           5 Troubleshoot the Connector .......................................................................................................... 2
                5.1 Cannot Connect to Data Source for Existing Report or Dashboard After Update .............. 2
                5.2 Missing Tables in the Navigator .......................................................................................... 3
                5.3 Missing Cubes in the Navigator .......................................................................................... 3
                5.4 Dimension Hierarchy Not Appearing in the Report Designer ............................................ 3
                5.5 Multilevel Dimension Hierarchy Not Functioning Correctly ............................................. 3
                5.6 Access Denied Error Appears When You Attempt to Connect to InterSystems IRIS ......... 3
                5.7 Power BI Service Cannot Retrieve Data for a Report or Dashboard .................................. 3




Connect Data Stored in an InterSystems Product to Power BI                                                                                                   iii
Connect Data Stored in an InterSystems
Product to Power BI
This page describes how to access data stored in an InterSystems® product in Power BI using the InterSystems® Health
Insight Connector.




1 Introduction to the Connector
The InterSystems Health Insight Connector for Power BI is a custom connector for InterSystems products. It allows you
to use Microsoft Power BI to access and create reports on regular relational tables as well as InterSystems IRIS Business
Intelligence cube data. It includes full DirectQuery support when querying either type of data. The connector is included
with Power BI Desktop.

Important:       Prior to July 2024, the InterSystems Health Insight Connector was distributed as the InterSystems IRIS
                 (Beta) connector. If your version of Power BI Desktop lists both connectors as options in the Get Data
                 menu, select the newer connector (InterSystems Health Insight).
                 To continue using a report or dashboard which was created using the beta connector, you must update it
                 to use the InterSystems Health Insight Connector instead. See Cannot Connect to Data Source for Existing
                 Report or Dashboard After Update.




2 Connect to InterSystems IRIS
Prior to connecting to InterSystems IRIS from Power BI Desktop, ensure that you have an InterSystems IRIS ODBC driver
installed on your system.
Note the following:
•    The Health Insight Connector does not require you to set up a DSN for operation; only the driver itself is necessary.
•    Ensure that you have an InterSystems IRIS ODBC35 driver installed. If you are unsure of which driver to download,
     please contact the InterSystems Worldwide Response Center (WRC).

In order to connect to InterSystems IRIS from Power BI Desktop, do the following:
1.   Open Power BI Desktop and click Get Data > More... > InterSystems Health Insight.
2.   Select Connect.
3.   Enter connection information for your InterSystems IRIS instance. Here, Host (IP Address) is the IP address of the host
     for your InterSystems IRIS instance, Port is the instance’s superserver port, and Namespace is the namespace where
     your Business Intelligence data is located. Accept all other options as default.
4.   Upon your first connection to an instance of InterSystems IRIS, an authentication dialog will appear. Choose Basic
     and enter your InterSystems IRIS credentials.




Connect Data Stored in an InterSystems Product to Power BI                                                                   1
Browse Your Data




3 Browse Your Data
If you have successfully connected to InterSystems IRIS, Power BI will display the database Navigator dialog. You can
browse relational tables by selecting Tables. You can expand packages in the left pane to select tables and/or views that
you want to include in your Power BI report.
Alternatively, you can view available InterSystems IRIS BI cubes by selecting Cubes in the left pane. Expanding the Cubes
option lists all available InterSystems IRIS Business Intelligence cubes in the current namespace. Note that cubes or subject
areas with certain features that cannot be supported through SQL access, such as programmatic filters, are excluded from
the list.
When you expand a cube, you will see the star schema representation of the cube, including regular dimensions and a fact
table with all regular measures for the cube. Note that some columns with internal identifiers are removed.




4 Publish Reports and Dashboards Using Your Data
Using the Power BI cloud service, you can share reports and dashboards which incorporate data from your InterSystems
IRIS cubes and tables. To do so, install and configure a data gateway according to the instructions provided by the Microsoft
documentation. Your data gateway and your data sources (including InterSystems IRIS) must be registered on the Manage
connections and gateways page of the Power BI service.

After you Publish your report or dashboard using Power BI Desktop, access the Gateway connection settings for the asso-
ciated dataset in the Power BI service and manually add a mapping to your InterSystems IRIS data source.




5 Troubleshoot the Connector
This section provides guidance regarding some common problems you may encounter when using the InterSystems Health
Insight Connector for Power BI.


5.1 Cannot Connect to Data Source for Existing Report or Dashboard After
Update
If you have created a report or dashboard which used the InterSystems IRIS (Beta) connector to access data on an InterSystems
IRIS instance, attempts to access that report or dashboard after updating to the July 2024 release of Power BI will yield an
error. This is because the beta connector has been removed, so Power BI will be unable to load the model for the report or
dashboard because it will be unable to connect to your InterSystems IRIS data source.
To restore access to a report or dashboard that you created using the beta connector, update it to use the InterSystems Health
Insight Connector by performing the following steps:
1.   Add the data source using the InterSystems Health Insight Connector by following the instructions described in Connect
     to InterSystems IRIS.
2.   For each query in the report or dashboard:
     a.   Update the query’s source so that it is IntersystemsHealthInsight.Database instead of IRIS.Database.

          Note:    Source names are case sensitive.




2                                                             Connect Data Stored in an InterSystems Product to Power BI
                                                                                                Troubleshoot the Connector


    b.   As needed, update the connector’s connection detail parameters, and provide connection credentials.

    For guidance editing queries, refer to the Microsoft Power BI documentation: https://learn.microsoft.com/en-us/power-
    bi/transform-model/desktop-query-overview.


5.2 Missing Tables in the Navigator
The InterSystems Health Insight Connector for Power BI excludes system tables and tables associated with InterSystems
IRIS Business Intelligence cubes from the regular Tables menu. Scrubbed and annotated versions of the latter are available
through the Cubes menu. If you need access to a table or a field not listed in the Navigator, you can add it manually with
a custom query or use Power BI’s generic ODBC connector.


5.3 Missing Cubes in the Navigator
The InterSystems Health Insight Connector for Power BI leverages the relational projects of InterSystems Business Intelli-
gence cubes to make them available for use in Power BI. Some cube features, like programmatic filters, cannot be supported
through these projections and are therefore left out of the list. Please contact the WRC if you encounter a cube where this
behavior is not appropriate.


5.4 Dimension Hierarchy Not Appearing in the Report Designer
Power BI does not currently allow seeding dimension information from a connector.


5.5 Multilevel Dimension Hierarchy Not Functioning Correctly
When a dimension has multiple levels, these levels are usually represented by separate dimension tables (snowflake schema).
While foreign key relationships exist between the fact table and each dimension level and between the different levels of
the dimension, Power BI can only choose one path from a fact table to a higher dimension level as the “active relationship”,
and may choose the wrong one, leading to unexpected query results. To fix the active relationship, click Manage Relationships
in Power BI Desktop and de-activate the direct links between a fact table and higher-level dimension tables. Then, activate
the correct relationships one by one. For more information, see the Microsoft documentation.


5.6 Access Denied Error Appears When You Attempt to Connect to InterSystems
IRIS
To connect to InterSystems IRIS from Power BI Desktop, you must have EXECUTE privileges on the following stored
procedures:
•   %DeepSee_SQL.GetCubes

•   %DeepSee_SQL.GetDimensionTables

•   %DeepSee_SQL.GetDimensionColumns

•   %DeepSee_SQL.GetUnsupportedFeatures

An administrator can use the GRANT command to grant privileges to you.


5.7 Power BI Service Cannot Retrieve Data for a Report or Dashboard
At this time, to populate a published report or dashboard with data from the InterSystems Health Insight Connector for
Power BI, you must manually create a mapping between the associated dataset and your InterSystems IRIS data source, as



Connect Data Stored in an InterSystems Product to Power BI                                                                 3
Troubleshoot the Connector


described in Publish Reports and Dashboards Using Your Data. Note that if you have already registered InterSystems IRIS
as a data source within the Power BI service, this action may create a duplicate entry for your InterSystems IRIS data source.
After you have successfully established access to the InterSystems IRIS data included within the dataset, you can specify
either entry and then remove the duplicate.




4                                                             Connect Data Stored in an InterSystems Product to Power BI
