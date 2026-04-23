Using the SAP Java Connector
        in Productions
                              Version 2026.1
                               2026-04-20




   InterSystems Corporation One Congress Street Boston MA 02114 www.intersystems.com
Using the SAP Java Connector in Productions
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
        1 Overview of SAP Java Connector ..................................................................................................... 1
        2 Setup Tasks for the SAP Java Connector ......................................................................................... 3
            2.1 Setting Up the Java Gateway ...................................................................................................... 3
            2.2 Installing the SAP JCo Jar File .................................................................................................. 4
            2.3 Generating Proxy Classes for SAP JCo ..................................................................................... 4
            2.4 Testing the SAP Connection ....................................................................................................... 4
        3 Using the SAP Java Connector .......................................................................................................... 7
            3.1 Basics ......................................................................................................................................... 7
            3.2 Settings for EnsLib.JavaGateway.Service .................................................................................. 7
            3.3 Settings for EnsLib.SAP.Operation ............................................................................................ 8




Using the SAP Java Connector in Productions                                                                                                                          iii
1
Overview of SAP Java Connector
SAP Java Connector (SAP JCo) is a Java-based component that supports communication with an SAP Server in both
directions. InterSystems provides components that you can add to a production to enable the production to communicate
with SAP JCo, and thus with an SAP Server. The following picture shows the architecture:

           Production                                                                   Key:
                                                  Other business hosts
                                                                                               Provided by Int...

                                        messages carrying...

                                                                                               Provided by SAP


                         EnsLib....                    EnsLib....



           Start/st...
                                                                    TCP/IP


                                      Java Gateway                            SAP JCo                          SAP

                                                                    run API                    TCP/IP


The architecture includes the Java Gateway, which must be running.
To communicate with SAP JCo, the production must include the following items:
•   EnsLib.SAP.Operation, which communicates via TCP/IP with the Java Gateway.

•   EnsLib.JavaGateway.Service, which starts and stops the Java Gateway.

    This business host performs an additional function: its settings indicate the location of the Java Gateway. When correctly
    configured, the EnsLib.SAP.Operation business host retrieves those settings and uses them. Thus it is not necessary to
    set any environment variables.
    Unlike most business hosts in a production, EnsLib.JavaGateway.Service does not handle any production messages.




Using the SAP Java Connector in Productions                                                                                 1
2
Setup Tasks for the SAP Java Connector
Before you can use the SAP components in a production, you must perform the setup activities discussed on this page.
To access SAP, it is necessary to provide a username and password. This means that you must also create production cre-
dentials that contain an SAP username and password. See Defining Production Credentials.




2.1 Setting Up the Java Gateway
The Java Gateway server runs within a JVM, which can be on the same machine as InterSystems IRIS or on a different
machine. Complete the following setup steps on the machine on which the Java Gateway will run:
1.   Install the Java Runtime Environment (for example, JRE 1.8.0_67).
2.   Make a note of the location of the installation directory for JRE. This is the directory that contains the subdirectories
     bin and lib.

     This is the value that you would use for JAVA_HOME environment variable. For example: c:\Program
     Files\Java\jre8

     You use this information later when you configure your production.
3.   Also make a note of the Java version. If you are uncertain about the Java version, open a DOS window, go to the bin
     subdirectory of your Java installation, and enter the following command:

     java.exe -version

     You should receive output like the following, depending on your platform:

     java version "1.8.0_67"
     Java(TM) SE Runtime Environment (build 1.8.0_67-b24)
     Java HotSpot(TM) 64-Bit Server VM (build 23.19-b22, mixed mode)


It is not necessary to set any environment variables. To access the JVM, InterSystems IRIS uses information contained in
the production.




Using the SAP Java Connector in Productions                                                                                  3
Setup Tasks for the SAP Java Connector




2.2 Installing the SAP JCo Jar File
Obtain, from SAP, the SAP Java Connector 3.x, as appropriate for your operating system. Generally, this is provided as a
compressed file. Uncompress it and place the contents in a convenient location. The directory should contain the following
items:
•    examples subdirectory

•    javadoc subdirectory

•    Readme.txt file

•    sapjco3.dll file

•    sapjco3.jar file

•    sapjcomanifest.mf file




2.3 Generating Proxy Classes for SAP JCo
To communicate with SAP JCo, your interoperability-enabled namespace must contain proxy classes that represent SAP
JCo. To generate these classes, do the following:
1.   Start the Java Gateway.
     The easiest way to do this is as follows:
     a.   Create a simple production that contains only one business host: EnsLib.JavaGateway.Service. See EnsLib.Java-
          Gateway.Service Settings.
     b.   Start the production, which starts the Java Gateway.

2.   In the Terminal, change to your interoperability-enabled namespace and use the ImportSAP() method of
     EnsLib.SAP.BootStrap, as follows:

     do ##class(EnsLib.SAP.BootStrap).ImportSAP(pFullPathToSAPJarFile,pPort,pAddress)

     Where:
     •    pFullPathToSAPJarFile is the full path to the SAP Jar file.
     •    pPort is the port used by the Java Gateway.
     •    pAddress is the IP address used by the Java Gateway.




2.4 Testing the SAP Connection
To test the SAP connection, do the following in the Terminal (or in code):
1.   Create an instance of EnsLib.SAP.Utils, which is the class that the SAP business operation uses internally to connect
     to SAP.
2.   Set the following properties of that instance. These are string properties unless otherwise noted.


4                                                                             Using the SAP Java Connector in Productions
                                                                                             Testing the SAP Connection


     •   SAPClient—SAP Client e.g 000.

     •   SAPUser—Username that has access to the SAP server.

     •   SAPPassword—Password for the user.

     •   SAPLanguage

     •   SAPHost— Host name or IP address of the SAP server.

     •   SAPSystemNumber—SAP SystemNumber e.g 00.

     •   JavaGatewayAddress—IP address or name of the machine where the JVM to be used by the Java Gateway server
         is located. Or specify this as the name of the external language server for Java and leave JavaGatewayPort black.
         For external language servers, Managing External Server Connections.
     •   JavaGatewayPort—Port used by the Java Gateway. Or leave this blank if JavaGatewayAddress is an external
         language server name.
     •   SAPTransactionAutoCommit—Specifies whether to execute the BAPI "BAPI_TRANSACTION_COMMIT" after
         a successful BAPI/RFC-call. This property is %Boolean.

3.   Call the PingSAP() method of your instance. This method connects to SAP and performs a dynamic invocation of the
     STFC_CONNECTION function. It returns a %Status.




Using the SAP Java Connector in Productions                                                                             5
3
Using the SAP Java Connector
This page describes how to add the required components to your production so that it can send requests to SAP. Also see
Setup Tasks.




3.1 Basics
Add the following business hosts to your production.
•   The business service EnsLib.JavaGateway.Service. Configure this business host as described later on this page.
•   The business operation EnsLib.SAP.Operation.
    Configure this business host as described in later on this page.
•   One or more business hosts that send SAP request messages to EnsLib.SAP.Operation, as needed.
    Use the message classes that you generated. Your business hosts should create instances of these classes, set properties
    as applicable, and send the messages to the instance of EnsLib.SAP.Operation.




3.2 Settings for EnsLib.JavaGateway.Service
Configure the settings for EnsLib.JavaGateway.Service so that it can find the Java Gateway. These settings are:

ExternalServerName
         The value of this setting should be an external language server name as described in Managing External Server
         Connections.

Stop Named Gateway When Stopping
         Determines if an attempt will be made to stop the specified named server when this business host stops. The default
         is off.




Using the SAP Java Connector in Productions                                                                               7
Using the SAP Java Connector




3.3 Settings for EnsLib.SAP.Operation
EnsLib.SAP.Operation sends requests to SAP JCo, via the Java Gateway. For this business host, specify the following settings:

SAPClient
         SAP Client e.g 000.

SAPCredentials
         This is the name of the set of production credentials to use when accessing the SAP server. See Defining Production
         Credentials.

SAPLanguage

SAPHost
         Host name or IP address of the SAP server.

SAPSystemNumber
         SAP SystemNumber e.g 00.

SAPTransactionAutoCommit
         Specifies whether to execute the BAPI "BAPI_TRANSACTION_COMMIT" after a successful BAPI/RFC-call.

SAPResponseHandler
         Configuration item in this production that should receive the SAP response.

JavaGatewayConfigItemName
         Name of the (required) configuration item that hosts the Java Gateway.
For settings not listed here, see Settings in All Productions.




8                                                                            Using the SAP Java Connector in Productions
