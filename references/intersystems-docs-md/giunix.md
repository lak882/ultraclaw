UNIX®, Linux, and macOS
      Installation
                             Version 2026.1
                              2026-04-20




  InterSystems Corporation One Congress Street Boston MA 02114 www.intersystems.com
UNIX®, Linux, and macOS Installation
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
        1 UNIX®, Linux, and macOS Installation Overview ......................................................................... 1
           1.1 How to Use This Guide .............................................................................................................. 1
           1.2 Deploying for Production Systems ............................................................................................ 1
        2 UNIX®, Linux, and macOS Pre-Installation ................................................................................... 3
           2.1 Step 1: Review Supported Platforms .......................................................................................... 3
           2.2 Step 2: Review Platform Specific Notes .................................................................................... 3
           2.3 Step 3: Install a Web Server ....................................................................................................... 3
           2.4 Step 4: Configure Large and Huge Pages (AIX® and Linux) ................................................... 4
           2.5 Step 5: Maximum User Processes Recommendations ............................................................... 4
           2.6 Step 6: Determine Owners and Groups ...................................................................................... 4
           2.7 Step 7: Set Swappiness (Linux) ................................................................................................. 5
           2.8 Step 8: Install the VS Code ObjectScript Development Environment (Linux and macOS) ...... 5
           2.9 Step 9: Acquire a Kit .................................................................................................................. 5
           2.10 Step 10: Uncompress the Installation Kit ................................................................................. 6
           2.11 Step 11: Install the Required Dependencies ............................................................................. 6
           2.12 Step 12: Choose Your Installation Strategy .............................................................................. 7
        3 UNIX®, Linux, and macOS Attended Installation .......................................................................... 9
           3.1 Step 1: Run sudo irisinstall ....................................................................................................... 9
           3.2 Step 2: System Type ................................................................................................................... 9
           3.3 Step 4: Begin Installation ......................................................................................................... 10
           3.4 Step 5: Choose Installation Type .............................................................................................. 10
        4 UNIX®, Linux, and macOS Development Installation ................................................................. 13
           4.1 Development Installation Overview ......................................................................................... 13
           4.2 Step 1: Choose Security Settings ............................................................................................. 14
           4.3 Step 2: Define Instance Owner ................................................................................................. 14
           4.4 Step 3: Determine Group to Start or Stop the Instance ............................................................ 15
           4.5 Step 4: Install Unicode Support ............................................................................................... 15
           4.6 Step 5: Configure Web Server .................................................................................................. 15
           4.7 Step 6: Activate License Key .................................................................................................... 16
           4.8 Step 7: Review Installation ....................................................................................................... 16
        5 UNIX®, Linux, and macOS Server Installation ............................................................................ 17
           5.1 Server Installation Overview .................................................................................................... 17
           5.2 Step 1: Choose Security Settings ............................................................................................. 18
           5.3 Step 2: Define Instance Owner ................................................................................................. 18
           5.4 Step 3: Determine Group to Start or Stop the Instance ............................................................ 19
           5.5 Step 4: Configure Additional Security Options ........................................................................ 19
           5.6 Step 5: Install Unicode Support ............................................................................................... 19
           5.7 Step 6: Configure Web Server .................................................................................................. 19
           5.8 Step 7: Activate License Key .................................................................................................... 20
           5.9 Step 8: Review Installation ....................................................................................................... 20
        6 UNIX®, Linux, and macOS Custom Installation .......................................................................... 23
           6.1 Custom Installation Overview .................................................................................................. 23
           6.2 Step 1: Choose Security Settings ............................................................................................. 24
           6.3 Step 2: Define Instance Owner ................................................................................................. 24
           6.4 Step 3: Determine Group to Start or Stop the Instance ............................................................ 24



UNIX®, Linux, and macOS Installation                                                                                                                        iii
           6.5 Step 4: Configure Additional Security Options ........................................................................ 25
           6.6 Step 5: Install Unicode Support ............................................................................................... 25
           6.7 Step 6: Configure Web Server .................................................................................................. 25
           6.8 Step 7: Activate License Key .................................................................................................... 26
           6.9 Step 8: Install InterSystems Package Manager ........................................................................ 26
           6.10 Step 9: Review Installation ..................................................................................................... 27
     7 UNIX®, Linux, and macOS Client-only Installation .................................................................... 29
        7.1 Client-only Installation Overview ............................................................................................ 29
        7.2 Step 1: Log in ........................................................................................................................... 29
        7.3 Step 2: Run irisinstall_client ................................................................................................... 30
        7.4 Step 3: System Type ................................................................................................................. 30
        7.5 Step 4: Specify Installation Directory ...................................................................................... 30
        7.6 Step 5: Complete Installation ................................................................................................... 30
     8 UNIX®, Linux, and macOS Unattended Installation ................................................................... 31
        8.1 Unattended Installation Overview ............................................................................................ 31
        8.2 Step 1: Before Beginning ......................................................................................................... 32
        8.3 Step 2: Determine Parameters to Specify ................................................................................. 32
        8.4 Step 3: Unattended Installation Packages ................................................................................ 32
        8.5 Step 4: Create Installation Command ....................................................................................... 33
        8.6 Step 6: Execute Command ....................................................................................................... 34
     9 UNIX®, Linux, and macOS Post-Installation ................................................................................ 35
        9.1 Post-Installation Tasks .............................................................................................................. 35




iv                                                                                                            UNIX®, Linux, and macOS Installation
1
UNIX®, Linux, and macOS Installation
Overview
The UNIX®, Linux, and macOS Installation Guide provides guidance on installing kit-based deployments on UNIX®,
Linux, and macOS.




1.1 How to Use This Guide
For all installations, you should begin with the Pre-Installation steps. You can then follow the steps for either an attended
or unattended installation. The attended installation process is different depending on the setup type you choose. After
following the steps for attended installations, use the documentation for the setup type you’ve chosen to continue the
installation process. After completing the installation, refer to the Post-Installation section for additional tasks that should
be completed.
This guide breaks steps into sections titled Default and More. Default includes basic information for a given step, details
on what actions need to be taken, and recommendations on which options to choose. More includes additional details and
other options that can be chosen.
In general, the Default sections are sufficient for quickly getting started. If you are unsure about a particular step or about
which option to select you can follow the guidance in the Default sections.




1.2 Deploying for Production Systems
Deploying for a live production system is a more involved procedure than deploying for development. In particular, you
should carefully consider the resources at your disposal and plan your configuration and deployment accordingly. Before
beginning the installation process, you should review the following sections that give detailed guidance on planning and
managing your resources:
•   System Resource Planning and Management
•   Memory and Startup Settings

You can still follow the procedures outlined in this guide, however the procedures outlined in the Default sections may not
be sufficient for your system. Review each step thoroughly, including the More sections, and select the configuration options
appropriate for your system.



UNIX®, Linux, and macOS Installation                                                                                          1
UNIX®, Linux, and macOS Installation Overview


Additionally, you should consider the following when installing for a production system:
•   Unattended installations or the use of configuration merge are recommended for production systems. These methods
    allow you to easily save your configuration and redeploy with the same settings.
•   Large or huge pages are highly recommended for production systems or any systems that will be performing memory
    intensive processes.
•   Properly configuring the number of maximum user processes is critical for production and other resource intensive
    systems.
•   Setting the swappiness values of your system to a high enough value can help increase performance.
•   You should install with “Locked Down” security settings. This allows for the strongest initial security for your
    deployment. See Initial InterSystems Security Settings for more details.
•   If you are performing an attended installation, the custom installation is recommended. This allows you to only install
    the components necessary for your deployment.




2                                                                                   UNIX®, Linux, and macOS Installation
2
UNIX®, Linux, and macOS Pre-Installation
This page details the pre-installation steps for UNIX®, Linux, and macOS installations.
Before beginning, make sure you review the UNIX®, Linux, and macOS Installation Overview, including:
•   How to Use This Guide
•   Deploying for Production Systems




2.1 Step 1: Review Supported Platforms
Default:
•   Review InterSystems Supported Platforms before installing to make sure the technologies you intend on using are
    supported.
•   Review Supported File Systems for details on optimal file systems and mount options for journaling.




2.2 Step 2: Review Platform Specific Notes
Default:
•   Review specific details for your platform:
    –      AIX®
    –      Red Hat Linux
    –      SUSE Linux
    –      Ubuntu




2.3 Step 3: Install a Web Server
Default:



UNIX®, Linux, and macOS Installation                                                                                  3
UNIX®, Linux, and macOS Pre-Installation


•   Install the Apache httpd web server. This web server supports auto-configuration during the installation process.

More:
•   Install another supported web server (you will have to manually configure this web server).
•   Proceed without a web server (you will have to manually configure a web server in order to access web applications,
    including the Management Portal).
•   If you are performing an unattended installation and are not auto-configuring the Apache web server, make sure that
    you set the parameter ISC_PACKAGE_WEB_CONFIGURE="N".

Important:      InterSystems recommends using the Apache httpd web server because it can be automatically configured
                during the installation process. Make sure it is installed and running before beginning the installation process.
                In most cases, it is not necessary to manually configure the Apache web server.




2.4 Step 4: Configure Large and Huge Pages (AIX® and
Linux)
Default:
•   Huge or large pages are recommended for all systems where performance is a priority. See Configuring Huge Pages
    and Large Pages for details.




2.5 Step 5: Maximum User Processes Recommendations
Default:
•   This step is primarily recommended for production systems or those that are expected to perform memory intensive
    processes.

•   Ensure that the maximum user processes is set high enough to allow all processes for a given user, as well as other
    default processes, to run on the system.




2.6 Step 6: Determine Owners and Groups
Default:
•   Determine or create the user account that you will identify as the owner of the instance.
•   Determine or create the group you will identify as group allowed to start and stop the instance.

More:
•   If your operating systems contains the useradd and groupadd utilities (or mkgroup and mkuser on AIX®), you can
    instead create accounts for the effective user for InterSystems IRIS superserver and the effective group for InterSystems
    IRIS processes during the installation.


4                                                                                      UNIX®, Linux, and macOS Installation
                                                                                            Step 7: Set Swappiness (Linux)


•   If your operating system uses Network Information Services (NIS) or another form of network-based user/group
    database, it may be best to create the effective user and effective group in your network database prior to installing.
    For details, see Owners and Groups.
•   Review Owners and Groups.
•   Review UNIX® User and Group Identifications.

Important:      The installer must set user, group, and other permissions on files that it installs. To accomplish this, the
                installer sets umask to 022 for the installation process - do not modify the umask until the installation is
                complete.




2.7 Step 7: Set Swappiness (Linux)
Default:
•   This step is primarily recommended for production systems or those that are expected to perform memory intensive
    processes.
•   For systems with less than 64GB of RAM: a swappiness of 5 is recommended.
•   For systems with 64GB of RAM or more: a swappiness of 1 is recommended.
•   The swappiness value determines how frequently your system will swap memory pages between the physical RAM
    and swap space.




2.8 Step 8: Install the VS Code ObjectScript Development
Environment (Linux and macOS)
Default:
•   Install InterSystems ObjectScript extensions for Visual Studio Code.
•   This can be done before or after installing.
•   The development environment enables you to connect to an instance and develop code in ObjectScript.




2.9 Step 9: Acquire a Kit
Default:
•   Acquire an installation kit from the WRC kit download site.




UNIX®, Linux, and macOS Installation                                                                                          5
UNIX®, Linux, and macOS Pre-Installation




2.10 Step 10: Uncompress the Installation Kit
Default:
•   If your installation kit is in the form of a .tar file, for example iris-2019.3.0.710.0–lnxrhx64.tar.gz, you should uncompress
    the file into a temporary directory to avoid permissions issues. See the example provided below.

More:
•   The installation files uncompress into a directory with the same name as the .tar file, for example
    /tmp/iriskit/iris-2019.3.0.710.0–lnxrhx64.

•   Because legacy tar commands may fail silently if they encounter long pathnames, InterSystems recommends that you
    use GNU tar to untar this file. To determine if your tar command is a GNU tar, run tar --version.

Example:

# mkdir /tmp/iriskit
# chmod og+rx /tmp/iriskit
# umask 022
# gunzip -c /download/iris-<version_number>-lnxrhx64.tar.gz | ( cd /tmp/iriskit ; tar xf - )

Important:      Do not uncompress the file into or run the installation from the /home directory, or any of its subdirectories.
                Additionally, the pathname of the temporary directory cannot contain spaces.
                Do not install the instance into the same directory you used to uncompress the installation kit.




2.11 Step 11: Install the Required Dependencies
Default:
•   Run the requirements checker using the following command:

    /<install-files-dir>/irisinstall --prechecker

    Note:     You must have the permissions necessary to run the command to execute the requirements checker:
              AIX®: lslpp
              Red Hat Linux and SUSE: rpm
              Ubuntu: dpkg

•   Install any missing dependencies and ensure the user performing the installation can access all necessary dependencies.

More:
•   If you try to install an instance with missing dependencies, the installation will fail with an error in messages.log like
    the following: Error: OS Package Requirements Check Failed.
•   The requirements checker always runs during instance startup. The startup fails if the requirements are not met.




6                                                                                       UNIX®, Linux, and macOS Installation
                                                                            Step 12: Choose Your Installation Strategy




2.12 Step 12: Choose Your Installation Strategy
Default:
•   Use irisinstall to run a Development, Server, or Custom installation.

More:
•   Use irisinstall_client to run a client-only installation.
•   Use configuration merge
•   Use an Installation Manifest.
•   Perform an Unattended Installation.
•   Add Unix® Installation Packages to an InterSystems IRIS Distribution.




UNIX®, Linux, and macOS Installation                                                                                7
3
UNIX®, Linux, and macOS Attended
Installation
This page details the initial steps for attended installations on UNIX®, Linux, and macOS.
Make sure you have completed the following before performing the steps on this page:
•   UNIX®, Linux, and macOS Pre-Installation




3.1 Step 1: Run sudo irisinstall
Default:
•   Start the installation by running the irisinstall script, located at the top level of the installation files:

    # /<install-files-dir>/irisinstall

•   <install-files-dir> is the location of the installation kit, typically the directory to which you extracted the kit.

•   If sudo is unavailable, you can perform a non-standard, limited installation as a nonroot user. See Installing as a Nonroot
    User before continuing.




3.2 Step 2: System Type
Default:
•   The installation script will attempt to automatically detect your system type and validate against the installation type
    on the distribution media.
•   If your system supports more than one type (for example, 32–bit and 64–bit) or if the install script cannot identify your
    system type, you are prompted with additional questions.
•   You may be asked for the “platform name” in the format of the string at the end of the installer kit name.

More:
•   If your system type does not match that on the distribution media, the installation stops.



UNIX®, Linux, and macOS Installation                                                                                         9
UNIX®, Linux, and macOS Attended Installation


•    Contact the InterSystems Worldwide Response Center (WRC) for help in obtaining the correct distribution.




3.3 Step 4: Begin Installation
Default:
•    The script displays a list of any existing instances on the host.
•    At the Enter instance name: prompt, enter an instance name.
•    Use only alphanumeric characters, underscores, and dashes.
•    If an instance with this name already exists, the program asks if you wish to upgrade it.

     Note:     If you select an existing instance that is of the same version as the installation kit, the installation is considered
               an upgrade, and you can use the Custom selection, described in the following step, to modify the installed
               client components and certain settings.
               The registry directory, /usr/local/etc/irissys, is always created along with the installation directory.

•    If no such instance exists, it asks if you wish to create it, then asks you to specify the installation directory.
•    If the directory you specify does not exist, it asks if you want to create it. The default answer to each of these questions
     is Yes.

More:
•    Review Installation Directory for important information about choosing an installation directory.




3.4 Step 5: Choose Installation Type
Default:
•    Select the Development type from the choices:
     Select installation type.
         1) Development - Install IRIS server and all language bindings
         2) Server only - Install IRIS server
         3) Custom - Choose components to install
     Setup type <1>?

•    Continue reading the documentation for a Development setup type.

More:
•    Choose any setup type. Review Choosing a Setup Type for details on the different setup types.
•    Continue reading the documentation for the setup type you choose:
     –     Development
     –     Server
     –     Custom




10                                                                                        UNIX®, Linux, and macOS Installation
                                                                                        Step 5: Choose Installation Type


•   If the CSP Gateway is already installed on your system when you install the Web Gateway, the installer automatically
    upgrades the CSP Gateway to the Web Gateway. For details, see Preexisting CSP Gateway.




UNIX®, Linux, and macOS Installation                                                                                 11
4
UNIX®, Linux, and macOS Development
Installation
This page details the steps for attended development installations on UNIX®, Linux, and macOS.
Make sure you have completed the following before performing the steps on this page:
•   UNIX®, Linux, and macOS Pre-Installation
•   UNIX®, Linux, and macOS Attended Installation (initial steps)




4.1 Development Installation Overview
Default:
•   A development installation installs only the components that are required on a development system.
•   The installation script, irisinstall, does the following:
    –      Installs the system manager databases.
    –      Starts the instance in installation mode.
    –      Installs the system manager globals and routines.
    –      Shuts down the instance and restarts using the default configuration file (iris.cpf). Upgrade installations restart
           using their updated configuration files.


More:
•   Standard installation consists of a set of modular package scripts. The scripts conditionally prompt for information
    based on input to previous steps, your system environment, and whether or not you are upgrading an existing instance.
•   The first stage of the installation stores all gathered information about the install in a parameter file.
•   You then confirm the specifics of the installation before the actual install takes place.
•   The final phase performs the operations that are contingent upon a successful install, such as instance startup.
•   Development installations include the following component groups:
    –      InterSystems IRIS Database Engine (including Language Gateways, and Server Monitoring Tools)



UNIX®, Linux, and macOS Installation                                                                                             13
UNIX®, Linux, and macOS Development Installation


     –     InterSystems IRIS launcher
     –     Database drivers
     –     InterSystems IRIS Application Development (including language bindings)
     –     Web Gateway


•    For details on these component groups, see Choosing a Setup Type.

Important:        If the profile of the user executing irisinstall has a value set for the CDPATH variable, the installation
                  fails.




4.2 Step 1: Choose Security Settings
Default:
•    Input (1) to choose Locked Down security settings in response to the following prompt:

     How restrictive do you want the initial Security settings to be?
     "Locked Down" is the most secure, "Minimal" is the least restrictive.
       1) Locked Down
       2) Normal
       3) Minimal
     Initial Security settings <1>?


More:
•    If you choose Minimal, you can skip the next step; the installer sets the owner of the instance as root.
•    There are additional security settings that you can choose only through a custom install. See Custom Installation for
     details.
•    See Initial InterSystems Security Settings for details on the different security settings and choosing one for your system.




4.3 Step 2: Define Instance Owner
Default:
•    If you selected Normal or Locked Down in the previous step, you are prompted for additional information:
     –     Instance owner — Enter the username of the account under which to run processes. See Determining Owners and
           Groups for information about this account. Once your instance is installed, you cannot change the owner of the
           instance.
     –     Password for the instance owner — Enter the password for username you entered at the previous prompt, and
           enter it again to confirm it. A privileged user account is created for this user with the %All role.
           This password is used not only for the privileged user account, but also for the _SYSTEM, Admin, and SuperUser
           predefined user accounts. For more details on these predefined users, see Predefined User Accounts.
     –     Password for the CSPSystem predefined user.


More:



14                                                                                     UNIX®, Linux, and macOS Installation
                                                                       Step 3: Determine Group to Start or Stop the Instance


•   The passwords must meet the criteria described in the Initial User Security Settings table. Passwords entered during
    this procedure cannot include space, tab, or backslash characters; the installer reject such passwords.




4.4 Step 3: Determine Group to Start or Stop the Instance
Default:
•   You are prompted which group should be allowed to start and stop the instance.
•   Only one group can have these privileges, and it must be a valid group on the machine.
•   Enter the name or group ID number of an existing group; the installer verifies that the group exists before proceeding.
•   See Determining Owners and Groups for more information.




4.5 Step 4: Install Unicode Support
Default:
•   Indicate whether to install with 8-bit or Unicode character support.
•   On upgrade, you can convert from 8-bit to Unicode, but not the reverse.

This step is skipped by the HealthShare installer and Unicode support is chosen automatically. Continue to the next step.




4.6 Step 5: Configure Web Server
Default:
•   If a local web server is detected, you will be asked if you would like to use the web server to connect to your installation.
•   Enter y. This will allow the web server to be connected automatically.
    If you enter n, the web server will not be connected automatically and you will have to configure it manually after the
    installation finishes.

More:
•   If a web server is not detected, you will be asked if you would like to abort. If you choose to continue the installation,
    you will have to configure your web server manually after the installation finishes.

Important:      InterSystems recommends using the Apache httpd web server because it can be automatically configured
                during the installation process. Make sure it is installed and running before beginning the installation process.
                In most cases, it is not necessary to manually configure the Apache web server.




UNIX®, Linux, and macOS Installation                                                                                          15
UNIX®, Linux, and macOS Development Installation




4.7 Step 6: Activate License Key
Default:
•    If the script does not detect an iris.key file in the mgr directory of an existing instance when upgrading, you are prompted
     for a license key file.
•    If you specify a valid key, the license is automatically activated and the license key copied to the instance’s mgr
     directory during installation and no further activation procedure is required.
•    If you do not specify a license key, you can activate a license key following installation. See Activating a License Key
     for information about licenses, license keys and activation.
•    On macOS, you may receive a prompt regarding network connections for irisdb. If so, select Allow.




4.8 Step 7: Review Installation
Default:
•    Review your installation options and press enter to proceed with the installation. File copying does not begin until you
     answer Yes.
•    When the installation completes, you are directed to the appropriate URL for the Management Portal to manage your
     system. See Using the Management Portal for more information.
•    Continue to Post-Installation Tasks.




16                                                                                      UNIX®, Linux, and macOS Installation
5
UNIX®, Linux, and macOS Server
Installation
This page details the steps for attended server installations on UNIX®, Linux, and macOS.
Make sure you have completed the following before performing the steps on this page:
•   UNIX®, Linux, and macOS Pre-Installation
•   UNIX®, Linux, and macOS Attended Installation (initial steps)




5.1 Server Installation Overview
Default:
•   A server installation installs only the components that are required on a server system.
•   The installation script, irisinstall, does the following:
    –      Installs the system manager databases.
    –      Starts the instance in installation mode.
    –      Installs the system manager globals and routines.
    –      Shuts down the instance and restarts using the default configuration file (iris.cpf). Upgrade installations restart
           using their updated configuration files.


More:
•   Standard installation consists of a set of modular package scripts. The scripts conditionally prompt for information
    based on input to previous steps, your system environment, and whether or not you are upgrading an existing instance.
•   The first stage of the installation stores all gathered information about the install in a parameter file.
•   You then confirm the specifics of the installation before the actual install takes place.
•   The final phase performs the operations that are contingent upon a successful install, such as instance startup.
•   Server installations include the following component groups:
    –      InterSystems IRIS Database Engine (including Language Gateways, and Server Monitoring Tools)



UNIX®, Linux, and macOS Installation                                                                                             17
UNIX®, Linux, and macOS Server Installation


     –     InterSystems IRIS launcher
     –     Web Gateway


•    For details on these component groups, see Choosing a Setup Type.




5.2 Step 1: Choose Security Settings
Default:
•    Input (1) to choose Locked Down security settings in response to the following prompt:

     How restrictive do you want the initial Security settings to be?
     "Locked Down" is the most secure, "Minimal" is the least restrictive.
       1) Locked Down
       2) Normal
       3) Minimal
     Initial Security settings <1>?


More:
•    If you choose Minimal, you can skip the next step; the installer sets the owner of the instance as root.
•    There are additional security settings that you can choose only through a custom install. See Custom Installation for
     details.
•    See Initial InterSystems Security Settings for details on the different security settings and choosing one for your system.




5.3 Step 2: Define Instance Owner
Default:
•    If you selected Normal or Locked Down in the previous step, you are prompted for additional information:
     –     Instance owner — Enter the username of the account under which to run processes. See Determining Owners and
           Groups for information about this account. Once the instance is installed, you cannot change the owner of the
           instance.
     –     Password for the instance owner — Enter the password for the username you entered at the previous prompt, and
           enter it again to confirm it. A privileged user account is created for this user with the %All role.
           This password is used not only for the privileged user account, but also for the _SYSTEM, Admin, and SuperUser
           predefined user accounts. For more details on these predefined users, see Predefined User Accounts.
     –     Password for the CSPSystem predefined user.


More:
•    The passwords must meet the criteria described in the Initial User Security Settings table. Passwords entered during
     this procedure cannot include space, tab, or backslash characters; the installer reject such passwords.




18                                                                                     UNIX®, Linux, and macOS Installation
                                                                       Step 3: Determine Group to Start or Stop the Instance




5.4 Step 3: Determine Group to Start or Stop the Instance
Default:
•   You are prompted which group should be allowed to start and stop the instance.
•   Only one group can have these privileges, and it must be a valid group on the machine.
•   Enter the name or group ID number of an existing group; The installer verifies that the group exists before proceeding.
•   See Determining Owners and Groups for more information.




5.5 Step 4: Configure Additional Security Options
Default:
•   If you chose Normal or Locked Down for your initial security settings, you are asked if you want to configure
    additional security options.
•   Input N to continue with the installation using the defaults for the initial security settings you chose.

More:
•   If you choose Y, you are prompted to configure additional settings:
    –      Effective group for InterSystems IRIS — InterSystems IRIS internal effective group ID, which also has all privileges
           to all files and executables in the installation. For maximum security, no actual users should belong to this group.
           (Defaults to irisusr.)
    –      Effective user for the InterSystems IRIS superserver — Effective user ID for processes started by the superserver
           and Job servers. Again, for maximum security, no actual users should have this user ID. (Defaults to irisusr.)

•   See Determining Owners and Groups for additional information.




5.6 Step 5: Install Unicode Support
Default:
•   Indicate whether to install with 8-bit or Unicode character support.
•   On upgrade, you can convert from 8-bit to Unicode, but not the reverse.

This step is skipped by the HealthShare installer and Unicode support is chosen automatically. Continue to the next step.




5.7 Step 6: Configure Web Server
Default:
•   If a local web server is detected, you will be asked if you would like to use the web server to connect to your installation.



UNIX®, Linux, and macOS Installation                                                                                          19
UNIX®, Linux, and macOS Server Installation


•    Input y. The web server will be connected automatically.
•    Input 1 to specify the Apache WebServer type.
•    Enter the location of the Apache configuration file. The default path is /etc/httpd/conf/httpd.conf.
•    Specify an Apache httpd port number. The default is 80 (8080 on macOS). Upgrade installs do not offer this choice;
     they keep the port numbers of the original instance.

     Important:       Specifying a custom web server port number during installation only modifies the WebServerPort
                      CPF parameter. This should be the port number that your web server is configured to listen over. The
                      default web server port number is 80 (8080 on macOS). Unless, you’ve configured your web server
                      to listen over a different port number, you shouldn’t change this setting from the default.

•    Specify a SuperServer port number. This is 1972 by default (or, if 1972 is taken, this is 51733 or the first available
     subsequent number). The port number cannot be greater than 65535.

More:
•    If a web server is not detected, you will be asked if you would like to abort. If you choose to continue the installation,
     you will have to configure your web server manually after the installation finishes.
•    If you choose not to connect a detected web server or set WebServer type to None, you will have to configure your
     web server manually after the installation finishes.

Important:        InterSystems recommends using the Apache httpd web server because it can be automatically configured
                  during the installation process. Make sure it is installed and running before beginning the installation process.
                  In most cases, it is not necessary to manually configure the Apache web server.




5.8 Step 7: Activate License Key
Default:
•    If the script does not detect an iris.key file in the mgr directory of an existing instance when upgrading, you are prompted
     for a license key file.
•    If you specify a valid key, the license is automatically activated and the license key copied to the instance’s mgr
     directory during installation and no further activation procedure is required.
•    If you do not specify a license key, you can activate a license key following installation. See Activating a License Key
     for information about licenses, license keys and activation.
•    On macOS, you may receive a prompt regarding network connections for irisdb. If so, select Allow.




5.9 Step 8: Review Installation
Default:
•    Review your installation options and press enter to proceed with the installation. File copying does not begin until you
     answer Yes.
•    When the installation completes, you are directed to the appropriate URL for the Management Portal to manage your
     system. See Using the Management Portal for more information.


20                                                                                       UNIX®, Linux, and macOS Installation
                                           Step 8: Review Installation


•   Continue to Post-Installation Tasks.




UNIX®, Linux, and macOS Installation                               21
6
UNIX®, Linux, and macOS Custom
Installation
This page details the steps for attended custom installations on UNIX®, Linux, and macOS.
Make sure you have completed the following before performing the steps on this page:
•   UNIX®, Linux, and macOS Pre-Installation
•   UNIX®, Linux, and macOS Attended Installation (initial steps)




6.1 Custom Installation Overview
Default:
•   A custom installation allows you to select specific components to install on the system. Some selections require that
    you install other components.

•   If you choose a custom installation, you must answer additional questions throughout the installation procedure about
    installing several individual components. The defaults appear in brackets before the question mark (?); press Enter to
    accept the default.
•   The installation script, irisinstall, does the following:
    –      Installs the system manager databases.
    –      Starts the instance in installation mode.
    –      Installs the system manager globals and routines.
    –      Shuts down the instance and restarts using the default configuration file (iris.cpf). Upgrade installations restart
           using their updated configuration files.


More:
•   Standard installation consists of a set of modular package scripts. The scripts conditionally prompt for information
    based on input to previous steps, your system environment, and whether or not you are upgrading an existing instance.
•   The first stage of the installation stores all gathered information about the install in a parameter file.
•   You then confirm the specifics of the installation before the actual install takes place.



UNIX®, Linux, and macOS Installation                                                                                             23
UNIX®, Linux, and macOS Custom Installation


•    The final phase performs the operations that are contingent upon a successful install, such as instance startup.




6.2 Step 1: Choose Security Settings
Default:
•    Input (1) to choose Locked Down security settings in response to the following prompt:

     How restrictive do you want the initial Security settings to be?
     "Locked Down" is the most secure, "Minimal" is the least restrictive.
       1) Locked Down
       2) Normal
       3) Minimal
     Initial Security settings <1>?


More:
•    If you choose Minimal, you can skip the next step; the installer sets the owner of the instance as root.
•    There are additional security settings that you can choose only through a custom install. See Configure Additional
     Security Options for details.
•    See Initial InterSystems Security Settings for details on the different security settings and choosing one for your system.




6.3 Step 2: Define Instance Owner
Default:
•    If you selected Normal or Locked Down in the previous step, you are prompted for additional information:
     –     Instance owner — Enter the username of the account under which to run processes. See Determining Owners and
           Groups for information about this account. Once the instance is installed, you cannot change the owner of the
           instance.
     –     Password for the instance owner — Enter the password for the username you entered at the previous prompt, and
           enter it again to confirm it. A privileged user account is created for this user with the %All role.
           This password is used not only for the privileged user account, but also for the _SYSTEM, Admin, and SuperUser
           predefined user accounts. For more details on these predefined users, see Predefined User Accounts.
     –     Password for the CSPSystem predefined user.


More:
•    The passwords must meet the criteria described in the Initial User Security Settings table. Passwords entered during
     this procedure cannot include space, tab, or backslash characters; the installer reject such passwords.




6.4 Step 3: Determine Group to Start or Stop the Instance
Default:



24                                                                                     UNIX®, Linux, and macOS Installation
                                                                                Step 4: Configure Additional Security Options


•   You are prompted which group should be allowed to start and stop the instance.
•   Only one group can have these privileges, and it must be a valid group on the machine.
•   Enter the name or group ID number of an existing group; the installer verifies that the group exists before proceeding.
•   See Determining Owners and Groups for more information.




6.5 Step 4: Configure Additional Security Options
Default:
•   If you chose Normal or Locked Down for your initial security settings, you are asked if you want to configure
    additional security options.
•   Input N to continue with the installation using the defaults for the initial security settings you chose.

More:
•   If you choose Y, you are prompted to configure additional settings:
    –      Effective group for InterSystems IRIS — InterSystems IRIS internal effective group ID, which also has all privileges
           to all files and executables in the installation. For maximum security, no actual users should belong to this group.
           (Defaults to irisusr.)
    –      Effective user for the InterSystems IRIS superserver — Effective user ID for processes started by the superserver
           and Job servers. Again, for maximum security, no actual users should have this user ID. (Defaults to irisusr.)

•   See Determining Owners and Groups for additional information.




6.6 Step 5: Install Unicode Support
Default:
•   Indicate whether to install with 8-bit or Unicode character support.
•   On upgrade, you can convert from 8-bit to Unicode, but not the reverse.

This step is skipped by the HealthShare installer and Unicode support is chosen automatically. Continue to the next step.




6.7 Step 6: Configure Web Server
Default:
•   If a local web server is detected, you will be asked if you would like to use the web server to connect to your installation.
•   Input y. The web server will be connected automatically.
•   Input 1 to specify the Apache WebServer type.
•   Enter the location of the Apache configuration file. The default path is /etc/httpd/conf/httpd.conf.




UNIX®, Linux, and macOS Installation                                                                                          25
UNIX®, Linux, and macOS Custom Installation


•    Specify an Apache httpd port number. The default is 80 (8080 on macOS). Upgrade installs do not offer this choice;
     they keep the port numbers of the original instance.

     Important:       Specifying a custom web server port number during installation only modifies the WebServerPort
                      CPF parameter. This should be the port number that your web server is configured to listen over. The
                      default web server port number is 80 (8080 on macOS). Unless, you’ve configured your web server
                      to listen over a different port number, you shouldn’t change this setting from the default.

•    Specify a SuperServer port number. This is 1972 by default (or, if 1972 is taken, this is 51733 or the first available
     subsequent number). The port number cannot be greater than 65535.

More:
•    If a web server is not detected, you will be asked if you would like to abort. If you choose to continue the installation,
     you will have to configure your web server manually after the installation finishes.
•    If you choose not to connect a detected web server or set WebServer type to None, you will have to configure your
     web server manually after the installation finishes.

Important:        InterSystems recommends using the Apache httpd web server because it can be automatically configured
                  during the installation process. Make sure it is installed and running before beginning the installation process.
                  In most cases, it is not necessary to manually configure the Apache web server.




6.8 Step 7: Activate License Key
Default:
•    If the script does not detect an iris.key file in the mgr directory of an existing instance when upgrading, you are prompted
     for a license key file.
•    If you specify a valid key, the license is automatically activated and the license key copied to the instance’s mgr
     directory during installation and no further activation procedure is required.
•    If you do not specify a license key, you can activate a license key following installation. See Activating a License Key
     for information about licenses, license keys and activation.
•    On macOS, you may receive a prompt regarding network connections for irisdb. If so, select Allow.




6.9 Step 8: Install InterSystems Package Manager
Default:
•    Indicate whether to install InterSystems Package Manager as part of your installation.
•    Selecting Y installs the zpm.xml file with your instance which allows for easy installation of IPM.




26                                                                                       UNIX®, Linux, and macOS Installation
                                                                                                 Step 9: Review Installation




6.10 Step 9: Review Installation
Default:
•   Review your installation options and press enter to proceed with the installation. File copying does not begin until you
    answer Yes.
•   When the installation completes, you are directed to the appropriate URL for the Management Portal to manage your
    system. See Using the Management Portal for more information.
•   Continue to Post-Installation Tasks.




UNIX®, Linux, and macOS Installation                                                                                     27
7
UNIX®, Linux, and macOS Client-only
Installation
This page details the steps for attended client-only installations on UNIX®, Linux, and macOS.
Make sure you have completed the following before performing the steps on this page:
•   UNIX®, Linux, and macOS Pre-Installation
•   UNIX®, Linux, and macOS Attended Installation (initial steps)




7.1 Client-only Installation Overview
Default:
•   A client installation installs only the components that are required on a client system.

More:
•   Client installations include the following component groups:
    –      InterSystems IRIS launcher
    –      Database drivers
    –      InterSystems IRIS Application Development (including language bindings)


•   For details on these component groups, see Choosing a Setup Type.




7.2 Step 1: Log in
Default:
•   Log in as any user. You do not need to install as root.
•   The files from this install have the user and group permissions of the installing user.




UNIX®, Linux, and macOS Installation                                                             29
UNIX®, Linux, and macOS Client-only Installation




7.3 Step 2: Run irisinstall_client
Default:
•    Start the installation by running the irisinstall_client script, located at the top level of the installation files:

     # /<install-files-dir>/irisinstall_client

•    <install-files-dir> is the location of the installation kit, typically the directory to which you extracted the kit.




7.4 Step 3: System Type
Default:
•    The installation script will attempt to automatically detect your system type and validate against the installation type
     on the distribution media.
•    If your system supports more than one type (for example, 32–bit and 64–bit) or if the install script cannot identify your
     system type, you are prompted with additional questions.
•    You may be asked for the “platform name” in the format of the string at the end of the installer kit name.

More:
•    If your system type does not match that on the distribution media, the installation stops.
•    Contact the InterSystems Worldwide Response Center (WRC) for help in obtaining the correct distribution.




7.5 Step 4: Specify Installation Directory
Default:
•    At the Enter a destination directory for client components prompt, specify the installation directory.
•    If the directory you specify does not exist, it asks if you want to create it. The default answer is Yes.

More:
•    Review Installation Directory for more important information about choosing an installation directory.
•    The registry directory, /usr/local/etc/irissys, is always created along with the installation directory.




7.6 Step 5: Complete Installation
Default:
•    After specifying the directory, the installation proceeds automatically. You should see Installation completed successfully.
•    Continue to Post-Installation Tasks.



30                                                                                        UNIX®, Linux, and macOS Installation
8
UNIX®, Linux, and macOS Unattended
Installation
This page details the steps for unattended installations on UNIX®, Linux, and macOS.
Make sure you have completed the following before performing the steps on this page:
•   UNIX®, Linux, and macOS Pre-Installation




8.1 Unattended Installation Overview
Default:
•   You can perform unattended installation on your systems using the irisinstall_silent script.
•   An unattended installation gets configuration specifications from the configuration parameters and the packages
    specified on the irisinstall_silent command line.
•   Each specified package represents a component; the installation scripts for each component are contained in the
    packages directory below the directory containing the irisinstall_silent script.

•   The general format for the irisinstall_silent command line is to precede the command itself by setting environment
    variables to define the installation parameters. See the example for details.

Example:

sudo ISC_PACKAGE_INSTANCENAME="<instancename>"
 ISC_PACKAGE_INSTALLDIR="<installdir>"
 ISC_PACKAGE_UNICODE="Y"|"N"
 ISC_PACKAGE_INITIAL_SECURITY="Normal"|"Locked Down"
 ISC_PACKAGE_MGRUSER="<instanceowner>"
 ISC_PACKAGE_MGRGROUP="<group>"
 ISC_PACKAGE_USER_PASSWORD="<pwd>"
 ISC_PACKAGE_CSPSYSTEM_PASSWORD="<pwd>"
 ISC_PACKAGE_IRISUSER="<user>"
 ISC_PACKAGE_IRISGROUP="<group>"
 ISC_PACKAGE_CLIENT_COMPONENTS="<component1> <component2> ..."
 ISC_PACKAGE_STARTIRIS="Y"|"N"
 ./irisinstall_silent [<pkg> ...]




UNIX®, Linux, and macOS Installation                                                                                     31
UNIX®, Linux, and macOS Unattended Installation




8.2 Step 1: Before Beginning
Default:
•    Before beginning your installation, perform the necessary pre-installation steps.
•    Determine your strategy for installing an external web server:
     –     The easiest option is to install the Apache httpd web server before beginning the installation. The installer can
           auto-configure this web server.
     –     If you intend on using a different web server or manually configuring the IIS web server, review Installing a Web
           Server for necessary steps that must be performed prior to the installation.




8.3 Step 2: Determine Parameters to Specify
Default:
•    Include the required unattended installation parameters:
     –     ISC_PACKAGE_INSTANCENAME=“ <instancename>”

     –     ISC_PACKAGE_INSTALLDIR=“ <install-dir> ” (New instances only)

     –     ISC_PACKAGE_USER_PASSWORD=“ <password>” (Required for installations with Normal or Locked Down
           security levels)

•    For details on these required parameters see Unattended Installation Parameters.
•    The installation uses the default for any parameter that is not included. The installation fails if a required parameter is
     not included.

More:
•    Include any other parameters. See Unattended Installation Parameters for details.




8.4 Step 3: Unattended Installation Packages
Default:
•    Do not include a package name or include the standard_install package.

More:
•    The installation scripts for each component are contained in the packages directory below the directory containing the
     irisinstall_silent script.

•    Each package is in its own directory, and each package directory contains a manifest.isc file defining prerequisite
     packages for the package in that directory.
•    The standard_install package is the starting point for a server install in which all packages are installed.




32                                                                                     UNIX®, Linux, and macOS Installation
                                                                                           Step 4: Create Installation Command


•   You can include one or more of these packages in your installation.
•   You can also define a custom package for your installation. See Unattended Installation Packages for details.
•   For details on more complex custom installation packages, see Adding UNIX® Installation Packages to a Distribution.




8.5 Step 4: Create Installation Command
Default:
•   Create an installation command using the following format:

    sudo ISC_PACKAGE_INSTANCENAME="<instance-name>" ISC_PACKAGE_INSTALLDIR=<install-dir> [PARAMETERS]
     ./irisinstall_silent [PACKAGES]

•   Include any additional parameters separated by spaces.
•   Include any specific packages separated by spaces.
•   If sudo is unavailable, you can perform a non-standard, limited installation as a nonroot user. See Installing as a Nonroot
    User before continuing.

Examples:
•   In this example, all packages are installed with minimal security:

    sudo ISC_PACKAGE_INSTANCENAME="MyIris" ISC_PACKAGE_INSTALLDIR="/opt/MyIris1" ./irisinstall_silent

    If the MyIris instance already exists, it is upgraded; otherwise, it is installed in the /opt/MyIris1 directory.
•   In this example, the installation is aborted and an error is thrown if the instance named MyIris does not already exist:

    sudo ISC_PACKAGE_INSTANCENAME="MyIris" ./irisinstall_silent

•   In this example, only the database_server and odbc packages and the odbc client binding are installed with
    minimal security:

    sudo ISC_PACKAGE_INSTANCENAME="MyIris" ISC_PACKAGE_INSTALLDIR="/opt/MyIris2"
    ISC_PACKAGE_CLIENT_COMPONENTS="odbc" ./irisinstall_silent database_server odbc

•   Installs in “normal” security mode with Superserver port 59992.

    sudo ISC_PACKAGE_INSTANCENAME="<instancename>"
     ISC_PACKAGE_INSTALLDIR="<installdir>"
     ISC_PACKAGE_USER_PASSWORD="<password>"
     ISC_PACKAGE_SUPERSERVER_PORT="59992"
     ISC_PACKAGE_INITIAL_SECURITY="Normal"
     ./irisinstall_silent [<pkg> ...]

•   Installs all modules; specifies the user and group who own the instance; configures the Web Gateway to work with an
    existing instance of Apache on the same host (installs Web Gateway libraries in /opt/gateway and adds Web




UNIX®, Linux, and macOS Installation                                                                                        33
UNIX®, Linux, and macOS Unattended Installation


     Gateway configuration information to httpd.conf). Note that this configuration is appropriate only for a development
     instance, not for a production installation.

     sudo ISC_PACKAGE_INSTANCENAME="<instancename>"
      ISC_PACKAGE_INSTALLDIR="<installdir>"
      ISC_PACKAGE_USER_PASSWORD="<password>"
      ISC_PACKAGE_INITIAL_SECURITY="Normal"
      ISC_PACKAGE_MGRUSER="admin1"
      ISC_PACKAGE_MGRGROUP="admin"
      ISC_PACKAGE_WEB_CONFIGURE="Y"
      ISC_PACKAGE_WEB_SERVERTYPE="Apache"
      ./irisinstall_silent [<pkg> ...]




8.6 Step 6: Execute Command
Default:
•    Execute the command you created in the above steps.
•    Proceed to Post-Installation.




34                                                                                 UNIX®, Linux, and macOS Installation
9
UNIX®, Linux, and macOS
Post-Installation
This page details the post-installation steps for installations on UNIX®, Linux, and macOS.
•   UNIX®, Linux, and macOS Pre-Installation.
•   Successfully performed an attended or unattended installation.




9.1 Post-Installation Tasks
Get Started
        •    Start the instance.
        •    Install a development environment.


Healthcare Setup
        •    Change the HS_Services password.
        •    Create a Foundation namespace.
        •    After creating a Foundation namespace, import the SDA3 schema if you are using SDA3 or SDA3 transfor-
             mations.


Web Server Setup
        •    If you did not configure your web server automatically during the installation process, you will need to connect
             it manually.
        •    If your web server is using a port number other than 80, you will need to change the CPF WebServerPort and
             WebServerURLPrefix parameters to your web server’s port number in order to connect with your IDE.
        •    In order for your web server to implement any configuration changes, you should restart your web server after
             the installation finishes.


Advanced Setup
        •    If you will be performing memory intensive activities, allocate system memory accordingly.


UNIX®, Linux, and macOS Installation                                                                                      35
UNIX®, Linux, and macOS Post-Installation


        •   Review details on how your instance interacts with third-party software.
        •   Migrate data from a different database to your newly installed instance.


Special Considerations
        •   If you are running multiple instances, review Configuring Multiple Instances.
        •   Change the language.
        •   If your system requires a large number of processes or telnet logins, review Adjustments for Large Number
            of Concurrent Processes on macOS.




36                                                                                UNIX®, Linux, and macOS Installation
