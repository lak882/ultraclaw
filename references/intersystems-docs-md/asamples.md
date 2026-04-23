Downloading Samples
                           Version 2026.1
                            2026-04-20




InterSystems Corporation One Congress Street Boston MA 02114 www.intersystems.com
Downloading Samples
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
       Downloading Samples............................................................................................................................ 1
          1 Introduction to Samples ................................................................................................................ 1
          2 Downloading a Sample ................................................................................................................. 1
               2.1 Using a Web Browser to Download a Repo ........................................................................ 1
               2.2 Using Linux or UNIX® Command Line to Download a Repo .......................................... 2
          3 Creating a Namespace and Database to Hold Samples ................................................................. 2
          4 Completing README.md Steps .................................................................................................. 2




Downloading Samples                                                                                                                                        iii
Downloading Samples
This page describes how to download samples for use with InterSystems IRIS® data platform, as well as how to create a
namespace and database to hold the samples.




1 Introduction to Samples
The installation kit for InterSystems IRIS does not include samples; this enables the kit to be as small as possible. Instead,
samples are available online at GitHub. In GitHub terms, each sample is provided as a repository or repo.
Each of the sample repos includes:
•    A detailed README file with specific setup instructions
•    A specialized routine that sets up the sample after you have downloaded it to a local disk.

Note that the InterSystems account (https://github.com/intersystems) includes many other repos. The repos that are meant
for use with the InterSystems IRIS documentation are tagged with intersystems-samples and have names starting
with Samples.
If you are familiar with GitHub, skip ahead to Creating a Namespace and Database to Hold Samples.
If you are not familiar with GitHub, see the next section for how to download samples. You do not need a GitHub account.




2 Downloading a Sample
You can download a GitHub repo as a single packaged unit, which you can then uncompress as a directory with multiple
files. Choose which method you prefer:
•    Using a Web Browser to Download a Repo
•    Using Linux or UNIX® Command Line to Download a Repo

If Git is installed on your machine, you can access the repo by cloning it, as described in Cloning a repository on the GitHub
website (https://docs.github.com/en/github/creating-cloning-and-archiving-repositories/cloning-a-repository)


2.1 Using a Web Browser to Download a Repo
To download a repo using a web browser:
1.   Click the link for that repo. The upper part of the page summarizes the contents, and the lower part displays the
     README file for the repo.
2.   Click the Clone or download button, visible from the default Code tab. Then click Download ZIP.
3.   The browser downloads a .zip file that contains the full repo. Depending on your browser settings, you may get prompted
     for a location. If not, check the usual download location for your browser.
4.   Uncompress the .zip file. The uncompressed directory contains a README.md file, a LICENSE file, a buildsample
     subdirectory, and other files and subdirectories.



Downloading Samples                                                                                                         1
Creating a Namespace and Database to Hold Samples



2.2 Using Linux or UNIX® Command Line to Download a Repo
To download a repo using Linux or UNIX® command line:
1.   From the shell, type:
     wget -qO- https://github.com/intersystems/repo-name/archive/master.tar.gz | tar xvz -C /samples

     where repo-name is the name of the repo you want, and /samples is an existing directory.
2.   Press Enter to download the repo into the /samples directory.
     The uncompressed directory contains a README.md file, a LICENSE file, a buildsample subdirectory, and other files
     and subdirectories.




3 Creating a Namespace and Database to Hold Samples
Many of the samples include InterSystems IRIS classes or routines and are meant to be loaded into an InterSystems IRIS
instance. InterSystems recommends that you create a dedicated namespace and database called SAMPLES for this purpose
and then load the samples into this namespace.
To create the SAMPLES namespace and database:
1.   In the Management Portal, click System Administration > Configuration > System Configuration > Namespaces.
2.   Click Create New Namespace.
3.   In the Name of the Namespace, enter SAMPLES.
4.   Next to Select an existing database for Globals, click Create New Database.
     In the next step, you are starting to create the namespace.
5.   For Enter the name of your database, enter SAMPLES. The name is not case-sensitive.
6.   For Database directory, enter SAMPLES.
7.   Click Next.
8.   Accept all other values as default.
9.   Click Finish.
     This step finishes creating the database.
10. For Select an existing database for Routines, select the database that you just created.
     Note that for a production system, you would use a different database to store routines and classes.
11. Accept all other values as default.
12. Click Save.




4 Completing README.md Steps
Now that you have downloaded the repo and created a namespace, complete the other setup steps in the README.md file
that is included with the GitHub repo.


2                                                                                                   Downloading Samples
