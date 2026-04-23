                        Auditing
                           Version 2026.1
                            2026-04-20




InterSystems Corporation One Congress Street Boston MA 02114 www.intersystems.com
Auditing
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
           Auditing................................................................................................................................................... 1
              1 Basic Auditing Concepts ............................................................................................................... 1
              2 Enable or Disable Auditing ........................................................................................................... 1
                   2.1 Enable Auditing ................................................................................................................... 2
                   2.2 Disable Auditing ................................................................................................................. 2
              3 Elements of an Audit Event ........................................................................................................... 2
              4 About System Audit Events ........................................................................................................... 4
                   4.1 %System/%Login/Logout and %System/%Login/Terminate ........................................... 13
                   4.2 %System/%SQL/EmbeddedStatement ............................................................................. 14
                   4.3 %System/%Security/DBEncChange ................................................................................. 15
                   4.4 %System/%Security/X509CredentialsChange ................................................................. 15
                   4.5 %System/%System/DatabaseChange ............................................................................... 15
                   4.6 %System/%System/RoutineChange ................................................................................. 16
              5 Manage User-Defined Audit Events ............................................................................................ 16
                   5.1 About User-Defined Audit Events ..................................................................................... 17
                   5.2 Create a User-Defined Audit Event ................................................................................... 17
                   5.3 Add an Entry to the Audit Log .......................................................................................... 17
                   5.4 Delete a User-Defined Audit Event ................................................................................... 18
              6 Enable or Disable an Audit Event ............................................................................................... 18
              7 Manage Auditing and the Audit Database ................................................................................... 19
                   7.1 View the Audit Database ................................................................................................... 19
                   7.2 Copy, Export, and Purge the Audit Database .................................................................... 20
                   7.3 Encrypt the Audit Database ............................................................................................... 22
                   7.4 General Management Functions ....................................................................................... 22
              8 Other Auditing Issues .................................................................................................................. 23
                   8.1 Freeze the System If It Is Impossible to Write to the Audit Database .............................. 23
                   8.2 Audit Event Counters ........................................................................................................ 23


           List of Tables
                Table 1: System Audit Events ........................................................................................................... 4




Auditing                                                                                                                                                                   iii
Auditing
Logging certain key events in a secure audit database is a major aspect of InterSystems security. InterSystems IRIS® allows
you to monitor events and add entries to the audit database when these events occur. These events can occur within Inter-
Systems IRIS itself or part of an application. The knowledge that all activities are being monitored and that all logs can be
reviewed is often an effective deterrent to malicious behavior.

Note:      This document describes how to manage audit events with the Management Portal. To manage audit events pro-
           grammatically, use the Security.Events class.

As an alternative, you can enable structured logging, which will write the same messages seen in the audit database to a
machine-readable file that can be ingested by your choice of monitoring tool. If you are using a monitoring tool which is
compatible with OpenTelemetry, you also have the option to transmit audit database events as OTLP/HTTP signals instead.




1 Basic Auditing Concepts
InterSystems IRIS allows you to enable or disable auditing for the entire InterSystems IRIS instance. When auditing is
enabled, InterSystems IRIS logs all requested events. Auditable events fall into two categories:
•   System audit events — InterSystems IRIS system events that are only logged if they are explicitly enabled.
•   User—defined audit events — Application events, which are only logged if they are explicitly enabled.

InterSystems IRIS system events are built-in events that monitor actions within InterSystems IRIS, such as start-up, shutdown,
logins, and so on; security-related events, such as changes to security or audit settings; and interoperability-related events,
such as changes to a production configuration or schema.
InterSystems IRIS does not automatically audit database activity, such as inserts, updates, or deletes for a table, because
this kind of activity typically generates so many audit entries as to be useless — or even counterproductive — due to the
performance impact on the system. For example, if a medical records application were to log all access to patient medical
information, then one such access event might result in hundreds or thousands of database accesses. It is much more efficient
to have the application create a single audit entry, rather than have the database manager generate thousands.




2 Enable or Disable Auditing
In the Auditing menu (System Administration > Security > Auditing), there are selections to enable and disable auditing. If
the Enable Auditing choice is available, this means that auditing is disabled; if the Disable Auditing choice is available, this
means that auditing is enabled. InterSystems IRIS auditing is disabled by default for minimal-security installations; it is
enabled by default for normal and locked-down installations.
If you enable (turn on) auditing, then InterSystems IRIS audits:
•   All system events that are enabled
•   All user-defined events that are enabled




Auditing                                                                                                                      1
Elements of an Audit Event



2.1 Enable Auditing
To turn on auditing, on the Auditing menu (System Administration > Security > Auditing), select Enable Auditing.


2.2 Disable Auditing
To turn off auditing, on the Auditing menu (System Administration > Security > Auditing), select Disable Auditing.




3 Elements of an Audit Event
Audit information is available in the IRISAUDIT database. New entries are added to the end of the log. When you view the
audit log, you see the following elements for each entry:

Time (also called UTCTimestamp)
         UTC date/time when the event was logged.

Event Source*
         The component of the InterSystems IRIS instance that is the source of the event. For InterSystems IRIS events,
         this is “%System” or “%Ensemble”. For user-defined events, the name can be any string that includes alphanumeric
         characters or punctuation, except for colons and commas; it can begin with any of these characters except for the
         percent sign. This can be up to 64 bytes.

Event Type*
         Categorizing information for the event. This string can include any alphanumeric characters or punctuation, except
         for colons and commas; it can begin with any of these characters except for the percent sign. This can be up to 64
         bytes.

Event* (also called Event Name)
         Identifier of the event being logged. This string can include any alphanumeric characters or punctuation, except
         for colons and commas; it can begin with any of these characters except for the percent sign. This can be up to 64
         bytes.

PID (also known as a Process ID)
         Operating system ID of the InterSystems IRIS process that logged the event. InterSystems IRIS uses the OS PID
         in its native form.

Web Session (search results only)
         The session ID, if there is one, of the web session that caused the event.

User (also called Username)
         Value of $USERNAME for the process that logged the event.

Description
         A field of up to 128 characters that applications can use to summarize the audit event. This field is intended for a
         user-readable explanation or display (as compared to the combination of EventSource, EventType, and Event,
         which uniquely define the audit event).


2                                                                                                                    Auditing
                                                                                                   Elements of an Audit Event


*Each different kind of event is uniquely identified by the combination of its EventSource, its EventType, and the Event
itself.
When you click Details, you see some of the same elements and the following additional elements:

Timestamp
           Date/time when the event was logged, in local time.

JobId
           ID of the job.

IP Address
           IP address of client associated with the process that logged the event.

Executable
           The client application associated with the process that logged the event, if there is one.

System ID
           The machine and InterSystems IRIS instance that logged the event. For example, for the machine MyMachine and
           the instance MyInstance, the system ID is MyMachine:MyInstance.

Index
           The index entry in the data structure containing the audit log.

Roles
           For all events except LoginFailure, the value of $ROLES for the process that logged the event. For LoginFailure,
           a value of “ ”, as the user is not logged in.

Namespace
           The namespace that was current when the event was logged.

Routine
           The routine or subroutine that was running when the event was logged.

User Info
           User-defined information about the process, added programmatically via the %SYS.ProcessQuery interface.

O/S Username
           Username given to the process by the operating system. When displayed, this is truncated to 16 characters.
           This is the actual operating system username only for UNIX® systems.
           For Windows:
           •   For a console process, this is the operating system username.
           •   For Telnet, this is the $USERNAME of the process.
           •   For client connections, this is the operating system username of the client.




Auditing                                                                                                                   3
About System Audit Events


Status
          The value of any %Status object that was audited.

Event Data
          A memo field where applications can store up to 3632952 bytes of data associated with the audit event. For
          example, it can contain a set of application values at the time of the event or can summarize the old and new states
          of a record or field.




4 About System Audit Events
System audit events are predefined events that are available for auditing by default. General information about them appears
in the table on the System Audit Events page (System Administration > Security > Auditing > Configure System Events),
where the columns are:
•     Event Name — The Event Source (which is %System or %Ensemble), Event Type, and Event proper, all together and
      concatenated with slashes (“/”). The %Ensemble Event Source is used for events related to the interoperability features
      in InterSystems IRIS.
•     Enabled — Whether or not the event is enabled (turned on) for auditing.
•     Total — The number of events of this type that have occurred since the last startup of InterSystems IRIS.
•     Written — The number of events of this type that have been written to the audit log since the last startup of InterSystems
      IRIS. This number may differ from the total occurrences.
•     Reset — Allows you to clear the audit log for this event and reset its counter to zero. For more information on counters,
      see Audit Event Counters.
•     Change Status — Allows you to enable or disable the event. For more information on these actions, see Enable or
      Disable an Audit Event section.

They monitor events within the InterSystems IRIS system, including changes to InterSystems IRIS productions. System
events are distinguishable by their Event Source value of %System or %Ensemble.
Table 1: System Audit Events

    Event Source         Event Type and                   Occurs When                    Event Data Contents          Default
                         Event                                                                                        Status
    %Ensemble            %Message/                        A user views the contents      Metadata about the           On
                                                          of a message in the            message.
                         ViewContents
                                                          Message Viewer.
    %Ensemble            %Production/                     A user modifies the            A summary of the change.     On
                                                          configuration of a
                         ModifyConfigura-
                                                          production.
                         tion

    %Ensemble            %Producto
                                 i n/ModfiyDefautlSetn
                                                     ig   A user creates, modifies, or   How the System Default       On
                                                          deletes System Default         Setting was modified.
                                                          Settings.
    %Ensemble            %Production/                     A user starts or stops a       Action (start or stop) and   On
                                                          production.                    the username for the
                         StartStop
                                                                                         initiator of the action.



4                                                                                                                      Auditing
                                                                                About System Audit Events


 Event Source   Event Type and    Occurs When                    Event Data Contents              Default
                Event                                                                             Status
 %Ensemble      %Schema/          A user creates, modifies, or   A summary of the change.         On
                                  deletes a schema structure.
                Modify

 %Ensemble      %Message/Resend   An interoperability message    Identification information for   On
                                  is resent.                     the message.
 %System        %DirectMode/      Any command is executed        The text of command.             Off
                                  in direct mode.
                DirectMode

 %System        %Login/           The JOB command ends a         The routine where the Job        Off
                                  background job.                command was executed
                JobEnd
                                                                 and the database where the
                                                                 routine is stored. If the
                                                                 values for these fields are
                                                                 null, then the Job command
                                                                 was executed from the
                                                                 shell.
 %System        %Login/           The JOB command starts a       The routine where the Job        Off
                                  background job.                command was executed
                JobStart
                                                                 and the database where the
                                                                 routine is stored. If the
                                                                 values for these fields are
                                                                 null, then the Job command
                                                                 was executed from the
                                                                 shell.
 %System        %Login/           A user successfully logs in.   The protocol, port number,       Off
                                                                 process ID, and application
                Login
                                                                 associated with the login.
                                                                 The user’s login roles.
 %System        %Login/           A login attempt fails.         Username.                        Varies*
                LoginFailure

 %System        %Login/           A user logs out.               The application (and, if         Off
                                                                 relevant, the class)
                Logout
                                                                 associated with the logout.
 %System        %Login/           The Task Manager ends a        None. See the Description        Off
                                  process.                       for the name of the task.
                TaskEnd

 %System        %Login/           The Task Manager starts a      None. See the Description        Off
                                  process.                       for the name of the task.
                TaskStart

 %System        %Login/           A process terminates           Varies, as does the              Off
                                  abnormally.                    Description field’s content;
                Terminate
                                                                 see below.




Auditing                                                                                                    5
About System Audit Events


    Event Source     Event Type and   Occurs When                     Event Data Contents             Default
                     Event                                                                            Status
    %System          %SMPExplorer/    Data is altered using the       Varies, as does the             Off
                                      Portal, such as by creating,    Description field, depending
                     Change
                                      editing, deleting, compiling,   on the action taken.
                                      dropping, replacing, or         Includes relevant content
                                      purging classes or tables.      such as the compile flags or
                                                                      the schema and table being
                                                                      dropped.
    %System          %SMPExplorer/    A query is executed using       The syntax of the executed      Off
                                      on the Portal’s SQL page.       query.
                     ExecuteQuery

    %System          %SMPExplorer/    Data is exported through        The options selected for        Off
                                      the Portal.                     data export.
                     Export

    %System          %SMPExplorer/    Data is imported through        The options selected for        Off
                                      the Portal.                     data import.
                     Import

    %System          %SMPExplorer/    Data is viewed through the      The filters that determined     Off
                                      Portal.                         what data was viewed. The
                     ViewContents
                                                                      Description field specifies
                                                                      what was viewed, such as
                                                                      a list of classes, an
                                                                      individual global, or process
                                                                      information.




6                                                                                                      Auditing
                                                                                About System Audit Events


 Event Source   Event Type and     Occurs When                    Event Data Contents           Default
                Event                                                                           Status
 %System        %SQL/Dynamic-      A dynamic SQL statement        The statement text and the    Off
                StatementDDL       is executed. The particular    values of any host-variable
                                   event that triggers depends    arguments passed to it. If
                %SQL/Dynamic-
                                   on the type of SQL             the total length of the
                StatementDML
                                   statement:                     statement and its
                %SQL/Dynamic-                                     parameters exceeds
                                   •   %SQL/DynamicState-
                StatementUtility                                  3,632,952 characters, the
                                       mentDDL: Statements
                                                                  event data is truncated.
                %SQL/Dynamic-          that change database
                StatementQuery         elements, settings, or
                                       other things that aren't
                                       data.
                                   •   %SQL/DynamicState-
                                       mentDML: Statements
                                       that change data.
                                   •   %SQL/DynamicState-
                                       mentUtility: Statements
                                       that don't change data
                                       nor metadata, but
                                       instead change the sta-
                                       tus of the process or
                                       machine learning mod-
                                       els.
                                   •   %SQL/DynamicState-
                                       mentQuery: Statements
                                       that execute or define a
                                       query that can return
                                       data.




Auditing                                                                                                  7
About System Audit Events


    Event Source     Event Type and      Occurs When                      Event Data Contents           Default
                     Event                                                                              Status
    %System          %SQL/Embed-         An embedded SQL                  The statement text and the    Off
                     dedStatement-       statement is executed. The       values of any host-variable
                     DDL                 particular event that triggers   arguments passed to it. If
                                         depends on the type of SQL       the total length of the
                     %SQL/Embed-
                                         statement:                       statement and its
                     dedStatement-
                                                                          parameters exceeds
                     DML                 •   %SQL/EmbeddedState-
                                                                          3,632,952 characters, the
                                             mentDDL: Statements
                     %SQL/Embed-                                          event data is truncated.
                                             that change database
                     dedStatementUtil-
                                             elements, settings, or
                     ity
                                             other things that aren't
                     %SQL/Embed-             data.
                     dedStatement-
                                         •   %SQL/EmbeddedState-
                     Query
                                             mentDML: Statements
                                             that change data.
                                         •   %SQL/EmbeddedState-
                                             mentUtility: Statements
                                             that don't change data
                                             nor metadata, but
                                             instead change the sta-
                                             tus of the process or
                                             machine learning mod-
                                             els.
                                         •   %SQL/EmbeddedState-
                                             mentQuery: Statements
                                             that execute or define a
                                             query that can return
                                             data.

                                         For usage instructions, see
                                         %System/%SQL/Embedded-
                                         Statement.




8                                                                                                        Auditing
                                                                                  About System Audit Events


 Event Source   Event Type and     Occurs When                     Event Data Contents               Default
                Event                                                                                Status
 %System        %SQL/              There is an SQLCODE=-99         •   The SQL error mes-            Off
                                   error, which occurs because         sage
                PrivilegeFailure
                                   a user attempts to execute
                                                                   •   The required privilege
                                   an SQL statement without
                                                                       that the user doesn’t
                                   the required privilege.
                                                                       have
                                                                   •   The entity type where
                                                                       the privilege is missing,
                                                                       such as table, view,
                                                                       stored procedure
                                                                   •   The table, view, or
                                                                       other entity on which
                                                                       the user lacks privileges
                                                                   •   If there are column-
                                                                       level privileges, the rele-
                                                                       vant fields


 %System        %SQL/XDBC-         A remote SQL statement is       The statement text and the        Off
                StatementDDL       executed using ODBC or          values of any host-variable
                                   JDBC. The particular event      arguments passed to it. If
                %SQL/XDBC-
                                   that triggers depends on the    the total length of the
                StatementDML
                                   type of SQL statement:          statement and its
                %SQL/XDBC-                                         parameters exceeds
                                   •   %SQL/XDBCStatement-
                StatementUtility                                   3,632,952 characters, the
                                       DDL: Statements that
                                                                   event data is truncated.
                %SQL/XDBC-             change database ele-
                StatementQuery         ments, settings, or
                                       other things that aren't
                                       data.
                                   •   %SQL/XDBCStatement-
                                       DML: Statements that
                                       change data.
                                   •   %SQL/XDBCStatemen-
                                       tUtility: Statements that
                                       don't change data nor
                                       metadata, but instead
                                       change the status of the
                                       process or machine
                                       learning models.
                                   •   %SQL/XDBCStatemen-
                                       tQuery: Statements that
                                       execute or define a
                                       query that can return
                                       data.




Auditing                                                                                                       9
About System Audit Events


 Event Source        Event Type and    Occurs When                                     Event Data Contents               Default
                     Event                                                                                               Status
 %System             %Security/        An application definition is                    Action (create new, modify,       On
                                       created, changed, or                            or delete), old and new
                     Application-
                                       deleted.                                        application data.
                     Change

 %System             %Security/        Auditing is stopped or                          Action (stop, start, erase,       On
                                       started, entries are erased                     delete, or specify), old and
                     AuditChange
                                       or deleted, or the list of                      new audit settings.
                                       events being audited is
                                       changed.
 %System             %Security/        Any standard audit report is                    Identification of audit report.   On
                                       run.
                     AuditReport

 %System             %Security/        There is a change related                       Varies, as does the               On
                                       to database or data-element                     Description field’s content.
                     DBEncChange
                                       encryption.                                     See below.
 %System             %Security/        A document database                             A summary of the change           On
                                       application definition is                       and a list of the current
                     DocDBChange
                                       created, changed, or                            values, if applicable.
                                       deleted.
 %System             %Security/        A domain definition is                          Action (new, modify,              On
                                       created, changed, or                            delete), old and new domain
                     DomainChange
                                       deleted.                                        data.
 %System             %Security/        A KMIP server definition is                     A summary of the action           On
                                       created, changed, or                            and a list of the current
                     KMIPServer-
                                       deleted, or KMIP servers                        values, if applicable. See
                     Change
                                       are exported or imported.                       the Description for
                                                                                       additional details.
 %System             %Security/        An LDAP configuration is                        A summary of the change           On
                                       created, changed, or                            and a list of the current
                     LDAPCon-
                                       deleted.                                        values, if applicable.
                     figChange

 %System             %Security/        An OAuth2 configuration                         Action (new, modify, or           On
                                       (except                                         delete), old and new
                     OAuth2
                                       OAuth2.ResourceServer,                          OAuth2 configuration
                                       which is handled by                             information.
                                       %System/%Security/OAuth2ResourceServerChange)
                                       is created, changed,
                                       deleted, or imported.
 %System             %Security/        An OAuth2.ResourceServer is                     Action (new, modify, or           On
                                       created, changed, deleted,                      delete), old and new
                     OAuth2Resource-
                                       or imported.                                    resource server information.
                     ServerChange




10                                                                                                                        Auditing
                                                                                 About System Audit Events


 Event Source   Event Type and    Occurs When                     Event Data Contents            Default
                Event                                                                            Status
 %System        %Security/        OpenAM Identity Services        File name and the number       On
                                  records are exported or         of records exported to or
                OpenAMIdentity-
                                  imported.                       imported from the file.
                ServicesChange

 %System        %Security/        A mobile phone service          For creating a provider, its   On
                                  provider is created,            name and the value of its
                PhoneProvider-
                                  updated, or deleted.            SMS gateway
                sChange
                                                                  For updating a provider, its
                                                                  name, and the old and new
                                                                  values of its SMS gateway.
                                                                  For deleting a provider,
                                                                  there is no event data; the
                                                                  name of the deleted
                                                                  provider is in the event
                                                                  description
 %System        %Security/        A process generates a           The error.                     On
                                  security protection error.
                Protect

 %System        %Security/        A resource definition is        Action (new, modify, or        On
                                  created, changed, or            delete), old and new
                ResourceChange
                                  deleted.                        resource data.
 %System        %Security/        A role definition is created,   Action (create new, modify,    On
                                  changed (including privilege    or delete), old and new role
                RoleChange
                                  grants and revocations), or     data. For privilege changes,
                                  deleted.                        this includes the
                                                                  grantor/revoker, the action
                                                                  type (GRANT or REVOKE),
                                                                  the privileges and their
                                                                  associated object, and the
                                                                  changed role.
 %System        %Security/        A TLS configuration’s           The changed fields with old    On
                                  settings are changed.           and new values.
                SSLCon-
                figChange

 %System        %Security/        A superserver is modified.      The old and new values for     On
                                                                  the superserver.
                ServerChange

 %System        %Security/        A service’s security settings   Old and new service            On
                                  are changed.                    security settings.
                ServiceChange

 %System        %Security/        System security settings are    Old and new security           On
                                  changed.                        settings.
                SystemChange




Auditing                                                                                               11
About System Audit Events


 Event Source        Event Type and    Occurs When                      Event Data Contents             Default
                     Event                                                                              Status
 %System             %Security/        A user definition is created,    Action (create new, modify,     On
                                       changed (including privilege     or delete), old and new user
                     UserChange
                                       grants and revocations), or      data. For privilege changes,
                                       deleted.                         this includes the
                                                                        grantor/revoker, the action
                                                                        type (GRANT or REVOKE),
                                                                        the privileges and their
                                                                        associated object, and the
                                                                        changed user.
 %System             %Security/        A secret is created,             Action (create new, modify,     On
                                       modified, or deleted.            or delete) and, if the change
                     WalletSe-
                                                                        was creation or
                     cretChange
                                                                        modification, a summary of
                                                                        the new secret data (key
                                                                        identifier, length, name, and
                                                                        version).
 %System             %Security/        A secret is used.                The name of the secret and      Off
                                                                        the class it was used with.
                     WalletSecretUse

 %System             %Security/        A user creates, updates, or      Varies by event. See below      On
                                       deletes a set of X.509
                     X509Creden-
                                       credentials.
                     tialsChange

 %System             %Security/        Event defined, but not           N/A                             On
                                       available for auditing until a
                     X509UserChange
                                       future release.
 %System             %System/          An audit entry has not been      None.                           On
                                       added to the audit database
                     AuditRecordLost
                                       due to resource limitations
                                       that constrain the audit
                                       system (such as disk or
                                       database full).
 %System             %System/          InterSystems IRIS                Username for the user who       On
                                       successfully starts with a       made the change; previous
                     Configura-
                                       configuration different than     and new values of the
                     tionChange
                                       the previous start, a new        changed element. For
                                       configuration is activated       deleted locks, information
                                       while InterSystems IRIS is       about which lock was
                                       running, or a lock is deleted    deleted.
                                       through the Portal or
                                       through the ^LOCKTAB
                                       utility.
 %System             %System/          There are changes to             Details about the particular    On
                                       database properties. See         change. See below.
                     DatabaseChange
                                       below.




12                                                                                                       Auditing
                                                                                                    About System Audit Events


    Event Source          Event Type and         Occurs When                        Event Data Contents                Default
                          Event                                                                                        Status
    %System               %System/               Journaling is started or           When journaling is started,        On
                                                 stopped for a database or          the name of the database
                          JournalChange
                                                 process.                           and its maximum size; when
                                                                                    journaling is stopped, none.
    %System               %System/               An operating-system                The operating system               On
                                                 command is issued from             command that was invoked;
                          OSCommand
                                                 within the system, such as         the directory in which it was
                                                 through a call to the              invoked; and any flags
                                                 $ZF(-100) function.                associated with the
                                                                                    command.
    %System               %System/               A method or routine is             No content, though the             Off
                                                 compiled or deleted on the         Description field depends
                          RoutineChange
                                                 local instance. For more           on the change itself; see
                                                 details, see below.                below.
    %System               %System/               The system starts.                 Indication of whether              On
                                                                                    recovery was performed.
                          Start

    %System               %System/               InterSystems IRIS is shut          None.                              On
                                                 down.
                          Stop

    %System               %System/               A process is suspended or          The process ID of the              Off
                                                 resumed.                           process.
                          SuspendResume

    %System               %System/               An application attempts to         The name of the event that         On
                                                 log an undefined event.            the application attempted to
                          UserEventOver-
                                                                                    log.
                          flow

*The LoginFailure event is off by default for minimal-security installations; it is on by default for normal and locked-down
installations.

Important:        If auditing is enabled, then all enabled events are audited.


4.1 %System/%Login/Logout and %System/%Login/Terminate
A process generates a %System/%Login/Logout event if the process ends because of:
•     A HALT command
•     Exiting application mode because of a QUIT command
•     Executing the Terminate method of the SYS.Process class to terminate itself (which is the same as executing HALT).

A process generates a %System/%Login/Terminate event if the process exits for any other reason, including:
•     The user closes the Terminal window, resulting in a Terminal disconnect. If the process is in application mode, the
      Description field of the audit record includes the statement “ ^routinename client disconnect ” (where routinename is
      the first routine that the process ran); if the process is in programmer mode, the Description field includes the statement
      “ Programmer mode disconnect. ”



Auditing                                                                                                                      13
About System Audit Events


•     A Terminal session is ended by an action in another process, including ^RESJOB, ^JOBEXAM, or the Management
      Portal. If the process is in application mode, the Description field of the audit record includes the statement “^routine-
      name client disconnect ” (where routinename is the first routine that the process ran) ; if the process is in programmer
      mode, the Description field includes the statement “Programmer mode disconnect. ” Note that the event data will
      contain the pid of the process which terminated them.
•     A core dump or process exception. When a process gets a core dump or exception, it is too late for it to write to the
      audit file. Therefore, when the clean daemon runs to clean up the state of the process, it writes an audit record to the
      log with a description “ Pid <process nunber> Cleaned”.
•     A TCP Client disconnect. When a process detects that a client has disconnected, this results in an audit record with a
      Description field which contains the name of the executable that disconnected, such as “<client application> client
      disconnect” .


4.2 %System/%SQL/EmbeddedStatement
%System/%SQL/EmbeddedStatement refers to a family of auditing events, each covering a different category of SQL
statement:
•     %SQL/EmbeddedStatementDDL: Statements that change database elements, settings, or other things that aren't data.
•     %SQL/EmbeddedStatementDML: Statements that change data.
•     %SQL/EmbeddedStatementUtility: Statements that don't change data nor metadata, but instead change the status of
      the process or machine learning models.
•     %SQL/EmbeddedStatementQuery: Statements that execute or define a query that can return data.

To use these events, you must both enable the event and set the #sqlcompile audit macro preprocessor directive:

    #sqlcompile audit = ON

For reference information, see #sqlcompile audit.
If these events are enabled, then executing any embedded SQL after a #sqlcompile audit = ON directive generates
an EmbeddedStatement audit event. For example:

      ...
    #sqlcompile audit = ON
      ...
     &sql(delete from MyTable where %ID = :id)
     // This statement is audited at runtime if %System/%SQL/EmbeddedStatement events are enabled.

      ...

    #sqlcompile audit = OFF
      ...
     &sql(delete from MyOtherTable where %ID = :id)
     // This statement is not audited at runtime even if %System/%SQL/EmbeddedStatement events are enabled.

      ...

Because an application may have hundreds or thousands of SQL statements (such as those generated as part of compiled
class code and those included in system code), the combination of the audit event and the preprocessor directive allows
you to be selective in defining which embedded SQL statements to audit.
Additional notes:
•     The #sqlcompile audit = ON directive on an INSERT, UPDATE, or DELETE statement does not cause the
      embedded SQL code in any trigger to be audited. To audit a nested SQL statement, you must include an additional
      #sqlcompile audit = ON directive in the nested code. For example, if trigger code contains embedded SQL,
      there must be a #sqlcompile audit = ON directive in that trigger code.



14                                                                                                                     Auditing
                                                                                                 About System Audit Events


•   The results of the audited statement are not recorded.

You can audit all embedded SQL statements except:
•   %BEGTRANS
•   %CHECKPRIV
•   %INTRANS
•   %INTRANSACTION
•   COMMIT
•   GET
•   ROLLBACK
•   SAVEPOINT
•   SET OPTION
•   STATISTICS


4.3 %System/%Security/DBEncChange
A process generates a %System/%Security/DBEncChange event because of:
•   Encryption key activation
•   Encryption key deactivation
•   Encryption key and key file creation
•   Encryption key file modification
•   Encryption settings modification, such as enabling interactive database encryption activation at startup.

The EventData includes data relevant to the event, such as the encryption key ID and key file or a key file administrator
name.


4.4 %System/%Security/X509CredentialsChange
For create or update operations, the event data lists the changed properties, subject to security considerations. For Subject
Key Identifier and Thumbprint, the event data is a hexadecimal string of space-separated one-byte words; for Certificate,
PrivateKey, PrivateKeyPassword, and PrivateKeyType, there is no event data.
For delete operations, there is no event data.


4.5 %System/%System/DatabaseChange
A process generates a %System/%System/DatabaseChange because of any of the following changes to a database:
•   Creation
•   Modification
•   Mounting
•   Dismounting
•   Compaction



Auditing                                                                                                                  15
Manage User-Defined Audit Events


•    Truncation
•    Global compaction
•    Defragmentation

For creation and modification, changes to the following properties cause auditing events (which are included in the event
data):
•    BlockSize (Create only)
•    ClusterMountMode (Cluster systems only)
•    ExpansionSize
•    GlobalJournalState
•    MaxSize
•    NewGlobalCollation
•    NewGlobalGrowthBlock
•    NewGlobalIsKeep
•    NewGlobalPointerBlock
•    ReadOnly
•    ResourceName
•    Size

For mounting and dismounting, the event data records the database that was mounted or dismounted. For compaction,
truncation, global compaction, and defragmentation, the event data includes include the parameters that the user selected.


4.6 %System/%System/RoutineChange
A process generates a %System/%System/RoutineChange event because a routine has been compiled or deleted. When
enabled, this event causes a record to be written to the audit log whenever a routine or class is compiled. The Description
field of the audit record includes the database directory where the modification took place, what routine or class was mod-
ified, and the word “Deleted” if the routine was deleted.
InterSystems IRIS audits events on the local server but not for associated instances. For example, if one instance of Inter-
Systems IRIS is an application server that is associated with another instance that is a database server, creating and compiling
a new routine on the application server is not audited on the database server, even if the RoutineChange audit event is
enabled on the database server. To create a comprehensive list of all changes on all associated instances, enable the relevant
events on all the instances and combine their audit logs.




5 Manage User-Defined Audit Events
This section includes the following topics:
•    About User-Defined Audit Events
•    Create a User-Defined Audit Event
•    Add an Entry to the Audit Log
•    Delete a User-Defined Audit Event



16                                                                                                                     Auditing
                                                                                         Manage User-Defined Audit Events


For information on enabling or disabling a user-defined audit event, see Enable or Disable an Audit Event.


5.1 About User-Defined Audit Events
In addition to system events, InterSystems IRIS allows you to create custom events that your application can add to the
audit database. These are known as user-defined audit events or user audit events.
All currently defined events are listed on the User-Defined Audit Events page (System Administration > Security > Auditing
> Configure User Events).


5.2 Create a User-Defined Audit Event
For InterSystems IRIS to audit a user-defined event, it must be added to the list of events and then enabled. The procedure
is:
1.   In the Management Portal, go to the User-Defined Audit Events page (System Administration > Security > Auditing >
     Configure User Events).

2.   Click Create New Event. This displays the Edit Audit Event page.
3.   On this page, enter values in the Event Source, Event Type, Event Name, and Description fields where these components
     have the purposes described in Elements of an Audit Log Entry.
4.   By default, the Enabled check box on this page is selected. Click it to disable the event.
5.   Click the page’s Save button to create the event.
6.   Make sure that auditing is enabled.
7.   Once the event is defined and auditing is enabled, you can add the event to the audit log by executing the following
     command:

     Do $SYSTEM.Security.Audit(EventSource,EventType,Event,EventData,Description)

     using the EventSource, EventType, Event, and EventData values that you defined in the Portal. For more details, see
     Add an Entry to the Audit Log.


5.3 Add an Entry to the Audit Log
Applications can add their own entries to the audit log with the $SYSTEM.Security.Audit function:

Do $SYSTEM.Security.Audit(EventSource,EventType,Event,EventData,Description)

where EventSource, EventType, Event, EventData, and Description are as described in Elements of an Audit Log Entry.
Both the EventData and Description arguments can hold variables or literal values (where strings must appear in quotation
marks). InterSystems IRIS provides all other elements of the log item automatically.
The content of EventData can span multiple lines. Its content is processed in a manner similar to the argument of the
ObjectScript Write command, so it uses the following form:

"Line 1"_$Char(13,10)_"Line 2"

In this case, the content listed in the Audit Detail is displayed as “Line 1”, then $Char(13,10) is a carriage return and
line feed, then there is “Line 2 ”.




Auditing                                                                                                                  17
Enable or Disable an Audit Event


For example, a medical records application from XYZ Software Company might use values such as:


 $SYSTEM.Security.Audit(
     "XYZ Software",
     "Medical Record",
     "Patient Record Access",
     765432,
     "Access to medical record for patient 765432"
     )

Note that the application uses the EventData element to record the ID of the patient whose record was accessed.
Further, if there is an “XYZ Software/Record Update/Modify Assignment ” event defined and enabled, then the following
code changes the value of a user-selected element of a list and notes the change in the audit database:

ObjectScript
 For i=1:1:10 {
     Kill fVal(i)
     Set fVal(i) = i * i
 }

 Read "Which field to change? ",fNum,!
 Read "What is the new value? ",newVal,!
 Set oldVal = fVal(fNum)
 Set fVal(fNum) = newVal
 Set Data = "Changed field " _ fNum _ " from " _ oldVal _ " to "_ newVal _ "."
 Set Description = "Record changed by user with an application manager role"
 Do $SYSTEM.Security.Audit(
     "XYZ Software",
     "Record Update",
     "Modify Assignment",
     Data,
     Description
 )
 Write "Field changed; change noted in audit database."

Audit returns 1 or 0 to indicate that the addition succeeded or failed.
No privilege is required to add an entry to the audit log.


5.4 Delete a User-Defined Audit Event
To delete a user event:
1.   From the Management Portal home page, go to the User-Defined Audit Events page (System Administration > Security
     > Auditing > Configure User Events).
2.   On this page, locate the event that you wish to enable or disable and select Delete from the column near the right-hand
     part of the table.
3.   When prompted, confirm that you wish to delete the event.

Note:     If you delete a user-defined audit event, it is no longer available as part of the InterSystems IRIS instance for
          auditing.




6 Enable or Disable an Audit Event
To enable or disable an audit event:
1.   From the Management Portal home page, go to either:
     •   The System Audit Events page (System Administration > Security > Auditing > Configure System Events).


18                                                                                                                    Auditing
                                                                                      Manage Auditing and the Audit Database


     •     The User-Defined Audit Events page (System Administration > Security > Auditing > Configure User Events).

2.   On the System Audit Events or the User-Defined Audit Events page, locate the event that you wish to enable or disable
     and select Change Status from the right-most column of the table. This changes the Enabled status from No to Yes, or
     vice versa.




7 Manage Auditing and the Audit Database
When events are logged, they are visible in the audit database, IRISAUDIT. The audit database also contains general infor-
mation, including the name of the server, the name of the InterSystems IRIS configuration, when the log was started, and
when the log was closed.
The following actions are available for managing the audit log:
•    View the audit database
•    Copy, export, and purge the audit database
•    Encrypt the audit database
•    General management functions


7.1 View the Audit Database
To view the audit database:
1.   Select View Audit Database from the Auditing menu, which displays the View Audit Database page (System Administration
     > Security > Auditing > View Audit Database).
2.   To refine the search, use the fields in this page’s left pane and select the Search button at the bottom of the pane. (Select
     Reset Values at the bottom of the pane to restore the default values.) See below for a list of fields for refining your
     search.
3.   To see more detailed information about a particular audit event, click the Details link in its row.

To refine the search, the fields are:
•    Event Source — The component of the instance that is the source of the event.

•    Event Type — Any categorizing information for the event.

•    Event Name — The identifier of the event being logged (also known simply as the Event).

•    System IDs — An identifier for the instance that appears in each audit log entry of the form
     machine_name:instance_name. For example, an instance called MyInstance running on a machine called MyMachine,
     then its system ID is MyMachine:MyInstance.
•    PIDs — The operating-system ID of the process that logged the event.

•    Users — The user who performed the activity that triggered the event.

•    Authentications — How the user who triggered the audit event was authenticated to the instance.

•    Begin Date/Time — The date and time for the first event to be displayed (midnight at the beginning of the current day,
     by default). To choose a starting date from a calendar, click the calendar icon to the right of the field.
•    End Date/Time — The date and time for the last (most recent) event to be displayed (the current time, by default). To
     choose an end date from a calendar, click the calendar icon to the right of the field.



Auditing                                                                                                                       19
Manage Auditing and the Audit Database


•    Maximum Rows — The maximum number of rows to display in a listing of the audit log (up to 10,000).


Note:     For fields with an arrow to the right, click the arrow to display a list of all the values in use. For fields that display
          an initial asterisk (“*”), choose or enter the asterisk to display all possible values for the field.

For background information on the fields displayed, see Elements of an Audit Event.


7.2 Copy, Export, and Purge the Audit Database
The audit log is stored in the %SYS.Audit table in the %SYS namespace; all audit data is mapped to the IRISAUDIT database
and protected by the %DB_IRISAUDIT resource. By default, the %Manager role holds the Read permission on this resource
and no role holds the Write permission.
The audit log database is managed with the same tools as other InterSystems IRIS databases. For example, you can use the
Management Portal to specify its initial size, growth increment, and location. To help avoid losing audit events, we inten-
tionally disallow the audit log database from having a specified maximum size. However the database is still constrained
by disk space and other such factors. Please note, if you try to set the maximum size of the audit log database while auditing
is disabled, it will appear to allow you to do so, but when you subsequently enable auditing, the maximum size will revert
to a setting of 0, indicating no maximum size.
The Management Portal allows you to perform special management operations on the audit database:
•    Copying — You can copy entries for one or more days to a specified namespace.
•    Exporting — You can export entries for one or more days from the log to a file.
•    Purging — You can remove entries for one or more days from the log.

Note:     All these operations act on all entries for one or more days. There are no operations for particular entries.


7.2.1 Copy the Audit Database
InterSystems IRIS allows you to copy all or part of an audit database to a namespace other than IRISAUDIT. To do this:
1.   From the Management Portal home page, go to the Copy Audit Log page (System Administration > Security > Auditing
     > Copy Audit Log).
2.   On the Copy Audit Log page, first select either:
     •    Copy all items from the audit log

     •    Copy items that are older than this many days from audit log In the field here, enter a number of days; any item
          older than this is copied to the new namespace.

3.   Next, use the drop-down menu to choose the namespace where you wish to copy the audit entries.
4.   If you wish to delete the audit items after they are copied, select the check box with that choice.
5.   Click OK to copy the entries.

InterSystems IRIS places the selected audit log entries in the ^IRIS.AuditD global in the selected namespace. To view this
data:
1.   From the Management Portal home page, go to the Globals page (System Explorer > Globals).
2.   From the Globals page, select the following items in the following order:
     a.   The Databases radio button from the upper left area of the page.
     b.   The name of the database holding the copied audit log entries.



20                                                                                                                         Auditing
                                                                                      Manage Auditing and the Audit Database


     c.    The System check box that appears above the list of globals.

     This displays a list of globals in the database, including ^IRIS.AuditD. Globals are listed without the preceding “^”
     character that is needed to manipulate them programmatically or in the Terminal.

     Note:      Clicking View Globals on this page refreshes the page but unchecks in the System check box, thereby making
                ^IRIS.AuditD unavailable.

3.   Click Data from the IRIS.AuditD line to display detailed information on the audit log entries.

Once you have copied audit data to another namespace, you can use the queries of the %SYS.Audit class to look at that
data.

7.2.2 Export the Audit Database
InterSystems IRIS allows you to export all or part of an audit database. To do this:
1.   From the Management Portal home page, go to the Export Audit Log page (System Administration > Security > Auditing
     > Export Audit Log).
2.   On the Export Audit Log page, first select either:
     •     Export all items from the audit log

     •     Export items that are older than this many days from audit log In the field here, enter a number of days; any item
           older than this is exported to the new namespace.

3.   Next, in the Export to file field, enter the path of the file where you wish to export the audit entries. If you do not enter
     a full path, the root for the path provided is install-dir/Mgr/.
4.   If you wish to delete the audit items after they are exported, select the check box with that choice.
5.   Click OK to export the entries.


7.2.3 Purge the Audit Database
InterSystems IRIS allows you to purge all or part of a database.

Important:        Purging the database is not a reversible action — purged items are permanently removed. You cannot
                  restore items to the audit database once you have purged them.

To do this:
1.   From the Management Portal home page, go to the Purge Audit Log page (System Administration > Security > Auditing
     > Purge Audit Log).
2.   On the Purge Audit Log page, first select either:
     •     Purge all items from the audit log

     •     Purge items that are older than this many days from audit log In the field here, enter a number of days; any item
           older than this is purged.

3.   Click OK to purge the entries.




Auditing                                                                                                                       21
Manage Auditing and the Audit Database



7.3 Encrypt the Audit Database
InterSystems IRIS allows you to encrypt the database that holds the audit log. This is described in Configure Encryption
Startup Settings.


7.4 General Management Functions
Because the audit log is stored in a table, you can manage it with standard InterSystems IRIS system management tools
and techniques:
•    Journaling is always turned on for it.
•    You can use standard ObjectScript commands to read it. In addition, its contents are accessible via standard SQL and
     you can use any standard SQL tool to work with it.
•    You can back it up using standard InterSystems IRIS database backup facilities.
•    If it becomes full, a <FILEFULL> error occurs and is handled in the same way as for any other InterSystems IRIS
     database. To avoid this situation, see Maintain the Size of the Audit Database

Note:     All access is subject to standard security restrictions at the database and namespace levels, or through SQL for
          table-based activity.

The %SYS.Audit table in the %SYS namespace holds the audit log. All audit data is mapped to the IRISAUDIT database.
(You can also copy audit data to any other database using the functionality described in Copy the Audit Database; you can
then use the %SYS.Audit class, which is available in every namespace, to query the audit log.)

7.4.1 Maintain the Size of the Audit Database
As InterSystems IRIS runs, it writes to the audit log. Without intervention, this will eventually fill the audit database. If
the audit database becomes full, then InterSystems IRIS either continues running without capturing audit entries or halts
until it can write to the audit database; the Freeze system on audit database error setting determines this behavior.
To properly store audit information and prevent any issues, you should regularly export and save the contents of the audit
database and then purge its contents. To do this:
1.   Export the contents of the audit database as described in Export the Audit Database.

     Note:    InterSystems recommends that you export all entries from the database.

2.   Check that the exported contents of the audit database are valid.

     Important:       InterSystems recommends that you confirm that this data is valid, as purging the data is a non-reversible
                      action.

3.   Purge old entries from the existing database as described in Purge the Audit Database.

     Important:       InterSystems recommends that you purge all entries except those of the last day, which ensures that
                      there is an overlap in the different groups of saved entries.


CAUTION:          If the audit database becomes full and InterSystems IRIS continues running, it does not record audit entries
                  for actions that cause audit events. Further, in a forensic context, the existence of only a single
                  AuditRecordLost audit entry indicates that at least one record was lost.




22                                                                                                                    Auditing
                                                                                                          Other Auditing Issues




8 Other Auditing Issues
This section covers the following topics:
•    Freeze the System If It Is Impossible to Write to the Audit Database
•    Audit Event Counters


8.1 Freeze the System If It Is Impossible to Write to the Audit Database
During operations of InterSystems IRIS, it may become impossible to write to the audit database. This can happen due to
a filled disk, a failed network connection, or some other reason. If this occurs, InterSystems IRIS can then either:
•    Generate an error and continue running (the default).
•    Freeze the system.

To modify this behavior:
1.   Go to the System-wide Security Parameters page (System Administration > Security > System Security > System-wide
     Security Parameters). On this page, if auditing is enabled, the Freeze system on audit database error check box is
     available.
2.   Select or clear the Freeze system on audit database error check box.
3.   Click the page’s Save button.

For example, suppose the audit database fills up. Any attempt to write to the audit log will generate a <FILEFULL> error
(disk full). The difference between the behaviors is:
•    When generating an error and continuing to run (the default) — The process does not write the audit record to the audit
     log; the audit record is therefore lost. When the problem is resolved, an entry is written into the audit log that lists how
     many audit events were lost.
•    When freezing the instance if there is an error — The process writes the error message to the messages.log file; the
     system then freezes.


8.1.1 Tips on Recovering from Audit Log Errors
To recover from a disk full error, force down the system, free up space on the audit disk, then restart the system.
To recover from an error caused by database corruption, delete or move the audit database; then create a new audit database
or copy a new one into the old one’s place. (To clear the error, you must use a new database rather than simply restarting
the system because restarting may write audit records, which will cause the system to freeze again.)


8.2 Audit Event Counters
To facilitate security monitoring, InterSystems IRIS keeps a counter for each audit event type and makes these counters
available via the InterSystems IRIS monitoring interface. These counters are maintained even if auditing is not enabled.
As an example, a site might monitor the LoginFailure event counter, to help detect break-in attempts.

Note:      Audit counters are reset when the instances is restarted.




Auditing                                                                                                                      23
Other Auditing Issues


8.2.1 Reset the Counters for a System Audit Event
To reset the counters for a system event:
1.   From the Management Portal home page, go to the System Audit Events page (System Administration > Security >
     Auditing > Configure System Events).

2.   On this page, locate the event that you wish to enable or disable and select Reset from the column near the right-hand
     part of the table.
3.   When prompted, click OK. This resets both the Total and Written counters for the event.


8.2.2 Reset the Counters For a User-Defined Audit Event
To reset the counters for a user event:
1.   From the Management Portal home page, go to the User-Defined Audit Events page (System Administration > Security
     > Auditing > Configure User Events).
2.   On this page, locate the event that you wish to enable or disable and select Reset from the column near the right-hand
     part of the table. This resets both the Total and Written counters for the event.
3.   When prompted, click OK. This resets both the Total and Written counters for the event.




24                                                                                                                Auditing
