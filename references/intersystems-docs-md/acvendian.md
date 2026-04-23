Using cvendian for Byte Order
         Conversion
                              Version 2026.1
                               2026-04-20




   InterSystems Corporation One Congress Street Boston MA 02114 www.intersystems.com
Using cvendian for Byte Order Conversion
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
        Using cvendian for Byte Order Conversion......................................................................................... 1
            1 Introduction to cvendian ................................................................................................................ 1
            2 Conversion Process ....................................................................................................................... 1
            3 Utility Syntax ................................................................................................................................ 1
            4 See Also ......................................................................................................................................... 2




Using cvendian for Byte Order Conversion                                                                                                                             iii
Using cvendian for Byte Order Conversion
This page describes how to use cvendian to convert or report on the byte order of an InterSystems database. You can use
this utility for migration between Big-endian and Little-endian platforms.




1 Introduction to cvendian
The cvendian utility converts (or reports on) the byte order of an InterSystems database. This utility is the file
install-dir\Bin\cvendian.exe.

Important:       You cannot use this utility on a mounted database.

Also, the utility does not work for backup and journal files. You must restore databases on a platform of the same endian,
move the restored databases to the different endian platform, and then use cvendian to convert the databases.
The utility uses simple buffered I/O to read and write the target file. For best performance, ensure that operating system
(OS) file-system caching is not disabled.




2 Conversion Process
You can run cvendian on either the system that has the files to be converted or the system that will be using the converted
files.
For example, to convert a database from a Little-endian to a Big-endian system, you can perform the conversion on the
Little-endian system and then transfer the database to the Big-endian system, or you can transfer the file first, and then
convert it.
To convert a database, the process is:
1.   Make a copy of your database files, because the utility replaces the source files with the converted files.
2.   Run cvendian using the syntax described in the Utility Syntax section.
3.   If the database file is encrypted, enter the encryption key and user/password when prompted. The utility does not provide
     command-line options for passing in these values.




3 Utility Syntax
With the cvendian utility, you can specify the desired byte order, or you can report the current byte order without conversion.
Use the following syntax:
cvendian [-option] file

The option argument is one of the following:
•    -big — convert the database to Big-endian



Using cvendian for Byte Order Conversion                                                                                     1
See Also


•   -little — convert the database to Little-endian

•   -report — report the byte order of the database

You can shorten the options to their initial letter. If this is a conversion request (-big or -little), and the database already
has the specified byte order, the utility displays a warning message and stops processing.
If you do not provide the option argument, the utility converts the database from the existing byte order to the other byte
order. It is recommended, however, that you use the option argument.
The file argument is the file to convert, and can include a complete pathname.
The utility performs the following actions:
•   Auto-detects the byte order of the database
•   Displays endian information and other information
•   Performs the conversion
•   Displays a message indicating success or failure

For example, suppose you are converting a database for use on AIX from Windows. This means you must convert from
Little-endian to Big-endian. The output from running cvendian on the Windows system before moving the file to the AIX
system looks similar to this:

C:\IrisSys\Bin>cvendian -big c:\temp\powerdb\iris.dat

This database is little-endian.
This database has a block size of 8192 bytes.

This database has 1 volume and 1 map.
The last block in the primary volume is 18176.

Original manager directory is c:\temp\powerdb\

No extension volumes.

Done converting c:\temp\powerdb\iris.dat to big-endian

C:\IrisSys\Bin>

You can now move the converted database file to the AIX system.




4 See Also
•   Platform Endianness




2                                                                                    Using cvendian for Byte Order Conversion
