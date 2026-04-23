InterSystems Supported
       Platforms
                           Version 2026.1
                            2026-04-20




InterSystems Corporation One Congress Street Boston MA 02114 www.intersystems.com
InterSystems Supported Platforms
PDF generated on 2026-04-20
InterSystems Version 2026.1
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
        1 Supported Technologies ..................................................................................................................... 1
            1.1 Supported Platforms ................................................................................................................... 1
                 1.1.1 Operating System Patches and Service Packs .................................................................. 1
                 1.1.2 Distribution Kits and Operating System Versions ............................................................ 1
                 1.1.3 Server Platforms ............................................................................................................... 2
                 1.1.4 Container Platforms ......................................................................................................... 2
                 1.1.5 Cloud Platforms ............................................................................................................... 3
                 1.1.6 Development Platforms .................................................................................................... 3
                 1.1.7 Hardware Considerations ................................................................................................. 3
            1.2 Supported File Systems .............................................................................................................. 4
            1.3 Supported Web Servers .............................................................................................................. 4
            1.4 Supported Web Browsers ........................................................................................................... 5
            1.5 ODBC Support ........................................................................................................................... 6
            1.6 Node.js Support .......................................................................................................................... 6
            1.7 Platform Endianness ................................................................................................................... 6
            1.8 Supported SQL Gateway Databases ........................................................................................... 7
            1.9 Supported .NET Frameworks ..................................................................................................... 7
            1.10 Supported Java Technologies ................................................................................................... 8
            1.11 Embedded Python Support ....................................................................................................... 9
            1.12 Other Supported Technologies ............................................................................................... 10
            1.13 Other Supported Features ....................................................................................................... 10
        2 Supported Languages ....................................................................................................................... 11
            2.1 InterSystems IRIS .................................................................................................................... 11
            2.2 NLP .......................................................................................................................................... 12
        3 Supported Version Compatibility .................................................................................................... 13
            3.1 ODBC and JDBC Compatibility .............................................................................................. 13
            3.2 Web Gateway Compatibility .................................................................................................... 13
            3.3 Backup Restore Compatibility ................................................................................................. 14
            3.4 Journal Restore Compatibility (Upgrade Implications) ........................................................... 14
            3.5 Mirror Compatibility ................................................................................................................ 14
            3.6 Mirror Arbiter (ISCAgent) Compatibility ................................................................................ 15
            3.7 ECP Compatibility ................................................................................................................... 15
        4 Cross-Product Technology Matrix .................................................................................................. 17




InterSystems Supported Platforms                                                                                                                                    iii
1
Supported Technologies
This page lists the technologies that InterSystems products support.




1.1 Supported Platforms
This release supports the listed server platforms and operating system releases on the indicated InterSystems products.
•   Server Platforms
•   Container Platforms
•   Cloud Platforms
•   Development Platforms


1.1.1 Operating System Patches and Service Packs
Because InterSystems relies on the operating system vendor to ensure compatibility, InterSystems does not certify its
products for specific operating system patches or service packs.
In the rare event that a specific patch or service pack (SP) is required to run InterSystems products, the appropriate table
indicates the explicit requirement.
If a vendor introduces new features or functionality in a base version to create a new offering, InterSystems does not do
additional testing but relies on the vendor to assure the quality of the base version.


1.1.2 Distribution Kits and Operating System Versions
When selecting a distribution kit, be sure to choose the correct kit for the version of the Operating System that you are
running. Some products provide a separate kit for each supported Operating System version.
When you upgrade your Operating System, verify whether your currently installed kit is still compatible with your new
Operating System. If not, you will need to install a new kit that matches your new OS version, even though the product’s
version has not changed.




InterSystems Supported Platforms                                                                                               1
Supported Technologies



1.1.3 Server Platforms
    Platform                                   Notes

    IBM AIX® 7.2, 7.3 for POWER                InterSystems IRIS supports OpenSSL 3.0 on AIX 7.2 and 7.3 via
    System-64 (POWER 8 and higher)             the aixopenssl30 kit. This kit has, as prerequisites, the latest Tech
                                               Level for either AIX 7.2 and 7.3.
                                               InterSystems IRIS for AIX was compiled using the IBM XL C/C++
                                               for AIX 16.1.x and 17.1.x compilers. If the system on which you
                                               are installing InterSystems IRIS does not have both of these ver-
                                               sions of the compiler or runtime already installed, you must install
                                               them both. First install 16.1.x, then 17.1.x.
                                               See https://www.ibm.com/support/pages/node/612497#171X for
                                               more information.

    Microsoft Windows:
    •   Server 2019, 2022, and 2025 for
        x86–64
    •   Windows OS 10 and 11 for x86–64


    Oracle Linux 9 and 10 for x86–64           Unmodified kernel.

    Red Hat Enterprise Linux 9 and 10 for      To use Kerberos on the Red Hat platform, you must install the
    x86-64 or ARM64                            krb5-devel package in addition to the krb5-libs package. See the
                                               Red Hat Linux Platform Notes section of the “ Preparing to Install
                                               InterSystems IRIS ” chapter of the Installation Guide for detailed
                                               information on obtaining these components.
                                               See Red Hat’s support lifecycle page for guidance on currently
                                               supported minor versions.

                                               See SUSE’s support lifecycle pagefor guidance on currently sup-
                                               ported minor versions.
    SUSE Linux Enterprise Server 15 (SP6
    and up) and 16 for x86-64                  InterSystems IRIS requires OpenSSL 3, which is the default
                                               starting with SP6.

    Ubuntu 22.04, 24.04 LTS for x86-64 or      A default Ubuntu setting can result in semaphore deletion. See
    ARM64                                      the Ubuntu Platform Notes section of the “ Preparing to Install
                                               InterSystems IRIS ” chapter of the Installation Guide for more
                                               information.


1.1.4 Container Platforms
Container images from InterSystems comply with the Open Container Initiative (OCI) specification and are built using the
Docker Enterprise Edition engine, which fully supports the OCI standard. InterSystems containers therefore are supported
on any OCI compliant runtime engine on Linux-based operating systems, both on-premises and in public clouds.
Container host systems are subject to the InterSystems Minimum Supported CPU policy.




2                                                                                    InterSystems Supported Platforms
                                                                                                       Supported Platforms


InterSystems container images are built and tested using Ubuntu as their base operating system. These images are available
for the CPU architectures shown below:

    Image Operating System                        CPU Architecture

                                                  •    Intel/AMD 64–bit
    Ubuntu 24.04                                  •    ARM 64–bit



1.1.5 Cloud Platforms
InterSystems IRIS can be successfully deployed on cloud platforms that meet both of the following criteria:
•     The operating system platform is in the supported Server Platform list.
•     The cloud platform provides support for their infrastructure.

Customers using mirroring on cloud virtual machines should note that the public clouds require IP addresses, as opposed
to virtual IPs, for mirroring.


1.1.6 Development Platforms
In addition to the listed Server Platforms, the following platforms are supported for development work:

    Platform                                      Notes

                                                  Use the current version of OpenSSL. You can install this using
                                                  Homebrew: https://formulae.brew.sh/formula/openssl@3
                                                  InterSystems IRIS requires several dependencies to run on this
                                                  platform. See Installing Required Dependencies for more informa-
    Apple macOS 13, 14, 15, and 26 for            tion.
    ARM
                                                  Key Management Interoperability Protocol (KMIP) is not supported
                                                  on macOS.
                                                  On the M1 platform, Shared Memory Connections (SHM) for Java
                                                  are not supported.

Support for development platforms is subject to the following qualifications:
•     Development platforms are to be used for application development only; they are not supported for deployment of
      applications.
•     The results of comparative analysis will not be underwritten by InterSystems. No valid conclusions can be drawn from
      performance, sizing, or other measurements taken on supported development platforms versus other supported platforms.
•     InterSystems will reevaluate its continued support for these platforms with each major release of InterSystems IRIS.


1.1.7 Hardware Considerations
In most cases, this document focuses specifically on operating system versions, and only generally on the characteristics
of the underlying hardware. This section is intended as a refinement of that approach, describing specific features of indi-
vidual hardware offerings that InterSystems products recognize and use to their advantage.




InterSystems Supported Platforms                                                                                           3
Supported Technologies


Minimum Supported CPU
InterSystems IRIS running on Intel and AMD (amd64/x86_64) processors must include the AVX, AVX2, BMI, and BMI2
instructions.




1.2 Supported File Systems
This release supports the following file systems on the specified platforms:

                                                      Recommended File              Other Supported File Systems
                    Platform                              System
    Apple macOS                                               HFS                                   APFS

    IBM AIX® for POWER System-64                                  3,4
                                                             JFS2
    Microsoft Windows for x86-64                              NTFS

    Oracle Linux for x86-64                                         4
                                                              XFS
    Red Hat Enterprise Linux for x86-64 or                          4                           1       1,2,4
    ARM64                                                     XFS                         ext3 , ext4           , NFS

    SUSE Linux Enterprise for x86-64                                4                       4       1       1,2,4
                                                              XFS                     Btrfs , ext3 , ext4           , NFS

    Ubuntu for x86-64 or ARM64                                      4                       4       1       1,2,4
                                                              XFS                     Btrfs , ext3 , ext4           , NFS
1
    The data=journal mount option for ext3/ext4 file systems is not supported.
2
  For customers wishing to use ext4, InterSystems recommends it only be used for journal and WIJ volumes, and the XFS
file system be used for data volumes.
3
    For optimum journaling performance, the cio mount option is recommended for JFS2 file systems.
4
    This file system enables faster database creation and expansion operations when compared with other options available.




1.3 Supported Web Servers
This release supports CSP technology on the following web servers for the indicated platforms. This does not necessarily
mean that all InterSystems products run on these platforms, but rather that the InterSystems Web Gateway component does.




4                                                                                       InterSystems Supported Platforms
                                                                                                Supported Web Browsers


    Web Server                      Platform
    Apache 2.4                      •   Apple macOS
                                    •   IBM AIX® for POWER System-64
                                                                              *


                                    •   Microsoft Windows
                                                            **


                                    •   Oracle Linux
                                    •   Red Hat Enterprise Linux
                                    •   SUSE Linux Enterprise
                                    •   Ubuntu


    Microsoft IIS 7.0 and later     •   Microsoft Windows


    Nginx (Stable)                  •   Apple macOS
                                    •   IBM AIX® for POWER System-64
                                    •   Microsoft Windows
                                    •   Red Hat Enterprise Linux
                                    •   SUSE Linux Enterprise
                                    •   Ubuntu


*
 Using Kerberos security and/or SSL for the Web Gateway on 64-bit UNIX® platforms requires 64-bit Apache.
**
    Requires manual configuration. See Install a Stand-Alone Web Gateway for details.




1.4 Supported Web Browsers
InterSystems IRIS supports CSP on the web browsers listed in the following tables.

Browser Platforms
Newer versions of the browsers listed in the following table will be supported with the understanding that critical issues
may be found that will have to be corrected in a major release of InterSystems IRIS. Those fixes will not be backported to
earlier releases of InterSystems IRIS.
InterSystems also requires that browsers support the XML HTTP interface which limits support for some older browser
versions.

    Platform                                                  Supported Web Browsers
    Windows                                                 Chrome, Edge, Firefox, Opera
    Linux                                                                Firefox
    Android                                                              Chrome
    iOS                                                                   Safari
    macOS                                                   Chrome, Firefox, Opera, Safari



InterSystems Supported Platforms                                                                                        5
Supported Technologies


Portals
Support for the InterSystems IRIS Management Portal is limited to the browsers listed in the following table. Except where
noted, this includes support for InterSystems IRIS® Business Intelligence functionality. New versions released by vendors
are assumed to provide backward compatibility; they are supported as described in Supported Web Browsers and are tested
as they become available.

    Web Browser (Platform)                             Version

    Chrome (Windows, macOS)                            latest released
    Edge (Windows)*                                    latest released
    Firefox (Windows, macOS, Linux)                    latest released

*At this time, InterSystems does not fully support InterSystems IRIS® Business Intelligence functionality on Microsoft
Edge.




1.5 ODBC Support
InterSystems products support multithreaded ODBC on most platforms.
The InterSystems ODBC driver on UNIX®-based systems supports the following driver managers:
•     The iODBC driver manager (see http://www.iodbc.org) — for use with the Unicode and 8-bit ODBC APIs; works
      with the select executable and the following drivers:

       libirisodbc35.so                        iODBC 3.5 driver
       libirisodbciw35.so                      iODBC 3.5 Unicode driver


•     The unixODBC driver manager (see http://www.unixodbc.org) — for use with the 8-bit ODBC API only; works with
      the selectu executable and the following driver:

       libirisodbcuw35.so                      unixODBC 3.5 Unicode driver
       libirisodbcur6435.so                    unixODBC Real Mode built 3.5 driver




1.6 Node.js Support
This release supports Node.js clients on the platforms and operating system versions listed in the Supported Server Platforms
table. For information about installation and configuration, see Native SDK for Node.js.




1.7 Platform Endianness
When restoring a backup or transferring a database, the target system must be the same Endianness (Big-endian or Little-
endian) as the source system; for example, if a backup was created on a Big-endian system, it cannot be restored to a Little-
endian system. For information, see Using cvendian to Convert Between Big-endian and Little-endian Systems.



6                                                                                        InterSystems Supported Platforms
                                                                                      Supported SQL Gateway Databases


The following table identifies the Endianness of the supported server platforms for this release:

    Platform                                                                                         Endianness
    Apple macOS                                                                                      Little-endian
    IBM AIX® for POWER System-64                                                                      Big-endian
    Microsoft Windows for x86-64                                                                     Little-endian
    Oracle Linux for x86-64                                                                          Little-endian
    Red Hat Enterprise Linux for x86-64 or ARM64                                                     Little-endian
    SUSE Linux Enterprise Server for x86-64                                                          Little-endian
    Ubuntu for x86–64 or ARM64                                                                       Little-endian




1.8 Supported SQL Gateway Databases
The InterSystems IRIS SQL Gateway supports access to external databases from InterSystems IRIS so long as:
•     The external database is supported by its manufacturer. For example, InterSystems IRIS can support a connection to
      Oracle 10g as long as Oracle 10g is still in Oracle's extended maintenance window.
•     The connecting driver is compliant with the appropriate protocol. InterSystems IRIS supports ODBC 3.0 through 3.7
      as well as JDBC 4.0 through 4.3.

The SQL Gateway provides features for querying external databases using the InterSystems IRIS SQL dialect. InterSystems
regularly tests these features against the latest versions of the following database systems:
•     IBM Db2
•     IBM Informix
•     Microsoft SQL Server
•     MySQL
•     Oracle
•     Sybase Adaptive Server Enterprise




1.9 Supported .NET Frameworks
InterSystems supports .NET on Windows, Linux, and macOS. Versions of the .NET Framework are supported only on
Windows. All InterSystems assemblies for .NET are installed to the .NET GAC (Global Assembly Cache) when InterSystems
IRIS is installed.
You can use any version of Visual Studio that is supported by Microsoft for your .NET development, with the following
exception: Entity Framework (EF) development requires specific Visual Studio tools to be installed in order to work with
newer versions of Visual Studio. The current EF Provider supports up to VS 2019 for InterSystems IRIS. VS 2022 is not
supported.




InterSystems Supported Platforms                                                                                       7
Supported Technologies


Note:      The InterSystems IRIS installation procedure does not install or upgrade any version of .NET or .NET Framework.
           Your client system must have a supported version of .NET or .NET Framework installed in order to use these
           assemblies.

There is a separate version of the IRISClient assembly (InterSystems.Data.IRISClient.dll) for each supported version of .NET
and .NET Framework. These files are located in the following subdirectories of <iris-install-dir>\dev\dotnet (see “Installation
Directory” in the Installation Guide for the location of <iris-install-dir> on your system):
•     .NET Framework 3.5: \dev\dotnet\bin\v3.5
•     .NET Framework 4.6.2: \dev\dotnet\bin\v4.6.2
•     .NET 6.0: \dev\dotnet\bin\net6.0
•     .NET 9.0: \dev\dotnet\bin\net9.0

The current default version is .NET 9.0.

Note:      Extra Requirements for XEP
           If your application uses both .NET Framework and XEP (see Persisting .NET Objects with InterSystems XEP),
           you must also declare the InterSystems.Data.XEP.dll assembly.
           There is a separate version of this file for each of the following .NET Framework versions:
           •   .NET Framework 3.5: \dev\dotnet\bin\v3.5
           •   .NET Framework 4.6.2: \dev\dotnet\bin\v4.6.2

           XEP does not require a separate assembly if your application uses .NET 6.0 or higher.

In some applications, the .NET Framework assemblies may be used to load unmanaged code libraries. Both 32-bit and 64-
bit assemblies are provided for each supported version, which makes it possible to create gateway applications for 64-bit
Windows that can load 32-bit libraries.
If you wish to use a version other than the default for your system, some extra configuration will be required to set the path
to your desired language platform.

Note:      InterSystems IRIS .NET clients do not support Kerberos because the .NET Framework does not include direct
           Kerberos support.




1.10 Supported Java Technologies
InterSystems Java products require a Java Development Kit (JDK) from Oracle (or a compatible JDK). This release supports
the following JDKs:

    Development Kits                                             Versions
    Java SE Development Kit (JDK)                                8 and higher
    OpenJDK                                                      8 and higher


Please contact InterSystems if you would like to take advantage of InterSystems product license sharing when running Java
on Windows Terminal Servers.




8                                                                                         InterSystems Supported Platforms
                                                                                                   Embedded Python Support




1.11 Embedded Python Support
The following table summarizes the versions of Python supported when using Embedded Python with InterSystems products.
(Supported operating system versions are those listed in the Supported Server Platforms table.)
The default version of Python supported for Embedded Python is the version that comes with your operating system and
is the version tested by InterSystems for use with Embedded Python.
The Flexible Python Runtime feature allows you to use a version of Python higher than the default version of Python for
your operating system. The table indicates the latest version of Python enabled with Flexible Python Runtime for each
operating system.
For more information, see Installing Embedded Python.

Important:         InterSystems IRIS does not support free threading in Python when used with Embedded Python. Do not
                   disable the global interpreter lock (GIL) if you are using Embedded Python. For more information, see
                   Python support for free threading.

Note:      The limitations in the table below do not apply to code written in Python that interacts with the InterSystems IRIS
           kernel using a driver in an InterSystems IRIS software development kit (SDK).

                                                     Default Version of Python               Latest Version of Python
                                                     Supported for Embedded                Enabled with Flexible Python
    Platform                                                  Python                                 Runtime
                                                    Python 3.11 (installation with
    Apple macOS                                                                                          N/A
                                                     Homebrew recommended)
                                                   Python 3.9.18+ (installed from
    IBM AIX® for POWER System-64                     the AIX Toolbox for Open                            N/A
                                                                            1, 2
                                                         Source Software)
    Microsoft Windows for x86-64                                  N/A                               Python 3.14
                                                                                       1
                                                     Oracle Linux 9: Python 3.9            Latest version available for the
    Oracle Linux for x86-64                                                                           platform
                                                    Oracle Linux 10: Python 3.12

                                                                                   1
    Red Hat Enterprise Linux for x86-64 or             Red Hat 9: Python 3.6               Latest version available for the
    ARM64                                             Red Hat 10: Python 3.12                         platform

                                                                               1
                                                        SUSE 15: Python 3.9                Latest version available for the
    SUSE Linux Enterprise for x86-64                                                                  platform
                                                       SUSE 16: Python 3.13

    Ubuntu for x86–64 or ARM64                       Ubuntu 22.04: Python 3.10             Latest version available for the
                                                     Ubuntu 24.04: Python 3.12                        platform

1
 This version of Python is no longer supported by the Python Software Foundation, however, it continues to be supported
by the platform vendor.
2
    This version of Python is the only version supported on AIX. Later versions are not enabled at this time.




InterSystems Supported Platforms                                                                                              9
Supported Technologies




1.12 Other Supported Technologies
This release supports other technologies as specified in the following tables:

    Supported Libraries                                        Version
    ICU                                                        69.1
    Xerces                                                     3.2

    Xalan                                                            *
                                                               1.12
                                                               Instance-specific; to determine the version in use by
    OpenSSL                                                    the instance, call
                                                               $SYSTEM.Encryption.OpenSSLVersion()


* New at this release.

    ODBC Driver Managers                                       Version
    unixODBC                                                   2.3.4
    iODBC                                                      3.52.4




1.13 Other Supported Features
InterSystems products support the LDAP protocol, multithreaded callin, T-SQL programming extensions, the MQ Interface,
and IntegratedML as indicated in the following table. (Supported operating system versions are those listed in the Supported
Server Platforms table.)

    Platform                                                                        Supported Features
    Apple macOS                                                                  LDAP, T-SQL, IntegratedML

    IBM AIX® for POWER System-64                                                                               1
                                                                                 LDAP, T-SQL, MQ Interface
                                                                          LDAP, Multithreaded Callin, T-SQL, MQ
    Microsoft Windows for x86-64                                                            1
                                                                                  Interface , IntegratedML
                                                                          LDAP, Multithreaded Callin, T-SQL, MQ
    Oracle Linux for x86-64                                                                           1
                                                                                          Interface
                                                                          LDAP, Multithreaded Callin, T-SQL, MQ
    Red Hat Enterprise Linux for x86-64 or ARM64                                            1
                                                                                  Interface , IntegratedML
                                                                          LDAP, Multithreaded Callin, T-SQL, MQ
    SUSE Linux Enterprise for x86-64                                                        1
                                                                                  Interface , IntegratedML
    Ubuntu for x86–64 or ARM64                                            LDAP, Multithreaded Callin, T-SQL, MQ
                                                                                            1
                                                                                  Interface , IntegratedML
1
    The minimum version supported by InterSystems IRIS is WebSphere MQ V7.0.




10                                                                                      InterSystems Supported Platforms
2
Supported Languages
InterSystems IRIS provides National Language Support (NLS) for selected regions in one or more character sets. InterSystems
IRIS also includes utility translations for some languages. These localizations exist for the languages as indicated in the
following table.
InterSystems IRIS documentation is available in English and Japanese.




2.1 InterSystems IRIS
The languages in the following table are supported by InterSystems IRIS in this release:

                                                                                                           Utility
 Language                                               Character Sets                                  Translation
 Arabic                        CP1256 (Arabic), Latin/Arabic, Unicode
 Chinese (Simplified)          GB18030 (Chinese National Standard), Unicode
 Chinese (Traditional)         Unicode
 Chinese (Mandarin)            Unicode                                                                    Included
 Czech                         CP1250 (Central Europe), Latin-2, Unicode
 Danish                        Latin-1, Latin-9, CP1252 (Western Europe), Unicode
 Dutch                         Latin-1, Latin-9, CP1252 (Western Europe), Unicode                         Included

 English                              †                                                                   Included
                               ASCII , Latin-1, Latin-9, CP1252 (Western Europe), Unicode
 Finnish                       Latin-1, Latin-9, CP1252 (Western Europe), Unicode
 French                        Latin-1, Latin-9, CP1252 (Western Europe), Unicode                         Included
 German                        Latin-1, Latin-9, CP1252 (Western Europe), Unicode                         Included
 Greek                         CP1253 (Greek), Latin-G, Unicode
 Hebrew                        CP1257 (Hebrew), Latin-H, Unicode
 Hungarian                     CP1250 (Central Europe), Latin-2, Unicode
 Italian                       Latin-1, Latin-9, CP1252 (Western Europe), Unicode                         Included




InterSystems Supported Platforms                                                                                        11
Supported Languages


                                                                                                      Utility
    Language                                         Character Sets                                Translation
    Japanese                  Unicode                                                               Included
    Korean                    Unicode                                                               Included
    Lithuanian                CP1257 (Baltic), Latin-4, Latin-6, Latin-7, Unicode
    Maltese                   Latin-3, Unicode
    Polish                    CP1250 (Central Europe), Latin-2, Unicode
    Portuguese (Brazil)       Latin-1, Latin-9, CP1252 (Western Europe), Unicode                    Included
    Russian                   CP1251 (Cyrillic), Latin-C, Unicode                                   Included
    Slovak                    Unicode
    Slovenian                 Unicode
    Spanish                   Latin-1, Latin-9, CP1252 (Western Europe), Unicode                    Included
    Thai                      CP874 (Thai), Latin-T, Unicode
    Turkish                   Unicode
    Ukranian                  Unicode                                                               Included
†
    US English only.




2.2 NLP
The following languages are supported by Natural Language Processing in this release:
•     Dutch
•     English
•     French
•     German
•     Japanese
•     Portuguese
•     Russian
•     Spanish
•     Swedish
•     Ukrainian




12                                                                                  InterSystems Supported Platforms
3
Supported Version Compatibility
This page describes which components of InterSystems IRIS® data platform can be used across different release versions.

Note:     Throughout this page, “version 2025.1” refers to InterSystems IRIS version 2025.1.
          For information about compatibility between InterSystems IRIS and other InterSystems software, see the Inter-
          Systems IRIS Migration Guide on the WRC distribution site under Docs.




3.1 ODBC and JDBC Compatibility
While InterSystems IRIS ODBC and JDBC clients are forward- and backward-compatible with all versions of InterSystems
IRIS, it is best practice to keep them updated to benefit from the latest bug fixes, client/server capabilities, and optimizations.
Customers are advised to upgrade their client libraries before upgrading their InterSystems IRIS server.
The following table describes the version interoperability between ODBC and JDBC clients, and servers.

                        Client Version                                                   Server Version
 2025.1                                                            2018.1 through 2025.1
 2024.3                                                            2018.1 through 2024.3
 2024.2                                                            2018.1 through 2024.2
 2024.1                                                            2018.1 through 2024.1
 2023.2                                                            2018.1 through 2023.2
 2023.1                                                            2018.1 through 2023.1




3.2 Web Gateway Compatibility
The InterSystems Web Gateway is backward-compatible with earlier versions of InterSystems IRIS. However, using an
earlier version of the Web Gateway with a newer version of InterSystems IRIS is not supported.
Customers are advised to upgrade the Web Gateway before upgrading their InterSystems IRIS server.
The following table describes the version interoperability between the Web Gateway and InterSystems IRIS.




InterSystems Supported Platforms                                                                                                13
Supported Version Compatibility


 Web Gateway Version                                             Compatible InterSystems IRIS Versions
 2025.1                                                          2018.1 through 2025.1
 2024.3                                                          2018.1 through 2024.3
 2024.2                                                          2018.1 through 2024.2
 2024.1                                                          2018.1 through 2024.1
 2023.2                                                          2018.1 through 2023.2
 2023.1                                                          2018.1 through 2023.1




3.3 Backup Restore Compatibility
Backups should always be restored on an InterSystems IRIS instance that is running the same, or a more recent version,
than the instance that created the backup. This is because an older version of InterSystems IRIS may not be able to process
newer features.




3.4 Journal Restore Compatibility (Upgrade Implications)
Journal file restores are guaranteed to be successful when restored on an InterSystems IRIS instance that is running the
same, or a more recent version than the instance that created the journal file. More specifically, a journal file restore is
guaranteed to be successful if the target instance uses the same version or a later version of the journal file format, relative
to the journal file being used. On the other hand, journal file restores are not guaranteed to be successful when restoring to
an older instance.

Important:       InterSystems IRIS 2025.1 introduces a new journal file format that is incompatible with earlier versions.
                 Journal files created by instances running InterSystems IRIS 2025.1 or later cannot be restored on instances
                 running any version prior to InterSystems IRIS 2025.1.

As a consequence, for a mirrored system, when you upgrade to a version from one version to another that uses a different
journal file format, you must take care to do the upgrades in the correct order. Specifically, always upgrade backup members
before upgrading the primary.
InterSystems strongly recommends always upgrading to the most recent maintenance release available for your InterSystems
IRIS version to ensure feature compatibility.




3.5 Mirror Compatibility
All members of a mirror must run on the same version of InterSystems IRIS. There are two exceptions:
1.   Mirror members may run on different versions for the duration of a mirror upgrade. See Upgrading a Mirror in the
     “Upgrading InterSystems IRIS” chapter of the Installation Guide. Once an upgraded mirror member becomes primary,
     you cannot allow the other failover member or any DR async members to become primary or access the application,
     until that member has been upgraded.
2.   Async members may run on a different version than the other members of the mirror, for the following reasons:




14                                                                                         InterSystems Supported Platforms
                                                                                    Mirror Arbiter (ISCAgent) Compatibility


    •    DR async members may continue to run on an older version for an extended period of time, as part of a broader
         upgrade strategy. For example, to fall back to after upgrading the primary and backup members.
    •    Reporting async members may run on a newer version to take advantage of a newer reporting features when
         upgrading the primary and backup members is not warranted.


Mirroring relies on journaling, hence the restrictions and recommendations described in the previous section also apply
here.




3.6 Mirror Arbiter (ISCAgent) Compatibility
The ISCAgent serving as arbiter does not have to run the same version of InterSystems IRIS as the members of the mirror
for which it is configured. We recommend that the arbiter always run a version greater than or equal to the highest version
of the mirror members that connect to it. InterSystems recommends that you upgrade the arbiter when you upgrade the
mirror members, so you can be sure to have the latest version of the ISCAgent.




3.7 ECP Compatibility
ECP is backward and forward compatible between InterSystems IRIS versions. This includes compiled routines and class
definitions, which can be passed over ECP and run on instances that are running a different version of InterSystems IRIS.
However, application code on both ends of an ECP connection must be compatible. For example, if your code performs
different business logic on different ECP servers, then your overall application behavior will be unpredictable.
Customers are advised to ensure that their feature usage is compatible with all of their versions of InterSystems IRIS that
are connected via ECP. For example, InterSystems IRIS 2021.2 introduced transparent stream compression. If a newer
server writes stream data via ECP to an older server, the stream data won’t be readable on servers running versions that
don't support transparent stream compression. Such incompatibilities can exist and are typically addressed in Maintenance
Releases. InterSystems strongly recommends always upgrading your ECP configurations to the most recent maintenance
release available for your InterSystems IRIS version.
Once a database has been updated to the extended database format, it can be mounted only by instances of InterSystems
IRIS 2026.1 or later and cannot be mounted or accessed via ECP by earlier instances (see Extended Database Size).




InterSystems Supported Platforms                                                                                        15
4
Cross-Product Technology Matrix
In general, connectivity components of InterSystems IRIS are not compatible with older InterSystems products. However,
there are certain exceptions. For information about cross-product compatibility, see “ Coexistence & Compatibility ” in the
InterSystems IRIS Migration Guide. You can download this guide from the WRC Document Distribution page (login
required).




InterSystems Supported Platforms                                                                                        17
