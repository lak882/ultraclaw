Using the ^%GSIZE Routine
                             Version 2026.1
                              2026-04-20




  InterSystems Corporation One Congress Street Boston MA 02114 www.intersystems.com
Using the ^%GSIZE Routine
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
       Using the ^%GSIZE Routine................................................................................................................ 1
           1 Basics ............................................................................................................................................ 1
           2 See Also ......................................................................................................................................... 2




Using the ^%GSIZE Routine                                                                                                                                            iii
Using the ^%GSIZE Routine
The ^%GSIZE routine enables you to determine the size of one or more globals.




1 Basics
To use this routine:
1.   Start an ObjectScript shell.
2.   Start the routine:

      do ^%GSIZE

3.   The first prompt lets you specify the database to look at. The prompt refers to the directory that contains the database
     file:

     Directory name: c:\intersystems\iris211\mgr\enslib\ =>

     The default is the globals database used by the namespace that you are currently in. You can either press Enter to accept
     this default, or type a full directory name and then press Enter.
4.   The next prompt is as follows:

     All Globals? No =>

     If you want information on all globals, enter Y (case-insensitive). Otherwise press Enter.

     Note:     If you request information on all globals, that includes all the internal, undocumented globals as well as your
               own globals. Some of these are quite large.

5.   If you did not enter Y in the previous step, the next prompt looks like the following, which is asking for a global name:

     Global ^

     Type the global name, without the leading caret and press Enter.
     Repeat as necessary. When you are done entering global names, press Enter again. Then the routine displays a message
     indicating how many globals you have selected:

     All Globals? No => No
     Global ^IRIS.Msg
     Global ^Ens.Config
     Global ^
     2 globals selected from 64 available globals.

6.   The next prompt asks whether to provide a full report on the globals:

     Show details?? No =>

     If you want full information, enter Y (case-insensitive). Otherwise press Enter
7.   Press Enter for the next two prompts, which let you specify where to write the output:

     Device:



Using the ^%GSIZE Routine                                                                                                   1
See Also


     and

     Right margin: 80 =>

8.   The routine then displays output like the following (using N for the Show details prompt):

                  Global Size Display of c:\intersystems\iris211\mgr\enslib\
                                     2:44 PM Aug 15 2024

       Ens.Config           1     IRIS.Msg        906

            TOTAL:       907

     When using Y for the Show details prompt, the report looks like this instead:

                  Global Size Display of c:\intersystems\iris211\mgr\enslib\
                                     2:44 PM Aug 15 2024

       Ens.Config           1     IRIS.Msg        906

           TOTAL:     907
     directory: c:\intersystems\iris211\mgr\enslib\
     Page: 1                           GLOBAL SIZE                                   15 Aug xxxx
                                                                                         2:42 PM
            Global           Blocks         Bytes Used      Packing    Contig.
            --------       --------    ---------------      -------    -------
            Ens.Config            1                 36          0 %          0
            IRIS.Msg            906          5,550,960         75 %        746


            TOTAL            Blocks         Bytes Used Packing    Contig.
            --------       --------    --------------- -------    -------
                                907          5,550,996     75 %       746
                                                   <RETURN> to continue or '^' to STOP:




2 See Also
•    Globals (APIs) (which lists APIs that get the sizes of globals)




2                                                                                        Using the ^%GSIZE Routine
