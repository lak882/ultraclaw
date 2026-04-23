IRISSECURITY Upgrade
       Impact
                            Version 2026.1
                             2026-04-20




 InterSystems Corporation One Congress Street Boston MA 02114 www.intersystems.com
IRISSECURITY Upgrade Impact
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
       IRISSECURITY Upgrade Impact........................................................................................................ 1
           1 Before You Upgrade ...................................................................................................................... 1
           2 Changes in Behavior and Updated Procedures ............................................................................. 2
               2.1 Global Access ...................................................................................................................... 2
               2.2 Global Locations ................................................................................................................. 2
               2.3 OAuth2 Global Mapping ..................................................................................................... 3
               2.4 SQL Security ....................................................................................................................... 4
               2.5 Percent-class Access Rules ................................................................................................. 4


       List of Tables
            Table 1: ............................................................................................................................................ 2




IRISSECURITY Upgrade Impact                                                                                                                                           iii
IRISSECURITY Upgrade Impact
In InterSystems IRIS 2025.2, security data was moved from the IRISSYS database to the IRISSECURITY database, and
the %SecurityAdministrator role was introduced for general security administration tasks. Unlike IRISSYS, IRIS-
SECURITY can be encrypted, which secures your sensitive data at rest. IRISSECURITY cannot be mirrored, but support
is planned for a future version.
The introduction of the IRISSECURITY database introduces several breaking changes in behavior, which can lead to
unexpected behavior when upgrading from InterSystems IRIS 2025.1 and below. This page details each change in behavior,
the operations affected, and the updated procedures.

Note:    The changes described in this page affect both continuous delivery (CD) and extended maintenance (EM) release
         tracks. That is, starting with versions 2025.2 (CD) and 2026.1 (EM), InterSystems IRIS will include the IRISSE-
         CURITY database, and all security data is automatically moved from IRISSYS to IRISSECURITY when you
         upgrade.




1 Before You Upgrade
When you upgrade from InterSystems IRIS 2025.1 or below, all security data is automatically moved from IRISSYS to
the IRISSECURITY database. This makes several improvements to data security and access management, but these changes
can be breaking:
•   Users can no longer directly access security globals without %All and must instead use the APIs provided by the var-
    ious security classes.
•   OAuth2 globals can no longer be mapped to a different database.
•   Users can no longer arbitrarily query security tables, even when SQL security is disabled.
•   System databases now use predefined resources that cannot be changed. On Unix, if you created and assigned a new
    resource to a system database in a previous version, it will be replaced by the predefined resource when you upgrade
    (though if any roles reference the non-default resource, they must be changed manually to use the default resource to
    keep database access).
    On Windows, you must change the resource back to the default. If you attempt to upgrade on Windows while databases
    have non-default resources, the upgrade will halt (the instance is not modified) and display an error message "Database
    must have a resource label of..."

The following sections go into detail about these changes and what you should do instead if you depended on the original
behavior, but in general, before you upgrade, you should verify and test that your applications and macros:
•   Use the provided security APIs to administer security (as opposed to direct global access).
•   Have the necessary permissions (%DB_IRISSYS:R and %Admin_Secure:U) for using those APIs.




IRISSECURITY Upgrade Impact                                                                                              1
Changes in Behavior and Updated Procedures




2 Changes in Behavior and Updated Procedures
The following sections go into detail about these changes and what you should do instead if you depended on the original
behavior.


2.1 Global Access
Previously, when security globals were stored in the IRISSYS database, users could access security data with the following
privileges:
•     %DB_IRISSYS:R: Read security globals both directly and through security APIs.

•     %DB_IRISSYS:RW: Read and write security globals.

•     %DB_IRISSYS:RW and %Admin_Secure:U: Administer security through security APIs.

Starting InterSystems IRIS 2025.2:
•     Security globals are now stored in IRISSECURITY.
•     Users can no longer access security globals directly without %All.
•     Both %DB_IRISSYS:R and %Admin_Secure:U are the minimum privileges needed to both access security data
      (through the provided security APIs) and administer security through the various security classes.
•     For general security administration, you can use the new %SecurityAdministrator role.
•     Read-only access to security data (previously available through %DB_IRISSYS:R) has been removed.


2.2 Global Locations
In InterSystems IRIS 2025.2, the following security globals have been moved from IRISSYS to the ^SECURITY global
located in IRISSECURITY:
•     ^SYS("SECURITY")
•     ^OAuth2.*
•     ^PKI.*
•     ^SYS.TokenAuthD

The following table lists the most notable globals that have been moved, their security classes, old locations, and new
locations:
Table 1:

    Security Class                         Old Location (IRISSYS)                  New Location (IRISSECURITY)
    N/A                                    ^SYS("Security","Version")              ^SECURITY("Version")
    Security.Applications                  ^SYS("Security","ApplicationsD")        ^SECURITY("ApplicationsD")
    Security.DocDBs                        ^SYS("Security","DocDBsD")              ^SECURITY("DocDBsD")
    Security.Events                        ^SYS("Security","EventsD")              ^SECURITY("EventsD")
    Security.LDAPConfigs                   ^SYS("Security","LDAPConfigsD")         ^SECURITY("LDAPConfigsD")
    Security.KMIPServers                   ^SYS("Security","KMIPServerD")          ^SECURITY("KMIPServerD")



2                                                                                         IRISSECURITY Upgrade Impact
                                                                                Changes in Behavior and Updated Procedures


    Security Class                         Old Location (IRISSYS)                       New Location (IRISSECURITY)
    Security.Resources                     ^SYS("Security","ResourcesD")                ^SECURITY("ResourcesD")
    Security.Roles                         ^SYS("Security","RolesD")                    ^SECURITY("RolesD")
    Security.Services                      ^SYS("Security","ServicesD")                 ^SECURITY("ServicesD")
    Security.SSLConfigs                    ^SYS("Security","SSLConfigsD")               ^SECURITY("SSLConfigsD")
    Security.System                        ^SYS("Security","SystemD")                   ^SECURITY("SystemD")
    Security.Users                         ^SYS("Security","UsersD")                    ^SECURITY("UsersD")
    %SYS.PhoneProviders                    ^SYS("Security","PhoneProvidersD")           ^SECURITY("PhoneProvidersD ")
    %SYS.X509Credentials                   ^SYS("Security","X509CredentialsD")          ^SECURITY("X509CredentialsD ")
    %SYS.OpenAIM.IdentityServices          ^SYS("Security","OpenAIMIdentityServersD")   ^SECURITY("OpenAIMIdentityServersD")
    OAuth2.AccessToken                     ^OAuth2. AccessTokenD                        ^SECURITY("OAuth2.AccessToken
                                                                                        ")
    OAuth2.Client                          ^OAuth2.ClientD                              ^SECURITY("OAuth2.Client")
    OAuth2.ServerDefinition                ^OAuth2.ServerDefinitionD                    ^SECURITY("OAuth2.ServerDefinitionD")
    OAuth2.Client.MetaData                 ^OAuth2.Client.MetaDataD                     ^SECURITY("OAuth2.Client.MetaDataD")
    OAuth2.Server.AccessToken              ^OAuth2.Server.AccessTokenD                  ^SECURITY("OAuth2.Server.AccessTokenD")
    OAuth2.Server.Client                   ^OAuth2.Server.ClientD                       ^SECURITY("OAuth2.Server.ClientD")
    OAuth2.Server.Configuration            ^OAuth2.Server.ConfigurationD                ^SECURITY("OAuth2.Server.ConfigurationD")
    OAuth2.Server.JWTid                    ^OAuth2.Server.JWTidD                        ^SECURITY("OAuth2.Server.JWTidD")
    OAuth2.Server.Metadata                 ^OAuth2.Server.MetadataD                     ^SECURITY("OAuth2.Server.MetadataD")
    PKI.CAClient                           ^PKI.CAClientD                               ^SECURITY("PKI.CAClient")
    PKI.CAServer                           ^PKI.CAServerD                               ^SECURITY("PKI.CAServer")
    PKI.Certificate                        ^PKI.CertificateD                            ^SECURITY("PKI.Certificate")
    %SYS.TokenAuth                         ^SYS.TokenAuthD                              ^SECURITY("TokenAuthD")


2.3 OAuth2 Global Mapping
Previously, you could map OAuth2 globals to a different database, which allowed OAuth2 configurations to be mirrored.
Starting in InterSystems IRIS 2025.2, OAuth2 globals can no longer be mapped, and IRISSECURITY cannot be mirrored.
If you depended on this behavior for mirroring, you can use any of the following workarounds:
•     Manually make changes to both the primary and failover.
•     Export the settings from the primary and then import them to the failover (requires %All).

To export OAuth2 configuration data:

set items = $name(^|"^^:ds:IRISSECURITY"|SECURITY("OAuth2"))_".gbl"
set filename = "/home/oauth2data.gbl"
do $SYSTEM.OBJ.Export(items,filename)

To import OAuth2 configuration data:

do $SYSTEM.OBJ.Import(filename)



IRISSECURITY Upgrade Impact                                                                                                         3
Changes in Behavior and Updated Procedures



2.4 SQL Security
Previously, SQL security was controlled by the CPF parameter DBMSSecurity. When DBMSSecurity was disabled,
users with SQL privileges could arbitrarily query all tables in the database.
Starting in InterSystems IRIS 2025.2:
•   The DBMSSecurity CPF parameter has been replaced with the system-wide SQL security property. You can enable
    (1, default) or disable (0) this in several ways:
    –    Management Portal: System Administration > System > System Security > System-wide Security Parameters >
         Enable SQL security

    –    $SYSTEM.SQL.Util.SetOption():

         do ##class(%SYSTEM.SQL.Util).SetOption("SQLSecurity", 1)

    –    Security.System.Modify():

         set properties("SQLSecurity")=1
         do ##class(Security.System).Modify(,.properties)


•   Security tables can now only be queried through the Detail and List APIs, which require both %DB_IRISSYS:R and
    %Admin_Secure:U even when SQL security is disabled.

For example, to get a list of roles, you can no longer directly query the Security.Roles table. Instead, you should use the
Security.Roles_List() query:

SELECT Name, Description FROM Security.Roles_List()



2.5 Percent-class Access Rules
In previous versions of InterSystems IRIS, the procedure for creating rules for managing a web application's access to
additional percent classes involved writing to security globals. You can accomplish this in InterSystems IRIS 2025.2 through
the Management Portal or the ^SECURITY routine.
To create a class access rule with the Management Portal:
•   Go to System Administration > Security > Web Applications.
•   Select your web application
•   In the Percent Class Access tab, set the following options:
    –    Type: Controls whether the rule applies to the application's access to just the specified percent class (AllowClass)
         or all classes that contain the specified prefix (AllowPrefix).
    –    Class name: The percent class or prefix to give the application access to.

    –    Allow access: Whether to give the application access to the specified percent class or package.

    –    Add this same access to ALL applications: Whether to apply the rule for all applications.


To create a class access rule with the ^SECURITY routine:
•   From the %SYS namespace, run the ^SECURITY routine:

    DO ^SECURITY




4                                                                                          IRISSECURITY Upgrade Impact
                                                                           Changes in Behavior and Updated Procedures


•   Choose options 5, 1, 8, and 1 to enter the class access rule prompt.
•   Follow the prompts, specifying the following:
    –   Application?: The name of the application.

    –   Allow type?: Whether the rule applies to the application's access to just the specified percent class (AllowClass)
        or all classes that contain the specified prefix (AllowPrefix).
    –   Class or package name?: The class or prefix to give the application access to

    –   Allow access?: Whether to give the application access to the specified class or package.




IRISSECURITY Upgrade Impact                                                                                             5
