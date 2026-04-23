Introducing Interoperability
        Productions
                             Version 2026.1
                              2026-04-20




  InterSystems Corporation One Congress Street Boston MA 02114 www.intersystems.com
Introducing Interoperability Productions
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
         1 InterSystems IRIS Basics: Connecting Systems Using Interoperability Productions ................. 1
             1.1 Why Connect Systems? .............................................................................................................. 1
             1.2 Introducing Productions ............................................................................................................. 2
             1.3 See Also ...................................................................................................................................... 3
         2 Introduction to Interoperability Productions .................................................................................. 5
             2.1 Production Basics ....................................................................................................................... 5
             2.2 Settings ....................................................................................................................................... 6
             2.3 Message Flow in a Production ................................................................................................... 7
         3 Connectivity Options for Productions .............................................................................................. 9
             3.1 Adapter Library .......................................................................................................................... 9
             3.2 Specialized Business Host Classes ........................................................................................... 12
                  3.2.1 Business Host Classes That Use File Adapters .............................................................. 12
                  3.2.2 Business Host Classes That Use FTP Adapters ............................................................. 12
                  3.2.3 Business Host Classes That Use HTTP Adapters .......................................................... 13
                  3.2.4 Business Host Classes That Use SOAP ......................................................................... 13
                  3.2.5 Business Host Classes That Use TCP Adapters ............................................................. 13
                  3.2.6 Business Host Classes That Support REST ................................................................... 13
             3.3 Gateways and External Servers ................................................................................................ 13
         4 Business Processes and Business Logic ........................................................................................... 15
             4.1 Introduction .............................................................................................................................. 15
             4.2 Types of Business Processes .................................................................................................... 15
             4.3 Data Transformations ............................................................................................................... 17
             4.4 Business Rules .......................................................................................................................... 18
             4.5 See Also .................................................................................................................................... 19
         5 Other Production Options ............................................................................................................... 21
             5.1 User Portal ................................................................................................................................ 21
             5.2 Workflow .................................................................................................................................. 22
             5.3 Business Activity Monitoring ................................................................................................... 22
             5.4 Alerts ........................................................................................................................................ 23
             5.5 Publish and Subscribe Message Delivery ................................................................................. 23
             5.6 Message Bank .......................................................................................................................... 23




Introducing Interoperability Productions                                                                                                                              iii
1
InterSystems IRIS Basics: Connecting
Systems Using Interoperability
Productions
This article explains how you can connect systems together with InterSystems IRIS® data platform interoperability pro-
ductions.
For an online hands-on activity that lets you create a simple production that organizes files on a local file system and use
file adapters to read and write the files, see Creating a Basic Production in InterSystems IRIS.




1.1 Why Connect Systems?
Connecting systems involves allowing messages from one system to be processed by another system. For example, the
following scenarios require connecting systems:
•   To improve efficiency, systems originally designed to perform a single function need to be integrated. For example,
    you can gain efficiency by integrating individual systems that track inventory, order materials, record sales, and control
    shipping.
•   After a merger, systems that perform the same function in the separate organizations need to work together for the
    unified organization to be effective.

When connecting systems together, you may be faced with challenges such as:
•   Systems use different communication protocols: one system may use TCP, another uses SOAP, and a third uses REST.
•   Systems use different messages with different formats or based on different standards.
•   You may be required to guarantee that messages are delivered successfully to the right system and be able to detect
    and correct failures.
•   You have to monitor the system transferring the messages, provide a queue for messages if too many come at one time,
    and monitor overall system performance to ensure that there aren’t any roadblocks.

While it is possible to code a custom application to connect systems, it is much easier and faster to develop an InterSystems
IRIS production. InterSystems IRIS provides a framework that allows you to connect systems and either minimizes or
eliminates the need for custom code.



Introducing Interoperability Productions                                                                                    1
InterSystems IRIS Basics: Connecting Systems Using Interoperability Productions




1.2 Introducing Productions
An InterSystems IRIS production is an integration framework for easily connecting systems and for developing applications
for interoperability. A production provides built-in connections to a wide variety of message formats and communications
protocols. You can easily add other formats and protocols – and define business logic and message transformations either
by coding or using graphic wizards. Productions provide persistent storage of messages, which allow you to trace the path
of a message and audit whether a message is successfully delivered. A production consists of business services, processes,
and operations:
•   Business services connect with external systems and receive messages from them.
•   Business processes allow you to define business logic, including routing and message transformation.
•   Business operations connect with external systems and send the messages to them.

When connecting systems together, it can be challenging to get them to understand the other system’s messages and docu-
ments. For example, consider the following problem:
•   You have two separate systems: one is collecting data from multiple networked devices and the other is a work order
    system that tracks broken devices and the repair process.
•   The current process depends on human intervention to monitor the devices and initiate the repair process. This has
    caused delays and is unreliable.
•   You have been given the task to connect the two systems together: to monitor the data being collected and to automate
    initiating the repair process. You know how to detect faulty devices in the data collection system and know how to
    initiate a repair, but the two systems store data in incompatible formats even when the data represents the same item.
•   You also need to record the actions when a repair is initiated from the data collection system.

You can solve this problem using an InterSystems IRIS production. It provides the framework for defining an interface
that accepts messages from the data collection system, transforming the message into one that can be understood by the
repair system, and then sending it to the repair system. It also stores a record of the message path.
The following illustrates a simple production:




2                                                                                  Introducing Interoperability Productions
                                                                         See Also




1.3 See Also
•   Creating a Basic Production in InterSystems IRIS (online activity)
•   Formal Overview of Productions
•   Developing Productions
•   Configuring Productions
•   Developing Business Rules




Introducing Interoperability Productions                                       3
2
Introduction to Interoperability
Productions
The purpose of interoperability productions is to enable you to connect systems so that you can transform and route messages
between them. To connect systems, you develop, configure, deploy, and manage productions, which integrate multiple
software systems. This topic introduces productions and some of the basic terminology.




2.1 Production Basics
An interoperability production is an integration framework for easily connecting systems and for developing applications
for interoperability. A production provides built-in connections to a wide variety of message formats and communications
protocols. You can easily add other formats and protocols – and define business logic and message transformations either
by coding or using graphic interfaces. Productions provide persistent storage of messages, which allow you to trace the
path of a message and audit whether a message is successfully delivered. The elements in a production are known as business
hosts. There are three kinds of business hosts, with different purposes as follows:
•   Business services connect with external systems and receive messages from them. Business services relay the messages
    to other business hosts in the production.
•   Business processes allow you to define business logic, including routing and message transformation. Business processes
    receive messages from other business hosts in the production and either process the requests or forward them to other
    business hosts.
•   Business operations connect with external systems and send the messages to them. Business operations receive messages
    from other business hosts in the production and typically send them to external systems.

The following figure provides a conceptual overview of a production and business hosts.




Introducing Interoperability Productions                                                                                  5
Introduction to Interoperability Productions




            External Applications...   Production




                                                                                                                                External Applications...
                                                                                                            Outbound Adapters
                                       Inbound Adapters
                                                          Business Se...   Business...   Business Oper...




Business hosts communicate with each other via messages. All messages are stored in the InterSystems IRIS® database
and can be seen via the Management Portal.
In most cases (but not all), a business service has an associated inbound adapter. The role of an inbound adapter is to accept
input from entities external to the production. Similarly, a business operation usually has an associated outbound adapter.
The role of an outbound adapter is to send output to entities external to the production. InterSystems IRIS provides a large
set of adapters to handle different technologies. For example, you use a different adapter for files than you do for FTP. It
is also possible to define your own adapters.
The following figure shows an actual production, as seen in the Management Portal:




2.2 Settings
A production typically includes a large number of settings. Settings are configurable values that control the behavior of a
production. Settings can affect a production in many ways. For example, a setting can specify:
•   The TCP port on which a business service should listen.
•   How frequently to check for new input.
•   The external data source name (DSN) to use.
•   The TLS configuration to use when connecting to an external entity.
•   How long to stay connected.
•   And so on.


6                                                                                               Introducing Interoperability Productions
                                                                                              Message Flow in a Production


An important feature of InterSystems IRIS is that a system administrator can modify settings while a production is running.
The changes take effect immediately. The following shows an example of the web page that the system administrator uses
to make such changes:




The production and its business hosts have settings provided by InterSystems IRIS; they correspond to properties of the
production and business host classes. You can define additional settings in exactly the same way, by defining your own
subclasses of InterSystems IRIS classes. You can also remove settings so that the corresponding properties are hardcoded
and not configurable.




2.3 Message Flow in a Production
An interoperability production typically processes incoming events as follows:
1.   An inbound adapter receives an incoming event, transforms it into a message object, and passes it to its associated
     business service.
2.   The business service creates a follow-on request message, and passes this new message to a business process or business
     operation within the production.
3.   A business process that receives a request message executes a predefined set of activities, in sequence or in parallel.
     These activities may include sending follow-on messages to other business hosts. Business processes are also respon-
     sible for most or all of the business logic in the production.
4.   A business operation encapsulates the capabilities of a resource outside InterSystems IRIS, usually an external software
     application. The business operation transforms properties of the request message object into a format usable by the
     external application API.
5.   An outbound adapter manages the details of communicating with a specific external system or application from within
     the production. It transmits the API call to the external entity.




Introducing Interoperability Productions                                                                                   7
Introduction to Interoperability Productions


6.   The response from the external system or application can trigger a cascade of response messages back to the external
     entity that started the flow of events. Details depend on the design choices made by the production developers.

As a demonstration, the following figure shows a trace of a set of related messages, which a production sent in response
to an initial message (in this case sent by the testing service in the Management Portal rather than by an exterior source):




The processing can also include workflow, which makes it possible to incorporate human interaction into automated business
processes. Uses of workflow within the enterprise might include order entry, order fulfillment, contract approval, or help
desk activities. Other Production Options provides more information.




8                                                                                   Introducing Interoperability Productions
3
Connectivity Options for Productions
InterSystems IRIS® enables you to define inbound and outbound connections to a wide variety of technologies. There are
three general categories of options: adapters, specialized business host classes, and gateways.
If the built-in tools do not meet your needs, you can create your own components. Also see the InterSystems Technology
Reference.




3.1 Adapter Library
InterSystems IRIS provides many adapters, and you can define your own. InterSystems IRIS provides adapters for the
following scenarios:

Amazon CloudWatch
         Monitor an application by collecting data for a metric defined in Amazon CloudWatch. See Using the Amazon
         CloudWatch Adapter.

Amazon SNS
         Send Amazon SNS messages.
         See Using External Messaging Platforms from Within Productions.

Cloud storage
         Read and write data from a cloud storage provider such as Amazon Web Services (AWS), Azure Blob Storage
         (Azure) or Google Cloud Platform (GCP). When using an InterSystems product to access cloud storage, you have
         two options: use an interoperability production or call low-level APIs.
         See Accessing Cloud Storage.

Email
         Receive email messages via the POP3 protocol and send email messages via the Simple Mail Transfer Protocol
         (SMTP).
         See Using Email Adapters in Productions.




Introducing Interoperability Productions                                                                              9
Connectivity Options for Productions


File
        Read and write files on the local network. Open, create, delete, modify, and move files. The file content can be
        character or binary data.
        See Using File Adapters in Productions.
        Also see Business Host Classes That Use File Adapters.

FTP
        Receive and send files between local and remote systems via the File Transfer Protocol (FTP). The file content
        can be characters or binary data. The adapters support FTP over TLS and SFTP.
        See Using FTP Adapters in Productions.
        Also see Business Host Classes That Use FTP Adapters.

HTTP
        Perform custom HTTP port listening, XML listening, or raw HTML handling. Supports the standard HTTP oper-
        ations Post, Get, Put, and Delete. The adapters support proxy servers.
        See Using HTTP Adapters in Productions.
        Also see Business Host Classes That Use HTTP Adapters.

JMS (Java Message Service)
        Send and receive JMS messages.
        See Using External Messaging Platforms from Within Productions.

Kafka
        Send and receive Kafka messages.
        See Using External Messaging Platforms from Within Productions.

LDAP
        Send requests to an LDAP server and receive responses.
        See the EnsLib.LDAP.OutboundAdapter entry in the Class Reference.

Managed File Transfer (MFT)
        Send and receive files from Box, DropBox, and Kiteworks managed file services.

MQSeries
        Send and receive messages in IBM WebSphere MQ (MQ Series) format. Message content can be a specific data
        type or a binary data stream. The adapter can simply send the message, or send it and then pull the corresponding
        response from the message queue.
        See Using IBM WebSphere MQ Adapters in Productions.

MQTT
        Receive and send Message Queuing Telemetry Transport (MQTT) messages. See Using MQTT Adapters in Pro-
        ductions.




10                                                                                Introducing Interoperability Productions
                                                                                                               Adapter Library


Pipe
         Execute a shell command and communicate with it via pipes. The adapters can handle character data or a binary
         data stream.
         See the EnsLib.Pipe.InboundAdapter and EnsLib.Pipe.OutboundAdapter entries in the Class Reference.

RabbitMQ
         Send and receive RabbitMQ messages.
         See Using External Messaging Platforms from Within Productions.

SAP
         Interface with the SAP Java Connector (SAP JCo).
         See Using the SAP Java Connector in Productions for details.

Siebel
         Send requests to a Siebel server and receive responses.
         See the EnsLib.Siebel.HTTPOutboundAdapter entry in the Class Reference.

SOAP
         Listen for SOAP requests on a local TCP port or via a standard web server. Dispatches outbound requests by acting
         as a SOAP client to an external SOAP server. In this special case, adapters are not necessarily involved.
         See Creating Web Services and Web Clients in Productions.

SQL
         Execute SQL statements against a remote database via an ODBC-defined or JDBC-defined connection.
         See Using SQL Adapters in Productions.

TCP
         Manage an incoming or outgoing TCP connection. The adapters allows simultaneous handling of multiple connec-
         tions. They also supports character and binary data streams, counted data blocks, and framed protocols.
         See Using TCP Adapters in Productions.
         Also see Business Host Classes That Use TCP Adapters.

Telnet
         Initiate and manage a Telnet connection.
         See the EnsLib.Telnet.OutboundAdapter entry in the Class Reference.
To use an adapter, you define a business host class that uses the adapter class. For a general description of this process, see
Developing Productions. The topics in the previous list provide details that apply to the specific adapters.
As noted previously, you can also define your own adapters. For information, see Developing Productions.




Introducing Interoperability Productions                                                                                    11
Connectivity Options for Productions




3.2 Specialized Business Host Classes
For specific scenarios, InterSystems IRIS® provides specialized business service classes and business operation classes so
that (usually) no coding is needed:
•    Files
•    FTP
•    HTTP and SOAP
•    TCP
•    REST

For practical reasons, the following sections might not cover all the specialized business host classes that InterSystems
IRIS provides. To find all the specialized business host classes that specify an adapter, perform a search in an IDE, and
look for Parameter ADAPTER within the EnsLib package.


3.2.1 Business Host Classes That Use File Adapters
InterSystems IRIS provides business host classes that use the file adapters. The following list summarizes the supported
content types and indicates where to find information.
•    ASTM documents — See Routing ASTM Documents in Productions.
•    DICOM documents — See Routing DICOM Documents in Productions.
•    EDIFACT documents — See Routing EDIFACT Documents in Productions.
•    HL7 version 2 messages — See Routing HL7 Version 2 Messages in Productions.
•    X12 documents — See Routing X12 Documents in Productions.
•    XML documents — See Routing XML Virtual Documents in Productions.
•    Fixed-column or delimited text documents — See Using the Record Mapper and Using the Complex Record Mapper.
•    Any — See Using the File Passthrough Service and Operation Classes.


3.2.2 Business Host Classes That Use FTP Adapters
InterSystems IRIS provides business host classes that use the FTP adapters. The following list summarizes the supported
content types and indicates where to find information.
•    ASTM documents — See Routing ASTM Documents in Productions.
•    EDIFACT documents — See Routing EDIFACT Documents in Productions.
•    HL7 version 2 messages — See Routing HL7 Version 2 Messages in Productions.
•    X12 documents — See Routing X12 Documents in Productions.
•    XML documents — See Routing XML Virtual Documents in Productions.
•    Fixed-column or delimited text documents — See Using the Record Mapper and Using the Complex Record Mapper.
•    Any — See EnsLib.FTP.PassthroughService and EnsLib.FTP.PassthroughOperation in the Class Reference.




12                                                                                 Introducing Interoperability Productions
                                                                                          Gateways and External Servers



3.2.3 Business Host Classes That Use HTTP Adapters
InterSystems IRIS provides business host classes that use the HTTP adapters. The following list summarizes the supported
content types and indicates where to find information.
•   EDIFACT documents — See Routing EDIFACT Documents in Productions.
•   HL7 version 2 messages — See Routing HL7 Version 2 Messages in Productions.
•   Any — See Pass-through Service and Operation Walkthrough.


3.2.4 Business Host Classes That Use SOAP
InterSystems IRIS provides business host classes that use SOAP. The following list summarizes the supported content
types and indicates where to find information.
•   HL7 version 2 messages — See Routing HL7 Version 2 Messages in Productions.
•   Any — See Pass-through Service and Operation Walkthrough.


3.2.5 Business Host Classes That Use TCP Adapters
InterSystems IRIS provides business host classes that use TCP adapters. The following list summarizes the supported
content types and indicates where to find information.
•   ASTM documents — See Routing ASTM Documents in Productions.
•   HL7 version 2 messages — See Routing HL7 Version 2 Messages in Productions.
•   X12 documents — See Routing X12 Documents in Productions.
•   Any — See EnsLib.TCP.PassthroughService and EnsLib.TCP.PassthroughOperation in the Class Reference.


3.2.6 Business Host Classes That Support REST
InterSystems IRIS provides business host classes that support REST (in this special case, adapters are not necessarily
involved). See Using REST Services and Operations in Productions.




3.3 Gateways and External Servers
InterSystems IRIS provides the following additional connectivity options:
•   The SQL Gateway, which provides access from InterSystems IRIS to external databases via JDBC and ODBC. You
    can, for example, link to tables and views in external sources and access the data in them in the same way you access
    any local data. See Using the InterSystems SQL Gateway.
•   An InterSystems External Server allows you to instantiate and manipulate objects written in an external language as
    if they were native objects within InterSystems IRIS. See Using InterSystems External Servers. In most cases, using
    the PEX framework to interact with an external language from a production is preferred over using the
    $system.external interface provided by the external server.




Introducing Interoperability Productions                                                                                 13
4
Business Processes and Business Logic
This topic describes the kinds of logic supported in business processes in interoperability productions.




4.1 Introduction
Business processes are the middle part of any production. They accept requests from host classes inside the production
—business services or business processes—and then either process the requests or relay them to other host classes inside
the production for processing.
InterSystems recommends the following division of labor within a production: Use business services to receive input from
outside of the production and simply forward it (as messages) into the production. Use business processes to handle any
needed business logic. Use business operations to receive messages from within the production and simply generate output
for destinations outside of the production. That is, centralize the business logic within the business processes.
Accordingly, InterSystems IRIS® provides extensive support for complex logic within business processes, and this logic
can be defined by nontechnical users.
First, a business process can contain its own complex logic. It can also use the following reusable items:
•   Data transformations calculate and apply changes to message contents.
•   Business rules change the behavior of business processes at decision points or send messages to specific destinations
    based on message type, message contents, or where the message came from.

InterSystems IRIS provides tools that enable nontechnical users to define business processes, data transformations, and
business rules. These users can view and edit the logic visually without programming or diagramming skills.
Note that there is overlap among the lower-level options available in business processes, data transformations, and business
rules. For a comparison, see Comparison of Business Logic Tools. It is worthwhile to review these options before deciding
how to organize your logic.




4.2 Types of Business Processes
InterSystems IRIS provides the following general types of business process:
•   BPL processes, which are based on the class Ens.BusinessProcessBPL. To create these processes, you use a graphical
    editor that is intended for use by nontechnical users. See Developing BPL Processes.




Introducing Interoperability Productions                                                                                  15
Business Processes and Business Logic


     The name of these processes comes from BPL (Business Process Language), which is the XML-based language that
     InterSystems IRIS uses to represent their definitions.
•    Routing processes, which are based on the class EnsLib.MsgRouter.RoutingEngine or
     EnsLib.MsgRouter.VDocRoutingEngine.

     InterSystems IRIS provides a set of classes to route specific kinds of messages. The following links indicate the routing
     process to use for different kinds of messages:

      Message Type          See
      EDIFACT               Routing EDIFACT Documents in Productions
      X12                   Routing X12 Documents in Productions
      XML                   Routing XML Virtual Documents in Productions


     To use these classes, no coding is generally necessary. It is, however, necessary, to provide a set of business rules.
•    Custom business processes, which are based on the class Ens.BusinessProcess. Note that all the previously listed
     business process classes inherit from this class. In this case, it is necessary to use a supported IDE to develop custom
     code.
     For information on defining custom business processes, see Developing Custom Business Processes.

A production can include any mix of these business processes.
The following shows a partial example of a BPL business process, as displayed in the BPL editor:




16                                                                                   Introducing Interoperability Productions
                                                                                                   Data Transformations




4.3 Data Transformations
A data transformation creates a new message that is a transformation of another message. You can invoke a data transfor-
mation from a business process, another data transformation, or a business rule.
When you transform a message, your data transformation swaps out the old message body object (the source) and exchanges
it for a new one (the target). Some of the transformations that occur during this process can include:
•   Copying values from properties on the source to properties on the target.
•   Performing calculations using the values of properties on the source.
•   Copying the results of calculations to properties on the target.
•   Assigning literal values to properties on the target.



Introducing Interoperability Productions                                                                             17
Business Processes and Business Logic


•    Ignoring any properties on the source that are not relevant to the target.

A data transformation is a class based on Ens.DataTransform or its subclass, Ens.DataTransformDTL.
•    If you use Ens.DataTransformDTL, the transformation is called a DTL transformation. To create these transformations,
     you use a graphical editor that is intended for use by nontechnical users. For details, see Developing DTL Transforma-
     tions.
     The name of these transformations comes from DTL (Data Transformation Language), which is the XML-based language
     that InterSystems IRIS uses to represent their definitions.
•    If you use Ens.DataTransform, the transformation is a custom transformation. In this case, you must use a supported
     IDE. For information on defining these, see Developing Custom Data Transformations.

The following shows an example DTL transformation, as seen in the DTL editor:




4.4 Business Rules
A business rule (also known as a business rule set) can return a value, transform data, or both. You can invoke a business
rule from a business process or from another business rule.
A business rule is a class based on Ens.Rule.Definition. You define these in the Management Portal, which provides a visual
editor for the benefit of nontechnical users. The following shows a partial example, as seen in this editor:




18                                                                                 Introducing Interoperability Productions
                                              See Also




For details, see Developing Business Rules.




4.5 See Also
•   Comparison of Business Logic Tools
•   Developing BPL Processes
•   Developing Custom Business Processes
•   Developing DTL Transformations
•   Developing Custom Data Transformations
•   Developing Business Rules




Introducing Interoperability Productions           19
5
Other Production Options
This topic provides an overview of other options related to interoperability productions.




5.1 User Portal
The User Portal (formally called the InterSystems User Portal) is intended for direct use by end users, in contrast to such
back end tools as IDEs and the Management Portal. The following shows an example:




The User Portal is designed to enable end users to do the following tasks:
•   View and dashboards, which can include production business metrics
•   View and manage workflow tasks.
•   Send messages to other users of the User Portal, as seen in the upper left corner of the previous figure.




Introducing Interoperability Productions                                                                                21
Other Production Options


For details, see Using Dashboards and the User Portal.

Important:       In order to use the User Portal, it is necessary to configure the web application for the namespace so that
                 it is Analytics-enabled; see Setting Up the Web Applications for Business Intelligence.




5.2 Workflow
InterSystems IRIS® supports workflow within productions. Workflow makes it possible to incorporate human interaction
into automated business processes. Uses of workflow within the enterprise might include order entry, order fulfillment,
contract approval, or help desk activities.
A production achieves workflow using a business process and set of business operations. A business process receives a
request, organizes the tasks required to fulfill that request, and then calls upon business operations to perform these tasks.
Each of these business operations assigns the task to a workflow role, which places the task into the workflow inbox of
each user who belongs to that role. To access this inbox, users work with the User Portal.




When a user marks as a task as complete, the workflow engine continues with the next processing step.
For details, see Defining Workflows.




5.3 Business Activity Monitoring
InterSystems IRIS includes all the elements required to include business activity monitoring (BAM) as part of an enterprise
integration project.
First, it provides business metrics, which are specialized business service classes that calculate specific values at a configurable
time interval. These calculations can take a variety of forms, involving calls to business operations, federated databases,
the InterSystems IRIS database, or any arbitrary source code contained within the business metric class. See Defining
Business Metrics.
Second, it provides dashboards, which display business metrics. See Creating and Modifying Dashboards.




22                                                                                       Introducing Interoperability Productions
                                                                                                                      Alerts




5.4 Alerts
An alert sends notifications to applicable users while a production is running, in the event that an alert event occurs. The
intention is to alert a system administrator or service technician to the presence of a problem. Alerts may be delivered via
email or other mechanisms. For details, see Programming in InterSystems IRIS.




5.5 Publish and Subscribe Message Delivery
Productions also support publish and subscribe message routing. This technique routes a message to one or more subscribers
based on the fact that those subscribers have previously registered to be notified about messages on a specific topic. For
details, see Managing Productions.




5.6 Message Bank
The Enterprise Message Bank is an optional remote archiving facility where you can collect messages, Event Log items,
and search table entries from multiple client productions. It consists of the following components:
•   The Message Bank server, which is a simple production consisting exclusively of a Message Bank service that receives
    submissions from any number of client productions.
•   A client operation (the Message Bank operation) that you add to a production and configure with the address of a
    Message Bank server.

To get started, see Defining an Enterprise Message Bank.




Introducing Interoperability Productions                                                                                 23
