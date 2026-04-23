InterSystems Error Reference
                              Version 2026.1
                               2026-04-20




   InterSystems Corporation One Congress Street Boston MA 02114 www.intersystems.com
InterSystems Error Reference
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
        1 General Error Messages .................................................................................................................... 1
            1.1 Error Codes 0 to 999 .................................................................................................................. 1
            1.2 Error Codes 1000 to 1999 ........................................................................................................ 22
            1.3 Error Codes 2000 to 4999 ........................................................................................................ 30
            1.4 Error Codes 5000 to 5999 ........................................................................................................ 35
            1.5 Error Codes 6000 to 6999 ........................................................................................................ 61
            1.6 Error Codes 7000 to 7999 ........................................................................................................ 77
            1.7 Error Codes 8000 to 8999 ........................................................................................................ 82
            1.8 Error Codes 9000 to 9999 ........................................................................................................ 89
            1.9 Error Codes 15000 and Higher ................................................................................................. 92
            1.10 Non-Numeric Error Codes ..................................................................................................... 93
        2 SQL Error Messages ........................................................................................................................ 95
            2.1 SQLCODE 0 and 100 ............................................................................................................... 95
            2.2 SQLCODE -400 ....................................................................................................................... 95
            2.3 Retrieving SQL Message Texts ................................................................................................ 96
            2.4 Table of SQL Error Codes and Messages ................................................................................. 96
        3 TSQL Error Messages .................................................................................................................... 109
        4 System Error Messages .................................................................................................................. 265
            4.1 General System Error Messages ............................................................................................ 265
            4.2 ISO 11756-1999 Standard Errors ........................................................................................... 275
        5 Messages Related to Productions .................................................................................................. 277
           5.1 Production Errors ................................................................................................................... 277
           5.2 Workflow Errors ..................................................................................................................... 281
           5.3 XPATH Transformation Errors ............................................................................................... 282
           5.4 Electronic Data Interchange (EDI) Errors .............................................................................. 282
           5.5 HL7 Version 2 Message Routing Errors ................................................................................. 283
           5.6 X12 Standard Exchange Format (SEF) File Errors ................................................................ 283
           5.7 X12 Message Routing Errors ................................................................................................. 283
           5.8 DICOM Message Routing Errors ........................................................................................... 286




InterSystems Error Reference                                                                                                                                iii
     List of Tables
     Table 1–1: General Error Codes - 0 to 199 .............................................................................................. 1
     Table 1–2: General Error Codes - 200 to 399 .......................................................................................... 7
     Table 1–3: General Error Codes - 400 to 599 ........................................................................................ 11
     Table 1–4: General Error Codes - 600 to 799 ........................................................................................ 14
     Table 1–5: General Error Codes - 800 to 999 ........................................................................................ 17
     Table 1–6: General Error Codes - 1000 to 1199 .................................................................................... 22
     Table 1–7: General Error Codes - 1200 to 1399 .................................................................................... 25
     Table 1–8: General Error Codes - 1400 to 1599 .................................................................................... 27
     Table 1–9: General Error Codes - 1600 to 1699 .................................................................................... 28
     Table 1–10: General Error Codes - 2000 to 2299 .................................................................................. 30
     Table 1–11: General Error Codes - 5000 to 5199 .................................................................................. 35
     Table 1–12: General Error Codes - 5200 to 5399 .................................................................................. 41
     Table 1–13: General Error Codes - 5400 to 5599 .................................................................................. 45
     Table 1–14: General Error Codes - 5600 to 5799 (Macro Compiler Errors) ........................................ 51
     Table 1–15: General Error Codes - 5800 to 5999 .................................................................................. 55
     Table 1–16: General Error Codes - 6000 to 6199 .................................................................................. 61
     Table 1–17: General Error Codes - 6200 to 6399 .................................................................................. 65
     Table 1–18: General Error Codes - 6400 to 6599 .................................................................................. 70
     Table 1–19: General Error Codes - 6600 to 6799 .................................................................................. 73
     Table 1–20: General Error Codes - 6800 to 6999 .................................................................................. 76
     Table 1–21: General Error Codes - 7000 to 7199 .................................................................................. 77
     Table 1–22: General Error Codes - 7200 to 7399 .................................................................................. 77
     Table 1–23: General Error Codes - 7400 to 7599 .................................................................................. 79
     Table 1–24: General Error Codes - 7600 to 7799 .................................................................................. 80
     Table 1–25: General Error Codes - 7800 to 7999 .................................................................................. 81
     Table 1–26: General Error Codes - 8000 to 8199 .................................................................................. 82
     Table 1–27: General Error Codes - 8200 to 8299 .................................................................................. 85
     Table 1–28: General Error Codes - 8300 to 8599 .................................................................................. 87
     Table 1–29: General Error Codes - 8600 to 8899 .................................................................................. 88
     Table 1–30: General Error Codes - 9000 to 9299 .................................................................................. 89
     Table 1–31: General Error Codes - 9300 to 9400 .................................................................................. 90
     Table 1–32: General Error Codes - 15000 and Higher .......................................................................... 92
     Table 1–33: Miscellaneous Error Codes ................................................................................................ 93
     Table 2–1: SQL Error Codes 0 and 100 ................................................................................................ 95
     Table 2–2: SQL Error Codes -1 to -99 .................................................................................................. 96
     Table 2–3: SQL Error Codes -101 to -399 ............................................................................................ 99
     Table 2–4: SQL Error Codes -400 to -500 .......................................................................................... 105
     Table 2–5: WinSock Error Codes -10050 to -11002 ........................................................................... 106
     Table 3–1: TSQL Error Codes - 0 to 99 .............................................................................................. 109
     Table 3–2: TSQL Error Codes - 100 to 199 ........................................................................................ 109
     Table 3–3: TSQL Error Codes - 200 to 299 ........................................................................................ 112
     Table 3–4: TSQL Error Codes - 300 to 399 ........................................................................................ 115
     Table 3–5: TSQL Error Codes - 400 to 499 ........................................................................................ 116
     Table 3–6: TSQL Error Codes - 500 to 599 ........................................................................................ 117
     Table 3–7: TSQL Error Codes - 600 to 699 ........................................................................................ 119
     Table 3–8: TSQL Error Codes - 700 to 799 ........................................................................................ 120
     Table 3–9: TSQL Error Codes - 800 to 899 ........................................................................................ 120



iv                                                                                                                 InterSystems Error Reference
        Table 3–10: TSQL Error Codes - 900 to 999 ...................................................................................... 121
        Table 3–11: TSQL Error Codes - 1000 to 1099 .................................................................................. 122
        Table 3–12: TSQL Error Codes - 1100 to 1199 .................................................................................. 125
        Table 3–13: TSQL Error Codes - 1200 to 1299 .................................................................................. 126
        Table 3–14: TSQL Error Codes - 1500 to 1599 .................................................................................. 126
        Table 3–15: TSQL Error Codes - 1600 to 1699 .................................................................................. 127
        Table 3–16: TSQL Error Codes - 1700 to 1799 .................................................................................. 127
        Table 3–17: TSQL Error Codes - 1800 to 1899 .................................................................................. 129
        Table 3–18: TSQL Error Codes - 1900 to 1999 .................................................................................. 130
        Table 3–19: TSQL Error Codes - 2000 to 2099 .................................................................................. 133
        Table 3–20: TSQL Error Codes - 2100 to 2199 .................................................................................. 133
        Table 3–21: TSQL Error Codes - 2500 to 2599 .................................................................................. 133
        Table 3–22: TSQL Error Codes - 2600 to 2699 .................................................................................. 136
        Table 3–23: TSQL Error Codes - 2700 to 2799 .................................................................................. 136
        Table 3–24: TSQL Error Codes - 2800 to 2899 .................................................................................. 139
        Table 3–25: TSQL Error Codes - 3000 to 3099 .................................................................................. 139
        Table 3–26: TSQL Error Codes - 3100 to 3199 .................................................................................. 140
        Table 3–27: TSQL Error Codes - 3200 to 3299 .................................................................................. 143
        Table 3–28: TSQL Error Codes - 3300 to 3399 .................................................................................. 145
        Table 3–29: TSQL Error Codes - 3400 to 3499 .................................................................................. 145
        Table 3–30: TSQL Error Codes - 3500 to 3599 .................................................................................. 147
        Table 3–31: TSQL Error Codes - 3600 to 3699 .................................................................................. 147
        Table 3–32: TSQL Error Codes - 3700 to 3799 .................................................................................. 148
        Table 3–33: TSQL Error Codes - 3900 to 3999 .................................................................................. 149
        Table 3–34: TSQL Error Codes - 4000 to 4099 .................................................................................. 150
        Table 3–35: TSQL Error Codes - 4200 to 4299 .................................................................................. 151
        Table 3–36: TSQL Error Codes - 4300 to 4399 .................................................................................. 152
        Table 3–37: TSQL Error Codes - 4400 to 4499 .................................................................................. 153
        Table 3–38: TSQL Error Codes - 4500 to 4599 .................................................................................. 155
        Table 3–39: TSQL Error Codes - 4600 to 4699 .................................................................................. 156
        Table 3–40: TSQL Error Codes - 4700 to 4799 .................................................................................. 156
        Table 3–41: TSQL Error Codes - 4800 to 4899 .................................................................................. 156
        Table 3–42: TSQL Error Codes - 4900 to 4999 .................................................................................. 159
        Table 3–43: TSQL Error Codes - 5000 to 5099 .................................................................................. 160
        Table 3–44: TSQL Error Codes - 5100 to 5199 .................................................................................. 162
        Table 3–45: TSQL Error Codes - 5700 to 5799 .................................................................................. 164
        Table 3–46: TSQL Error Codes - 5800 to 5899 .................................................................................. 164
        Table 3–47: TSQL Error Codes - 5900 to 5999 .................................................................................. 165
        Table 3–48: TSQL Error Codes - 6000 to 6099 .................................................................................. 165
        Table 3–49: TSQL Error Codes - 6100 to 6199 .................................................................................. 165
        Table 3–50: TSQL Error Codes - 6400 to 6499 .................................................................................. 166
        Table 3–51: TSQL Error Codes - 6600 to 6799 .................................................................................. 166
        Table 3–52: TSQL Error Codes - 6800 to 6899 .................................................................................. 167
        Table 3–53: TSQL Error Codes - 7000 to 7099 .................................................................................. 169
        Table 3–54: TSQL Error Codes - 7100 to 7199 .................................................................................. 169
        Table 3–55: TSQL Error Codes - 7200 to 7299 .................................................................................. 171
        Table 3–56: TSQL Error Codes - 7300 to 7399 .................................................................................. 171
        Table 3–57: TSQL Error Codes - 7400 to 7499 .................................................................................. 174
        Table 3–58: TSQL Error Codes - 7600 to 7699 .................................................................................. 174
        Table 3–59: TSQL Error Codes - 7900 to 7999 .................................................................................. 176
        Table 3–60: TSQL Error Codes - 8100 to 8199 .................................................................................. 179



InterSystems Error Reference                                                                                                                   v
     Table 3–61: TSQL Error Codes - 8500 to 8599 .................................................................................. 182
     Table 3–62: TSQL Error Codes - 8600 to 8699 .................................................................................. 183
     Table 3–63: TSQL Error Codes - 8900 to 8999 .................................................................................. 185
     Table 3–64: TSQL Error Codes - 9000 to 9099 .................................................................................. 190
     Table 3–65: TSQL Error Codes - 10000 to 10999 .............................................................................. 190
     Table 3–66: TSQL Error Codes - 11000 to 11999 .............................................................................. 192
     Table 3–67: TSQL Error Codes - 13000 to 13999 .............................................................................. 194
     Table 3–68: TSQL Error Codes - 14000 to 14999 .............................................................................. 195
     Table 3–69: TSQL Error Codes - 14100 to 14199 .............................................................................. 198
     Table 3–70: TSQL Error Codes - 14200 to 14299 .............................................................................. 200
     Table 3–71: TSQL Error Codes - 14300 to 14399 .............................................................................. 204
     Table 3–72: TSQL Error Codes - 14400 to 14499 .............................................................................. 204
     Table 3–73: TSQL Error Codes - 14500 to 14599 .............................................................................. 205
     Table 3–74: TSQL Error Codes - 15000 to 15099 .............................................................................. 208
     Table 3–75: TSQL Error Codes - 15100 to 15199 .............................................................................. 211
     Table 3–76: TSQL Error Codes - 15200 to 15299 .............................................................................. 212
     Table 3–77: TSQL Error Codes - 15300 to 15399 .............................................................................. 215
     Table 3–78: TSQL Error Codes - 15400 to 15499 .............................................................................. 216
     Table 3–79: TSQL Error Codes - 15500 to 15599 .............................................................................. 219
     Table 3–80: TSQL Error Codes - 15600 to 15699 .............................................................................. 221
     Table 3–81: TSQL Error Codes - 16800 to 16899 .............................................................................. 222
     Table 3–82: TSQL Error Codes - 16900 to 16999 .............................................................................. 226
     Table 3–83: TSQL Error Codes - 17000 to 17099 .............................................................................. 228
     Table 3–84: TSQL Error Codes - 17100 to 17199 .............................................................................. 228
     Table 3–85: TSQL Error Codes - 17200 to 17299 .............................................................................. 229
     Table 3–86: TSQL Error Codes - 17300 to 17399 .............................................................................. 230
     Table 3–87: TSQL Error Codes - 17400 to 17499 .............................................................................. 230
     Table 3–88: TSQL Error Codes - 17500 to 17599 .............................................................................. 231
     Table 3–89: TSQL Error Codes - 17600 to 17699 .............................................................................. 231
     Table 3–90: TSQL Error Codes - 17700 to 17799 .............................................................................. 231
     Table 3–91: TSQL Error Codes - 17800 to 17899 .............................................................................. 232
     Table 3–92: TSQL Error Codes - 18000 to 18099 .............................................................................. 233
     Table 3–93: TSQL Error Codes - 18100 to 18199 .............................................................................. 234
     Table 3–94: TSQL Error Codes - 18200 to 18299 .............................................................................. 234
     Table 3–95: TSQL Error Codes - 18400 to 18499 .............................................................................. 235
     Table 3–96: TSQL Error Codes - 18500 to 18599 .............................................................................. 236
     Table 3–97: TSQL Error Codes - 18600 to 18699 .............................................................................. 236
     Table 3–98: TSQL Error Codes - 18700 to 18799 .............................................................................. 236
     Table 3–99: TSQL Error Codes - 18800 to 18899 .............................................................................. 237
     Table 3–100: TSQL Error Codes - 19000 to 19099 ............................................................................ 239
     Table 3–101: TSQL Error Codes - 20000 to 20099 ............................................................................ 239
     Table 3–102: TSQL Error Codes - 20500 to 20599 ............................................................................ 242
     Table 3–103: TSQL Error Codes - 20600 to 20699 ............................................................................ 245
     Table 3–104: TSQL Error Codes - 21000 to 21099 ............................................................................ 246
     Table 3–105: TSQL Error Codes - 21100 to 21199 ............................................................................ 250
     Table 3–106: TSQL Error Codes - 21200 to 21299 ............................................................................ 253
     Table 3–107: TSQL Error Codes - 21300 to 21399 ............................................................................ 258
     Table 3–108: TSQL Error Codes - 21400 to 21499 ............................................................................ 262
     Table 3–109: TSQL Error Codes - 21500 to 21599 ............................................................................ 263
     Table 4–1: System Error Messages ..................................................................................................... 265
     Table 4–2: ISO 11756-1999 Standard Error Messages ....................................................................... 275



vi                                                                                                                 InterSystems Error Reference
1
General Error Messages
This document contains tables of numeric error codes and their corresponding error messages for InterSystems IRIS® data
platform. Commonly, these error codes are reported as ERROR #nnn. These error codes are sometimes referred to as
%Status error codes.
The $SYSTEM.Status class methods used for handling these error codes are documented in the InterSystems Class Reference.
You can determine the error message for a specified error code using the DisplayError() and Error() methods, as shown
in the following example displaying error code #101, where the embedded message variables are %1="5", %2="10", and
%3="2.7":

ObjectScript
    DO $SYSTEM.Status.DisplayError($SYSTEM.Status.Error(101,"5","10","2.7"))

•        Two error codes, 83 and 5001, are provided to enable you to generate your own custom error messages. For details
         refer to the %SYSTEM.Status class in the InterSystems Class Reference.
•        Two error codes, 5521 and 5540, are provided for SQLCODE errors. For details see the %SYSTEM.Error class.

For more information on using these error codes, refer to %Status Error Processing.




1.1 Error Codes 0 to 999
Table 1–1: General Error Codes - 0 to 199

    Error Code          Description
    1                   the volume already exists
    2                   the read of the map block failed
    3                   error writing map blk of primary volume
    4                   unable to read the global directory map block
    5                   unable to write the global directory map block
    6                   unable to write the global directory block
    13                  failed opening the next volume
    14                  failed reading the next volume's map block



InterSystems Error Reference                                                                                                1
General Error Messages


    Error Code    Description
    15            the directory name is too long
    16            the number of maps is invalid
    17            the size is out of range
    18            failed creating a new volume
    19            the file was already mounted
    20            the file already exists
    21            a file create is in progress
    22            the current # of maps is too small
    23            unable to expand the file
    24            the file is cluster mounted
    25            unable to allocate CFN
    26            incompatible mount state or db does not exist
    27            the system mgr's database cannot be cluster mounted
    28            the database is in transition
    30            the system is not part of the cluster
    31            can't change the mode of a mounted database
    32            there is not enough space on device for new vol
    33            the new volume exceeds the system file size limit
    34            unknown error writing to new volume
    35            the database is being expanded
    36            the database is not mountable
    37            the database is mounted elsewhere
    38            there is no room in GVXTAB for secondary volumes
    39            the volume is readonly
    40            databases cannot be deleted while they are cluster mounted
    41            the directory was not found
    42            The database name is invalid
    43            the write daemon failed to set the READ/WRITE flag in label
    44            the expansion failed to start
    45            some or all database files were not deleted
    51            unknown and unexpected error
    52            invalid argument
    53            target could not be opened
    54            target could not be read



2                                                                               InterSystems Error Reference
                                                                                        Error Codes 0 to 999


 Error Code       Description
 55               target could not be written to
 56               the database is being restored
 57               the database does not exist
 58               the operation requires too many bitmap blocks
 59               the allocation new bitmap blks failed
 60               the database must be dismounted to do this
 61               the database must be privately mounted for this
 62               global directory must be empty
 63               cannot cluster mount temp database
 64               cannot dismount temp database
 65               cannot reinitialize mounted database
 66               the resource name in the database is not known to the system
 67               the encryption key for this database is not activated
 68               the mounted database count exceeds license limit
 69               read/write state of mirrored databases can only be changed on the primary
 70               *** Error while formatting volume because
 71               Not owner
 72               No such raw disk device
 73               No such directory
 74               I/O error
 75               No such device or address
 76               Permission to access file denied
 77               Device or resource busy
 78               File already exists
 79               No such device or inappropriate use
 80               File table overflow
 81               Too many open files
 82               Read-only file system
 83               Error code = %1
 84               Audit Database Max size must be set to 0
 85               Operation is not permitted when running in single user mode
 86               the database default collation is not available
 87               the database block size is too small to support direct I/O
 88               direct I/O is not supported on NFS filesystems



InterSystems Error Reference                                                                              3
General Error Messages


    Error Code    Description
    89            database must be opened for direct I/O because async I/O is enabled
    90            2K database block size no longer supported
    91            Creation of Database Extent is not allowed
    92            Database was created in system with different endian
    93            Journaling is required for Audit database
    101           Top Pointer Level: # of blocks=%1 %2kb (%3% full)
    102           Bottom Pointer Level: # of blocks=%1 %2kb (%3% full)
    103           Pointer Level: # of blocks=%1 %2kb (%3% full)
    104           Top/Bottom Pnt Level: # of blocks=%1 %2kb (%3% full)
    105           Data Level: # of blocks=%1 %2kb (%3% full)
    106           Total: # of blocks=%1 %2kb (%3% full)
    107           Elapsed Time = %1 seconds, Completed %2
    108           Error of type %1 while processing pointer block %2
    109           The error occurred while processing node %1
    110           The lower level block specifies a right link block of %1.
    111           Error of type 1. View buffer not open or this dataset can't be mounted.
    112           which is the first block on this level.
    113           which has a left neighbor pointer block of %1
    114           The pointer block is degraded and can't be parsed.
    115           The lower level block is degraded and can't be parsed.
    116           The global reference input as the expected first node is too long.
    117           The pointer block's 1st node - %1 points to block %2. We were expecting it to point to %3,
                  which is the right link of the last lower block of the previous pointer block.
    118           The pointer block's 1st node is: %1. It does not
    119           follow the last global reference.
    120           equal the expected global reference based upon the right link data.
    121           of the last lower block of the previous pointer block, which is: %1.
    122           which is %1 pointing to the lower level block %2
    123           **********Global %1 is Not OK**********
    124           Global ^%1 is OK
    125           The lower level block has a block type of %1
    126           whereas we were expecting %1
    127           The pointer block expected the data block to have
    128           The pointer block did not expect the data block to have any



4                                                                                      InterSystems Error Reference
                                                                                              Error Codes 0 to 999


 Error Code       Description
 129              big strings but the data block's type information
 130              big strings but the data block's big string count
 131              says it does not.
 132              says it does.
 133              The lower level block's info about the first node in the next block is wrong.
 134              The length in blnextpntlen4 is 0 but there is a right link
 135              The length in blnextpntlen4 is nonzero but there is no right link
 136              The length in blnextpntlen4 is too long for a global reference.
 137              The reference described by blnextpntlen4/blnextpntvalue4
 138              doesn't follow the last node in the block.
 139              The length in blnextpntlen4 does not match the length of the first node in the next block
 140              The lower level block has a value in blnextpntlen4
 141              The lower level block has a value in blnextpntoff44
 142              but this isn't a data block
 143              blnextpntoff4 but this isn't a big database data block
 144              (discovered while looking for big strings in the block)
 145              The data block's count of big strings is %1.
 146              whereas its block type specifies
 147              there should be big strings.
 148              there should not be big strings.
 150              The data block has a syntax error
 151              in its big string info
 152              Map block %1 has a label error
 153              The lower block %1 isn't allocated in map block %2
 154              The data block points to a big string stored in block %1
 155              that isn't allocated from its map block %1.
 156              The pointer block is empty.
 157              The lower block has a right link global reference that doesn't
 158              Match what was expected in the next pointer node's global reference.
 159              We would expect the lower block's last node to collate earlier.
 160              We would expect them to be equal.
 161              The lower block's right link reference is %1
 162              The pointer block's next reference is %1.
 163              The pointer node's global reference doesn't match



InterSystems Error Reference                                                                                    5
General Error Messages


    Error Code    Description
    164           the 1st node of the lower block.
    165           The lower block's 1st node is %1.
    166           Since it is a big database data block it should match
    167           the first blpntlen4 bytes of the first node, which is %1.
    168           That doesn't match the next pointer node in the pointer block, which is %1.
    169           The pointer node specifies a block # %1
    170           That is out of the range of this database.
    171           The pointer block has a right link of %1.
    172           No longer present on disk.
    173           Block %1 is not a pointer block type: %2
    174           Top block %1 does not have a top pointer block type: %2
    175           Lower level pointer block %1 has a top pointer block type: %2
    176           Big Strings: # of blocks=%2 %3MB (%4% full) # = %1
    177           Big Strings: # of blocks=%2 %3kb (%4% full) # = %1
    178           The database cannot be mounted because
    179           An unexpected error occurred: %1
    180           Value (report to InterSystems) = %1
    181           ***Further checking of this directory is aborted.
    182           ***Further checking of this global is aborted.
    183           ***We will continue checking with the next pointer block at this level.
    184           The database is not mounted.
    185           Inserted new node %1 at end of block.
    186           Consider if this node should be in this block.
    187           Inserted new node 1 at beginning of block.
    188           Changes are needed in other blocks.
    189           Inserted as new node %1.
    190           Old node %1 and subsequent nodes have been shuffled up.
    191           Node already exists (Node %1).
    192           *** Not enough room in block. ***
    193           ...Deleted. (Higher numbered nodes have been shuffled down.)
    194           Deleted 1st node in block.
    195           ***Type is %1 - Invalid Type.
    196           ***Offset improper: %1 shouldn't be > %2
    197           Top Pointer Level: # of blocks=%1 %2MB (%3% full)



6                                                                                    InterSystems Error Reference
                                                                                             Error Codes 0 to 999


 Error Code       Description
 198              Bottom Pointer Level: # of blocks=%1 %2MB (%3% full)
 199              Pointer Level: # of blocks=%1 %2MB (%3% full)

Table 1–2: General Error Codes - 200 to 399

 Error Code       Description
 200              Top/Bottom Pnt Level: # of blocks=%1 %2MB (%3% full)
 201              Data Level: # of blocks=%1 %2MB (%3% full)
 202              Total: # of blocks=%1 %2MB (%3% full)
 203              but the lower block has a right link of %1.
 204              ***Map Error: The count field in map block %1 says %2 but the counted total is %3.
 205              Integrity Job failed to start.
 206              Stop integrity check?
 207              Stop checking directory?
 208              Stop checking global?
 209              This points to big string block %1 but that has type %2
 211              The pointer block contains the wrong global
 212              Cannot insert long strings.
 213              Creating 2k databases not allowed.
 214              There are %1 duplicate pointers, the first is global %2 pointing to %3.
 215              There is a duplicate pointer, global %1 pointing to %2.
 216              '^%1' is not a valid global name.
 217              Global name '^%1' is too long (over %2).
 250              The stored value of the next pointer in this data block does not match the actual next pointer
                  or blnextpntlen4 is incorrect.
 251              Node #%1 in block #%2 contains an invalid subscript length
 252              Collate #%1 in the block does not match with the collate #%2 in global directory
 253              Block offset in bigstring block #%1 has bad value #%2.
 254              The bigstring block #%1 is pointed with a bad block value #%2.
 255              Block #%1 changed during integrity check, counts may be incorrect
 256              Block #%1 changed during integrity check, might be OK, check should be rerun for this
                  global
 257              Unable to read global directory block #%1
 258              Invalid name %1 in global directory block #%3, entry %2
 259              %1 block %2 is corrupt
 260              %1 block %2 has incorrect type



InterSystems Error Reference                                                                                       7
General Error Messages


    Error Code    Description
    261           %1 block %2 has incorrect label
    262           %1 block %2 has incorrect map number
    263           %1 block %2 has incorrect incremental file number
    264           %1 block %2 has incorrect database creation time
    265           %1 block %2 is marked as bad
    266           The top pointer block %1 is not marked as allocated
    267           %1 errors found during integrity check
    268           whereas we were expecting a pointer block type (2 or 6)
    269           Global directory block %1 points back to previous block %2 in chain
    270           Global directory block %1 has invalid type %2
    271           *** Warning: Counts for global %1 may not be correct, one or more blocks changed during
                  check ***
    272           *** Warning: Global %1 might be corrupt, should be rechecked ***
    273           *** Errors were detected, but only in blocks that changed during check ***
    274           which is %1 in data block %2
    275           which is %1 pointing to a lower level block, however, node may have been deleted. Re-run
                  this check to be sure
    276           The top pointer block %1 has a right link %2
    277           Level %1 possibly has an infinite loop, should have %2 blocks, seen %3 already
    278           Level %1 possibly has an infinite loop, pointer block %2's right link %3 seen already
    279           That doesn't match the next pointer node in the pointer block, however, node may have
                  been deleted. Re-run this check to be sure.
    280           Error parsing global directory block %1. Some globals may be unavailable.
    281           Block offset in the pointer block has a bad value.
    282           Block offset in the lower level block has a bad value.
    283           Error parsing pointer block %1.
    284           %1 block %2 isn't allocated from its map block %3.
    300           the database is not mounted.
    301           the database has degradation.
    302           the database is read-only.
    303           A primary volume already exists in %1.
    304           A secondary volume already exists in %1.
    305           You must choose another location for this primary volume.
    306           You must choose another location for this secondary volume.
    307           Created %1 but failed to mount it. Mount error is %2.



8                                                                                  InterSystems Error Reference
                                                                        Error Codes 0 to 999


 Error Code       Description
 308              Global %1 not found.
 309              Global already defined.
 310              Temp database cannot be the Manager's database
 311              Failed to designate %1 as the Temp database
 312              Failed to lookup sfn for the Temp database
 313              Modify of %1 failed because
 314              This is not a database file %1
 315              The database was created but not formatted.
 316              Cannot delete %1 because
 317              Cannot delete database.
 318              Deleting mirrored database %1 is not allowed.
 319              Completed reclaiming routine blocks for %1.
 320              Create failed because: %1
 321              Could not set Keep Type for %1 because
 322              %1 not mounted because %2 networking is not active.
 323              Cluster mount failed for %1.
 324              This global directory is corrupt.
 325              Could not set journaling type for %1 because
 326              Could not set protection for %1 because
 327              There are no %1 KB buffers (or bigger) configured.
 328              Could not set collation for %1 because
 329              Database Error in ^%1, (report to InterSystems)
 330              Block %1 is not used in any global
 331              Block passed is wrong length: %1
 332              Big string block, use Block Dump option
 333              Global %1 already exists
 334              Cannot create global %1
 335              Global %1 would be remote, not allowed
 336              %1 is not a legal name
 337              Cannot write to file %1
 338              Cannot read input file %1, error is %2
 339              %1 is not a good configuration file
 340              File %1 is not available
 341              Block number %1 is too high for this database



InterSystems Error Reference                                                              9
General Error Messages


 Error Code       Description
 342              Block %1 is not a map block
 343              Block %1 is not the correct map block for %2
 344              Function not supported for legacy databases
 345              Cannot dismount manager's database
 346              Cannot modify this parameter if database exists
 347              Cannot set size less than current size of %1MB
 348              Invalid Parameter for this Operation
 349              Database must exist before adding volumes
 350              Failed to mount %1, the reason is
 351              Error reclaiming routine blocks for %1 :
 352              Map block %1 is corrupt
 353              Database in %1 created with %2 MB instead of requested %3 MB
 354              Comm device(s) are currently in use
 355              Database creation with block size %1 is not allowed
 356              Database %1 cannot be mounted, resource %2 is unknown to the system
 357              FileCompact failed: Insufficient global buffers
 358              FileCompact failed: Compaction in progress
 359              FileCompact: Freespace maximum reached
 360              FileCompact failed: Freespace requested exceeds filesize
 361              Defragmentation failed: Insufficient file space
 362              Defragmentation failed: Insufficient space
 363              Adding system database %1 to mirrored DB is not allowed
 364              Cannot display contents of mirror information block
 365              Namespace %1 is not available. Either the default database is not mounted, or you do not
                  have permission to access it
 366              Database must be larger than minimum allocated size
 367              Import of global '%1' needs collation #%2, not available, skipping import of this item
 368              Failed to return all cached free blocks in the Temp database
 369              Failed, process id %1 has a truncation, compaction or defragmentation operation in progress
                  in this database
 370              The Expansion Size or Maximum Size must be an integer
 371              Database %1 is dismounted
 372              Database %1 is read only
 373              Database %1 is cluster mounted




10                                                                                  InterSystems Error Reference
                                                                                          Error Codes 0 to 999


 Error Code       Description
 374              Database %1 is not journaled
 375              Journaling is not enabled
 376              The collation of some system globals is incorrect
 377              Namespace %1 is not available via ECP. ECP Status returned: %2
 378              Failed: Truncation in progress
 379              Failed: Unexpected block type encountered
 380              Completed but skipped some blocks, details recorded in the messages log.
 381              Stopped at an unmoveable block, details recorded in the messages log.
 382              Unable to get directory info for global %1, Error: %2
 383              Global names for the start node %1 and end node %2 must be the same
 384              Global range %1 must come after %2
 385              Database ExpansionSize %1MB is less than %2MB which is the minimum value of %3KB
                  block size database.
 386              %1 is not a valid operation for the Temp database
 388              Unknown error, code %1
 389              Failed due to backup in progress
 390              Failed due to expansion in progress
 391              Mirrored database has %1 KB block size in primary and there are no buffers configured for
                  it
 392              Mirrored database has %1 KB block size in primary and it is not allowed in local system
 393              Unknown system name %1

Table 1–3: General Error Codes - 400 to 599

 Error Code       Description
 400              , LINE:'%2=%3' at line %1
 401              at line %1
 402              Not enough fields
 403              Invalid line, LINE:'%1'
 404              No version information found in file '%1', file may be corrupt
 405              Invalid version '%1'
 406              Invalid parameter name '%1'
 407              Invalid value for property '%1'
 408              The following parameters are missing from section %1: '%2'
 409              Cannot delete section %1
 410              Too many fields



InterSystems Error Reference                                                                                11
General Error Messages


 Error Code       Description
 411              File %1 has been edited, cannot modify from the management portal
 412              Invalid map keyword %1
 415              Invalid or duplicate section name %1
 416              Duplicate line detected
 417              Duplicate entry %1 detected
 418              Section '[%1]' already exists
 419              %1 %2 already exists
 420              %1 %2 does not exist
 421              %1 map %2 in namespace %3 does not exist
 422              %1 map %2 in namespace %3 already exists
 423              Cannot delete server %1, in use by the following databases: %2
 424              Device name cannot be the same as the Alias
 425              Data server %1 not defined
 426              Data server %1 not allowed for system databases
 427              Cannot delete system database %1
 428              Namespace %1 already exists
 429              Cannot delete database %1, in use by the following namespaces: %2
 430              MountAtStartup, ClusterMountMode, and MountRequired not allowed for a remote server
 431              System database cannot be cluster mounted
 432              Required database %1 is not defined
 433              Namespace %1 does not exist
 434              Cannot delete system namespace %1
 435              Required namespace %1 is not defined
 436              [%1] section must be defined before [Databases] section
 437              [Databases] section must be defined before [Namespaces] section
 438              [DeviceSubTypes] section must be defined before [Devices] section
 439              [Namespaces] section must be defined before [%1] section
 440              These sections are missing: %1
 441              Further processing is aborted
 442              System does not support clustered databases
 444              Comment length must be less than %1 characters
 445              Comment must start with one of the comment chars '%1'
 446              Invalid nested comment, LINE:'%1'
 447              No end comment '%1' found



12                                                                                 InterSystems Error Reference
                                                                                            Error Codes 0 to 999


 Error Code       Description
 448              Invalid routine type %1
 449              Cannot map routine %1 when %2 already exists
 450              %1 data server %1 already defined
 451              You must delete mapping %1 before deleting mapping %2
 452              Mapping %1 already exists
 453              Cannot quiesce the system for namespace reactivation
 454              Global mapping %1 must be defined before subscript mapping %2
 455              Database %1 required, but could not be mounted
 456              [config] MaxServers parameter must be increased to at least %1
 457              Invalid namespace name
 458              Invalid server name
 459              Database %1 already exists
 460              Invalid collation %1
 461              System does not support IPv6
 462              Invalid block size %1
 463              Database %1 is not allowed for ECP Mirror Connection
 464              ECP Server %1 does not exist
 465              Remote Server %1 does not support Mirror
 466              LongStrings cannot be enabled when 2KB or 4KB databases are mounted
 467              Alias %1 is already in use by device %2
 468              Invalid shadow name
 469              [Shadows] section must be defined before [%1] section
 470              Server name '%1' matched local system name
 471              %1 section must be defined before [%2] section
 472              New WIJ directory cannot contain an existing IRIS.WIJ file.
 473              No entry found pointing at local directory %1 in the [Databases] section of the configuration
 474              Unable to obtain lock on CPF file %1
 475              Database %1 is required read-write, but was mounted read-only
 476              Invalid MirrorConnection value %1
 477              Database %1 is not allowed for ECP Non-Mirror Connection
 570              Global %1 contains control characters. Restore of this global may fail. Use block format to
                  save this data. See file %2 for details.
 571              Database copy to %1 is already running
 572              Cannot copy and replace the cluster mounted database %1



InterSystems Error Reference                                                                                    13
General Error Messages


 Error Code       Description
 573              Cannot copy and replace a mirrored database %1

Table 1–4: General Error Codes - 600 to 799

 Error Code       Description
 601              CSP Application
 602              Data Server
 603              Database
 604              Device
 605              Global Mapping
 606              Global Replication
 607              License Server
 608              Namespace
 609              SQL Gateway
 610              Routine Mapping
 611              Mag Tape
 612              Device Sub Type
 613              Ethernet Connection
 614              UDP Connection
 615              Ethernet Device
 616              Volume Set-UCI Mapping
 617              Shadow Destination
 618              Shadow Source
 619              LAT Service
 620              Com Port
 621              SQL System Data Type
 622              SQL User Data Type
 623              SLM Replication
 624              SLM
 625              Journal History
 626              Remote Volume Set
 627              Namespaces
 628              Databases
 629              Devices
 630              Configuration




14                                                                 InterSystems Error Reference
                                                                                         Error Codes 0 to 999


 Error Code       Description
 631              Projection type
 632              Java Application
 633              EJB Application
 634              C++ Application
 635              Class Mapping
 641              %1 '%2' is not defined in this Configuration.
 642              %1 '%2' is referenced by the following %3.
 643              %1 '%2' already exists.
 644              Parameter '%1' invalid: '%2'.
 645              %1 '%2' does not exist.
 646              The configuration could not be reactivated because the changes made require a restart.
 647              Error loading configuration %1: %2.
 648              Configuration %1 needs to be %Saved() before calling the Activate() method.
 649              Configuration %1 is in use by another process.
 650              %1 already defined in Namespace '%2'.
 651              Failed to set Startup configuration to '%1'.
 652              A clustered configuration requires a non empty PIJDirectory.
 653              Subscript reference may not contain the '~' character.
 654              Subscript reference must begin with an open parenthesis.
 655              Subscript reference must end with a close parenthesis.
 656              Open parenthesis before a close parenthesis.
 657              Invalid subscript in reference %1 subscript #1.
 658              Invalid subscript in reference %1 subscript #%2.
 659              Invalid range specification.
 660              More that two references in range specification.
 661              Name required for setting within Config API.
 662              Key is required.
 663              Unable to find information for config setting: %1
 664              [Property does not exist]
 665              Unable to open configuration object: %1
 666              Remote system status change failed.
 667              Error parsing config file: %1
 668              Reactivation error: %1
 669              Collate #%1 entered does not match with the collate #%2 of ^%3 in global directory



InterSystems Error Reference                                                                               15
General Error Messages


 Error Code       Description
 701              LDAP error(%1): %2
 702              LDAP or passed argument is not initialized
 703              Failed to load LDAP shared lib(%1)
 704              Value reach 32K boundary
 705              LDAP can't allocate enough from heap
 706              Invalid parent
 707              Unexpected object passed
 708              LDAP unexpected library version - expecting - %1 loaded - %2
 709              Server passed back another challenge, determine the response to that challenge and call
                  the SASLConect again to send that response
 710              Invalid parameter was passed
 711              Request is not supported
 712              specified SASL mechanism is not supported
 725              Invalid peer certificate verification level for client type
 726              Expanded CipherSuite list contains no values
 727              SSL Communication Not Permitted With Current License
 728              Certificate %1 has expired
 729              Certificate %1 is not valid for TLS Web client authentication
 730              Certificate %1 is not valid for TLS Web server authentication
 731              Encryption with public key in certificate %1 failed
 732              Decryption of private key file %1 failed (possible bad password)
 733              The public key in certificate %1 and the private key in %2 do not match
 734              Verification of certificate %1 with CA file %2 failed, error= %3
 735              '%1' member missing mirror SSL configuration
 736              '%1' is not a mirror member
 737              '%1' is unreachable, error=%2
 738              Can not disable all authentication mechanisms used by Terminal
 739              Mirror SSL validation of '%1' failed with error: %2
 740              Mirror SSL configuration missing certificate file name
 741              Mirror SSL configuration missing CA file name
 742              Certificate %1 is not valid
 743              CA certificate file %1 is not valid
 744              The X.509 certificate is missing
 797              User account has expired



16                                                                                   InterSystems Error Reference
                                                                                   Error Codes 0 to 999


 Error Code       Description
 798              %1 authentication failed
 799              Invalid Application name %1

Table 1–5: General Error Codes - 800 to 999

 Error Code       Description
 800              Logins for Service %1 are disabled
 801              Logins are disabled
 802              Logins are disabled for service %1, system startup in progress
 803              Logins are disabled, system shutdown is in progress
 804              Kerberos logins not allowed for service %1
 805              Kerberos data integrity logins are not allowed for service %1
 806              Kerberos data encryption logins not allowed for service %1
 807              O/S logins are not allowed for service %1
 808              Kerberos logins required for service %1
 809              Service %1 does not exist
 810              Invalid username or password
 811              Kerberos K5CCache logins not allowed for service %1
 812              Kerberos K5Prompt logins not allowed for service %1
 813              Kerberos K5API logins not allowed for service %1
 814              Kerberos K5KeyTab logins not allowed for service %1
 815              User not authorized for service %1
 816              Invalid authentication option %1
 817              Client IP Address %1 not authorized for service %2
 818              Cannot delete service %1
 819              Service %1 already exists
 820              Invalid authentication option %1 for service %2
 821              Access Denied: Cannot access %1
 822              Access Denied
 824              Invalid Username or Password
 825              Unable to initialize SQL, %1
 826              Unable to run ZSTART, %1
 827              User %1 is not authorized
 828              User %1 account is disabled
 829              User %1 unable to add role %2




InterSystems Error Reference                                                                        17
General Error Messages


 Error Code       Description
 830              User %1 unable to update last login
 831              User %1 invalid name or password
 832              User %1 error updating password
 833              Login timeout
 834              Login aborted
 835              User %1 bypassing system security
 836              Insufficient privilege for programmer access
 837              User %1 already exists
 838              User %1 does not exist
 839              Cannot delete superuser %1.
 840              Cannot delete %1, only user with %All role.
 841              Cannot delete default user %1.
 842              Username %1 is invalid.
 843              Username %1 is in use by service %2.
 844              Insufficient privilege for namespace %1, database %2, resource %3
 845              Password does not match length or pattern requirements
 846              Username cannot contain domain specification
 848              System Security configuration %1 already exists.
 849              System Security configuration %1 does not exist.
 850              Audit database %1 not available
 851              Invalid Audit Event name %1
 852              Audit Event %1 already exists
 853              Audit Event %1 does not exist
 854              Cannot delete system Audit Event %1
 855              Cannot modify system Audit Event %1
 856              Error stopping auditing to %1
 857              Unable to start auditing to %1
 858              Unable to quiesce system to erase audit file
 859              Audit record %1 does not exist
 860              Unable to initialize security label for %1, resource is %2
 861              Privileged application %1 is disabled.
 862              User is restricted from running privileged application %2 -- cannot execute.
 863              Privileged application %1 is locked.
 864              An authenticated user name is required.



18                                                                                 InterSystems Error Reference
                                                                                           Error Codes 0 to 999


 Error Code       Description
 865              Routine %1, in database %2, is not authorized to add roles for application %3.
 866              Client application %1 not authorized to add roles - Signature %2.
 867              Cannot create privileged application %1 -- an application by that name already exists.
 868              Privileged application %1 not found.
 869              Application %1 does not exist
 870              Cannot delete system application %1
 874              Duplicate Match role %1.
 875              Match role %1 does not exist.
 878              Duplicate Target role %1.
 879              Target role %1 does not exist.
 880              Cannot delete role %1.
 881              Cannot remove role %1.
 883              Role %1 does not exist.
 884              Role %1 already exists.
 885              Maximum number of roles reached.
 886              Cannot modify role %1.
 887              Invalid role name %1.
 890              Cannot delete system resource %1.
 891              Resource %1 already exists.
 892              Resource %1 does not exist.
 893              Cannot modify system resource %1.
 894              Maximum number of resources reached.
 895              Duplicate resource %1.
 896              Invalid resource name %1.
 897              Invalid permission %1 for resource name %2.
 898              SSL configuration %1 already exists
 900              Cannot delete domain %1, domain is in use.
 901              Domain %1 already exists.
 902              Invalid Domain name %1
 903              Domain %1 does not exist
 904              User's must all be in domain %1, user %2 is not
 913              PhoneProvider %1 does not exist
 914              X509Credentials %1 does not exist
 915              OpenAMIdentityServices %1 does not exist



InterSystems Error Reference                                                                                19
General Error Messages


 Error Code       Description
 920              Cannot modify field '%1'
 921              Operation requires %1 privilege
 922              Operation requires %1 privilege on resource %2
 923              Operation requires %1 privilege on resource %2 or %3
 924              Operation requires %1 privilege on resources %2 and %3
 930              Cannot delete system security parameters
 935              Password change required.
 939              Insufficient privilege for object access '%1'
 940              Insufficient privilege for operation
 941              Audit header contains unwritten records
 942              Username and Role cannot have the same name
 943              User %1 has no role
 944              Invalid expirationdate
 945              Import of audit events to namespace '%1' is prohibited
 946              User %1 has no accessible namespaces
 947              Password logins not allowed for service %1
 948              Unrecognized connection message
 949              Unable to get full header of message within timeout
 950              Invalid service name %1
 951              Unauthenticated access for service %1 is disabled
 952              Invalid password
 953              Invalid Legacy password
 954              Invalid password, cannot convert legacy password
 955              Invalid Kerberos username or password for user %1
 956              Kerberos error: %1
 957              Password logins not allowed for application %1
 958              Invalid password pattern '%1'
 959              User %1 account has expired
 960              User %1 account is inactive
 961              Kerberos Authentication Not Permitted With Current License
 962              Cache Direct Client must be upgraded
 963              No authentication enabled for service
 964              LDAP server unavailable - %1 %2 %3
 965              LDAP search bind failed, error %1, %2



20                                                                             InterSystems Error Reference
                                                                                              Error Codes 0 to 999


 Error Code       Description
 966              LDAP search failed, error %1, %2
 967              LDAP count entries failed, error %1, %2
 968              User %1 does not exist in the LDAP database
 969              User %1 is not unique in the LDAP database
 970              LDAP first entry failed, error %1, %2
 971              Invalid LDAP password, error %1, %2
 972              User %1 is not a LDAP user
 973              User %1 is not a Delegated user
 974              User %1 is not an IRIS user. They are either LDAP, Delegated, Kerberos, or O/S
 975              LDAP Get DN failed, error %1, %2
 976              LDAP Get Values Len failed, error %1, %2
 977              Attribute value %1 must be in $list format
 978              System requires that the user must own the %1 role to connect
 979              SSL configuration %1 does not exist
 980              Unable to activate SSL configuration %1
 981              Invalid SSL configuration name %1
 982              All specified CipherSuites require server authentication, Certificate File and Private Key File
                  are required
 983              Private Key File is required when Certificate File is specified
 984              Certificate File is required when Private Key File is specified
 985              Private Key File is required when Private Key Password is specified
 986              CA File is required when Peer Verification or CRL File is specified
 987              SSL configuration %1 is disabled
 988              SSL handshake failed
 989              SSL connection failed, make sure server address and port (not url) is specified
 990              Can only test SSL Client
 991              Host and Port must be specified
 992              Password has expired
 993              Cannot modify LDAP authentication user
 994              Cannot modify Delegated authentication user
 995              SSL/TLS is required for incoming connections
 996              SSL/TLS is not configured for incoming connections
 997              User %1 failed O/S delegated authentication
 998              Login Token expired



InterSystems Error Reference                                                                                    21
General Error Messages


 Error Code       Description
 999              User %1 Login Token expired




1.2 Error Codes 1000 to 1999
Table 1–6: General Error Codes - 1000 to 1199

 Error Code       Description
 1000             Shadow configuration '%1' incomplete: missing source IP address or DNS name
 1001             Shadow configuration '%1' error: invalid source port number: %2
 1002             Shadow configuration '%1' incomplete: directory for storing copied journal files not specified
 1003             Shadow configuration '%1' incomplete: start point not specified
 1004             Shadow configuration '%1' error: manager directory %2 is not allowed as a shadow database
 1005             Shadow configuration '%1' incomplete: no database mappings exist
 1006             Invalid shadow ID '%1': character '~' not allowed
 1007             Shadow configuration '%1' error: cannot use %2, a primary or alternate journal directory, to
                  store copied journal files
 1008             Shadow configuration '%1': Source databases or journal belong to different mirrors ('%2'
                  and '%3').
 1010             Cannot resume a stopped shadow '%1'
 1012             Unable to acquire exclusive access to properties of shadow configuration '%1'
 1013             Must specify a shadow configuration ID
 1014             Shadow configuration '%1' does not exist
 1015             Shadow '%1' test failed: %2
 1016             Shadow '%1' test timed out
 1017             Shadow '%1' must NOT be running
 1018             Shadow database '%1' is also its corresponding source database
 1020             Database server and shadow server have incompatible shadow protocols: version '%1' on
                  database server vs. version '%2' on shadow server
 1021             Database server and shadow server have incompatible journal versions: version %1 on
                  database server vs. version %2 on shadow server
 1022             Connection denied by database server %1
 1023             Received unrecognizable version '%1' from server
 1024             Error allocating memory from Generic Memory Heap: %1
 1025             Insufficient Generic Memory Heap available for shadowing
 1026             Received unrecognizable message '%1' from server




22                                                                                   InterSystems Error Reference
                                                                                         Error Codes 1000 to 1999


 Error Code       Description
 1027             Cluster shadowing request denied: database server %1 is not part of a cluster
 1028             Cluster shadowing request denied: database server %1 is not part of the source cluster of
                  shadowing, identified by %2
 1029             Shadowing aborted on error
 1030             Unable to job off shadow server process
 1031             Shadow '%1' is being stopped by another process
 1032             Unable to suspend shadow '%1' within %2 seconds
 1033             Requested journal file '%1' does not exist on the source
 1034             Requested file '%1' is not a valid journal file on the source
 1035             Journal file '%1' is corrupted
 1036             Error opening file %1: %2
 1037             Shadow copy %1 is ahead of source journal file %2
 1038             Invalid address %1 in journal file %2
 1039             Journal file to start or resume shadowing with is not specified - possibly as a result of the
                  originally specified journal file name being invalid
 1040             Failed to sync database updates as one updater has died
 1041             Missing start point for cluster shadowing
 1042             Incomplete start point for cluster shadowing: %1
 1043             Shadowing is unavailable for current license
 1044             Shadow is already running
 1045             Bad checkpoint for cluster shadowing: %1
 1046             Database updates are NOT currently journaled on the source of shadowing - shadow
                  databases may be out of sync with the source
 1047             Shadow is not suspended and therefore cannot be resumed
 1048             Shadow is not stopped and therefore cannot be started or restarted
 1070             Attempt to connect to %1 at port %2 timed out - database server is not running or network
                  is down
 1071             TCP read timed out - remote server is not responding
 1072             Database server has disconnected - %1 to the server is aborted
 1073             Shadow server (%2) has disconnected - %1 to the server is aborted
 1074             Unable to job off routine %1
 1075             Failed to start purging as another job (PID %1) appears to be in the middle of purging shadow
                  journal files
 1076             Purging not available to this shadow
 1077             Error getting answer: %1




InterSystems Error Reference                                                                                      23
General Error Messages


 Error Code       Description
 1078             Error killing job (PID %1): %2
 1079             Purging aborted due to failure to sync journal
 1080             Error mounting shadow database %1 when processing journal file %3 -- subsequent updates
                  to the source database %2 will NOT be applied to the shadow database
 1090             There is no database in %1 on the source or it is not readable
 1091             Database in %1 on the source is not currently mounted
 1092             Invalid source directory %1 - name too long or has invalid syntax
 1093             Invalid journal EOF at offset %1 of file '%2' - must traverse forward to get end position
 1094             Got fewer records than expected: last one at %1. Possible corruption in %2 or its source
                  copy.
 1100             Failed to open journal file '%1' for record reading
 1101             File '%1' does not exist
 1102             File '%1' is not a valid journal file
 1103             Error getting previous file of '%1': %2
 1104             Failed to create an instance of journal file '%1'
 1105             The first record of journal file '%1' is invalid
 1106             Error deleting journal file '%1': %2
 1107             Search string not specified
 1108             Journal file not specified
 1109             Journal file '%1' is expected to be followed by another file, which does not exist
 1110             No valid record in journal file '%1'
 1111             Error getting the file following journal file '%1': %2
 1112             Corruption between offsets %2 and %3 of journal file '%1'
 1113             File '%1' does not exist in journal log '%2'
 1120             Unknown column: %1
 1121             Bad directory in journal record
 1122             Bad global node in journal record
 1140             Error starting journaling: %1
 1141             Error stopping journaling: %1
 1142             Error switching journal file: %1
 1143             Directory '%1' does not exist
 1144             Directory name '%1' is invalid
 1145             Error creating directory '%1': %2
 1146             Journal file prefix '%1' is invalid




24                                                                                   InterSystems Error Reference
                                                                                           Error Codes 1000 to 1999


 Error Code       Description
 1147             Directory name '%1' is too long for journal files with names in the form of '%2YYYYMMDD.nnn'
 1148             Commas are NOT allowed in a journal file path ('%1%2YYYYMMDD.nnn')
 1149             Unable to get directory attributes for directory %1
 1150             Journal directory %1 cannot be readonly
 1160             Invalid transaction ID: %1
 1161             Transaction start at offset %1 of file %2 is not a TSTART record
 1180             Cluster journal marker file missing
 1181             Failed to open cluster journal marker file: %1
 1197             Database encryption key activation at startup must be enabled before journal encryption
                  can be enabled
 1198             Failed to switch journal file to activate journal encryption immediately -- journal files will be
                  encrypted following current file
 1199             Failed to switch journal file to deactivate journal encryption immediately -- journal files will
                  stop being encrypted following current file

Table 1–7: General Error Codes - 1200 to 1399

 Error Code       Description
 1200             Encryption key '%1' is already activated
 1201             Encryption key is not activated
 1202             '%1' is not a valid encryption key file
 1203             Encryption key in file '%1' does not match activated key
 1204             User '%1' not found in encryption key file '%2'
 1205             User '%1' already exists in encryption key file '%2'
 1206             Encryption key creation failed
 1207             Encryption key activation failed
 1208             Can not deactivate encryption key. Encrypted databases are mounted: %1
 1209             Invalid password. Must contain at least %1 characters
 1210             Can not remove last administrator from key file
 1211             Wide Unicode characters are not supported in administrator usernames or passwords
 1212             Disabling encryption key activation at startup is NOT allowed when %1
 1213             Disabling encryption key activation at startup is NOT allowed when the encrypted journal
                  file '%1' is required for crash recovery
 1214             Deactivating encryption key is NOT allowed when %1
 1215             Deactivating encryption key is NOT allowed when the encrypted journal file '%1' contains
                  open transactions
 1216             Encryption key activation at startup is still enabled



InterSystems Error Reference                                                                                         25
General Error Messages


 Error Code       Description
 1217             Can not disable encryption key activation at startup. Encrypted databases are required at
                  startup: %1
 1218             Encryption key activation at startup must be enabled before audit encryption can be enabled
 1219             Encryption key unwrap failed; possible incorrect password
 1220             No space available for encryption key
 1221             Key '%1' not found in encryption key file '%2'
 1222             Cannot remove unattended activation administrator from key file
 1300             Failed to lock DataCheck system
 1301             Cannot be run from DataCheck daemon job
 1302             DataCheck System already started
 1303             Global reference %1 does not collate before %2 in collation %3
 1304             DataCheck protocol error
 1305             Failed to initialize DataCheck message queue
 1306             Timed out starting DataCheck job
 1307             Failure during DataCheck job initialization
 1308             Access denied by peer with message: %1
 1309             Timed out waiting for peer
 1310             Duplicate database mapping for %1
 1311             Timed out trying to establish a connection
 1312             %1 is not supported by the peer system
 1313             Unable to detect Mirror-based DataCheck configuration using Mirror name '%1'
 1314             DataCheck source system found for destination GUID does not match the connecting
                  destination system
 1315             Related object '%1' has an incorrect DataCheck system name (%2)
 1316             Database specification %1 is invalid
 1317             Global selection mask is defined for duplicate database specifications %1 and %2
 1360             RangeList state is invalid due to previous error and must be reloaded
 1361             RangeList Collation is already set
 1362             RangeList has newer version stored and must be reloaded
 1370             Initial global reference is null
 1371             Initial global reference and target global reference are identical
 1372             Initial global reference and target global reference refer to different global names
 1380             Workflow must have at least one phase
 1381             Workflow NextPhase is out of range




26                                                                                     InterSystems Error Reference
                                                                                Error Codes 1000 to 1999


 Error Code       Description
 1390             Global Reference is invalid

Table 1–8: General Error Codes - 1400 to 1599

 Error Code       Description
 1400             User %1 is not a Kerberos user
 1401             Routine ZAUTHORIZE not found, see the ZAUTHORIZE routine in the SAMPLES namespace
 1402             Routine ZAUTHENTICATE not found, see the ZAUTHENTICATE routine in the SAMPLES
                  namespace
 1403             Routine ZAUTHENTICATE requires the following parameters:
                  (ServiceName,Namespace,Username,Password,.Properties), see the ZAUTHENTICATE
                  routine in the SAMPLES namespace
 1404             Cannot modify Kerberos authentication user
 1405             User %1 is not a O/S user
 1406             Routine ZAUTHORIZE requires the following parameters:
                  (ServiceName,Namespace,Username,Password,.Credentials,.Properties), see the
                  ZAUTHORIZE routine in the SAMPLES namespace
 1407             Cannot modify O/S authentication user
 1408             Invalid authentication option %1 for application %2
 1409             User '%1' is not configured for two-factor authentication
 1410             Incorrect function code '%1' for two-factor authentication
 1411             Two-factor authentication timeout
 1412             Incorrect token received for two-factor authentication
 1413             Mobile phone service provider '%1' already exists
 1414             Mobile phone service provider '%1' does not exist
 1415             User '%1' has invalid mobile phone number '%2'
 1416             User '%1' has invalid mobile phone service provider '%2'
 1417             Invalid configuration for two-factor authentication
 1418             User %1 account has reached the invalid login limit
 1419             GetCredentials^ZAUTHENTICATE failed
 1420             GetCredentials^ZAUTHENTICATE failed to return a username or password
 1421             User '%1' has mobile phone number but no service provider
 1422             Mirror and shadow service cannot both be enabled.
 1423             LoginRules Security configuration %1 does not exist.
 1424             Cannot add roles while ZINSERT active
 1425             You must modify settings through the Security.System class
 1426             Unauthenticated access for application %1 is disabled



InterSystems Error Reference                                                                         27
General Error Messages


 Error Code       Description
 1427             Unable to add or set Audit Event %1, event table may be full
 1428             Studio does not support Two Factor Authentication
 1429             Insufficient privilege for service %1
 1430             Cannot use implied namespace %1 with -U switch
 1431             The %Manager role requires the %1 resource with R/W access
 1432             Domain name for user %1 is NULL, check network configuration or Kerberos settings
 1433             Incorrect verification code received for one time password authentication
 1434             Two-factor Authentication requires one of the following to be enabled: %1
 1435             Two-factor SMS text authentication requires a phone number and service provider
 1436             Only one type of Two-factor authentication can be enabled
 1501             SSL configuration '%1' does not include valid SSL certificate
 1504             Management Portal unavailable.You must modify settings through the System Management
                  menu.

Table 1–9: General Error Codes - 1600 to 1699

 Error Code       Description
 1600             %1 already exists
 1601             %1 does not exist
 1602             %1 is still running, Pid: %1
 1603             Cannot modify %1, operation is either running or has completed
 1604             User terminated the operation
 1605             Cannot open journal file %1
 1606             Unable to find journal file after %1
 1607             Source and destination database are the same - %1
 1608             Cannot copy from an ECP database
 1609             Cannot copy from system database %1
 1610             Journaling must be enabled on your system
 1611             Journaling is troubled - %1
 1612             Database %1 - %2 must be configured for mirroring
 1613             Unable to set mirror failover state, Status - %1
 1614             Nodes from global %1 already exist in destination database %2
 1615             Global %1 does not exist in source database %2
 1616             %1 has already been run
 1617             Cannot operate on namespace %1
 1618             Routines are already split from namespace %1



28                                                                                 InterSystems Error Reference
                                                                                         Error Codes 1000 to 1999


 Error Code        Description
 1619              Unable to get directory info for global %1, Error: %2
 1620              Collation for global %1 in directories %2 and %3 don't match
 1621              Move globals job failed to start.
 1622              Move globals %1 has already been run.
 1623              Operation terminated by error
 1624              Starting and ending global must be the same
 1625              State is wrong for %1 call, State=%2
 1626              Unable to obtain Data Move Namespace lock
 1627              Unable to find SFN in journal %1 for source directory %2
 1628              Collation of global %1 has changed, unrecoverable error at journal offset %2
 1629              Did not handle Kill of node %1 - Range = %2
 1630              UnHandled Journal record type %1 at journal offset %2
 1631              Unable to start journal monitor
 1632              Cannot calculate Freespace for %1, Database is dismounted
 1633              Max size of database %1 must be increased by at least %2 MB
 1634              Move of data into the following databases exceeds the space on the partition by %1 MB:
                   %2
 1635              New destination database directory for database %1 is not configured
 1636              New destination database directory %1 for database %2 is already configured as database
                   %3
 1637              The following globals in range %1 already exist in destination database %2 : %3
 1638              Data Move Operation %1 is running
 1639              Unable to find and delete range %1
 1640              Invalid method %1
 1641              Invalid Job method %1
 1642              Cannot Job method %1
 1643              Move Data operation %1 %2 is already running
 1644              Move operation %1 has already completed
 1645              Move operation %1 has an unrecoverable error, you must roll it back
 1646              Collation of global %1 has changed, unrecoverable error
 1647              Unable to quiesce system within %1 seconds
 1648              Unable to Suspend, operation already completed
 1649              Unable to Suspend, operation not started
 1650              Unable to Suspend, operation past journal phase




InterSystems Error Reference                                                                                  29
General Error Messages


 Error Code       Description
 1651             Unable to suspend, operation already stopped
 1652             Unable to Stop, operation already completed
 1653             Unable to Stop, operation not started
 1654             Unable to Stop, operation past journal phase
 1655             Invalid Data Move name %1




1.3 Error Codes 2000 to 4999
Table 1–10: General Error Codes - 2000 to 2299

 Error Code       Description
 2000             Journal file #%1 for database '%2' not found in mirror journal log (%3)
 2001             Failed to read header of journal file '%1'
 2002             Mirror name not specified
 2003             Mirror journal log file '%1' not found
 2004             Failed to open journal log for mirror '%1'
 2005             Failed to read journal log for mirror '%1'
 2006             Cannot modify the name of the mirror set
 2007             Cannot modify the GUID associated with the mirror set
 2008             Failed to send updated recovery parameters to mirror members
 2009             Mirror set GUID is not defined. %1 section failed to load
 2010             Failed to load mirror configuration
 2011             Mirror name cannot contain the ':' character
 2012             Mirror name exceeds the maximum length of %1 characters
 2013             Mirror parameters are already loaded - cannot be reloaded with MirrorMember.Load()
 2014             JoinMirror and AsyncMemberGUID should not both be set - %1 aborting
 2015             JoinMirror and AsyncMemberGUID should not both be set
 2016             Missing system name in [MirrorMember] section, can't join mirror
 2017             Missing mirror name in [MirrorMember] section, can't join mirror
 2018             Missing mirror GUID in [MirrorMember] section, can't join mirror
 2019             MirrorMember.CheckSecurity failed to open mirror service '%1'
 2020             Mirror name not defined
 2021             Bad mirror name '%1'
 2022             Cannot shutdown mirroring on the primary mirror member



30                                                                                   InterSystems Error Reference
                                                                                          Error Codes 2000 to 4999


 Error Code       Description
 2023             System name cannot contain the ':' character
 2024             System name exceeds the maximum length of %1 characters
 2025             Mirror name not configured, AsyncMemberAuthorizedIDs cannot be loaded
 2026             SSL DN (Distinguished Name) field already in use
 2027             SSL DN (Distinguished Name) field cannot be null
 2028             %1 missing required parameter(s) - aborting
 2029             No Async member configuration is defined
 2030             No mirror set name to update
 2031             Could not find mirror set %1 in query list
 2032             Mirror set name %1 does not exist
 2033             Invalid mirror configuration for %1, system name '%2' is not unique
 2034             Failed to allocate mirror set %1 structure
 2035             Found duplicate mirror name or GUID with local in %1
 2036             Failed to load mirror configuration of '%1'
 2037             Failed to retrieve mirror configuration for %1 from %2 (%3)
 2038             Mirror member name cannot contain the ':' character
 2039             Mirror member name exceeds the maximum length of %1 characters
 2040             Mirror set name is not defined
 2041             Load All Mirror Set Members already run once, cannot be executed again
 2042             Failed to find our mirror name (%1) in the mirror configuration for %2
 2043             Could not add new member when the Async member connected
 2044             Argument to %1 is not an object
 2045             Failed to add Mirror Set Member %1
 2046             Invalid mirror configuration for %1, guid (%2) for system %3 is not unique
 2047             Incorrect base directory '%1' - Expected '%2'
 2048             Failed to add Mirror Set Member %1 (#%2) to mirror %3
 2049             Insufficient privilege to startup mirroring
 2050             Mirror configuration not loaded
 2051             Mirror set name '%1' is not configured
 2052             Failed to start mirror manager daemon %1
 2053             Failed to create mirror journal log file '%1'
 2054             Failed to delete mirror journal log file '%1'
 2055             Failed to open mirror journal file (%1) containing the start point of the journal file purge
 2056             Virtual IP for mirror %1 is not a valid address '%2'



InterSystems Error Reference                                                                                     31
General Error Messages


 Error Code       Description
 2057             Interface of Mirror Virtual IP does not exist '%1'
 2058             Mirror Database Name is required but not provided
 2059             Mirror Database Name exceeds the maximum length of %1 characters
 2060             Mirror Database Name cannot contain the ':' character
 2061             Mirror Database Name '%1' is not unique, found in mirror member %2
 2062             Failed to check other systems for duplicate Mirror Database name
 2063             Database '%1' is already being mirrored
 2064             Cannot remove database '%1' as is not currently being mirrored
 2065             Could not create new mirror: %1
 2066             Mirroring Service is required but not enabled
 2067             SSL Configuration %1 is required but missing
 2068             SSL Configuration %1 is not enabled
 2069             Names in SSL Server Configuration '%1' and Client Configuration '%2' are different
 2070             Mirror Virtual IP '%1' is owned by another system
 2071             Error retrieving Mirror Set information for '%1'. Error info: %2
 2072             The character size of the other system is different from local system
 2073             Mirrored Database '%1' is not found on this system
 2074             This system has not been configured as a Mirror Member
 2075             There is no other failover member defined on this system
 2076             Error retrieving Mirror Member information for '%1'. Error info: %2
 2077             Failed to force this member become primary, reason: %1
 2078             Mirrored DB is already activated
 2079             Failed to activate mirrored DB reason: %1
 2080             Failed to remove mirrored DB reason: %1
 2081             This is not a Failover mirror member
 2082             Failed to connect to mirror primary node
 2083             Failed to lookup instance name, reason: %1
 2084             Could not join existing mirror: %1
 2085             Virtual IP did not include or had bad CIDR subnet mask: %1
 2086             Agent is unreachable with %1, reason: %2
 2087             Mirror member %1 is unreachable with %2
 2088             ECP connection to Mirror member %1 is unreachable with %2
 2089             Network Interface %1 is not a virtual interface
 2090             Network Interface is not specified for Virtual Address



32                                                                                   InterSystems Error Reference
                                                                                        Error Codes 2000 to 4999


 Error Code       Description
 2091             Failed to get SSL DN field on %1, reason: %2
 2092             SSL required to mirror encrypted database
 2093             Insufficient privilege to shutdown mirroring
 2094             Mirror connections for %1 failed to disconnect cleanly
 2095             Problem detected with mirror SSL/TLS configuration
 2096             Mirror Virtual IP '%1' is not reachable
 2097             Mirror Virtual IP '%1' could not find a matched subnet in Interface '%2'
 2098             Cannot find starting location from filename '%1'
 2099             Mirroring is unavailable for current license
 2100             Failed to open MirrorSetMember entry for %1 (%2)
 2101             Mirror name '%1' is already in use
 2102             Mirrored DB %1 not found in failover member
 2103             Mirrored DB %1 not found in primary member
 2104             Failed to create new mirrored DB (%1)
 2105             Matching mirrored DB %1 in member %2 was not created as mirrored DB
 2106             Mirror Set %1 has already been started
 2107             Mirror Set %1 has not been started
 2108             Failed to open [Mirrors] entry for %1 (%2)
 2109             Failover members can only be a member of a single mirror. [Mirrors] contains %1 mirror
                  definitions
 2110             Mirror name '%1' is not valid - must contain only alphanumeric characters
 2111             Failed to read local mirror member information (%1)
 2112             Delete operations on %1 are not permitted
 2113             Operation can only be performed on the primary mirror member
 2114             Failed to open [MapMirrors.%1] entry for %2
 2115             Clear FailoverDB Flag is not allowed on this system
 2116             Operation is not allowed on the primary mirror member
 2117             Mirror promotion is not allowed for non DR member
 2118             ISCAgent is not up on the local system
 2119             Mirror promotion is only allowed when only one mirror set is configured
 2120             Mirror promotion is only allowed when only one mirror set is configured
 2121             One of the failover members is unreachable through the ISCAgent
 2122             Failed to create Config.MapMirrors object
 2123             GUID mismatch in journal files from mirror members (%1) vs (%2)



InterSystems Error Reference                                                                                 33
General Error Messages


 Error Code       Description
 2124             Selected mirror partner %1 is not in the failover member list
 2125             Selected mirror partner %1 is not a primary candidate
 2126             Failed to clear ValidatedMember on %1. Error: %2
 2127             Failed to tell primary %1 to promote %2. Error: %3
 2128             ISCAgent is unreachable
 2129             Journaling is required for mirrored databases
 2130             Cannot remove database '%1' as it is not currently mounted
 2131             Mirror promotion is not allowed for a relay server member
 2132             VIP is configured but network interface is not configured
 2133             Demotion is not allowed when this is the only failover member
 2134             This member cannot belong to more than one mirror
 2135             Failed to get ISCAgent version information
 2136             Instance's version is later than ISCAgent's version
 2137             There are already more than one failover member configured
 2140             Remote member has different UNICODE property from local member
 2141             Passed system name %1 is different from configured system name %2
 2142             AsyncMemberType parameter is out of range or mismatch with the current setting
 2146             Clear FailoverDB Flag is not allowed on non-activated mirrored DB
 2147             Clear FailoverDB Flag failed due to: %1
 2148             Default system name exceeds the maximum length of %1 characters, caller needs to provide
                  a system name
 2149             A DR async member cannot belong to more than one mirror
 2150             DR async member is not allowed to connect to a non-failover member
 2151             Journal encryption is not allowed when Mirror's UseSSL is not enabled
 2152             Journal encryption is enabled but Mirror's UseSSL is not enabled
 2153             This member is not a reporting member
 2154             Dejournaling is already running (process id: %1)
 2155             Demote without partner does not allow running primary member '%1'.
 2156             Demote %1 failed during promotion. Error: %2.
 2157             Primary (%1) is in trouble state (%2) mirror promotion is not allowed.
 2158             This operation is only allowed on a reporting async member
 2159             This instance is not tracking any mirrors
 2160             This instance is not tracking mirror '%1'
 2161             The mirror name must be specified because the async member is tracking multiple mirrors



34                                                                                 InterSystems Error Reference
                                                                                         Error Codes 5000 to 5999


 Error Code       Description
 2162             Failed to identify the ISCAgent application server port.
 2163             Failed to identify the ISCAgent application server interface.
 2164             The ISCAgent returned an invalid status response.
 2165             This member is not an async member
 2166             his operation is only allowed on an async member
 2167             Invalid Mirror Database Name
 2168             Backup daemon did not exit after mirror shutdown
 2169             Mirror master daemon of mirror set %1 did not exit after 5 seconds timeout
 2170             Mirror Dejournal Filter is enabled but the RunFilter method in SYS.MirrorDejournal.%1 class
                  does not exist
 2171             Mirror name '%1' contains an illegal character sequence '%2'
 2172             Non-FailoverDB mirrored database is not allowed to be configured in DR member
 2173             The mirror configuration change to %1 is blocked until the local validation trouble is resolved
 2174             Failed to create or join mirror set 5 because a mirror journal file (10) exists with the same
                  mirror name
 2175             Mirror SSL DN is too long (over 1024 characters)
 2176             Promotion is not allowed when the mirror is in 'No Partner In No Failover' state.
 2177             Join as Failover is not allowed when the mirror is in 'No Partner In No Failover' state.
 2178             Someone else is doing Promotion or Demotion on this member.
 2179             Failed to shutdown mirror.
 2200             There is no Certificate Authority server configured at instance %1 on node %2.
 2201             Certificate Signing Request %1 not found.
 2202             Certificate number %1 not found.
 2203             Private key file %1 not found.
 2204             Certificate Signing Request %1 creation failed. OpenSSL command output: %2
 2205             Certificate %1 creation failed. OpenSSL command output: %2
 2206             Subject Distinguished Name is required.
 2207             Private Key file password is required.




1.4 Error Codes 5000 to 5999
Table 1–11: General Error Codes - 5000 to 5199

 Error Code       Description
 5001             %1



InterSystems Error Reference                                                                                      35
General Error Messages


 Error Code       Description
 5002             ObjectScript error: %1
 5003             Not implemented
 5004             Cannot generate UUID
 5005             Cannot open file '%1'
 5006             File name '%1' is invalid
 5007             Directory name '%1' is invalid
 5008             File name is required
 5009             Directory name is required
 5010             File '%1' is already opened
 5011             File '%1' is not opened
 5012             File '%1' does not exist
 5013             Cannot Generate Type Library
 5014             %1 is not supported in this version
 5015             Namespace '%1' does not exist
 5017             Too many errors
 5018             Routine '%1' does not exist
 5019             Cannot delete file '%1'
 5020             Cannot rename file '%1'
 5021             Directory '%1' does not exist.
 5022             Expected Data is missing
 5023             Java Gateway Error: %1
 5024             Unable to copy file '%1' to '%2'
 5025             Invalid Connection Name: '%1'
 5026             Invalid ECP client action type: %1
 5027             File '%1' already exists
 5028             Invalid routine name
 5029             Unable to kill process %1
 5030             An error occurred while compiling class %1
 5031             Cannot JOB routine %1
 5032             Cannot create directory '%1'
 5033             Interrupt
 5034             Invalid status code structure (%1)
 5035             General exception Name '%1' Code '%2' Data '%3'
 5036             Failed to acquire lock on SMP Query History metadata



36                                                                       InterSystems Error Reference
                                                                                     Error Codes 5000 to 5999


 Error Code       Description
 5037             No permission to view files in directory '%1'.
 5038             An error occurred while compiling the generator routine '%1'.
 5039             An error occurred while calling function '%1'.
 5040             Unable to copy file %1 to %2
 5041             Unable to execute Java using '%1'. Java may not be installed correctly on your system.
 5042             Unable to execute $zf(%1,%2).
 5043             Jar file %1 does not exist.
 5044             Java Exception: %1.
 5045             Java unknown error: %1.
 5046             Error executing java command '%1'. Java may not be installed correctly on your system.
 5047             Parameter '%1' marked as base64 encoded but not valid base64 '%2'.
 5050             Constraint name '%1' is invalid
 5051             Class '%1' already exists
 5052             Duplicated name: %1
 5053             Class name '%1' is invalid
 5054             Method name '%1' is invalid
 5055             Parameter name '%1' is invalid
 5056             Property name '%1' is invalid
 5057             Storage name '%1' is invalid
 5058             Trigger name '%1' is invalid
 5059             Method name conflict: %1
 5060             Parameter name conflict: %1
 5061             Property name conflict: %1
 5062             Storage name conflict: %1
 5063             Trigger name conflict: %1
 5064             Key name '%1' is invalid
 5065             Key name conflict: %1
 5066             Index name '%1' is invalid
 5067             Index name conflict: %1
 5068             Query name '%1' is invalid
 5069             Query name conflict: %1
 5070             Class name conflict: %1
 5071             Constraint name conflict: '%1'
 5072             Constraint SQL name conflict: '%1'



InterSystems Error Reference                                                                               37
General Error Messages


 Error Code       Description
 5073             XML Map name conflict: %1
 5074             XML Map name '%1' is invalid
 5075             Class dictionary out of date, please run upgrade utility $system.OBJ.Upgrade()
 5076             Key name '%1' is longer than '%2' characters
 5077             Index name '%1' is longer than '%2' characters
 5078             Method name '%1' is longer than '%2' characters
 5079             Property name '%1' is longer than '%2' characters
 5080             Parameter name '%1' is longer than '%2' characters
 5081             Query name '%1' is longer than '%2' characters
 5082             Storage name '%1' is longer than '%2' characters
 5083             Stored procedure name is not unique: %1, projected from %2
 5084             Package name '%1' is invalid
 5085             Package name '%1' is longer than '%2' characters
 5086             Method implementation > 32k
 5087             Projection class type is required for %1:%2.
 5088             Projection class defined for %1:%2 does not exist.
 5089             Projection class defined for %1:%2 is not a subclass of %Projection.AbstractProjection.
 5090             An error has occurred while creating projection %1:%2.
 5091             An error has occurred while removing projection %1:%2.
 5092             Name conflict on class '%1' because class '%2' has the same name but differs in case.
 5093             Name conflict on class '%1' because package '%2' has the same name but differs in case.
 5094             Member name conflict in class '%1' between '%2' and '%3'.
 5095             Name conflict on class '%1' because class '%2' could conflict in the class descriptor.
 5096             Classname '%1' is longer than %2 characters.
 5097             Collation for property '%1' is invalid: '%2'
 5098             Constraint name '%1' is longer than '%2' characters
 5099             Name conflict with project '%1' because you are trying to save project '%2' which has the
                  same name but differs in case.
 5100             In class '%1' sqlname name '%2' from query '%3' conflicts with query '%4' sqlname '%5'.
 5101             Class name required
 5102             Environment keyword required
 5103             Method name required
 5104             Parameter name required
 5105             Property name required



38                                                                                  InterSystems Error Reference
                                                                                          Error Codes 5000 to 5999


 Error Code       Description
 5106             Storage keyword required
 5107             Storage name required
 5108             Trigger name required
 5109             Library name required
 5110             Query name required
 5111             Key name required
 5112             Index name required
 5113             XML Map name required
 5114             Package name required
 5115             Class dictionary version number in database '%1' is too high.
 5116             Class dictionary version for '%1' is out of date, please run upgrade utility
                  $system.OBJ.Upgrade()
 5117             In class '%1' element type '%2', element '%3' and '%4' have the same name but differ in
                  case.
 5118             Schema name conflict on class '%1' because package '%2' has the same schema but is a
                  different name.
 5119             The classname '%1' conflicts with the default resultset package name '%2'.
 5120             The class descriptor is too large, instance methods %1, class methods %2, instance
                  composite %3, class composite %4, properties %5, parameters %6.
 5121             Parameter value for parameter '%1' is longer than '%2' characters
 5122             Class '%1' index '%2': the SQLNAME '%3' is not unique
 5123             Unable to find entry point for method '%1' in routine '%2'
 5124             In class '%1' alias property '%2' from property '%3' conflicts with property '%4'.
 5125             Invalid XML export version '%1', must be major minor version e.g. 2010.1.
 5126             XML export version '%1' not supported, supports 2010.1 and onwards.
 5127             In XML export keyword '%1' in class '%2' not available in target version '%3'. Will remove
                  keyword in exported file.
 5128             In XML export keyword SqlCategory value '%1' in class '%2' not supported in version '%3'.
                  Will remove keyword in exported file.
 5129             Invalid control character in class definition for XML export. Stripping value in XML export,
                  value is '%1'.
 5130             Member '%1' in class '%2' contains an invalid character, the following are not valid '%3'.
 5131             Query class depends on '%1' which has been recompiled.
 5132             Parameter '%1' in class '%2' is not a CONFIGVALUE type so can not be changed.
 5133             Parameter '%1' in class '%2' is not defined in this subclass so can not be changed here,
                  modify in superclass where it is defined.




InterSystems Error Reference                                                                                     39
General Error Messages


 Error Code       Description
 5134             In XML export for index '%1' in class '%2' the index type=collatedkey is not supported in
                  version '%3', will remove type keyword in exported file.
 5135             An MVENABLED persistent class does not support polymorphic dispatch so you can not
                  create a subclass '%1' to the extent root class '%2'.
 5136             You can not have an MV enabled class with a property '%1' list/array collection of objects
                  that includes classname.
 5137             In class '%1' alias property '%2' from property '%3' conflicts with alias property '%4' from
                  property '%5'.
 5149             %1 keyword '%2' type in '%3' is invalid
 5150             %1 keyword '%2' value in '%3' is invalid
 5151             Class attribute keyword '%1' is invalid
 5152             Environment keyword '%1' is invalid
 5153             Method attribute keyword '%1' is invalid
 5154             Parameter attribute keyword '%1' is invalid
 5155             Property attribute keyword '%1' is invalid
 5156             Trigger attribute keyword '%1' is invalid
 5157             Class keyword type '%1' is invalid
 5158             Method keyword type '%1' is invalid
 5159             Parameter keyword type '%1' is invalid
 5160             Property keyword type '%1' is invalid
 5161             Trigger keyword type '%1' is invalid
 5162             Method keyword value '%1' is invalid
 5163             property keyword value '%1' is invalid
 5164             Key attribute keyword '%1' is invalid
 5165             Key keyword type '%1' is invalid
 5166             Key keyword value '%1' is invalid
 5167             Index attribute keyword '%1' is invalid
 5168             Index keyword type '%1' is invalid
 5169             Index keyword value '%1' is invalid
 5170             Query attribute keyword '%1' is invalid
 5171             Query keyword type '%1' is invalid
 5172             Query keyword value '%1' is invalid
 5173             Property '%1' SQL column must be greater than 1 and not greater than 4096
 5174             XML Map attribute keyword '%1' is invalid
 5175             XML Map keyword type '%1' is invalid



40                                                                                   InterSystems Error Reference
                                                                                      Error Codes 5000 to 5999


 Error Code       Description
 5176             Class keyword value '%1' is invalid
 5177             Index property collation of '%2' is invalid: '%1'
 5178             Index data property '%2' is invalid or transient: '%1'
 5179             Property '%1' SQL column must be unique: '%2' is assigned to '%3'
 5190             InitialExpression is not supported for streams, property '%1'
 5191             Can not implement a system method in class '%1'

Table 1–12: General Error Codes - 5200 to 5399

 Error Code       Description
 5201             Invalid parse tree
 5202             Nothing to compile
 5203             CDL Parser error: %1
 5250             Index '%1':'%2' type class, '%3' is not an INDEX class
 5251             Cannot change final method '%1'
 5252             Cannot change final parameter '%1'
 5253             Cannot change final property '%1'
 5254             Cannot inherit from final class '%1'
 5255             Cannot override final property method '%1'
 5256             Cannot replace final behavior '%1'
 5257             Cannot override key definition '%1'
 5258             Cannot override index definition '%1'
 5259             Query type cannot be changed: '%1'
 5260             Cannot change final query '%1'
 5261             Cannot override final query method '%1'
 5262             Cannot project query with parameters '%1' as view
 5263             Cannot project non-SQL query '%1' as view
 5264             Property %1: SQLComputeOnChange attribute %2 is not defined
 5265             Final keyword '%1' can not be changed
 5266             Multiple dependent relationships defined: '%1'
 5267             Cannot change final XML Map '%1'
 5268             Cannot override final XML method '%1'
 5269             Cannot override final method '%1'
 5270             There is a composite method name conflict between '%1' and '%2'
 5271             Cannot override '%1' definition: '%2'




InterSystems Error Reference                                                                               41
General Error Messages


 Error Code       Description
 5272             Cannot change final '%1': '%2'
 5273             Aliased method loop detected in %1:%2
 5274             Aliased method '%3' not found in %1:%2 (%4)
 5275             Aliased method '%3' signature mismatch to %1:%2
 5276             Aliased method '%1:%2' refers to class %3 that is not a superclass
 5277             Cannot introduce dependent (parent) relationship '%1' in subextent '%2' of '%3'
 5278             VERSIONPROPERTY property '%2' is not defined in '%1'
 5279             VERSIONPROPERTY cannot be changed in subextent '%1'
 5280             Cannot support calculated collection property '%1' (it can be computed but not calculated).
 5281             Class has multiple identity properties: '%1::%2'
 5282             Identity property cannot be a collection: '%1::%2'
 5283             Identity property type must be integer: '%1::%2'
 5284             IDKEY index based on non-identity property: '%1::%2'
 5285             Property '%1' is SQLComputed but no SQLComputeCode is defined
 5286             Cannot override classtype '%1' from class '%2' with '%3' in class '%4'.
 5287             Class contains too many properties and hence too many instance variables to compile.
 5288             Compilation of queued classes skipped because queued classes can not queue more classes
                  for compilation more than twice. Classes skipped: '%1'
 5289             Unable to construct the compile tree because class '%1' which it depends on has not had
                  inheritance resolved.
 5290             Class contains too many '%1' members '%2' maximum supported is '%3'.
 5291             Class inheritance depth is too large, maximum supported is '%1'.
 5292             Class/es '%1' has already been compiled twice during this compile so they can not be queued
                  to compile again.
 5301             Method '%1' is missing call tag
 5302             Method '%1' is missing code
 5303             Method '%1' is missing expression
 5304             Method '%1' is missing generator
 5305             Method '%1' is missing name
 5306             Parameter '%1' is missing name
 5307             Property '%1' is missing name
 5308             Query '%1' is missing name
 5309             Query '%1' is missing type
 5310             SQL Procedure Method '%1' must be a class method
 5311             SQL Procedure Method '%1' context parameter is invalid



42                                                                                 InterSystems Error Reference
                                                                                        Error Codes 5000 to 5999


 Error Code       Description
 5312             Constraint '%1' is missing name
 5313             Projection '%1' is missing type
 5314             Method '%1' inherited from class '%2' and required to be regenerated in this subclass has
                  no code as superclass is deployed.
 5315             Member '%1' method '%2' inherited from class '%3' and required to be regenerated in this
                  subclass has no code as superclass is deployed.
 5316             Class dependency loop for classes '%1'
 5317             Class dependency loop for class '%1', parent/child class '%2' has a different system level
 5318             Class dependency loop in classes that must be fully compiled before others in classes '%1'
 5319             The type of a property in a serial class cannot be recursive: %1
 5320             Class '%1' has more than one property of type %Library.RowVersion. Only one is allowed.
                  Properties: %2
 5330             Relationship OnDelete value '%3' in '%1':'%2' is invalid
 5331             OnDelete keyword value '%3' is only valid for a relationship: '%1':'%2'
 5349             Collection of type='%3' is not supported: '%1':'%2'
 5350             Class '%1' can not be locked for exclusive use as user '%2' in process '%3' has an escalated
                  lock.
 5351             Class '%1' does not exist
 5352             Class '%1' is not up-to-date
 5353             Class dependency for class '%1' is unresolved.
 5354             Circular inheritance detected: %1
 5355             Method generator dependency unresolved: %1
 5356             Compiled storage class '%1' does not exist
 5357             Class dependency for class '%1' is unresolved because its parent/child, class '%2', is
                  unresolved.
 5358             Method with language = '%1' cannot be projected as an SQL procedure: '%2'
 5359             Language type = '%1' not supported for method generator = '%2'
 5360             Class '%1' is a stub name and can not be opened
 5361             Attempt to set method '%1' but member method '%2' is already defined
 5362             Attempt to set member method %1:%2:%3 but this is not defined in this class
 5363             Attempt to set member method %1:%2:%3 but this is overridden by method %4
 5364             Class '%1', used by '%2', is not defined.
 5365             Name for table projected from collection '%1::%2' is not unique: %3
 5367             Routine placement dependency unresolved: %1
 5368             System shutting down so unable to compile.




InterSystems Error Reference                                                                                   43
General Error Messages


 Error Code       Description
 5369             Class '%1' is currently being compiled by process '%2'
 5370             Method generator '%1' does not exist
 5371             Class '%1' can not be locked for shared use
 5372             Class '%1' can not be locked for exclusive use
 5373             Class '%1', used by '%2', does not exist
 5374             Internal error attempting to create class descriptor in method '%1'. Contact support
 5375             You can not use an instance property '%1' in a class method
 5376             Method or Property '%1' does not exist in this class.
 5377             You are attempting to call instance method '%1' from a class method
 5378             Class '%1' is in deployed mode.
 5379             Can not compile class in deployed mode: '%1'.
 5380             Class '%1', used by '%2', is in deployed mode.
 5381             Can not export class in deployed mode: '%1'.
 5382             Can not edit class in deployed mode: '%1'.
 5383             Only SQL DATA Map can be overridden: '%1'.
 5384             SQL Map keywords are final, only new DATA items are valid: '%1'.
 5385             SQL Map DATA piece %3 in node %2 is already used: '%1'.
 5386             Method '%1' does not exist in any superclass to class '%2'.
 5387             Method '%1' is abstract in the superclass to class '%2' so you can not call it.
 5388             You do not have write permission on the database class '%1' is in, so class lock can not be
                  obtained.
 5389             Method '%1' is an instance method that uses ##super to call class '%2', but this class is not
                  a primary superclass of '%3' so can not be called.
 5390             Class dependency for class '%1' is unresolved because its predecessor, class '%2', is
                  unresolved.
 5391             Class dependency for class '%1' is unresolved because of the following error: %2.
 5392             No such method '%1' defined in this class.
 5393             You can not reference a property '%1' in a class method.
 5394             Class '%1' depends on class '%2' which has a different System level that prevents it being
                  compiled first or together.
 5395             Invalid routine to call from class '%1' to method '%2' via label '%3'.
 5396             Class descriptor for class '%1' is too large to be supported by system code.
 5397             You do not have write permission on the database item '%1' is in so unable to compile this
                  item.
 5398             Lock table full: Class '%1' can not be locked for exclusive use




44                                                                                    InterSystems Error Reference
                                                                                    Error Codes 5000 to 5999


 Error Code       Description
 5399             Can not compile class '%1' because class '%2' is not up-to-date

Table 1–13: General Error Codes - 5400 to 5599

 Error Code       Description
 5400             Property cannot be stored in multiple data locations: '%1.%2'
 5401             Invalid action type: %1
 5402             Invalid CacheDirect map
 5403             Invalid CLIENTDATATYPE: %1
 5404             Invalid code mode returned by generator: %1
 5405             Invalid collection type: %1
 5406             Invalid default storage environment
 5407             Invalid ID Cardinality: %1
 5408             Invalid ID Counter: %1
 5409             Invalid ID Dependency: %1
 5410             Invalid ID Key: %1
 5411             Invalid ID Key column: %1
 5412             Invalid ID Key property: %1
 5413             Invalid identity type: %1
 5414             Invalid index attribute: %1
 5415             Invalid key
 5416             Invalid key property: %1
 5417             Invalid method code mode: %1
 5418             Invalid property type: %1
 5419             Invalid reference type: %1
 5420             Invalid storage alias
 5421             Invalid storage definition
 5422             Invalid usage of no context: %1
 5423             No data maps defined
 5424             No storage name specified
 5425             Property parameter not declared: %1
 5426             Property type can not be changed: %1
 5427             Error compiling routine: %1
 5428             Storage class not specified
 5429             Storage '%1' not defined




InterSystems Error Reference                                                                             45
General Error Messages


 Error Code       Description
 5430             Trigger '%1' not defined
 5431             Query parameter not declared: %1
 5432             Type specified in ROWSPEC is invalid: %1
 5433             Invalid ODBCTYPE: %1
 5434             Invalid SQLCATEGORY: %1
 5435             Invalid storage structure
 5436             Invalid storage dependency
 5437             Invalid storage literal expression: %1
 5438             Invalid storage symbol expression: %1
 5439             Storage undefined symbol: %1
 5440             Invalid serial dependency
 5441             Undefined storage symbol: %1
 5442             Data subscript already in use: %1
 5443             Multiple Id Keys defined: %1
 5444             Multiple Primary Keys defined: %1
 5445             Multiple Extent indices defined: %1
 5446             Id Key cannot be conditional: %1
 5447             Primary Key cannot be conditional: %1
 5448             Extent index cannot be conditional: %1
 5449             Cannot cluster data with Id Key: %1
 5450             Cannot cluster data with Extent index: %1
 5451             Properties cannot be defined for Extent index: %1
 5452             Extent index cannot also be a key: %1
 5453             Datatype classes can not have properties: %1
 5454             Attribute specified in EXTENTQUERYSPEC is invalid: %1
 5455             Trigger '%1' event invalid
 5456             Trigger '%1' event required
 5457             Trigger '%1' time invalid
 5458             Trigger '%1' time required
 5459             Trigger '%1' order required
 5460             Trigger '%1' code required
 5461             Stream type for attribute '%1' is invalid
 5462             Stream storage value for '%1' is invalid
 5463             Invalid foreign key attribute: '%1'



46                                                                        InterSystems Error Reference
                                                                                     Error Codes 5000 to 5999


 Error Code       Description
 5464             Foreign key '%1' target class '%2' is invalid
 5465             Foreign key '%1' target key '%2' is invalid
 5466             Error code '%1' is out of range
 5467             Error name '%1' is invalid
 5468             Index '%1' TYPE is invalid
 5469             View classes can not have properties: %1
 5470             Id, Primary Key and Unique indices cannot override collation: %1
 5471             Bitmap index cannot be unique: %1
 5472             Cannot cluster data with a bitmap index: %1
 5473             Constraint parameter not declared: %1
 5474             ID Counter is not valid for external table: %1
 5475             Error compiling routine: %1. Errors: %2
 5476             Compilation signature in routine '%1' is incorrect
 5477             Keyword signature error in %1, keyword '%2' must be '%3'
 5478             Keyword signature error in %1, keyword '%2' must be '%3' or its subclass
 5479             An IDKEY Index is required for persistent classes: %1
 5480             %1 parameter not declared: %2
 5481             Class %1 storage definition is invalid
 5482             Class %1 storage is invalid
 5483             Invalid collection type for subnode: %1
 5484             Bitmap indices not supported in dependent class
 5485             Bitmap indices are only supported when the IDKEY is based on a single positive integer
                  attribute
 5486             Invalid method language: %1
 5487             Invalid ROWSPEC format %2: %1
 5488             Invalid %1 formalspec format %2, expected %3
 5489             Error $ZE='%1' reported while running generator for property method '%2:%3'
 5490             Error $ZE='%1' reported while running generator for method '%2'
 5491             Cannot form a relationship with a serial or literal class, '%1'
 5492             Relationship cardinality is invalid, '%1'
 5493             Relationship cardinality is required, '%1'
 5494             Inverse cardinality, '%2' is not valid, '%1'
 5495             Relationship inverse is required, '%1'
 5496             Inverse property, '%2', is not defined, '%1'



InterSystems Error Reference                                                                               47
General Error Messages


 Error Code       Description
 5497             Inverse of inverse property, '%2' does not reference relationship, '%1'
 5498             Related class, '%2', has not been compiled, '%1'
 5499             Internal relationship error
 5500             %1 formal argument type in %2 is invalid: %3
 5502             Error compiling SQL Table '%1'
 5503             Field name is invalid: %1
 5504             Parent column '%1' is invalid
 5505             SQL Table, '%1', parent is invalid
 5506             SQL Counter '%1' is invalid
 5507             SQL Identity table '%1' is invalid
 5508             SQL Map data field '%1' in Map '%2' is invalid
 5509             SQL Map row IDField '%1' is invalid
 5510             SQL Map Subscript '%1' in Map '%2' is invalid
 5511             SQL Map type '%1' is invalid
 5512             SQL Reference target '%1' is invalid
 5513             Map Data Field '%1' is not a valid field
 5514             Map expression - unknown or invalid field: %1
 5515             Table '%1' already exists
 5516             Table '%1' does not exist
 5517             Table not found
 5518             Table ID '%1' does not exist
 5519             Invalid SQL Parent table
 5520             Invalid table reference
 5521             SQLError: SQLCODE=%1 %msg=%2
 5522             Cannot export SQL Table '%1', parent not exported
 5523             Table name is invalid: %1
 5524             Invalid {Field} reference in %2: '%1'
 5525             Class with View named '%1' not found
 5526             Table '%1', specified as reference by '%2', does not exist
 5527             SQL Privilege Violation
 5528             Illegal Regular SQL identifier: '%1', SQL Delimited Identifier option is off
 5529             Illegal Regular SQL identifier: '%1' is an SQL Reserved word please specify a different SQL
                  name for this %2
 5530             Invalid username/password



48                                                                                    InterSystems Error Reference
                                                                                         Error Codes 5000 to 5999


 Error Code       Description
 5531             SQLMGR Missing class name.
 5532             Connection Error
 5533             Allocation Error
 5534             Columns error
 5535             Tables error
 5536             PrimaryKeys error
 5537             Unable to move to offset %1 in stream
 5538             Map Data Variable '%1' expression in Map '%2' is missing
 5539             Map Data Variable name missing in Map '%1', subscript level '%2'
 5540             SQLCODE: %1 Message: %2
 5541             Map: %2 - Map Expression - unknown or invalid field: %1
 5542             Map: %2 - Data Access Expression - invalid expression '%1'. Must be a {Li}, {Di}, or {iDj}
                  reference from a previous subscript level.
 5543             Map: %2 - Invalid Condition, NEXT Subroutine, Row Reference, or Subscript Stop Expression
                  - invalid expression '%1'. Must be an {Li} or {Di} reference from this or a previous subscript
                  level, or an {iDj} reference from a previous subscript level.
 5544             Map: %2 - Data Access Variable Expression - invalid expression '%1'. Must be a {Li}, {Di},
                  or {iDj} reference from this or a previous subscript level.
 5545             Map: %2 - Map Data Retrieval Code - invalid expression '%1'. Must be a {Li}, {Di}, {iDj},
                  {%row}, {%rowraw}, or {*} (This field) reference.
 5546             Map: %2 - RowID Specifications - invalid expression '%1'. Must be a {Li} or any field from
                  Map Data.
 5547             Map: %2 - Subscript Expression - invalid expression '%1'. Must be a valid field reference.
                  If this is the Master Map, it must be an IDKEY field.
 5548             Map: %2 - Map Data Field Name - invalid expression '%1'. Must be a valid field reference.
 5549             Map: %2 - Map Data Node - invalid expression '%1'. Must be a {Di} or {iDj} reference.
 5550             SQL does not support data type methods in languages other than COS in class %1 method
                  %2.
 5551             DEFAULTDATA must be a listnode: %1
 5552             PARENT token used in storage but there is no parent relationship: %1
 5553             ID Property collation must be EXACT: %1
 5554             %2 parameter value must be a positive integer: %1.%2=%3
 5555             Incorrect numeric format in class %1 property %2 method %3
 5556             Foreign key '%1' cardinality does not match referenced key
 5557             BITSLICE index can only have one property: %1
 5558             A SUBVALUE index is defined but BuildValueArray method is not implemented: %1




InterSystems Error Reference                                                                                   49
General Error Messages


 Error Code       Description
 5559             Studio was not able to parse the class definition for class '%1' correctly, possibly due to
                  non-matching {} or () characters, so we can not compile this class. Edit this in Studio and
                  correct the problem.
 5560             Can not save a read only method. This is because implementation is too large to put into
                  property
 5561             An index must have at least one property: %1
 5562             A SUBVALUE index cannot be unique: %1
 5563             %2 parameter value must be an integer between 0 and 15: %1.%2=%3
 5564             Storage reference: '%1' used in '%2' is already registered for use by '%3'
 5565             Error registering reference '%1' for use by '%2': %3
 5566             Unable to recompile all classes in %SYS if system library database is read only
 5567             Class '%1' is in a database you do not have write permissions on so it can not be compiled
 5568             %Currency SCALE parameter value is final and cannot be overridden: %1.%2
 5569             SCALE parameter value cannot be negative: %1.%2
 5570             Class '%1' is in a database you do not have write permissions on so %2 cannot be defined
                  as a subextent.
 5571             Property '%1' in class '%2' is defined as 'not inheritable' but this is not supported.
 5572             Can not inherit relationship property '%1' in class '%2' as a secondary superclass.
 5573             Required constraint not supported on N-Cardinality relationship property '%1' in class '%2'.
 5574             Error reported while running generator for parameter '%1'
 5575             Index cannot reference a private property of a serial class: %1
 5576             No metadata created by '%1'.
 5577             Error calling metadata generator '%1'.
 5578             No method found for metadata generator '%1'.
 5579             Invalid codemode '%1' for metadata generator '%2'.
 5580             SQL Privilege Violation: '%1'
 5581             Error during Build or Purge Indices: $ZError = '%1'
 5582             Unable to grant all privileges on tables, views, and procedures to _PUBLIC for SAMPLES
                  namespace: $ZError = '%1'
 5583             SQL Map '%1', Data Field '%2', Node Value '%3' is invalid. Node Value is not allowed for
                  index maps, only data maps.
 5584             Unable to grant SELECT privilege on tables Docbook.block to _PUBLIC for DOCBOOK
                  namespace: $ZError = '%1'
 5585             Unable to define default RowID Specifications for class %1, map %2, field %3. RowID
                  Specifications must be defined manually for this map definition.
 5586             Invalid argument passed to %1. %2 parameter must be one or more of: %3.




50                                                                                    InterSystems Error Reference
                                                                                       Error Codes 5000 to 5999


 Error Code       Description
 5587             Invalid argument passed to %1. %2 parameter must be begin with one of: %3.
 5588             Invalid argument passed to %1. %2 parameter must be '%3'.
 5589             Invalid argument passed to %1. %2 parameter must be '9,ProcedureName'.
 5590             Failed to acquire lock on extent %1 in order to determine Map Block Counts for the extent
 5591             Invalid argument passed to %1. %2 parameter must be %3.
 5592             Unable to split global '%1' into segments for parallel work because '%2'.
 5593             Unable to split global '%1' into segments for parallel work.
 5594             Error during %SQLBuildPurgeIndexForRow: $ZError = '%1'
 5595             Feature is not supported for a Sharded table: '%1'.
 5596             Global name is missing for SQL map '%1' in table '%2'.
 5597             Sharded table's shard key (%1) must be the same as the idkey (%2) when the idkey (or
                  identity field) is defined.
 5598             Sharded class '%1' must use storage type %Storage.Persistent, not storage type '%2'.
 5599             Sharded class '%1' must be ClassType 'persistent', not ClassType '%2'.
 5597             Sharded table's shard key (%1) must be the same as the idkey (%2) when the idkey is
                  defined.
 5598             Sharded class '%1' must use storage type %Storage.Persistent, not storage type '%2'.
 5599             Sharded class '%1' must be ClassType 'persistent', not ClassType '%2'.

Table 1–14: General Error Codes - 5600 to 5799 (Macro Compiler Errors)

 Error Code       Description
 5600             Feature not supported for sharded class %1: %2 %3.
 5601             No class context: %1
 5602             Cannot resolve super class '%1'
 5603             Instance variable '%1' does not exist
 5604             Instance variable '%1' does not support array
 5605             Invalid class context for instance variable '%1'
 5606             Invalid usage of super - %1
 5607             Reference variable '%1' does not exist
 5608             Reference variable '%1' does not support array
 5610             Referenced macro not defined: '%1'
 5611             Function macro missing arguments: '%1'
 5612             Referenced macro missing right paren: '%1'
 5613             Too many arguments to macro: '%1'
 5614             Not enough arguments to macro: '%1'



InterSystems Error Reference                                                                                  51
General Error Messages


 Error Code       Description
 5615             No closing %1 character inside '%2'
 5616             No open parenthesis after ##keyword
 5617             Invalid preprocessor ##keyword: ##%1
 5618             No closing parenthesis after ##%1
 5619             Invalid ##%1 argument '%1'
 5620             Need Table.Field for ##%1
 5621             No table '%1' for ##%1
 5622             No field '%1' in table '%1' for ##%1
 5623             Invalid argument '%1' to ##%1
 5624             No previous ##%1 (NEW%1) for ##%1(%1%1)
 5625             No macro name for #define
 5626             No closing paren for arglist
 5627             More than one macro parameter with #def1arg
 5628             Macro argument does not begin with %
 5629             Bad character in argument
 5630             ##continue on last line
 5631             '%1' ignored; not preceded by #if or #ifdef
 5632             Null argument to '%1'
 5633             Error evaluating #if or #elseif argument (%1): %2
 5634             No macro name for #%1
 5635             No include file '%1'
 5636             No library file '%1'
 5637             No version #%1 for library file %1
 5638             Incorrect mode for #sqlcompile
 5639             ##function on '%1' failed with an error: %2
 5640             #routine already specified for this macro source file
 5641             #routine cannot be specified after an sql statement
 5642             invalid routine name specified in #routine
 5643             cannot nest ##rtnref calls
 5644             invalid reference specified in ##rtnref
 5645             another element of the same name already exist
 5646             ##expression on '%1' failed with an error: %2
 5647             Invalid macro name in #define or #def1arg: %1
 5648             ##function use is restricted to embedded SQL



52                                                                        InterSystems Error Reference
                                                                                         Error Codes 5000 to 5999


 Error Code       Description
 5649             Too many (%1) macros referenced on this line. This might indicate recursion in the macro
                  definitions.
 5650             SPACE, TAB, "+", "-", "*", "/", "\", "|" characters not allowed in <marker> when using
                  &SQL<marker>(...)<reverse-marker> syntax
 5651             Cannot do property
 5652             Cannot set method
 5653             Compiled class '%1' does not exist
 5654             Method '%1' does not exist
 5655             Parameter '%1' does not exist
 5656             Property '%1' does not exist
 5657             Method '%1' has no return value
 5658             Object instance required
 5659             Property '%1' required
 5660             Query '%1' does not exist
 5661             Collection property '%1' is required so must have at least one member
 5662             Relationship child/many property '%1' is required so must have at least one member
 5663             Statement type (%1) is not supported in #sqlcompile mode=deferred.
 5664             Attempt to reference instance variable '%1' in class method context.
 5665             Macro Preprocessor (MPP) Function '%1' failed with an error: %2.
 5701             Missing required name (macro compiler error)
 5702             Missing left paren (macro compiler error)
 5703             Missing right paren (macro compiler error)
 5704             No equal sign after set left (macro compiler error)
 5705             Unbalanced quotes (macro compiler error)
 5706             Unbalanced parentheses (macro compiler error)
 5707             Unbalanced #beginlit .. #endlit (macro compiler error)
 5710             Unexpected #else (macro compiler error)
 5711             Unexpected #elseif (macro compiler error)
 5712             Unexpected #endif (macro compiler error)
 5720             Unexpected end of line (macro compiler error)
 5721             Unexpected end of file (macro compiler error)
 5730             Incorrect delimiter (macro compiler error)
 5731             External package named %1 not supported (macro compiler error)
 5732             Macro nesting limit exceeded, check for circular macro reference (macro compiler error)




InterSystems Error Reference                                                                                  53
General Error Messages


 Error Code       Description
 5733             No previous new for variable %1 (macro compiler error)
 5734             Embedded file '%1' not found (macro compiler error)
 5740             Compiling (macro compiler error)
 5741             Compile Complete! (macro compiler error)
 5742             Failed to file INT code (macro compiler error)
 5743             Failed to file MAC code (macro compiler error)
 5744             Module exceeded maximum PCODE size (macro compiler error)
 5745             Compile Failed! (macro compiler error)
 5746             Unable to split the code block, pcode is larger than %2 for routine '%1' (macro compiler
                  error)
 5747             Unable to split the code for routine '%1' as it is not INT code (macro compiler error)
 5748             No current class context for #classcontext statement (macro compiler error)
 5750             Security violation opening object '%1'
 5751             Cannot access method '%1'
 5752             Class '%1' is abstract
 5753             Cannot instantiate abstract class '%1'
 5754             Cannot instantiate datatype class '%1'
 5755             Object '%1' is not registered
 5756             Procedure name: '%1' is not valid
 5757             Procedure: '%1' not found
 5758             Method not implemented: %1
 5759             Property is read only
 5760             Fail to instantiate object instance: %1
 5761             Fail to create new object instance: %1
 5762             Class '%1' is read only
 5763             Failed to create embedded object for '%1'
 5764             %DeleteExtent could not delete all instances of '%1'
 5765             Export was done on a system with a different locale: '%1'
 5766             Invalid table name: '%1'
 5767             Table already exists: '%1'
 5768             Class already exists: '%1'
 5769             Linking error: '%1'
 5770             Object open failed because '%1' key value of '%2' was not found
 5771             Object delete failed because '%1' key value of '%2' was not found



54                                                                                   InterSystems Error Reference
                                                                                          Error Codes 5000 to 5999


 Error Code       Description
 5772             Collection is read only
 5773             Cannot set Identity property unless IDENTITY_INSERT option is on: %1
 5774             Cannot update a previously assigned counter property value: %1:%2
 5775             Unable to get a lock on class inheritance structure '%1' within timeout.
 5795             Cannot acquire lock on referenced object for foreign key '%1' for '%2'
 5796             Cannot acquire lock on referenced object for referenced key '%1'
 5797             Instance of '%1' with '%2' key value = '%3' not found
 5798             Failed to lock extent for exclusive access: '%1'
 5799             Failed to lock extent for shared access: '%1'

Table 1–15: General Error Codes - 5800 to 5999

 Error Code       Description
 5800             Concurrency failure on update: object versions not the same for '%1'
 5801             Cannot set serial
 5802             Datatype validation failed on property '%1', with value equal to "%2"
 5803             Failed to acquire exclusive lock on instance of '%1'
 5804             Failed to acquire read lock on instance of '%1'
 5805             ID key not unique for extent '%1' : '%2' exists. Id counter location = '%3'
 5806             Lock type '%1' is invalid
 5807             Oref '%1' is invalid
 5808             Key not unique: %1
 5809             Object to Load not found, class '%1', ID '%2'
 5810             Object to Delete not found, class '%1', ID '%2'
 5811             Nothing to load, class '%1', ID '%2'
 5812             Null id, class '%1'
 5813             Null oid, class '%1'
 5814             Oid previously assigned, class '%1', ID '%2'
 5815             Too many calls to close
 5816             Transaction roll back failed
 5817             No properties selected in query: %1
 5818             Query is not closed
 5819             Too many arguments
 5820             Collection key '%1' is invalid
 5821             Cannot instantiate query: '%1'




InterSystems Error Reference                                                                                   55
General Error Messages


 Error Code       Description
 5822             Formal argument invalid: '%1'
 5823             Cannot delete object, referenced by '%1'
 5824             Object referenced by '%1' does not exist
 5825             Not an instance of %1
 5826             Class '%1' does not support '%2' interface
 5827             Invalid cyclical dependency in save, class '%1'
 5828             Concurrency must be an integer from 0 to 4
 5829             Foreign Key constraint (%1) failed referential integrity check upon %2 in referencing extent
 5830             Foreign Key constraint (%1) failed upon %3 of object in %2 (referential action of %4)
 5831             Foreign Key constraint (%1) failed upon %3 of object in %2: At least 1 object exists which
                  references key %4
 5832             At least one component of the ID value for class %1 is Null: '%2'
 5833             Value not an instance of property's type class: '%1::%2'
 5834             ID counter value is invalid, check the messages log: '%1'
 5835             You can not disconnect a collection that is already disconnected
 5836             Property type class '%3' is abstract: '%1::%2'
 5837             Null GUID: '%1'
 5838             You need %Development:use privilege to run this application.
 5839             Unable to add CSP item '%1' to project because it already includes '%2' which is same name
                  but different case.
 5840             Unable to import file '%1' as this is not a supported type.
 5841             Unable to goto offset %1 in line %2 in file '%3' as line is not long enough.
 5842             Unable to goto line %1 in file '%2' as file too short.
 5843             Unable to instantiate user defined document '%1'.
 5844             User defined document '%1' not supported. No user defined document class in this
                  namespace.
 5845             Item '%1' is not editable%2
 5846             To use Studio you must have %Developer:Use privilege.
 5847             You can not import the default project '%1'.
 5848             You can not export the default project '%1', rename project then export it.
 5849             Routine '%1' is of language type '%2' which is different to the language specified.
 5850             You can not add/remove '%1' to this project as it already contains the package '%2'.
 5851             Cannot modify library class
 5852             Cannot save library class
 5853             Invalid element type



56                                                                                    InterSystems Error Reference
                                                                                            Error Codes 5000 to 5999


 Error Code       Description
 5854             Invalid global reference %1
 5855             Invalid oid prefix
 5856             SQLBinding does not exist
 5857             Storage sql map data name required
 5858             Storage sql map name required
 5859             Storage sql map row IDSpec name required
 5860             Storage sql map subscript name required
 5861             Package routine prefix is too long
 5862             Package global prefix is too long
 5863             Another user has '%1' open for editing.
 5864             User '%2' in process '%3' has '%1' open for editing.
 5865             Item '%1' is not checked out of source control%2
 5876             Project does not have a Name
 5877             Invalid type for project item: '%1'
 5878             Name for project item is blank
 5879             No stream data to import
 5880             Unable to create source control class: %1
 5881             Project '%1' does not exist
 5882             Unable to create a new routine with name '%1'
 5883             Item '%1' is mapped from a database that you do not have write permission on.
 5885             The CSP/CSR page '%1' will be opened as Read Only because its source file is marked as
                  Read Only.
 5886             Can not save compiled dictionary classes.
 5887             Can not delete compiled dictionary classes.
 5888             Can not create new compiled dictionary classes.
 5889             Not logged into source control system so this action is unavailable
 5890             Routine name '%1' is too long
 5891             Unable to copy this project to a new name
 5892             Routine '%1' already exists and is of a different type to the current routine. Either rename
                  your routine or delete the routine that already exists.
 5893             The file '%1' is invalid and terminates before a valid %RO file should, the routine '%2' may
                  be truncated.
 5894             There are too many items in this file to return a list of the items correctly, the list of items is
                  truncated.
 5895             Item '%1' is mapped from another namespace, so you can not save it here.



InterSystems Error Reference                                                                                        57
General Error Messages


 Error Code       Description
 5896             Bad template mode '%1' can be one of TEMPLATE,ADDIN,NEW.
 5897             The source control class can not be changed from Studio, it is locked as '%1'.
 5898             Unable to decode this global format due to it being too long.
 5899             Unable to decode this global format is bad '%1'.
 5900             Package name supplied was '%1' but the real package name was '%2', case in inconsistent.
 5901             Rule family '%1' does not exist
 5902             Rule '%1' does not exist
 5903             Rule name is required
 5904             Attribute '%2' is required for tag '<%1>' on line number %3
 5905             The value of attribute %1, '%2', is invalid, on line number %3
 5906             Session ID is missing
 5907             Session ID '%1' does not exist
 5908             Failed to create class '%1': %2
 5909             There is no closing tag for the tag <%1> on line number %2
 5910             Must relogin with two factor protocol.
 5911             Character Set '%1' not installed, unable to perform character set translation
 5912             Page '%1' does not exist
 5913             HTTP response has an invalid Content-Type '%1'
 5914             CSP Application '%1' does not exist
 5915             Cannot allocate a license
 5916             Illegal CSP Request
 5917             HTTP method '%1' not supported by CSP
 5918             You are logged out, and can no longer perform that action
 5919             The action you are requesting is not valid
 5920             Must use CSP page '%1' from namespace '%2' and not current namespace '%3'
 5921             The CSP application '%1' must specify a namespace to run in
 5922             Timed out waiting for response
 5923             Redirected %1 times, appears to be a redirection loop
 5924             An error occurred and the specified error page could not be displayed - please inform the
                  web master
 5925             <SCRIPT LANGUAGE=CACHE> tag is missing either RUNAT or METHOD attribute, on
                  line number %1
 5926             Unable to redirect as HTTP headers have already been written and flushed
 5927             Unable to load page '%1' because its class name conflicts with the class '%2' that is already
                  loaded



58                                                                                  InterSystems Error Reference
                                                                                       Error Codes 5000 to 5999


 Error Code       Description
 5928             Syntax error while parsing tag <%1> on line number %2
 5929             Syntax error while parsing CSP directive on line number %1
 5930             Include path type does not match filename specification on line number %1
 5931             Can only call this method/set this value in OnPreHTTP() before page has started to be
                  displayed
 5932             Action not valid with this version of the Web Gateway on the web server
 5933             The CSP Server had an internal error: %1
 5934             The class '%1' referred to by the CSP:OBJECT tag '%2' on line %3 is not defined.
 5935             The name of the HTML form, '%1', is longer than 25 characters on line %2.
 5936             The HTML form '%1' is not bound to a valid csp object name on line %2.
 5937             The object variable '%1' to which form '%2' is bound on line %3 is not defined.
 5938             The tag name, '%1', is not unique in the form '%2' on line %3.
 5939             The CSPBIND attribute for SELECT with QUERY must be a persistent object reference on
                  line %1.
 5940             CSP:OBJECT NAME attribute must be a valid identifier for tag '%1' on line %2.
 5941             Multiple CHECKBOX tags cannot be bound to a single value field on line %1.
 5942             %1 tag on line %2 has CSPBIND attribute, but is not in a bound form.
 5943             SCRIPT LANGUAGE=SQL tag cannot have both NAME and CURSOR attribute on line %1.
 5944             %1 attribute must be a valid identifier for %2 on line %3.
 5945             MODE attribute must be DISPLAY, LOGICAL, ODBC or SYSTEM on line %1.
 5946             Duplicate definition of SQL CURSOR '%1' on line %2.
 5947             SQL CURSOR '%1' is not defined and is used on line %2.
 5948             Duplicate definition of object '%1' on line %2.
 5949             Duplicate definition of the rule '%1'.
 5950             Class '%1' does not exist for rule '%2' on line %3.
 5951             The csp:search tag '%1' may have ONSELECT specified only with OPTION=POPUP on
                  line %2.
 5952             The CSP rule version has changed - user rules need to be reloaded.
 5953             Query method did not return a value: %1.
 5954             Failed to lock CSP page.
 5955             CSPAppList query: invalid data in Fetch().
 5956             Directory '%1' for CSP Application '%2' does not exist
 5957             CSPPageLookup: Search error.
 5958             CSPPageLookup: CLASSNAME Missing.
 5959             CSPPageLookup: WHERE Missing.



InterSystems Error Reference                                                                                59
General Error Messages


 Error Code       Description
 5960             CSPPageLookup: Unable to create result set.
 5961             Unable to convert character set '%1'.
 5962             Unable to allocate new session.
 5963             Invalid SysLog level: %1.
 5964             Language changed by page directive on line number %1
 5965             Invalid language, '%1', specified on line number %2
 5966             Unknown charset, '%1', specified on line number %2
 5967             The CSP hyperevent request did not include a mandatory parameter so it can not be
                  processed.
 5968             CSR:RULE LANGUAGE attribute value, %1, is invalid in rule %2.
 5969             Script tag language, '%1', does not match page language on line number %2
 5970             Static SQL tags are not supported on Basic pages on line number %1
 5971             An error occurred attempting to trade a CSP license for a named user license '%1'
 5972             Invalid format for SaveCallback for form %1
 5973             The CSP page '%1' is too large to load, we support pages up to 1.5Mb in size.
 5974             The persistent session is no longer available because the server process does not exist
 5975             Unable to lock session object as another process has this lock
 5976             Direction attribute is not 'forward' or 'backward' on line %1.
 5977             Direction part of WHERE, SELECT or ORDER attribute of csp:search must be ASC or DESC.
 5978             Value of cspSaveMsgEscape attribute must be None, HTML or JS on line number %1.
 5979             Session Id invalid.
 5980             Preserve=1 mode only supported with a real web server.
 5981             csp:include tag must include a PAGE attribute to specify the page to include.
 5982             Only the SELECT SQL command is allowed in SCRIPT LANGUAGE=SQL tag on line %1.
 5983             Page not found.
 5984             In order to run pages in this application we need an authenticated user.
 5985             Attempt to use a web session for service '%1' when session was started as service '%2'.
 5986             Current user is not authenticated to run service '%1'.
 5987             Methods that are defined in a CSP page must be classmethods on line %1.
 5988             The session is only using cookies for session management, but the browser provided a
                  CSPCHD argument to this session.
 5989             System rules (name begins with %) and namespace local rules may not both be defined in
                  the same file.
 5990             Session id '%1' not found.
 5991             Unable to create SOAP method %1



60                                                                                 InterSystems Error Reference
                                                                                       Error Codes 6000 to 6999


 Error Code       Description
 5992             You are not allowed to alter the SecurityContext property
 5993             CSP error trap called with no error information available.
 5994             The CSP application '%1' specifies a namespace '%2' that does not exist.
 5995             Unexpected attribute, %1, on line %2.
 5996             Unable to find CSP.ini CSP gateway file.
 5997             Unable to find CSP gateway username in CSP.ini file.
 5998             Unable to update the CSP.ini CSP gateway file.
 5999             Expecting second portion of two factor authentication to finish login process.




1.5 Error Codes 6000 to 6999
Table 1–16: General Error Codes - 6000 to 6199

 Error Code       Description
 6000             Entered Security Token '%1' did not match sent token.
 6001             Can not restore file '%1' because it contains OBJ routines
 6002             File '%1' is not a %RO output file
 6003             Unable to convert class format
 6004             Unable to export class as XML
 6005             Unable to import class from XML, details follow '%1'
 6006             The XML file does not contain a recognized import format
 6007             Unable to set 'Content-Length' header, since it's readonly.
 6008             Unable to set 'Connection' header.
 6009             Method not supported.
 6010             Already connected.
 6011             Need to be connected.
 6012             No response from POP server: %1.
 6013             Unable to make TCP/IP connection to mail server. An earlier connection may not have been
                  closed.
 6014             TCP/IP session already terminated.
 6015             POP3 Server reported error: %1.
 6016             Invalid response to %1 command: %2.
 6017             Line read from mailbox should not be blank
 6018             TCP/IP session unexpected error: %1.




InterSystems Error Reference                                                                                61
General Error Messages


 Error Code       Description
 6019             Attempt to find location failed
 6020             Handler POP failed
 6021             Handler PUSH failed
 6022             Gateway failed: %1.
 6023             Query not Prepared.
 6024             Invalid %qacn.
 6025             Gateway: Invalid connection handle.
 6026             Gateway: Cannot allocate statement.
 6027             NamespaceList query: invalid data in Fetch().
 6028             Error in Macro Preprocessor: %1.
 6029             Timed out waiting for response.
 6030             '%1' property must be specified for SMTP.
 6031             Unable to open TCP/IP connection.
 6032             Unexpected initial message, server may not be SMTP server: %1.
 6033             Error response to SMTP %1: %2.
 6034             SMTP server connection failed during %1 command: %2.
 6035             Output charset must be specified on Unicode system.
 6036             Character > 255 not valid for quoted printable message
 6037             Nothing imported.
 6038             Failed to Initialize
 6039             RetType not VOID or HRESULT
 6040             RetType name not NULL
 6041             No class to compile: %1
 6042             Routine %1 object code not found
 6043             Database contains class definitions: %1
 6044             Cannot mount database: %1
 6045             Illegal Export Directory Name
 6046             Database doesn't exist: %1
 6047             Invalid identifier format
 6048             Invalid Statement Type: %1
 6049             Invalid Dynamic Query formal parameter %1
 6050             Invalid number of parameter values
 6051             Error Generating INTO clause:
 6052             Invalid conversion direction value



62                                                                            InterSystems Error Reference
                                                                                       Error Codes 6000 to 6999


 Error Code       Description
 6053             Malformed serialized data
 6054             A valid %MessageDictionary is not specified by '%1'
 6055             No language specified.
 6056             Unable to find translate table for output charset: %1.
 6057             POP3 error: %1.
 6058             MessageNumber must be specified.
 6059             Unable to open TCP/IP socket to server %1
 6060             Somebody else is using the Monitor.
 6061             The Monitor is not running
 6062             The Monitor is already running
 6063             Memory allocation for the Monitor failed
 6064             Could not enable statistics collection for Monitor
 6065             Unable to open collection '%1'
 6066             Invalid extension type on compile '%1'
 6067             Problem rebuilding the class index
 6068             Unable to find default XML catalog file '%1'
 6069             Error loading global file '%1' : %2
 6070             SMTP Send failed for all specified email addresses.
 6071             Required argument missing
 6072             Invalid License Key Data
 6073             Could not open license key file '%1' for write.
 6074             Invalid value for ContentTransferEncoding: %1
 6075             %1 is not a block number.
 6076             Block %1 is not a bitmap block.
 6077             Can not compare routines '%1' and '%2' as they are different types
 6078             No implementation in source control class for action %1 with document %2
 6079             The class '%1' is not a valid Studio extension class.
 6080             Can not export '%1' type in %RO format for item '%2'.
 6081             XML exported abstract document data not formatted as CDATA.
 6082             License upgrade error: '%1'.
 6083             The operation is not licensed.
 6084             Unknown errors detected, but no error code reported
 6085             Unable to write to socket with SSL/TLS configuration '%1', error reported '%2'
 6086             If Content-Type is message/rfc822, the only part must be a %Net.MailMessage.



InterSystems Error Reference                                                                                63
General Error Messages


 Error Code       Description
 6087             Content-Transfer-Encoding for attached email must be '7bit' or '8bit'.
 6088             Invalid response from proxy '%1' on CONNECT command '%2'.
 6089             CONNECT command to proxy '%1' failed with response '%2'.
 6090             No boundary attribute specified for multipart Content-Type.
 6091             Unexpected boundary line found at beginning of MIME body.
 6092             Invalid MIME header format.
 6093             Unexpected end of message found. Invalid MIME format.
 6094             MIME message source must be defined using OpenFile or OpenStream.
 6095             HTTP header name too long to store '%1'.
 6096             Global name '%1' is not valid.
 6097             Error '%1' while using TCP/IP device $zu(189,1)='%2'
 6098             Unable to create temporary file for HTTP request
 6099             SSLConfiguration must be specified if UseSTARTTLS is true.
 6100             STARTTLS not supported for SMTP: %1.
 6101             Com Exception: '%1'
 6102             Com CoClass has no default Interface defined
 6103             Com CoClass default interface does not support automation
 6150             Unable to set new source control class as you do not have WRITE privileges needed update
                  ^%SYS global
 6151             Item '%1' is marked as read only by source control hooks.
 6152             Unable to remove item '%1' from the project as is not present in the project.
 6153             Email must be retrieved with Fetch before GetAttachedEmail is called.
 6154             Connection to web server can not reuse existing socket as socket was closed to server '%1'.
 6155             Unable to verify SSL/TLS connected to correct system as no SSL certificate present for this
                  socket.
 6156             No match between server name '%1' and SSL certificate values '%2'.
 6157             Unable to save CSP file '%1' because temp file '%2' was not created, check directory
                  permissions.
 6158             Unable to use fulldeploy on class '%1' because it is a subclass of %SwizzleObject or
                  %XML.Adaptor.
 6159             Although Https property is enabled no SSLConfiguration is specified so unable to make an
                  HTTPS connection to '%1'.
 6160             HTTP request redirected to HTTPS address but no SSLConfiguration is specified so unable
                  to make an HTTPS connection to '%1'.
 6161             HTTP request redirected to server '%1' at location '%2' which then reported the embedded
                  error.



64                                                                                  InterSystems Error Reference
                                                                                     Error Codes 6000 to 6999


 Error Code       Description
 6162             Unable to create HTTP Authorization header for %1 scheme.
 6163             Authentication error for %1 scheme.
 6164             External Interrupt request failed with an error: %1
 6165             Path associated with cookie '%1' is too long, maximum supported is 510 characters and it
                  is '%2' characters for path '%3'.
 6166             Server does not support authentication.
 6167             Authentication expected but failed.

Table 1–17: General Error Codes - 6200 to 6399

 Error Code       Description
 6201             Cannot Create Object: %1
 6202             Cannot Create Message Handler: %1
 6203             Unexpected Element
 6204             SOAP message contains prohibited processing instruction
 6205             Element must be namespace qualified
 6206             Version Error, namespace must be %1.
 6207             Unexpected SOAPACTION value: %1
 6208             Unexpected Attribute
 6209             Wrong number of Attributes
 6210             Invalid Attribute value
 6211             Missing Attribute
 6212             Incorrect Attribute namespace
 6213             Attribute namespace not in scope
 6214             Attribute NOT qualified
 6215             Attribute value NOT qualified
 6216             Unsupported Transport
 6217             Add Operation Failed
 6218             Duplicate Element
 6219             Unknown Error
 6220             Internal Server Error
 6221             Mandatory Header NOT supported: %1
 6222             Invalid SoapBindingStyle keyword '%1' for WebMethod %2.
 6223             Invalid SoapBodyUse keyword '%1' for WebMethod %2.
 6224             Arguments to a Web Service may not be of type: %1.
 6225             A DTD cannot be generated for class: %1.



InterSystems Error Reference                                                                                 65
General Error Messages


 Error Code       Description
 6226             Argument, %1, of WebMethod, %2, must be a simple type or SOAP enabled.
 6227             Server Application Error
 6228             Badly formed SOAP Message
 6229             XMLPROJECTION value is inconsistent with type of property: %1.
 6230             Invalid value for XMLPROJECTION of property: %1.
 6231             Invalid format for %XML.Adaptor: %1.
 6232             Datatype validation failed for tag, %1, with value: %2
 6233             XML input is not in proper format for tag: %1.
 6234             Required tag not present: %1
 6235             Unexpected namespace for tag: %1.
 6236             Referenced id not found, %1, for tag: %2.
 6237             Unexpected tag in XML input: %1.
 6238             Key attribute not specified for an array tag: %1.
 6239             Only one property may have XMLPROJECTION = content
 6240             SERVICENAME must be specified by overriding the SERVICENAME parameter.
 6241             The SOAP WebClient LOCATION parameter must specify http or https transport.
 6242             HTTP request to SOAP WebService returned unexpected status: %1.
 6243             HTTP request to SOAP WebService returned response with unexpected CONTENT-TYPE:
                  %1.
 6244             The location of the web service must be specified.
 6245             Client Web Method may not have an argument beginning with %: %1.
 6246             No response to SOAP request.
 6247             Unexpected encoding of SOAP response.
 6248             SOAP response is a SOAP fault: %1
 6249             A class referenced by an XMLENABLED class must be a subclass of %XML.Adaptor: %1
 6250             Collection property requires ELEMENTTYPE parameter in referenced class: %1
 6251             Cannot find message element '%1' in XML namespace '%2'
 6252             Datatype validation failed because no value found for tag, %1.
 6253             Datatype validation failed for tag %1. Unexpected tag <%2> found.
 6254             Tag expected, XML input, %1, is not in proper format as child of %2.
 6255             XML is not in proper format for DataSet record in field '%1', %2.
 6256             SubstitutionGroup for property '%1' is inconsistent with previous substitutionGroup.
 6257             XMLCHOICELIST for property '%1' may not contain literal type '%2'.
 6258             Invalid ENCODING parameter '%1' for property '%2'.



66                                                                                    InterSystems Error Reference
                                                                                        Error Codes 6000 to 6999


 Error Code       Description
 6259             XMLPROJECTION for property '%1' may not be ID unless this property is a persistent object.
 6260             Datatype validation failed for attribute, %1, with value %2 for element %3.
 6261             Unexpected value for XMLIGNORENULL class parameter: %1
 6262             Invalid value for XMLIO of property: %1.
 6263             Invalid value for XMLREFERENCE of property: %1.
 6264             Invalid value for XMLTYPECONSTRAINT of property: %1.
 6265             XMLREFERENCE and XMLTYPECONSTRAINT may be specified only for class references
                  for property: %1.
 6266             XMLTYPECONSTRAINT may not be specified with XMLREFERENCE = ID for property:
                  %1.
 6267             XMLSUMMARY must a comma separated list of class properties.
 6268             Invalid value for XMLDEFAULTREFERENCE.
 6269             CLASS and QUERY must be specified for a typed dataset.
 6270             Duplicate WebMethod name not allowed: %1.
 6272             The QUERYNAME parameter and the classname (or XMLNAME override) may not be the
                  same.
 6273             An %XML.DataSet cannot have the QueryName and DataSetName properties.
 6275             Cannot output a new XML document or change %XML.Writer properties until the current
                  document is completed.
 6276             A root element must be written to contain child elements.
 6277             Type attribute, %1, does not specify valid type for XML input tag: %2.
 6278             XML output string is not available.
 6279             XML output string length is greater than the maximum string length.
 6280             An %XML.DataSet cannot be directly executed to get the query result.
 6281             %1 of class %2 must be able to differentiate child classes of %3.
 6282             Malformed SOAP Body in response.
 6283             Unexpected session cookie in session header.
 6284             Security header error: %1.
 6285             Cannot call EndDocument unless StartDocument called.
 6286             Root element, processing instruction or DOCTYPE may not be in root element.
 6287             Attribute may only be called immediately after Element or RootElement.
 6288             Invalid schema for %XML.Dataset at element '%1', %2.
 6289             Dataset schema does not match the specified typed %XML.Dataset: %1, %2 : %3 '= %4.
 6290             Dataset schema must be in XML input if %XML.Dataset is not typed.
 6291             Dataset name, row name and XML namespace must match XML schema for %XML.Dataset.



InterSystems Error Reference                                                                                 67
General Error Messages


 Error Code       Description
 6292             %XML.Dataset may not have duplicated column name: %1.
 6293             Unable to load translate table '%1' for charset '%2'.
 6294             Cannot find message part in schema: %1
 6295             Internal error in XML Schema Wizard: %1
 6296             XML export cycle found in class: %1
 6297             Invalid value for XMLSTREAMMODE of property: %1.
 6298             XMLSTREAMMODE is not permitted for property %1, since it is not a character stream.
 6299             XMLNAME does not specify a valid XML name for property %1.
 6300             Invalid value for XMLFORMAT.
 6301             SAX XML Parser Error: %1
 6302             XML message file format invalid at Line %1 Offset %2.
 6303             Content Handler is NOT a subclass of %XML.SAX.ContentHandler
 6304             Unable to export item '%1' because XML export does not support items of this type. Will
                  skip this item.
 6305             Unable to export item '%1' because can not instantiate user defined document type '%2'.
                  Will skip this item.
 6306             CSP page '%1' does not have an associated application, skipping this item.
 6307             CSP file '%1' associated with page '%2' does not exist, skipping this item.
 6308             Item '%1' is invalid or does not have any data to export, skipping this item.
 6309             Class '%1' is in deployed mode and so can not be exported, skipping this item.
 6310             URL '%1' is malformed and cannot be processed
 6311             Schema definition for namespace '%1' does not exist.
 6312             Unable to find default namespace for class '%1'.
 6313             Schema moniker type '%2' (from schema '%1') is invalid.
 6314             SAX XML Parser Warning: %1
 6315             Errors reporting importing XML subelement in file '%1' at line '%2' offset '%3', skipping this
                  item.
 6316             No subdocument to import, skipping this item.
 6317             Invalid value for XMLINHERITANCE: %1.
 6318             Property required in XML document: %1
 6320             Unexpected value for fixed attribute, %1, with value %2 for element %3.
 6321             Only CreateSequenceResponse response to WS-ReliableMessaging CreateSequence
                  request is supported: %1.
 6322             Unsupported value of IncompleteSequenceBehavior in CreateSequenceResponse message:
                  %1.




68                                                                                   InterSystems Error Reference
                                                                                    Error Codes 6000 to 6999


 Error Code       Description
 6323             Unexpected WS-ReliableMessaging header: %1
 6324             WS-ReliableMessaging Sequence header expected but not present
 6325             WS-ReliableMessaging response Sequence header LastMessageNumber does not match
                  request Sequence header
 6326             Only CloseSequenceResponse response to WS-ReliableMessaging CloseSequence request
                  is supported: %1.
 6327             Only TerminateSequenceResponse response to WS-ReliableMessaging TerminateSequence
                  request is supported: %1.
 6328             A %SOAP.RM.CreateSequence object may only be used once to call %StartRMSession in
                  order to start an RM session.
 6350             SoapMessageName keyword may only be specified for a web service method: %1.
 6351             SoapAction keyword may only be specified for a web service method: %1.
 6352             Invalid value for HttpRequester: %1.
 6353             Unexpected attributes for element %1: %2
 6354             If a property is not of type string and has XMLPROJECTION = content, then all other
                  properties must have XMLPROJECTION = attribute.
 6355             SOAP message has no body.
 6356             Invalid node type: %1.
 6357             Parent node may not be set directly.
 6358             Error scanning tree: element expected.
 6359             Binary SOAP protocol may not be used with %SOAP.WebRequest.
 6360             Unexpected class, %1, received for binary SOAP protocol. %2 expected.
 6361             Class must be XML enabled: %1.
 6362             Duplicate definition of XML schema %1 %2 for class %3.
 6363             Inconsistent use of encoded format for XML namespace %1.
 6364             Inconsistent definition of ELEMENTQUALIFIED or ATTRIBUTEQUALIFIED for classes in
                  namespace %1.
 6365             Invalid format of SOAP binary %1.
 6366             Unexpected top logical block: %1.
 6367             Unexpected SOAP binary version number: %1.
 6368             Duplicate definition of class, %1, in SOAP binary message.
 6369             Object instance refers to unknown class with index %1 in SOAP binary message.
 6370             Duplicate specification of SOAPCLASSNAME for class %1.
 6371             ServiceName must be specified in SOAPCLASSNAME for class %1.
 6372             Multipart MIME SOAP message received with unexpected Content-Type header field: %1.
                  Only SOAP with Attachments and MTOM are supported.



InterSystems Error Reference                                                                             69
General Error Messages


 Error Code       Description
 6373             The SOAPVERSION parameter specifies an unsupported SOAP version: %1.
 6374             SOAP version %1 is not supported for this web client.
 6375             SOAP encodingStyle %1 is not supported.
 6376             Mandatory Header NOT supported
 6378             Invalid value for SECURITYIN parameter: %1
 6379             WS-Security header is required.
 6380             Format of certificate file is invalid: %1.
 6381             Unsupported Encryption algorithm for WS-Security: %1.
 6382             Key encryption failed: %1.
 6383             Encryption failed: %1.
 6384             Invalid value for XMLMAPPING.
 6385             XMLPROJECTION as attribute or content not allowed for XMLMAPPING="sequence".
 6386             XMLPROJECTION must be "group" when referencing class with XMLMAPPING="sequence":
                  %1.
 6387             ARGUMENTSTYLE must be either "wrapped" or "message": %1.
 6388             Unexpected element in SOAP message: %1.
 6389             Unable to create security element: %1.
 6390             Signature validation failed: %1.
 6391             Invalid WS-SecureConversation DerivedKeyToken: %1.
 6392             Only RequestSecurityTokenResponseCollection response to WS-SecureConversation
                  RequestSecurityToken request is supported: %1.
 6393             RequestSecurityTokenResponseCollection response to WS-SecureConversation
                  RequestSecurityToken request with no elements is not supported.
 6394             Unexpected %1 in SecurityTokenRequestResponse: %2.
 6395             %1 element is not supported in SecurityTokenRequestResponse.
 6396             SecurityContextToken not returned in SecurityTokenRequestResponse.
 6397             Invalid SecurityContextToken in SecurityTokenRequestResponse: %1."
 6398             SecurityContextToken has no associated key.
 6399             Unexpected SecurityTokenRequestResponse to cancel request.

Table 1–18: General Error Codes - 6400 to 6599

 Error Code       Description
 6401             Element '%1', invalid attribute '%2'
 6402             Element '%1', attribute '%2' has invalid value %3
 6403             Element '%1' contains invalid attributes




70                                                                             InterSystems Error Reference
                                                                                       Error Codes 6000 to 6999


 Error Code       Description
 6404             Element '%1', invalid
 6405             Element '%1' has invalid value '%2'
 6406             Specified namespace '%1' is invalid, MUST be '%2'
 6407             Cannot deduce Schema Type - No valid correspondence found
 6408             Cannot deduce Message Type - No valid correspondence found
 6409             Unsupported encoding '%1'
 6410             Element '%1', required attribute '%2' is missing
 6411             Element '%1' is missing
 6412             Element '%1' - cannot determine %2 for operation %3
 6413             Element '%1' - corresponding %2 %3
 6414             Element '%1' - duplicate name '%2'
 6415             Element '%1' - unsupported transport '%2'
 6416             Element '%1' - unrecognized %2 element '%3'
 6417             Element '%1' - message '%2' type or element attribute must be specified for a part.
 6418             Element '%1' - message '%2' parameters not found for literal encoding
 6419             Element '%1' - inconsistent %2 for operation %3
 6420             Element '%1' - parts list contains an undefined or multiply defined part name.
 6421             Element '%1' - %2 ParameterOrder parameter count mismatch
 6422             WSDL namespace is not defined for targetNamespace = %1.
 6423             SOAP namespace is not defined for targetNamespace = %1.
 6424             Element '%1' - message '%2' both type and element attribute may not be specified for a
                  part.
 6425             Element '%1' - message '%2' Message Style must be used for document style message
                  with 2 or more parts.
 6426             Both the Client and the Service class cannot be in the same package: %1.
 6427             Client class not defined: %1.
 6428             Cannot define configuration for client class, %1, since it is already configured by %2 which
                  configures multiple classes.
 6429             The specified WSDL must have exactly one port which will supply the policy for %1.
 6440             Unexpected root element, %1, in %SOAP.Configuration XData block,%2.
 6441             Unexpected element, %1, in %3 XData block, %2.
 6442             Duplicate name of %SOAP.Configuration XData block: %1.
 6443             Duplicate configuration name, %1, for SOAP class, %2.
 6444             SOAP class name not specified for service in configuration: %1.
 6445             Method name not specified for method element in configuration: %1.



InterSystems Error Reference                                                                                 71
General Error Messages


 Error Code       Description
 6446             Duplicate method name, %1, in configuration, %2.
 6447             Unexpected element, %1, from WS-Policy namespace in %SOAP.Configuration XData
                  block, %2.
 6448             Name attribute of configuration, %1, does not match name of %SOAP.Configuration XData
                  block, %2.
 6449             Invalid SOAP configuration class name %1.
 6450             Configuration not found, %1, in %SOAP.Configuration class, %2.
 6451             A policy assertion, %1, may not have text children in %SOAP.Configuration class, %2.
 6452             Internal error while analyzing policy in configuration %1: %2.
 6453             Unsupported assertion namespace "%1", assertion=%2, configuration=%3.
 6454             No supported policy alternative in configuration %1.
 6455             Policy assertion %1 is not supported in configuration %2.
 6456             Policy assertion %1 is not recognized in configuration %2.
 6457             Policy assertion %1 may not have wsp:Policy child element in configuration %2.
 6458             Policy assertion %1 has unsupported parameter %2 in configuration %3.
 6459             Policy assertion %1 Header parameter requires Namespace attribute in configuration %2.
 6460             Policy assertion %1 Header parameter requires Name attribute in configuration %2.
 6461             Policy assertion %1 does not support nested policy assertion %2 in configuration %3.
 6462             Policy assertion %1 requires a nested policy in configuration %2.
 6463             Policy assertion %1 is not in expected namespace in configuration %2.
 6464             Only one %1 may be specified in configuration %2.
 6465             No assertion parameters are supported for token %1 in configuration %2.
 6466             Unsupported token %1 in %2 assertion in configuration %3.
 6467             %1 requires AlgorithmSuite assertion in configuration %2.
 6468             Token %1 format error in configuration %2.
 6469             Unexpected value for sp:IncludeToken %1 in configuration %2.
 6470             %1 requires one %2 token in configuration %3.
 6471             %1 requires at least one token in configuration %2.
 6472             %1 element is not in expected namespace, in %3 XData block, %2.
 6473             Unexpected attribute %1 in %2 element in configuration %3.
 6474             Both cfg:FindField and cfg:FindValue must be specified if either is specified for sp:X509Token
                  in configuration %1.
 6475             Unexpected value of cfg:FindField, %1, for sp:X509Token in configuration %2.
 6476             No local URI attribute for wsp:PolicyReference element in configuration %1.




72                                                                                   InterSystems Error Reference
                                                                                         Error Codes 6000 to 6999


 Error Code       Description
 6477             URI attribute, %1, for wsp:PolicyReference element does not reference a policy in
                  configuration %2.
 6478             sp:Username token is not valid for a supporting token with sp:SignedParts or
                  sp:EncryptedParts assertion.
 6479             cfg:wsdlElement="%1" does not specify a valid value for wsdlElement in configuration %2.
 6480             Method name not specified for method element in parameters XData in class: %1.
 6481             Method named %1 in method element of parameters does not exist in class %2.
 6482             Header element requires %1 attribute in class %2.
 6483             Conflicting DerivedKey assertions for %1 in configuration %2.
 6484             Action element requires non-empty value in class %1.
 6485             Only one SecurityContextToken may be specified for %1 in any alternative in configuration
                  %2.
 6486             Value of cfg:Lifetime, %1, for sp:SecureConversationToken must be in hours as a floating
                  point number in configuration %2.
 6487             Value of %1 parameter, %2, is not of expected type, %3, in configuration %4.
 6501             Unrecognized XSD type '%1'
 6502             Cannot determine corresponding class type for specified XSD type '%1'
 6503             Lock timeout. XML projection failed for class '%1' trying to lock '%2' with timeout '%3'
 6504             XML projection of an array of streams is not supported in property: %1.
 6505             SOAP session failure: new session created since session specified in session header was
                  not found.
 6506             No schema definition was found in specified file.
 6507             Invalid value for XMLNILNOOBJECT, %1.
 6550             Cannot open QR Code %1 file %2.
 6551             Cannot open QR Code exception file %1.
 6552             QR Code file %1 not created.
 6553             Invalid correction level %1, must be one of 'L', 'M', 'Q', or 'H'.
 6554             QR Code not supported on this platform.
 6555             QR Code invalid Dimension parameter %1.
 6556             QR Code Correction Level %1 supports string length of %2, size of string is %3.
 6557             The QRCode string %1 may not have been correctly escaped. The partial QR Code is in
                  the file %2.

Table 1–19: General Error Codes - 6600 to 6799

 Error Code       Description
 6601             BeanName is required.




InterSystems Error Reference                                                                                  73
General Error Messages


 Error Code       Description
 6602             RootDir is required.
 6603             ClassPath is required.
 6604             App Server Home is required. (APPSERVERHOME is "".)
 6605             Java Home is required.
 6606             Path is required.
 6607             ServerType is required.
 6608             We only support QuickStatement interface.
 6609             %1 is neither Persistent nor a Session Bean. ClassList is %2. ClassList must contain only
                  Persistent or Session Bean classes.
 6610             ClassList must be specified in projection or in calling this routine. ClassList must not be
                  empty.
 6611             This server whose name is %1 is not defined in the EJB Wizard. Please pick one of
                  WEBLOGIC, WEBLOGIC7, WEBLOGIC8, JBOSS, JBOSS3 or PRAMATI. JBOSS generates
                  code for JBOSS 2.4.3 and 2.4.4 and JBOSS3 generates code for JBoss 3.X. For WebLogic
                  6.1 use WEBLOGIC, for WebLogic 7.0 use WEBLOGIC7, and for WEBLOGIC 8.1 use
                  WEBLOGIC8. Please read your release notes for the list of supported servers.
 6612             CMP generator for Class=%1 failed: CMP generation is only supported on classes with
                  primary keys.
 6613             Common CPP output not set
 6614             getClassMethodsError: %1 className=%2
 6615             getClassPropertiesError: %1 className=%2
 6616             getClassQueriesError: %1 className=%2
 6617             getEJBClassNameError: %1 className=%2
 6618             getEJBClassNameError: %1
 6619             Common output not set
 6620             Common language generator object not set
 6621             EJB Easy projection is only supported on Windows. On UNIX® use EJB.
 6622             PersistenceType must be BMP or CMP.
 6623             CMP generation for Class=%1 failed. CMP generation can only be done if all required
                  properties are CMP compatible. Property=%2 is not CMP compatible.
 6624             EJB generation for ClassList=%1 failed. ClassList must include at least one persistent class
                  that is not a session bean.
 6625             WebLogic requires a testable to be defined to test connection existence in connection pooling.
 6626             Class %1 is not projectible. Projection is aborting. If the super of a class is not a
                  %RegisteredObject and all the methods of the super are server-only and the class has some
                  methods that are not class methods then it is not projectible. If the super of a class is null
                  then the class must contain only class methods.




74                                                                                   InterSystems Error Reference
                                                                                            Error Codes 6000 to 6999


 Error Code       Description
 6627             %1 is not a valid value for TRANSACTIONISOLATION valid values are
                  TRANSACTION_READ_UNCOMMITTED, and TRANSACTION_READ_COMMITTED.
 6628             Class %1 is not projectible. Projection is aborting. For a class to be projectible all methods
                  in the class must have the same signature in the left-most super. There is a conflict on
                  Method %2.
 6629             Class %1 is not projectible. Projection is aborting. For a class to be projectible all properties
                  in the class must have the same declaration in the left-most super. There is a conflict on
                  Property %2.
 6630             Class %1 is not projectible. Projection is aborting. For a class to be projectible its left-most
                  super %2 must be a %Library.RegisteredObject or class %1 must be a "static" class: a class
                  that has only class methods and no properties or instance methods.
 6631             Persistent Class %1 is not projectible. Projection is aborting. For a persistent class to be
                  projectible its left-most super %2 must be a %Library.Persistent.
 6632             Class %1 is not up-to-date. Please recompile the class and try again.
 6633             Class %1 is not projectible to EJB. Projection is aborting. For a class to be projectible all its
                  child tables must be valid. Child table %2 is not valid.
 6634             getClientClassDefError: %1 className=%2
 6635             QueryGetInfoError: %1, className=%2, query=%3
 6636             Class %1 is a datatype and cannot be projected
 6637             It is not valid for a format flag to contain / (back-slash). The invalid format flag is %1.
 6638             The List that %1 is attempting to return on Class %2 is too big
 6639             getCountMethodsError: %1 className=%2
 6640             getCountPropertiesError: %1 className=%2
 6641             getCountQueriesError: %1 className=%2
 6642             Aborting EJB Projection of %1 because property %2 is required and yet is not supported by
                  the EJB Wizard.
 6643             Class %1 is not exportable. It should extend %Compiler.LG.Exportable to be exportable.
 6645             %1: %2 className=%3
 6646             JAVAPACKAGE parameter conflicts with clientname parameter. JAVAPACKAGE is %1 and
                  clientname parameter is %2
 6647             Server side code generation is not available. Please use cpp_generator for client side code
                  generation.
 6648             Cannot generate code for class %1 because depends on class %2 which has a problem in
                  its generation.
 6649             Cannot generate code for class %1 because depends on class %2 which cannot be generated
                  for reason: %3.
 6650             Cannot generate code for class %1 because depends on class %2 which is serveronly class.
 6651             Skipping generation of class %1 because it depends on something that is not projectable
                  and is not serveronly. Here is more information. %2



InterSystems Error Reference                                                                                      75
General Error Messages


 Error Code       Description
 6653             Class %1 has an empty JavaBlock
 6654             Class %1 has more than one JavaBlock
 6655             Cannot project %1 because super %2 is collection.
 6656             Cannot project %1 as POJO because method %2 has ByRef argument.
 6657             Cannot project %1 because method %2 has abstract stream in return type or argument type.
 6658             Cannot project %1 because left-most super %2 is a stream.
 6659             Timed out waiting for lock on cache for class %1
 6660             QueryGetParamInfoEror: %1, className=%2, query=%3
 6701             Already Attached
 6702             Missing PID value
 6703             Invalid PID value
 6704             Target has exited debugger
 6705             Could not issue break to target
 6706             Error attaching to CSP server: %1
 6707             Not Attached
 6708             Error unattaching from target
 6709             Target not stopped
 6710             Could not attach to target
 6711             Invalid debugger target: %1
 6712             Unable to find mapping for breakpoint '%1'
 6713             Start target failed
 6714             Debugger Error: %1
 6715             Invalid PID value '%1'
 6716             Target already in debug mode
 6717             Target in signon mode

Table 1–20: General Error Codes - 6800 to 6999

 Error Code       Description
 6901             XSLT XML Transformer Error: %1
 6902             Error Handler is NOT a subclass of %XML.XSLT.ErrorHandler
 6903             Output Stream is NOT a subclass of %BinaryStream
 6904             Result Handler is NOT a subclass of %XML.XPATH.ResultHandler
 6905             Input Stream is NOT a subclass of %BinaryStream
 6906             %New() should NOT be called directly, use 'Create...' factory methods




76                                                                               InterSystems Error Reference
                                                                                    Error Codes 7000 to 7999




1.6 Error Codes 7000 to 7999
Table 1–21: General Error Codes - 7000 to 7199

 Error Code       Description
 7001             TSQL compiler error: %1
 7002             TSQL: %1
 7003             ISQL compiler error: %1
 7004             ISQL: %1
 7005             TSQL querybuilder expected "%1" (got "%2")
 7006             You can't assign the result of a query to a variable
 7011             TSQL language mode requires procedureblock: '%1::%2'
 7050             Error opening class definition for "%1": "%2"
 7051             Unrecognized input: "%1"
 7052             Read: Missing "]"
 7053             Read: Missing quote at end of string
 7054             Read: Syntax error at or around "%1"
 7055             RunQuery: Procedure "%1" is not a query
 7056             RunQuery: Argument "%1" has already been passed (as "%2")
 7101             Specified Seek position (%1) is past end of file (%2)
 7102             FileStream Mode %1 does not include Read mode setting
 7103             FileStream Mode %1 does not include Write mode setting
 7104             No delegated input stream is bound to this MetaStream
 7105             No Translation Table mapping found for CharEncoding '%1'
 7106             IO Stream class %1 is not closeable
 7107             Delegated IO Stream class %1 is not Seekable
 7108             Object of type %1 is not a Stream object
 7109             Timed out after %2 seconds trying to open stream '%1'
 7110             Timed out after %2 seconds listening for an incoming connection on socket '%1'
 7150             Telnet Option %1 is not set
 7151             Error in telnet handshake; state=%1,current byte=%2
 7152             Timeout attempting telnet initialization handshake

Table 1–22: General Error Codes - 7200 to 7399

 Error Code        Description
 7200              Datatype value '%1' failed IsValidDT validation



InterSystems Error Reference                                                                             77
General Error Messages


 Error Code       Description
 7201             Datatype value '%1' length longer than MAXLEN allowed of %2
 7202             Datatype value '%1' length less than MINLEN allowed of %2
 7203             Datatype value '%1' greater than MAXVAL allowed of %2
 7204             Datatype value '%1' less than MINVAL allowed of %2
 7205             Datatype value '%1' not in VALUELIST '%2'
 7206             Datatype value '%1' is not a valid boolean
 7207             Datatype value '%1' is not a valid number
 7208             Datatype value '%1' is not a valid timestamp format
 7209             Datatype value '%1' does not match PATTERN '%2'
 7210             Datatype value '%1' contains invalid character/s '%2'
 7211             Datatype value '%1' is not a valid duration
 7212             Datatype value '%1' is not a valid uniqueidentifier/GUID format
 7300             Failed to open logfile %1 for output
 7301             Backup.General.ExternalFreeze cannot run with switch 10 or 13 already set
 7302             Failed to locate TCP information for all cluster members
 7303             Failed to switch journal files on other cluster members
 7304             Failed to switch journal file. Status = %1
 7305             Failed to switch local journal file. Status = %1
 7306             System failed to quiesce
 7307             Failed to place journal marker
 7308             Task %1 does not exist
 7309             Backup is currently running
 7310             Failed to open task %1
 7311             No backup recorded for task %1
 7312             Unknown platform in $zversion(1)
 7313             Error building list of log files: %1
 7314             Error building list of tasks: %1
 7315             Unable to determine base directory from: %1
 7316             Unable to create directory for storing the log file: %1
 7317             Unable to determine base directory for: %1
 7318             Unable to create backup output directory: %1
 7319             Failed to set up list of databases for backup
 7320             Unknown backup type: %1
 7321             Database %1 does not exist



78                                                                                  InterSystems Error Reference
                                                                                      Error Codes 7000 to 7999


 Error Code        Description
 7322              IRISTEMP cannot be included in a backup
 7323              Error building list of databases: %1
 7324              %1 is not part of the current backup list
 7325              Failed to start backup job
 7326              Failed to initialize IJC Device: %1
 7327              BACKUP^DBACK returned failure
 7328              Cannot modify a built-in system task
 7329              Invalid backup type: %1
 7330              Taskname not specified as argument to %New
 7331              Taskname must contain only alphanumeric characters
 7332              Task already exists
 7333              No backup volume specified
 7334              Unable to read file, Backup or Restore is in progress
 7335              Cannot open backup volume '%1'
 7336              This is not a %1 Backup File
 7337              Request to suspend write daemon cleared

Table 1–23: General Error Codes - 7400 to 7599

 Error Code        Description
 7400              TASKMGR is already running
 7401              Unable to open task (%1)
 7402              Selected User (%1) is not enabled
 7403              Task (%1) is not scheduled to run
 7404              Multiple times per day but DailyIncrement is 0
 7405              Operation requires %1 to change the task username
 7406              User does not exist (RunAsUser %1)
 7408              DailyEndTime must be after DailyStartTime
 7409              EndDate must be after StartDate
 7410              TimePeriodDay must be null or contain values 1 through 7 (%1) is not valid
 7411              Output Directory does not exist
 7412              Filename is not valid
 7413              Task Class is required but is null
 7414              Task Class (%1) does not exist in %2
 7415              Could not find task to delete




InterSystems Error Reference                                                                               79
General Error Messages


 Error Code       Description
 7416             Unknown Scheduling problem, New Time = Last Time
 7418             Failed to mark task as suspended (SQLCODE=%1)
 7419             Failed to mark task as resumed (SQLCODE=%1)
 7420             Invalid Suspend Flag (FLAG=%1)
 7421             Unable to send mail. The Mail Server is not defined.
 7422             Unable to send mail. No email addresses are defined.
 7423             Failed to update configuration for (%1) with error %2
 7424             Failed to send email (%1)
 7425             Unable to delete task, clear all run after references first
 7426             At least 1 Run day Monday - Sunday must be selected
 7427             Task repeating offset must be a positive integer
 7428             Invalid day of the month (%1)
 7429             Invalid weekly offset use 1 - 5
 7430             Invalid frequency time (DailyFrequencyTime) use 0 or 1
 7431             Run After Task value is required
 7432             Start Date and Time must be after the current date and time
 7450             Task job running
 7451             Task job untrapped error (%1)
 7452             Task job setup error (%1)
 7453             Task job timeout error
 7454             Task job post process error (%1)
 7460             Must enter a tape device.
 7461             Enter a valid number of days
 7500             SSH %3 Error '%1': %2

Table 1–24: General Error Codes - 7600 to 7799

 Error Code       Description
 7600             Invalid global format to import from
 7601             Unknown package format type: %1
 7602             Exported on version '%1' but this machine on version '%2' so unable to import
 7603             Delimited id's setting on exported version %1 on current system %2 so unable to import
 7604             Global node collision with class '%1'
 7605             Unable to deploy routine '%1' with no source (as specified by removesource parameter) as
                  there is no OBJ code
 7606             Global node already in use '%1'



80                                                                               InterSystems Error Reference
                                                                                        Error Codes 7000 to 7999


 Error Code        Description
 7607              Original data value at %1=%2 new value %3
 7608              New data has %1=%2 but in original global this does not exist
 7609              File '%1' does not contain an exported deployment
 7610              Signature on code '%1' incorrect so this item is not original released version
 7700              Invalid manifest specification '%1'
 7701              Invalid expression '%1': %2
 7702              Invalid special variable '%1'
 7703              Parser error parsing '%1' at offset %2: '%3'

Table 1–25: General Error Codes - 7800 to 7999

 Error Code        Description
 7800              Unable to start any worker jobs
 7801              Another job is modifying worker numbers
 7802              Worker job/s unexpectedly shut down
 7803              Job complete queue unexpectedly closed
 7804              Lock table full, aborting
 7805              Unable to create workers when we already have work being processed
 7806              Unable to signal all workers
 7807              Not all worker jobs started, was attempting to start '%1'
 7808              Can not count worker jobs because unable to get a lock
 7809              Unable to create workers in a worker process
 7810              Work queue API being called using an invalid queue name '%1' for $job='%2'
 7811              Unable to find classname for '%1' call
 7812              Work queue unexpectedly removed, shutting down.
 7813              Work queue received bad response from worker, shutting down.
 7814              Worker jobs not processing any work, so process appears to be stalled, shutting down.
 7815              Work queue not initialized, either due to a previous error causing a shutdown, or no call to
                   Initialize before queuing work.
 7850              Class '%1' is classtype=system but this does not support any '%2' members
 7851              Classtype=system classes can only inherit from other classtype=system classes. Super
                   class path '%1'.
 7852              Classtype='%1' is not a valid classtype. Valid values are '%2'.
 7853              Classtype=system classes do not support generator methods '%1'.
 7854              C++ method '%1' in class '%2' can not support alias methods associated with property '%3'.
 7855              C++ method '%1' in class '%2' returntype not supported '%3'.



InterSystems Error Reference                                                                                  81
General Error Messages


 Error Code       Description
 7856             C++ method '%1' in class '%2' argument type not supported '%3'.
 7900             Service '%1' not enabled for application '%2'
 7901             Second Factor Login Failed for application '%1'
 7902             OnApplication callback aborted the application change and the login process
 7903             Second Factor cancelled by user
 7904             Can not call on class that is not subclass of %ZEN.Mobile.basePage and not mobile enabled
                  '%1'
 7905             Invalid method to call on mobile page '%1'
 7906             Session event callback prevented session from being created.
 7950             The WebSocket Read operation has timed out
 7951             The Client has closed the WebSocket




1.7 Error Codes 8000 to 8999
Table 1–26: General Error Codes - 8000 to 8199

 Error Code       Description
 8000             Domain %1 already exists
 8001             Invalid SortField %1
 8002             Global name '%1' is reserved
 8003             Failed to process source
 8004             Failed to acquire lock on domain %1
 8005             External Id not found for internal id %1
 8006             Configuration %1 does not exist
 8007             Failed to initialize DirectInput
 8008             Failed to initialize Indexer
 8009             Failed to load KB %1
 8010             Failed to load LB %1
 8011             KB %1 Not Found
 8012             %1: Caught Error %2
 8013             Lister alias '%1' already in use by class %2 in this namespace
 8014             Failed to reset %1 from location %2
 8015             Nothing to process
 8016             Configuration with id %1 does not exist




82                                                                                 InterSystems Error Reference
                                                                               Error Codes 8000 to 8999


 Error Code        Description
 8017              Domain name and id do not match
 8018              Domain %1 does not exist
 8019              Domain %1 is corrupt
 8020              Domain %1 must be opened in namespace %2
 8021              Domain with id %1 does not exist
 8022              Internal datasource error
 8023              Failed to delete source %1
 8024              Invalid Type: %1
 8025              Missing Source Id
 8026              Missing Source Field %1 in source %2
 8027              Missing Continuation Key in source %1
 8028              Missing Crc Field %1 in source %2
 8029              Missing Sentence Field %1 in source %2
 8030              Missing Relation Frequency in source %2
 8031              Missing %1 Attribute in source %2
 8032              Search string must be at least %1 characters long
 8033              Source not specified
 8034              Source does not exist (srcId: %1)
 8035              Source does not exist (extId: %1)
 8036              No metadata field specified
 8037              Metadata field does not exist (field ID: %1)
 8038              Metadata field does not exist (field name: %1)
 8039              Supplied metadata value '%1' not allowed for MD Domain %2
 8040              Metadata field '%1' already exists in this domain
 8041              Dictionary %1 does not exist
 8042              Dictionary item %1 does not exist
 8043              Dictionary term %1 does not exist
 8044              Dictionary element %1 does not exist
 8045              Dictionary item with URI '%1' already exists
 8046              Dictionary format class %1 does not exist
 8047              Internal error indexing dictionary terms
 8048              Metadata operator '%1' not supported for field %2
 8049              Metadata LOV %1 does not exist
 8050              Failed to convert buffer text to lower case



InterSystems Error Reference                                                                        83
General Error Messages


 Error Code       Description
 8051             Failed to create encoding object for %1
 8052             Failed to transcode string
 8053             Invalid indexer id specified
 8054             Unknown language id specified
 8055             Invalid object id specified
 8056             Failed to open file %1
 8057             Cannot index with no KB loaded
 8058             Indexer returned a data item larger than the maximum supported
 8059             Indexer failed while attempting to return output data
 8060             An invalid data processing object was passed to the indexer
 8061             Configuration %1 exists
 8062             Languages must be in $list format
 8063             Language %1 does not exist
 8064             Failed to load library: %1
 8065             Unable to instantiate iKnow Engine
 8066             Failed to lock iKnow Indexer
 8067             Can't open Lister id: %1
 8068             Ngram search is not enabled for this domain
 8069             Cannot overwrite an existing MD value in batch mode
 8070             Supplied metadata value count (%1) does not correspond to key count (%2)
 8071             Unable to open Converter id: %1
 8072             Unable to open Processor id: %1
 8073             There are still lists scheduled for a Batch load. Process them first or call Loader.Reset()
 8074             Indexer process failed
 8075             Failed to create Loader instance
 8076             Failed to split External ID: %1
 8077             Unknown Lister class or alias: %1
 8078             BuildExtIdFromName() should be called for an implementing Lister class, not the abstract
                  one
 8079             Match ID does not exist: %1
 8080             Configuration ID (%1) and name (%2) do not match
 8081             Missing bitstring
 8082             Bad $List in %1
 8083             Failed to build: %1



84                                                                                  InterSystems Error Reference
                                                                                         Error Codes 8000 to 8999


 Error Code        Description
 8084              Failed to start any worker processes
 8085              Only a single Virtual Source ID is supported for this query
 8086              Virtual Source %1 not found in this domain
 8087              Dictionary element value is too long: %1
 8088              Group with id %1 does not exist
 8089              Source with external ID already exists: %1
 8090              String too long: %1
 8091              SkipList with name '%1' already exists
 8092              Dictionary with name '%1' already exists
 8093              SkipList with id %1 does not exist
 8094              Failed to load the requested iKnow language data. This may be due to an insufficiently large
                   gmheap setting.
 8095              Cannot set domain parameter '%1' (either unknown or not user-configurable)
 8096              Domain must be empty (no sources or entities) before parameter '%1' can be changed.
 8097              iKnow is not available for this license
 8098              Illegal result parameter value: %1 (should be either empty for output var or start with ^ for
                   global output)
 8099              STORE error while compiling query result. Either decrease page size or use global output.
 8100              Gateway Request Failed: %1
 8101              Gateway Request Exception: %1
 8102              Gateway Request No Data: %1
 8103              Gateway Request Timedout: %1

Table 1–27: General Error Codes - 8200 to 8299

 Error Code        Description
 8200              Maximum concept length must be positive.
 8201              User has no permissions to write to the database
 8202              Missing Lister Parameter at index %1 (%2)
 8203              Invalid Lister Parameter at index %1 (%2): "%3"
 8204              No Lister registered in this Loader instance. Use Loader.SetLister() first
 8205              There is no User Dictionary with name "%1
 8206              There is no User Dictionary with id %1
 8207              User Dictionary with name "%1" already exists
 8208              Invalid filter spec: "%1”
 8209              Missing Relation Dominance in source %1



InterSystems Error Reference                                                                                       85
General Error Messages


 Error Code       Description
 8210             Missing Proximity Field %1 in source %2
 8211             %1 is not a valid Converter class
 8212             %1 is not a valid Processor class
 8213             Missing Concept Dominance in source %1
 8214             Missing %1 Field %2 in source %3
 8215             The supplied Matching Profile has not been saved since it was last modified
 8216             A Matching Profile named "%1" does not exist in domain %2
 8217             No sources can be added to a DeepSee-managed domain other than through DeepSee
 8218             A Matching Profile named "%1" already exists
 8219             "%1" is not a valid Matching Profile name (no colons allowed)
 8220             This feature is only supported for domains in versions %1 or above
 8221             This parameter has already been set to '%1' at the system level. Use
                  UnsetSystemParameter() to clear it first
 8222             Failed to acquire lock
 8223             %1 object is modified, please save first.
 8224             Domain parameter '%1' can only be changed at the namespace level if no non-empty
                  domains exist in this namespace.
 8225             Cannot change domain parameter '%1' to '%2'. Illegal value.
 8226             Metric with ID %1 does not exist
 8227             Metric '%1' does not exist
 8228             Metric target '%1' with ID %2 does not exist
 8229             Metric '%1' does not support target '%2'
 8230             Domain %1 is managed by %2 and cannot be updated directly.
 8231             %1 %2 is managed by %3 and cannot be updated directly.
 8232             Internal error in iKnow Engine: %1
 8233             At least one of the data structures required to resolve this query is not build or up-to-date.
                  Please review your domain's build flags (%1).
 8234             Failed to load iKnow language model. File: %1, Line: %2, '%3'
 8235             The "system" domain only supports Virtual Sources
 8236             This operation is not supported in the "system" domain
 8237             The iKnow engine could not allocate enough memory to process the current document.
 8238             Stemming is not enabled for this domain.
 8239             Search string syntax error: brackets mismatch




86                                                                                   InterSystems Error Reference
                                                                                Error Codes 8000 to 8999


Table 1–28: General Error Codes - 8300 to 8599

 Error Code        Description
 8300              No Pattern Argument
 8301              ICU Regular Expression Error Number %1 (0x%2)
 8310              Internal error in ICU regular expression library
 8311              Syntax error in regexp pattern
 8312              RegexMatcher in invalid state for requested operation
 8313              Unrecognized backslash escape sequence in pattern
 8314              Incorrect Unicode property
 8315              Use of regexp feature that is not yet implemented
 8316              Incorrectly nested parentheses in regexp pattern
 8317              Decimal number is too large for ICU library
 8318              Error in {min,max} interval
 8319              In {min,max}, max is less than min
 8320              Back-reference to a non-existent capture group
 8321              Invalid value for match mode flags
 8322              Look-Behind pattern matches must have a bounded maximum length
 8323              Regexps cannot have UnicodeSets containing strings
 8324              Octal character constant cannot be greater than 0377
 8325              Missing closing bracket on a bracket expression
 8326              In a character range [x-y], x is greater than y
 8327              Regular expression backtrack stack overflow
 8328              Maximum allowed match time exceeded
 8329              Matching operation aborted by user callback fn
 8351              Index, such as group number, is out of bounds
 8352              Illegal argument, such as empty string for Pattern
 8400              No file with GUID '%1'
 8401              No file with name '%1'
 8402              No file with name '%1' in '%2'
 8403              Multiple files with name '%1'
 8404              Multiple files with name '%1' in '%2'
 8405              No file prior to '%1'
 8406              No file prior to '%1' with prefix '%2'
 8500              Error: '%1' in Line %2 at offset %3 (%4)
 8501              Error: '%1' in Line %2 at offset %3 (%4)



InterSystems Error Reference                                                                         87
General Error Messages


Table 1–29: General Error Codes - 8600 to 8899

 Error Code       Description
 8600             Cannot return application license, session out of scope
 8601             Invalid licensed application name
 8602             Cannot open license key file '%1'.
 8603             Not a valid license key file.
 8604             License key has expired.
 8605             License key is invalid.
 8606             License key invalid for product version.
 8607             This system (%1 Cores) exceeds permitted CPU core limit (%2) for IRIS.
 8608             This system (%1 Cores) exceeds permitted CPU core limit (%2) for IRIS.
 8609             License key platform (%1) invalid for this platform (%2).
 8610             License keys are not accepted on a Single User (SU) platform.
 8611             Licensed Application (%1), Keyword (%2) value (%3) is not a number.
 8612             No license for Application (%1).
 8613             Application connection count overflowed for user.
 8700             XData Missing - class: %1 name: %2
 8701             Dispatch Map Schema Validation Failed
 8800             The notification is invalid
 8801             The notification protocol '%1' is not supported
 8802             The device token is invalid
 8803             The APNS connection to %1 timed out after %2s
 8804             The push notification attempt failed
 8805             The push notification attempt failed: %1
 8806             Invalid response from the APNS: %1
 8807             Connection to %1:%2 failed
 8808             The APNS terminated the connection
 8809             Connection to %1 failed
 8810             Unexpected HTTP status %1: '%2'
 8812             The push notification attempt failed
 8813             The push notification attempt failed: %1




88                                                                                InterSystems Error Reference
                                                                                          Error Codes 9000 to 9999




1.8 Error Codes 9000 to 9999
Table 1–30: General Error Codes - 9000 to 9299

 Error Code        Description
 9000              Class (%1) is not up to date.
 9001              Name: (%1) already exists.
 9002              Class (%1) is generated.
 9003              Class (%1) cannot be opened.
 9004              Class (%1), method (%2) cannot be parsed.
 9005              Class (%1) is deployed.
 9100              Extent size must be a positive number '%1'.
 9101              Global name '%1' for '%2' is too long, must be no more than %3 characters in length. (See
                   Incompatibility History)
 9200              %1
 9201              "%1" is not a valid option.
 9202              "%1" is not a valid value for ImportTableExists option.
 9203              Datatype "%1" is not supported for import columns.
 9204              Table %1 already exists.
 9205              Cannot acquire lock on table name "%1" in namespace %2.
 9206              Syntax error in import table column specification.
 9207              Syntax error: do not use keyword "AS" with SQL datatype name "%1".
 9208              Datatype parameter "%1" is not supported.
 9209              Datatype parameter "%1" is not supported for datatype %2.
 9210              Cardinality "%1" is not supported.
 9211              Time format %1 is not supported.
 9212              Specified inverse relationship name "%1" conflicts with an existing property of class %2.
 9213              Must specify inverse relationship name for relationship property %1.
 9214              Option "%1" cannot be set at the connection level.
 9215              Must connect before creating MapReduceResult.
 9216              Must connect before executing command.
 9217              Must connect before executing command.
 9218              Cannot acquire lock needed to synchronize class %1.
 9219              Cannot acquire lock needed to rollback checkpoint for class %1.
 9220              No information available about synchronization job with ID %1.




InterSystems Error Reference                                                                                   89
General Error Messages


Table 1–31: General Error Codes - 9300 to 9400

 Error Code       Description
 9300             Shard %1:%2:%3 returned error
 9301             %1 shards returned errors
 9302             Transaction with id "%1" has already been started
 9303             Invalid transaction state transition: %1 to %2
 9304             Invalid transaction state transition: %1 to %2
 9305             Cannot open ECP connection to host %1 port %2
 9306             Attempt to close ECP connection to host %1 port %2 failed
 9307             Failed to create semaphore %1
 9308             Cannot open TCP/IP connection to host %1 port %2
 9309             Failed to delete semaphore %1
 9310             Requested operation not supported for storage model %1
 9311             Parallel load of %1 is already in progress
 9312             %1 is not a sharded table
 9313             No compiled shard-local class found for %1
 9314             Class %1 has %2 storage definitions
 9315             Shard namespace %1 on host %2 is mapped to remote host %3
 9316             Cannot login user %1 to shard server at host %2, port %3
 9317             Timed out waiting for lock to update mappings
 9318             Connection to host %1 port %2 shard namespace %3 was reset, try operation again
 9319             Current namespace %1 has no shards configured
 9320             Current namespace %1 is not a shard
 9321             Instance is not current primary failover member
 9322             Namespace %1 has no shard %2
 9323             No app server is assigned to shard %1 with hostname %2 port %3 namespace %4
 9324             Invalid SQL statement
 9325             Error allocating Id range, SQLCODE %d, SQL message: %2
 9326             Cannot add shard while tables with user-defined shard keys exist
 9327             Could not activate new shard%1, must call ActivateNewShards method
 9328             Requested operation must be performed on host on which globals database of master
                  namespace %1 resides
 9329             Cannot create shard routines database path %1, internal error %2
 9330             Cannot create shard routines database, .DAT database file already exists in %1
 9331             Cannot create shard routine namespace %1, a namespace with that name already exists



90                                                                               InterSystems Error Reference
                                                                                      Error Codes 9000 to 9999


 Error Code       Description
 9332             Cannot create shard routines database %1, a database with that name already exists
 9333             No path defined for shard routines database %1
 9334             No shard routine namespace defined for master namespace %1
 9335             No shard routine namespace defined for master namespace %1
 9336             Drop table: %1.%DeleteExtent() failed, %2 rows not deleted
 9337             Authentication error: %1
 9338             %1 is not enabled on shard %2:%3:%4
 9339             Shard %1:%2:%3 does not allow incoming connections from IP address %4
 9340             Hostname %1 cannot be translated to an IP address
 9341             Message out of sequence, expected message code %1, got message code %2
 9342             IP address %1 specified in connect request does not match startup IP address %2
 9343             No hostname or IP address can be found for this system
 9344             Master namespace %1 on primary mirror failover member is not mirrored
 9345             Query shard cannot be mirrored
 9346             Cannot deassign data shard while sharded tables exist
 9347             Namespace %1 has no shard with hostname %2, port %3 namespace %4
 9348             Shard count %1 for entity %2 is greater than total shard count %3
 9349             Could not clean up deassigned shard %1:%2:%3
 9350             Shard %1:%2:%3 has already been assigned
 9351             Shard %1:%2:%3 has already been assigned to another master (%4:%5:%6))
 9352             Shard %1 in namespace %2 has no query shard %3
 9353             Namespace %1 has no shards configured
 9354             Shard %1 failed verification
 9355             %1 shards failed verification
 9356             Query shard %1 of shard %2 failed verification
 9357             %1 query shards failed verification
 9358             Internal error: unrecognized message code %1
 9359             MaxServers setting %1 too low, %2 needed
 9360             MaxServerConn setting %1 too low, %2 needed
 9361             MaxServers setting %1 and MaxServerConn setting %2 both too low, %3 needed
 9362             Query shard mapped to wrong directory %1, should be %2
 9363             Query shard mapped to wrong instance %1:%2, should be %3:%4
 9364             Shard assigned with backup member address %1:%2 is not actually mirrored




InterSystems Error Reference                                                                               91
General Error Messages


 Error Code       Description
 9365             Shard assigned with backup member address %1:%2 is actually configured with backup
                  member address %3:%4
 9366             %1 is not a valid option
 9367             %1 is not a valid value for option %2
 9368             Master namespace %1:%2:%3 cannot be assigned as a shard
 9369             Globals database for mirrored shard %1:%2:%3 must be mirrored
 9370             Previous database for shard %1:%2:%3 must be dismounted before executing ReassignShard
 9371             Sharding is not enabled in this version
 9374             Timed out waiting for reply from job %1 on shard %2 %3:%4:%5
 9375             Cannot read valid reply from shard %1, port number %2 may be incorrect
 9376             Sharding service is not enabled on shard server
 9377             ECP service is not enabled
 9378             Instance requires restart because CPF file has been modified and not yet activated
 9379             Current instance of version %1 cannot access sharded cluster of version %2
 9380             Shard %1:%2:%3 version %4 cannot be assigned to sharded cluster of version %5
 9381             Instance has been upgraded, $SYSTEM.Sharding.Upgrade() must be run in master
                  namespace




1.9 Error Codes 15000 and Higher
Table 1–32: General Error Codes - 15000 and Higher

 Error Code       Description
 15414            The type of the index key property, '%3' in class '%1', index '%2', is not a serial type.
 15511            SQL Map '%1' is conditional but condition is null.
 15555            Incorrect string format in class %1, '%2' = %3.
 15808            $$$iFindIndexIdKeyError
 16000            Line: '%1' Offset: '%2'.
 16001            Couldn't open document '%1'.
 16002            Invalid JSON Content.
 16003            HTTP POST has no content.
 16004            Unknown request type '%1'.
 16005            Document '%1' does NOT exist.
 16006            Document '%1' name is invalid.
 16007            Couldn't parse debugger command '%1'.



92                                                                                    InterSystems Error Reference
                                                                                       Non-Numeric Error Codes




1.10 Non-Numeric Error Codes
Table 1–33: Miscellaneous Error Codes

 Error Code                             Description
 DisplayStringLoaderError               DisplayStringLoader error '%1'
 DisplayStringLoaderException           DisplayStringLoader exception '%1'
 DomainOrFilesEmpty                     The Domain or Files parameter(s) must not be empty
 ERROR                                  ERROR
 ErrDisplayStringNotFound               DisplayString undefined for Id='%1', domain='%2', language='%3'
 ErrNoSaveMasterStrings                 Failed to save XData MasterStrings for MasterLanguage '%1' to file
                                        %2
 MasterStringsNewer                     %1 XData MasterStrings are newer than strings in %2 - first difference
                                        = %3
 MasterStringsOlder                     %1 Strings in %2 are newer than XData MasterStrings - first difference
                                        = %3
 MessageDomainNotFound                  The domain specified in the domain parameter was not found in any
                                        message file
 NoStatusCode                           (no error description)
 OK                                     OK
 STATUS                                 STATUS
 UnknownStatusCode                      Unknown status code:
 WARNING                                WARNING
 XMLImportLocation                      (ending at line %1 character %2)




InterSystems Error Reference                                                                                 93
2
SQL Error Messages
The table below lists the SQL numeric error codes and their error messages for InterSystems IRIS® data platform. These
codes are returned as the SQLCODE variable value.

Note:       While this document lists error codes as negative values, JDBC and ODBC clients always receive positive values.
            For example, if an ODBC or JDBC application returns error code 30, look up error code -30 in this table.




2.1 SQLCODE 0 and 100
There are two SQLCODE values that do not represent an SQL error:
Table 2–1: SQL Error Codes 0 and 100

    Error Code            Description
    0                     Successful Completion
    100                   No (more) data


•       SQLCODE=0 indicates successful completion of an SQL operation. For a SELECT statement, this usually means the
        successful retrieval of data from a table. However, if the SELECT performs an aggregate operation, (for example:
        SELECT SUM(myfield)) the aggregate operation is successful and an SQLCODE=0 is issued even when there is
        no data in myfield; in this case SUM returns NULL and %ROWCOUNT=1.
•       SQLCODE=100 indicates that the SQL operation was successful, but found no data to act upon. This can occur for a
        number of reasons. For a SELECT these include: the specified table contains no data; the table contains no data that
        satisfies the query criteria; or row retrieval has reached the final row of the table. For an UPDATE or DELETE these
        include: the specified table contains no data; or the table contains no row of data that satisfies the WHERE clause
        criteria. In these cases %ROWCOUNT=0.
        In Embedded SQL, when SQLCODE=100 the output host variables specified in the INTO clause are nulled.




2.2 SQLCODE -400
The SQLCODE -400 error “Fatal error occurred” is a general error. It is generated when a more specific SQLCODE error
code is not available.


InterSystems Error Reference                                                                                             95
SQL Error Messages




2.3 Retrieving SQL Message Texts
To determine the meaning of an SQLCODE numeric code, use the following ObjectScript statement:

ObjectScript
     WRITE "SQLCODE=",$SYSTEM.SQL.Functions.SQLCODE(-nnn)

This SQLCODE() method can also be called as a stored procedure: %SYSTEM_SQL.Functions_SQLCODE(-nnn).
When possible (usually at SQL compile time), error messages include the name of the field, table, view, or other element
that caused the error. Placeholders for these names are shown using the <name> syntax convention.
The %msg variable may contain an additional message error text for certain errors. For further details, refer to System
Variables.
The message texts returned are shown below in their English versions. The actual message text returned depends upon your
locale setting.
For information on generating ObjectScript general errors from SQLCODE errors, see the %SYSTEM.Error class.




2.4 Table of SQL Error Codes and Messages
For ease of use, the SQL Error Codes Table has been divided into the following sub-tables:
•        Error Codes 0 and 100
•        Error Codes -1 to -99
•        Error Codes -101 to -399
•        Error Codes -400 to -500
•        WinSock Error Codes -10050 to -11002

Table 2–2: SQL Error Codes -1 to -99

    Error Code                   Description
    -1                           Invalid SQL statement
    -2                           Exponent digits missing after 'E'
    -3                           Closing quote (") missing
    -4                           A term expected, beginning with one of the following: identifier, constant, aggregate,
                                 %ALPHAUP, %EXACT, %MVR, %SQLSTRING, %SQLUPPER, %STRING, %UPPER,
                                 $$, :, +, -, (, NOT, EXISTS, or FOR
    -5                           Column number specified in ORDER does not match SELECT list
    -6                           ORDER BY column after UNION not found as SELECT column
    -7                           Exponent out of range
    -8                           Invalid DATEPART code for DATEPART(), DATENAME(), DATEADD(), or DATEDIFF()
    -9                           Incompatible SELECT lists used in UNION/INTERSECT/EXCEPT



96                                                                                           InterSystems Error Reference
                                                                            Table of SQL Error Codes and Messages


 Error Code             Description
 -10                    The SELECT list of the subquery must have exactly one item
 -11                    A scalar expression expected, not a condition
 -12                    A term expected, beginning with one of the following: identifier, constant, aggregate,
                        $$, :, (, +, -, %ALPHAUP, %EXACT, %MVR, %SQLSTRING, %SQLUPPER, %STRING,
                        or %UPPER
 -13                    An expression other than a subquery expected here
 -14                    A comparison operator is required here
 -15                    A condition expected after NOT
 -16                    Quantifier SOME expected after the FOR in the for-expression
 -17                    A for-condition expected after the ( in the for-expression
 -18                    IS (or IS NOT) NULL predicate can be applied only to a field
 -19                    An aggregate function cannot be used in a WHERE or GROUP BY clause
 -20                    Name conflict in the FROM list over label
 -21                    Pointer->Field reference may not be modified by an INSERT or UPDATE statement
 -22                    ORDER must specify column names, not numbers, when after 'SELECT *'
 -23                    Label is not listed among the applicable tables
 -24                    Ambiguous sort column
 -25                    Input encountered after end of query
 -26                    Missing FROM clause
 -27                    Field is ambiguous among the applicable tables
 -28                    Host variable name must begin with either % or a letter
 -29                    Field not found in the applicable tables
 -30                    Table or view not found
 -31                    Field not (found/unique) in table(s)
 -32                    Outer-join symbol ( =* or *= ) must be between two fields
 -33                    No field(s) found for table
 -34                    Optimizer failed to find a usable join order
 -35                    INSERT/UPDATE/DELETE not allowed for non-updateable view
 -36                    WITH CHECK OPTION (CHECKOPTION class parameter) not allowed for
                        non-updateable views
 -37                    SQL Scalar/Aggregate/Unary function not supported for Stream fields
 -38                    No master map for table
 -39                    No RowID field for table
 -40                    ODBC escape extension not supported
 -41                    An extrinsic function call must have the form '$$tag^routine(...)'



InterSystems Error Reference                                                                                  97
SQL Error Messages


 Error Code          Description
 -42                 Closing quotes ("") missing following pattern match
 -43                 Table is ambiguous within #IMPORT schema name list
 -44                 Duplicate method or query characteristic
 -45                 Duplicate method in ObjectScript query body
 -46                 Required method missing in ObjectScript query body
 -47                 Invalid method or query characteristic
 -48                 Invalid trigger REFERENCING clause for the trigger's event
 -49                 Trigger REFERENCING clause cannot be specified when trigger language not SQL
 -50                 Trigger specifies UPDATE OF <fieldlist> clause when trigger language not SQL
 -51                 SQL statement expected
 -52                 Cursor (Already/Was Not) DECLAREd
 -53                 Constant or variable expected as new value
 -54                 Array designator (last subscript omitted) expected after VALUES
 -55                 Invalid GRANT <role> TO or REVOKE <role> FROM
 -56                 GRANT/REVOKE Action not applicable to an object of this type
 -57                 Trigger specifies WHEN clause when trigger language not SQL
 -58                 Duplicate field found in trigger UPDATE OF <fieldlist> clause
 -59                 Cannot have more than one field
 -60                 An action (%ALTER, SELECT, UPDATE, etc.) expected
 -61                 Cursor not updateable
 -62                 Additional new values expected for INSERT/UPDATE
 -63                 Data exception - invalid escape character
 -64                 Incompatible SELECT list is used in INSERT
 -65                 Positive integer constant or variable expected
 -66                 Redundant fields found in SELECT list
 -67                 Implicit join (arrow syntax) not supported in ON clause
 -68                 Legacy outer join (=*, *=) not supported in ON clause
 -69                 SET <field> = <value expression> not allowed with WHERE CURRENT OF <cursor>
 -70                 Multi-Line field only valid for LIKE, Contains ([), or NULL Comparison.
 -71                 Multi-Line field must be the left operand of the Comparison.
 -72                 Multi-Line field not valid in ORDER BY clause
 -73                 Aggregates not supported in ORDER BY clause
 -74                 Duplicate <select-list> alias names found
 -75                 <trim_spec> and/or <trim_char> required before FROM in TRIM function.



98                                                                               InterSystems Error Reference
                                                                           Table of SQL Error Codes and Messages


 Error Code             Description
 -76                    Cardinality mismatch between the SELECT-list and INTO-list.
 -77                    Qualified column reference not allowed in this JOIN context.
 -78                    Invalid transaction state.
 -79                    Referencing key and referenced key must be the same size
 -80                    Integer expected
 -81                    Column Constraint expected
 -82                    Multiple table %DESCRIPTION definitions found
 -83                    Multiple table %FILE definitions found
 -84                    Multiple table %NUMROWS definitions found
 -85                    Multiple table %ROUTINE definitions found
 -86                    Invalid field definition, no datatype defined
 -87                    Invalid table name
 -88                    Invalid field name
 -89                    Invalid index name
 -90                    Invalid view name
 -91                    Transaction mode cannot be specified more than once
 -92                    Level of isolation cannot be READ UNCOMMITTED or READ VERIFIED if READ
                        WRITE specified
 -93                    number of conditions for the DIAGNOSTICS SIZE must be exact numeric
 -94                    Unsupported usage of OUTER JOIN
 -95                    Operation disallowed by operation table
 -96                    Specified level of isolation is not supported
 -97                    Duplicate select-list names found.
 -98                    License violation
 -99                    Privilege violation

Table 2–3: SQL Error Codes -101 to -399

 Error Code             Description
 -101                   Attempt to open a cursor that is already open
 -102                   Operation (FETCH/CLOSE/UPDATE/DELETE/...) attempted on an unopened cursor
 -103                   Positioned UPDATE or DELETE attempted, but the cursor is not positioned on any row
 -104                   Field validation failed in INSERT, or value failed to convert in DisplayToLogical or
                        OdbcToLogical
 -105                   Field validation failed in UPDATE
 -106                   Row to DELETE not found



InterSystems Error Reference                                                                                   99
SQL Error Messages


 Error Code          Description
 -107                Cannot UPDATE RowID or RowID based on fields
 -108                Required field missing; INSERT or UPDATE not allowed
 -109                Cannot find the row designated for UPDATE
 -110                Locking conflict in filing
 -111                Cannot INSERT into a 'Default Only' RowID or RowID based on field
 -112                Access violation
 -113                %THRESHOLD violation
 -114                One or more matching rows is locked by another user
 -115                Cannot INSERT/UPDATE/DELETE on a read only table
 -116                Cardinality mismatch on INSERT/UPDATE between values list and number of table
                     columns.
 -117                Aggregates not supported in views
 -118                Unknown or non-unique User or Role
 -119                UNIQUE or PRIMARY KEY constraint failed uniqueness check upon INSERT
 -120                UNIQUE or PRIMARY KEY constraint failed uniqueness check upon UPDATE
 -121                FOREIGN KEY constraint failed referential check upon INSERT of row in referencing
                     table
 -122                FOREIGN KEY constraint failed referential check upon UPDATE of row in referencing
                     table
 -123                FOREIGN KEY constraint failed referential check upon UPDATE of row in referenced
                     table
 -124                FOREIGN KEY constraint failed referential check upon DELETE of row in referenced
                     table
 -125                UNIQUE or PRIMARY KEY Constraint failed uniqueness check upon creation of the
                     constraint
 -126                REVOKE with RESTRICT failed.
 -127                FOREIGN KEY Constraint failed referential check upon creation of the constraint
 -128                Argument to scalar function %OBJECT() must be a stream field
 -129                Illegal value for SET OPTION locale property
 -130                Before Insert trigger failed
 -131                After Insert trigger failed
 -132                Before Update trigger failed
 -133                After Update trigger failed
 -134                Before Delete trigger failed
 -135                After Delete trigger failed
 -136                View's WITH CHECK OPTION validation failed in INSERT



100                                                                            InterSystems Error Reference
                                                                            Table of SQL Error Codes and Messages


 Error Code             Description
 -137                   View's WITH CHECK OPTION validation failed in UPDATE
 -138                   Cannot INSERT/UPDATE a value for a read only field
 -139                   Concurrency failure on update: row versions not the same
 -140                   Invalid length parameter passed to the SUBSTRING function
 -141                   Invalid input value passed to the CONVERT function
 -142                   Cardinality mismatch between the view-column-list and view query's SELECT clause
 -143                   ORDER BY not valid in a view's query
 -144                   A subquery is not allowed in an insert statement's set/values clause
 -146                   Unable to convert date input to a valid logical date value
 -147                   Unable to convert time input to a valid logical time value
 -148                   CREATE VIEW, ALTER VIEW, or a view's query may not contain host variable
                        references
 -149                   SQL Function encountered an error
 -150                   Optimistic concurrency locking for a class definition failed
 -151                   Index is not found within tables used by this statement
 -152                   Index is ambiguous within tables used by this statement
 -153                   SQL compile options comment contains invalid JSON string
 -154                   Cannot UPDATE fields that are part of the shard key
 -155                   INSERT/UPDATE into external (linked) cannot use an array variable for input of new
                        values
 -159                   Specified field cannot be converted to columnar
 -160                   Storage conversion failed
 -161                   References to an SQL connection must constitute a whole subquery
 -162                   SQL Connection is not defined
 -163                   Heterogeneous queries via the JDBC gateway are not supported
 -164                   Storage conversion completed successfully but the automatic cleanup of stale table
                        data failed
 -165                   Specified table does not have a cleanup to be done
 -166                   Cleanup failed
 -178                   Cannot apply partition range compiling embedded cached query
 -180                   Model name not unique
 -181                   Model or Trained Model not found
 -182                   No query is defined for the model
 -183                   Predicting Column cannot appear in the specified WITH column list
 -184                   Provider class not found



InterSystems Error Reference                                                                                 101
SQL Error Messages


 Error Code          Description
 -185                Predicting Column only has one unique value in the dataset
 -186                Model's Provider is unavailable on this instance
 -187                ML Configuration not found
 -188                ML Configuration property is not supported for this provider
 -189                Cannot DROP the System Default ML Configuration
 -190                IntegratedML not permitted with current license
 -191                Model has no default trained model. It may not have been trained.
 -192                ML Configuration name not unique
 -193                Model Column / With Column type mismatch
 -194                Cannot specify NOT DEFAULT when the Trained Model name is the same as the
                     Model's DefaultTrainedModel
 -201                Table or view name not unique
 -219                External Language Server required by this query could not be started
 -220                Gateway query error
 -221                Gateway query GetConnection() failed
 -222                Gateway query AllocStatement() failed
 -223                Gateway query Prepare() failed
 -225                Gateway query BindParameters() failed
 -226                Gateway query Execute() failed
 -227                Gateway query Fetch() failed
 -228                Gateway query GetData() failed
 -229                Foreign table query error
 -230                Foreign tables Execute() failed
 -231                Foreign tables Fetch() failed
 -232                Foreign tables Close() failed
 -233                Cardinality mismatch between COLUMNS/VALUES clause and number of table columns
 -234                Invalid foreign server type
 -235                Invalid foreign data wrapper
 -237                Schema import for foreign table did not return column metadata
 -241                Parallel query queue error
 -242                Parallel query run-time error
 -250                Field in QUERY clause doesn't match provided external name
 -251                Sharded query queue error
 -252                Sharded query run-time error



102                                                                                 InterSystems Error Reference
                                                                          Table of SQL Error Codes and Messages


 Error Code             Description
 -253                   Sharded INSERT/UPDATE/DELETE run-time error
 -300                   DDL not allowed on this table definition
 -301                   No Savepoint name
 -302                   Savepoint names starting with "SYS" are reserved
 -303                   No implicit conversion of Stream value to non-Stream field in UPDATE assignment is
                        supported
 -304                   Attempt to add a NOT NULL field with no default value to a table which contains data
 -305                   Attempt to make field required when the table has one or more rows where the column
                        value is NULL
 -306                   Column with this name already exists
 -307                   Primary key already defined for this table
 -308                   Identity column already defined for this table
 -309                   The left operand of %CONTAINS is not a property that supports the %Text interface
 -310                   Foreign key references non-existent table
 -311                   Foreign key with same name already defined for this table
 -312                   Invalid schema name. Must use delimited identifiers to reference this schema name
 -313                   Condition expression not supported for Stream fields
 -314                   Foreign key references non-unique key/column collection
 -315                   Constraint or Key not found
 -316                   Foreign key references non-existent key/column collection
 -317                   Cannot DROP Constraint - One or more Foreign Key constraints reference this Unique
                        constraint
 -319                   Referenced table has no primary key defined
 -320                   Cannot DROP table - One or more Foreign Key constraints reference this table
 -321                   Cannot DROP view - One or more views reference this view
 -322                   Cannot DROP column — column is defined on one or more indexes or constraints
 -324                   Index with this name already defined for this table
 -325                   Index cannot be dropped because it is the IDKEY index and the table has data
 -326                   Duplicate TUNE TABLE option clause found
 -327                   Duplicate table option found
 -328                   Duplicate foreign server option found
 -329                   Required foreign server option missing
 -333                   No such index defined
 -334                   Index name is ambiguous. Index found in multiple tables.
 -340                   No such database (namespace) defined



InterSystems Error Reference                                                                               103
SQL Error Messages


 Error Code          Description
 -341                Database file already exists
 -342                Cannot delete system namespace
 -343                Invalid database name
 -344                Cannot drop database that you are currently using or connected to
 -350                An unexpected error occurred executing SqlComputeCode
 -356                SQL Function (function stored procedure) is not defined to return a value
 -357                SQL Function (function stored procedure) is not defined as a function procedure
 -358                SQL Function (function stored procedure) name not unique
 -359                SQL Function (function stored procedure) not found
 -360                Class not found
 -361                Method or Query name not unique
 -362                Method or Query not found
 -363                Trigger not found
 -364                Trigger with same EVENT, TIME, and ORDER already defined
 -365                Trigger name not unique
 -366                Schema name mismatch between trigger name and table name
 -370                SQL CALL, more arguments specified than defined in the stored procedure
 -371                :HVar = CALL ... Specified for a procedure which does not return a value
 -372                Support for extrinsic function calls are disabled
 -373                An extrinsic function call may not call a % routine
 -374                Cannot alter the datatype of a field to/from a stream type when the table contains data
 -375                Cannot ROLLBACK to unestablished savepoint
 -376                Unsupported CAST target specified
 -377                Field appears more than once in assignment list of insert or update statement
 -378                Datatype mismatch, explicit CAST is required
 -380                Invalid or Missing argument to scalar function
 -381                Too many arguments to scalar function
 -382                CTE name defined more than once
 -383                CTE used for any statement type other than select
 -385                CTE statements over xDBC are only supported by newer versions of the xDBC driver
 -386                Cannot use more than one of TOP, LIMIT or ANSI styles




104                                                                              InterSystems Error Reference
                                                                        Table of SQL Error Codes and Messages


Table 2–4: SQL Error Codes -400 to -500

 Error Code             Description
 -400                   Fatal error occurred
 -401                   Fatal Connection error
 -402                   Invalid Username/Password
 -405                   Unable to read from communication device
 -406                   Unable to Write to Server
 -407                   Unable to Write to Server Master
 -408                   Unable to start server
 -409                   Invalid server function
 -410                   Invalid Directory
 -411                   No stream object defined for field
 -412                   General stream error
 -413                   Incompatible client/server protocol
 -415                   Fatal error occurred within the SQL filer
 -416                   Info Error
 -417                   Security Error
 -422                   SELECT request processed via ODBC, JDBC, or Dynamic SQL cannot contain an
                        INTO clause
 -425                   Error processing stored procedure request
 -426                   Error preparing stored procedure
 -427                   Invalid stored procedure name
 -428                   Stored procedure not found
 -429                   Invalid number of input/output parameters for stored procedure
 -430                   Cannot initialize procedure context
 -431                   Stored procedure parameter type mismatch
 -432                   Function returned multiple rows when only a single value is expected
 -450                   Request timed out due to user timeout
 -451                   Unable to receive server message
 -452                   Message sequencing error
 -453                   Error in user initialization code
 -454                   Error sending external interrupt request
 -456                   SQL query execution interrupted by user
 -459                   Kerberos authentication failure
 -460                   General error



InterSystems Error Reference                                                                             105
SQL Error Messages


 Error Code           Description
 -461                 Communication link failure
 -462                 Memory allocation failure
 -463                 Invalid column number
 -464                 Function sequence error
 -465                 Invalid string or buffer length
 -466                 Invalid parameter number
 -467                 Column type out of range
 -468                 Fetch type out of range
 -469                 Driver not capable
 -470                 Option value changed
 -471                 Duplicate cursor name
 -472                 A collection-valued property was expected
 -473                 Schema not found
 -474                 Explain does not support the following SQL statement type: INSERT
 -475                 Schema is not empty
 -476                 Schema already exists
 -481                 Explain does not support the following SQL statement type: INSERT
 -482                 Schema is not empty
 -483                 Comparison between DATE and TIMESTAMP values of 'dStart' and
                      'CURRENT_TIMESTAMP' detected where ANSI SQL standard output may differ from
                      legacy IRIS SQL output. Use CAST to ensure same-datatype comparisons. System-wide
                      flag is set to raise this as an error.
 -478                 Query recompiled: Result Set mismatch
 -500                 Fetch row count limit reached

Table 2–5: WinSock Error Codes -10050 to -11002

 Error Code           Description
 -10050               WinSock: Network is down
 -10051               WinSock: Network is unreachable
 -10052               WinSock: Net dropped connection or reset
 -10054               WinSock: Connection reset by peer (due to timeout or reboot)
 -10055               WinSock: No buffer space available
 -10056               WinSock: Socket is already connected
 -10057               WinSock: Socket is not connected
 -10058               WinSock: Cannot send after socket shutdown




106                                                                             InterSystems Error Reference
                                                                    Table of SQL Error Codes and Messages


 Error Code             Description
 -10060                 WinSock: Connection timed out
 -10061                 WinSock: Connection refused
 -10064                 WinSock: Host is down
 -10065                 WinSock: No route to host
 -10070                 WinSock: Stale NFS file handle
 -10091                 WinSock: Network subsystem is unavailable
 -10092                 WinSock: WINSOCK DLL version out of range
 -10093                 WinSock: Successful WSASTARTUP not yet performed
 -11001                 WinSock: Host not found
 -11002                 WinSock: Nonauthoritative host not found




InterSystems Error Reference                                                                         107
3
TSQL Error Messages
This section contains the TSQL error messages for InterSystems IRIS® data platform. To use these messages, your appli-
cation’s TSQL procedure must reference the master..sysmessages system table. InterSystems IRIS does not support
all TSQL features mentioned in these messages.
Table 3–1:TSQL Error Codes - 0 to 99

 Error Code                    Description
 1                             Version date of last upgrade: 10/11/90
 21                            Warning: Fatal error %d occurred at %S_DATE. Note the error and time, and
                               contact your system administrator.


Table 3–2:TSQL Error Codes - 100 to 199

 Error Code                    Description
 102                           Incorrect syntax near '%.*ls'.
 103                           The %S_MSG that starts with '%.*ls' is too long. Maximum length is %d.
 104                           ORDER BY items must appear in the select list if the statement contains a UNION
                               operator.
 105                           Unclosed quotation mark before the character string '%.*ls'.
 106                           Too many table names in the query. The maximum allowable is %d.
 107                           The column prefix '%.*ls' does not match with a table name or alias name used
                               in the query.
 108                           The ORDER BY position number %ld is out of range of the number of items in
                               the select list.
 109                           There are more columns in the INSERT statement than values specified in the
                               VALUES clause. The number of values in the VALUES clause must match the
                               number of columns specified in the INSERT statement.
 110                           There are fewer columns in the INSERT statement than values specified in the
                               VALUES clause. The number of values in the VALUES clause must match the
                               number of columns specified in the INSERT statement.
 111                           '%ls' must be the first statement in a query batch.




InterSystems Error Reference                                                                                      109
TSQL Error Messages


 Error Code           Description
 112                  Variables are not allowed in the %ls statement.
 113                  Missing end comment mark '*/'.
 114                  Browse mode is invalid for a statement that assigns values to a variable.
 116                  Only one expression can be specified in the select list when the subquery is not
                      introduced with EXISTS.
 117                  The %S_MSG name '%.*ls' contains more than the maximum number of prefixes.
                      The maximum is %d.
 118                  Only members of the sysadmin role can specify the %ls option for the %ls
                      statement.
 119                  Must pass parameter number %d and subsequent parameters as '@name =
                      value'. After the form '@name = value' has been used, all subsequent parameters
                      must be passed in the form '@name = value'.
 120                  The select list for the INSERT statement contains fewer items than the insert list.
                      The number of SELECT values must match the number of INSERT columns.
 121                  The select list for the INSERT statement contains more items than the insert list.
                      The number of SELECT values must match the number of INSERT columns.
 122                  The %ls option is allowed only with %ls syntax.
 123                  Batch/procedure exceeds maximum length of %d characters.
 124                  CREATE PROCEDURE contains no statements.
 125                  Case expressions may only be nested to level %d.
 128                  The name '%.*ls' is not permitted in this context. Only constants, expressions, or
                      variables allowed here. Column names are not permitted.
 129                  Fillfactor %d is not a valid percentage; fillfactor must be between 1 and 100.
 130                  Cannot perform an aggregate function on an expression containing an aggregate
                      or a subquery.
 131                  The size (%d) given to the %S_MSG '%.*ls' exceeds the maximum allowed for
                      any data type (%d).
 132                  The label '%.*ls' has already been declared. Label names must be unique within
                      a query batch or stored procedure.
 133                  A GOTO statement references the label '%.*ls' but the label has not been declared.
 134                  The variable name '%.*ls' has already been declared. Variable names must be
                      unique within a query batch or stored procedure.
 135                  Cannot use a BREAK statement outside the scope of a WHILE statement.
 136                  Cannot use a CONTINUE statement outside the scope of a WHILE statement.
 137                  Must declare the variable '%.*ls'.
 138                  Correlation clause in a subquery not permitted.
 139                  Cannot assign a default value to a local variable.
 140                  Can only use IF UPDATE within a CREATE TRIGGER statement.



110                                                                           InterSystems Error Reference
                                                                                            TSQL Error Messages


 Error Code                    Description
 141                           A SELECT statement that assigns a value to a variable must not be combined
                               with data-retrieval operations.
 142                           Incorrect syntax for definition of the '%ls' constraint.
 143                           A COMPUTE BY item was not found in the order by list. All expressions in the
                               compute by list must also be present in the order by list.
 144                           Cannot use an aggregate or a subquery in an expression used for the group by
                               list of a GROUP BY clause.
 145                           ORDER BY items must appear in the select list if SELECT DISTINCT is specified.
 146                           Could not allocate ancillary table for a subquery. Maximum number of tables in
                               a query (%d) exceeded.
 147                           An aggregate may not appear in the WHERE clause unless it is in a subquery
                               contained in a HAVING clause or a select list, and the column being aggregated
                               is an outer reference.
 148                           Incorrect time syntax in time string '%.*ls' used with WAITFOR.
 149                           Time value '%.*ls' used with WAITFOR is not a valid value. Check date/time
                               syntax.
 150                           Both terms of an outer join must contain columns.
 151                           '%.*ls' is an invalid money value.
 153                           Invalid usage of the option %.*ls in the %ls statement.
 154                           %S_MSG is not allowed in %S_MSG.
 155                           '%.*ls' is not a recognized %ls option.
 156                           Incorrect syntax near the keyword '%.*ls'.
 157                           An aggregate may not appear in the set list of an UPDATE statement.
 159                           For DROP INDEX, you must give both the table and the index name, in the form
                               tablename.indexname.
 160                           Rule does not contain a variable.
 161                           Rule contains more than one variable.
 163                           The compute by list does not match the order by list.
 164                           GROUP BY expressions must refer to column names that appear in the select
                               list.
 165                           Privilege %ls may not be granted or revoked.
 166                           '%ls' does not allow specifying the database name as a prefix to the object name.
 167                           Cannot create a trigger on a temporary object.
 168                           The %S_MSG '%.*ls' is out of the range of computer representation (%d bytes).
 169                           A column has been specified more than once in the order by list. Columns in the
                               order by list must be unique.
 170                           Line %d: Incorrect syntax near '%.*ls'.



InterSystems Error Reference                                                                                  111
TSQL Error Messages


 Error Code                 Description
 171                        Cannot use SELECT INTO in browse mode.
 172                        Cannot use HOLDLOCK in browse mode.
 173                        The definition for column '%.*ls' must include a data type.
 174                        The %ls function requires %d arguments.
 177                        The IDENTITY function can only be used when the SELECT statement has an
                            INTO clause.
 178                        A RETURN statement with a return value cannot be used in this context.
 179                        Cannot use the OUTPUT option when passing a constant to a stored procedure.
 180                        There are too many parameters in this %ls statement. The maximum number is
                            %d.
 181                        Cannot use the OUTPUT option in a DECLARE statement.
 182                        Table and column names must be supplied for the READTEXT or WRITETEXT
                            utility.
 183                        The scale (%d) for column '%.*ls' must be within the range %d to %d.
 185                        Data stream is invalid for WRITETEXT statement in bulk form.
 186                        Data stream missing from WRITETEXT statement.
 188                        Cannot specify a log device in a CREATE DATABASE statement without also
                            specifying at least one non-log device.
 189                        The %ls function requires %d to %d arguments.
 191                        Some part of your SQL statement is nested too deeply. Rewrite the query or break
                            it up into smaller queries.
 192                        The scale must be less than or equal to the precision.
 193                        The object or column name starting with '%.*ls' is too long. The maximum length
                            is %d characters.
 194                        A SELECT INTO statement cannot contain a SELECT statement that assigns
                            values to a variable.
 195                        '%.*ls' is not a recognized %S_MSG.
 196                        SELECT INTO must be the first query in an SQL statement containing a UNION
                            operator.
 197                        EXECUTE cannot be used as a source when inserting into a table variable.
 198                        Browse mode is invalid for statements containing a UNION operator.
 199                        An INSERT statement cannot contain a SELECT statement that assigns values
                            to a variable.

Table 3–3:TSQL Error Codes - 200 to 299

 Error Code                 Description
 201                        Procedure '%.*ls' expects parameter '%.*ls', which was not supplied.




112                                                                                  InterSystems Error Reference
                                                                                             TSQL Error Messages


 Error Code                    Description
 202                           Invalid type '%s' for WAITFOR. Supported data types are CHAR/VARCHAR,
                               NCHAR/NVARCHAR, and DATETIME. WAITFOR DELAY supports the INT and
                               SMALLINT data types.
 203                           The name '%.*ls' is not a valid identifier.
 204                           Normalization error in node %ls.
 205                           All queries in an SQL statement containing a UNION operator must have an equal
                               number of expressions in their target lists.
 206                           Operand type clash: %ls is incompatible with %ls
 207                           Invalid column name '%.*ls'.
 208                           Invalid object name '%.*ls'.
 209                           Ambiguous column name '%.*ls'.
 210                           Syntax error converting datetime from binary/varbinary string.
 212                           Expression result length exceeds the maximum. %d max, %d found.
 213                           Insert Error: Column name or number of supplied values does not match table
                               definition.
 214                           Procedure expects parameter '%ls' of type '%ls'.
 217                           Maximum stored procedure, function, trigger, or view nesting level exceeded (limit
                               %d).
 220                           Arithmetic overflow error for data type %ls, value = %ld.
 221                           FIPS Warning: Implicit conversion from %ls to %ls.
 223                           Object ID %ld specified as a default for table ID %ld, column ID %d is missing or
                               not of type default.
 224                           Object ID %ld specified as a rule for table ID %ld, column ID %d is missing or not
                               of type default.
 226                           %ls statement not allowed within multi-statement transaction.
 229                           %ls permission denied on object '%.*ls', database '%.*ls', owner '%.*ls'.
 230                           %ls permission denied on column '%.*ls' of object '%.*ls', database '%.*ls', owner
                               '%.*ls'.
 231                           No such default. ID = %ld, database ID = %d.
 232                           Arithmetic overflow error for type %ls, value = %f.
 233                           The column '%.*ls' in table '%.*ls' cannot be null.
 234                           There is insufficient result space to convert a money value to %ls.
 235                           Cannot convert a char value to money. The char value has incorrect syntax.
 236                           The conversion from char data type to money resulted in a money overflow error.
 237                           There is insufficient result space to convert a money value to %ls.
 238                           There is insufficient result space to convert the %ls value (= %d) to the money
                               data type.



InterSystems Error Reference                                                                                  113
TSQL Error Messages


 Error Code           Description
 241                  Syntax error converting datetime from character string.
 242                  The conversion of a char data type to a datetime data type resulted in an
                      out-of-range datetime value.
 243                  Type %.*ls is not a defined system type.
 244                  The conversion of the %ls value '%.*ls' overflowed an %hs column. Use a larger
                      integer column.
 245                  Syntax error converting the %ls value '%.*ls' to a column of data type %ls.
 248                  The conversion of the %ls value '%.*ls' overflowed an int column. Maximum integer
                      value exceeded.
 251                  Could not allocate ancillary table for query optimization. Maximum number of
                      tables in a query (%d) exceeded.
 256                  The data type %ls is invalid for the %ls function. Allowed types are: char/varchar,
                      nchar/nvarchar, and binary/varbinary.
 257                  Implicit conversion from data type %ls to %ls is not allowed. Use the CONVERT
                      function to run this query.
 259                  Ad hoc updates to system catalogs are not enabled. The system administrator
                      must reconfigure SQL Server to allow this.
 260                  Disallowed implicit conversion from data type %ls to data type %ls, table '%.*ls',
                      column '%.*ls'. Use the CONVERT function to run this query.
 261                  '%.*ls' is not a recognized function.
 262                  %ls permission denied in database '%.*ls'.
 263                  Must specify table to select from.
 264                  Column name '%.*ls' appears more than once in the result column list.
 266                  Transaction count after EXECUTE indicates that a COMMIT or ROLLBACK
                      TRANSACTION statement is missing. Previous count = %ld, current count = %ld.
 267                  Object '%.*ls' cannot be found.
 268                  Cannot run SELECT INTO in this database. The database owner must run
                      sp_dboption to enable this option.
 270                  Object '%.*ls' cannot be modified.
 271                  Column '%.*ls' cannot be modified because it is a computed column.
 272                  Cannot update a timestamp column.
 273                  Cannot insert a non-null value into a timestamp column. Use INSERT with a
                      column list or with a default of NULL for the timestamp column.
 278                  The text, ntext, and image data types cannot be used in a GROUP BY clause.
 279                  The text, ntext, and image data types are invalid in this subquery or aggregate
                      expression.
 280                  Only text, ntext, and image columns are valid with the TEXTPTR function.
 281                  %d is not a valid style number when converting from %ls to a character string.



114                                                                           InterSystems Error Reference
                                                                                              TSQL Error Messages


 Error Code                    Description
 282                           The '%.*ls' procedure attempted to return a status of NULL, which is not allowed.
                               A status of 0 will be returned instead.
 283                           READTEXT cannot be used on inserted or deleted tables within an INSTEAD OF
                               trigger.
 284                           Rules cannot be bound to text, ntext, or image data types.
 285                           The READTEXT, WRITETEXT, and UPDATETEXT statements cannot be used
                               with views or functions.
 286                           The logical tables INSERTED and DELETED cannot be updated.
 287                           The %ls statement is not allowed within a trigger.
 288                           The PATINDEX function operates on char, nchar, varchar, nvarchar, text, and
                               ntext data types only.
 291                           CAST or CONVERT: invalid attributes specified for type '%.*ls'
 292                           There is insufficient result space to convert a smallmoney value to %ls.
 293                           Cannot convert char value to smallmoney. The char value has incorrect syntax.
 294                           The conversion from char data type to smallmoney data type resulted in a
                               smallmoney overflow error.
 295                           Syntax error converting character string to smalldatetime data type.
 296                           The conversion of char data type to smalldatetime data type resulted in an
                               out-of-range smalldatetime value.
 298                           The conversion from datetime data type to smalldatetime data type resulted in a
                               smalldatetime overflow error.
 299                           The DATEADD function was called with bad type %ls.

Table 3–4:TSQL Error Codes - 300 to 399

 Error Code                    Description
 301                           Query contains an outer-join request that is not permitted.
 303                           The table '%.*ls' is an inner member of an outer-join clause. This is not allowed
                               if the table also participates in a regular join clause.
 306                           The text, ntext, and image data types cannot be compared or sorted, except when
                               using IS NULL or LIKE operator.
 307                           Index ID %d on table '%.*ls' (specified in the FROM clause) does not exist.
 308                           Index '%.*ls' on table '%.*ls' (specified in the FROM clause) does not exist.
 311                           Cannot use text, ntext, or image columns in the 'inserted' and 'deleted' tables.
 312                           Cannot reference text, ntext, or image columns in a filter stored procedure.
 313                           An insufficient number of arguments were supplied for the procedure or function
                               %.*ls.
 314                           Cannot use GROUP BY ALL with the special tables INSERTED or DELETED.




InterSystems Error Reference                                                                                      115
TSQL Error Messages


Table 3–5:TSQL Error Codes - 400 to 499

 Error Code                 Description
 401                        Unimplemented statement or expression %ls.
 403                        Invalid operator for data type. Operator equals %ls, type equals %ls.
 409                        The %ls operation cannot take a %ls data type as an argument.
 410                        COMPUTE clause #%d 'BY' expression #%d is not in the order by list.
 411                        COMPUTE clause #%d, aggregate expression #%d is not in the select list.
 420                        The text, ntext, and image data types cannot be used in an ORDER BY clause.
 425                        Data type %ls of receiving variable is not equal to the data type %ls of column
                            '%.*ls'.
 426                        The length %d of the receiving variable is less than the length %d of the column
                            '%.*ls'.
 427                        Could not load sysprocedures entries for constraint ID %d in database ID %d.
 428                        Could not find row in sysconstraints for constraint ID %d in database ID %d.
 429                        Could not find new constraint ID %d in sysconstraints, database ID %d, at compile
                            time.
 430                        Could not resolve table name for object ID %d, database ID %d, when compiling
                            foreign key.
 431                        Could not bind foreign key constraint. Too many tables involved in the query.
 433                        Could not find CHECK constraint for '%.*ls', although the table is flagged as having
                            one.
 436                        Could not open referenced table ID %d in database ID %d.
 437                        Could not resolve the referenced column name in table ID %d.
 438                        Could not resolve the referencing column name in table ID %d.
 439                        Could not find FOREIGN KEY constraints for table '%.*ls' in database ID %d
                            although the table is flagged as having them.
 441                        Cannot use the '%ls' function on a remote data source.
 443                        Invalid use of '%s' within a function.
 444                        Select statements included within a function cannot return data to a client.
 445                        COLLATE clause cannot be used on expressions containing a COLLATE clause.
 446                        Cannot resolve collation conflict for %ls operation.
 447                        Expression type %ls is invalid for COLLATE clause.
 448                        Invalid collation '%.*ls'.
 449                        Collation conflict caused by collate clauses with different collation '%.*ls' and
                            '%.*ls'.
 450                        Code page translations are not supported for the text data type. From: %d To:
                            %d.




116                                                                                  InterSystems Error Reference
                                                                                             TSQL Error Messages


 Error Code                    Description
 451                           Cannot resolve collation conflict for column %d in %ls statement.
 452                           COLLATE clause cannot be used on user-defined data types.
 453                           Collation '%.*ls' is supported on Unicode data types only and cannot be set at the
                               database or server level.
 455                           The last statement included within a function must be a return statement.
 456                           Implicit conversion of %ls value to %ls cannot be performed because the resulting
                               collation is unresolved due to collation conflict.
 457                           Implicit conversion of %ls value to %ls cannot be performed because the collation
                               of the value is unresolved due to a collation conflict.

Table 3–6:TSQL Error Codes - 500 to 599

 Error Code                    Description
 502                           The SQL Debugging Interface (SDI) requires that SQL Server, when started as
                               a service, must not log on as System Account. Reset to log on as user account
                               using Control Panel.
 503                           Unable to send symbol information to debugger on %ls for connection %d.
                               Debugging disabled.
 504                           Unable to connect to debugger on %ls (Error = 0x%08x). Ensure that client-side
                               components, such as SQLDBREG.EXE, are installed and registered on %.*ls.
                               Debugging disabled for connection %d.
 505                           Current user account was invoked with SETUSER. Changing databases is not
                               allowed.
 506                           Invalid escape character '%.*ls' was specified in a LIKE predicate.
 507                           Invalid argument for SET ROWCOUNT. Must be a non-null non-negative integer.
 508                           Unable to connect to debugger on %ls (Error = 0x%08x). Ensure that client-side
                               components, such as SQLLE.DLL, are installed and registered on %.*ls.
                               Debugging disabled for connection %d.
 509                           User name '%.*ls' not found.
 510                           Cannot create a worktable row larger than allowable maximum. Resubmit your
                               query with the ROBUST PLAN hint.
 511                           Cannot create a row of size %d which is greater than the allowable maximum of
                               %d.
 512                           Subquery returned more than 1 value. This is not permitted when the subquery
                               follows =, !=, <, <= , >, >= or when the subquery is used as an expression.
 513                           A column insert or update conflicts with a rule imposed by a previous CREATE
                               RULE statement.The statement was terminated.The conflict occurred in database
                               '%.*ls', table '%.*ls', column '%.*ls'.
 514                           Unable to communicate with debugger on %ls (Error = 0x%08x). Debugging
                               disabled for connection %d.




InterSystems Error Reference                                                                                  117
TSQL Error Messages


 Error Code           Description
 515                  Cannot insert the value NULL into column '%.*ls', table '%.*ls'; column does not
                      allow nulls. %ls fails.
 516                  Attempt to initialize OLE library failed. Check for correct versions of OLE DLLs
                      on this machine.
 517                  Adding a value to a '%ls' column caused overflow.
 518                  Cannot convert data type %ls to %ls.
 520                  SQL Server no longer supports version %d of the SQL Debugging Interface (SDI).
 528                  System error detected during attempt to use the 'upsleep' system function.
 529                  Explicit conversion from data type %ls to %ls is not allowed.
 532                  The timestamp (changed to %S_TS) shows that the row has been updated by
                      another user.
 535                  Difference of two datetime columns caused overflow at runtime.
 536                  Invalid length parameter passed to the substring function.
 538                  Cannot find '%.*ls'. This language may have been dropped. Contact your system
                      administrator.
 542                  An invalid datetime value was encountered. Value exceeds the year 9999.
 544                  Cannot insert explicit value for identity column in table '%.*ls' when
                      IDENTITY_INSERT is set to OFF.
 545                  Explicit value must be specified for identity column in table '%.*ls' when
                      IDENTITY_INSERT is set to ON.
 547                  %ls statement conflicted with %ls %ls constraint '%.*ls'. The conflict occurred in
                      database '%.*ls', table '%.*ls'%ls%.*ls%ls.
 548                  The identity range managed by replication is full and must be updated by a
                      replication agent. The %ls conflict occurred in database '%.*ls', table
                      '%.*ls'%ls%.*ls%ls. Sp_adjustpublisheridentityrange can be called to get a new
                      identity range.
 550                  The attempted insert or update failed because the target view either specifies
                      WITH CHECK OPTION or spans a view that specifies WITH CHECK OPTION
                      and one or more rows resulting from the operation did not qualify under the CHECK
                      OPTION constraint.
 551                  The checksum has changed to %d. This shows that the row has been updated
                      by another user.
 552                  CryptoAPI function '%ls' failed. Error 0x%x: %ls
 555                  User-defined functions are not yet enabled.
 556                  INSERT EXEC failed because the stored procedure altered the schema of the
                      target table.
 557                  Only functions and extended stored procedures can be executed from within a
                      function.
 558                  Remote function calls are not allowed within a function.



118                                                                           InterSystems Error Reference
                                                                                                TSQL Error Messages


 Error Code                    Description
 561                           Failed to access file '%.*ls'
 562                           Failed to access file '%.*ls'. Files can be accessed only through shares
 563                           The transaction for the INSERT EXEC statement has been rolled back. The
                               INSERT EXEC operation will be terminated.
 564                           Attempted to create a record with a fixed length of '%d'. Maximum allowable fixed
                               length is '%d'.
 565                           The server encountered a stack overflow during compile time.
 566                           Error writing audit trace. SQL Server is shutting down.
 567                           File '%.*ls' either does not exist or is not a recognizable trace file. Or there was
                               an error opening the file.
 568                           Server encountered an error '%.*ls'.

Table 3–7:TSQL Error Codes - 600 to 699

 Error Code                    Description
 601                           Could not continue scan with NOLOCK due to data movement.
 602                           Could not find row in sysindexes for database ID %d, object ID %ld, index ID %d.
                               Run DBCC CHECKTABLE on sysindexes.
 604                           Could not find row in sysobjects for object ID %ld in database '%.*ls'. Run DBCC
                               CHECKTABLE on sysobjects.
 605                           Attempt to fetch logical page %S_PGID in database '%.*ls' belongs to object
                               '%.*ls', not to object '%.*ls'.
 607                           Insufficient room was allocated for search arguments in the session descriptor
                               for object '%.*ls'. Only %d search arguments were anticipated.
 615                           Could not find database table ID %d, name '%.*ls'.
 617                           Descriptor for object ID %ld in database ID %d not found in the hash table during
                               attempt to unhash it.
 618                           A varno of %d was passed to the opentable system function. The largest valid
                               value is %d.
 622                           Filegroup '%.*ls' has no files assigned to it. Tables, indexes, and text, ntext, and
                               image columns cannot be populated on this filegroup until a file is added.
 623                           Could not retrieve row from page by RID because logical page %S_PGID is not
                               a data page. %S_RID. %S_PAGE.
 624                           Could not retrieve row from page by RID because the requested RID has a higher
                               number than the last RID on the page. %S_RID.%S_PAGE, DBID %d.
 625                           Cannot retrieve row from page %S_PGID by RID because the slotid (%d) is not
                               valid.
 626                           Cannot use ROLLBACK with a savepoint within a distributed transaction.
 627                           Cannot use SAVE TRANSACTION within a distributed transaction.
 628                           Cannot issue SAVE TRANSACTION when there is no active transaction.



InterSystems Error Reference                                                                                      119
TSQL Error Messages


 Error Code                 Description
 635                        Process %d tried to remove DES resource lock %S_DES, which it does not hold.
 637                        Index shrink program returned invalid status of 0.
 639                        Could not fetch logical page %S_PGID, database ID %d. The page is not currently
                            allocated.
 644                        Could not find the index entry for RID '%.*hs' in index page %S_PGID, index ID
                            %d, database '%.*ls'.
 649                        Could not find the clustered index entry for page %S_PGID, object ID %ld, status
                            0x%x. Index page %S_PGID, in database '%.*ls', was searched for this entry.
 650                        You can only specify the READPAST lock in the READ COMMITTED or
                            REPEATABLE READ isolation levels.
 651                        Cannot use %hs granularity hint on table '%.*ls' because locking at the specified
                            granularity is inhibited.
 652                        Index ID %d for table '%.*ls' resides on a read-only filegroup which cannot be
                            modified.
 653                        Two buffers are conflicting for the same keep slot in table '%.*ls'.
 654                        No slots are free to keep buffers for table '%.*ls'.
 655                        Expected to find buffer in keep slot for table '%.*ls'.
 666                        Maximum system-generated unique value for a duplicate group exceeded for
                            table ID %d, index ID %d. Dropping and re-creating the index may fix the problem;
                            otherwise use another clustering key.
 667                        Index %d for table '%.*ls' resides on offline filegroup that cannot be accessed.

Table 3–8:TSQL Error Codes - 700 to 799

 Error Code                 Description
 701                        There is insufficient system memory to run this query.
 708                        Warning: Due to low virtual memory, special reserved memory used %d times
                            since startup. Increase virtual memory on server.


Table 3–9:TSQL Error Codes - 800 to 899

 Error Code                 Description
 802                        No more buffers can be stolen.
 804                        Could not find buffer 0x%lx holding logical page %S_PGID in the SDES 0x%lx
                            kept buffer pool for object '%.*ls'.
 809                        Buffer 0x%lx, allocation page %S_PGID, in database '%.*ls' is not in allocation
                            buffer pool in PSS (process status structure). Contact Technical Support.
 813                        Logical page %S_PGID in database ID %d is already hashed.
 816                        Process ID %d tried to remove a buffer resource lock %S_BUF that it does not
                            hold in SDES %S_SDES. Contact Technical Support.




120                                                                                   InterSystems Error Reference
                                                                                              TSQL Error Messages


 Error Code                    Description
 818                           There is no room to hold the buffer resource lock %S_BUF in SDES %S_SDES.
                               Contact Technical Support.
 821                           Could not unhash buffer at 0x%lx with a buffer page number of %S_PGID and
                               database ID %d with HASHED status set. The buffer was not found. %S_PAGE.
 822                           Could not start I/O for request %S_BLKIOPTR.
 823                           I/O error %ls detected during %S_MSG at offset %#016I64x in file '%ls'.
 834                           The bufclean system function was called on dirty buffer (page %S_PGID, stat
                               %#x/%#x, objid %#x, sstat%#x).
 840                           Device '%.*ls' (physical name '%.*ls', virtual device number %d) is not available.
                               Contact the system administrator for assistance.
 844                           Time out occurred while waiting for buffer latch type %d, bp %#x, page %S_PGID,
                               stat %#x, object ID %d:%d:%d, waittime %d. Continuing to wait.
 845                           Time-out occurred while waiting for buffer latch type %d for page %S_PGID,
                               database ID %d.

Table 3–10:TSQL Error Codes - 900 to 999

 Error Code                    Description
 901                           Could not find descriptor for database ID %d, object ID %ld in hash table after
                               hashing it.
 902                           To change the %ls, the database must be in state in which a checkpoint can be
                               executed.
 903                           Could not find row in sysindexes for clustered index on system catalog %ld in
                               database ID %d. This index should exist in all databases. Run DBCC
                               CHECKTABLE on sysindexes in the database.
 906                           Could not locate row in sysobjects for system catalog '%.*ls' in database '%.*ls'.
                               This system catalog should exist in all databases. Run DBCC CHECKTABLE on
                               sysobjects in this database.
 911                           Could not locate entry in sysdatabases for database '%.*ls'. No entry found with
                               that name. Make sure that the name is entered correctly.
 913                           Could not find database ID %d. Database may not be activated yet or may be in
                               transition.
 916                           Server user '%.*ls' is not a valid user in database '%.*ls'.
 921                           Database '%.*ls' has not been recovered yet. Wait and try again.
 922                           Database '%.*ls' is being recovered. Waiting until recovery is finished.
 923                           Database '%.*ls' is in restricted mode. Only the database owner and members of
                               the dbcreator and sysadmin roles can access it.
 924                           Database '%.*ls' is already open and can only have one user at a time.
 925                           Maximum number of databases used for each query has been exceeded. The
                               maximum allowed is %d.




InterSystems Error Reference                                                                                     121
TSQL Error Messages


 Error Code                Description
 926                       Database '%.*ls' cannot be opened. It has been marked SUSPECT by recovery.
                           See the SQL Server errorlog for more information.
 927                       Database '%.*ls' cannot be opened. It is in the middle of a restore.
 929                       Attempting to close a database that is not already open. Contact Technical
                           Support.
 941                       Cannot open database '%.*ls'. It has not been upgraded to the latest format.
 942                       Database '%.*ls' cannot be opened because it is offline.
 943                       Database '%.*ls' cannot be opened because its version (%d) is later than the
                           current server version (%d).
 944                       Converting database '%.*ls' from version %d to the current version %d.
 945                       Database '%.*ls' cannot be opened due to inaccessible files or insufficient memory
                           or disk space. See the SQL Server errorlog for details.
 946                       Cannot open database '%.*ls' version %d. Upgrade the database to the latest
                           version.
 947                       Error while closing database '%.*ls' cleanly.
 948                       Database '%.*ls' cannot be upgraded. Database is version %d and this server
                           supports version %d.
 949                       tempdb is skipped. You cannot run a query that requires tempdb
 950                       Database '%.*ls' cannot be upgraded - database has a version (%d) earlier than
                           SQL Server 7.0(%d).
 951                       Database '%.*ls' running the upgrade step from version %d to version %d.
 952                       Database '%.*ls' is in transition. Try the statement later.
 953                       Warning: Index '%ls' on '%ls' in database '%ls' may be corrupt because of
                           expression evaluation changes in this release. Drop and re-create the index.

Table 3–11:TSQL Error Codes - 1000 to 1099

 Error Code                Description
 1001                      Line %d: Length or precision specification %d is invalid.
 1002                      Line %d: Specified scale %d is invalid.
 1003                      Line %d: %ls clause allowed only for %ls.
 1004                      Invalid column prefix '%.*ls': No table name specified
 1005                      Line %d: Invalid procedure number (%d). Must be between 1 and 32767.
 1006                      CREATE TRIGGER contains no statements.
 1007                      The %S_MSG '%.*ls' is out of the range for numeric representation (maximum
                           precision 38).
 1008                      The SELECT item identified by the ORDER BY number %d contains a variable
                           as part of the expression identifying a column position. Variables are only allowed
                           when ordering by an expression referencing a column name.



122                                                                                  InterSystems Error Reference
                                                                                               TSQL Error Messages


 Error Code                    Description
 1010                          Invalid escape character '%.*ls'.
 1011                          The correlation name '%.*ls' is specified multiple times in a FROM clause.
 1012                          The correlation name '%.*ls' has the same exposed name as table '%.*ls'.
 1013                          Tables or functions '%.*ls' and '%.*ls' have the same exposed names. Use
                               correlation names to distinguish them.
 1014                          TOP clause contains an invalid value.
 1015                          An aggregate cannot appear in an ON clause unless it is in a subquery contained
                               in a HAVING clause or select list, and the column being aggregated is an outer
                               reference.
 1016                          Outer join operators cannot be specified in a query containing joined tables.
 1019                          Invalid column list after object name in GRANT/REVOKE statement.
 1020                          Column list cannot be specified for object-level permissions.
 1021                          FIPS Warning: Line %d has the non-ANSI statement '%ls'.
 1022                          FIPS Warning: Line %d has the non-ANSI clause '%ls'.
 1023                          Invalid parameter %d specified for %ls.
 1024                          FIPS Warning: Line %d has the non-ANSI function '%ls'.
 1025                          FIPS Warning: The length of identifier '%.*ls' exceeds 18.
 1027                          Too many expressions are specified in the GROUP BY clause. The maximum
                               number is %d when either CUBE or ROLLUP is specified.
 1028                          The CUBE and ROLLUP options are not allowed in a GROUP BY ALL clause.
 1029                          Browse mode is invalid for subqueries and derived tables.
 1031                          Percent values must be between 0 and 100.
 1032                          Cannot use the column prefix '%.*ls'. This must match the object in the UPDATE
                               clause '%.*ls'.
 1033                          The ORDER BY clause is invalid in views, inline functions, derived tables, and
                               subqueries, unless TOP is also specified.
 1035                          Incorrect syntax near '%.*ls', expected '%.*ls'.
 1036                          File option %hs is required in this CREATE/ALTER DATABASE statement.
 1037                          The CASCADE, WITH GRANT or AS options cannot be specified with statement
                               permissions.
 1038                          Cannot use empty object or column names. Use a single space if necessary.
 1039                          Option '%.*ls' is specified more than once.
 1040                          Mixing old and new syntax in CREATE/ALTER DATABASE statement is not
                               allowed.
 1041                          Option %.*ls is not allowed for a LOG file.
 1042                          Conflicting %ls optimizer hints specified.




InterSystems Error Reference                                                                                   123
TSQL Error Messages


 Error Code           Description
 1043                 '%hs' is not yet implemented.
 1044                 Cannot use an existing function name to specify a stored procedure name.
 1045                 Aggregates are not allowed in this context. Only scalar expressions are allowed.
 1046                 Subqueries are not allowed in this context. Only scalar expressions are allowed.
 1047                 Conflicting locking hints specified.
 1048                 Conflicting cursor options %ls and %ls.
 1049                 Mixing old and new syntax to specify cursor options is not allowed.
 1050                 This syntax is only allowed within the stored procedure sp_executesql.
 1051                 Cursor parameters in a stored procedure must be declared with OUTPUT and
                      VARYING options, and they must be specified in the order CURSOR VARYING
                      OUTPUT.
 1052                 Conflicting %ls options %ls and %ls.
 1053                 For DROP STATISTICS, you must give both the table and the column name in
                      the form 'tablename.column'.
 1054                 Syntax '%ls' is not allowed in schema-bound objects.
 1055                 '%.*ls' is an invalid name because it contains a NULL character.
 1056                 The maximum number of elements in the select list is %d and you have supplied
                      %d.
 1057                 The IDENTITY function cannot be used with a SELECT INTO statement containing
                      a UNION operator.
 1058                 Cannot specify both READ_ONLY and FOR READ ONLY on a cursor declaration.
 1059                 Cannot set or reset the %ls option within a procedure.
 1060                 The number of rows in the TOP clause must be an integer.
 1061                 The text/ntext/image constants are not yet implemented.
 1062                 The TOP N WITH TIES clause is not allowed without a corresponding ORDER
                      BY clause.
 1063                 A filegroup cannot be added using ALTER DATABASE ADD FILE. Use ALTER
                      DATABASE ADD FILEGROUP.
 1064                 A filegroup cannot be used with log files.
 1065                 The NOLOCK, READUNCOMMITTED, and READPAST lock hints are only allowed
                      in a SELECT statement.
 1066                 Warning. Line %d: The option '%ls' is obsolete and has no effect.
 1067                 The SET SHOWPLAN statements must be the only statements in the batch.
 1068                 Only one list of index hints per table is allowed.
 1069                 Index hints are only allowed in a FROM clause.
 1070                 CREATE INDEX option '%.*ls' is no longer supported.




124                                                                            InterSystems Error Reference
                                                                                              TSQL Error Messages


 Error Code                    Description
 1071                          Cannot specify a JOIN algorithm with a remote JOIN.
 1072                          A REMOTE hint can only be specified with an INNER JOIN clause.
 1073                          '%.*ls' is not a recognized cursor option for cursor %.*ls.
 1074                          Creation of temporary functions is not allowed.
 1075                          RETURN statements in scalar valued functions must include an argument.
 1076                          Function '%s' requires at least %d argument(s).
 1077                          INSERT into an identity column not allowed on table variables.
 1078                          '%.*ls %.*ls' is not a recognized option.
 1079                          A variable cannot be used to specify a search condition in a fulltext predicate
                               when accessed through a cursor.

Table 3–12:TSQL Error Codes - 1100 to 1199

 Error Code                    Description
 1101                          Could not allocate new page for database '%.*ls'. There are no more pages
                               available in filegroup %.*ls. Space can be created by dropping objects, adding
                               additional files, or allowing file growth.
 1102                          IAM page %S_PGID for object ID %ld is incorrect. The %S_MSG ID on page is
                               %ld; should be %ld. The entry in sysindexes may be incorrect or the IAM page
                               may contain an error.
 1103                          Allocation page %S_PGID in database '%.*ls' has different segment ID than that
                               of the object which is being allocated to. Run DBCC CHECKALLOC.
 1105                          Could not allocate space for object '%.*ls' in database '%.*ls' because the '%.*ls'
                               filegroup is full.
 1109                          Could not read allocation page %S_PGID because either the object ID (%ld) is
                               not correct, or the page ID (%S_PGID) is not correct.




InterSystems Error Reference                                                                                     125
TSQL Error Messages


Table 3–13:TSQL Error Codes - 1200 to 1299

 Error Code                Description
 1201                      The page_lock system function was called with a mode %d that is not permitted.
 1203                      Process ID %d attempting to unlock unowned resource %.*ls.
 1204                      The SQL Server cannot obtain a LOCK resource at this time. Rerun your statement
                           when there are fewer active users or ask the system administrator to check the
                           SQL Server lock and memory configuration.
 1205                      Transaction (Process ID %d) was deadlocked on {%Z} resources with another
                           process and has been chosen as the deadlock victim. Rerun the transaction.
 1206                      Transaction manager has canceled the distributed transaction.
 1211                      Process ID %d was chosen as the deadlock victim with P_BACKOUT bit set.
 1220                      No more lock classes available from transaction.
 1221                      Invalid lock class for release call.
 1222                      Lock request time out period exceeded.
 1223                      Attempting to release application lock '%.*ls' that is not currently held.


Table 3–14:TSQL Error Codes - 1500 to 1599

 Error Code                Description
 1501                      Sort failure.
 1505                      CREATE UNIQUE INDEX terminated because a duplicate key was found for
                           index ID %d. Most significant primary key is '%S_KEY'.
 1507                      Warning: Deleted duplicate row. Primary key is '%S_KEY'.
 1508                      CREATE INDEX terminated because a duplicate row was found. Primary key is
                           '%S_KEY'.
 1509                      Row compare failure.
 1510                      Sort failed. Out of space or locks in database '%.*ls'.
 1511                      Sort cannot be reconciled with transaction log.
 1522                      Sort failure. Prevented overwriting of allocation page in database '%.*ls' by
                           terminating sort.
 1523                      Sort failure. Prevented incorrect extent deallocation by aborting sort.
 1528                      Character data comparison failure. An unrecognized Sort-Map-Element type (%d)
                           was found in the server-wide default sort table at SMEL entry [%d].
 1529                      Character data comparison failure. A list of Sort-Map-Elements from the
                           server-wide default sort table does not end properly. This list begins at SMEL
                           entry [%d].
 1530                      CREATE INDEX with DROP_EXISTING was aborted because a row was out of
                           order. Most significant offending primary key is '%S_KEY'. Explicitly drop and
                           create the index instead.




126                                                                                  InterSystems Error Reference
                                                                                               TSQL Error Messages


 Error Code                    Description
 1531                          The SORTED_DATA_REORG option cannot be used for a nonclustered index if
                               the keys are not unique within the table. CREATE INDEX was aborted because
                               of duplicate keys. Primary key is '%S_KEY'.
 1532                          New sort run starting on page %S_PGID found extent not marked as shared.
 1533                          Cannot share extent %S_PGID among more than eight sort runs.
 1534                          Extent %S_PGID not found in shared extent directory.
 1535                          Cannot share extent %S_PGID with shared extent directory full.
 1536                          Cannot build a nonclustered index on a memory-only work table.
 1537                          Cannot suspend a sort not in row input phase.
 1538                          Cannot insert into a sort not in row input phase.
 1540                          Cannot sort a row of size %d, which is greater than the allowable maximum of
                               %d.

Table 3–15:TSQL Error Codes - 1600 to 1699

 Error Code                    Description
 1619                          Could not open tempdb. Cannot continue.
 1620                          Cannot start C2 audit trace. SQL Server is shutting down.
 1621                          Server started with '-f'. Auditing will not be started.


Table 3–16:TSQL Error Codes - 1700 to 1799

 Error Code                    Description
 1701                          Creation of table '%.*ls' failed because the row size would be %d, including internal
                               overhead. This exceeds the maximum allowable table row size, %d.
 1702                          CREATE TABLE failed because column '%.*ls' in table '%.*ls' exceeds the
                               maximum of %d columns.
 1703                          Could not allocate disk space for a work table in database '%.*ls'. You may be
                               able to free up space by using BACKUP LOG, or you may want to extend the
                               size of the database by using ALTER DATABASE.
 1704                          Only members of the sysadmin role can create the system table '%.*ls'.
 1705                          You must create system table '%.*ls' in the master database.
 1706                          System table '%.*ls' was not created, because ad hoc updates to system catalogs
                               are not enabled.
 1708                          Warning: The table '%.*ls' has been created but its maximum row size (%d)
                               exceeds the maximum number of bytes per row (%d). INSERT or UPDATE of a
                               row in this table will fail if the resulting row length exceeds %d bytes.
 1709                          Cannot use TEXTIMAGE_ON when a table has no text, ntext, or image columns.
 1750                          Could not create constraint. See previous errors.




InterSystems Error Reference                                                                                     127
TSQL Error Messages


 Error Code           Description
 1752                 Could not create DEFAULT for column '%.*ls' as it is not a valid column in the
                      table '%.*ls'.
 1753                 Column '%.*ls.%.*ls' is not the same length as referencing column '%.*ls.%.*ls'
                      in foreign key '%.*ls'.
 1754                 Defaults cannot be created on columns with an IDENTITY attribute. Table '%.*ls',
                      column '%.*ls'.
 1755                 Defaults cannot be created on columns of data type timestamp. Table '%.*ls',
                      column '%.*ls'.
 1756                 Skipping FOREIGN KEY constraint '%.*ls' definition for temporary table.
 1757                 Column '%.*ls.%.*ls' is not of same collation as referencing column '%.*ls.%.*ls'
                      in foreign key '%.*ls'.
 1759                 Invalid column '%.*ls' is specified in a constraint or computed-column definition.
 1760                 Constraints of type %ls cannot be created on columns of type %ls.
 1763                 Cross-database foreign key references are not supported. Foreign key '%.*ls'.
 1766                 Foreign key references to temporary tables are not supported. Foreign key '%.*ls'.
 1767                 Foreign key '%.*ls' references invalid table '%.*ls'.
 1768                 Foreign key '%.*ls' references object '%.*ls' which is not a user table.
 1769                 Foreign key '%.*ls' references invalid column '%.*ls' in referencing table '%.*ls'.
 1770                 Foreign key '%.*ls' references invalid column '%.*ls' in referenced table '%.*ls'.
 1772                 Foreign key '%.*ls' defines an invalid relationship between a user table and system
                      table.
 1773                 Foreign key '%.*ls' has implicit reference to object '%.*ls' which does not have a
                      primary key defined on it.
 1774                 The number of columns in the referencing column list for foreign key '%.*ls' does
                      not match those of the primary key in the referenced table '%.*ls'.
 1776                 There are no primary or candidate keys in the referenced table '%.*ls' that match
                      the referencing column list in the foreign key '%.*ls'.
 1777                 User does not have correct permissions on referenced table '%.*ls' to create
                      foreign key '%.*ls'.
 1778                 Column '%.*ls.%.*ls' is not the same data type as referencing column '%.*ls.%.*ls'
                      in foreign key '%.*ls'.
 1779                 Table '%.*ls' already has a primary key defined on it.
 1780                 Could not find column ID %d in syscolumns for object ID %d in database ID %d.
 1781                 Column already has a DEFAULT bound to it.
 1784                 Cannot create the foreign key '%.*ls' because the referenced column '%.*ls.%.*ls'
                      is a computed column.




128                                                                            InterSystems Error Reference
                                                                                                TSQL Error Messages


 Error Code                    Description
 1785                          Introducing FOREIGN KEY constraint '%.*ls' on table '%.*ls' may cause cycles
                               or multiple cascade paths. Specify ON DELETE NO ACTION or ON UPDATE
                               NO ACTION, or modify other FOREIGN KEY constraints.
 1786                          Either column '%.*ls.%.*ls' or referencing column '%.*ls.%.*ls' in foreign key '%.*ls'
                               is a timestamp column. This data type cannot be used with cascading referential
                               integrity constraints.
 1787                          Cannot define foreign key constraint '%.*ls' with cascaded DELETE or UPDATE
                               on table '%.*ls' because the table has an INSTEAD OF DELETE or UPDATE
                               TRIGGER defined on it.
 1788                          Cascading foreign key '%.*ls' cannot be created where the referencing column
                               '%.*ls.%.*ls' is an identity column.
 1789                          Cannot use CHECKSUM(*) in a computed column definition.

Table 3–17:TSQL Error Codes - 1800 to 1899

 Error Code                    Description
 1801                          Database '%.*ls' already exists.
 1802                          CREATE DATABASE failed. Some file names listed could not be created. Check
                               previous errors.
 1803                          CREATE DATABASE failed. Could not allocate enough disk space for a new
                               database on the named disks. Total space allocated must be at least %d MB to
                               accommodate a copy of the model database.
 1804                          There is no disk named '%.*ls'. Checking other disk names.
 1805                          The CREATE DATABASE process is allocating %.2f MB on disk '%.*ls'.
 1806                          CREATE DATABASE failed. The default collation of database '%.*ls' cannot be
                               set to '%.*ls'.
 1807                          Could not obtain exclusive lock on database '%.*ls'. Retry the operation later.
 1808                          Default devices are not supported.
 1809                          To achieve optimal performance, update all statistics on the '%.*ls' database by
                               running sp_updatestats.
 1811                          '%.*ls' is the wrong type of device for CREATE DATABASE or ALTER DATABASE.
                               Check sysdevices. The statement is aborted.
 1812                          CREATE DATABASE failed. COLLATE clause cannot be used with the FOR
                               ATTACH option.
 1813                          Could not open new database '%.*ls'. CREATE DATABASE is aborted.
 1814                          Could not create tempdb. If space is low, extend the amount of space and restart.
 1818                          Primary log file '%ls' is missing and the database was not cleanly shut down so
                               it cannot be rebuilt.
 1819                          Could not create default log file because the name was too long.
 1820                          Disk '%.*ls' is already completely used by other databases. It can be expanded
                               with DISK RESIZE.



InterSystems Error Reference                                                                                      129
TSQL Error Messages


 Error Code                Description
 1826                      User-defined filegroups are not allowed on '%hs'.
 1827                      CREATE/ALTER DATABASE failed because the resulting cumulative database
                           size would exceed your licensed limit of %d MB per %S_MSG.
 1828                      The file named '%.*ls' is already in use. Choose another name.
 1829                      The FOR ATTACH option requires that at least the primary file be specified.
 1830                      The files '%.*ls' and '%.*ls' are both primary files. A database can only have one
                           primary file.
 1832                      Could not attach database '%.*ls' to file '%.*ls'.
 1833                      File '%ls' cannot be reused until after the next BACKUP LOG operation.
 1834                      The file '%ls' cannot be overwritten. It is being used by database '%.*ls'.
 1835                      Unable to create/attach any new database because the number of existing
                           databases has reached the maximum number allowed: %d.

Table 3–18:TSQL Error Codes - 1900 to 1999

 Error Code                Description
 1901                      Column '%.*ls'. Cannot create index on a column of bit data type.
 1902                      Cannot create more than one clustered index on table '%.*ls'. Drop the existing
                           clustered index '%.*ls' before creating another.
 1903                      Index keys are too large. The %d bytes needed to represent the keys for index
                           %d exceeds the size limit of %d bytes.
 1904                      Cannot specify more than %d column names for statistics or index key list. %d
                           specified.
 1905                      Could not find 'zero' row for index '%.*ls' the table in sysindexes.
 1906                      Cannot create an index on '%.*ls', because this table does not exist in database
                           '%.*ls'.
 1907                      Cannot re-create index '%.*ls'. The new index definition does not match the
                           constraint being enforced by the existing index.
 1909                      Cannot use duplicate column names in index key list. Column name '%.*ls' listed
                           more than once.
 1910                      Cannot create more than %d nonclustered indices or column statistics on one
                           table.
 1911                      Column name '%.*ls' does not exist in the target table.
 1913                      There is already an index on table '%.*ls' named '%.*ls'.
 1914                      Index cannot be created on object '%.*ls' because the object is not a user table
                           or view.
 1916                      CREATE INDEX options %ls and %ls are mutually exclusive.
 1918                      Index (ID = %d) is being rebuilt.




130                                                                                  InterSystems Error Reference
                                                                                               TSQL Error Messages


 Error Code                    Description
 1919                          Column '%.*ls'. Cannot create index on a column of text, ntext, or image data
                               type.
 1920                          Skipping rebuild of index ID %d, which is on a read-only filegroup.
 1921                          Invalid filegroup '%.*ls' specified.
 1922                          Filegroup '%.*ls' has no files assigned to it. Tables, indexes, and text, ntext, and
                               image columns cannot be created on this filegroup.
 1923                          The clustered index has been dropped.
 1924                          Filegroup '%.*ls' is read-only.
 1925                          Cannot convert a clustered index to a nonclustered index using the
                               DROP_EXISTING option.
 1926                          Cannot create a clustered index because nonclustered index ID %d is on a
                               read-only filegroup.
 1927                          There are already statistics on table '%.*ls' named '%.*ls'.
 1928                          Cannot create statistics on table '%.*ls' because this table does not exist in
                               database '%.*ls'.
 1929                          Statistics cannot be created on object '%.*ls' because the object is not a user
                               table or view.
 1931                          Filegroup '%.*ls' is offline.
 1932                          Cannot create a clustered index because nonclustered index ID %d is on an
                               offline filegroup.
 1933                          Cannot create index because the key column '%.*ls' is non-deterministic or
                               imprecise.
 1934                          %ls failed because the following SET options have incorrect settings: '%.*ls'.
 1935                          Cannot create index. Object '%.*ls' was created with the following SET options
                               off: '%.*ls'.
 1936                          Cannot %ls the %S_MSG '%.*ls'. It contains one or more disallowed constructs.
 1937                          Cannot index the view '%.*ls'. It references another view or function '%.*ls'.
 1938                          Index cannot be created on %S_MSG '%.*ls' because the underlying object '%.*ls'
                               has a different owner.
 1939                          Cannot create %S_MSG on view '%.*ls' because the view is not schema bound.
 1940                          Cannot create %S_MSG on view '%.*ls'. It does not have a unique clustered
                               index.
 1941                          Nonunique clustered index cannot be created on view '%.*ls' because only unique
                               clustered indexes are allowed.
 1942                          Index cannot be created on view '%.*ls' because the view contains text, ntext or
                               image columns.
 1943                          Index cannot be created on view '%.*ls' because the view has one or more
                               nondeterministic expressions.




InterSystems Error Reference                                                                                     131
TSQL Error Messages


 Error Code           Description
 1944                 Index '%.*ls' was not created. This index has a key length of at least %d bytes.
                      The maximum permissible key length is %d bytes.
 1945                 Warning! The maximum key length is %d bytes. The index '%.*ls' has maximum
                      length of %d bytes. For some combination of large values, the insert/update
                      operation will fail.
 1946                 Operation failed. The index entry of length %d bytes for the index '%.*ls' exceeds
                      the maximum length of %d bytes.
 1947                 Index cannot be created on view '%.*ls' because the view contains a self-join on
                      '%.*ls'.
 1948                 Duplicate index names '%.*ls' and '%.*ls' detected on table '%.*ls'.
 1949                 Index on view '%.*ls' cannot be created because function '%s' yields
                      nondeterministic results.
 1950                 Index on view '%.*ls' cannot be created because the view contains an imprecise
                      expression in a GROUP BY clause
 1951                 Index on view '%.*ls' cannot be created because the view contains an imprecise
                      expression in the WHERE clause.
 1952                 Index on view '%.*ls' cannot be created because the view contains an imprecise
                      expression in a join.
 1953                 Index on view '%.*ls' cannot be created because some arguments are missing in
                      a built-in function.
 1954                 Index on view '%.*ls' cannot be created because the view uses a column bound
                      to a rule.
 1955                 Index on view '%.*ls' cannot be created because the view contains a
                      nondeterministic computed column.
 1956                 Index on view '%.*ls' cannot be created because the view uses a nondeterministic
                      user-defined function.
 1957                 Index on view '%.*ls' cannot be created because the view requires a conversion
                      involving dates or variants.
 1958                 This edition of SQL Server does not support indexed views.
 1959                 Cannot create index on view or computed column because this database is not
                      SQL Server compatible.




132                                                                          InterSystems Error Reference
                                                                                               TSQL Error Messages


Table 3–19:TSQL Error Codes - 2000 to 2099

 Error Code                    Description
 2001                          Cannot use duplicate parameter names. Parameter name '%.*ls' listed more than
                               once.
 2004                          Procedure '%.*ls' has already been created with group number %d. Create
                               procedure with an unused group number.
 2007                          Cannot add rows to sysdepends for the current stored procedure because it
                               depends on the missing object '%.*ls'. The stored procedure will still be created.
 2008                          The object '%.*ls' is not a procedure so you cannot create another procedure
                               under that group name.
 2009                          Procedure '%.*ls' was created despite delayed name resolution warnings (if any).
 2010                          Cannot perform alter on %.*ls because it is an incompatible object type.
 2011                          Index hints cannot be specified within a schema-bound object.
 2012                          User-defined variables cannot be declared within a schema-bound object.


Table 3–20:TSQL Error Codes - 2100 to 2199

 Error Code                    Description
 2106                          Cannot create a trigger on table '%.*ls', because this table does not exist in
                               database '%.*ls'.
 2108                          Cannot create a trigger on table '%.*ls' because you can only create a trigger on
                               a table in the current database.
 2110                          Cannot alter trigger '%.*ls' for table '%.*ls' because this trigger does not belong
                               to this table.
 2111                          Cannot %s trigger '%.*ls' for %S_MSG '%.*ls' because an INSTEAD OF %s trigger
                               already exists.
 2112                          Cannot %s trigger '%.*ls' for view '%.*ls' because it is defined with the CHECK
                               OPTION.
 2113                          Cannot %s INSTEAD OF DELETE or UPDATE TRIGGER '%.*ls' on table '%.*ls'
                               because the table has a FOREIGN KEY with cascaded DELETE or UPDATE.
 2114                          Column '%.*ls' cannot be used in an IF UPDATE clause because it is a computed
                               column.


Table 3–21:TSQL Error Codes - 2500 to 2599

 Error Code                    Description
 2501                          Could not find a table or object named '%.*ls'. Check sysobjects.
 2502                          Could not start transaction.
 2503                          Successfully deleted the physical file '%ls'.
 2504                          Could not delete the physical file '%ls'. The DeleteFile system function returned
                               error %ls.



InterSystems Error Reference                                                                                     133
TSQL Error Messages


 Error Code           Description
 2505                 The device '%.*ls' does not exist. Use sp_helpdevice to show available devices.
 2506                 Could not find a table or object name '%.*ls' in database '%.*ls'.
 2511                 Table error: Object ID %d, Index ID %d. Keys out of order on page %S_PGID,
                      slots %d and %d.
 2512                 Table error: Object ID %d, Index ID %d. Duplicate keys on page %S_PGID slot
                      %d and page %S_PGID slot %d.
 2513                 Table error: Object ID %ld (object '%.*ls') does not match between '%.*ls' and
                      '%.*ls'.
 2514                 Table error: Data type %ld (type '%.*ls') does not match between '%.*ls' and
                      '%.*ls'.
 2515                 Page %S_PGID, object ID %d, index ID %d has been modified but is not marked
                      modified in the differential backup bitmap.
 2516                 The differential bitmap was invalidated for database %.*ls. A full database backup
                      is required before a differential backup can be performed.
 2517                 The minimally logged operation status has been turned on for database %.*ls.
                      Rerun backup log operations to ensure that all data has been secured.
 2519                 Unable to process table %.*ls because filegroup %.*ls is invalid.
 2520                 Could not find database '%.*ls'. Check sysdatabases.
 2521                 Could not find database ID %d. Check sysdatabases.
 2522                 Unable to process index %.*ls of table %.*ls because filegroup %.*ls is invalid.
 2523                 Filegroup %.*ls is invalid.
 2524                 Unable to process table %.*ls because filegroup %.*ls is offline.
 2525                 Database file %.*ls is offline.
 2526                 Incorrect DBCC statement. Check the documentation for the correct DBCC syntax
                      and options.
 2527                 Unable to process index %.*ls of table %.*ls because filegroup %.*ls is offline.
 2528                 DBCC execution completed. If DBCC printed error messages, contact your system
                      administrator.
 2529                 Filegroup %.*ls is offline.
 2530                 Secondary index entries were missing or did not match the data in the table. Use
                      the WITH TABLOCK option and run the command again to display the failing
                      records.
 2531                 Table error: Object ID %d, index ID %d B-tree level mismatch, page %S_PGID.
                      Level %d does not match level %d from previous %S_PGID.
 2532                 DBCC SHRINKFILE could not shrink file %ls. Log files are not supported.
 2533                 Table error: Page %S_PGID allocated to object ID %d, index ID %d was not seen.
                      Page may be invalid or have incorrect object ID information in its header.




134                                                                           InterSystems Error Reference
                                                                                                 TSQL Error Messages


 Error Code                    Description
 2534                          Table error: Page %S_PGID with object ID %d, index ID %d in its header is
                               allocated by another object.
 2535                          Table error: Page %S_PGID is allocated to object ID %d, index ID %d, not to
                               object ID %d, index ID %d found in page header.
 2536                          DBCC results for '%.*ls'.
 2537                          Table error: Object ID %d, index ID %d, page %S_PGID, row %d. Record check
                               (%hs) failed. Values are %ld and %ld.
 2538                          File %d. Number of extents = %ld, used pages = %ld, reserved pages = %ld.
 2539                          Total number of extents = %ld, used pages = %ld, reserved pages = %ld in this
                               database.
 2540                          The system cannot self repair this error.
 2541                          DBCC UPDATEUSAGE: sysindexes row updated for table '%.*ls' (index ID %ld):
 2542                          DATA pages: Changed from (%ld) to (%ld) pages.
 2543                          USED pages: Changed from (%ld) to (%ld) pages.
 2544                          RSVD pages: Changed from (%ld) to (%ld) pages.
 2545                          ROWS count: Changed from (%I64d) to (%I64d) rows.
 2546                          Index '%.*ls' on table '%.*ls' is marked offline. Rebuild the index to bring it online.
 2547                          Performing second pass of index checks.
 2548                          DBCC: Compaction phase of index '%.*ls' is %d%% complete.
 2549                          DBCC: Defrag phase of index '%.*ls' is %d%% complete.
 2557                          User '%.*ls' does not have permission to run DBCC %ls for object '%.*ls'.
 2559                          The '%ls' and '%ls' options are not allowed on the same statement.
 2560                          Parameter %d is incorrect for this DBCC statement.
 2562                          '%ls' cannot access object '%.*ls' because it is not a table.
 2566                          DBCC DBREINDEX cannot be used on system tables.
 2567                          DBCC INDEXDEFRAG cannot be used on system table indexes
 2568                          Page %S_PGID is out of range for this database or is in a log file.
 2570                          Warning: Page %S_PGID, slot %d in Object %d Index %d Column %.*ls value
                               %.*ls is out of range for data type "%.*ls". Update column to a legal value.
 2571                          User '%.*ls' does not have permission to run DBCC %.*ls.
 2572                          DBCC cannot free DLL '%.*ls'. The DLL is in use.
 2573                          Database '%.*ls' is not marked suspect. You cannot drop it with DBCC.
 2574                          Object ID %d, index ID %d: Page %S_PGID is empty. This is not permitted at
                               level %d of the B-tree.
 2575                          IAM page %S_PGID is pointed to by the next pointer of IAM page %S_PGID
                               object ID %d index ID %d but was not detected in the scan.



InterSystems Error Reference                                                                                       135
TSQL Error Messages


 Error Code                Description
 2576                      IAM page %S_PGID is pointed to by the previous pointer of IAM page %S_PGID
                           object ID %d index ID %d but was not detected in the scan.
 2577                      Chain sequence numbers are out of order in IAM chain for object ID %d, index
                           ID %d. Page %S_PGID sequence number %d points to page %S_PGID sequence
                           number %d.
 2578                      Minimally logged extents were found in GAM interval starting at page %S_PGID
                           but the minimally logged flag is not set in the database table.
 2579                      Table error: Extent %S_PGID object ID %d, index ID %d is beyond the range of
                           this database.
 2580                      Table '%.*ls' is either a system or temporary table. DBCC CLEANTABLE cannot
                           be applied to a system or temporary table.
 2583                      An incorrect number of parameters was given to the DBCC statement.
 2588                      Page %S_PGID was expected to be the first page of a text, ntext, or image value.
 2590                      User '%.*ls' is modifying bytes %d to %d of page %S_PGID in database '%.*ls'.
 2591                      Could not find row in sysindexes with index ID %d for table '%.*ls'.
 2592                      %ls index successfully restored for object '%.*ls' in database '%.*ls'.
 2593                      There are %I64d rows in %ld pages for object '%.*ls'.
 2594                      Invalid index ID (%d) specified.
 2595                      Database '%.*ls' must be set to single user mode before executing this statement.
 2597                      The database is not open. Execute a 'USE %.*ls' statement and rerun the DBCC
                           statement.
 2598                      Clustered indexes on sysobjects and sysindexes cannot be re-created.

Table 3–22:TSQL Error Codes - 2600 to 2699

 Error Code                Description
 2601                      Cannot insert duplicate key row in object '%.*ls' with unique index '%.*ls'.
 2603                      No space left on logical page %S_PGID of index ID %d for object '%.*ls' when
                           inserting row on an index page. This situation should have been handled while
                           traversing the index.
 2617                      Buffer holding logical page %S_PGID not found in keep pool in SDES for object
                           '%.*ls'. Contact Technical Support.
 2624                      Could not insert into table %S_DES because row length %d is less than the
                           minimum length %d.
 2627                      Violation of %ls constraint '%.*ls'. Cannot insert duplicate key in object '%.*ls'.


Table 3–23:TSQL Error Codes - 2700 to 2799

 Error Code                Description
 2701                      Database name '%.*ls' ignored, referencing object in tempdb.




136                                                                                 InterSystems Error Reference
                                                                                              TSQL Error Messages


 Error Code                    Description
 2702                          Database '%.*ls' does not exist.
 2705                          Column names in each table must be unique. Column name '%.*ls' in table '%.*ls'
                               is specified more than once.
 2706                          Table '%.*ls' does not exist.
 2710                          You are not the owner specified for the object '%.*ls' in this statement (CREATE,
                               ALTER, TRUNCATE, UPDATE STATISTICS or BULK INSERT).
 2714                          There is already an object named '%.*ls' in the database.
 2715                          Column or parameter #%d: Cannot find data type %.*ls.
 2716                          Column or parameter #%d: Cannot specify a column width on data type %.*ls.
 2717                          The size (%d) given to the %S_MSG '%.*ls' exceeds the maximum allowed (%d).
 2718                          Column or parameter #%d: Cannot specify null values on a column of data type
                               bit.
 2721                          Could not find a default segment to create the table on. Ask your system
                               administrator to specify a default segment in syssegments.
 2724                          Parameter '%.*ls' has an invalid data type.
 2727                          Cannot find index '%.*ls'.
 2730                          Cannot create procedure '%.*ls' with a group number of %d because a procedure
                               with the same name and a group number of 1 does not currently exist in the
                               database. Must execute CREATE PROCEDURE '%.*ls';1 first.
 2731                          Column '%.*ls' has invalid width: %d.
 2732                          Error number %ld is invalid. The number must be from %ld through %ld
 2734                          The user name '%.*ls' does not exist in sysusers.
 2736                          Owner name specified is a group name. Objects cannot be owned by groups.
 2737                          Message passed to %hs must be of type char, varchar, nchar, or nvarchar.
 2738                          A table can only have one timestamp column. Because table '%.*ls' already has
                               one, the column '%.*ls' cannot be added.
 2739                          The text, ntext, and image data types are invalid for local variables.
 2740                          SET LANGUAGE failed because '%.*ls' is not an official language name or a
                               language alias on this SQL Server.
 2741                          SET DATEFORMAT date order '%.*ls' is invalid.
 2742                          SET DATEFIRST %d is out of range.
 2743                          %ls statement requires %S_MSG parameter.
 2744                          Multiple identity columns specified for table '%.*ls'. Only one identity column per
                               table is allowed.
 2745                          Process ID %d has raised user error %d, severity %d. SQL Server is terminating
                               this process.
 2746                          Cannot specify user error format string with a length exceeding %d bytes.



InterSystems Error Reference                                                                                    137
TSQL Error Messages


 Error Code           Description
 2747                 Too many substitution parameters for RAISERROR. Cannot exceed %d
                      substitution parameters.
 2748                 Cannot specify %ls data type (RAISERROR parameter %d) as a substitution
                      parameter for RAISERRROR.
 2749                 Identity column '%.*ls' must be of data type int, bigint, smallint, tinyint, or decimal
                      or numeric with a scale of 0, and constrained to be nonnullable.
 2750                 Column or parameter #%d: Specified column precision %d is greater than the
                      maximum precision of %d.
 2751                 Column or parameter #%d: Specified column scale %d is greater than the specified
                      precision of %d.
 2752                 Identity column '%.*ls' contains invalid SEED.
 2753                 Identity column '%.*ls' contains invalid INCREMENT.
 2754                 Error severity levels greater than %d can only be specified by members of the
                      sysadmin role, using the WITH LOG option.
 2755                 SET DEADLOCK_PRIORITY option '%.*ls' is invalid.
 2756                 Invalid value %d for state. Valid range is from %d to %d.
 2757                 RAISERROR failed due to invalid parameter substitution(s) for error %d, severity
                      %d, state %d.
 2758                 %hs could not locate entry for error %d in sysmessages.
 2759                 CREATE SCHEMA failed due to previous errors.
 2760                 Specified owner name '%.*ls' either does not exist or you do not have permission
                      to use it.
 2761                 The ROWGUIDCOL property can only be specified on the uniqueidentifier data
                      type.
 2762                 sp_setapprole was not invoked correctly. Refer to the documentation for more
                      information.
 2763                 Could not find application role '%.*ls'.
 2764                 Incorrect password supplied for application role '%.*ls'.
 2765                 Could not locate statistics for column '%.*ls' in the system catalogs.
 2766                 The definition for user-defined data type '%.*ls' has changed.
 2767                 Could not locate statistics '%.*ls' in the system catalogs.
 2768                 Statistics for %ls '%.*ls'.
 2769                 Column '%.*ls'. Cannot create statistics on a column of data type %ls.
 2770                 The SELECT INTO statement cannot have same source and destination tables.
 2771                 Cannot create statistics on table '%.*ls'. This table is a virtual system table.
 2772                 Cannot access temporary tables from within a function.
 2773                 Sort order ID %d is invalid.



138                                                                             InterSystems Error Reference
                                                                                             TSQL Error Messages


 Error Code                    Description
 2774                          Collation ID %d is invalid.
 2775                          Code page %d is not supported by the operating system.
 2777                          Database '%.*ls' contains columns or parameters with the following code page(s)
                               not supported by the operating system: %ls.

Table 3–24:TSQL Error Codes - 2800 to 2899

 Error Code                    Description
 2801                          The definition of object '%.*ls' has changed since it was compiled.
 2809                          The request for %S_MSG '%.*ls' failed because '%.*ls' is a %S_MSG object.
 2812                          Could not find stored procedure '%.*ls'.


Table 3–25:TSQL Error Codes - 3000 to 3099

 Error Code                    Description
 3009                          Could not insert a backup or restore history/detail record in the msdb database.
                               This may indicate a problem with the msdb database.The backup/restore operation
                               was still successful.
 3011                          All backup devices must be of the same general class (for example, DISK and
                               TAPE).
 3013                          %hs is terminating abnormally.
 3014                          %hs successfully processed %d pages in %d.%03d seconds (%d.%03d MB/sec).
 3015                          %hs is not yet implemented.
 3016                          File '%ls' of database '%ls' has been removed or shrunk since this backup or
                               restore operation was interrupted. The operation cannot be restarted.
 3017                          Could not resume interrupted backup or restore operation. See the SQL Server
                               error log for more information.
 3018                          There is no interrupted backup or restore operation to restart. Reissue the
                               statement without the RESTART clause.
 3019                          The checkpoint file was for a different backup or restore operation. Reissue the
                               statement without the RESTART clause.
 3020                          The backup operation cannot be restarted as the log has been truncated. Reissue
                               the statement without the RESTART clause.
 3021                          Cannot perform a backup or restore operation within a transaction.
 3023                          Backup and file manipulation operations (such as ALTER DATABASE ADD FILE)
                               on a database must be serialized. Reissue the statement after the current backup
                               or file manipulation operation is completed.
 3024                          You can only perform a full backup of the master database. Use BACKUP
                               DATABASE to back up the entire master database.
 3025                          Missing database name. Reissue the statement specifying a valid database name.




InterSystems Error Reference                                                                                  139
TSQL Error Messages


 Error Code                Description
 3026                      Could not find filegroup ID %d in sysfilegroups for database '%ls'.
 3027                      Could not find filegroup '%.*ls' in sysfilegroups for database '%.*ls'.
 3028                      Operation checkpoint file is invalid. Could not restart operation. Reissue the
                           statement without the RESTART option.
 3031                      Option '%ls' conflicts with option(s) '%ls'. Remove the conflicting option and reissue
                           the statement.
 3032                      One or more of the options (%ls) are not supported for this statement. Review
                           the documentation for supported options.
 3033                      BACKUP DATABASE cannot be used on a database opened in emergency mode.
 3034                      No files were selected to be processed. You may have selected one or more
                           filegroups that have no members.
 3035                      Cannot perform a differential backup for database '%ls', because a current
                           database backup does not exist. Perform a full database backup by reissuing
                           BACKUP DATABASE, omitting the WITH DIFFERENTIAL option.
 3036                      Database '%ls' is in warm-standby state (set by executing RESTORE WITH
                           STANDBY) and cannot be backed up until the entire load sequence is completed.
 3037                      Minimally logged operations have occurred prior to this WITH RESTART command.
                           Reissue the BACKUP statement without WITH RESTART.
 3038                      The filename '%ls' is invalid as a backup device name. Reissue the BACKUP
                           statement with a valid filename.
 3039                      Cannot perform a differential backup for file '%ls' because a current file backup
                           does not exist. Reissue BACKUP DATABASE omitting the WITH DIFFERENTIAL
                           option.
 3040                      An error occurred while informing replication of the backup. The backup will
                           continue, but the replication environment should be inspected.
 3041                      BACKUP failed to complete the command %.*ls

Table 3–26:TSQL Error Codes - 3100 to 3199

 Error Code                Description
 3101                      Exclusive access could not be obtained because the database is in use.
 3108                      RESTORE DATABASE must be used in single user mode when trying to restore
                           the master database.
 3110                      User does not have permission to RESTORE database '%.*ls'.
 3112                      Cannot restore any database other than master when the server is in single user
                           mode.
 3113                      The database owner (DBO) does not have an entry in sysusers in database '%.*ls'.
 3114                      Database '%.*ls' does not have an entry in sysdatabases.
 3123                      Invalid database name '%.*ls' specified for backup or restore operation.
 3127                      Temporary Message: The backup set does not contain pages for file '%ls'.



140                                                                                  InterSystems Error Reference
                                                                                                TSQL Error Messages


 Error Code                    Description
 3128                          File '%ls' has an unsupported page size (%d).
 3129                          Temporary Message: File '%ls' has changed size from %d to %d bytes.
 3132                          The media set for database '%ls' has %d family members but only %d are
                               provided. All members must be provided.
 3133                          The volume on device '%ls' is not a member of the media family.
 3135                          The backup set in file '%ls' was created by %hs and cannot be used for this restore
                               operation.
 3136                          Cannot apply the backup on device '%ls' to database '%ls'.
 3138                          One or more files in the backup set are no longer part of database '%ls'.
 3140                          Could not adjust the space allocation for file '%ls'.
 3141                          The database to be restored was named '%ls'. Reissue the statement using the
                               WITH REPLACE option to overwrite the '%ls' database.
 3142                          File '%ls' cannot be restored over the existing '%ls'. Reissue the RESTORE
                               statement using WITH REPLACE to overwrite pre-existing files.
 3143                          The data set on device '%ls' is not a SQL Server backup set.
 3144                          File '%.*ls' was not backed up in file %d on device '%ls'. The file cannot be restored
                               from this backup set.
 3145                          The STOPAT option is not supported for RESTORE DATABASE. You can use
                               the STOPAT option with RESTORE LOG.
 3146                          None of the newly-restored files had been modified after the backup was taken,
                               so no further recovery actions are required. The database is now available for
                               use.
 3147                          Backup and restore operations are not allowed on database tempdb.
 3148                          Media recovery for ALTER DATABASE is not yet implemented. The database
                               cannot be rolled forward.
 3150                          The master database has been successfully restored. Shutting down SQL Server.
 3151                          The master database failed to restore. Use the rebuildm utility to rebuild the master
                               database. Shutting down SQL Server.
 3152                          Cannot overwrite file '%ls' because it is marked as read-only.
 3153                          The database is already fully recovered.
 3154                          The backup set holds a backup of a database other than the existing '%ls'
                               database.
 3155                          The RESTORE operation cannot proceed because one or more files have been
                               added or dropped from the database since the backup set was created.
 3156                          File '%ls' cannot be restored to '%ls'. Use WITH MOVE to identify a valid location
                               for the file.
 3157                          The logical file (%d) is named '%ls'. RESTORE will not overwrite it from '%ls'.




InterSystems Error Reference                                                                                      141
TSQL Error Messages


 Error Code           Description
 3158                 Could not create one or more files. Consider using the WITH MOVE option to
                      identify valid locations.
 3159                 The tail of the log for database '%ls' has not been backed up. Back up the log
                      and rerun the RESTORE statement specifying the FILE clause.
 3160                 Could not update primary file information in sysdatabases.
 3161                 The primary file is unavailable. It must be restored or otherwise made available.
 3162                 The database has on-disk structure version %d. The server supports version %d
                      and can only restore such a database that was inactive when it was backed up.
                      This database was not inactive.
 3163                 The transaction log was damaged. All data files must be restored before RESTORE
                      LOG can be attempted.
 3164                 Cannot roll forward the database with on-disk structure version %d. The server
                      supports version %d. Reissue the RESTORE statement WITH RECOVERY.
 3165                 Could not adjust the replication state of database '%ls'. The database was
                      successfully restored, however its replication state is indeterminate. See the
                      Troubleshooting Replication section in SQL Server Books Online.
 3166                 RESTORE DATABASE could not drop database '%ls'. Drop the database and
                      then reissue the RESTORE DATABASE statement.
 3167                 RESTORE could not start database '%ls'.
 3168                 The backup of the system database on device %ls cannot be restored because
                      it was created by a different version of the server (%u) than this server (%u).
 3169                 The backed-up database has on-disk structure version %d. The server supports
                      version %d and cannot restore or upgrade this database.
 3170                 The STANDBY filename is invalid.
 3171                 Cannot restore file %ls because the file is offline.
 3172                 Cannot restore filegroup %ls because the filegroup is offline.
 3174                 The file '%ls' cannot be moved by this RESTORE operation.
 3175                 The filegroup '%ls' cannot be restored because all of the files are not present in
                      the backup set. File '%ls' is missing.
 3176                 File '%ls' is claimed by '%ls'(%d) and '%ls'(%d). The WITH MOVE clause can be
                      used to relocate one or more files.
 3177                 Only members of the dbcreator and sysadmin roles can execute the %ls statement.
 3178                 File %ls is not in the correct state to have this differential backup applied to it.
 3179                 The system database cannot be moved by RESTORE.
 3180                 This backup cannot be restored using WITH STANDBY because a database
                      upgrade is needed. Reissue the RESTORE without WITH STANDBY.




142                                                                             InterSystems Error Reference
                                                                                               TSQL Error Messages


Table 3–27:TSQL Error Codes - 3200 to 3299

 Error Code                    Description
 3201                          Cannot open backup device '%ls'. Device error or device off-line. See the SQL
                               Server error log for more details.
 3202                          Write on '%ls' failed, status = %ld. See the SQL Server error log for more details.
 3203                          Read on '%ls' failed, status = %ld. See the SQL Server error log for more details.
 3204                          Operator aborted backup or restore. See the error messages returned to the
                               console for more details.
 3205                          Too many backup devices specified for backup or restore; only %d are allowed.
 3206                          No entry in sysdevices for backup device '%.*ls'. Update sysdevices and rerun
                               statement.
 3207                          Backup or restore requires at least one backup device. Rerun your statement
                               specifying a backup device.
 3208                          Unexpected end of file while reading beginning of backup set. Confirm that the
                               media contains a valid SQL Server backup set, and see the console error log for
                               more details.
 3209                          '%.*ls' is not a backup device. Check sysdevices.
 3211                          %d percent %hs.
 3217                          Invalid value specified for %ls parameter.
 3221                          The ReadFileEx system function executed on file '%ls' only read %d bytes,
                               expected %d.
 3222                          The WriteFileEx system function executed on file '%ls' only wrote %d bytes,
                               expected %d.
 3224                          Cannot create worker thread.
 3227                          The volume on device '%ls' is a duplicate of stripe set member %d.
 3229                          Request for device '%ls' timed out.
 3230                          Operation on device '%ls' exceeded retry count.
 3234                          Logical file '%.*ls' is not part of database '%ls'. Use RESTORE FILELISTONLY
                               to list the logical file names.
 3235                          File '%ls' is not part of database '%ls'. You can only list files that are members of
                               this database.
 3237                          Option not supported for Named Pipe-based backup sets.
 3239                          The backup set on device '%ls' uses a feature of the Microsoft Tape Format not
                               supported by SQL Server.
 3241                          The media family on device '%ls' is incorrectly formed. SQL Server cannot process
                               this media family.
 3242                          The file on device '%ls' is not a valid Microsoft Tape Format backup set.
 3243                          The media family on device '%ls' was created using Microsoft Tape Format version
                               %d.%d. SQL Server supports version %d.%d.



InterSystems Error Reference                                                                                     143
TSQL Error Messages


 Error Code           Description
 3244                 Descriptor block size exceeds %d bytes. Use a shorter name and/or description
                      string and retry the operation.
 3245                 Could not convert a string to or from Unicode, %ls.
 3246                 The media family on device '%ls' is marked as nonappendable. Reissue the
                      statement using the INIT option to overwrite the media.
 3247                 The volume on device '%ls' has the wrong media sequence number (%d). Remove
                      it and insert volume %d.
 3248                 >>> VOLUME SWITCH <<< (not for output!)
 3249                 The volume on device '%ls' is a continuation volume for the backup set. Remove
                      it and insert the volume holding the start of the backup set.
 3250                 The value '%d' is not within range for the %ls parameter.
 3251                 The media family on device '%ls' is complete. The device is now being reused
                      for one of the remaining families.
 3253                 The block size parameter must supply a value that is a power of 2.
 3254                 The volume on device '%ls' is empty.
 3255                 The data set on device '%ls' is a SQL Server backup set not compatible with this
                      version of SQL Server.
 3256                 The backup set on device '%ls' was terminated while it was being created and is
                      incomplete. RESTORE sequence is terminated abnormally.
 3257                 There is insufficient free space on disk volume '%ls' to create the database. The
                      database requires %I64u additional free bytes, while only %I64u bytes are
                      available.
 3258                 The volume on device '%ls' belongs to a different media set.
 3259                 The volume on device '%ls' is not part of a multiple family media set. BACKUP
                      WITH FORMAT can be used to form a new media set.
 3260                 An internal buffer has become full.
 3261                 SQL Server cannot use the virtual device configuration.
 3262                 The backup set is valid.
 3263                 Cannot use the volume on device '%ls' as a continuation volume. It is sequence
                      number %d of family %d for the current media set. Insert a new volume, or
                      sequence number %d of family %d for the current set.
 3264                 The operation did not proceed far enough to allow RESTART. Reissue the
                      statement without the RESTART qualifier.
 3265                 The login has insufficient authority. Membership of the sysadmin role is required
                      to use VIRTUAL_DEVICE with BACKUP or RESTORE.
 3266                 The backup data in '%ls' is incorrectly formatted. Backups cannot be appended,
                      but existing backup sets may still be usable.
 3267                 Insufficient resources to create UMS scheduler.




144                                                                         InterSystems Error Reference
                                                                                               TSQL Error Messages


 Error Code                    Description
 3268                          Cannot use the backup file '%ls' because it was originally formatted with sector
                               size %d and is now on a device with sector size %d.
 3269                          Cannot restore the file '%ls' because it was originally written with sector size %d;
                               '%ls' is now on a device with sector size %d.
 3270                          An internal consistency error occurred. Contact Technical Support for assistance.
 3271                          Nonrecoverable I/O error occurred on file '%ls'.
 3272                          The '%ls' device has a hardware sector size of %d, but the block size parameter
                               specifies an incompatible override value of %d. Reissue the statement using a
                               compatible block size.
 3273                          The BUFFERCOUNT parameter must supply a value that allows at least one
                               buffer per backup device.
 3274                          Incorrect checksum computed for the backup set on device %ls. The backup set
                               cannot be restored.
 3275                          I/O request 0x%08x failed I/O verification. See the error log for a description.
 3276                          WITH SNAPSHOT can be used only if the backup set was created WITH
                               SNAPSHOT.
 3277                          WITH SNAPSHOT must be used with only one virtual device.
 3278                          Failed to encrypt string %ls
 3279                          Access is denied due to a password failure
 3280                          Backups on raw devices are not supported. '%ls' is a raw device.
 3281                          Released and initiated rewind on '%ls'.

Table 3–28:TSQL Error Codes - 3300 to 3399

 Error Code                    Description
 3301                          Invalid log record found in the transaction log (logop %d).
 3313                          Error while redoing logged operation in database '%.*ls'. Error at log record ID
                               %S_LSN.
 3314                          Error while undoing logged operation in database '%.*ls'. Error at log record ID
                               %S_LSN.
 3315                          During rollback, process %d was expected to hold mode %d lock at level %d for
                               row %S_RID in database '%.*ls' under transaction %S_XID.


Table 3–29:TSQL Error Codes - 3400 to 3499

 Error Code                    Description
 3405                          Recovering database '%.*ls'.
 3406                          %d transactions rolled forward in database '%.*ls' (%d).
 3407                          %d transactions rolled back in database '%.*ls' (%d).
 3408                          Recovery complete.



InterSystems Error Reference                                                                                      145
TSQL Error Messages


 Error Code           Description
 3413                 Database ID %d. Could not mark database as suspect. Getnext NC scan on
                      sysdatabases.dbid failed.
 3414                 Database '%.*ls' (database ID %d) could not recover. Contact Technical Support.
 3415                 Database '%.*ls' is read-only or has read-only files and must be made writable
                      before it can be upgraded.
 3417                 Cannot recover the master database. Exiting.
 3429                 Warning: The outcome of transaction %S_XID, named '%.*ls' in database '%.*ls'
                      (database ID %d), could not be determined because the coordinating database
                      (database ID %d) could not be opened. The transaction was assumed to be
                      committed.
 3430                 Warning: Could not determine the outcome of transaction %S_XID, named '%.*ls'
                      in database '%.*ls' (with ID %d) because the coordinating database (ID %d) did
                      not contain the outcome. The transaction was assumed to be committed.
 3431                 Could not recover database '%.*ls' (database ID %d) due to unresolved transaction
                      outcomes.
 3432                 Warning: syslanguages is missing.
 3433                 Name is truncated to '%.*ls'. The maximum name length is %d.
 3434                 Cannot change sort order or locale. Server shutting down. Restart SQL Server
                      to continue with sort order unchanged.
 3435                 Sort order or locale cannot be changed because user objects or user databases
                      exist.
 3436                 Cannot rebuild index for the '%.*ls' table in the '%.*ls' database.
 3437                 Error recovering database '%.*ls'. Could not connect to MSDTC to check the
                      completion status of transaction %S_XID.
 3438                 Database '%.*ls' (database ID %d) failed to recover because transaction first LSN
                      is not equal to LSN in checkpoint. Contact Technical Support.
 3439                 Database '%.*ls' (database ID %d). The DBCC RECOVERDB statement failed
                      due to previous errors.
 3440                 Database '%.*ls' (database ID %d). The DBCC RECOVERDB statement can only
                      be run after a RESTORE statement that used the WITH NORECOVERY option.
 3441                 Database '%.*ls' (database ID %d). The RESTORE statement could not access
                      file '%ls'. Error was '%ls'.
 3442                 Database '%.*ls' (database ID %d). The size of the undo file is insufficient.
 3443                 Database '%.*ls' (database ID %d) was marked for standby or read-only use, but
                      has been modified. The RESTORE LOG statement cannot be performed.
 3445                 File '%ls' is not a valid undo file for database '%.*ls', database ID %d.
 3446                 Primary log file is not available for database '%.*ls'. The log cannot be backed
                      up.
 3447                 Could not activate or scan all of the log files for database '%.*ls'.




146                                                                             InterSystems Error Reference
                                                                                            TSQL Error Messages


 Error Code                    Description
 3448                          Could not undo log record %S_LSN, for transaction ID %S_XID, on page
                               %S_PGID, database '%.*ls' (database ID %d). Page information: LSN = %S_LSN,
                               type = %ld. Log information: OpCode = %ld, context %ld.
 3449                          An error has occurred that requires SQL Server to shut down so that recovery
                               can be performed on database ID %d.
 3450                          Recovery of database '%.*ls' (%d) is %d%% complete (approximately %d more
                               seconds) (Phase %d of 3).
 3451                          Recovery has failed because reexecution of CREATE INDEX found inconsistencies
                               between target filegroup '%ls' (%d) and source filegroup '%ls' (%d). Restore both
                               filegroups before attempting further RESTORE LOG operations.
 3452                          Recovery of database '%.*ls' (%d) detected possible identity value inconsistency
                               in table ID %d. Run DBCC CHECKIDENT ('%.*ls').
 3453                          This version cannot redo any index creation or non-logged operation done by
                               SQL Server 7.0. Further roll forward is not possible.
 3454                          Recovery is checkpointing database '%.*ls' (%d)
 3455                          Analysis of database '%.*ls' (%d) is %d%% complete (approximately %d more
                               seconds)
 3456                          Could not redo log record %S_LSN, for transaction ID %S_XID, on page
                               %S_PGID, database '%.*ls' (%d). Page: LSN = %S_LSN, type = %ld. Log: OpCode
                               = %ld, context %ld, PrevPageLSN: %S_LSN.

Table 3–30:TSQL Error Codes - 3500 to 3599

 Error Code                    Description
 3501                          Could not find row in sysdatabases for database ID %d at checkpoint time.
 3505                          Only the owner of database '%.*ls' can run the CHECKPOINT statement.
 3508                          Could not get an exclusive lock on the database '%.*ls'. Make sure that no other
                               users are currently using this database, and rerun the CHECKPOINT statement.
 3509                          Could not set database '%.*ls' %ls read-only user mode because you could not
                               exclusively lock the database.
 3510                          Database '%.*ls' cannot be changed from read-only because the primary and/or
                               log file(s) are not writable.


Table 3–31:TSQL Error Codes - 3600 to 3699

 Error Code                    Description
 3604                          Duplicate key was ignored.
 3605                          Duplicate row was ignored.
 3606                          Arithmetic overflow occurred.
 3607                          Division by zero occurred.
 3608                          Cannot allocate a GUID for the token.




InterSystems Error Reference                                                                                  147
TSQL Error Messages


 Error Code                Description
 3612                      %hsSQL Server Execution Times:%hs CPU time = %lu ms, elapsed time = %lu
                           ms.
 3613                      SQL Server parse and compile time: %hs CPU time = %lu ms, elapsed time =
                           %lu ms.
 3615                      Table '%.*ls'. Scan count %d, logical reads %d, physical reads %d, read-ahead
                           reads %d.
 3618                      The transaction has been terminated.
 3619                      Could not write a CHECKPOINT record in database ID %d because the log is out
                           of space.
 3620                      Automatic checkpointing is disabled in database '%.*ls' because the log is out of
                           space. It will continue when the database owner successfully checkpoints the
                           database. Free up some space or extend the database and then run the
                           CHECKPOINT statement.
 3621                      The statement has been terminated.
 3622                      A domain error occurred.
 3625                      '%hs' is not yet implemented.
 3627                      Could not create worker thread.
 3628                      A floating point exception occurred in the user process. Current transaction is
                           canceled.
 3629                      This SQL Server has been optimized for %d concurrent queries. This limit has
                           been exceeded by %d queries and performance may be adversely affected.
 3630                      Concurrency violations since %ls%s 1 2 3 4 5 6 7 8 9 10-100
                           >100%s%6u%6u%6u%6u%6u%6u%6u%6u%6u%8u%6u
 3631                      Concurrency violations will be written to the SQL Server error log.
 3632                      Concurrency violations will not be written to the SQL Server error log.

Table 3–32:TSQL Error Codes - 3700 to 3799

 Error Code                Description
 3701                      Cannot %S_MSG the %S_MSG '%.*ls', because it does not exist in the system
                           catalog.
 3702                      Cannot drop the %S_MSG '%.*ls' because it is currently in use.
 3703                      Cannot detach the %S_MSG '%.*ls' because it is currently in use.
 3704                      User does not have permission to perform this operation on %S_MSG '%.*ls'.
 3705                      Cannot use DROP %ls with '%.*ls' because '%.*ls' is a %S_MSG. Use DROP
                           %ls.
 3708                      Cannot %S_MSG the %S_MSG '%.*ls' because it is a system %S_MSG.
 3716                      The %S_MSG '%.*ls' cannot be dropped because it is bound to one or more
                           %S_MSG.




148                                                                               InterSystems Error Reference
                                                                                               TSQL Error Messages


 Error Code                    Description
 3718                          Could not drop index '%.*ls' because the table or clustered index entry cannot be
                               found in the sysindexes system table.
 3723                          An explicit DROP INDEX is not allowed on index '%.*ls'. It is being used for %ls
                               constraint enforcement.
 3724                          Cannot %S_MSG the %S_MSG '%.*ls' because it is being used for replication.
 3725                          The constraint '%.*ls' is being referenced by table '%.*ls', foreign key constraint
                               '%.*ls'.
 3726                          Could not drop object '%.*ls' because it is referenced by a FOREIGN KEY
                               constraint.
 3727                          Could not drop constraint. See previous errors.
 3728                          '%.*ls' is not a constraint.
 3729                          Cannot %ls '%.*ls' because it is being referenced by object '%.*ls'.
 3733                          Constraint '%.*ls' does not belong to table '%.*ls'.
 3736                          Cannot drop the %S_MSG '%.*ls' because it is being used for distribution.
 3737                          Could not delete file '%ls'. See the SQL Server error log for more information.
 3738                          Deleting database file '%ls'.
 3739                          Cannot %ls the index '%.*ls' because it is not a statistics collection.
 3740                          Cannot drop the %S_MSG '%.*ls' because at least part of the table resides on a
                               read-only filegroup.
 3741                          Cannot drop the %S_MSG '%.*ls' because at least part of the table resides on
                               an offline filegroup.

Table 3–33:TSQL Error Codes - 3900 to 3999

 Error Code                    Description
 3902                          The COMMIT TRANSACTION request has no corresponding BEGIN
                               TRANSACTION.
 3903                          The ROLLBACK TRANSACTION request has no corresponding BEGIN
                               TRANSACTION.
 3904                          Cannot unsplit logical page %S_PGID in object '%.*ls', in database '%.*ls'. Both
                               pages together contain more data than will fit on one page.
 3906                          Could not run BEGIN TRANSACTION in database '%.*ls' because the database
                               is read-only.
 3908                          Could not run BEGIN TRANSACTION in database '%.*ls' because the database
                               is in bypass recovery mode.
 3909                          Session binding token is invalid.
 3910                          Transaction context in use by another session.
 3912                          Cannot bind using an XP token while the server is not in an XP call.




InterSystems Error Reference                                                                                     149
TSQL Error Messages


 Error Code                Description
 3914                      The data type '%s' is invalid for transaction names or savepoint names. Allowed
                           data types are char, varchar, nchar, or nvarchar.
 3915                      Cannot use the ROLLBACK statement within an INSERT-EXEC statement.
 3916                      Cannot use the COMMIT statement within an INSERT-EXEC statement unless
                           BEGIN TRANSACTION is used first.
 3917                      Session is bound to a transaction context that is in use. Other statements in the
                           batch were ignored.
 3918                      Statement must be executed in the context of a user transaction.
 3919                      Cannot enlist in the transaction because the transaction has already been
                           committed or rolled back.
 3920                      The WITH MARK option only applies to the first BEGIN TRAN WITH MARK
                           statement. The option is ignored.
 3921                      Cannot get a transaction token if there is no transaction active. Reissue the
                           statement after a transaction has been started
 3922                      Cannot enlist in the transaction because the transaction does not exist.
 3923                      Cannot use transaction marks on database '%.*ls' with bulk-logged operations
                           that have not been backed up. The mark is ignored.
 3924                      The session was enlisted in an active user transaction while trying to bind to a
                           new transaction. The session has defected from the previous user transaction.
 3925                      Invalid transaction mark name. The 'LSN:' prefix is reserved.
 3926                      The transaction active in this session has been committed or aborted by another
                           session.
 3927                      The session had an active transaction when it tried to enlist in a Distributed
                           Transaction Coordinator transaction.
 3928                      The marked transaction '%.*ls' failed. A Deadlock was encountered while
                           attempting to place the mark in the log.

Table 3–34:TSQL Error Codes - 4000 to 4099

 Error Code                Description
 4003                      ODS error. Server is terminating this connection.
 4004                      Unicode data in a Unicode-only collation or ntext data cannot be sent to clients
                           using DB-Library (such as ISQL) or ODBC version 3.7 or earlier.
 4015                      Language requested in login '%.*ls' is not an official name on this SQL Server.
                           Using server-wide default %.*ls instead.
 4016                      Language requested in 'login %.*ls' is not an official name on this SQL Server.
                           Using user default %.*ls instead.
 4017                      Neither the language requested in 'login %.*ls' nor user default language %.*ls is
                           an official language name on this SQL Server. Using server-wide default %.*ls
                           instead.




150                                                                                InterSystems Error Reference
                                                                                               TSQL Error Messages


 Error Code                    Description
 4018                          User default language %.*ls is not an official language name on this SQL Server.
                               Using server-wide default %.*ls instead.
 4019                          Language requested in login '%.*ls' is not an official language name on this SQL
                               Server. Login fails.
 4020                          Default date order '%.*ls' for language %.*ls is invalid. Using mdy instead.
 4027                          Mount tape for %hs of database '%ls'.
 4028                          End of tape has been reached. Remove tape '%ls' and mount next tape for %hs
                               of database '%ls'.
 4030                          The medium on device '%ls' expires on %hs and cannot be overwritten.
 4035                          Processed %d pages for database '%ls', file '%ls' on file %d.
 4037                          User-specified volume ID '%ls' does not match the volume ID '%ls' of the device
                               '%ls'.
 4038                          Cannot find file ID %d on device '%ls'.
 4060                          Cannot open database requested in login '%.*ls'. Login fails.
 4061                          Cannot open either database requested in login (%.*ls) or user default database.
                               Using master database instead.
 4062                          Cannot open user default database. Using master database instead.
 4063                          Cannot open database requested in login (%.*ls). Using user default '%.*ls' instead.
 4064                          Cannot open user default database. Login failed.

Table 3–35:TSQL Error Codes - 4200 to 4299

 Error Code                    Description
 4208                          The statement %hs is not allowed while the recovery model is SIMPLE. Use
                               BACKUP DATABASE or change the recovery model using ALTER DATABASE.
 4212                          Cannot back up the log of the master database. Use BACKUP DATABASE instead.
 4214                          There is no current database backup. This log backup cannot be used to roll
                               forward a preceding database backup.
 4215                          The log was not truncated because records at the beginning of the log are pending
                               replication. Ensure the Log Reader Agent is running or use sp_repldone to mark
                               transactions as distributed.
 4216                          Minimally logged operations cannot be backed up when the database is
                               unavailable.
 4217                          BACKUP LOG cannot modify the database because database is read-only. The
                               backup will continue,although subsequent backups will duplicate the work of this
                               backup.




InterSystems Error Reference                                                                                    151
TSQL Error Messages


Table 3–36:TSQL Error Codes - 4300 to 4399

 Error Code                Description
 4301                      Database in use. The system administrator must have exclusive use of the
                           database to restore the log.
 4304                      A USER ATTENTION signal raised during RESTORE LOG is being ignored until
                           the current restore completes.
 4305                      The log in this backup set begins at LSN %.*ls, which is too late to apply to the
                           database. An earlier log backup that includes LSN %.*ls can be restored.
 4306                      The preceding restore operation did not specify WITH NORECOVERY or WITH
                           STANDBY. Restart the restore sequence, specifying WITH NORECOVERY or
                           WITH STANDBY for all but the final step.
 4316                      Can only RESTORE LOG in the master database if SQL Server is in single user
                           mode.
 4318                      File '%ls' has been rolled forward to LSN %.*ls. This log terminates at LSN %.*ls,
                           which is too early to apply the WITH RECOVERY option. Reissue the RESTORE
                           LOG statement WITH NORECOVERY.
 4320                      File '%ls' was only partially restored by a database or file restore. The entire file
                           must be successfully restored before applying the log.
 4322                      This log file contains records logged before the designated point-in-time. The
                           database is being left in load state so you can apply another log file.
 4323                      The database is marked suspect. Transaction logs cannot be restored. Use
                           RESTORE DATABASE to recover the database.
 4324                      Backup history older than %ls has been deleted.
 4325                      Could not delete entries for backup set ID '%ls'.
 4326                      The log in this backup set terminates at LSN %.*ls, which is too early to apply to
                           the database. A more recent log backup that includes LSN %.*ls can be restored.
 4327                      The log in this backup set contains minimally logged changes. Point-in-time
                           recovery is inhibited. RESTORE will roll forward to end of logs without recovering
                           the database.
 4328                      File '%ls' is missing. Rollforward stops at log sequence number %.*ls. File is
                           created at LSN %.*ls, dropped at LSN %.*ls. Restore transaction log beyond
                           beyond point in time when file was dropped or restore data to be consistent with
                           rest of database.
 4329                      This log file contains records logged before the designated mark. The database
                           is being left in load state so you can apply another log file.
 4330                      The log in this backup set cannot be applied because it is on a recovery path
                           inconsistent with the database.
 4331                      The database cannot be recovered because the files have been restored to
                           inconsistent points in time.
 4332                      RESTORE LOG has been halted. To use the database in its current state, run
                           RESTORE DATABASE %ls WITH RECOVERY.
 4333                      The database cannot be recovered because the log was not restored.



152                                                                                  InterSystems Error Reference
                                                                                               TSQL Error Messages


 Error Code                    Description
 4334                          The named mark does not identify a valid LSN.

Table 3–37:TSQL Error Codes - 4400 to 4499

 Error Code                    Description
 4403                          View or function '%.*ls' is not updatable because it contains aggregates.
 4404                          View or function '%.*ls' is not updatable because the definition contains the
                               DISTINCT clause.
 4405                          View or function '%.*ls' is not updatable because the modification affects multiple
                               base tables.
 4406                          Update or insert of view or function '%.*ls' failed because it contains a derived or
                               constant field.
 4408                          The query and the views or functions in it exceed the limit of %d tables.
 4413                          Could not use view or function '%.*ls' because of binding errors.
 4414                          Could not allocate ancillary table for view or function resolution. The maximum
                               number of tables in a query (%d) was exceeded.
 4415                          View '%.*ls' is not updatable because either it was created WITH CHECK OPTION
                               or it spans a view created WITH CHECK OPTION and the target table is
                               referenced multiple times in the resulting query.
 4416                          UNION ALL view '%.*ls' is not updatable because the definition contains a
                               disallowed construct.
 4417                          Derived table '%.*ls' is not updatable because the definition contains a UNION
                               operator.
 4418                          Derived table '%.*ls' is not updatable because it contains aggregates.
 4419                          Derived table '%.*ls' is not updatable because the definition contains the DISTINCT
                               clause.
 4420                          Derived table '%.*ls' is not updatable because the modification affects multiple
                               base tables.
 4421                          Derived table '%.*ls' is not updatable because a column of the derived table is
                               derived or constant.
 4422                          View '%.*ls' has an INSTEAD OF UPDATE trigger and cannot be a target of an
                               UPDATE FROM statement.
 4423                          View '%.*ls' has an INSTEAD OF DELETE trigger and cannot be a target of a
                               DELETE FROM statement.
 4424                          Joined tables cannot be specified in a query containing outer join operators. View
                               or function '%.*ls' contains joined tables.
 4425                          Cannot specify outer join operators in a query containing joined tables. View or
                               function '%.*ls' contains outer join operators.
 4427                          The view or function '%.*ls' is not updatable because the definition contains the
                               TOP clause.




InterSystems Error Reference                                                                                     153
TSQL Error Messages


 Error Code           Description
 4428                 The derived table '%.*ls' is not updatable because the definition contains the TOP
                      clause.
 4429                 View or function '%.*ls' contains a self-reference. Views or functions cannot
                      reference themselves directly or indirectly.
 4430                 Warning: Index hints supplied for view '%.*ls' will be ignored.
 4431                 Partitioned view '%.*ls' is not updatable because table '%.*ls' has a timestamp
                      column.
 4432                 Partitioned view '%.*ls' is not updatable because table '%.*ls' has a DEFAULT
                      constraint.
 4433                 Cannot INSERT into partitioned view '%.*ls' because table '%.*ls' has an IDENTITY
                      constraint.
 4434                 Partitioned view '%.*ls' is not updatable because table '%.*ls' has an INSTEAD
                      OF trigger.
 4435                 Partitioned view '%.*ls' is not updatable because a value was not specified for
                      partitioning column '%.*ls'.
 4436                 UNION ALL view '%.*ls' is not updatable because a partitioning column was not
                      found.
 4437                 Partitioned view '%.*ls' is not updatable as the target of a bulk operation.
 4438                 Partitioned view '%.*ls' is not updatable because it does not deliver all columns
                      from its member tables.
 4439                 Partitioned view '%.*ls' is not updatable because the source query contains
                      references to partition table '%.*ls'.
 4440                 UNION ALL view '%.*ls' is not updatable because a primary key was not found
                      on table '%.*ls'.
 4441                 Partitioned view '%.*ls' is not updatable because the table '%.*ls' has an index
                      on a computed column.
 4442                 UNION ALL view '%.*ls' is not updatable because base table '%.*ls' is used multiple
                      times.
 4443                 UNION ALL view '%.*ls' is not updatable because column '%.*ls' of base table
                      '%.*ls' is used multiple times.
 4444                 UNION ALL view '%.*ls' is not updatable because the primary key of table '%.*ls'
                      is not included in the union result.
 4445                 UNION ALL view '%.*ls' is not updatable because the primary key of table '%.*ls'
                      is not unioned with primary keys of preceding tables.
 4446                 UNION ALL view '%.*ls' is not updatable because the definiton of column '%.*ls'
                      of view '%.*ls' is used by another view column.
 4447                 View '%.*ls' is not updatable because the definition contains a set operator.
 4448                 Cannot INSERT into partitioned view '%.*ls' because values were not supplied
                      for all columns.
 4449                 Using defaults is not allowed in views that contain a set operator.



154                                                                           InterSystems Error Reference
                                                                                            TSQL Error Messages


 Error Code                    Description
 4450                          Cannot update partitioned view '%.*ls' because the definition of the view column
                               '%.*ls' in table '%.*ls' has a IDENTITY constraint.
 4451                          Views referencing tables on multiple servers are not updatable on this SKU of
                               SQL Server.
 4452                          Cannot UPDATE partitioning column '%.*ls' of view '%.*ls' because the table
                               '%.*ls' has a CASCADE DELETE or CASCADE UPDATE constraint.
 4453                          Cannot UPDATE partitioning column '%.*ls' of view '%.*ls' because the table
                               '%.*ls' has a INSERT, UPDATE or DELETE trigger.

Table 3–38:TSQL Error Codes - 4500 to 4599

 Error Code                    Description
 4501                          View or function '%.*ls' has more columns defined than column names given.
 4502                          View or function '%.*ls' has more column names specified than columns defined.
 4505                          CREATE VIEW failed because column '%.*ls' in view '%.*ls' exceeds the maximum
                               of %d columns.
 4506                          Column names in each view or function must be unique. Column name '%.*ls' in
                               view or function '%.*ls' is specified more than once.
 4508                          Views or functions are not allowed on temporary tables. Table names that begin
                               with '#' denote temporary tables.
 4509                          Could not perform CREATE VIEW because WITH %ls was specified and the view
                               contains set operators.
 4510                          Could not perform CREATE VIEW because WITH %ls was specified and the view
                               is not updatable.
 4511                          Create View or Function failed because no column name was specified for column
                               %d.
 4512                          Cannot schema bind %S_MSG '%.*ls' because name '%.*ls' is invalid for schema
                               binding. Names must be in two-part format and an object cannot reference itself.
 4513                          Cannot schema bind %S_MSG '%.*ls'. '%.*ls' is not schema bound.
 4514                          CREATE FUNCTION failed because a column name is not specified for column
                               %d.
 4515                          CREATE FUNCTION failed because column '%.*ls' in function '%.*ls' exceeds
                               the maximum of %d columns.
 4516                          Cannot schema bind function '%.*ls' because it contains an EXECUTE statement.




InterSystems Error Reference                                                                                   155
TSQL Error Messages


Table 3–39:TSQL Error Codes - 4600 to 4699

 Error Code                Description
 4602                      Only members of the sysadmin role can grant or revoke the CREATE DATABASE
                           permission.
 4604                      There is no such user or group '%.*ls'.
 4606                      Granted or revoked privilege %ls is not compatible with object.
 4610                      You can only grant or revoke permissions on objects in the current database.
 4611                      To revoke grantable privileges, specify the CASCADE option with REVOKE.
 4613                      Grantor does not have GRANT permission.
 4615                      Invalid column name '%.*ls'.
 4617                      Cannot grant, deny or revoke permissions to or from special roles.
 4618                      You do not have permission to use %.*ls in the AS clause.
 4619                      CREATE DATABASE permission can only be granted in the master database.


Table 3–40:TSQL Error Codes - 4700 to 4799

 Error Code                Description
 4701                      Could not truncate table '%.*ls' because this table does not exist in database
                           '%.*ls'.
 4706                      Could not truncate table '%.*ls' because there is not enough room in the log to
                           record the deallocation of all the index and data pages.
 4707                      Could not truncate object '%.*ls' because it or one of its indexes resides on a
                           READONLY filegroup.
 4708                      Could not truncate object '%.*ls' because it is not a table.
 4709                      You are not allowed to truncate the system table '%.*ls'.
 4711                      Cannot truncate table '%.*ls' because it is published for replication.
 4712                      Cannot truncate table '%.*ls' because it is being referenced by a FOREIGN KEY
                           constraint.


Table 3–41:TSQL Error Codes - 4800 to 4899

 Error Code                Description
 4803                      Received invalid row length %d from bcp client. Maximum row size is %d.
 4804                      Premature end-of-message while reading current row from host. Host program
                           may have terminated.
 4805                      The front-end tool you are using does not support the feature of bulk insert from
                           host. Use the proper tools for this command.
 4807                      Received invalid row length %d from bcp client. Minimum row size is %d.
 4808                      Bulk copy operations cannot trigger BULK INSERT statements.




156                                                                                InterSystems Error Reference
                                                                                               TSQL Error Messages


 Error Code                    Description
 4810                          Expected the TEXT token in data stream for bulk copy of text or image data.
 4811                          Expected the column offset in data stream for bulk copy of text or image data.
 4812                          Expected the row offset in data stream for bulk copy of text or image data.
 4813                          Expected the text length in data stream for bulk copy of text, ntext, or image data.
 4815                          Received invalid column length from bcp client.
 4817                          Could not bulk insert. Invalid sorted column '%.*ls'. Assuming data stream is not
                               sorted.
 4818                          Could not bulk insert. Sorted column '%.*ls' was specified more than once.
                               Assuming data stream is not sorted.
 4819                          Could not bulk insert. Bulk data stream was incorrectly specified as sorted.
 4820                          Could not bulk insert. Unknown version of format file '%s'.
 4821                          Could not bulk insert. Error reading the number of columns from format file '%s'.
 4822                          Could not bulk insert. Invalid number of columns in format file '%s'.
 4823                          Could not bulk insert. Invalid column number in format file '%s'.
 4824                          Could not bulk insert. Invalid data type for column number %d in format file '%s'.
 4825                          Could not bulk insert. Invalid prefix for column number %d in format file '%s'.
 4826                          Could not bulk insert. Invalid column length for column number %d in format file
                               '%s'.
 4827                          Could not bulk insert. Invalid column terminator for column number %d in format
                               file '%s'.
 4828                          Could not bulk insert. Invalid destination table column number for source column
                               %d in format file '%s'.
 4829                          Could not bulk insert. Error reading destination table column name for source
                               column %d in format file '%s'.
 4830                          Bulk Insert: DataFileType was incorrectly specified as char. DataFileType will be
                               assumed to be widechar because the data file has a Unicode signature.
 4831                          Bulk Insert: DataFileType was incorrectly specified as widechar. DataFileType
                               will be assumed to be char because the data file does not have a Unicode
                               signature.
 4832                          Bulk Insert: Unexpected end-of-file (EOF) encountered in data file.
 4833                          Bulk Insert: Version mismatch between the provider dynamic link library and the
                               server executable.
 4834                          You do not have permission to use the BULK INSERT statement.
 4835                          Bulk copying into a table with computed columns is not supported for downlevel
                               clients.
 4837                          Error: Cannot bulk copy into a table '%s' enabled for immediate-updating
                               subscriptions




InterSystems Error Reference                                                                                     157
TSQL Error Messages


 Error Code           Description
 4838                 The bulk data source does not support the SQLNUMERIC or SQLDECIMAL data
                      types.
 4839                 Cannot perform bulk insert. Invalid collation name for source column %d in format
                      file '%s'.
 4840                 The bulk data source provider string has an invalid %ls property value %ls.
 4841                 The data source name is not a simple object name.
 4842                 The required FormatFile property is missing from the provider string of the server.
 4843                 The bulk data source provider string has a syntax error ('%lc') near character
                      position %d.
 4844                 The bulk data source provider string has an unsupported property name (%ls).
 4845                 The bulk data source provider string has a syntax error near character position
                      %d. Expected '%lc', but found '%lc'.
 4846                 The bulk data provider failed to allocate memory.
 4847                 Bulk copying into a table with bigint columns is not supported for versions earlier
                      than SQL Server 2000.
 4848                 Bulk copying into a table with sql_variant columns is not supported for versions
                      earlier than SQL Server 2000.
 4849                 Could not import table '%ls'. Error %d.
 4850                 Data import: Table '%ls' is already locked by another user.
 4851                 Data import: Table '%ls' already has data. Skipping to next table.
 4852                 Data import: Table '%ls' does not exist or it is not a user table.
 4853                 %hs
 4854                 %hs
 4860                 Could not bulk insert. File '%ls' does not exist.
 4861                 Could not bulk insert because file '%ls' could not be opened. Operating system
                      error code %ls.
 4862                 Could not bulk insert because file '%ls' could not be read. Operating system error
                      code %ls.
 4863                 Bulk insert data conversion error (truncation) for row %d, column %d (%ls).
 4864                 Bulk insert data conversion error (type mismatch) for row %d, column %d (%ls).
 4865                 Could not bulk insert because the maximum number of errors (%d) was exceeded.
 4866                 Bulk Insert fails. Column is too long in the data file for row %d, column %d. Make
                      sure the field terminator and row terminator are specified correctly.
 4867                 Bulk insert data conversion error (overflow) for row %d, column %d (%ls).
 4868                 Bulk Insert fails. Codepage '%d' is not installed. Install the codepage and run the
                      command again.




158                                                                             InterSystems Error Reference
                                                                                               TSQL Error Messages


 Error Code                    Description
 4869                          Bulk Insert failed. Unexpected NULL value in data file row %d, column %d.
                               Destination column (%ls) is defined NOT NULL.
 4880                          Could not bulk insert. When using the FIRSTROW and LASTROW parameters,
                               the value for FIRSTROW cannot be greater than the value for LASTROW.
 4881                          Note: Bulk Insert through a view may result in base table default values being
                               ignored for NULL columns in the data file.
 4882                          Could not bulk insert. Prefix length, field length, or terminator required for source
                               column %d in format file '%s'.

Table 3–42:TSQL Error Codes - 4900 to 4999

 Error Code                    Description
 4901                          ALTER TABLE only allows columns to be added that can contain nulls or have
                               a DEFAULT definition specified. Column '%.*ls' cannot be added to table '%.*ls'
                               because it does not allow nulls and does not specify a DEFAULT definition.
 4902                          Cannot alter table '%.*ls' because this table does not exist in database '%.*ls'.
 4909                          Cannot alter '%.*ls' because it is not a table.
 4910                          Only the owner or members of the sysadmin role can alter table '%.*ls'.
 4916                          Could not enable or disable the constraint. See previous errors.
 4917                          Constraint '%.*ls' does not exist.
 4920                          ALTER TABLE failed because trigger '%.*ls' on table '%.*ls' does not exist.
 4921                          ALTER TABLE failed because trigger '%.*ls' does not belong to table '%.*ls'.
 4922                          %ls %.*ls failed because one or more objects access this column.
 4923                          ALTER TABLE DROP COLUMN failed because '%.*ls' is the only data column
                               in table '%.*ls'. A table must have at least one data column.
 4924                          %ls failed because column '%.*ls' does not exist in table '%.*ls'.
 4925                          ALTER TABLE ALTER COLUMN ADD ROWGUIDCOL failed because a column
                               already exists in table '%.*ls' with ROWGUIDCOL property.
 4926                          ALTER TABLE ALTER COLUMN DROP ROWGUIDCOL failed because a column
                               does not exist in table '%.*ls' with ROWGUIDCOL property.
 4927                          Cannot alter column '%.*ls' to be data type %.*ls.
 4928                          Cannot alter column '%.*ls' because it is '%ls'.
 4929                          Cannot alter the %S_MSG '%.*ls' because it is being published for replication.
 4930                          Warning: Columns added to the replicated table %S_MSG '%.*ls' will be ignored
                               by existing articles.
 4931                          Cannot add columns to %S_MSG '%.*ls' because it is being published for merge
                               replication.
 4932                          ALTER TABLE DROP COLUMN failed because '%.*ls' is currently replicated.




InterSystems Error Reference                                                                                       159
TSQL Error Messages


Table 3–43:TSQL Error Codes - 5000 to 5099

 Error Code                Description
 5001                      User must be in the master database.
 5002                      Database '%.*ls' does not exist. Check sysdatabases.
 5004                      To use ALTER DATABASE, the database must be in a writable state in which a
                           checkpoint can be executed.
 5005                      Extending database by %.2f MB on disk '%.*ls'.
 5006                      Could not get exclusive use of %S_MSG '%.*ls' to perform the requested operation.
 5008                      This ALTER DATABASE statement is not supported.
 5009                      ALTER DATABASE failed. Some disk names listed in the statement were not
                           found. Check that the names exist and are spelled correctly before rerunning the
                           statement.
 5010                      Log file name cannot be generated from a raw device. The log file name and path
                           must be specified.
 5011                      User does not have permission to alter database '%.*ls'.
 5012                      The name of the primary filegroup cannot be changed.
 5013                      The master and model databases cannot have files added to them. ALTER
                           DATABASE was aborted.
 5014                      The %S_MSG '%.*ls' does not exist in database '%.*ls'.
 5015                      ALTER DATABASE failed. The total size specified must be 1 MB or greater.
 5016                      System databases master, model, and tempdb cannot have their names changed.
 5017                      ALTER DATABASE failed. Database '%.*ls' was not created with 'FOR LOAD'
                           option.
 5018                      File '%.*ls' modified in sysaltfiles. Delete old file after restarting SQL Server.
 5019                      Cannot find entry in sysaltfiles for file '%.*ls'.
 5020                      The primary data or log file cannot be removed from a database.
 5021                      The %S_MSG name '%.*ls' has been set.
 5022                      Log file '%ls' for this database is already active.
 5023                      Database must be put in bypass recovery mode to rebuild the log.
 5024                      No entry found for the primary log file in sysfiles1. Could not rebuild the log.
 5025                      The file '%ls' already exists. It should be renamed or deleted so that a new log
                           file can be created.
 5026                      Could not create a new log file with file '%.*ls'. See previous errors.
 5027                      System databases master, model, and tempdb cannot have their logs rebuilt.
 5028                      The system could not activate enough of the database to rebuild the log.
 5029                      Warning: The log for database '%.*ls' has been rebuilt. Transactional consistency
                           has been lost. DBCC CHECKDB should be run to validate physical consistency.
                           Database options will have to be reset, and extra log files may need to be deleted.



160                                                                                  InterSystems Error Reference
                                                                                                TSQL Error Messages


 Error Code                    Description
 5030                          The database could not be exclusively locked to perform the operation.
 5031                          Cannot remove the file '%.*ls' because it is the only file in the DEFAULT filegroup.
 5032                          The file cannot be shrunk below page %ud until the log is backed up because it
                               contains bulk logged pages.
 5035                          Filegroup '%.*ls' already exists in this database.
 5036                          MODIFY FILE failed. Specify logical name.
 5037                          MODIFY FILE failed. Do not specify physical name.
 5038                          MODIFY FILE failed for file "%.*ls". At least one property per file must be specified.
 5039                          MODIFY FILE failed. Specified size is less than current size.
 5040                          MODIFY FILE failed. Size is greater than MAXSIZE.
 5041                          MODIFY FILE failed. File '%.*ls' does not exist.
 5042                          The %S_MSG '%.*ls' cannot be removed because it is not empty.
 5043                          The %S_MSG '%.*ls' cannot be found in %ls.
 5044                          The %S_MSG '%.*ls' has been removed.
 5045                          The %S_MSG already has the '%ls' property set.
 5046                          The %S_MSG property '%ls' has been set.
 5047                          Cannot change the READONLY property of the PRIMARY filegroup.
 5048                          Cannot add, remove, or modify files in filegroup '%.*ls'. The filegroup is read-only.
 5049                          Cannot extend file '%ls' using this syntax as it was not created with DISK INIT.
                               Use ALTER DATABASE MODIFY FILE.
 5050                          Cannot change the properties of empty filegroup '%.*ls'.The filegroup must contain
                               at least one file.
 5051                          Cannot have a filegroup with the name 'DEFAULT'.
 5053                          The maximum of %ld filegroups per database has been exceeded.
 5054                          Could not cleanup worktable IAM chains to allow shrink or remove file operation.
                               Please try again when tempdb is idle.
 5055                          Cannot add, remove, or modify file '%.*ls'. The file is read-only.
 5056                          Cannot add, remove, or modify a file in filegroup '%.*ls' because the filegroup is
                               offline.
 5057                          Cannot add, remove, or modify file '%.*ls' because it is offline.
 5058                          Option '%.*ls' cannot be set in database '%.*ls'.
 5059                          Database '%.*ls' is in transition. Try the ALTER DATABASE statement later.
 5060                          Nonqualified transactions are being rolled back. Estimated rollback completion:
                               %d%%.
 5061                          ALTER DATABASE failed because a lock could not be placed on database '%.*ls'.
                               Try again later.



InterSystems Error Reference                                                                                      161
TSQL Error Messages


 Error Code                Description
 5062                      Option '%.*ls' cannot be set at the same time as another option setting.
 5063                      Database '%.*ls' is in warm standby. A warm-standby database is read-only.
 5064                      Changes to the state or options of database '%.*ls' cannot be made at this time.
                           The database is in single-user mode, and a user is currently connected to it.
 5065                      Database '%.*ls' cannot be opened.
 5066                      Database options single user and dbo use only cannot be set at the same time.
 5068                      Failed to restart the current database. The current database is switched to master.
 5069                      ALTER DATABASE statement failed.
 5070                      Database state cannot be changed while other users are using the database
                           '%.*ls'
 5072                      ALTER DATABASE failed. The default collation of database '%.*ls' cannot be set
                           to %.*ls.
 5073                      Cannot alter collation for database '%ls' because it is READONLY, OFFLINE, or
                           marked SUSPECT.
 5074                      The %S_MSG '%.*ls' is dependent on %S_MSG '%.*ls'.
 5075                      The %S_MSG '%.*ls' is dependent on %S_MSG.
 5076                      Warning: Changing default collation for database '%.*ls', which is used in
                           replication. It is recommend that all replication database have the same default
                           collation.

Table 3–44:TSQL Error Codes - 5100 to 5199

 Error Code                Description
 5101                      You must supply parameters for the DISK %hs statement. Usage: %hs.
 5102                      No such statement DISK %.*ls.
 5103                      MAXSIZE cannot be less than SIZE for file '%ls'.
 5104                      File '%.*ls' already used.
 5105                      Device activation error. The physical file name '%.*ls' may be incorrect.
 5106                      Parameter '%hs' requires value of data type '%hs'.
 5107                      Value is wrong data type for parameter '%hs' (requires data type '%hs').
 5108                      Log file '%.*ls' does not match the primary file. It may be from a different database
                           or the log may have been rebuilt previously.
 5109                      No such parameter '%.*ls'.
 5110                      File '%.*ls' is on a network device not supported for database files.
 5116                      You do not have permission to run DISK statements.
 5117                      Could not run DISK statement. You must be in the master database to run this
                           statement.
 5122                      Each disk file size must be greater than or equal to 1 MB.



162                                                                                 InterSystems Error Reference
                                                                                              TSQL Error Messages


 Error Code                    Description
 5123                          CREATE FILE encountered operating system error %ls while attempting to open
                               or create the physical file '%.*ls'.
 5126                          The logical device '%.*ls' does not exist in sysdevices.
 5146                          The %hs of %d is out of range. It must be between %d and %d.
 5148                          Could not set the file size to the desired amount. The operating system file size
                               limit may have been reached.
 5149                          MODIFY FILE encountered operating system error %ls while attempting to expand
                               the physical file.
 5150                          The size of a single log file must not be greater than 2 TB.
 5151                          The %hs statement is obsolete and no longer supported.
 5157                          I/O error encountered in the writelog system function during backout.
 5158                          Warning: Media in device '%.*ls' may have been changed.
 5159                          Operating system error %.*ls on device '%.*ls' during %ls.
 5160                          Cannot take '%.*ls' offline because the database is in use.
 5162                          Cannot find '%.*ls' in sysdatabases.
 5163                          Cannot open '%.*ls' to take offline.
 5164                          Usage: DBCC DBCONTROL(dbname,ONLINE|OFFLINE)
 5165                          Cannot explicitly open or close master database.
 5167                          Database '%.*ls' is already offline.
 5168                          File '%.*ls' is on a network drive, which is not allowed.
 5169                          FILEGROWTH cannot be greater than MAXSIZE for file '%.*ls'.
 5170                          Cannot create file '%ls' because it already exists.
 5171                          %.*ls is not a primary database file.
 5172                          The header for file '%ls' is not a valid database file header. The %ls property is
                               incorrect.
 5173                          Cannot associate files with different databases.
 5174                          Each file size must be greater than or equal to 512 KB.
 5175                          The file '%.*ls' has been expanded to prevent recovery from failing. Contact the
                               system administrator for further assistance.
 5176                          The file '%.*ls' has been expanded beyond its maximum size to prevent recovery
                               from failing. Contact the system administrator for further assistance.
 5177                          Encountered an unexpected error while checking the sector size for file '%.*ls'.
                               Check the SQL Server error log for more information.
 5178                          Cannot use file '%.*ls' because it was originally formatted with sector size %d and
                               is now on a device with sector size %d.
 5179                          Cannot use file '%.*ls', which is on a device with sector size %d. SQL Server
                               supports a maximum sector size of 4096 bytes.



InterSystems Error Reference                                                                                    163
TSQL Error Messages


 Error Code                Description
 5180                      Could not open FCB for invalid file ID %d in database '%.*ls'.
 5181                      Could not restart database '%.*ls'. Reverting back to old status.
 5182                      New log file '%.*ls' was created.
 5183                      File '%ls' cannot be created. Use WITH MOVE to specify a usable physical file
                           name.
 5184                      Cannot use file '%.*ls' for clustered server. Only formatted files on which the
                           cluster resource of the server has a dependency can be used.

Table 3–45:TSQL Error Codes - 5700 to 5799

 Error Code                Description
 5701                      Changed database context to '%.*ls'.
 5702                      SQL Server is terminating this process.
 5703                      Changed language setting to %.*ls.


Table 3–46:TSQL Error Codes - 5800 to 5899

 Error Code                Description
 5803                      Unknown config number (%d) in sysconfigures.
 5804                      Character set, sort order, or collation cannot be changed because at least one
                           database is not writable.
 5805                      Too few locks specified. Minimum %d.
 5807                      Recovery intervals above %d minutes not recommended. Use the RECONFIGURE
                           WITH OVERRIDE statement to force this configuration.
 5808                      Ad hoc updates to system catalogs not recommended. Use the RECONFIGURE
                           WITH OVERRIDE statement to force this configuration.
 5809                      Average time slices above %d milliseconds not recommended. Use the
                           RECONFIGURE WITH OVERRIDE statement to force this configuration.
 5810                      Valid values for the fill factor are 0 to 100.
 5812                      You do not have permission to run the RECONFIGURE statement.
 5823                      Cannot reconfigure SQL Server to use sort order ID %d, because the row for that
                           sort order does not exist in syscharsets.
 5828                      User connections are limited to %d.
 5829                      The specified user options value is invalid.
 5830                      The default collation for SQL Server has been reconfigured. Restart SQL Server
                           to rebuild the table indexes on columns of character data types.
 5831                      Minimum server memory value (%d) must be less than or equal to the maximum
                           value (%d).




164                                                                                InterSystems Error Reference
                                                                                            TSQL Error Messages


Table 3–47:TSQL Error Codes - 5900 to 5999

 Error Code                    Description
 5904                          Background checkpoint process suspended until locks are available.


Table 3–48:TSQL Error Codes - 6000 to 6099

 Error Code                    Description
 6001                          SHUTDOWN is waiting for %d process(es) to complete.
 6002                          SHUTDOWN is in progress. Log off.
 6004                          User does not have permission to perform this action.
 6005                          SHUTDOWN is in progress.
 6006                          Server shut down by request.
 6007                          The SHUTDOWN statement cannot be executed within a transaction or by a
                               stored procedure.


Table 3–49:TSQL Error Codes - 6100 to 6199

 Error Code                    Description
 6101                          Process ID %d is not a valid process ID. Choose a number between 1 and %d.
 6102                          User does not have permission to use the KILL statement.
 6103                          Could not do cleanup for the killed process. Received message %d.
 6104                          Cannot use KILL to kill your own process.
 6106                          Process ID %d is not an active process ID.
 6107                          Only user processes can be killed.
 6108                          KILL SPID WITH COMMIT/ABORT is not supported by Microsoft SQL Server
                               2000. Use Microsoft Distributed Transaction Coordinator to resolve distributed
                               transactions.
 6109                          SPID %d: transaction rollback in progress. Estimated rollback completion: %d%%.
                               Estimated time remaining: %d seconds.
 6110                          The distributed transaction with UOW %s does not exist.
 6111                          Another user has decided a different outcome for the distributed transaction
                               associated with UOW %s.
 6112                          Distributed transaction with UOW %s is in prepared state. Only Microsoft
                               Distributed Transaction Coordinator can resolve this transaction. KILL command
                               failed.
 6113                          The distributed transaction associated with UOW %s is in PREPARE state. Use
                               KILL UOW WITH COMMIT/ABORT syntax to kill the transaction instead.
 6114                          Distributed transaction with UOW %s is being used by another user. KILL
                               command failed.
 6115                          KILL command cannot be used inside user transactions.



InterSystems Error Reference                                                                                    165
TSQL Error Messages


 Error Code                Description
 6116                      KILL command failed.
 6117                      There is a connection associated with the distributed transaction with UOW %s.
                           First, kill the connection using KILL SPID syntax.
 6118                      The distributed transaction associated with UOW %s is not in PREPARED state.
                           Use KILL UOW to kill the transaction instead.
 6119                      Distributed transaction with UOW %s is rolling back: estimated rollback completion:
                           %d%%, estimated time left %d seconds.
 6120                      Status report cannot be obtained. Rollback operation for Process ID %d is not in
                           progress.
 6121                      Status report cannot be obtained. Rollback operation for UOW %s is not in
                           progress.

Table 3–50:TSQL Error Codes - 6400 to 6499

 Error Code                Description
 6401                      Cannot roll back %.*ls. No transaction or savepoint of that name was found.


Table 3–51:TSQL Error Codes - 6600 to 6799

 Error Code                Description
 6600                      XML error: %.*ls
 6601                      XML parser returned the error code %d from line number %d, source '%.*ls'.
 6602                      The error description is '%.*ls'.
 6603                      XML parsing error: %.*ls
 6604                      XML stored procedures are not supported in fibers mode.
 6605                      %.*ls: Failed to obtain an IPersistStream interface on the XML text.
 6606                      %.*ls: Failed to save the XML text stream. The server resources may be too low.
 6607                      %.*ls: The value supplied for parameter number %d is invalid.
 6608                      Failed to instantiate class '%ls'. Make sure Msxml2.dll exists in the SQL Server
                           installation.
 6609                      Column '%ls' contains an invalid data type. Valid data types are char, varchar,
                           nchar, nvarchar, text, and ntext.
 6610                      Failed to load Msxml2.dll.
 6612                      Invalid data type for the column indicated by the parameter '%ls'. Valid data types
                           are int, bigint, smallint, and tinyint.
 6613                      Specified value '%ls' already exists.
 6614                      Value specified for column '%ls' is the same for column '%ls'. An element cannot
                           be its own parent.
 6615                      Invalid data type is specified for column '%ls'. Valid data types are int, bigint,
                           smallint, and tinyint.



166                                                                                  InterSystems Error Reference
                                                                                                TSQL Error Messages


 Error Code                    Description
 6616                          Parameter '%ls' is required when the parent of the element to be added is missing
                               and must be inserted.
 6617                          The specified edge table has an invalid format. Column '%ls' is missing or has
                               an invalid data type.
 6618                          Column '%ls' in the specified edge table has an invalid or null value.
 6619                          XML node of type %d named '%ls' cannot be created .
 6620                          XML attribute or element cannot be created for column '%ls'.
 6621                          XML encoding or decoding error occurred with object name '%.*ls'.
 6622                          Invalid data type for column '%ls'. Data type cannot be text, ntext, image, or binary.
 6623                          Column '%ls' contains an invalid data type. Valid data types are char, varchar,
                               nchar, and nvarchar.
 6624                          XML document could not be created because server memory is low. Use
                               sp_xml_removedocument to release XML documents.

Table 3–52:TSQL Error Codes - 6800 to 6899

 Error Code                    Description
 6800                          FOR XML AUTO requires at least one table for generating XML tags. Use FOR
                               XML RAW or add a FROM clause with a table name.
 6801                          FOR XML EXPLICIT requires at least three columns, including the tag column,
                               the parent column, and at least one data column.
 6802                          FOR XML EXPLICIT query contains the invalid column name '%.*ls'. Use the
                               TAGNAME!TAGID!ATTRIBUTENAME[!..] format where TAGID is a positive
                               integer.
 6803                          FOR XML EXPLICIT requires the first column to hold positive integers that
                               represent XML tag IDs.
 6804                          FOR XML EXPLICIT requires the second column to hold NULL or nonnegative
                               integers that represent XML parent tag IDs.
 6805                          FOR XML EXPLICIT stack overflow occurred. Circular parent tag relationships
                               are not allowed.
 6806                          Undeclared tag ID %d is used in a FOR XML EXPLICIT query.
 6807                          Undeclared parent tag ID %d is used in a FOR XML EXPLICIT query.
 6808                          XML tag ID %d could not be added. The server memory resources may be low.
 6809                          Unnamed column or table names cannot be used as XML identifiers. Name
                               unnamed columns using AS in the SELECT statement.
 6810                          Column name '%.*ls' is repeated. The same attribute cannot be generated more
                               than once on the same XML tag.
 6811                          FOR XML is incompatible with COMPUTE expressions. Remove the COMPUTE
                               expression.
 6812                          XML tag ID %d that was originally declared as '%.*ls' is being redeclared as '%.*ls'.



InterSystems Error Reference                                                                                      167
TSQL Error Messages


 Error Code           Description
 6813                 FOR XML EXPLICIT cannot combine multiple occurrences of ID, IDREF, IDREFS,
                      NMTOKEN, and/or NMTOKENS in column name '%.*ls'.
 6814                 In the FOR XML EXPLICIT clause, ID, IDREF, IDREFS, NMTOKEN, and
                      NMTOKENS require attribute names in '%.*ls'.
 6815                 In the FOR XML EXPLICIT clause, ID, IDREF, IDREFS, NMTOKEN, and
                      NMTOKENS attributes cannot be hidden in '%.*ls'.
 6816                 In the FOR XML EXPLICIT clause, ID, IDREF, IDREFS, NMTOKEN, and
                      NMTOKENS attributes cannot be generated as CDATA, XML, or XMLTEXT in
                      '%.*ls'.
 6817                 FOR XML EXPLICIT cannot combine multiple occurrences of ELEMENT, XML,
                      XMLTEXT, and CDATA in column name '%.*ls'.
 6818                 In the FOR XML EXPLICIT clause, CDATA attributes must be unnamed in '%.*ls'.
 6819                 The FOR XML clause is not allowed in a %ls statement.
 6820                 FOR XML EXPLICIT requires column %d to be named '%ls' instead of '%.*ls'.
 6821                 GROUP BY and aggregate functions are currently not supported with FOR XML
                      AUTO.
 6824                 In the FOR XML EXPLICIT clause, mode '%.*ls' in a column name is invalid.
 6825                 ELEMENTS mode requires FOR XML AUTO.
 6826                 Every IDREFS or NMTOKENS column in a FOR XML EXPLICIT query must
                      appear in a separate SELECT clause, and the instances must be ordered directly
                      after the element to which they belong.
 6827                 FOR XML EXPLICIT queries allow only one XMLTEXT column per tag. Column
                      '%.*ls' declares another XMLTEXT column that is not permitted.
 6828                 XMLTEXT column '%.*ls' must be of a string data type.
 6829                 FOR XML EXPLICIT and RAW modes currently do not support addressing binary
                      data as URLs in column '%.*ls'. Remove the column, or use the BINARY BASE64
                      mode, or create the URL directly using the
                      'dbobject/TABLE[@PK1="V1"]/@COLUMN' syntax.
 6830                 FOR XML AUTO could not find the table owning the following column '%.*ls' to
                      create a URL address for it. Remove the column, or use the BINARY BASE64
                      mode, or create the URL directly using the
                      'dbobject/TABLE[@PK1="V1"]/@COLUMN' syntax.
 6831                 FOR XML AUTO requires primary keys to create references for '%.*ls'. Select
                      primary keys, or use BINARY BASE64 to obtain binary data in encoded form if
                      no primary keys exist.
 6832                 FOR XML AUTO cannot generate a URL address for binary data if a primary key
                      is also binary.
 6833                 Parent tag ID %d is not among the open tags. FOR XML EXPLICIT requires
                      parent tags to be opened first. Check the ordering of the result set.
 6834                 XMLTEXT field '%.*ls' contains an invalid XML document. Check the root tag and
                      its attributes.



168                                                                       InterSystems Error Reference
                                                                                                TSQL Error Messages


 Error Code                    Description
 6835                          FOR XML EXPLICIT field '%.*ls' can specify the directive HIDE only once.
 6836                          FOR XML EXPLICIT requires attribute-centric IDREFS or NMTOKENS field '%.*ls'
                               to precede element-centric IDREFS/NMTOKEN fields.
 6837                          The XMLTEXT document attribute that starts with '%.*ls' is too long. Maximum
                               length is %d.
 6838                          Attribute-centric IDREFS or NMTOKENS field not supported on tags having
                               element-centric field '%.*ls' of type TEXT/NTEXT or IMAGE. Either specify
                               ELEMENT on IDREFS/NMTOKENS field or remove the ELEMENT directive.
 6839                          FOR XML EXPLICIT does not support XMLTEXT field on tag '%.*ls' that has
                               IDREFS or NMTOKENS fields.
 6840                          XMLDATA does not support namespace elements or attributes such as '%.*ls'.
                               Run the SELECT FOR XML statement without XMLDATA or remove the
                               namespace prefix declaration.

Table 3–53:TSQL Error Codes - 7000 to 7099

 Error Code                    Description
 7000                          OPENXML document handle parameter must be of data type int.
 7001                          OPENXML flags parameter must be of data type int.
 7002                          OPENXML XPath must be of a string data type, such as nvarchar.
 7003                          Only one OPENXML column can be of type %ls.
 7004                          OPENXML does not support retrieving schema from remote tables, as in '%.*ls'.
 7005                          OPENXML requires a metaproperty namespace to be declared if 'mp' is used for
                               another namespace in sp_xml_preparedocument.
 7006                          OPENXML encountered a problem identifying the metaproperty namespace prefix.
                               Consider removing the namespace parameter from the corresponding
                               sp_xml_preparedocument statement.
 7007                          OPENXML encountered unknown metaproperty '%.*ls'.
 7008                          The OPENXML EDGETABLE is incompatible with the XMLTEXT OVERFLOW
                               flag.
 7009                          OPENXML allows only one metaproperty namespace prefix declaration in
                               sp_xml_preparedocument.


Table 3–54:TSQL Error Codes - 7100 to 7199

 Error Code                    Description
 7101                          You cannot use a text pointer for a table with option 'text in row' set to ON.
 7102                          SQL Server Internal Error. Text manager cannot continue with current statement.
 7103                          You cannot set option 'text in row' for table %s.
 7104                          Offset or size type is invalid. Must be int or smallint data type.




InterSystems Error Reference                                                                                    169
TSQL Error Messages


 Error Code           Description
 7105                 Page %S_PGID, slot %d for text, ntext, or image node does not exist.
 7106                 You cannot update a blob with a read-only text pointer
 7107                 You can have only 1,024 in-row text pointers in one transaction
 7116                 Offset %d is not in the range of available text, ntext, or image data.
 7122                 Invalid text, ntext, or image pointer type. Must be binary(16).
 7123                 Invalid text, ntext, or image pointer value %hs.
 7124                 The offset and length specified in the READTEXT statement is greater than the
                      actual data length of %ld.
 7125                 The text, ntext, or image pointer value conflicts with the column name specified.
 7126                 The text, ntext, or image pointer value references a data page with an invalid text,
                      ntext, or image status.
 7127                 The text, ntext, or image pointer value references a data page with an invalid
                      timestamp.
 7128                 The text, ntext, or image pointer value references a data page that is no longer
                      allocated.
 7130                 %ls WITH NO LOG is not valid at this time. Use sp_dboption to set the 'select
                      into/bulkcopy' option on for database '%.*ls'.
 7133                 NULL textptr (text, ntext, or image pointer) passed to %ls function.
 7135                 Deletion length %ld is not in the range of available text, ntext, or image data.
 7137                 %s is not allowed because the column is being processed by a concurrent
                      snapshot and is being replicated to a non-SQL Server Subscriber or Published
                      in a publication allowing Data Transformation Services (DTS).
 7138                 The WRITETEXT statement is not allowed because the column is being replicated
                      with Data Transformation Services (DTS).
 7139                 Length of text, ntext, or image data (%ld) to be replicated exceeds configured
                      maximum %ld.
 7141                 Must create orphaned text inside a user transaction.
 7142                 Must drop orphaned text before committing the transaction.
 7143                 Invalid locator de-referenced.




170                                                                            InterSystems Error Reference
                                                                                               TSQL Error Messages


Table 3–55:TSQL Error Codes - 7200 to 7299

 Error Code                    Description
 7201                          Could not execute procedure on remote server '%.*ls' because SQL Server is not
                               configured for remote access. Ask your system administrator to reconfigure SQL
                               Server to allow remote access.
 7202                          Could not find server '%.*ls' in sysservers. Execute sp_addlinkedserver to add
                               the server to sysservers.
 7212                          Could not execute procedure '%.*ls' on remote server '%.*ls'.
 7213                          Could not set up parameter for remote server '%.*ls'.
 7214                          Remote procedure time out of %d seconds exceeded. Remote procedure '%.*ls'
                               is canceled.
 7221                          Could not relay results of procedure '%.*ls' from remote server '%.*ls'.
 7300                          OLE DB error trace [%ls].


Table 3–56:TSQL Error Codes - 7300 to 7399

 Error Code                    Description
 7301                          Could not obtain a required interface from OLE DB provider '%ls'.
 7302                          Could not create an instance of OLE DB provider '%ls'.
 7303                          Could not initialize data source object of OLE DB provider '%ls'. %ls
 7304                          Could not create a new session on OLE DB provider '%ls'.
 7305                          Could not create a statement object using OLE DB provider '%ls'.
 7306                          Could not open table '%ls' from OLE DB provider '%ls'. %ls
 7307                          Could not obtain the data source of a session from OLE DB provider '%ls'. This
                               action must be supported by the provider.
 7310                          Could not obtain the schema options for OLE DB provider '%ls'. The provider
                               supports the interface, but returns a failure code when it is used.
 7311                          Could not obtain the schema rowset for OLE DB provider '%ls'. The provider
                               supports the interface, but returns a failure code when it is used.
 7312                          Invalid use of schema and/or catalog for OLE DB provider '%ls'. A four-part name
                               was supplied, but the provider does not expose the necessary interfaces to use
                               a catalog and/or schema.
 7313                          Invalid schema or catalog specified for provider '%ls'.
 7314                          OLE DB provider '%ls' does not contain table '%ls'. The table either does not exist
                               or the current user does not have permissions on that table.
 7315                          OLE DB provider '%ls' contains multiple tables that match the name '%ls'.
 7316                          Could not use qualified table names (schema or catalog) with OLE DB provider
                               '%ls' because it does not implement required functionality.
 7317                          OLE DB provider '%ls' returned an invalid schema definition.




InterSystems Error Reference                                                                                    171
TSQL Error Messages


 Error Code           Description
 7318                 OLE DB provider '%ls' returned an invalid column definition.
 7319                 OLE DB provider '%ls' returned a '%ls' index '%ls' with incorrect bookmark ordinal
                      %d.
 7320                 Could not execute query against OLE DB provider '%ls'. %ls
 7321                 An error occurred while preparing a query for execution against OLE DB provider
                      '%ls'. %ls
 7322                 A failure occurred while giving parameter information to OLE DB provider '%ls'.
                      %ls
 7323                 An error occurred while submitting the query text to OLE DB provider '%ls'. %ls
 7330                 Could not fetch a row from OLE DB provider '%ls'. %ls
 7331                 Rows from OLE DB provider '%ls' cannot be released. %ls
 7332                 Could not rescan the result set from OLE DB provider '%ls'. %ls
 7333                 Could not fetch a row using a bookmark from OLE DB provider '%ls'. %ls
 7340                 Could not create a column accessor for OLE DB provider '%ls'. %ls
 7341                 Could not get the current row value of column '%ls.%ls' from the OLE DB provider
                      '%ls'. %ls
 7342                 Unexpected NULL value returned for column '%ls.%ls' from the OLE DB provider
                      '%ls'. This column cannot be NULL.
 7343                 OLE DB provider '%ls' could not %ls table '%ls'. %ls
 7344                 OLE DB provider '%ls' could not %ls table '%ls' because of column '%ls'. %ls
 7345                 OLE DB provider '%ls' could not delete from table '%ls'. %ls
 7346                 Could not get the data of the row from the OLE DB provider '%ls'. %ls
 7347                 OLE DB provider '%ls' returned an unexpected data length for the fixed-length
                      column '%ls.%ls'. The expected data length is %ls, while the returned data length
                      is %ls.
 7348                 OLE DB provider '%ls' could not set range for table '%ls'.%ls
 7349                 OLE DB provider '%ls' could not set range for table '%ls' because of column
                      '%ls'.%ls
 7350                 Could not get the column information from the OLE DB provider '%ls'.
 7351                 OLE DB provider '%ls' could not map ordinals for one or more columns of object
                      '%ls'.
 7352                 OLE DB provider '%ls' supplied inconsistent metadata. The object '%ls' was
                      missing expected column '%ls'.
 7353                 OLE DB provider '%ls' supplied inconsistent metadata. An extra column was
                      supplied during execution that was not found at compile time.
 7354                 OLE DB provider '%ls' supplied invalid metadata for column '%ls'. %ls
 7355                 OLE DB provider '%ls' supplied inconsistent metadata for a column. The name
                      was changed at execution time.



172                                                                          InterSystems Error Reference
                                                                                              TSQL Error Messages


 Error Code                    Description
 7356                          OLE DB provider '%ls' supplied inconsistent metadata for a column. Metadata
                               information was changed at execution time.
 7357                          Could not process object '%ls'. The OLE DB provider '%ls' indicates that the object
                               has no columns.
 7358                          Could not execute query.The OLE DB provider '%ls' did not provide an appropriate
                               interface to access the text, ntext, or image column '%ls.%ls'.
 7359                          The OLE DB provider '%ls' reported a schema version for table '%ls' that changed
                               between compilation and execution.
 7360                          Could not get the length of a storage object from the OLE DB provider '%ls' for
                               table '%ls', column '%ls'.
 7361                          Could not read a storage object from the OLE DB provider '%ls', for table '%ls',
                               column '%ls'.
 7362                          The OLE DB provider '%ls' reported different meta data at for table '%ls' column
                               '%ls'.
 7365                          Could not obtain optional metadata columns of columns rowset from the OLE DB
                               provider '%ls'.
 7366                          Could not obtain columns rowset from OLE DB provider '%ls'. The provider
                               supports the interface, but returns a failure code when used.
 7367                          The OLE DB provider '%ls' supports column-level collation, but failed to provide
                               metadata column '%ls' at .
 7368                          The OLE DB provider '%ls' supports column-level collation, but failed to provide
                               collation data for column '%ls'.
 7369                          The OLE DB provider '%ls' provided invalid collation. %ls.
 7370                          One or more properties could not be set on the query for OLE DB provider '%ls'.
                               %ls
 7371                          One or more properties could not be set on the table for OLE DB provider '%ls'.
 7372                          Cannot get properties from OLE DB provider '%ls'.
 7373                          Could not set the initialization properties for the OLE DB provider '%ls'.
 7374                          Could not set the session properties for the OLE DB provider '%ls'.
 7375                          Could not open index '%ls' on table '%ls' from OLE DB provider '%ls'. %ls
 7376                          Could not enforce the remote join hint for this query.
 7377                          Cannot specify an index or locking hint for a remote data source.
 7378                          The update/delete operation requires a unique key or a clustered index on the
                               remote table.
 7379                          OLE DB provider '%ls' returned an unexpected '%ls' for the decimal/numeric
                               column '%ls.%ls'. The expected data length is '%ls', while the returned data length
                               is '%ls'.
 7390                          The requested operation could not be performed because the OLE DB provider
                               '%ls' does not support the required transaction interface.



InterSystems Error Reference                                                                                   173
TSQL Error Messages


 Error Code                Description
 7391                      The operation could not be performed because the OLE DB provider '%ls' was
                           unable to begin a distributed transaction.
 7392                      Could not start a transaction for OLE DB provider '%ls'.
 7393                      OLE DB provider '%ls' reported an error aborting the current transaction.
 7394                      OLE DB provider '%ls' reported an error committing the current transaction.
 7395                      Unable to start a nested transaction for OLE DB provider '%ls'. A nested
                           transaction was required because the XACT_ABORT option was set to OFF.
 7399                      OLE DB provider '%ls' reported an error. %ls

Table 3–57:TSQL Error Codes - 7400 to 7499

 Error Code                Description
 7401                      Cannot create OLE DB provider enumeration object installed with SQL Server.
                           Verify installation.
 7403                      Could not locate registry entry for OLE DB provider '%ls'.
 7404                      The server could not load DCOM.
 7405                      Heterogeneous queries require the ANSI_NULLS and ANSI_WARNINGS options
                           to be set for the connection. This ensures consistent query semantics. Enable
                           these options and then reissue your query.
 7410                      Remote access not allowed for Windows NT user activated by SETUSER.
 7411                      Server '%.*ls' is not configured for %ls.
 7413                      Could not perform a Windows NT authenticated login because delegation is not
                           available.
 7414                      Invalid number of parameters. Rowset '%ls' expects %d parameter(s).
 7415                      Ad hoc access to OLE DB provider '%ls' has been denied. You must access this
                           provider through a linked server.
 7416                      Access to the remote server is denied because no login-mapping exists.
 7417                      GROUP BY ALL is not supported in queries that access remote tables if there is
                           also a WHERE clause in the query.
 7418                      Text, image, or ntext column was too large to send to the remote data source due
                           to the storage interface used by the provider.
 7419                      Lazy schema validation error. Linked server schema version has changed. Re-run
                           the query.

Table 3–58:TSQL Error Codes - 7600 to 7699

 Error Code                Description
 7601                      Cannot use a CONTAINS or FREETEXT predicate on %S_MSG '%.*ls' because
                           it is not full-text indexed.
 7602                      The Full-Text Service (Microsoft Search) is not available. The system administrator
                           must start this service.



174                                                                                InterSystems Error Reference
                                                                                                TSQL Error Messages


 Error Code                    Description
 7603                          Syntax error in search condition, or empty or null search condition '%ls'.
 7604                          Full-text operation failed due to a time out.
 7605                          Full-text catalog '%ls' has been lost. Use sp_fulltext_catalog to rebuild and to
                               repopulate this full-text catalog.
 7606                          Could not find full-text index for database ID %d, table ID %d. Use sp_fulltext_table
                               to deactivate then activate this index.
 7607                          Search on full-text catalog '%ls' for database ID %d, table ID %d with search
                               condition '%ls' failed with unknown result (%x).
 7608                          An unknown full-text failure (%x) occurred in function %hs on full-text catalog
                               '%ls'.
 7609                          Full-Text Search is not installed, or a full-text component cannot be loaded.
 7610                          Access is denied to '%ls', or the path is invalid. Full-text search was not installed
                               properly.
 7611                          Warning: Request to start a population in full-text catalog '%ls' ignored because
                               a population is currently active for this full-text catalog.
 7612                          %d is not a valid value for full-text system resource usage.
 7613                          Cannot drop index '%.*ls' because it enforces the full-text key for table '%.*ls'.
 7614                          Cannot alter or drop column '%.*ls' because it is enabled for Full-Text Search.
 7615                          A CONTAINS or FREETEXT predicate can only operate on one table. Qualify
                               the use of * with a table name.
 7616                          Full-Text Search is not enabled for the current database. Use sp_fulltext_database
                               to enable full-text search for the database.
 7617                          Query does not reference the full-text indexed table.
 7618                          %d is not a valid value for a full-text connection time out.
 7620                          Conversion to data type %ls failed for full-text search key value 0x%ls.
 7621                          Invalid use of full-text predicate in the HAVING clause.
 7622                          Full-text catalog '%ls' lacks sufficient disk space to complete this operation.
 7623                          Full-text query failed because full-text catalog '%ls' is not yet ready for queries.
 7624                          Full-text catalog '%ls' is in a unusable state. Drop and re-create this full-text
                               catalog.
 7625                          Full-text table has more than one LCID among its full-text indexed columns.
 7626                          The top_n_by_rank argument ('%d') must be greater than zero.
 7627                          Full-text catalog in directory '%ls' for clustered server cannot be created. Only
                               directories on a disk in the cluster group of the server can be used.
 7628                          Cannot copy Schema.txt to '%.*ls' because access is denied or the path is invalid.
                               Full-text search was not installed properly.
 7629                          Cannot open or query registry key '%.*ls'.




InterSystems Error Reference                                                                                        175
TSQL Error Messages


 Error Code                Description
 7630                      Syntax error occurred near '%.*ls' in search condition '%.*ls'.
 7631                      Syntax error occurred near '%.*ls'. Expected '%.*ls' in search condition '%.*ls'.
 7632                      The value of the Weight argument must be between 0.0 and 1.0.
 7633                      The syntax <content search condition> OR NOT <content boolean term> is not
                           allowed.
 7634                      Stack overflow occurred in parsing search condition '%.*ls'.
 7635                      The Microsoft Search service cannot be administered under the present user
                           account
 7636                      Warning: Request to start a full-text index population on table '%ls' is ignored
                           because a population is currently active for this table.
 7637                      Value %d is not valid for full-text data time-out.
 7638                      Warning: Request to stop change tracking has deleted all changes tracked on
                           table '%ls'.
 7639                      Cannot use a full-text predicate on %S_MSG '%.*ls' because it is not located on
                           the local server.
 7640                      Warning: Request to stop tracking changes on table '%ls' will not stop population
                           currently in progress on the table.
 7641                      Full-Text catalog '%ls' does not exist.
 7642                      A full-text catalog named '%ls' already exists in this database.

Table 3–59:TSQL Error Codes - 7900 to 7999

 Error Code                Description
 7905                      The object specified is neither a table nor a constraint
 7908                      The table '%.*ls' was created with the NO_LOG option.
 7910                      Repair: Page %S_PGID has been allocated to object ID %d, index ID %d.
 7911                      Repair: Page %S_PGID has been deallocated from object ID %d, index ID %d.
 7912                      Repair: Extent %S_PGID has been allocated to object ID %d, index ID %d.
 7913                      Repair: Extent %S_PGID has been deallocated from object ID %d, index ID %d.
 7914                      Repair: %ls page at %S_PGID has been rebuilt.
 7915                      Repair: IAM chain for object ID %d, index ID %d, has been truncated before page
                           %S_PGID and will be rebuilt.
 7916                      Repair: Deleted record for object ID %d, index ID %d, on page %S_PGID, slot
                           %d. Indexes will be rebuilt.
 7917                      Repair: Converted forwarded record for object ID %d, index ID %d, at page
                           %S_PGID, slot %d to a data row.
 7918                      Repair: Page %S_PGID next and %S_PGID previous pointers have been set to
                           match each other in object ID %d, index ID %d.
 7919                      Repair statement not processed. Database needs to be in single user mode.



176                                                                                   InterSystems Error Reference
                                                                                                 TSQL Error Messages


 Error Code                    Description
 7920                          Processed %ld entries in sysindexes for database ID %d.
 7922                          ***************************************************************
 7923                          Table %.*ls Object ID %ld.
 7924                          Index ID %ld. FirstIAM %S_PGID. Root %S_PGID. Dpages %ld.
 7925                          Index ID %d. %ld pages used in %ld dedicated extents.
 7927                          Total number of extents is %ld.
 7932                          The indexes for '%.*ls' are already correct. They will not be rebuilt.
 7933                          One or more indexes contain errors. They will be rebuilt.
 7934                          The table '%.*ls' has no indexes.
 7935                          REINDEX received an exception. Statement terminated.
 7937                          The data in table '%.*ls' is possibly inconsistent. REINDEX terminated. Run DBCC
                               CHECKTABLE and report errors to your system administrator.
 7939                          Cannot detach database '%.*ls' because it does not exist.
 7940                          System databases master, model, msdb, and tempdb cannot be detached.
 7941                          Trace option(s) not enabled for this connection. Use 'DBCC TRACEON()'.
 7942                          DBCC %ls scanning '%.*ls' table...
 7943                          Table: '%.*ls' (%d); index ID: %d, database ID: %d
 7944                          %ls level scan performed.
 7945                          - Pages Scanned................................: %lu
 7946                          - Extents Scanned..............................: %lu
 7947                          - Extent Switches..............................: %lu
 7948                          - Avg. Pages per Extent........................: %3.1f
 7949                          - Scan Density [Best Count:Actual Count].......: %4.2f%ls [%lu:%lu]
 7950                          - Logical Scan Fragmentation ..................: %4.2f%ls
 7951                          - Physical Scan Fragmentation .................: %4.2f%ls
 7952                          - Extent Scan Fragmentation ...................: %4.2f%ls
 7953                          - Avg. Bytes Free per Page.....................: %3.1f
 7954                          - Avg. Page Density (full).....................: %4.2f%ls
 7955                          Invalid SPID %d specified.
 7956                          Permission to execute DBCC %ls denied.
 7957                          Cannot display the specified SPID's buffer; in transition.
 7958                          The specified SPID does not process input/output data streams.
 7959                          The DBCC statement is not supported in this release.




InterSystems Error Reference                                                                                    177
TSQL Error Messages


 Error Code           Description
 7961                 Object ID %d, index ID %d, page ID %S_PGID, row ID %d. Column '%.*ls' is a
                      var column with a NULL value and non-zero data length.
 7962                 Upgrade requires SQL Server to be started in single user mode. Restart SQL
                      Server with the -m flag.
 7963                 Upgrade encountered a fatal error. See the SQL Server errorlog for more
                      information.
 7965                 Table error: Could not check object ID %d, index ID %d due to invalid allocation
                      (IAM) page(s).
 7966                 Warning: NO_INDEX option of %ls being used. Checks on non-system indexes
                      will be skipped.
 7968                 Transaction information for database '%.*ls'.
 7969                 No active open transactions.
 7970                 %hsOldest active transaction:
 7971                 SPID (server process ID) : %d
 7972                 UID (user ID) : %d
 7974                 Name : %.*ls
 7975                 LSN : (%d:%d:%d)
 7977                 Start time : %.*ls
 7979                 %hsReplicated Transaction Information:
 7980                 Oldest distributed LSN : (%d:%d:%d)
 7982                 Oldest non-distributed LSN : (%d:%d:%d)
 7983                 User '%.*ls' does not have permission to run DBCC %ls for database '%.*ls'.
 7984                 Invalid object name '%.*ls'.
 7985                 The object name '%.*ls' contains more than the maximum number of prefixes.
                      The maximum is %d.
 7986                 Warning: Pinning tables should be carefully considered. If a pinned table is larger,
                      or grows larger, than the available data cache, the server may need to be restarted
                      and the table unpinned.
 7991                 System table mismatch: Table '%.*ls', object ID %d has index ID 1 in sysindexes
                      but the status in sysobjects does not have the clustered bit set. The table will be
                      checked as a heap.
 7992                 Cannot shrink 'read only' database '%.*ls'.
 7993                 Cannot shrink file '%d' in database '%.*ls' to %d pages as it only contains %d
                      pages.
 7994                 Object ID %d, index ID %d: FirstIAM field in sysindexes is %S_PGID. FirstIAM
                      for statistics only and dummy index entries should be (0:0).
 7995                 Database '%ls' consistency errors in sysobjects, sysindexes, syscolumns, or
                      systypes prevent further %ls processing.



178                                                                           InterSystems Error Reference
                                                                                                  TSQL Error Messages


 Error Code                    Description
 7996                          Extended stored procedures can only be created in the master database.
 7997                          '%.*ls' does not contain an identity column.
 7998                          Checking identity information: current identity value '%.*hs', current column value
                               '%.*hs'.
 7999                          Could not find any index named '%.*ls' for table '%.*ls'.

Table 3–60:TSQL Error Codes - 8100 to 8199

 Error Code                    Description
 8101                          An explicit value for the identity column in table '%.*ls' can only be specified when
                               a column list is used and IDENTITY_INSERT is ON.
 8102                          Cannot update identity column '%.*ls'.
 8103                          Table '%.*ls' does not exist or cannot be opened for SET operation.
 8104                          The current user is not the database or object owner of table '%.*ls'. Cannot
                               perform SET operation.
 8105                          '%.*ls' is not a user table. Cannot perform SET operation.
 8106                          Table '%.*ls' does not have the identity property. Cannot perform SET operation.
 8107                          IDENTITY_INSERT is already ON for table '%.*ls.%.*ls.%.*ls'. Cannot perform
                               SET operation for table '%.*ls'.
 8108                          Cannot add identity column, using the SELECT INTO statement, to table '%.*ls',
                               which already has column '%.*ls' that inherits the identity property.
 8109                          Attempting to add multiple identity columns to table '%.*ls' using the SELECT
                               INTO statement.
 8110                          Cannot add multiple PRIMARY KEY constraints to table '%.*ls'.
 8111                          Cannot define PRIMARY KEY constraint on nullable column in table '%.*ls'.
 8112                          Cannot add more than one clustered index for constraints on table '%.*ls'.
 8114                          Error converting data type %ls to %ls.
 8115                          Arithmetic overflow error converting %ls to data type %ls.
 8116                          Argument data type %ls is invalid for argument %d of %ls function.
 8117                          Operand data type %ls is invalid for %ls operator.
 8118                          Column '%.*ls.%.*ls' is invalid in the select list because it is not contained in an
                               aggregate function and there is no GROUP BY clause.
 8119                          Column '%.*ls.%.*ls' is invalid in the HAVING clause because it is not contained
                               in an aggregate function and there is no GROUP BY clause.
 8120                          Column '%.*ls.%.*ls' is invalid in the select list because it is not contained in either
                               an aggregate function or the GROUP BY clause.
 8121                          Column '%.*ls.%.*ls' is invalid in the HAVING clause because it is not contained
                               in either an aggregate function or the GROUP BY clause.
 8122                          Only the first query in a UNION statement can have a SELECT with an assignment.



InterSystems Error Reference                                                                                        179
TSQL Error Messages


 Error Code           Description
 8123                 A correlated expression is invalid because it is not in a GROUP BY clause.
 8124                 Multiple columns are specified in an aggregated expression containing an outer
                      reference. If an expression being aggregated contains an outer reference, then
                      that outer reference must be the only column referenced in the expression.
 8125                 An aggregated expression containing an outer reference must be contained in
                      either the select list, or a HAVING clause subquery in the query whose FROM
                      clause contains the table with the column being aggregated.
 8126                 Column name '%.*ls.%.*ls' is invalid in the ORDER BY clause because it is not
                      contained in an aggregate function and there is no GROUP BY clause.
 8127                 Column name '%.*ls.%.*ls' is invalid in the ORDER BY clause because it is not
                      contained in either an aggregate function or the GROUP BY clause.
 8128                 Using '%s' version '%s' to execute extended stored procedure '%s'.
 8129                 The new disk size must be greater than %d. Consider using DBCC SHRINKDB.
 8130                 The device is not a database device. Only database devices can be expanded.
 8131                 Extended stored procedure DLL '%s' does not export __GetXpVersion(). Refer
                      to the topic "Backward Compatibility Details (Level 1) - Open Data Services" in
                      the documentation for more information.
 8132                 Extended stored procedure DLL '%s' reports its version is %d.%d. Server expects
                      version %d.%d.
 8133                 None of the result expressions in a CASE specification can be NULL.
 8134                 Divide by zero error encountered.
 8135                 Table level constraint does not specify column list, table '%.*ls'.
 8136                 Duplicate columns specified in %ls constraint key list, table '%.*ls'.
 8138                 More than 16 columns specified in foreign key column list, table '%.*ls'.
 8139                 Number of referencing columns in foreign key differs from number of referenced
                      columns, table '%.*ls'.
 8140                 More than one key specified in column level %ls constraint, table '%.*ls'.
 8141                 Column %ls constraint for column '%.*ls' references another column, table '%.*ls'.
 8142                 Subqueries are not supported in %ls constraints, table '%.*ls'.
 8143                 Parameter '%.*ls' was supplied multiple times.
 8144                 Procedure or function %.*ls has too many arguments specified.
 8145                 %.*ls is not a parameter for procedure %.*ls.
 8146                 Procedure %.*ls has no parameters and arguments were supplied.
 8147                 Could not create IDENTITY attribute on nullable column '%.*ls', table '%.*ls'.
 8148                 More than one column %ls constraint specified for column '%.*ls', table '%.*ls'.
 8149                 OLE Automation objects are not supported in fiber mode.
 8150                 Multiple NULL constraints were specified for column '%.*ls', table '%.*ls'.



180                                                                            InterSystems Error Reference
                                                                                                TSQL Error Messages


 Error Code                    Description
 8151                          Both a PRIMARY KEY and UNIQUE constraint have been defined for column
                               '%.*ls', table '%.*ls'. Only one is allowed.
 8152                          String or binary data would be truncated.
 8153                          Warning: Null value is eliminated by an aggregate or other SET operation.
 8154                          The table '%.*ls' is ambiguous.
 8155                          No column was specified for column %d of '%.*ls'.
 8156                          The column '%.*ls' was specified multiple times for '%.*ls'.
 8157                          All the queries in a query expression containing a UNION operator must have the
                               same number of expressions in their select lists.
 8158                          '%.*ls' has more columns than were specified in the column list.
 8159                          '%.*ls' has fewer columns than were specified in the column list.
 8160                          A grouping function can only be specified when either CUBE or ROLLUP is
                               specified in the GROUP BY clause.
 8161                          A grouping function argument does not match any of the expressions in the
                               GROUP BY clause.
 8162                          Formal parameter '%.*ls' was defined as OUTPUT but the actual parameter not
                               declared OUTPUT.
 8163                          The text, ntext, or image data type cannot be selected as DISTINCT.
 8164                          An INSERT EXEC statement cannot be nested.
 8165                          Invalid subcommand value %d. Legal range from %d to %d.
 8166                          Constraint name '%.*ls' not permitted. Constraint names cannot begin with a
                               number sign (#).
 8168                          Cannot create two constraints named '%.*ls'. Duplicate constraint names are not
                               allowed.
 8169                          Syntax error converting from a character string to uniqueidentifier.
 8170                          Insufficient result space to convert uniqueidentifier value to char.
 8171                          Hint '%ls' on object '%.*ls' is invalid.
 8175                          Could not find table %.*ls. Will try to resolve this table name later.
 8176                          Resync procedure expects value of key '%.*ls', which was not supplied.
 8177                          Cannot use a column in the %hs clause unless it is contained in either an
                               aggregate function or the GROUP BY clause.
 8178                          Prepared statement '%.*ls' expects parameter %.*ls, which was not supplied.
 8179                          Could not find prepared statement with handle %d.
 8180                          Statement(s) could not be prepared.
 8181                          Text for '%.*ls' is missing from syscomments. The object must be dropped and
                               re-created before it can be used.
 8183                          Only UNIQUE or PRIMARY KEY constraints are allowed on computed columns.



InterSystems Error Reference                                                                                   181
TSQL Error Messages


 Error Code                Description
 8184                      Error expanding '*': all columns incomparable, '*' expanded to zero columns.
 8185                      Error expanding '*': An uncomparable column has been found in an underlying
                           table or view.
 8186                      Function '%.*ls' can be used only on user and system tables.
 8190                      Cannot compile replication filter procedure without defining table being filtered.
 8191                      Replication filter procedures can only contain SELECT, GOTO, IF, WHILE,
                           RETURN, and DECLARE statements.
 8192                      Replication filter procedures cannot have parameters.
 8193                      Cannot execute a procedure marked FOR REPLICATION.
 8194                      Cannot execute a USE statement while an application role is active.
 8196                      Duplicate column specified as ROWGUIDCOL.
 8197                      Windows NT user '%.*ls' does not have server access.
 8198                      Could not obtain information about Windows NT group/user '%ls'.
 8199                      In EXECUTE <procname>, procname can only be a literal or variable of type
                           char, varchar, nchar, or nvarchar.

Table 3–61:TSQL Error Codes - 8500 to 8599

 Error Code                Description
 8501                      MSDTC on server '%.*ls' is unavailable.
 8502                      Unknown MSDTC token '0x%x' received.
 8504                      Invalid transaction import buffer.
 8506                      Invalid transaction state change requested from %hs to %hs.
 8508                      QueryInterface failed for '%hs': %hs.
 8509                      Import of MSDTC transaction failed: %hs.
 8510                      Enlist of MSDTC transaction failed: %hs.
 8511                      Unknown isolation level %d requested from MSDTC.
 8512                      MSDTC Commit acknowledgment failed: %hs.
 8513                      MSDTC Abort acknowledgment failed: %hs.
 8514                      MSDTC PREPARE acknowledgment failed: %hs.
 8515                      MSDTC Global state is invalid.
 8517                      Failed to get MSDTC PREPARE information: %hs.
 8518                      MSDTC BEGIN TRANSACTION failed: %hs.
 8519                      Current MSDTC transaction must be committed by remote client.
 8520                      Commit of internal MSDTC transaction failed: %hs.
 8521                      Invalid awakening state. Slept in %hs; awoke in %hs.




182                                                                                InterSystems Error Reference
                                                                                               TSQL Error Messages


 Error Code                    Description
 8522                          Distributed transaction aborted by MSDTC.
 8523                          PREPARE TRAN statement not allowed on MSDTC transaction.
 8524                          The current transaction could not be exported to the remote provider. It has been
                               rolled back.
 8525                          Distributed transaction completed. Either enlist this session in a new transaction
                               or the NULL transaction.

Table 3–62:TSQL Error Codes - 8600 to 8699

 Error Code                    Description
 8601                          Internal Query Processor Error: The query processor could not obtain access to
                               a required interface.
 8602                          Indexes used in hints must be explicitly included by the index tuning wizard.
 8616                          The index hints for table '%.*ls' were ignored because the table was considered
                               a fact table in the star join.
 8617                          Invalid Query: CUBE and ROLLUP cannot compute distinct aggregates.
 8618                          Warning: The query processor could not produce a query plan from the optimizer
                               because the total length of all the columns in the GROUP BY or ORDER BY
                               clause exceeds 8000 bytes.
 8619                          Warning: The query processor could not produce a query plan from the optimizer
                               because the total length of all the columns in the GROUP BY or ORDER BY
                               clause exceeds 8000 bytes. Resubmit your query without the ROBUST PLAN
                               hint.
 8620                          Internal Query Processor Error: The query processor encountered an internal
                               limit overflow.
 8621                          Internal Query Processor Error: The query processor ran out of stack space during
                               query optimization.
 8622                          Query processor could not produce a query plan because of the hints defined in
                               this query. Resubmit the query without specifying any hints and without using
                               SET FORCEPLAN.
 8623                          Internal Query Processor Error: The query processor could not produce a query
                               plan. Contact your primary support provider for more information.
 8624                          Internal SQL Server error.
 8625                          Warning: The join order has been enforced because a local join hint is used.
 8626                          Only text pointers are allowed in work tables, never text, ntext, or image columns.
                               The query processor produced a query plan that required a text, ntext, or image
                               column in a work table.
 8627                          The query processor could not produce a query plan because of the combination
                               of hints and text, ntext, or image data passing through operators using work tables.
 8628                          A time out occurred while waiting to optimize the query. Rerun the query.




InterSystems Error Reference                                                                                    183
TSQL Error Messages


 Error Code           Description
 8629                 The query processor could not produce a query plan from the optimizer because
                      a query cannot update a text, ntext, or image column and a clustering key at the
                      same time.
 8630                 Internal Query Processor Error: The query processor encountered an unexpected
                      error during execution.
 8640                 Internal Query Processor Error: The query processor encountered an unexpected
                      work table error during execution.
 8642                 The query processor could not start the necessary thread resources for parallel
                      query execution.
 8644                 Internal Query Processor Error: The plan selected for execution does not support
                      the invoked given execution routine.
 8645                 A time out occurred while waiting for memory resources to execute the query.
                      Rerun the query.
 8646                 The index entry for row ID %.*hs was not found in index ID %d, of table %d, in
                      database '%.*ls'.
 8647                 Scan on sysindexes for database ID %d, object ID %ld, returned a duplicate index
                      ID %d. Run DBCC CHECKTABLE on sysindexes.
 8648                 Could not insert a row larger than the page size into a hash table. Resubmit the
                      query with the ROBUST PLAN hint.
 8649                 The query has been canceled because the estimated cost of this query (%d)
                      exceeds the configured threshold of %d. Contact the system administrator.
 8650                 Intra-query parallelism caused your server command (process ID #%d) to
                      deadlock. Rerun the query without intra-query parallelism by using the query hint
                      option (maxdop 1).
 8651                 Could not perform the requested operation because the minimum query memory
                      is not available. Decrease the configured value for the 'min memory per query'
                      server configuration option.
 8653                 Warning: The query processor is unable to produce a plan because the table
                      '%.*ls' is marked OFFLINE.
 8654                 A cursor plan could not be generated for the given statement because it contains
                      textptr ( inrow lob ).
 8660                 An index cannot be created on the view '%.*ls' because the view definition does
                      not include all the columns in the GROUP BY clause.
 8661                 A clustered index cannot be created on the view '%.*ls' because the index key
                      includes columns which are not in the GROUP BY clause.
 8662                 An index cannot be created on the view '%.*ls' because the view definition includes
                      an unknown value (the sum of a nullable expression).
 8663                 An index cannot be created on the view '%.*ls' because the view definition does
                      not include count_big(*).
 8664                 An index cannot be created on the view '%.*ls' because the view definition includes
                      duplicate column names.



184                                                                           InterSystems Error Reference
                                                                                            TSQL Error Messages


 Error Code                    Description
 8665                          An index cannot be created on the view '%.*ls' because no row can satisfy the
                               view definition.
 8666                          Warning: The optimizer cannot use the index because the select list of the view
                               contains a non-aggregate expression.
 8667                          Warning: The optimizer cannot use the index because the group-by list in the
                               view forms a key and is redundant.
 8680                          Internal Query Processor Error: The query processor encountered an unexpected
                               error during the processing of a remote query phase.

Table 3–63:TSQL Error Codes - 8900 to 8999

 Error Code                    Description
 8901                          Deadlock detected during DBCC. Complete the transaction in progress and retry
                               this statement.
 8902                          Memory allocation error during DBCC processing.
 8903                          Extent %S_PGID in database ID %d is allocated in both GAM %S_PGID and
                               SGAM %S_PGID.
 8904                          Extent %S_PGID in database ID %d is allocated by more than one allocation
                               object.
 8905                          Extent %S_PGID in database ID %d is marked allocated in the GAM, but no
                               SGAM or IAM has allocated it.
 8906                          Page %S_PGID in database ID %d is allocated in the SGAM %S_PGID and PFS
                               %S_PGID, but was not allocated in any IAM. PFS flags '%hs'.
 8908                          Table error: Database ID %d, object ID %d, index ID %d. Chain linkage mismatch.
                               %S_PGID->next = %S_PGID, but %S_PGID->prev = %S_PGID.
 8909                          Table error: Object ID %d, index ID %d, page ID %S_PGID. The PageId in the
                               page header = %S_PGID.
 8910                          Page %S_PGID in database ID %d is allocated to both object ID %d, index ID
                               %d, and object ID %d, index ID %d.
 8911                          The error has been repaired.
 8912                          %.*ls fixed %d allocation errors and %d consistency errors in database '%ls'.
 8913                          Extent %S_PGID is allocated to '%ls' and at least one other object.
 8914                          Incorrect PFS free space information for page %S_PGID, object ID %d, index ID
                               %d, in database ID %d. Expected value %hs, actual value %hs.
 8915                          File %d (number of mixed extents = %ld, mixed pages = %ld).
 8916                          Object ID %ld, Index ID %ld, data extents %ld, pages %ld, mixed extent pages
                               %ld.
 8917                          Object ID %ld, Index ID %ld, index extents %ld, pages %ld, mixed extent pages
                               %ld.
 8918                          (number of mixed extents = %ld, mixed pages = %ld) in this database.




InterSystems Error Reference                                                                                   185
TSQL Error Messages


 Error Code           Description
 8919                 Single page allocation %S_PGID in table %ls, object ID %d, index ID %d is not
                      allocated in PFS page ID %S_PGID.
 8920                 Cannot perform a %ls operation inside a user transaction. Terminate the
                      transaction and reissue the statement.
 8921                 CHECKTABLE terminated. A failure was detected while collecting facts. Possibly
                      tempdb out of space or a system table is inconsistent. Check previous errors.
 8922                 Could not repair this error.
 8923                 The repair level on the DBCC statement caused this repair to be bypassed.
 8924                 Repairing this error requires other errors to be corrected first.
 8925                 Table error: Cross object linkage: Page %S_PGID, slot %d, in object ID %d, index
                      ID %d, refers to page %S_PGID, slot %d, in object ID %d, index ID %d.
 8926                 Table error: Cross object linkage: Parent page %S_PGID, slot %d, in object ID
                      %d, index ID %d, and page %S_PGID, slot %d, in object ID %d, index ID %d,
                      next refer to page %S_PGID but are not in the same object.
 8927                 Object ID %d, index ID %d: The ghosted record count (%d) in the header does
                      not match the number of ghosted records (%d) found on page %S_PGID.
 8928                 Object ID %d, index ID %d: Page %S_PGID could not be processed. See other
                      errors for details.
 8929                 Object ID %d: Errors found in text ID %I64d owned by data record identified by
                      %.*ls.
 8930                 Table error: Object ID %d, index ID %d cross-object chain linkage. Page %S_PGID
                      points to %S_PGID in object ID %d, index ID %d.
 8931                 Table error: Object ID %d, index ID %d B-tree level mismatch, page %S_PGID.
                      Level %d does not match level %d from parent %S_PGID.
 8932                 Table error: Object ID %d, index ID %d, column '%.*ls'. The column ID %d is not
                      valid for this table. The valid range is from 1 to %d.
 8933                 Table error: Object ID %d, index ID %d. The low key value on page %S_PGID
                      (level %d) is not %ls the key value in the parent %S_PGID slot %d.
 8934                 Table error: Object ID %d, index ID %d. The high key value on page %S_PGID
                      (level %d) is not less than the low key value in the parent %S_PGID, slot %d of
                      the next page %S_PGID.
 8935                 Table error: Object ID %d, index ID %d. The previous link %S_PGID on page
                      %S_PGID does not match the previous page %S_PGID that the parent %S_PGID,
                      slot %d expects for this page.
 8936                 Table error: Object ID %d, index ID %d. B-tree chain linkage mismatch.
                      %S_PGID->next = %S_PGID, but %S_PGID->Prev = %S_PGID.
 8937                 Table error: Object ID %d, index ID %d. B-tree page %S_PGID has two parent
                      nodes %S_PGID, slot %d and %S_PGID, slot %d.
 8938                 Table error: Page %S_PGID, Object ID %d, index ID %d. Unexpected page type
                      %d.




186                                                                            InterSystems Error Reference
                                                                                               TSQL Error Messages


 Error Code                    Description
 8939                          Table error: Object ID %d, index ID %d, page %S_PGID. Test (%hs) failed. Values
                               are %ld and %ld.
 8940                          Table error: Object ID %d, index ID %d, page %S_PGID. Test (%hs) failed.
                               Address 0x%x is not aligned.
 8941                          Table error: Object ID %d, index ID %d, page %S_PGID. Test (%hs) failed. Slot
                               %d, offset 0x%x is invalid.
 8942                          Table error: Object ID %d, index ID %d, page %S_PGID. Test (%hs) failed. Slot
                               %d, offset 0x%x overlaps with the prior row.
 8943                          Table error: Object ID %d, index ID %d, page %S_PGID. Test (%hs) failed. Slot
                               %d, row extends into free space at 0x%x.
 8944                          Table error: Object ID %d, index ID %d, page %S_PGID, row %d. Test (%hs)
                               failed. Values are %ld and %ld.
 8945                          Table error: Object ID %d, index ID %d will be rebuilt.
 8946                          Table error: Allocation page %S_PGID has invalid %ls page header values. Type
                               is %d. Check type, object ID and page ID on the page.
 8947                          Table error: Multiple IAM pages for object ID %d, index ID %d contain allocations
                               for the same interval. IAM pages %S_PGID and %S_PGID.
 8948                          Database error: Page %S_PGID is marked with the wrong type in PFS page
                               %S_PGID. PFS status 0x%x expected 0x%x.
 8949                          %.*ls fixed %d allocation errors and %d consistency errors in table '%ls' (object
                               ID %d).
 8950                          %.*ls fixed %d allocation errors and %d consistency errors not associated with
                               any single object.
 8951                          Table error: Table '%ls' (ID %d). Missing or invalid key in index '%ls' (ID %d) for
                               the row:
 8952                          Table error: Database '%ls', index '%ls.%ls' (ID %d) (index ID %d). Extra or invalid
                               key for the keys:
 8953                          Repair: Deleted text column, text ID %I64d, for object ID %d on page %S_PGID,
                               slot %d.
 8954                          %.*ls found %d allocation errors and %d consistency errors not associated with
                               any single object.
 8955                          Data row (%d:%d:%d) identified by (%ls) has index values (%ls).
 8956                          Index row (%d:%d:%d) with values (%ls) points to the data row identified by (%ls).
 8957                          DBCC %ls (%ls%ls%ls) executed by %ls found %d errors and repaired %d errors.
 8958                          %ls is the minimum repair level for the errors found by DBCC %ls (%ls %ls).
 8959                          Table error: IAM page %S_PGID for object ID %d, index ID %d is linked in the
                               IAM chain for object ID %d, index ID %d by page %S_PGID.
 8960                          Table error: Page %S_PGID, slot %d, column %d is not a valid complex column.




InterSystems Error Reference                                                                                     187
TSQL Error Messages


 Error Code           Description
 8961                 Table error: Object ID %d. The text, ntext, or image node at page %S_PGID, slot
                      %d, text ID %I64d does not match its reference from page %S_PGID, slot %d.
 8962                 Table error: The text, ntext, or image node at page %S_PGID, slot %d, text ID
                      %I64d has incorrect node type %d.
 8963                 Table error: The text, ntext, or image node at page %S_PGID, slot %d, text ID
                      %I64d has type %d. It cannot be placed on a page of type %d.
 8964                 Table error: Object ID %d. The text, ntext, or image node at page %S_PGID, slot
                      %d, text ID %I64d is not referenced.
 8965                 Table error: Object ID %d. The text, ntext, or image node at page %S_PGID, slot
                      %d, text ID %I64d is referenced by page %S_PGID, slot %d, but was not seen
                      in the scan.
 8966                 Could not read and latch page %S_PGID with latch type %ls. %ls failed.
 8967                 Table error: Invalid value detected in %ls for Object ID %d, index ID %d. Row
                      skipped.
 8968                 Table error: %ls page %S_PGID (object ID %d, index ID %d) is out of the range
                      of this database.
 8969                 Table error: IAM chain linkage error: Object ID %d, index ID %d. The next page
                      for IAM page %S_PGID is %S_PGID, but the previous link for page %S_PGID
                      is %S_PGID.
 8970                 Row error: Object ID %d, index ID %d, page ID %S_PGID, row ID %d. Column
                      '%.*ls' was created NOT NULL, but is NULL in the row.
 8971                 Forwarded row mismatch: Object ID %d, page %S_PGID, slot %d points to
                      forwarded row page %S_PGID, slot %d; the forwarded row points back to page
                      %S_PGID, slot %d.
 8972                 Forwarded row referenced by more than one row. Object ID %d, page %S_PGID,
                      slot %d incorrectly points to forwarded row page %S_PGID, slot %d; the forwarded
                      row correctly refers back to page %S_PGID, slot %d.
 8973                 CHECKTABLE processing of object ID %d, index ID %d encountered page
                      %S_PGID, slot %d twice. Possible internal error or allocation fault.
 8974                 Text node referenced by more than one node. Object ID %d, text, ntext, or image
                      node page %S_PGID, slot %d, text ID %I64d is pointed to by page %S_PGID,
                      slot %d and by page %S_PGID, slot %d.
 8975                 Table error: Object ID %d, index ID %d. The child page pointer %S_PGID on
                      PageId %S_PGID, slot %d is not a valid page for this database.
 8976                 Table error: Object ID %d, index ID %d. Page %S_PGID was not seen in the
                      scan although its parent %S_PGID and previous %S_PGID refer to it. Check any
                      previous errors.
 8977                 Table error: Object ID %d, index ID %d. Parent node for page %S_PGID was not
                      encountered.
 8978                 Table error: Object ID %d, index ID %d. Page %S_PGID is missing a reference
                      from previous page %S_PGID. Possible chain linkage problem.




188                                                                         InterSystems Error Reference
                                                                                             TSQL Error Messages


 Error Code                    Description
 8979                          Table error: Object ID %d, index ID %d. Page %S_PGID is missing references
                               from parent (unknown) and previous (page %S_PGID) nodes. Possible bad root
                               entry in sysindexes.
 8980                          Table error: Object ID %d, index ID %d. Index node page %S_PGID, slot %d
                               refers to child page %S_PGID and previous child %S_PGID, but they were not
                               encountered.
 8981                          Table error: Object ID %d, index ID %d. The next pointer of %S_PGID refers to
                               page %S_PGID. Neither %S_PGID nor its parent were encountered. Possible
                               bad chain linkage.
 8982                          Table error: Cross object linkage. Page %S_PGID->next in object ID %d, index
                               ID %d refers to page %S_PGID in object ID %d, index ID %d but is not in the
                               same index.
 8983                          File %d. Extents %d, used pages %d, reserved pages %d, mixed extents %d,
                               mixed pages %d.
 8984                          Object ID %d, index ID %d. Allocations for %S_PGID. IAM %S_PGID, extents
                               %d, used pages %d, mixed pages %d.
 8985                          Could not locate file '%.*ls' in sysfiles.
 8986                          Too many errors found (%d) for object ID %d. To see all error messages rerun
                               the statement using "WITH ALL_ERRORMSGS".
 8987                          No help available for DBCC statement '%.*ls'.
 8988                          The schema for database '%ls' is changing. May find spurious allocation problems
                               due to schema changes in progress.
 8989                          %.*ls found %d allocation errors and %d consistency errors in database '%ls'.
 8990                          %.*ls found %d allocation errors and %d consistency errors in table '%ls' (object
                               ID %d).
 8991                          0x%.8x + 0x%.8x bytes is not a valid address range.
 8992                          Database ID %d, object '%ls' (ID %d). Loop in data chain detected at %S_PGID.
 8993                          Object ID %d, forwarding row page %S_PGID, slot %d points to page %S_PGID,
                               slot %d. Did not encounter forwarded row. Possible allocation error.
 8994                          Object ID %d, forwarded row page %S_PGID, slot %d should be pointed to by
                               forwarding row page %S_PGID, slot %d. Did not encounter forwarding row.
                               Possible allocation error.
 8995                          System table '%.*ls' (object ID %d, index ID %d) is in filegroup %d. All system
                               tables must be in filegroup %d.
 8996                          IAM page %S_PGID for object ID %d, index ID %d controls pages in filegroup
                               %d, that should be in filegroup %d.
 8997                          Single page allocation %S_PGID for object ID %d, index ID %d is in filegroup
                               %d; it should be in filegroup %d.
 8998                          Page errors on the GAM, SGAM, or PFS pages do not allow CHECKALLOC to
                               verify database ID %d pages from %S_PGID to %S_PGID. See other errors for
                               cause.



InterSystems Error Reference                                                                                     189
TSQL Error Messages


 Error Code                Description
 8999                      Database tempdb allocation errors prevent further %ls processing.

Table 3–64:TSQL Error Codes - 9000 to 9099

 Error Code                Description
 9001                      The log for database '%.*ls' is not available.
 9002                      The log file for database '%.*ls' is full. Back up the transaction log for the database
                           to free up some log space.
 9003                      The LSN %S_LSN passed to log scan in database '%.*ls' is invalid.
 9004                      An error occurred while processing the log for database '%.*ls'.
 9005                      Either start LSN or end LSN specified in OpenRowset(DBLog, ...) is invalid.
 9006                      Cannot shrink log file %d (%s) because total number of logical log files cannot
                           be fewer than %d.
 9007                      Cannot shrink log file %d (%s) because requested size (%dKB) is larger than the
                           start of the last logical log file.
 9008                      Cannot shrink log file %d (%s) because all logical log files are in use.
 9009                      Cannot shrink log file %d (%s) because of minimum log space required.
 9010                      User does not have permission to query the virtual table, DBLog. Only members
                           of the sysadmin fixed server role and the db_owner fixed database role have this
                           permission


Table 3–65:TSQL Error Codes - 10000 to 10999

 Error Code                Description
 10000                     Unknown provider error.
 10001                     The provider reported an unexpected catastrophic failure.
 10002                     The provider did not implement the functionality.
 10003                     The provider ran out of memory.
 10004                     One or more arguments were reported invalid by the provider.
 10005                     The provider did not support an interface.
 10006                     The provider indicated an invalid pointer was used.
 10007                     The provider indicated an invalid handle was used.
 10008                     The provider terminated the operation.
 10009                     The provider did not give any information about the error.
 10010                     The data necessary to complete this operation was not yet available to the
                           provider.
 10011                     Access denied.
 10021                     Execution terminated by the provider because a resource limit was reached.




190                                                                                  InterSystems Error Reference
                                                                                              TSQL Error Messages


 Error Code                    Description
 10022                         The provider called a method from IRowsetNotify in the consumer, and the method
                               has not yet returned.
 10023                         The provider does not support the necessary method.
 10024                         The provider indicates that the user did not have the permission to perform the
                               operation.
 10025                         Provider caused a server fault in an external process.
 10026                         No command text was set.
 10027                         Command was not prepared.
 10028                         Authentication failed.
 10031                         An error occurred because one or more properties could not be set.
 10032                         Cannot return multiple result sets (not supported by the provider).
 10033                         The specified index does not exist or the provider does not support an index scan
                               on this data source.
 10034                         The specified table does not exist.
 10035                         No value was given for one or more of the required parameters.
 10041                         Could not set any property values.
 10042                         Cannot set any properties while there is an open rowset.
 10051                         An error occurred while setting the data.
 10052                         The insertion was canceled by the provider during notification.
 10053                         Could not convert the data value due to reasons other than sign mismatch or
                               overflow.
 10054                         The data value for one or more columns overflowed the type used by the provider.
 10055                         The data violated the integrity constraints for one or more columns.
 10056                         The number of rows that have pending changes has exceeded the limit specified
                               by the DBPROP_MAXPENDINGROWS property.
 10057                         Cannot create the row. Would exceed the total number of active rows supported
                               by the rowset.
 10058                         The consumer cannot insert a new row before releasing previously-retrieved row
                               handles.
 10061                         An error occurred while setting data for one or more columns.
 10062                         The change was canceled by the provider during notification.
 10063                         Could not convert the data value due to reasons other than sign mismatch or
                               overflow.
 10064                         The data value for one or more columns overflowed the type used by the provider.
 10065                         The data violated the integrity constraints for one or more columns.
 10066                         The number of rows that have pending changes has exceeded the limit specified
                               by the DBPROP_MAXPENDINGROWS property.



InterSystems Error Reference                                                                                 191
TSQL Error Messages


 Error Code                Description
 10067                     The rowset was using optimistic concurrency and the value of a column has been
                           changed after the containing row was last fetched or resynchronized.
 10068                     The consumer could not delete the row. A deletion is pending or has already been
                           transmitted to the data source.
 10069                     The consumer could not delete the row. The insertion has been transmitted to
                           the data source.
 10075                     An error occurred while deleting the row.
 10081                     The rowset uses integrated indexes and there is no current index.
 10085                     RestartPosition on the table was canceled during notification.
 10086                     The table was built over a live data stream and the position cannot be restarted.
 10087                     The provider did not release some of the existing rows.
 10088                     The order of the columns was not specified in the object that created the rowset.
                           The provider had to reexecute the command to reposition the next fetch position
                           to its initial position, and the order of the columns changed.

Table 3–66:TSQL Error Codes - 11000 to 11999

 Error Code                Description
 11000                     Unknown status code for this column.
 11001                     Non-NULL value successfully returned.
 11002                     Deferred accessor validation occurred. Invalid binding for this column.
 11003                     Could not convert the data value due to reasons other than sign mismatch or
                           overflow.
 11004                     Successfully returned a NULL value.
 11005                     Successfully returned a truncated value.
 11006                     Could not convert the data type because of a sign mismatch.
 11007                     Conversion failed because the data value overflowed the data type used by the
                           provider.
 11008                     The provider cannot allocate memory or open another storage object on this
                           column.
 11009                     The provider cannot determine the value for this column.
 11010                     The user did not have permission to write to the column.
 11011                     The data value violated the integrity constraints for the column.
 11012                     The data value violated the schema for the column.
 11013                     The column had a bad status.
 11014                     The column used the default value.
 11015                     The column was skipped when setting data.
 11031                     The row was successfully deleted.



192                                                                               InterSystems Error Reference
                                                                                               TSQL Error Messages


 Error Code                    Description
 11032                         The table was in immediate-update mode, and deleting a single row caused more
                               than one row to be deleted in the data source.
 11033                         The row was released even though it had a pending change.
 11034                         Deletion of the row was canceled during notification.
 11036                         The rowset was using optimistic concurrency and the value of a column has been
                               changed after the containing row was last fetched or resynchronized.
 11037                         The row has a pending delete or the deletion had been transmitted to the data
                               source.
 11038                         The row is a pending insert row.
 11039                         DBPROP_CHANGEINSERTEDROWS was VARIANT_FALSE and the insertion
                               for the row has been transmitted to the data source.
 11040                         Deleting the row violated the integrity constraints for the column or table.
 11041                         The row handle was invalid or was a row handle to which the current thread does
                               not have access rights.
 11042                         Deleting the row would exceed the limit for pending changes specified by the
                               rowset property DBPROP_MAXPENDINGROWS.
 11043                         The row has a storage object open.
 11044                         The provider ran out of memory and could not fetch the row.
 11045                         User did not have sufficient permission to delete the row.
 11046                         The table was in immediate-update mode and the row was not deleted due to
                               reaching a limit on the server, such as query execution timing out.
 11047                         Updating did not meet the schema requirements.
 11048                         There was a recoverable, provider-specific error, such as an RPC failure.
 11100                         The provider indicates that conflicts occurred with other properties or requirements.
 11101                         Could not obtain an interface required for text, ntext, or image access.
 11102                         The provider could not support a required row lookup interface.
 11103                         The provider could not support an interface required for the
                               UPDATE/DELETE/INSERT statements.
 11104                         The provider could not support insertion on this table.
 11105                         The provider could not support updates on this table.
 11106                         The provider could not support deletion on this table.
 11107                         The provider could not support a row lookup position.
 11108                         The provider could not support a required property.
 11109                         The provider does not support an index scan on this data source.




InterSystems Error Reference                                                                                     193
TSQL Error Messages


Table 3–67:TSQL Error Codes - 13000 to 13999

 Error Code                Description
 13001                     data page
 13002                     index page
 13003                     leaf page
 13004                     last
 13005                     root
 13006                     read from
 13007                     send to
 13008                     receive
 13009                     send
 13010                     read
 13011                     wait
 13012                     a USE database statement
 13013                     a procedure or trigger
 13014                     a DISTINCT clause
 13015                     a view
 13016                     an INTO clause
 13017                     an ORDER BY clause
 13018                     a COMPUTE clause
 13019                     a SELECT INTO statement
 13020                     option
 13021                     offset option
 13022                     statistics option
 13023                     parameter option
 13024                     function name
 13025                     varbinary (128) NOT NULL
 13026                     parameter
 13027                     convert specification
 13028                     index
 13029                     table
 13030                     database
 13031                     procedure
 13032                     trigger
 13033                     view



194                                                   InterSystems Error Reference
                                                                                           TSQL Error Messages


 Error Code                    Description
 13034                         default
 13035                         rule
 13036                         system table
 13037                         unknown type
 13038                         SET statement
 13039                         column
 13040                         type
 13041                         character string
 13042                         integer
 13043                         identifier
 13044                         number
 13045                         integer value
 13046                         floating point value
 13047                         object
 13048                         column heading
 13076                         an assignment
 13077                         a cursor declaration
 13078                         replication filter
 13079                         variable assignment
 13080                         statistics
 13081                         file
 13082                         filegroup
 13083                         server
 13084                         write
 13085                         function
 13086                         database collation
 13087                         drop
 13088                         alter

Table 3–68:TSQL Error Codes - 14000 to 14999

 Error Code                    Description
 14002                         Could not find the 'Sync' subsystem with the task ID %ld.
 14003                         You must supply a publication name.
 14004                         %s must be in the current database.




InterSystems Error Reference                                                                              195
TSQL Error Messages


 Error Code           Description
 14005                Could not drop publication. A subscription exists to it.
 14006                Could not drop the publication.
 14008                There are no publications.
 14009                There are no articles for publication '%s'.
 14010                The remote server is not defined as a subscription server.
 14012                The @status parameter value must be either 'active' or 'inactive'.
 14013                This database is not enabled for publication.
 14014                The synchronization method (@sync_method) must be '[bcp] native', '[bcp]
                      character', 'concurrent' or 'concurrent_c'.
 14015                The replication frequency (@repl_freq) must be either 'continuous' or 'snapshot'.
 14016                The publication '%s' already exists.
 14017                Invalid @restricted parameter value. Valid options are 'true' or 'false'.
 14018                Could not create the publication.
 14019                The @operation parameter value must be either 'add' or 'drop'.
 14020                Could not obtain the column ID for the specified column. Schema replication
                      failed.
 14021                The column was not added correctly to the article.
 14022                The @property parameter value must be either 'description', 'sync_object', 'type',
                      'ins_cmd', 'del_cmd', 'upd_cmd', 'filter', 'dest_table', 'dest_object', 'creation_script',
                      'pre_creation_cmd', 'status', 'schema_option', or 'destination_owner'.
 14023                The type must be '[indexed view] logbased', '[indexed view] logbased manualfilter',
                      '[indexed view] logbased manualview', '[indexed view] logbased manualboth', or
                      '( view | indexed view | proc | func ) schema only'.
 14025                Article update successful.
 14027                %s does not exist in the current database.
 14028                Only user tables, materialized views, and stored procedures can be published as
                      'logbased' articles.
 14029                The vertical partition switch must be either 'true' or 'false'.
 14030                The article '%s' exists in publication '%s'.
 14031                User tables and views are the only valid synchronization objects.
 14032                The value of parameter %s cannot be 'all'. It is reserved by replication stored
                      procedures.
 14033                Could not change replication frequency because there are active subscriptions
                      on the publication.
 14034                The publication name (@publication) cannot be the keyword 'all'.
 14035                The replication option '%s' of database '%s' has already been set to true.
 14036                Could not enable database for publishing.



196                                                                               InterSystems Error Reference
                                                                                                 TSQL Error Messages


 Error Code                    Description
 14037                         The replication option '%s' of database '%s' has been set to false.
 14038                         Could not disable database for publishing.
 14039                         Could not construct column clause for article view. Reduce the number of columns
                               or create the view manually.
 14040                         The server '%s' is already a Subscriber.
 14042                         Could not create Subscriber.
 14043                         The parameter %s cannot be NULL.
 14046                         Could not drop article. A subscription exists on it.
 14047                         Could not drop %s.
 14048                         The server '%s' is not a Subscriber.
 14049                         Stored procedures for replication are the only objects that can be used as a filter.
 14050                         No subscription is on this publication or article.
 14051                         The parameter value must be 'sync_type' or 'dest_db'.
 14052                         The @sync_type parameter value must be 'automatic' or 'none'.
 14053                         The subscription could not be updated at this time.
 14054                         The subscription was updated successfully.
 14055                         The subscription does not exist.
 14056                         The subscription could not be dropped at this time.
 14057                         The subscription could not be created.
 14058                         The subscription already exists.
 14059                         Materialized view articles cannot be created for publications with the properties
                               allow_sync_tran, allow_queued_tran, or allow_dts.
 14061                         The @pre_creation_cmd parameter value must be 'none', 'drop', 'delete', or
                               'truncate'.
 14062                         The Subscriber was dropped.
 14063                         The remote server does not exist or has not been designated as a valid Subscriber.
 14065                         The @status parameter value must be 'initiated', 'active', 'inactive', or 'subscribed'.
 14066                         The previous status must be 'active', 'inactive', or 'subscribed'.
 14067                         The status value is the same as the previous status value.
 14068                         Could not update sysobjects. The subscription status could not be changed.
 14069                         Could not update sysarticles. The subscription status could not be changed.
 14070                         Could not update the distribution database subscription table. The subscription
                               status could not be changed.
 14071                         Could not find the Distributor or the distribution database for the local server. The
                               Distributor may not be installed, or the local server may not be configured as a
                               Publisher at the Distributor.



InterSystems Error Reference                                                                                       197
TSQL Error Messages


 Error Code                Description
 14074                     The server '%s' is already listed as a Publisher.
 14075                     The Publisher could not be created at this time.
 14076                     Could not grant replication login permission to '%s'.
 14077                     The publication was updated successfully.
 14078                     The parameter must be 'description', 'taskid', 'sync_method', 'status', 'repl_freq',
                           'restricted', 'retention', 'immediate_sync', 'enabled_for_internet', 'allow_push',
                           'allow_pull', 'allow_anonymous', or 'retention'.
 14080                     The remote server does not exist or has not been designated as a valid Publisher.
 14085                     The Subscriber information could not be obtained from the Distributor.
 14088                     The table '%s' must have a primary key to be published using the
                           transaction-based method.
 14089                     The clustered index on materialized view '%s' may not contain nullable columns
                           if it is to be published using the transaction-based method.
 14090                     Error evaluating article synchronization object after column drop. The filter clause
                           for article '%s' must not reference the dropped column.
 14091                     The @type parameter passed to sp_helpreplicationdb must be either 'pub' or
                           'sub'.
 14092                     Could not change article because there is an existing subscription to the article.
 14093                     Cannot grant or revoke access directly on publication '%s' because it uses the
                           default publication access list.
 14094                     Could not subscribe to article '%s' because heterogeneous Subscriber '%s' does
                           not support the @pre_creation_cmd parameter value 'truncate'.
 14095                     Could not subscribe to publication '%s' because heterogeneous Subscriber '%s'
                           only supports the @sync_method parameter value 'bcp character' .
 14096                     The path and name of the table creation script must be specified if the
                           @pre_creation_cmd parameter value is 'drop'.
 14097                     The 'status' value must be 'no column names', 'include column names', 'string
                           literals', 'parameters', 'DTS horizontal partitions' or 'no DTS horizontal partitions'.
 14098                     Cannot drop Distribution Publisher '%s'. The remote Publisher is using '%s' as
                           Distributor.
 14099                     The server '%s' is already defined as a Distributor.

Table 3–69:TSQL Error Codes - 14100 to 14199

 Error Code                Description
 14100                     Specify all articles when subscribing to a publication using concurrent snapshot
                           processing.
 14101                     The publication '%s' already has a Snapshot Agent defined.
 14102                     Specify all articles when unsubscribing from a publication using concurrent
                           snapshot processing.



198                                                                                  InterSystems Error Reference
                                                                                               TSQL Error Messages


 Error Code                    Description
 14105                         You have updated the distribution database property '%s' successfully.
 14106                         Distribution retention periods must be greater than 0.
 14107                         The @max_distretention value must be larger than the @min_distretention value.
 14108                         Removed %ld history records from %s.
 14109                         The @security_mode parameter value must be 0 (SQL Server Authentication) or
                               1 (Windows Authentication).
 14110                         For stored procedure articles, the @property parameter value must be 'description',
                               'dest_table', 'dest_object', 'creation_script', 'pre_creation_cmd', 'schema_option',
                               or 'destination_owner'.
 14111                         The @pre_creation_cmd parameter value must be 'none' or 'drop'.
 14112                         This procedure can be executed only against table-based articles.
 14113                         Could not execute '%s'. Check '%s' in the install directory.
 14114                         '%s' is not configured as a Distributor.
 14115                         The property parameter value must be %s.
 14117                         '%s' is not configured as a distribution database.
 14118                         A stored procedure can be published only as a 'serializable proc exec' article, a
                               'proc exec' article, or a 'proc schema only' article.
 14119                         Could not add the distribution database '%s'. This distribution database already
                               exists.
 14120                         Could not drop the distribution database '%s'. This distributor database is
                               associated with a Publisher.
 14121                         Could not drop the Distributor '%s'. This Distributor has associated distribution
                               databases.
 14122                         The @article parameter value must be 'all' for immediate_sync publications.
 14123                         The subscription @sync_type parameter value 'manual' is no longer supported.
 14124                         A publication must have at least one article before a subscription to it can be
                               created.
 14126                         You do not have the required permissions to complete the operation.
 14128                         Invalid @subscription_type parameter value. Valid options are 'push' or 'pull'.
 14129                         The @status parameter value must be NULL for 'automatic' sync_type when you
                               add subscriptions to an immediate_sync publication.
 14135                         There is no subscription on Publisher '%s', publisher database '%s', publication
                               '%s'.
 14136                         The keyword 'all' is reserved by replication stored procedures.
 14137                         The @value parameter value must be either 'true' or 'false'.
 14138                         Invalid option name '%s'.
 14139                         The replication system table '%s' already exists.



InterSystems Error Reference                                                                                       199
TSQL Error Messages


 Error Code                Description
 14143                     Cannot drop Distributor Publisher '%s'. There are Subscribers associated with it
                           in the distribution database '%s'.
 14144                     Cannot drop Subscriber '%s'. There are subscriptions from it in the publication
                           database '%s'.
 14146                     The article parameter '@schema_option' cannot be NULL.
 14147                     Restricted publications are no longer supported.
 14148                     Invalid '%s' value. Valid values are 'true' or 'false'.
 14149                     Removed %ld replication history records in %s seconds (%ld row/secs).
 14150                     Replication-%s: agent %s succeeded. %s
 14151                     Replication-%s: agent %s failed. %s
 14152                     Replication-%s: agent %s scheduled for retry. %s
 14153                     Replication-%s: agent %s warning. %s
 14154                     The Distributor parameter must be '@heartbeat_interval'.
 14155                     Invalid article ID specified for procedure script generation.
 14156                     The custom stored procedure was not specified in the article definition.
 14157                     The subscription created by Subscriber '%s' to publication '%s' has expired and
                           has been dropped.
 14158                     Replication-%s: agent %s: %s.
 14159                     Could not change property '%s' for article '%s' because there is an existing
                           subscription to the article.
 14199                     The specified job "%s" is not created for maintenance plans.

Table 3–70:TSQL Error Codes - 14200 to 14299

 Error Code                Description
 14200                     The specified '%s' is invalid.
 14201                     0 (all steps) ..
 14202                     before or after @active_start_time
 14203                     sp_helplogins [excluding Windows NT groups]
 14204                     0 (non-idle), 1 (executing), 2 (waiting for thread), 3 (between retries), 4 (idle), 5
                           (suspended), 7 (performing completion actions)
 14205                     (unknown)
 14206                     0..n seconds
 14207                     -1 [no maximum], 0..n
 14208                     1..7 [1 = E-mail, 2 = Pager, 4 = NetSend]
 14209                     0..127 [1 = Sunday .. 64 = Saturday]
 14210                     notification



200                                                                                  InterSystems Error Reference
                                                                                              TSQL Error Messages


 Error Code                    Description
 14211                         server
 14212                         (all jobs)
 14213                         Core Job Details:
 14214                         Job Steps:
 14215                         Job Schedules:
 14216                         Job Target Servers:
 14217                         SQL Server Warning: '%s' has performed a forced defection of TSX server '%s'.
                               Run sp_delete_targetserver at the MSX in order to complete the defection.
 14218                         hour
 14219                         minute
 14220                         second
 14221                         This job has one or more notifications to operators other than '%s'. The job cannot
                               be targeted at remote servers as currently defined.
 14222                         Cannot rename the '%s' operator.
 14223                         Cannot modify or delete operator '%s' while this server is a %s.
 14224                         Warning: The server name given is not the current MSX server ('%s').
 14225                         Warning: Could not determine local machine name. This prevents MSX operations
                               from being posted.
 14226                         %ld history entries purged.
 14227                         Server defected from MSX '%s'. %ld job(s) deleted.
 14228                         Server MSX enlistment changed from '%s' to '%s'.
 14229                         Server enlisted into MSX '%s'.
 14230                         SP_POST_MSX_OPERATION: %ld %s download instruction(s) posted.
 14231                         SP_POST_MSX_OPERATION Warning: The specified %s ('%s') is not involved
                               in a multiserver job.
 14232                         Specify either a job_name, job_id, or an originating_server.
 14233                         Specify a valid job_id (or 0x00 for all jobs).
 14234                         The specified '%s' is invalid (valid values are returned by %s).
 14235                         The specified '%s' is invalid (valid values are greater than 0 but excluding %ld).
 14236                         Warning: Non-existent step referenced by %s.
 14237                         When an action of 'REASSIGN' is specified, the New Login parameter must also
                               be supplied.
 14238                         %ld jobs deleted.
 14239                         %ld jobs reassigned to %s.
 14240                         Job applied to %ld new servers.




InterSystems Error Reference                                                                                    201
TSQL Error Messages


 Error Code           Description
 14241                Job removed from %ld servers.
 14242                Only a system administrator can reassign ownership of a job.
 14243                Job '%s' started successfully.
 14244                Only a system administrator can reassign tasks.
 14245                Specify either the @name, @id, or @loginname of the task(s) to be deleted.
 14246                Specify either the @currentname or @id of the task to be updated.
 14247                Only a system administrator can view tasks owned by others.
 14248                This login is the owner of %ld job(s). You must delete or reassign these jobs
                      before the login can be dropped.
 14249                Specify either @taskname or @oldloginname when reassigning a task.
 14250                The specified %s is too long. It must contain no more than %ld characters.
 14251                Cannot specify '%s' as the operator to be notified.
 14252                Cannot perform this action on a job you do not own.
 14253                %ld (of %ld) job(s) stopped successfully.
 14254                Job '%s' stopped successfully.
 14255                The owner ('%s') of this job is either an invalid login, or is not a valid user of
                      database '%s'.
 14256                Cannot start job '%s' (ID %s) because it does not have any job server(s) defined.
 14257                Cannot stop job '%s' (ID %s) because it does not have any job server(s) defined.
 14258                Cannot perform this operation while SQLServerAgent is starting. Try again later.
 14259                A schedule (ID %ld, '%s') for this job with this definition already exists.
 14260                You do not have sufficient permission to run this command.
 14261                The specified %s ('%s') already exists.
 14262                The specified %s ('%s') does not exist.
 14263                Target server '%s' is already a member of group '%s'.
 14264                Target server '%s' is not a member of group '%s'.
 14265                The MSSQLServer service terminated unexpectedly.
 14266                The specified '%s' is invalid (valid values are: %s).
 14267                Cannot add a job to the '%s' job category.
 14268                There are no jobs at this server that originated from server '%s'.
 14269                Job '%s' is already targeted at server '%s'.
 14270                Job '%s' is not currently targeted at server '%s'.
 14271                A target server cannot be named '%s'.
 14272                Object-type and object-name must be supplied as a pair.




202                                                                             InterSystems Error Reference
                                                                                              TSQL Error Messages


 Error Code                    Description
 14273                         You must provide either @job_id or @job_name (and, optionally,
                               @schedule_name), or @schedule_id.
 14274                         Cannot add, update, or delete a job (or its steps or schedules) that originated
                               from an MSX server.
 14275                         The originating server must be either '(local)' or '%s'.
 14276                         '%s' is a permanent %s category and cannot be deleted.
 14277                         The command script does not destroy all the objects that it creates. Revise the
                               command script.
 14278                         The schedule for this job is invalid (reason: %s).
 14279                         Supply either @job_name or @originating_server.
 14280                         Supply either a job name (and job aspect), or one or more job filter parameters.
 14281                         Warning: The @new_owner_login_name parameter is not necessary when
                               specifying a 'DELETE' action.
 14282                         Supply either a date (created or last modified) and a data comparator, or no date
                               parameters at all.
 14283                         Supply @target_server_groups or @target_servers, or both.
 14284                         Cannot specify a job ID for a new job. An ID will be assigned by the procedure.
 14285                         Cannot add a local job to a multiserver job category.
 14286                         Cannot add a multiserver job to a local job category.
 14287                         The '%s' supplied has an invalid %s.
 14288                         %s cannot be before %s.
 14289                         %s cannot contain '%s' characters.
 14290                         This job is currently targeted at the local server so cannot also be targeted at a
                               remote server.
 14291                         This job is currently targeted at a remote server so cannot also be targeted at the
                               local server.
 14292                         There are two or more tasks named '%s'. Specify %s instead of %s to uniquely
                               identify the task.
 14293                         There are two or more jobs named '%s'. Specify %s instead of %s to uniquely
                               identify the job.
 14294                         Supply either %s or %s to identify the job.
 14295                         Frequency Type 0x2 (OnDemand) is no longer supported.
 14296                         This server is already enlisted into MSX '%s'.
 14297                         Cannot enlist into the local machine.
 14298                         This server is not currently enlisted into an MSX.
 14299                         Server '%s' is an MSX. Cannot enlist one MSX into another MSX.




InterSystems Error Reference                                                                                     203
TSQL Error Messages


Table 3–71:TSQL Error Codes - 14300 to 14399

 Error Code                Description
 14300                     Circular dependencies exist. Dependency evaluation cannot continue.
 14301                     Logins other than the current user can only be seen by members of the sysadmin
                           role.
 14302                     You must upgrade your client to version 6.5 of SQL-DMO and SQL Server
                           Enterprise Manager to connect to this server. The upgraded versions will
                           administer both SQL Server version 6.5 and 6.0 (if sqlole65.sql is run).
 14303                     Stored procedure '%s' failed to access registry key.
 14304                     Stored procedure '%s' can run only on Windows 2000 servers.
 14350                     Cannot initialize COM library because CoInitialize failed.
 14351                     Cannot complete this operation because an unexpected error occurred.
 14352                     Cannot find Active Directory information in the registry for this SQL Server instance.
                           Run sp_ActiveDirectory_SCP again.
 14353                     Cannot determine the service account for this SQL Server instance.
 14354                     Cannot start the MSSQLServerADHelper service. Verify that the service account
                           for this SQL Server instance has the necessary permissions to start the
                           MSSQLServerADHelper service.
 14355                     The MSSQLServerADHelper service is busy. Retry this operation later.
 14356                     The Windows Active Directory client is not installed properly on the computer
                           where this SQL Server instance is running. LoadLibrary failed to load
                           ACTIVEDS.DLL.
 14357                     Cannot list '%s' in Active Directory because the name is too long. Active Directory
                           common names cannot exceed 64 characters.
 14358                     Cannot determine the SQL Server Agent proxy account for this SQL Server
                           instance or the account is not a domain user account. Use
                           xp_sqlagent_proxy_account to configure SQL Server Agent to use a domain user
                           account as the proxy account.

Table 3–72:TSQL Error Codes - 14400 to 14499

 Error Code                Description
 14410                     You must supply either a plan_name or a plan_id.
 14411                     Cannot delete this plan. The plan contains enlisted databases.
 14412                     The destination database is already part of a log shipping plan.
 14413                     This database is already log shipping.
 14414                     A log shipping monitor is already defined.
 14415                     The user name cannot be null when using SQL Server authentication.
 14416                     This stored procedure must be run in msdb.
 14417                     Cannot delete the monitor server while databases are participating in log shipping.




204                                                                                  InterSystems Error Reference
                                                                                               TSQL Error Messages


 Error Code                    Description
 14418                         The specified @backup_file_name was not created from database '%s'.
 14419                         The specified @backup_file_name is not a database backup.
 14420                         The log shipping source %s.%s has not backed up for %s minutes.
 14421                         The log shipping destination %s.%s is out of sync by %s minutes.
 14422                         Supply either @plan_id or @plan_name.
 14423                         Other databases are enlisted on this plan and must be removed before the plan
                               can be deleted.
 14424                         The database '%s' is already involved in log shipping.
 14425                         The database '%s' does not seem to be involved in log shipping.
 14426                         A log shipping monitor is already defined. Call sp_define_log_shipping_monitor
                               with @delete_existing = 1.
 14427                         A user name is necessary for SQL Server security.
 14428                         Could not remove the monitor as there are still databases involved in log shipping.
 14429                         There are still secondary servers attached to this primary.
 14430                         Invalid destination path %s.
 14440                         Could not set single user mode.
 14441                         Role change succeeded.
 14442                         Role change failed.
 14450                         The specified @backup_file_name was not taken from database '%s'.
 14451                         The specified @backup_file_name is not a database backup.

Table 3–73:TSQL Error Codes - 14500 to 14599

 Error Code                    Description
 14500                         Supply either a non-zero message ID, non-zero severity, or non-null performance
                               condition.
 14501                         An alert ('%s') has already been defined on this condition.
 14502                         The @target_name parameter must be supplied when specifying an @enum_type
                               of 'TARGET'.
 14503                         The @target_name parameter should not be supplied when specifying an
                               @enum_type of 'ALL' or 'ACTUAL'.
 14504                         '%s' is the fail-safe operator.You must make another operator the fail-safe operator
                               before '%s' can be dropped.
 14505                         Specify a null %s when supplying a performance condition.
 14506                         Cannot set alerts on message ID %ld.
 14507                         A performance condition must be formatted as:
                               'object_name|counter_name|instance_name|comparator(> or < or =)|numeric
                               value'.



InterSystems Error Reference                                                                                    205
TSQL Error Messages


 Error Code           Description
 14539                Only a Standard or Enterprise edition of SQL Server can be enlisted into an MSX.
 14540                Only a SQL Server running on Microsoft Windows NT can be enlisted into an
                      MSX.
 14541                The version of the MSX (%s) is not recent enough to support this TSX. Version
                      %s or later is required at the MSX.
 14542                It is invalid for any TSQL step of a multiserver job to have a non-null %s value.
 14543                Login '%s' owns one or more multiserver jobs. Ownership of these jobs can only
                      be assigned to members of the %s role.
 14544                This job is owned by '%s'. Only a job owned by a member of the %s role can be
                      a multiserver job.
 14545                The %s parameter is not valid for a job step of type '%s'.
 14546                The %s parameter is not supported on Windows 95/98 platforms.
 14547                Warning: This change will not be downloaded by the target server(s) until an %s
                      for the job is posted using %s.
 14548                Target server '%s' does not have any jobs assigned to it.
 14549                (Description not requested.)
 14550                Command-Line Subsystem
 14551                Replication Snapshot Subsystem
 14552                Replication Transaction-Log Reader Subsystem
 14553                Replication Distribution Subsystem
 14554                Replication Merge Subsystem
 14555                Active Scripting Subsystem
 14556                Transact-SQL Subsystem
 14557                [Internal]
 14558                (encrypted command)
 14559                (append output file)
 14560                (include results in history)
 14561                (normal)
 14562                (quit with success)
 14563                (quit with failure)
 14564                (goto next step)
 14565                (goto step)
 14566                (idle)
 14567                (below normal)
 14568                (above normal)




206                                                                           InterSystems Error Reference
                                                                                             TSQL Error Messages


 Error Code                    Description
 14569                         (time critical)
 14570                         (Job outcome)
 14571                         No description available.
 14572                         @freq_interval must be at least 1 for a daily job.
 14573                         @freq_interval must be a valid day of the week bitmask [Sunday = 1 .. Saturday
                               = 64] for a weekly job.
 14574                         @freq_interval must be between 1 and 31 for a monthly job.
 14575                         @freq_relative_interval must be one of 1st (0x1), 2nd (0x2), 3rd [0x4], 4th (0x8)
                               or Last (0x10).
 14576                         @freq_interval must be between 1 and 10 (1 = Sunday .. 7 = Saturday, 8 = Day,
                               9 = Weekday, 10 = Weekend-day) for a monthly-relative job.
 14577                         @freq_recurrence_factor must be at least 1.
 14578                         Starts whenever the CPU usage has remained below %ld percent for %ld seconds.
 14579                         Automatically starts when SQLServerAgent starts.
 14580                         job
 14581                         Replication Transaction Queue Reader Subsystem
 14585                         Only the owner of DTS Package '%s' or a member of the sysadmin role may
                               reassign its ownership.
 14586                         Only the owner of DTS Package '%s' or a member of the sysadmin role may
                               create new versions of it.
 14587                         Only the owner of DTS Package '%s' or a member of the sysadmin role may drop
                               it or any of its versions.
 14588                         ID.VersionID =
 14589                         [not specified]
 14590                         DTS Package '%s' already exists with a different ID in this category.
 14591                         DTS Category '%s' already exists in the specified parent category.
 14592                         DTS Category '%s' was found in multiple parent categories. You must uniquely
                               specify the category to be dropped.
 14593                         DTS Category '%s' contains packages and/or other categories. You must drop
                               these first, or specify a recursive drop.
 14594                         DTS Package
 14595                         DTS Package '%s' exists in different categories. You must uniquely specify the
                               package.
 14596                         DTS Package '%s' exists in another category.
 14597                         DTS Package ID '%s' already exists with a different name.
 14598                         Cannot drop the Local, Repository, or LocalDefault DTS categories.
 14599                         Name



InterSystems Error Reference                                                                                    207
TSQL Error Messages


Table 3–74:TSQL Error Codes - 15000 to 15099

 Error Code                Description
 15001                     Object '%ls' does not exist or is not a valid object for this operation.
 15002                     The procedure '%s' cannot be executed within a transaction.
 15003                     Only members of the %s role can execute this stored procedure.
 15004                     Name cannot be NULL.
 15005                     Statistics for all tables have been updated.
 15006                     '%s' is not a valid name because it contains invalid characters.
 15007                     The login '%s' does not exist.
 15008                     User '%s' does not exist in the current database.
 15009                     The object '%s' does not exist in database '%s'.
 15010                     The database '%s' does not exist. Use sp_helpdb to show available databases.
 15011                     Database option '%s' does not exist.
 15012                     The device '%s' does not exist. Use sp_helpdevice to show available devices.
 15013                     Table '%s': No columns without statistics found.
 15014                     The role '%s' does not exist in the current database.
 15015                     The server '%s' does not exist. Use sp_helpserver to show available servers.
 15016                     The default '%s' does not exist.
 15017                     The rule '%s' does not exist.
 15018                     Table '%s': Creating statistics for the following columns:
 15019                     The extended stored procedure '%s' does not exist.
 15020                     Statistics have been created for the %d listed columns of the above tables.
 15021                     There are no remote users mapped to any local user from remote server '%s'.
 15022                     The specified user name is already aliased.
 15023                     User or role '%s' already exists in the current database.
 15024                     The group '%s' already exists in the current database.
 15025                     The login '%s' already exists.
 15026                     Logical device '%s' already exists.
 15027                     There are no remote users mapped to local user '%s' from remote server '%s'.
 15028                     The server '%s' already exists.
 15029                     The data type '%s' already exists in the current database.
 15030                     The read-only bit cannot be turned off because the database is in standby mode.
 15031                     'Virtual_device' device added.
 15032                     The database '%s' already exists.
 15033                     '%s' is not a valid official language name.



208                                                                                  InterSystems Error Reference
                                                                                                TSQL Error Messages


 Error Code                    Description
 15034                         The application role password must not be NULL.
 15035                         '%s' is not a database device.
 15036                         The data type '%s' does not exist.
 15037                         The physical data type '%s' does not allow nulls.
 15038                         User-defined data types based on timestamp are not allowed.
 15039                         The language %s already exists in syslanguages.
 15040                         User-defined error messages must have an ID greater than 50000.
 15041                         User-defined error messages must have a severity level between 1 and 25.
 15043                         You must specify 'REPLACE' to overwrite an existing message.
 15044                         '%s' is an unknown device type. Use 'disk', 'tape', or 'pipe'.
 15045                         The logical name cannot be NULL.
 15046                         The physical name cannot be NULL.
 15047                         The only permitted options for a tape device are 'skip' and 'noskip'.
 15048                         Valid values of database compatibility level are %d, %d, %d, or %d.
 15049                         Cannot unbind from '%s'. Use ALTER TABLE DROP CONSTRAINT.
 15050                         Cannot bind default '%s'. The default must be created using the CREATE
                               DEFAULT statement.
 15051                         Cannot rename the table because it is published for replication.
 15052                         Prior to updating sysdatabases entry for database '%s', mode = %d and status
                               = %d (status suspect_bit = %d).
 15053                         Objects exist which are not owned by the database owner.
 15054                         The current compatibility level is %d.
 15055                         Error. Updating sysdatabases returned @@error <> 0.
 15056                         No row in sysdatabases was updated because mode and status are already
                               correctly reset. No error and no changes made.
 15057                         List of %s name contains spaces, which are not allowed.
 15058                         List of %s has too few names.
 15059                         List of %s has too many names.
 15060                         List of %s names contains name(s) which have '%s' non-alphabetic characters.
 15061                         Add device request denied. A physical device named '%s' already exists.
 15062                         The guest user cannot be mapped to a login name.
 15063                         The login already has an account under a different user name.
 15064                         PRIMARY KEY and UNIQUE KEY constraints do not have space allocated.
 15065                         All user IDs have been assigned.
 15066                         A default-name mapping of a remote login from remote server '%s' already exists.



InterSystems Error Reference                                                                                   209
TSQL Error Messages


 Error Code           Description
 15067                '%s' is not a local user. Remote login denied.
 15068                A remote user '%s' already exists for remote server '%s'.
 15069                One or more users are using the database. The requested operation cannot be
                      completed.
 15070                Object '%s' was successfully marked for recompilation.
 15071                Usage: sp_addmessage <msgnum>,<severity>,<msgtext> [,<language> [,FALSE
                      | TRUE [,REPLACE]]]
 15072                Usage: sp_addremotelogin remoteserver [, loginame [,remotename]]
 15073                For row in sysdatabases for database '%s', the status bit %d was forced off and
                      mode was forced to 0.
 15074                Warning: You must recover this database prior to access.
 15075                The data type '%s' is reserved for future use.
 15076                Default, table, and user data types must be in the current database.
 15077                Rule, table, and user data type must be in the current database.
 15078                The table or view must be in the current database.
 15079                Queries processed: %d.
 15081                Membership of the public role cannot be changed.
 15082                NULL is not an acceptable parameter value for this procedure. Use a percent
                      sign instead.
 15083                Physical data type '%s' does not accept a collation
 15084                The column or user data type must be in the current database.
 15085                Usage: sp_addtype name, 'data type' [,'NULL' | 'NOT NULL']
 15086                Invalid precision specified. Precision must be between 1 and 38.
 15087                Invalid scale specified. Scale must be less than precision and positive.
 15088                The physical data type is fixed length. You cannot specify the length.
 15089                Cannot change the '%s' option of a database while another user is in the database.
 15090                There is already a local server.
 15091                You must specify a length with this physical data type.
 15092                Invalid length specified. Length must be between 1 and 8000 bytes.
 15093                '%s' is not a valid date order.
 15094                '%s' is not a valid first day.
 15095                Insert into syslanguages failed. Language not added.
 15097                The size associated with an extended property cannot be more than 7,500 bytes.




210                                                                             InterSystems Error Reference
                                                                                                   TSQL Error Messages


Table 3–75:TSQL Error Codes - 15100 to 15199

 Error Code                    Description
 15100                         Usage: sp_bindefault defaultname, objectname [, 'futureonly']
 15101                         Cannot bind a default to a column of data type timestamp.
 15102                         Cannot bind a default to an identity column.
 15103                         Cannot bind a default to a column created with or altered to have a default value.
 15104                         You do not own a table named '%s' that has a column named '%s'.
 15105                         You do not own a data type with that name.
 15106                         Usage: sp_bindrule rulename, objectname [, 'futureonly']
 15107                         Cannot bind a rule to a column of data type text, ntext, image, or timestamp.
 15109                         Cannot change the owner of the master database.
 15110                         The proposed new database owner is already a user in the database.
 15111                         The proposed new database owner is already aliased in the database.
 15112                         The third parameter for table option 'text in row' is invalid. It should be 'on', 'off',
                               '0', or a number from 24 through 7000.
 15123                         The configuration option '%s' does not exist, or it may be an advanced option.
 15124                         The configuration option '%s' is not unique.
 15125                         Trigger '%s' is not a trigger for '%s'.
 15126                         Trigger '%s' was not found.
 15127                         Cannot set the default language to a language ID not defined in syslanguages.
 15129                         '%d' is not a valid value for configuration option '%s'.
 15130                         Table '%s' already has a '%s' trigger for '%s'.
 15131                         Usage: sp_dbremove <dbname> [,dropdev]
 15132                         Cannot change default database belonging to someone else.
 15133                         INSTEAD OF trigger '%s' cannot be associated with an order.
 15134                         No alias exists for the specified user.
 15135                         Object is invalid. Extended properties are not permitted on '%s', or the object does
                               not exist.
 15139                         The device is a RAM disk and cannot be used as a default device.
 15140                         Usage: sp_diskdefault logicalname {defaulton | defaultoff}
 15142                         Cannot drop the role '%s'.
 15143                         '%s' is not a valid option for the @updateusage parameter. Enter either 'true' or
                               'false'.
 15144                         The role has members. It must be empty before it can be dropped.
 15174                         Login '%s' owns one or more database(s). Change the owner of the following
                               database(s) before dropping login:



InterSystems Error Reference                                                                                          211
TSQL Error Messages


 Error Code                Description
 15175                     Login '%s' is aliased or mapped to a user in one or more database(s). Drop the
                           user or alias before dropping the login.
 15176                     The only valid @parameter value is 'WITH_LOG'.
 15177                     Usage: sp_dropmessage <msg number> [,<language> | 'ALL']
 15178                     Cannot drop a message with an ID less than 50000.
 15179                     Message number %u does not exist.
 15180                     Cannot drop. The data type is being used.
 15181                     Cannot drop the database owner.
 15182                     Cannot drop the guest user from master or tempdb.
 15183                     The user owns objects in the database and cannot be dropped.
 15184                     The user owns data types in the database and cannot be dropped.
 15185                     There is no remote user '%s' mapped to local user '%s' from the remote server
                           '%s'.
 15190                     There are still remote logins for the server '%s'.
 15191                     Usage: sp_dropserver server [, droplogins]
 15193                     This procedure can only be used on system tables.
 15194                     Cannot re-create index on this table.
 15197                     There is no text for object '%s'.
 15198                     The name supplied (%s) is not a user, role, or aliased login.

Table 3–76:TSQL Error Codes - 15200 to 15299

 Error Code                Description
 15200                     There are no remote servers defined.
 15201                     There are no remote logins for the remote server '%s'.
 15202                     There are no remote logins defined.
 15203                     There are no remote logins for '%s'.
 15204                     There are no remote logins for '%s' on remote server '%s'.
 15205                     There are no servers defined.
 15206                     Invalid Remote Server Option: '%s'.
 15210                     Only members of the sysadmin role can use the loginame option. The password
                           was not changed.
 15211                     Old (current) password incorrect for user. The password was not changed.
 15216                     '%s' is not a valid option for the @delfile parameter.
 15217                     Property cannot be updated or deleted. Property '%s' does not exist for '%s'.
 15218                     Object '%s' is not a table.




212                                                                                 InterSystems Error Reference
                                                                                            TSQL Error Messages


 Error Code                    Description
 15220                         Usage: sp_remoteoption [remoteserver, loginame, remotename, optname, {true
                               | false}]
 15221                         Remote login option does not exist or cannot be set by user. Run sp_remoteoption
                               with no parameters to see options.
 15222                         Remote login option '%s' is not unique.
 15223                         Error: The input parameter '%s' is not allowed to be null.
 15224                         Error: The value for the @newname parameter contains invalid characters or
                               violates a basic restriction (%s).
 15225                         No item by the name of '%s' could be found in the current database '%s', given
                               that @itemtype was input as '%s'.
 15227                         The database '%s' cannot be renamed.
 15228                         A member of the sysadmin role must set database '%s' to single user mode with
                               sp_dboption before it can be renamed.
 15233                         Property cannot be added. Property '%s' already exists for '%s'.
 15234                         Object is stored in sysprocedures and has no space allocated directly.
 15235                         Views do not have space allocated.
 15236                         Column '%s' has no default.
 15237                         User data type '%s' has no default.
 15238                         Column '%s' has no rule.
 15239                         User data type '%s' has no rule.
 15241                         Usage: sp_dboption [dbname [,optname [,'true' | 'false']]]
 15242                         Database option '%s' is not unique.
 15243                         The option '%s' cannot be changed for the master database.
 15244                         Only members of the sysadmin role or the database owner may set database
                               options.
 15245                         DBCC DBCONTROL error. Database was not placed offline.
 15247                         User does not have permission to perform this action.
 15248                         Error: The parameter @oldname is either ambiguous or the claimed @itemtype
                               (%s) was wrong.
 15249                         Error: Explicit @itemtype '%s' is unrecognized (%d).
 15250                         The database name component of the object qualifier must be the name of the
                               current database.
 15251                         Invalid '%s' specified. It must be %s.
 15252                         The primary or foreign key table name must be given.
 15253                         Syntax error parsing SQL identifier '%s'.
 15254                         Users other than the database owner or guest exist in the database. Drop them
                               before removing the database.



InterSystems Error Reference                                                                                 213
TSQL Error Messages


 Error Code           Description
 15255                '%s' is not a valid value for @autofix. The only valid value is 'auto'.
 15256                Usage: sp_certify_removable <dbname> [,'auto']
 15257                The database that you are attempting to certify cannot be in use at the same time.
 15258                The database must be owned by a member of the sysadmin role before it can be
                      removed.
 15261                Usage: sp_create_removable
                      <dbname>,<syslogical>,<sysphysical>,<syssize>,<loglogical>,<logphysical>,<logsize>,<datalogical1>,<dataphysical1>,<datasize1>
                      [,<datalogical2>,<dataphysical2>,<datasize2>...<datalogical16>,<dataphysical16>,<datasize16>]
 15262                Invalid file size entered. All files must be at least 1 MB.
 15264                Could not create the '%s' portion of the database.
 15266                Cannot make '%s' database removable.
 15269                Logical data device '%s' not created.
 15270                You cannot specify a length for user data types based on sysname.
 15271                Invalid @with_log parameter value. Valid values are 'true' or 'false'.
 15275                FOREIGN KEY constraints do not have space allocated.
 15277                The only valid @parameter_value values are 'true' or 'false'.
 15278                Login '%s' is already mapped to user '%s' in database '%s'.
 15279                You must add the us_english version of this message before you can add the
                      '%s' version.
 15280                All localized versions of this message must be dropped before the us_english
                      version can be dropped.
 15283                The name '%s' contains too many characters.
 15284                The user has granted or revoked privileges to the following in the database and
                      cannot be dropped.
 15285                The special word '%s' cannot be used for a logical device name.
 15286                Terminating this procedure. The @action '%s' is unrecognized. Try 'REPORT',
                      'UPDATE_ONE', or 'AUTO_FIX'.
 15287                Terminating this procedure. '%s' is a forbidden value for the login name parameter
                      in this procedure.
 15289                Terminating this procedure. Cannot have an open transaction when this is run.
 15290                Terminating this procedure. The Action '%s' is incompatible with the other
                      parameter values ('%s', '%s').
 15291                Terminating this procedure. The %s name '%s' is absent or invalid.
 15292                The row for user '%s' will be fixed by updating its login link to a login already in
                      existence.
 15293                Barring a conflict, the row for user '%s' will be fixed by updating its link to a new
                      login. Consider changing the new password from null.




214                                                                                                       InterSystems Error Reference
                                                                                              TSQL Error Messages


 Error Code                    Description
 15294                         The number of orphaned users fixed by adding new logins and then updating
                               users was %d.
 15295                         The number of orphaned users fixed by updating users was %d.
 15298                         New login created.

Table 3–77:TSQL Error Codes - 15300 to 15399

 Error Code                    Description
 15300                         No recognized letter is contained in the parameter value for General Permission
                               Type (%s). Valid letters are in this set: %s .
 15301                         Collation '%s' is supported for Unicode data types only and cannot be set at either
                               the database or server level.
 15302                         Database_Name should not be used to qualify owner.object for the parameter
                               into this procedure.
 15303                         The "user options" config value (%d) was rejected because it would set
                               incompatible options.
 15304                         The severity level of the '%s' version of this message must be the same as the
                               severity level (%ld) of the us_english version.
 15305                         The @TriggerType parameter value must be 'insert', 'update', or 'delete'.
 15306                         Cannot change the compatibility level of replicated or distributed databases.
 15307                         Could not change the merge publish option because the server is not set up for
                               replication.
 15308                         You must set database '%s' to single user mode with sp_dboption before fixing
                               indexes on system tables.
 15311                         The file named '%s' does not exist.
 15312                         The file named '%s' is a primary file and cannot be removed.
 15318                         All fragments for database '%s' on device '%s' are now dedicated for log usage
                               only.
 15319                         Error: DBCC DBREPAIR REMAP failed for database '%s' (device '%s').
 15321                         There was some problem removing '%s' from sysaltfiles.
 15322                         File '%s' was removed from tempdb, and will take effect upon server restart.
 15323                         The selected index does not exist on table '%s'.
 15324                         The option %s cannot be changed for the '%s' database.
 15325                         The current database does not contain a %s named '%ls'.
 15326                         No extended stored procedures exist.
 15327                         The database is now offline.
 15328                         The database is offline already.
 15330                         There are no matching rows on which to report.




InterSystems Error Reference                                                                                   215
TSQL Error Messages


 Error Code                Description
 15331                     The user '%s' cannot take the action auto_fix due to duplicate SID.
 15333                     Error: The qualified @oldname references a database (%s) other than the current
                           database.
 15335                     Error: The @newname value '%s' is already in use as a %s name and would
                           cause a duplicate that is not permitted.
 15336                     Object '%s' cannot be renamed because the object participates in enforced
                           dependencies.
 15337                     Caution: sysdepends shows that other objects (views, procedures and so on) are
                           referencing this object by its old name. These objects will become invalid, and
                           should be dropped and re-created promptly.
 15338                     The %s was renamed to '%s'.
 15339                     Creating '%s'.
 15340                     Alias user added.
 15341                     Granted database access to '%s'.
 15354                     Usage: sp_detach_db <dbname>, [TRUE|FALSE]
 15358                     User-defined filegroups should be made read-only.
 15363                     The role '%s' already exists in the current database.
 15379                     The server option value '%s' supplied is unrecognized.
 15387                     If the qualified object name specifies a database, that database must be the
                           current database.
 15388                     There is no user table matching the input name '%s' in the current database.
 15390                     Input name '%s' does not have a matching user table or indexed view in the
                           current database.
 15394                     Collation '%s' is not supported by the operating system
 15395                     The qualified old name could not be found for item type '%s'.
 15398                     Only objects in the master database owned by dbo can have the startup setting
                           changed.
 15399                     Could not change startup option because this option is restricted to objects that
                           have no parameters.

Table 3–78:TSQL Error Codes - 15400 to 15499

 Error Code                Description
 15401                     Windows NT user or group '%s' not found. Check the name again.
 15402                     '%s' is not a fixed server role.
 15405                     Cannot use the reserved user or role name '%s'.
 15407                     '%s' is not a valid Windows NT name. Give the complete name:
                           <domain\username>.
 15409                     '%s' is not a role.



216                                                                                InterSystems Error Reference
                                                                                               TSQL Error Messages


 Error Code                    Description
 15410                         User or role '%s' does not exist in this database.
 15412                         '%s' is not a known fixed role.
 15413                         Cannot make a role a member of itself.
 15414                         Cannot set compatibility level because database has a view or computed column
                               that is indexed. These indexes require a SQL Server compatible database.
 15415                         User is a member of more than one group. sp_changegroup is set up for backward
                               compatibility and expects membership in one group at most.
 15416                         Usage: sp_dbcmptlevel [dbname [, compatibilitylevel]]
 15417                         Cannot change the compatibility level of the '%s' database.
 15418                         Only members of the sysadmin role or the database owner may set the database
                               compatibility level.
 15419                         Supplied parameter @sid should be binary(16).
 15420                         The group '%s' does not exist in this database.
 15421                         The user owns role(s) in the database and cannot be dropped.
 15422                         Application roles can only be activated at the ad hoc level.
 15423                         The password for application role '%s' has been changed.
 15424                         New role added.
 15425                         New application role added.
 15426                         You must specify a provider name with this set of properties.
 15427                         You must specify a provider name for unknown product '%ls'.
 15428                         You cannot specify a provider or any properties for product '%ls'.
 15429                         '%ls' is an invalid product name.
 15430                         Limit exceeded for number of servers.
 15431                         You must specify the @rolename parameter.
 15432                         Stored procedure '%s' can only be executed at the ad hoc level.
 15433                         Supplied parameter @sid is in use.
 15434                         Could not drop login '%s' as the user is currently logged in.
 15435                         Database successfully published.
 15436                         Database successfully enabled for subscriptions.
 15437                         Database successfully published using merge replication.
 15438                         Database is already online.
 15439                         Database is now online.
 15440                         Database is no longer published.
 15441                         Database is no longer enabled for subscriptions.
 15442                         Database is no longer enabled for merge publications.



InterSystems Error Reference                                                                                  217
TSQL Error Messages


 Error Code           Description
 15443                Checkpointing database that was changed.
 15444                'Disk' device added.
 15445                'Diskette' device added.
 15446                'Tape' device added.
 15447                'Pipe' device added.
 15449                Type added.
 15450                New language inserted.
 15452                No alternate languages are available.
 15453                us_english is always available, even though it is not in syslanguages.
 15454                Language deleted.
 15456                Valid configuration options are:
 15457                Configuration option '%ls' changed from %ld to %ld. Run the RECONFIGURE
                      statement to install.
 15458                Database removed.
 15459                In the current database, the specified object references the following:
 15460                In the current database, the specified object is referenced by the following:
 15461                Object does not reference any object, and no objects reference it.
 15462                File '%s' closed.
 15463                Device dropped.
 15467                Type has been dropped.
 15469                No constraints have been defined for this object.
 15470                No foreign keys reference this table.
 15471                The object comments have been encrypted.
 15472                The object does not have any indexes.
 15473                Settable remote login options.
 15475                The database is renamed and in single user mode.
 15476                A member of the sysadmin role must reset the database to multiuser mode with
                      sp_dboption.
 15477                Caution: Changing any part of an object name could break scripts and stored
                      procedures.
 15478                Password changed.
 15479                Login dropped.
 15480                Could not grant login access to '%s'.
 15481                Granted login access to '%s'.
 15482                Could not deny login access to '%s'.



218                                                                          InterSystems Error Reference
                                                                                           TSQL Error Messages


 Error Code                    Description
 15483                         Denied login access to '%s'.
 15484                         Could not revoke login access from '%s'.
 15485                         Revoked login access from '%s'.
 15486                         Default database changed.
 15487                         %s's default language is changed to %s.
 15488                         '%s' added to role '%s'.
 15489                         '%s' dropped from role '%s'.
 15490                         The dependent aliases were also dropped.
 15491                         User has been dropped from current database.
 15492                         Alias user dropped.
 15493                         Role dropped.
 15494                         The application role '%s' is now active.
 15495                         Application role dropped.
 15496                         Group changed.
 15497                         Could not add login using sp_addlogin (user = %s). Terminating this procedure.
 15498                         Inside txn_1a_, update failed. Will roll back (1a1).
 15499                         The dependent aliases were mapped to the new database owner.

Table 3–79:TSQL Error Codes - 15500 to 15599

 Error Code                    Description
 15500                         The dependent aliases were dropped.
 15501                         Database owner changed.
 15502                         Setting database owner to SA.
 15503                         Giving ownership of all objects to the database owner.
 15504                         Deleting users except guest and the database owner from sysusers.
 15505                         Cannot change owner of object '%ls' or one of its child objects because the new
                               owner '%ls' already has an object with the same name.
 15511                         Default bound to column.
 15512                         Default bound to data type.
 15513                         The new default has been bound to columns(s) of the specified user data type.
 15514                         Rule bound to table column.
 15515                         Rule bound to data type.
 15516                         The new rule has been bound to column(s) of the specified user data type.
 15519                         Default unbound from table column.
 15520                         Default unbound from data type.



InterSystems Error Reference                                                                                219
TSQL Error Messages


 Error Code           Description
 15521                Columns of the specified user data type had their defaults unbound.
 15522                Rule unbound from table column.
 15523                Rule unbound from data type.
 15524                Columns of the specified user data type had their rules unbound.
 15525                sp_checknames is used to search for non 7-bit ASCII characters.
 15526                in several important columns of system tables. The following
 15527                columns are searched:
 15528                In master:
 15536                In all databases:
 15543                Looking for non 7-bit ASCII characters in the system tables of database '%s'.
 15544                Table.column '%s'
 15545                The following database names contain non 7-bit ASCII characters.
 15546                If you wish to change these names, use '%s'.
 15547                The following logins have default database names that contain
 15548                non 7-bit ASCII characters. If you wish to change these names use
 15549                sp_defaultdb.
 15550                The following servers have 'initialization file' names that contain
 15551                non 7-bit ASCII characters. If you wish to change these names,
 15552                use UPDATE.
 15553                Database '%s' has no object, user, and so on
 15554                names that contain non 7-bit ASCII characters.
 15555                The database name provided '%s' must be the current database when executing
                      this stored procedure.
 15564                The following device names contain non 7-bit ASCII characters.
 15565                The following login names contain non 7-bit ASCII characters.
 15566                The following remote login names contain non 7-bit ASCII characters.
 15567                The following server names contain non 7-bit ASCII characters.
 15568                The following column and parameter names contain non 7-bit ASCII characters.
 15569                The following index names contain non 7-bit ASCII characters.
 15570                The following object names contain non 7-bit ASCII characters.
 15571                The following segment names contain non 7-bit ASCII characters.
 15572                The following data type names contain non 7-bit ASCII characters.
 15573                The following user or role names contain non 7-bit ASCII characters.
 15574                This object does not have any statistics.



220                                                                            InterSystems Error Reference
                                                                                               TSQL Error Messages


 Error Code                    Description
 15575                         This object does not have any statistics or indexes.
 15576                         You cannot set network name on server '%ls' because it is not a linked SQL
                               Server.
 15577                         Warning: A linked server that refers to the originating server is not a supported
                               scenario. If you wish to use a four-part name to reference a local table, please
                               use the actual server name rather than an alias.

Table 3–80:TSQL Error Codes - 15600 to 15699

 Error Code                    Description
 15600                         An invalid parameter or option was specified for procedure '%s'.
 15601                         Full-Text Search is not enabled for the current database. Use sp_fulltext_database
                               to enable Full-Text Search.
 15604                         Cannot drop full-text catalog '%ls' because it contains a full-text index.
 15605                         A full-text index for table '%ls' has already been created.
 15606                         You must first create a full-text index on table '%ls'.
 15607                         '%ls' is not a valid index to enforce a full-text search key. You must specify a
                               unique, non-nullable, single-column index.
 15608                         Full-text search has already been activated for table '%ls'.
 15609                         Cannot activate full-text search for table '%ls' because no columns have been
                               enabled for full-text search.
 15610                         You must deactivate full-text search on table '%ls' before adding columns to or
                               removing columns from the full-text index.
 15611                         Column '%ls' of table '%ls' cannot be used for full-text search because it is not a
                               character-based column.
 15612                         DBCC DBCONTROL error. Database was not made read-only.
 15613                         The database is now read-only.
 15614                         The database already is read-only.
 15615                         DBCC DBCONTROL error. Database was not made single user.
 15616                         The database is now single user.
 15617                         The database already is single user.
 15618                         The database is now read/write.
 15619                         The database already is read/write.
 15620                         The database is now multiuser.
 15621                         The database already is multiuser.
 15622                         No permission to access database '%s'.
 15623                         Enabling %ls option for database '%ls'.
 15624                         Disabling %ls option for database '%ls'.



InterSystems Error Reference                                                                                      221
TSQL Error Messages


 Error Code                Description
 15625                     Option '%ls' not recognized for '%ls' parameter.
 15626                     You attempted to acquire a transactional application lock without an active
                           transaction.
 15627                     sp_dboption command failed.
 15630                     Full-text search must be activated on table '%ls' before this operation can be
                           performed.
 15631                     Full-text change tracking is currently enabled for table '%ls'.
 15632                     Full-text change tracking must be started on table '%ls' before full-text auto
                           propagation can begin.
 15633                     Full-text auto propagation is currently enabled for table '%ls'.
 15634                     Full-text change tracking must be started on table '%ls' before the changes can
                           be flushed.
 15635                     Cannot execute '%ls' because the database is in read-only access mode.
 15636                     Full-text catalog '%ls' cannot be populated because the database is in single-user
                           access mode.
 15637                     Full-text index for table '%ls' cannot be populated because the database is in
                           single-user access mode.
 15638                     Warning: Full-text index for table '%ls' cannot be populated because the database
                           is in single-user access mode. Change tracking is stopped for this table. Use
                           sp_fulltext_table to start change tracking.
 15639                     Warning: Table '%s' does not have the option 'text in row' enabled and has full-text
                           indexed columns that are of type image, text, or ntext. Full-text change tracking
                           cannot track WRITETEXT or UPDATETEXT operations performed on these
                           columns.
 15640                     sp_fulltext_table 'start_full' must be executed on table '%ls'. Columns affecting
                           the index have been added or dropped since the last index full population.
 15642                     The ongoing population is necessary to ensure an up-to-date index. If needed,
                           stop change tracking, and then deactivate the full-text index population.
 15643                     Warning: This operation did not succeed on one or more tables. A table may be
                           inactive, or a full-text index population may already be active.
 15644                     Full-text index population failed to start on this table. Execute sp_fulltext_table
                           '%ls', '%ls' to update the index.
 15645                     Column '%ls' does not exist.
 15646                     Column '%ls' is not a computed column.
 15647                     No views with schema binding reference this table.

Table 3–81:TSQL Error Codes - 16800 to 16899

 Error Code                Description
 16801                     sp_dropwebtask requires at least one defined parameter @outputfile or
                           @procname.



222                                                                                 InterSystems Error Reference
                                                                                            TSQL Error Messages


 Error Code                    Description
 16802                         sp_dropwebtask cannot find the specified task.
 16803                         sp_runwebtask requires at least one defined parameter @outputfile or
                               @procname.
 16804                         SQL Web Assistant: Could not establish a local connection to SQL Server.
 16805                         SQL Web Assistant: Could not execute the SQL statement.
 16806                         SQL Web Assistant: Could not bind the parameter to the SQL statement.
 16807                         SQL Web Assistant: Could not obtain a bind token.
 16808                         SQL Web Assistant: Could not find the existing trigger. This could be due to
                               encryption.
 16809                         SQL Web Assistant failed on the call to SQLGetData.
 16810                         SQL Web Assistant failed on the call to SQLFetch.
 16811                         SQL Web Assistant failed to bind a results column.
 16812                         SQL Web Assistant: The @query parameter must be specified.
 16813                         SQL Web Assistant: Parameters can be passed either by name or position.
 16814                         SQL Web Assistant: Invalid parameter.
 16815                         SQL Web Assistant: @procname is not valid.
 16816                         SQL Web Assistant: @outputfile is not valid.
 16817                         SQL Web Assistant: Could not read the given file.
 16820                         SQL Web Assistant failed because the state of the Web task in msdb..MSwebtasks
                               is invalid.
 16821                         SQL Web Assistant: Could not open the output file.
 16822                         SQL Web Assistant: Could not open the template file.
 16823                         SQL Web Assistant: Could not allocate enough memory to satisfy this request.
 16824                         SQL Web Assistant: The template file specified in the Web task has a bad size.
 16825                         SQL Web Assistant: Could not read the template file.
 16826                         SQL Web Assistant: Could not find the specified marker for data insertion in the
                               template file.
 16827                         SQL Web Assistant: Could not write to the output file.
 16828                         SQL Web Assistant: @tabborder must be tinyint.
 16829                         SQL Web Assistant: @singlerow must be 0 or 1. Cannot specify this parameter
                               with @nrowsperpage.
 16830                         SQL Web Assistant: The @blobfmt parameter specification is invalid.
 16831                         SQL Web Assistant: The output file name is mandatory for every column specified
                               in the @blobfmt parameter.
 16832                         SQL Web Assistant: Procedure called with too many parameters.




InterSystems Error Reference                                                                                  223
TSQL Error Messages


 Error Code           Description
 16833                SQL Web Assistant: @nrowsperpage must be a positive number and it cannot
                      be used with @singlerow.
 16834                SQL Web Assistant: Read/write operation on text, ntext, or image column failed.
 16838                SQL Web Assistant: Could not find the table in the HTML file.
 16839                SQL Web Assistant: Could not find the matching end table tag in the HTML file.
 16841                SQL Web Assistant: The @datachg parameter cannot be specified with the given
                      @whentype value.
 16842                SQL Web Assistant: Could not find and drop the necessary trigger for updating
                      the Web page.
 16843                SQL Web Assistant: Could not add the necessary trigger for the @datachg
                      parameter. There could be an existing trigger on the table with missing or
                      encrypted text.
 16844                SQL Web Assistant: Incorrect syntax for the @datachg parameter.
 16845                SQL Web Assistant: @datachg must be specified for the given @whentype option.
 16846                SQL Web Assistant: @unittype and/or @numunits must be specified for the given
                      @whentype option.
 16847                SQL Web Assistant: @fixedfont must be 0 or 1.
 16848                SQL Web Assistant: @bold must be 0 or 1.
 16849                SQL Web Assistant: @italic must be 0 or 1.
 16850                SQL Web Assistant: @colheaders must be 0 or 1.
 16851                SQL Web Assistant: @lastupdated must be 0 or 1.
 16852                SQL Web Assistant: @HTMLheader must be in the range 1 to 6.
 16853                SQL Web Assistant: @username is not valid.
 16854                SQL Web Assistant: @dbname is not valid.
 16855                SQL Web Assistant: @whentype must be in the range 1 to 9.
 16856                SQL Web Assistant: @unittype must be in the range 1 to 4.
 16857                SQL Web Assistant: @targetdate is invalid. It must be a valid date after
                      1900-01-01.
 16858                SQL Web Assistant: The @targettime parameter must be between 0 and 240000.
 16859                SQL Web Assistant: @dayflags must be 1, 2, 4, 8, 16, 32, or 64.
 16860                SQL Web Assistant: @numunits must be greater than 0.
 16861                SQL Web Assistant: @targetdate must be specified for the given @whentype
                      option.
 16862                SQL Web Assistant: @dayflags must be specified for the given @whentype option.
 16863                SQL Web Assistant: URL specification is invalid.
 16864                SQL Web Assistant: @blobfmt is invalid. The file must include the full path to the
                      output_file location.



224                                                                          InterSystems Error Reference
                                                                                             TSQL Error Messages


 Error Code                    Description
 16865                         SQL Web Assistant: URL hyperlink text column must not be of the image data
                               type.
 16866                         SQL Web Assistant: Could not obtain the number of columns in @query.
 16867                         SQL Web Assistant: URL hyperlink text column is missing in @query.
 16868                         SQL Web Assistant failed on the call to SQLColAttribute.
 16869                         SQL Web Assistant: Columns of data type image cannot have a template.
 16870                         SQL Web Assistant: Internal error. Could not read @ parameters.
 16871                         SQL Web Assistant: Invalid @charset. Execute sp_enumcodepages for a list of
                               character sets.
 16873                         SQL Web Assistant: Invalid @codepage. Execute sp_enumcodepages for a list
                               of code pages.
 16874                         SQL Web Assistant: Internal error. Cannot translate to the specified code page.
 16875                         SQL Web Assistant: Translation to the desired code page is unavailable on this
                               system.
 16876                         SQL Web Assistant: Internal error. Could not obtain COM interface ID.
 16877                         SQL Web Assistant: Internal error. Could not obtain COM language ID.
 16878                         SQL Web Assistant: Internal error. Could not initialize COM library.
 16879                         SQL Web Assistant: Internal error. Could not translate from Unicode to the
                               specified code page.
 16880                         SQL Web Assistant: Internal error. Could not create translation object. Make sure
                               that the file MLang.dll is in your system directory.
 16881                         SQL Web Assistant: This version is not supported on Win32s of Windows 3.1.
 16882                         SQL Web Assistant: Web task not found. Verify the name of the task for possible
                               errors.
 16883                         SQL Web Assistant: Could not list Web task parameters. xp_readwebtask requires
                               @procname.
 16884                         SQL Web Assistant: Procedure name is required to convert Web tasks.
 16885                         SQL Web Assistant: Could not upgrade the Web task to 7.0. The Web task will
                               remain in 6.5 format and will need to be re-created.
 16886                         SQL Web Assistant: Could not update Web tasks system table. The Web task
                               remains in 6.5 format.
 16887                         SQL Web Assistant: @procname parameter is missing.The parameter is required
                               to upgrade a Web task to 7.0.
 16888                         SQL Web Assistant: Source code page is not supported on the system. Ensure
                               @charset and @codepage language files are installed on your system.
 16889                         SQL Web Assistant: Could not send Web task row to the client.
 16890                         SQL Web Assistant: ODS error occurred. Could not send Web task parameters.




InterSystems Error Reference                                                                                  225
TSQL Error Messages


Table 3–82:TSQL Error Codes - 16900 to 16999

 Error Code                Description
 16901                     %hs: This feature has not been implemented yet.
 16902                     %hs: The value of parameter %hs is invalid.
 16903                     %hs procedure called with incorrect number of parameters.
 16904                     sp_cursor: optype:You can only specify ABSOLUTE in conjunction with DELETE
                           or UPDATE.
 16905                     The cursor is already open.
 16907                     %hs is not allowed in cursor statements.
 16909                     %hs: The cursor identifier value provided (%x) is not valid.
 16911                     %hs: The fetch type %hs cannot be used with forward only cursors.
 16914                     %hs procedure called with too many parameters.
 16915                     A cursor with the name '%.*ls' already exists.
 16916                     A cursor with the name '%.*ls' does not exist.
 16917                     Cursor is not open.
 16922                     Cursor Fetch: Implicit conversion from data type %s to %s is not allowed.
 16924                     Cursorfetch: The number of variables declared in the INTO list must match that
                           of selected columns.
 16925                     The fetch type %hs cannot be used with dynamic cursors.
 16926                     sp_cursoroption: The column ID (%d) does not correspond to a text, ntext, or
                           image column.
 16927                     Cannot fetch into text, ntext, and image variables.
 16929                     The cursor is READ ONLY.
 16930                     The requested row is not in the fetch buffer.
 16931                     There are no rows in the current fetch buffer.
 16932                     The cursor has a FOR UPDATE list and the requested column to be updated is
                           not in this list.
 16933                     The cursor does not include the table being modified or the table is not updatable
                           through the cursor.
 16934                     Optimistic concurrency check failed. The row was modified outside of this cursor.
 16935                     No parameter values were specified for the sp_cursor-%hs statement.
 16936                     sp_cursor: One or more values parameters were invalid.
 16937                     A server cursor is not allowed on a remote stored procedure or stored procedure
                           with more than one SELECT statement. Use a default result set or client cursor.
 16938                     sp_cursoropen/sp_cursorprepare: The statement parameter can only be a single
                           select or a single stored procedure.




226                                                                               InterSystems Error Reference
                                                                                                 TSQL Error Messages


 Error Code                    Description
 16940                         Cannot specify UPDLOCK or TABLOCKX with READ ONLY or INSENSITIVE
                               cursors.
 16941                         Cursor updates are not allowed on tables opened with the NOLOCK option.
 16942                         Could not generate asynchronous keyset. The cursor has been deallocated.
 16943                         Could not complete cursor operation because the table schema changed after
                               the cursor was declared.
 16944                         Cannot specify UPDLOCK or TABLOCKX on a read-only table in a cursor.
 16945                         The cursor was not declared.
 16946                         Could not open the cursor because one or more of its tables have gone out of
                               scope.
 16947                         No rows were updated or deleted.
 16948                         The variable '%.*ls' is not a cursor variable, but it is used in a place where a cursor
                               variable is expected.
 16949                         The variable '%.*ls' is a cursor variable, but it is used in a place where a cursor
                               variable is not valid.
 16950                         The variable '%.*ls' does not currently have a cursor allocated to it.
 16951                         The variable '%.*ls' cannot be used as a parameter because a CURSOR OUTPUT
                               parameter must not have a cursor allocated to it before execution of the procedure.
 16952                         A cursor variable cannot be used as a parameter to a remote procedure call.
 16953                         Remote tables are not updatable. Updatable keyset-driven cursors on remote
                               tables require a transaction with the REPEATABLE_READ or SERIALIZABLE
                               isolation level spanning the cursor.
 16954                         Executing SQL directly; no cursor.
 16955                         Could not create an acceptable cursor.
 16956                         Cursor created was not of the requested type.
 16957                         FOR UPDATE cannot be specified on a READ ONLY cursor.
 16958                         Could not complete cursor operation because the set options have changed since
                               the cursor was declared.
 16959                         Unique table computation failed.
 16960                         You have reached the maximum number of cursors allowed.
 16961                         One or more FOR UPDATE columns have been adjusted to the first instance of
                               their table in the query.
 16962                         The target object type is not updatable through a cursor.
 16963                         You cannot specify scroll locking on a cursor that contains a remote table.
 16996                         %hs cannot take output parameters.
 16998                         Internal Cursor Error: A cursor work table operation failed.
 16999                         Internal Cursor Error: The cursor is in an invalid state.



InterSystems Error Reference                                                                                       227
TSQL Error Messages


Table 3–83:TSQL Error Codes - 17000 to 17099

 Error Code                Description
 17000                     Usage: sp_autostats <table_name> [, {ON|OFF} [, <index_name>] ]
 17050                     The '%ls' option is ignored in this edition of SQL Server.
 17052                     %1
 17053                     %1: Operating system error %2 encountered.
 17054                     LogEvent: Failed to report the current event. Operating system error = %1.
 17055                     %1 :%n%2
 17059                     Operating system error %1!d!: %2!hs!.
 17065                     SQL Server Assertion: File: <%1>, line = %2!d! %nFailed Assertion = '%3' %4.
 17066                     SQL Server Assertion: File: <%1>, line=%2!d! %nFailed Assertion = '%3'.
 17067                     SQL Server Assertion: File: <%1>, line = %2!d! %n%3.
 17068                     PrintStack Request


Table 3–84:TSQL Error Codes - 17100 to 17199

 Error Code                Description
 17104                     Server Process ID is %1!ld!.
 17112                     Invalid command option %1!c!.
 17113                     initconfig: Error %2 opening '%1' for configuration information.
 17114                     initconfig: Error %2 reading configuration information from '%1'.
 17117                     initconfig: Number of user connections reduced to %1!ld!.
 17118                     upinit: Warning: Could not raise priority of %1 thread.
 17119                     initconfig: Number of server processes reduced to %1!ld!.
 17120                     SQL Server could not spawn %1 thread.
 17122                     initdata: Warning: Could not set working set size to %1!d! KB.
 17124                     SQL Server configured for %1 mode processing.
 17125                     Using %1 lock allocation. [%2!d!] Lock Blocks, [%3!d!] Lock Owner Blocks.
 17126                     SQL Server is ready for client connections
 17127                     initdata: No memory for kernel buffer hash table.
 17128                     initdata: No memory for kernel buffers.
 17130                     initdata: No memory for kernel locks.
 17131                     initdata: Not enough memory for descriptor hash tables.
 17132                     initdata: Not enough memory for descriptors.
 17134                     initmaster: Could not allocate process status structure (PSS).
 17138                     Could not allocate enough memory to initialize '%1'.



228                                                                                  InterSystems Error Reference
                                                                                              TSQL Error Messages


 Error Code                    Description
 17140                         Could not dispatch SQL Server by Service Control Manager. Operating system
                               error = %1.
 17141                         Could not register Service Control Handler. Operating system error = %1.
 17142                         SQL Server has been paused. No new connections will be allowed.
 17143                         %1: Could not set Service Control Status. Operating system error = %2.
 17144                         SQL Server is disallowing new connections due to 'pause' request from Service
                               Control Manager.
 17145                         Service Control Handler received an invalid control code = %1!d!.
 17146                         SQL Server is allowing new connections due to 'continue' request from Service
                               Control Manager.
 17147                         SQL Server terminating because of system shutdown.
 17148                         SQL Server is terminating due to 'stop' request from Service Control Manager.
 17151                         Maximum number of pages in batch I/O is limited to %1!ld!.
 17154                         initdata: Not enough memory for procedure cache/hash table.
 17156                         initeventlog: Could not initiate the EventLog Service for the key '%1'.
 17157                         %1: Could not initialize Communication Layer.
 17160                         Could not use SQLEVN70.DLL version '%1'. SQLEVN70.DLL version '%2' was
                               expected.
 17161                         Master device sector size is %1!d!. SQL Server cannot use the NO_BUFFERING
                               option during I/O.
 17162                         SQL Server is starting at priority class '%1'(%2!d! %3 detected).
 17168                         SQL Server shut down because configured codepage %1!d! is not supported by
                               the

Table 3–85:TSQL Error Codes - 17200 to 17299

 Error Code                    Description
 17204                         %1: Could not open device %2 for virtual device number (VDN) %3!d!.
 17207                         %1: Operating system error %3 during the creation/opening of physical device
                               %2.
 17208                         %1: File '%2' has an incorrect size (%3!d! MB, should be %4!d! MB).
 17218                         %1: Operating system error %2 on device '%3' (virtual page %4).
 17249                         %1: Negative outstanding I/O count in process ID = %2!d!.
 17252                         %1: Actual bytes transferred (%2!d!) does not match requested amount (%3!d!)
                               on device '%4' (virtual page %5).
 17253                         The sector size for device %1 is %2!d!. SQL Server cannot use the
                               NO_BUFFERING option during I/O on this device.
 17254                         Warning: Cannot use NO_BUFFERING option on '%1'. Operating system error
                               %2.



InterSystems Error Reference                                                                                 229
TSQL Error Messages


Table 3–86:TSQL Error Codes - 17300 to 17399

 Error Code                Description
 17300                     Not enough memory for process status structure (PSS) allocation.
 17302                     The maximum limit for connections has been reached.
 17303                     freepss: Bad process status structure (PSS) value.
 17304                     Warning: Clean_process system function called from another thread. Outstanding
                           I/O may not complete.
 17308                     %1: Process %2!d! generated an access violation. SQL Server is terminating this
                           process.
 17309                     The current contents of process' input buffer are '%1'.
 17310                     %1: Process %2!d! generated fatal exception %3!lx! %4. SQL Server is terminating
                           this process.
 17311                     SQL Server is aborting. Fatal exception %1!lx! caught.


Table 3–87:TSQL Error Codes - 17400 to 17499

 Error Code                Description
 17402                     Database '%1' set to single user mode.
 17422                     closetable: Called with null session descriptor (SDES), server process ID (SPID)
                           %1!d!.
 17423                     closetable: Table already closed for session descriptor (SDES) %1!08lx!.
 17424                     Warning: OPEN OBJECTS parameter may be too low.
 17426                     Run sp_configure to increase the parameter value.
 17429                     The srchindex system function failed for index ID = %1!d!, sridoff = %2!d!.
 17430                     Database '%1' set to read only mode.




230                                                                                  InterSystems Error Reference
                                                                                               TSQL Error Messages


Table 3–88:TSQL Error Codes - 17500 to 17599

 Error Code                    Description
 17550                         DBCC TRACEON %d, server process ID (SPID) %d.
 17551                         DBCC TRACEOFF %d, server process ID (SPID) %d.
 17557                         DBCC DBRECOVER failed for database ID %d.
 17558                         *** Bypassing recovery for database ID %d.
 17560                         DBCC DBREPAIR: '%ls' index restored for '%ls.%ls'.
 17561                         %ls index restored for %ls.%ls.
 17569                         DBCC cannot find the library initialization function %ls.
 17570                         DBCC cannot find the function %ls in the library %ls.
 17571                         DBCC function %ls in the library %ls generated an access violation. SQL Server
                               is terminating process %d.
 17572                         DBCC cannot free DLL %ls. SQL Server depends on this DLL to function properly.


Table 3–89:TSQL Error Codes - 17600 to 17699

 Error Code                    Description
 17654                         Warning: Process status structure (PSS) found with open session descriptor
                               (SDES). PSPID %1!d!, PSUID %2!d!, PCURDB %3!d!, range entry %4!d!, SDESP
                               0x%5!lx!, object ID %6!ld!.
 17657                         Attempting to change default collation to %1.
 17658                         SQL Server started in single user mode. Updates allowed to system catalogs.
 17660                         Starting without recovery.
 17661                         Recovering all databases but not clearing tempdb.
 17669                         Table still open. Database ID %1!d!, table ID %2!ld!.
 17674                         Login: %1 %2, server process ID (SPID): %3!d!, kernel process ID (KPID): %4!d!.
 17676                         SQL Server shutdown due to Ctrl-C or Ctrl-Break signal.


Table 3–90:TSQL Error Codes - 17700 to 17799

 Error Code                    Description
 17750                         Cannot load the DLL %ls, or one of the DLLs it references. Reason: %ls.
 17751                         Cannot find the function %ls in the library %ls. Reason: %ls.
 17752                         Extended procedure memory allocation failed for '%ls'.
 17753                         %.*ls can only be executed in the master database.




InterSystems Error Reference                                                                                  231
TSQL Error Messages


Table 3–91:TSQL Error Codes - 17800 to 17899

 Error Code                Description
 17801                     Unknown internal error value.
 17803                     Insufficient memory available.
 17804                     Invalid 'nbytes' value.
 17805                     Invalid buffer received from client.
 17807                     Invalid event '%1!ld!'.
 17808                     Invalid starting position specified.
 17809                     Could not connect. The maximum number of '%1!ld!' configured user connections
                           are already connected. The system administrator can change the maximum to a
                           higher value using sp_configure.
 17814                     Invalid function parameter.
 17815                     No longer waiting for client connections using Net-Library'%1!hs!'.
 17820                     Invalid data type parameter.
 17822                     Could not load Net-Library '%1!hs!'.
 17824                     Could not write to Net-Library '%1!hs!', loginname '%2!ls!', hostname '%3!ls!'.
                           Connection closed.
 17825                     Could not close Net-Library '%1!hs!'.
 17826                     Could not set up Net-Library '%1!hs!'.
 17831                     Could not load Net-Library '%1!hs!' version '%2!hs!'. Need Net-Library version
                           '%3!hs!' or greater.
 17832                     Connection opened but invalid login packet(s) sent. Connection closed.
 17833                     Net-Library %1!hs!' is already in use.
 17834                     Using '%1!hs!' version '%2!hs!'.
 17837                     char data type%0
 17838                     variable-length char data type%0
 17839                     binary data type%0
 17840                     variable-length binary data type%0
 17841                     1-byte integer data type%0
 17842                     2-byte integer data type%0
 17843                     4-byte integer data type%0
 17844                     bit data type%0
 17845                     datetime data type%0
 17846                     datetime data type, nulls allowed%0
 17847                     money data type%0
 17848                     money data type, nulls allowed%0



232                                                                               InterSystems Error Reference
                                                                                              TSQL Error Messages


 Error Code                    Description
 17849                         4-byte float data type, nulls allowed%0
 17850                         8-byte float data type%0
 17851                         8-byte float data type, nulls allowed%0
 17852                         4-byte datetime data type, nulls allowed%0
 17853                         4-byte money data type%0
 17854                         event type%0
 17855                         done packet status field%0
 17856                         error severity type%0
 17857                         4-byte integer data type, nulls allowed%0
 17858                         image data type%0
 17859                         text data type%0
 17868                         numeric data type%0
 17869                         numeric data type, nulls allowed%0
 17870                         decimal data type%0
 17871                         decimal data type, nulls allowed%0
 17872                         bit data type, nulls allowed%0
 17873                         8000-byte variable-length binary data type%0
 17874                         8000-byte variable-length character data type%0
 17875                         8000-byte binary data type%0
 17876                         8000-byte character data type%0
 17877                         8000-byte Unicode character data type%0
 17878                         8000-byte Unicode variable-length character data type%0
 17879                         Unicode text data type%0
 17880                         uniqueidentifier data type%0
 17881                         '%1!ls!' is an unsupported Open Data Services API.
 17882                         Error accepting connection request via Net-Library '%1!hs!'. Execution continuing.

Table 3–92:TSQL Error Codes - 18000 to 18099

 Error Code                    Description
 18002                         Stored function '%.*ls' in the library '%.*ls' generated an access violation. SQL
                               Server is terminating process %d.
 18052                         Error: %1!d!, Severity: %2!d!, State: %3!d!.
 18053                         Error: %1!d!, Severity: %2!d!, State: %3!d!%n%4%5.




InterSystems Error Reference                                                                                       233
TSQL Error Messages


Table 3–93:TSQL Error Codes - 18100 to 18199

 Error Code                Description
 18100                     Process ID %d killed by hostname %.*ls, host process ID %d.
 18113                     SQL Server shutdown after verifying system indexes.
 18124                     Default collation successfully changed.


Table 3–94:TSQL Error Codes - 18200 to 18299

 Error Code                Description
 18200                     %1: Backup device ID %2!d! out of range.
 18201                     ksconsole: Cannot create ConsBufMutex: %1.
 18203                     ksconsole: Cannot create %1 : %2.
 18204                     %1: Backup device '%2' failed to %3. Operating system error = %4.
 18205                     %1: Could not initialize console operation.
 18207                     %1: Null request packet.
 18208                     %1: Backup device ID %2!d! is not active.
 18209                     ksconsole: Could not send request to console client.
 18210                     %1: %2 failure on backup device '%3'. Operating system error %4.
 18211                     ksconsole: Could not receive request from console client.
 18213                     ksconsole: Console input request for type 0x%1!x!, ID 0x%2!x! failed.
 18214                     %1: Server console thread not running.
 18215                     %1: Response type 0x%2!x!, ID 0x%3!x! not found in request.
 18216                     %1: Could not access console mutex. Operating system error %2.
 18217                     %1: Type 0x%2!x! not implemented.
 18218                     %1: Incorrect number of parameters: %2!d!.
 18219                     ksconsole: Could not close console connection.
 18221                     ksconsole: Reinitializing the console.
 18223                     %1: No console client connected. Start CONSOLE.EXE.
 18225                     Tape '%1' (Family ID: %2, sequence %3) mounted on tape drive '%4'.
 18227                     Unnamed tape (Family ID: %1, sequence %2) mounted on tape drive '%3'.
 18257                     %1: Device or media does not support %2.
 18264                     Database backed up: Database: %1, creation date(time): %2(%3), pages dumped:
                           %4!d!, first LSN: %5, last LSN: %6, number of dump devices: %9!d!, device
                           information: (%10).
 18265                     Log backed up: Database: %1, creation date(time): %2(%3), first LSN: %4, last
                           LSN: %5, number of dump devices: %7!d!, device information: (%8).




234                                                                               InterSystems Error Reference
                                                                                              TSQL Error Messages


 Error Code                    Description
 18266                         Database file backed up: Database: %1, creation date(time): %2(%3), file list:
                               (%4), pages dumped: %5!d!, number of dump devices: %8!d!, device information:
                               (%9).
 18267                         Database restored: Database: %1, creation date(time): %2(%3), first LSN: %4,
                               last LSN: %5, number of dump devices: %7!d!, device information: (%8).
 18268                         Log restored: Database: %1, creation date(time): %2(%3), first LSN: %4, last
                               LSN: %5, number of dump devices: %7!d!, device information: (%8).
 18269                         Database file restored: Database: %1, creation date(time): %2(%3), file list: (%4),
                               number of dump devices: %6!d!, device information: (%7).
 18270                         Database differential changes backed up: Database: %1, creation date(time):
                               %2(%3), pages dumped: %4!d!, first LSN: %5, last LSN: %6, full backup LSN:
                               %7, number of dump devices: %10!d!, device information: (%11).
 18271                         Database changes restored: Database: %1, creation date(time): %2(%3), first
                               LSN: %4, last LSN: %5, number of dump devices: %7!d!, device information:
                               (%8).
 18272                         I/O error on backup or restore restart-checkpoint file '%1'. Operating system error
                               %2. The statement is proceeding but is non-restartable.
 18273                         Could not clear '%1' bitmap in database '%2' due to error %3!d!. A subsequent
                               backup operation may be slower/larger than normal.
 18274                         Tape '%1' (Family ID: %2, sequence %3) dismounted from tape drive '%4'.
 18275                         Unnamed tape (Family ID: %1, sequence %2) dismounted from tape drive '%3'.
 18276                         Database file differential changes backed up: Database: %1, creation date(time):
                               %2(%3), file list: (%4), pages dumped: %5!d!, number of dump devices: %8!d!,
                               device information: (%9).
 18277                         Database file changes restored: Database: %1, creation date(time): %2(%3), file
                               list: (%4), number of dump devices: %6!d!, device information: (%7).
 18278                         Database log truncated: Database: %1.

Table 3–95:TSQL Error Codes - 18400 to 18499

 Error Code                    Description
 18400                         Checkpoint process is terminating due to a fatal exception.
 18450                         Login failed for user '%ls'. Reason: Not defined as a valid user of a trusted SQL
                               Server connection.
 18451                         Login failed for user '%ls'. Only administrators may connect at this time.
 18452                         Login failed for user '%ls'. Reason: Not associated with a trusted SQL Server
                               connection.
 18453                         Login succeeded for user '%ls'. Connection: Trusted.
 18454                         Login succeeded for user '%ls'. Connection: Non-Trusted.
 18455                         Login succeeded for user '%ls'.
 18456                         Login failed for user '%ls'.



InterSystems Error Reference                                                                                   235
TSQL Error Messages


 Error Code                Description
 18457                     Login failed for user '%ls'. Reason: User name contains a mapping character or
                           is longer than 30 characters.
 18458                     Login failed. The maximum simultaneous user count of %d licenses for this server
                           has been exceeded. Additional licenses should be obtained and registered through
                           the Licensing application in the Windows NT Control Panel.
 18459                     Login failed. The maximum workstation licensing limit for SQL Server access has
                           been exceeded.
 18460                     Login failed. The maximum simultaneous user count of %d licenses for this '%ls'
                           server has been exceeded. Additional licenses should be obtained and installed
                           or you should upgrade to a full version.
 18461                     Login failed for user '%ls'. Reason: Server is in single user mode. Only one
                           administrator can connect at this time.
 18482                     Could not connect to server '%ls' because '%ls' is not defined as a remote server.
 18483                     Could not connect to server '%ls' because '%ls' is not defined as a remote login
                           at the server.
 18485                     Could not connect to server '%ls' because it is not configured for remote access.
 18490                     Maximum number of processors supported is '%1!ld!'.
 18491                     Could not start due to invalid serial number.
 18492                     The license agreement has been violated for this '%1' version of SQL Server.
                           Cannot start.

Table 3–96:TSQL Error Codes - 18500 to 18599

 Error Code                Description
 18500                     Could not load startup handler DLL '%1'.
 18501                     Could not load startup handler function '%1'.
 18502                     Could not add startup handler '%1'.


Table 3–97:TSQL Error Codes - 18600 to 18699

 Error Code                Description
 18666                     Could not free up descriptor in rel_desclosed() system function.


Table 3–98:TSQL Error Codes - 18700 to 18799

 Error Code                Description
 18750                     %ls: The parameter '%ls' is invalid.
 18751                     %ls procedure called with incorrect number of parameters.
 18752                     Another log reader is replicating the database.
 18754                     Could not open table %d.
 18755                     Could not allocate memory for replication.



236                                                                               InterSystems Error Reference
                                                                                               TSQL Error Messages


 Error Code                    Description
 18756                         Could not get replication information for table %d.
 18757                         The database is not published.
 18759                         Replication failure. File '%ls', line %d.
 18760                         Invalid %ls statement for article %d.
 18761                         Commit record at (%ls) has already been distributed. Check DBTABLE.
 18762                         Invalid begin LSN (%ls) for commit record (%ls). Check DBTABLE.
 18763                         Commit record (%ls) reports oldest active LSN as (0:0:0).
 18764                         Execution of filter stored procedure %d failed. See the SQL Server errorlog for
                               more information.
 18765                         Begin LSN specified for replication log scan is invalid.
 18766                         The replbeginlsn field in the DBTABLE is invalid.
 18767                         The specified begin LSN (%ls) for replication log scan occurs before replbeginlsn
                               (%ls).
 18768                         The specified LSN (%ls) for repldone log scan occurs before the current start of
                               replication in the log (%ls).
 18769                         The specified LSN (%ls) for repldone log scan is not a replicated commit record.
 18770                         The specified LSN (%ls) for repldone log scan is not present in the transaction
                               log.
 18771                         Invalid storage type %d specified writing variant of type %d.
 18772                         Invalid server data type (%d) specified in repl type lookup.
 18773                         Could not locate text information records for column %d during command
                               construction.
 18774                         The stored procedure sp_replsetoriginator must be executed within a transaction.
 18775                         The Log Reader Agent encountered an unexpected log record of type %u
                               encountered while processing DML operation.
 18776                         An error occurred while waiting on the article cache access event.
 18777                         %s: Error initializing MSMQ components
 18778                         %s: Error opening Microsoft Message Queue %s

Table 3–99:TSQL Error Codes - 18800 to 18899

 Error Code                    Description
 18800                         Warning: Index '%1' on '%2' in database '%3' may be corrupt because of
                               expression evaluation changes in this release. Drop and re-create the index.
 18831                         ;// Database ID %d. Could not find object descriptor for object ID %ld.
 18833                         Database ID %d. Could not find clustered index on system table ID %ld. This
                               index should exist in all databases. Run DBCC CHECKTABLE on sysindexes in
                               the database.




InterSystems Error Reference                                                                                  237
TSQL Error Messages


 Error Code           Description
 18836                Database ID %d. Could not find object ID %ld in sysobjects. This system catalog
                      should exist in all databases. Run DBCC CHECKTABLE on sysobjects in this
                      database.
 18841                Could not locate entry in sysdatabases for database '%.*ls'. No entry found with
                      that name.
 18843                Could not find database ID %d in sysdatabases.
 18872                Rec_finish: getnext SCAN_NOINDEX on sysdatabases.dbid=%d failed.
 18874                Rec_complete: Could not open controlling database (ID %d) of controlling database
                      in multi-database transaction
 18875                Recovering database '%.*s'.
 18876                %d transactions rolled forward in database '%.*ls' (%d).
 18877                %d transactions rolled back in database '%.*ls' (%d).
 18883                ;//Database ID %d: Attempt to mark database SUSPECT. Getnext NC scan on
                      sysobjects.dbid failed.
 18884                ;//Database '%.*s' (ID %d). Recovery failed. Run DBCC.
 18885                Page #%lx from table ID #%ld, database ID #%d, not found in cache.
 18886                Page #%lx from sysindexes in database ID #%X not in cache after reading it into
                      cache.
 18887                Cannot recover the master database. Exiting.
 18892                Extent ID %ld which should belong to syslogs belongs to object ID %ld.
 18894                No more room in the transaction table.
 18895                Transaction (%d, %d) not found in the transaction table.
 18901                Could not build an allocation map for the database '%.*s'. Database does not
                      have a DBINFO structure.




238                                                                           InterSystems Error Reference
                                                                                                  TSQL Error Messages


Table 3–100:TSQL Error Codes - 19000 to 19099

 Error Code                    Description
 19000                         ODBC error encountered, State = %1, native error = %2, error message = %3.
 19001                         Windows NT Error encountered, %1.
 19002                         MS SQL SNMP Extension Agent starting, %1, version %2.
 19003                         MS SQL SNMP Extension Agent reconnecting.
 19004                         MS SQL SNMP Extension Agent stopping.
 19010                         RPC Net-Library listening on: %1.
 19011                         SuperSocket info: %1.
 19012                         SuperSocket Info: Bind failed on TCP port %1.
 19013                         SQL server listening on %1.
 19014                         Invalid Protocol specified for a %1 instance: %2.
 19015                         Encryption requested but no valid certificate was found. SQL Server terminating.


Table 3–101:TSQL Error Codes - 20000 to 20099

 Error Code                    Description
 20001                         There is no nickname for article '%s' in publication '%s'.
 20002                         The filter '%s' already exists for article '%s' in publication '%s'.
 20003                         Could not generate nickname for '%s'.
 20007                         The system tables for merge replication could not be dropped successfully.
 20008                         The system tables for merge replication could not be created successfully.
 20009                         The article '%s' could not be added to the publication '%s'.
 20010                         The Snapshot Agent corresponding to the publication '%s' could not be dropped.
 20011                         Cannot set incompatible publication properties. The 'allow_anonymous' property
                               of a publication depends on the 'immediate_sync' property.
 20012                         The subscription type '%s' is not allowed on publication '%s'.
 20013                         The publication property '%s' cannot be changed when there are subscriptions
                               on it.
 20014                         Invalid @schema_option value.
 20015                         Could not remove directory '%ls'. Check the security context of xp_cmdshell and
                               close other processes that may be accessing the directory.
 20016                         Invalid @subscription_type value. Valid values are 'pull' or 'anonymous'.
 20017                         The subscription on the Subscriber does not exist.
 20018                         The @optional_command_line is too long. Use an agent definition file.
 20019                         Replication database option '%s' cannot be set unless the database is a publishing
                               database or a distribution database.




InterSystems Error Reference                                                                                     239
TSQL Error Messages


 Error Code           Description
 20020                The article resolver supplied is either invalid or nonexistent.
 20021                The subscription could not be found.
 20023                Invalid @subscriber_type value. Valid options are 'local', 'global', 'anonymous',
                      or 'repub'.
 20025                The publication name must be unique. The specified publication name '%s' has
                      already been used.
 20026                The publication '%s' does not exist.
 20027                The article '%s' does not exist.
 20028                The Distributor has not been installed correctly. Could not enable database for
                      publishing.
 20029                The Distributor has not been installed correctly. Could not disable database for
                      publishing.
 20030                The article '%s' already exists on another publication with a different column
                      tracking option.
 20031                Could not delete the row because it does not exist.
 20032                '%s' is not defined as a Subscriber for '%s'.
 20033                Invalid publication type.
 20034                Publication '%s' does not support '%s' subscriptions.
 20036                The Distributor has not been installed correctly.
 20037                The article '%s' already exists in another publication with a different article resolver.
 20038                The article filter could not be added to the article '%s' in the publication '%s'.
 20039                The article filter could not be dropped from the article '%s' in the publication '%s'.
 20040                Could not drop the article(s) from the publication '%s'.
 20041                Transaction rolled back. Could not execute trigger. Retry your transaction.
 20043                Could not change the article '%s' because the publication has already been
                      activated.
 20044                The priority property is invalid for local subscribers.
 20045                You must supply an article name.
 20046                The article does not exist.
 20047                You are not authorized to perform this operation.
 20049                The priority value should not be larger than 100.0.
 20050                The retention period must be greater than or equal to %d.
 20051                The Subscriber is not registered.
 20054                Current database is not enabled for publishing.
 20055                Table '%s' cannot be published for merge replication because it has a timestamp
                      column.



240                                                                               InterSystems Error Reference
                                                                                                 TSQL Error Messages


 Error Code                    Description
 20056                         Table '%s' cannot be republished.
 20057                         The profile name '%s' already exists for the specified agent type.
 20058                         The @agent_type must be 1 (Snapshot), 2 (Logreader), 3 (Distribution), or 4
                               (Merge)
 20059                         The @profile_type must be 0 (System) or 1 (Custom)
 20060                         Compatibility level cannot be smaller than 60.
 20061                         The compatibility level of this database must be set to 70 or higher to be enabled
                               for merge publishing.
 20062                         Updating columns with the rowguidcol property is not allowed.
 20064                         Cannot drop profile. Either it is not defined or it is defined as the default profile.
 20065                         Cannot drop profile because it is in use.
 20066                         Profile not defined.
 20067                         The parameter name '%s' already exists for the specified profile.
 20068                         The article cannot be created on table '%s' because it has more than %d columns.
 20069                         Cannot validate a merge article that uses looping join filters.
 20070                         Cannot update subscription row.
 20072                         Cannot update Subscriber information row.
 20073                         Articles can be added or changed only at the Publisher.
 20074                         Only a table object can be published as a "table" article for merge replication.
 20075                         The 'status' parameter value must be either 'active' or 'unsynced'.
 20076                         The @sync_mode parameter value must be 'native' or 'character'.
 20077                         Problem encountered generating replica nickname.
 20078                         The @property parameter value must be 'sync_type', 'priority', or 'description'.
 20079                         Invalid @subscription_type parameter value. Valid options are 'push', 'pull', or
                               'both'.
 20081                         Publication property '%s' cannot be NULL.
 20084                         Publication '%s' cannot be subscribed to by Subscriber database '%s'.
 20086                         Publication '%s' does not support the nosync type because it contains a table that
                               does not have a rowguidcol column.
 20087                         You cannot push an anonymous subscription.
 20088                         Only assign priorities that are greater than or equal to 0 and less than 100.
 20089                         Could not get license information correctly.
 20090                         Could not get version information correctly.
 20091                         sp_mergesubscription_cleanup is used to clean up push subscriptions. Use
                               sp_dropmergepullsubscription to clean up pull or anonymous subscriptions.




InterSystems Error Reference                                                                                        241
TSQL Error Messages


 Error Code                Description
 20100                     Cannot drop Subscriber '%s'. There are existing subscriptions.

Table 3–102:TSQL Error Codes - 20500 to 20599

 Error Code                Description
 20500                     The updatable Subscriber stored procedure '%s' does not exist in sysobjects.
 20501                     Could not insert into sysarticleupdates using sp_articlecolumn.
 20502                     Invalid '%s' value. Valid values are 'read only', 'sync tran', 'queued tran', or 'failover'.
 20503                     Invalid '%s' value in '%s'. The publication is not enabled for '%s' updatable
                           subscriptions.
 20505                     Could not drop synchronous update stored procedure '%s' in '%s'.
 20506                     Source table '%s' not found in '%s'.
 20507                     Table '%s' not found in '%s'.
 20508                     Updatable Subscriptions: The text/ntext/image values inserted at Subscriber will
                           be NULL.
 20509                     Updatable Subscriptions: The text/ntext/image values cannot be updated at
                           Subscriber.
 20510                     Updatable Subscriptions: Cannot update identity columns.
 20511                     Updatable Subscriptions: Cannot update timestamp columns.
 20512                     Updatable Subscriptions: Rolling back transaction.
 20515                     Updatable Subscriptions: Rows do not match between Publisher and Subscriber.
                           Run the Distribution Agent to refresh rows at the Subscriber.
 20516                     Updatable Subscriptions: Replicated data is not updatable.
 20517                     Updatable Subscriptions: Update of replica's primary key is not allowed unless
                           published table has a timestamp column.
 20518                     Updatable Subscriptions: INSERT and DELETE operations are not supported
                           unless published table has a timestamp column.
 20519                     Updatable Subscriptions: INSERT operations on tables with identity or timestamp
                           columns are not allowed unless a primary key is defined at the Subscriber.
 20520                     Updatable Subscriptions: UPDATE operations on tables with identity or timestamp
                           columns are not allowed unless a primary key is defined at the Subscriber.
 20521                     sp_MSmark_proc_norepl: must be a member of the db_owner or sysadmin roles.
 20522                     sp_MSmark_proc_norepl: invalid object name '%s'.
 20523                     Could not validate the article '%s'. It is not activated.
 20524                     Table '%s' may be out of synchronization. Rowcounts (actual: %s, expected: %s).
                           Rowcount method %d used (0 = Full, 1 = Fast).
 20525                     Table '%s' might be out of synchronization. Rowcounts (actual: %s, expected
                           %s). Checksum values (actual: %s, expected: %s).




242                                                                                      InterSystems Error Reference
                                                                                              TSQL Error Messages


 Error Code                    Description
 20526                         Table '%s' passed rowcount (%s) validation. Rowcount method %d used (0 =
                               Full, 1 = Fast).
 20527                         Table '%s' passed rowcount (%s) and checksum validation. Checksum is not
                               compared for any text or image columns.
 20528                         Log Reader Agent startup message.
 20529                         Starting agent.
 20530                         Run agent.
 20531                         Detect nonlogged agent shutdown.
 20532                         Replication agent schedule.
 20533                         Replication agents checkup
 20534                         Detects replication agents that are not logging history actively.
 20535                         Removes replication agent history from the distribution database.
 20536                         Replication: agent failure
 20537                         Replication: agent retry
 20538                         Replication: expired subscription dropped
 20540                         Replication: agent success
 20541                         Removes replicated transactions from the distribution database.
 20542                         Detects and removes expired subscriptions from published databases.
 20543                         @rowcount_only parameter must be the value 0,1, or 2. 0=7.0 compatible
                               checksum. 1=only check rowcounts. 2=new checksum functionality introduced
                               in version 8.0.
 20545                         Default agent profile
 20546                         Verbose history agent profile.
 20547                         Agent profile for detailed history logging.
 20548                         Slow link agent profile.
 20549                         Agent profile for low bandwidth connections.
 20550                         Windows Synchronization Manager profile
 20551                         Profile used by the Windows Synchronization Manager.
 20552                         Could not clean up the distribution transaction tables.
 20553                         Could not clean up the distribution history tables.
 20554                         The agent is suspect. No response within last %ld minutes.
 20555                         6.x publication.
 20556                         Heartbeats detected for all running replication agents.
 20557                         Agent shutdown. For more information, see the SQL Server Agent job history for
                               job '%s'.




InterSystems Error Reference                                                                                 243
TSQL Error Messages


 Error Code           Description
 20558                Table '%s' passed full rowcount validation after failing the fast check. DBCC
                      UPDATEUSAGE will be initiated automatically.
 20559                Conditional Fast Rowcount method requested without specifying an expected
                      count. Fast method will be used.
 20560                An expected checksum value was passed, but checksums will not be compared
                      because rowcount-only checking was requested.
 20561                Generated expected rowcount value of %s for %s.
 20562                User delete.
 20563                No longer belongs in this partial.
 20564                System delete.
 20565                Replication: Subscriber has failed data validation
 20566                Replication: Subscriber has passed data validation
 20567                Agent history clean up: %s
 20568                Distribution clean up: %s
 20569                Expired subscription clean up
 20570                Reinitialize subscriptions having data validation failures
 20571                Reinitializes all subscriptions that have data validation failures.
 20572                Subscriber '%s' subscription to article '%s' in publication '%s' has been reinitialized
                      after a validation failure.
 20573                Replication: Subscription reinitialized after validation failure
 20574                Subscriber '%s' subscription to article '%s' in publication '%s' failed data validation.
 20575                Subscriber '%s' subscription to article '%s' in publication '%s' passed data
                      validation.
 20576                Subscriber '%s' subscription to article '%s' in publication '%s' has been reinitialized
                      after a synchronization failure.
 20577                No entries were found in msdb..sysreplicationalerts.
 20578                Replication: agent custom shutdown
 20579                Generated expected rowcount value of %s and expected checksum value of %s
                      for %s.
 20580                Heartbeats not detected for some replication agents. The status of these agents
                      have been changed to 'Failed'.
 20581                Cannot drop server '%s' because it is used as a Distributor in replication.
 20582                Cannot drop server '%s' because it is used as a Publisher in replication.
 20583                Cannot drop server '%s' because it is used as a Subscriber in replication.
 20584                Cannot drop server '%s' because it is used as a Subscriber to remote Publisher
                      '%s' in replication.
 20585                Validation Failure. Object '%s' does not exist.



244                                                                              InterSystems Error Reference
                                                                                                  TSQL Error Messages


 Error Code                    Description
 20586                         (default destination)
 20587                         Invalid '%s' value for stored procedure '%s'.
 20588                         The subscription is not initialized. Run the Distribution Agent first.
 20589                         Agent profile for replicated queued transaction reader.
 20590                         The article property 'status' cannot include bit 64, 'DTS horizontal partitions'
                               because the publication does not allow data transformations.
 20591                         Only 'DTS horizontal partitions' and 'no DTS horizontal partitions' are valid 'status'
                               values because the publication allows data transformations.
 20592                         'dts horizontal partitions' and 'no dts horizontal partitions' are not valid 'status'
                               values because the publication does not allow data transformations.
 20593                         Cannot modify publication '%s'. The sync_method cannot be changed to 'native',
                               'concurrent' or 'concurrent_c' because the publication has subscriptions from
                               ODBC or OLE DB Subscribers.
 20594                         A push subscription to the publication exists. Use sp_subscription_cleanup to
                               drop defunct push subscriptions.
 20595                         Skipping error signaled.
 20596                         Only '%s' or members of db_owner can drop the anonymous agent.
 20597                         Dropped %d anonymous subscription(s).
 20598                         The row was not found at the Subscriber when applying the replicated command.
 20599                         Continue on data consistency errors.

Table 3–103:TSQL Error Codes - 20600 to 20699

 Error Code                    Description
 20600                         Agent profile for skipping data consistency errors. It can be used only by SQL
                               Server Subscribers.
 20601                         Invalid value specified for agent parameter 'SkipErrors'.
 20602                         The value specified for agent parameter 'SkipErrors' is too long.
 20603                         The agent profile cannot be used by heterogeneous Subscribers.
 20604                         You do not have permissions to run agents for push subscriptions. Make sure
                               that you specify the agent parameter 'SubscriptionType'.
 20605                         Invalidated the existing snapshot of the publication. Run the Snapshot Agent
                               again to generate a new snapshot.
 20606                         Reinitialized subscription(s).
 20607                         Cannot make the change because a snapshot is already generated. Set
                               @force_invalidate_snapshot to 1 to force the change and invalidate the existing
                               snapshot.
 20608                         Cannot make the change because there are active subscriptions. Set
                               @force_reinit_subscription to 1 to force the change and reinitialize the active
                               subscriptions.



InterSystems Error Reference                                                                                           245
TSQL Error Messages


 Error Code                Description
 20609                     Cannot attach subscription file '%s'. Make sure that it is a valid subscription copy
                           file.
 20610                     Cannot run '%s' when the Log Reader Agent is replicating the database.
 20611                     Only table or indexed view to table articles are allowed in publications that allow
                           DTS.
 20612                     Checksum validation is not supported because the publication allows DTS. Use
                           row count only validation.
 20613                     Validation is not supported for articles that are set up for DTS horizontal partitions.
 20614                     Validation is not supported for heterogeneous Subscribers.
 20616                     High Volume Server-to-Server Profile
 20617                     Merge agent profile optimized for the high volume server-to-server synchronization
                           scenario.
 20618                     You must have CREATE DATABASE permission to attach a subscription database.
 20619                     Server user '%s' is not a valid user in database '%s'. Add the user account or
                           'guest' user account into the database first.
 20620                     The security mode specified requires the server '%s' in sysservers. Use
                           sp_addlinkedserver to add the server.
 20621                     Cannot copy a subscription database to an existing database.
 20622                     Replication database option 'sync with backup' cannot be set on the publishing
                           database because the database is in Simple Recovery mode.
 20623                     You cannot validate article '%s' unless you have 'SELECT ALL' permission on
                           table '%s'.

Table 3–104:TSQL Error Codes - 21000 to 21099

 Error Code                Description
 21000                     Cannot subscribe to an inactive publication.
 21001                     Cannot add a Distribution Agent at the Subscriber for a push subscription.
 21002                     The Distribution Agent for this subscription already exists (%s).
 21003                     Changing publication names is no longer supported.
 21004                     Cannot publish the database object '%s' because it is encrypted.
 21005                     For backward compatibility, sp_addpublisher can be used to add a Publisher for
                           this Distributor. However, sp_adddistpublisher is more flexible.
 21006                     Cannot use sp_addpublisher to add a Publisher. Use sp_adddistpublisher.
 21007                     Cannot add the remote Distributor. Make sure that the local server is configured
                           as a Publisher at the Distributor.
 21008                     Cannot uninstall the Distributor because there are Subscribers defined.
 21009                     The specified filter procedure is already associated with a table.




246                                                                                  InterSystems Error Reference
                                                                                               TSQL Error Messages


 Error Code                    Description
 21010                         Removed %ld replicated transactions consisting of %ld statements in %ld seconds
                               (%ld rows/sec).
 21011                         Deactivated subscriptions.
 21012                         Cannot change the 'allow_push' property of the publication to "false". There are
                               push subscriptions on the publication.
 21013                         Cannot change the 'allow_pull' property of the publication to "false". There are
                               pull subscriptions on the publication.
 21014                         The @optname parameter value must be 'transactional' or 'merge'.
 21015                         The replication option '%s' has been set to TRUE already.
 21016                         The replication option '%s' has been set to FALSE already.
 21017                         Cannot perform SQL Server 7.0 compatible checksum operation on a merge
                               article that has a vertical or horizontal partition. Rowcount validation and SQL
                               Server 2000 compatible binary checksum operation can be performed on this
                               page.
 21018                         There are too many consecutive snapshot transactions in the distribution database.
                               Run the Log Reader Agent again or clean up the distribution database.
 21021                         Drop the Distributor before you uninstall replication.
 21022                         Cannot set incompatible publication properties. The 'immediate_sync' property
                               of a publication is dependent on the 'independent agent' property of a publication.
 21023                         '%s' is no longer supported.
 21024                         The stored procedure '%s' is already published as an incompatible type.
 21025                         The string being encrypted cannot have null characters.
 21026                         Cannot have an anonymous subscription on a publication that does not have an
                               independent agent.
 21027                         '%s' replication stored procedures are not installed. Use sp_replicationoption to
                               install them.
 21028                         Replication components are not installed on this server. Run SQL Server Setup
                               again and select the option to install replication.
 21029                         Cannot drop a push subscription entry at the Subscriber unless @drop_push is
                               'true'.
 21030                         Names of SQL Server replication agents cannot be changed.
 21031                         'post_script' is not supported for stored procedure articles.
 21032                         Could not subscribe because non-SQL Server Subscriber '%s' does not support
                               'sync tran' update mode.
 21033                         Cannot drop server '%s' as Distribution Publisher because there are databases
                               enabled for replication on that server.
 21034                         Rows inserted or updated at the Subscriber cannot be outside the article partition.
 21035                         You have updated the Publisher property '%s' successfully.




InterSystems Error Reference                                                                                      247
TSQL Error Messages


 Error Code           Description
 21036                Another %s agent for the subscription(s) is running.
 21037                Invalid working directory '%s'.
 21038                Windows Authentication is not supported by the server.
 21039                The destination owner name is not supported for publications that can have
                      heterogeneous Subscribers. Use native mode bcp for this functionality.
 21040                Publication '%s' does not exist.
 21041                A remote distribution Publisher is not allowed on this server version.
 21042                The distribution Publisher property, 'distributor_password', has no usage and is
                      not supported for a Distributor running on Windows NT 4.0.
 21043                The Distributor is not installed.
 21044                Cannot ignore the remote Distributor (@ignore_remote_distributor cannot be 1)
                      when enabling the database for publishing or merge publishing.
 21045                Cannot uninstall the Distributor because there are databases enabled for publishing
                      or merge publishing.
 21046                Cannot change distribution Publisher property 'distribution_db' because the remote
                      Publisher is using the current distribution database.
 21047                Cannot drop the local distribution Publisher because there are Subscribers defined.
 21048                Cannot add login '%s' to the publication access list because it does not have
                      access to the distribution server '%s'.
 21049                The login '%s' does not have access permission on publication '%s' because it is
                      not in the publication access list.
 21050                Only members of the sysadmin or db_owner roles can perform this operation.
 21051                Could not subscribe because non-SQL Server Subscriber '%s' does not support
                      custom stored procedures.
 21052                Queued Updating Subscriptions: write to message queue failed.
 21053                The parameter must be one of the following: 'description', 'status', 'retention',
                      'sync_mode', 'allow_push', 'allow_pull', 'allow_anonymous', 'enabled_for_internet',
                      'centralized_conflicts', 'conflict_retention', or 'snapshot_ready'.
 21054                Updatable Subscribers: RPC to Publisher failed.
 21055                Invalid parameter %s specified for %s.
 21056                The subscription to publication '%s' has expired and does not exist.
 21057                Anonymous Subscribers cannot have updatable subscriptions.
 21058                An updatable subscription to publication '%s' on Subscriber '%s' already exists.
 21059                Cannot reinitialize subscriptions of non-immediate_sync publications.
 21060                Could not subscribe because non-SQL Server Subscriber '%s' does not support
                      parameterized statements.
 21061                Invalid article status %d specified when adding article '%s'.




248                                                                           InterSystems Error Reference
                                                                                                  TSQL Error Messages


 Error Code                    Description
 21062                         The row size of table '%s' exceeds the replication limit of 6,000 bytes.
 21063                         Table '%s' cannot participate in updatable subscriptions because it is published
                               for merge replication.
 21064                         The subscription is uninitialized or unavailable for immediate updating as it is
                               marked for reinitialization. If using queued failover option, run Queue Reader
                               Agent for subscription initialization. Try again after the (re)initialization completes.
 21070                         This subscription does not support automatic reinitialization (subscribed with the
                               'no sync' option). To reinitialize this subscription, you must drop and re-create the
                               subscription.
 21071                         Cannot reinitialize article '%s' in subscription '%s:%s' to publication '%s'
                               (subscribed with the 'no sync' option).
 21072                         The subscription has not been synchronized within the maximum retention period
                               or it has been dropped at the Publisher. You must reinitialize the subscription to
                               receive data.
 21073                         The publication specified does not exist.
 21074                         The subscription has been marked inactive and must be reinitialized at the
                               Publisher. Contact the database administrator.
 21075                         The initial snapshot for publication '%s' is not yet available.
 21076                         The initial snapshot for article '%s' is not yet available.
 21077                         Deactivated initial snapshot for anonymous publication(s). New subscriptions
                               must wait for the next scheduled snapshot.
 21078                         Table '%s' does not exist in the Subscriber database.
 21079                         The RPC security information for the Publisher is missing or invalid. Use
                               sp_link_publication to specify it.
 21080                         The 'msrepl_tran_version' column must be in the vertical partition of the article
                               that is enabled for updatable subscriptions; it cannot be dropped.
 21081                         Server setting 'Allow triggers to be fired which fire other triggers (nested triggers)'
                               must exist on updatable Subscribers.
 21082                         Database property 'IsRecursiveTriggersEnabled' has to be false for subscription
                               databases at Subscribers that allow updatable subscriptions.
 21083                         Database compatibility level at immediate updating Subscribers cannot be less
                               than 70.
 21084                         Publication '%s' does not allow anonymous subscriptions.
 21085                         The retention period must be less than the retention period for the distribution
                               database.
 21086                         The retention period for the distribution database must be greater than the retention
                               period of any existing non-merge publications.
 21087                         Anonymous Subscribers or Subscribers at this server are not allowed to create
                               merge publications.
 21088                         The initial snapshot for the publication is not yet available.



InterSystems Error Reference                                                                                        249
TSQL Error Messages


Table 3–105:TSQL Error Codes - 21100 to 21199

 Error Code                Description
 21107                     '%ls' is not a table or view.
 21108                     This edition of SQL Server does not support transactional publications.
 21109                     The parameters @xact_seqno_start and @xact_seqno_end must be identical if
                           @command_id is specified.
 21110                     @xact_seqno_start and @publisher_database_id must be specified if
                           @command_id is specified.
 21111                     '%s' is not a valid parameter for the Snapshot Agent.
 21112                     '%s' is not a valid parameter for the Log Reader Agent.
 21113                     '%s' is not a valid parameter for the Distribution Agent.
 21114                     '%s' is not a valid parameter for the Merge Agent.
 21115                     '%s' is not a valid value for the '%s' parameter. The value must be a positive
                           integer.
 21116                     '%s' is not a valid value for the '%s' parameter. The value must be 1, 2, or 3.
 21117                     '%s' is not a valid value for the '%s' parameter. The value must be 0, 1, or 2.
 21118                     '%s' is not a valid value for the '%s' parameter. The value must be greater than
                           or equal to 0 and less than or equal to 10,000.
 21119                     '%s' is not a valid value for the '%s' parameter. The value must be a non-negative
                           integer.
 21120                     Only members of the sysadmin fixed server role and db_owner fixed database
                           role can drop subscription '%s' to publication '%s'.
 21121                     Only members of the sysadmin fixed server role and '%s' can drop the pull
                           subscription to the publication '%s'.
 21122                     Cannot drop the distribution database '%s' because it is currently in use.
 21123                     The agent profile '%s' could not be found at the Distributor.
 21124                     Cannot find the table name or the table owner corresponding to the alternative
                           table ID(nickname) '%d' in sysmergearticles.
 21125                     A table used in merge replication must have at least one non-computed column.
 21126                     Pull subscriptions cannot be created in the same database as the publication.
 21127                     Only global merge subscriptions can be added to database '%s'.
 21128                     Terminating immediate updating or queued updating INSERT trigger because it
                           is not the first trigger to fire. Use sp_settriggerorder procedure to set the firing
                           order for trigger '%s' to first.
 21129                     Terminating immediate updating or queued updating UPDATE trigger because it
                           is not the first trigger to fire. Use sp_settriggerorder procedure to set the firing
                           order for trigger '%s' to first.




250                                                                                 InterSystems Error Reference
                                                                                               TSQL Error Messages


 Error Code                    Description
 21130                         Terminating immediate updating or queued updating DELETE trigger because it
                               is not the first trigger to fire. Use sp_settriggerorder procedure to set the firing
                               order for trigger '%s' to first.
 21131                         There are existing subscriptions to heterogeneous publication '%s'. To add new
                               articles, first drop the existing subscriptions to the publication.
 21132                         Cannot create transactional subscription to merge publication '%s'.The publication
                               type should be either transactional(0) or snapshot(1) for this operation.
 21133                         Publication '%s' is not enabled to use an independent agent.
 21134                         The specified job ID must identify a Distribution Agent or a Merge Agent job.
 21135                         Detected inconsistencies in the replication agent table. The specified job ID does
                               not correspond to an entry in '%ls'.
 21136                         Detected inconsistencies in the replication agent table. The specified job ID
                               corresponds to multiple entries in '%ls'.
 21137                         This procedure supports only remote execution of push subscription agents.
 21138                         The 'offload_server' property cannot be the same as the Distributor name.
 21139                         Could not determine the Subscriber name for distributed agent execution.
 21140                         Agent execution cannot be distributed to a Subscriber that resides on the same
                               server as the Distributor.
 21141                         The @change_active flag may not be specified for articles with manual filters or
                               views.
 21142                         The SQL Server '%s' could not obtain Windows group membership information
                               for login '%s'. Verify that the Windows account has access to the domain of the
                               login.
 21143                         The custom stored procedure schema option is invalid for a snapshot publication
                               article.
 21144                         Cannot subscribe to publication of sync_type 'dump database' because the
                               Subscriber has subscriptions to other publications.
 21145                         Cannot subscribe to publication %s because the Subscriber has a subscription
                               to a publication of sync_type 'dump database'.
 21146                         @use_ftp cannot be 'true' while @alt_snapshot_folder is neither NULL nor empty.
 21147                         The '%s' database is not published for merge replication.
 21148                         Both @subscriber and @subscriberdb must be specified with non-null values
                               simultaneously, or both must be left unspecified.
 21149                         The '%s' database is not published for transactional or snapshot replication.
 21150                         Unable to determine the snapshot folder for the specified subscription because
                               the specified Subscriber is not known to the Distributor.
 21151                         Pre- and post-snapshot commands are not supported for a publication that may
                               support non-SQL Server Subscribers by using the character-mode bcp as the
                               synchronization method.




InterSystems Error Reference                                                                                    251
TSQL Error Messages


 Error Code           Description
 21152                Cannot create a subscription of sync_type 'none' to a publication using the
                      'concurrent' or 'concurrent_c' synchronization method.
 21153                Cannot create article '%s'. All articles that are part of a concurrent synchronization
                      publication must use stored procedures to apply changes to the Subscriber.
 21154                Cannot change article '%s'. All articles that are part of a concurrent synchronization
                      publication must use stored procedures to apply changes to the Subscriber.
 21156                The @status parameter value must be 'initiated' or 'active'.
 21157                The snapshot compression option can be enabled only for a publication having
                      an alternate snapshot generation folder defined.
 21158                For a publication to be enabled for the Internet, the 'ftp_address' property must
                      not be null.
 21159                If a publication is enabled for the Internet, the 'alt_snapshot_folder' property must
                      be non-empty.
 21160                The @ftp_port parameter cannot be NULL.
 21161                Could not change the Publisher because the subscription has been dropped. Use
                      sp_subscription_cleanup to clean up the triggers.
 21162                It is invalid to exclude the rowguid column for the table from the partition.
 21163                It is not possible to add column '%s' to article '%s' because the snapshot for
                      publication '%s' has been run.
 21164                Column '%s' cannot be included in a vertical partition because it is neither nullable
                      nor defined with a default value.
 21165                Column '%s' cannot be excluded from a vertical partition because it is neither
                      nullable nor defined with a default value.
 21166                Column '%s' does not exist.
 21167                The specified job ID does not represent a %s agent job for any push subscription
                      in this database.
 21168                Only members of the sysadmin fixed server role, members of the db_owner fixed
                      database role, and owners of subscriptions served by the specified replication
                      agent job can modify the agent offload settings.
 21169                Could not identify the Publisher '%s' at the Distributor '%s'. Make sure that '%s'
                      is registered in the sysservers table at the Distributor.
 21170                Only a SQL Server 2000 or OLE DB Subscriber can use DTS.
 21171                Could not find package '%s' in msdb at server '%s'.
 21172                The publication has to be in 'character' or 'concurrent_c' bcp mode to allow DTS.
 21173                The publication has to be 'independent_agent type' to allow DTS.
 21174                You must use default values for @ins_cmd, @upd_cmd, and @del_cmd, and
                      @status can be only 16 or 80 because the publication allows DTS.
 21175                You cannot change 'ins_cmd','upd_cmd', or 'del_cmd' article properties because
                      the publication allows DTS or queued updating option.



252                                                                             InterSystems Error Reference
                                                                                               TSQL Error Messages


 Error Code                    Description
 21176                         Only members of the sysadmin fixed server role, db_owner fixed database role,
                               or the creator of the subscription can change the subscription properties.
 21177                         Could not create column list because it is too long. Create the list manually.
 21178                         DTS properties cannot be set because the publication does not allow for data
                               transformation.
 21179                         Invalid @dts_package_location parameter value. Valid options are 'Distributor'
                               or 'Subscriber'.
 21180                         A publication that allows DTS cannot be enabled for updatable subscriptions.
 21181                         @dts_package_name can be set for push subscriptions only.
 21182                         The @agent_type parameter must be one of 'distribution', 'merge', or NULL.
 21183                         Invalid property name '%s'.
 21184                         %s parameter is incorrect: it should be '%s', '%s' or '%s'.
 21185                         The subscription is not initialized or not created for failover mode operations.
 21186                         Subscription for Publisher '%s' does not have a valid queue_id.
 21187                         The current mode is the same as the requested mode.
 21188                         Changed update mode from [%s] to [%s].
 21189                         The queue for this subscription with queue_id = '%s' is not empty. Run the Queue
                               Reader Agent to make sure the queue is empty before setting mode from [queued]
                               to [immediate].
 21190                         Overriding queue check for setting mode from [%s] to [%s].
 21191                         Values for @ins_cmd, @upd_cmd, and @del_cmd can be only [%s], [%s] and
                               [%s] respectively because the publication allows queued transactions.
 21192                         MSrepl_tran_version column is a predefined column used for replication and can
                               be only of data type uniqueidentifier
 21193                         @identity_range, @pub_identity_range, or @threshold cannot be NULL when
                               @auto_identity_support is set to TRUE.
 21194                         Cannot support identity_range_control because this table does not have an identity
                               column.
 21195                         A valid identity range is not available. Check the data type of the identity column.
 21196                         Identity automation failed.
 21197                         Failed to allocate new identity range.
 21198                         Schema replication failed.
 21199                         This change cannot take effect until you run the snapshot again.

Table 3–106:TSQL Error Codes - 21200 to 21299

 Error Code                    Description
 21200                         Publication '%s' does not exist.




InterSystems Error Reference                                                                                      253
TSQL Error Messages


 Error Code           Description
 21201                Dropping a column that is being used by a merge filter clause is not allowed.
 21202                It is not possible to drop column '%s' to article '%s' because the snapshot for
                      publication '%s' has already been run.
 21203                Duplicate rows found in %s. Unique index not created.
 21204                The publication '%s' does not allow subscription copy or its subscription has not
                      been synchronized.
 21205                The subscription cannot be attached because the publication does not allow
                      subscription copies to synchronize changes.
 21206                Cannot resolve load hint for object %d because the object is not a user table.
 21207                Cannot find source object ID information for article %d.
 21208                This step failed because column '%s' exists in the vertical partition.
 21209                This step failed because column '%s' does not exist in the vertical partition.
 21210                The publication must be immediate_sync type to allow subscription copy.
 21211                The database is attached from a subscription copy file without using
                      sp_attach_subscription. Drop the database and reattach it using
                      sp_attach_subscription.
 21212                Cannot copy subscription. Only single file subscription databases are supported
                      for this operation.
 21213                Non-SQL Server Subscribers cannot subscribe to publications that allow DTS
                      without using a DTS package.
 21214                Cannot create file '%s' because it already exists.
 21215                An alternate synchronization partner can be configured only at the Publisher.
 21216                Publisher '%s', publisher database '%s', and publication '%s' are not valid
                      synchronization partners.
 21217                Publication of '%s' data from Publisher '%s'.
 21218                The creation_script property cannot be NULL if a schema option of
                      0x0000000000000000 is specified for the article.
 21219                The specified source object must be a stored procedure object if it is published
                      as a 'proc schema only' type article.
 21220                Unable to add the article '%s' because a snapshot has been generated for the
                      publication '%s'.
 21221                The specified source object must be a view object if it is going to be as a 'view
                      schema only' type article.
 21222                The @schema_option parameter for a procedure or function schema article can
                      include only the options 0x0000000000000001 or 0x0000000000002000.
 21223                The @pre_creation_command parameter for a schema only article must be either
                      'none' or 'drop'.
 21224                '%s' is not a valid property for a schema only article.




254                                                                             InterSystems Error Reference
                                                                                               TSQL Error Messages


 Error Code                    Description
 21225                         The 'offload_server' property cannot be NULL or empty if the pull subscription
                               agent is to be enabled for remote activation.
 21226                         The database '%s' does not have a pull subscription to the specified publication.
 21227                         The 'offload_server' property cannot be the same as the Subscriber server name.
 21228                         The specified source object must be a user-defined function object if it is going
                               to be published as a 'func schema only' type article.
 21229                         The only schema options available for a view schema article are:
                               0x0000000000000001, 0x0000000000000010, 0x0000000000000040,
                               0x0000000000000100, and 0x0000000000002000.
 21230                         Do not call this stored procedure for schema change because the current database
                               is not enabled for replication.
 21231                         Automatic identity range support is useful only for publications that allow queued
                               updating.
 21232                         Identity range values must be positive numbers that are greater than 1.
 21233                         Threshold value must be from 1 through 100.
 21234                         Cannot use the INSERT command because the table has an identity column. The
                               insert custom stored procedure must be used to set 'identity_insert' settings at
                               the Subscriber.
 21235                         Article property '%s' can be set only when the article uses automatic identity range
                               management.
 21236                         The subscription(s) to Publisher '%s' does not allow subscription copy or it has
                               not been synchronized.
 21237                         There is a push subscription to Publisher '%s'. Only pull and anonymous
                               subscriptions can be copied.
 21238                         There is a push subscription to publication '%s'. Only pull and anonymous
                               subscriptions can be copied.
 21239                         Cannot copy subscriptions because there is no synchronized subscription found
                               in the database.
 21240                         The table '%s' is already published as another article with a different automatic
                               identity support option.
 21241                         The threshold value should be from 0 through 99.
 21242                         Conflict table for article '%s' could not be created successfully.
 21243                         Publisher '%s', publication database '%s', and publication '%s' could not be added
                               to the list of synchronization partners.
 21244                         Character mode publication does not support vertical filtering when the base table
                               does not support column-level tracking.
 21245                         Table '%s' is not part of publication '%s'.
 21246                         This step failed because table '%s' is not part of any publication.
 21247                         Cannot create file at '%s'. Ensure the file path is valid.



InterSystems Error Reference                                                                                    255
TSQL Error Messages


 Error Code           Description
 21248                Cannot attach subscription file '%s'. Ensure the file path is valid and the file is
                      updatable.
 21249                OLE DB or ODBC Subscribers cannot subscribe to article '%s' in publication '%s'
                      because the article has a timestamp column and the publication is
                      'allow_queued_tran' (allows queued updating subscriptions).
 21250                Primary key column '%s' cannot be excluded from a vertical partition.
 21251                Publisher '%s', publisher database '%s', publication '%s' could not be removed
                      from the list of synchronization partners.
 21252                It is invalid to remove the default Publisher '%s', publication database '%s', and
                      publication '%s' from the list of synchronization partners
 21253                Parameter '@add_to_active_directory' cannot be set to TRUE because Active
                      Directory client package is not installed properly on the machine where SQL
                      Server is running.
 21254                The Active Directory operation on publication '%s' could not be completed bacause
                      Active Directory client package is not installed properly on the machine where
                      SQL Server is running.
 21255                Column '%s' already exists in table '%s'.
 21256                A column used in filter clause '%s' either does not exist in the table '%s' or cannot
                      be excluded from the current partition.
 21257                Invalid property '%s' for article '%s'.
 21258                You must first drop all existing merge publications to add an anonymous or local
                      subscription to database '%s'.
 21259                Invalid property value '%s'.
 21260                Schema replication failed because database '%s' on server '%s' is not the original
                      Publisher of table '%s'.
 21261                The offload server must be specified if the agent for this subscription is to be
                      offloaded for remote execution.
 21262                Failed to drop column '%s' from the partition because a computed column is
                      accessing it.
 21263                Parameter '%s' cannot be NULL or an empty string.
 21264                Column '%s' cannot be dropped from table '%s' because it is a primary key column.
 21265                Column '%s' cannot be dropped from table '%s' because there is a unique index
                      accessing this column.
 21266                Cannot publish table '%s' for both a merge publication and a publication with the
                      queued updating option .
 21267                Invalid value for queue type was specified. Valid values = (%s).
 21268                Cannot change queue type while there are subscriptions to the publication.
 21269                Cannot add a computed column or a timestamp column to a vertical partition for
                      a character mode publication.




256                                                                             InterSystems Error Reference
                                                                                               TSQL Error Messages


 Error Code                    Description
 21270                         Queued snapshot publication property '%s' cannot have the value '%s'.
 21272                         Cannot clean up the meta data for publication '%s' because other publications
                               are using one or more articles in this publication.
 21273                         You must upgrade the Subscriber to SQL Server 2000 to create updatable
                               subscriptions to SQL Server 2000 Publishers.
 21274                         Invalid publication name '%s'.
 21275                         The schema-bound view '%ls' can be published only as 'indexed view schema
                               only' or a log-based indexed view (transactional only) article.
 21276                         The type must be 'table' or '( view | indexed view | proc | func ) schema only'.
 21277                         The source object '%ls' must be a schema-bound view to be published as 'indexed
                               view schema only' or a log-based indexed view article.
 21278                         The source object '%ls' must be a schema-bound view with at least a clustered
                               index to be published as a log-based indexed view article.
 21279                         The 'schema_option' property for a merge article cannot be changed after a
                               snapshot is generated for the publication. To change the 'schema_option' property
                               of this page the corresponding merge publication must be dropped and re-created.
 21280                         Publication '%s' cannot be subscribed to by Subscriber database '%s' because
                               it contains one or more articles that have been subscribed to by the same
                               Subscriber database at transaction level.
 21281                         Publication '%s' cannot be subscribed to by Subscriber database '%s' because
                               it contains one or more articles that have been subscribed to by the same
                               Subscriber database at merge level.
 21282                         @identity_range, @pub_identity_range, and @threshold must be NULL when
                               @auto_identity_support is set to FALSE.
 21283                         Column '%s' of table '%s' cannot be excluded from a vertical partition because
                               there is a computed column that depends on it.
 21284                         Failed to drop column '%s' from table '%s'.
 21285                         Failed to add column '%s' to table '%s'.
 21286                         Conflict table '%s' does not exist.
 21287                         The specified @destination_folder is not a valid path of an existing folder.
 21288                         Could not create the snapshot directory structure in the specified
                               @destination_folder.
 21289                         Either the snapshot files have not been generated or they have been cleaned up.
 21290                         Identity range value is too large for the data type of the identity column.
 21291                         The specified automatic identity support parameters conflict with the settings in
                               another article.
 21292                         Object '%s' cannot be published twice in the same publication.
 21293                         Warning: adding updatable subscription for article '%s' may cause data
                               inconsistency as the source table is already subscribed to '%s'



InterSystems Error Reference                                                                                      257
TSQL Error Messages


 Error Code                Description
 21294                     Either @publisher (and @publisher_db) or @subscriber (and @subscriber_db)
                           must be specified, but both cannot be specified.
 21295                     Publication '%s' does not contain any article that uses automatic identity range
                           management.
 21296                     Parameter @resync_type must be either 0, 1, 2.
 21297                     Invalid resync type. No validation has been performed for this subscription.
 21298                     Failed to resynchronize this subscription.
 21299                     Invalid Subscriber partition validation expression '%s'.

Table 3–107:TSQL Error Codes - 21300 to 21399

 Error Code                Description
 21300                     The resolver information was specified without specifying the resolver to be used
                           for article '%s'. The default resolver will be used.
 21301                     The resolver information should be specified while using the '%s' resolver.
 21302                     The resolver information should specify a column with data type, datetime, or
                           smalldatetime while using the '%s' resolver.
 21303                     The article '%s' should enable column tracking to use the '%s' resolver. The default
                           resolver will be used to resolve conflicts on this page.
 21304                     The merge triggers could not be created on the table '%s'.
 21305                     The schema change information could not be updated at the subscription database.
 21306                     The copy of the subscription could not be made because the subscription to
                           publication '%s' has expired.
 21307                     The subscription could not be attached because the subscription to publication
                           '%s' has expired.
 21308                     Rowcount validation profile.
 21309                     Profile used by the Merge Agent to perform rowcount validation.
 21310                     Rowcount and checksum validation profile.
 21311                     Profile used by the Merge Agent to perform rowcount and checksum validation.
 21312                     Cannot change this publication property because there are active subscriptions
                           to this publication.
 21313                     Subscriber partition validation expression must be NULL for static publications.
 21314                     There must be one and only one of '%s' and '%s' that is not NULL.
 21315                     Failed to adjust Publisher identity range for table '%s'.
 21316                     Failed to adjust Publisher identity range for publication '%s'.
 21317                     A push subscription to the publication '%s' already exists. Use
                           sp_mergesubscription_cleanup to drop defunct push subscriptions.
 21318                     Table '%s' must have at least one column that is included in the vertical partition.




258                                                                                    InterSystems Error Reference
                                                                                                TSQL Error Messages


 Error Code                    Description
 21319                         Could not find the Snapshot Agent command line for the specified publication.
 21320                         This version of the Publisher cannot use a SQL Server 7.0 Distributor.
 21321                         The parameter @dynamic_snapshot_location cannot be an empty string.
 21323                         A dynamic snapshot job can be scheduled only for a publication with dynamic
                               filtering enabled.
 21324                         A Snapshot Agent must be added for the specified publication before a dynamic
                               snapshot job can be scheduled.
 21325                         Could not find the Snapshot Agent ID for the specified publication.
 21326                         Could not find the dynamic snapshot job with a '%ls' of '%ls' for the specified
                               publication.
 21327                         '%ls' is not a valid dynamic snapshot job name.
 21328                         The specified dynamic snapshot job name '%ls' is already in use. Try the operation
                               again with a different job name.
 21329                         Only one of the parameters, @dynamic_snapshot_jobid or
                               @dynamic_snapshot_jobname, can be specified with a nondefault value.
 21330                         Failed to create a sub-directory under the replication working directory.(%ls)
 21331                         Failed to copy user script file to the Distributor.(%ls)
 21332                         Failed to retrieve information about the publication : %ls. Check the name again.
 21333                         Protocol error. Message indicates a generation has disappeared.
 21334                         Cannot initialize Message Queuing-based subscription because the platform is
                               not Message Queuing %s compliant
 21335                         Warning: column '%s' already exists in the vertical partition already.
 21336                         Warning: column '%s' does not exist in the vertical partition.
 21337                         Invalid @subscriber_type value. Valid options are 'local' and 'global'.
 21338                         Cannot drop article '%s' from publication '%s' because its snapshot has been run
                               and this publication could have active subscriptions.
 21339                         Warning: the publication uses a feature that is only supported only by Ssubscribers
                               running '%s' or higher.
 21340                         On Demand user script cannot be applied to the snapshot publication.
 21341                         @dynamic_snapshot_location cannot be a non-empty string while
                               @alt_snapshot_folder is neither empty nor null.
 21342                         @dynamic_snapshot_location cannot be a non-empty string while @use_ftp is
                               'true'.
 21343                         Could not find stored procedure '%s'.
 21344                         Invalid value specified for %ls parameter.
 21345                         Excluding the last column in the partition is not allowed.
 21346                         Failed to change the owner of '%s' to '%s'.



InterSystems Error Reference                                                                                     259
TSQL Error Messages


 Error Code           Description
 21347                Column '%s' cannot be excluded from the vertical partitioning because there is a
                      unique index accessing this column.
 21348                Invalid property name '%s'.
 21349                Warning: only Subscribers running SQL Server 7.0 Service Pack 2 or later can
                      synchronize with publication '%s' because decentralized conflict logging is
                      designated.
 21350                Warning: only Subscribers running SQL Server 2000 can synchronize with
                      publication '%s' because a compressed snapshot is used.
 21351                Warning: only Subscribers running SQL Server 2000 can synchronize with
                      publication '%s' because vertical filters are being used.
 21352                Warning: only Subscribers running SQL Server 2000 can synchronize with
                      publication '%s' because schema replication is performed.
 21353                Warning: only Subscribers running SQL Server 7.0 Service Pack 2 or later can
                      synchronize with publication '%s' because publication wide reinitialization is
                      performed.
 21354                Warning: only Subscribers running SQL Server 2000 can synchronize with
                      publication '%s' because publication wide reinitialization is performed.
 21355                Warning: only Subscribers running SQL Server 7.0 Service Pack 2 or later can
                      synchronize with publication '%s' because merge metadata cleanup task is
                      performed.
 21356                Warning: only Subscribers running SQL Server 7.0 Service Pack 2 or later can
                      synchronize with publication '%s' because publication wide validation task is
                      performed.
 21357                Warning: only Subscribers running SQL Server 2000 can synchronize with
                      publication '%s' because data types new in SQL Server 2000 exist in one of its
                      articles.
 21358                Warning: only Subscribers running SQL Server 2000 can synchronize with
                      publication '%s' because at least one timestamp column exists in one of its articles..
 21359                Warning: only Subscribers running SQL Server 2000 can synchronize with
                      publication '%s' because automatic identity ranges are being used.
 21360                Warning: only Subscribers running SQL Server 2000 can synchronize with
                      publication '%s' because a new article has been added to the publication after its
                      snapshot has been generated.
 21361                The specified @agent_jobid is not a valid job id for a '%s' agent job.
 21362                Merge filter '%s' does not exist.
 21363                Failed to add publication '%s' to Active Directory. %s
 21364                Could not add article '%s' because a snapshot is already generated. Set
                      @force_invalidate_snapshot to 1 to force this and invalidate the existing snapshot.
 21365                Could not add article '%s' because there are active subscriptions. Set
                      @force_reinit_subscription to 1 to force this and reintialize the active subscriptions.




260                                                                             InterSystems Error Reference
                                                                                                 TSQL Error Messages


 Error Code                    Description
 21366                         Could not add filter '%s' because a snapshot is already generated. Set
                               @force_invalidate_snapshot to 1 to force this and invalidate the existing snapshot.
 21367                         Could not add filter '%s' because there are active subscriptions. Set
                               @force_reinit_subscription to 1 to force this and reintialize the active subscriptions.
 21368                         The specified offload server name contains the invalid character '%s'.
 21369                         Could not remove publication '%s' from Active Directory.
 21370                         The resync date specified '%s' is not a valid date.
 21371                         Could not propagate the change on publication '%s' to Active Directory.
 21372                         Cannot drop filter '%s' from publication '%s' because its snapshot has been run
                               and this publication could have active subscriptions.
 21373                         Could not open database %s. Replication settings and system objects could not
                               be upgraded. If the database is used for replication, run sp_vupgrade_replication
                               in the [master] database when the database is available.
 21374                         Upgrading distribution settings and system objects in database %s.
 21375                         Upgrading publication settings and system objects in database %s.
 21376                         Could not open database %s. Replication settings and system objects could not
                               be upgraded. If the database is used for replication, run sp_vupgrade_replication
                               in the [master] database when the database is available.
 21377                         Upgrading subscription settings and system objects in database %s.
 21378                         Could not open distribution database %s because it is offline or being recovered.
                               Replication settings and system objects could not be upgraded. Be sure this
                               database is available and run sp_vupgrade_replication again.
 21379                         Cannot drop article '%s' from publication '%s' because a snapshot is already
                               generated. Set @force_invalidate_snapshot to 1 to force this and invalidate the
                               existing snapshot.
 21380                         Cannot add identity column without forcing reinitialization. Set
                               @force_reinit_subscription to 1 to force reinitialization.
 21381                         Cannot add (drop) column to table '%s' because the table belongs to publication(s)
                               with an active updatable subscription. Set @force_reinit_subscription to 1 to force
                               reinitialization.
 21382                         Cannot drop filter '%s' because a snapshot is already generated. Set
                               @force_invalidate_snapshot to 1 to force this and invalidate the existing snapshot.
 21383                         Cannot enable a merge publication on this server because the working directory
                               of its Distributors is not using a UNC path.
 21384                         The specified subscription does not exist or has not been synchronized yet.
 21385                         Snapshot failed to process publication '%s'. Possibly due to active schema change
                               activity.
 21386                         Schema change failed on publication '%s'. Possibly due to active snapshot or
                               other schema change activity.




InterSystems Error Reference                                                                                       261
TSQL Error Messages


 Error Code                Description
 21387                     The expanded dynamic snapshot view definition of one of the articles exceeds
                           the system limit of 3499 characters. Consider using the default mechanism instead
                           of the dynamic snapshot for initializing the specified subscription.
 21388                     The concurrent snapshot for publication '%s' has not been activated by the Log
                           Reader Agent.
 21389                     Warning: only Subscribers running SQL Server 2000 can synchronize with
                           publication '%s' because column-level collation is scripted out with the article
                           schema creation script.
 21390                     Warning: only Subscribers running SQL Server 2000 can synchronize with
                           publication '%s' because extended properties are scripted out with the article
                           schema creation script.
 21391                     Warning: only Subscribers running SQL Server 2000 can synchronize with
                           publication '%s' because it contains schema-only articles.
 21392                     Row filter(%s) is invalid for column partition(%s) for article '%s' in publication '%s'.
 21393                     Dropping row filter(%s) for article '%s' in '%s'. Reissue sp_articlefilter and
                           sp_articleview to create a row filter.
 21394                     Invalid schema option specified for Queued updating publication. Need to set the
                           schema option to include DRI constraints.
 21395                     This column cannot be included in a transactional publication because the column
                           ID is greater than 255.
 21396                     The subscription is marked inactive and must be dropped and re-created.

Table 3–108:TSQL Error Codes - 21400 to 21499

 Error Code                Description
 21400                     Article property must be changed at the original Publisher of article '%s'.
 21401                     Article name cannot be 'all'.
 21402                     Incorrect value for parameter '%s'.
 21403                     The 'max_concurrent_dynamic_snapshots' publication property must be greater
                           than or equal to zero.
 21404                     '%s' is not a valid value for the '%s' parameter. The value must be a positive
                           integer greater than 300 or 0.
 21405                     '%s' is not a valid value for the '%s' parameter. The value must be an integer
                           greater than or equal to %d.
 21406                     '%s' is not a valid value for the '%s' parameter. The value must be 0 or 1.
 21413                     Failed to acquire the application lock indicating the front of the queue.
 21414                     Unexpected failure acquiring application lock.
 21415                     Unexpected failure releasing application lock.
 21416                     Property '%s' of article '%s' cannot be changed.
 21417                     Having a queue timeout value of over 12 hours is not allowed.



262                                                                                   InterSystems Error Reference
                                                                                               TSQL Error Messages


 Error Code                    Description
 21418                         Failed to add column '%s' to table '%s' because of metadata overflow.
 21419                         Filter '%s' of article '%s' cannot be changed.
 21420                         Subscription property '%s' cannot be changed.
 21421                         Article '%s' cannot be dropped because there are other articles using it as a join
                               article.

Table 3–109:TSQL Error Codes - 21500 to 21599

 Error Code                    Description
 21500                         Invalid subscription type is specified. A subscription to publication '%s' already
                               exists in the database with a different subscription type.
 21501                         The supplied resolver information does not specify a valid column name to be
                               used for conflict resolution by '%s'.
 21502                         The publication '%s' does not allow the subscription to synchronize to an alternate
                               synchronization partner.
 21503                         Cleanup of merge meta data cannot be performed while merge processes are
                               running. Retry this operation after the merge processes have completed.
 21504                         Cleanup of merge meta data at republisher '%s'.'%s' could not be performed
                               because merge processes are propagating changes to the republisher. All
                               subscriptions to this republisher must be reinitialized.
 21505                         Changes to publication '%s' cannot be merged because it has been marked
                               inactive.
 21506                         sp_mergecompletecleanup cannot be executed before sp_mergepreparecleanup
                               is executed. Use sp_mergepreparecleanup to initiate the first phase of merge
                               meta data cleanup.
 21507                         All prerequisites for cleaning up merge meta data have been completed. Execute
                               sp_mergecompletecleanup to initiate the final phase of merge meta data cleanup.
 21508                         Cleanup of merge meta data cannot be performed while merge processes are
                               running. Cleanup will proceed after the merge processes have completed.
 21509                         Cleanup of merge meta data cannot be performed because some republishers
                               have not quiesced their changes. Cleanup will proceed after all republishers have
                               quiesced their changes.
 21510                         Data changes are not allowed while cleanup of merge meta data is in progress.
 21511                         Neither MSmerge_contents nor MSmerge_tombstone contain meta data for this
                               row.




InterSystems Error Reference                                                                                    263
4
System Error Messages

4.1 General System Error Messages
The following table lists the InterSystems IRIS® system error messages. If a system process terminates with an error, it
reports the error message via the operator console facility.
Table 4–1: System Error Messages

 Error Code                         Description
 <ALARM>                            An internal timer for user events has expired.
 <ARRAY DIMENSION>                  The expected dimensionality of the variable or argument is incorrect.
 <BAD IMPLICIT>                     Invalid implicit data conversion requested.
 <BLOCKNUMBER>                      A reference has been made to a block outside the range of the database file.
 <_CALLBACK SYNTAX>                 (Note underscore in error code name.) A name has been specified beginning
                                    with an underscore character followed by a letter.
 <CANNOT GET THIS                   There has been an attempt to get a property of a class for which getting this
 PROPERTY>                          property is invalid.
 <CANNOT SET THIS                   There has been an attempt to set a property of a class for which setting this
 PROPERTY>                          property is invalid.
 <CLASS COMPILING>                  There has been an attempt to instantiate a class or invoke a class method
                                    of a class which is currently being recompiled on the local system.
 <CLASS DESCRIPTOR>                 There has been an attempt to run a routine which is actually a class descriptor.
 <CLASS DOES NOT EXIST>             A reference has been made to a nonexistent class. For further details, refer
                                    to $ZERROR.
 <CLASS EDITED>                     There has been an attempt to use an object hosted on the local system whose
                                    class has been recompiled from a remote system since the object was created.
 <CLASS PROPERTY>                   InterSystems IRIS does not support class properties. Class property syntax
                                    generates a compile error. Attempts to issue a class property reference by
                                    calling a propertyGet() instance method as a class method fails with this error.
                                    Rewrite as a proper class method instead of a calculated property.




InterSystems Error Reference                                                                                          265
System Error Messages


 Error Code             Description
 <CLASS RECOMPILED>     There has been an attempt to use an object hosted on the local system whose
                        class has been recompiled on the local system since the object was created.
 <CLASS TOO BIG TO      A class cannot be used because its class descriptor is too large to fit into a
 LOAD>                  routine buffer.
 <CLASS TOO BIG TO      A class cannot be created because its class descriptor is too large to fit into
 SAVE>                  a routine buffer.
 <CLIENT-SERVER         A network request cannot be processed due to incompatibility between the
 MISMATCH>              client and server.
 <CLUSTERFAIL>          A cluster member has failed during global buffer lock processing.
 <COLLATECHANGE>        There was an attempt to change the collation algorithm while subscripted
                        local variables are defined.
 <COLLATEMISMATCH>      Subscript level mapping failed due to misconfigured collation type.
 <COLLATION NOT         A reference has been made to a global whose collation type is not supported
 SUPPORTED>             on the current system.
 <COMMAND>              A command has been used improperly in this context, such as an
                        argumentless GoTo in a routine. For further details, refer to $ZERROR.
 <COMMITFAIL>           Received during a COMMIT when InterSystems IRIS receives an error while
                        processing a TCommit. This error means that InterSystems IRIS is not sure
                        whether one or more remote machines actually processed the commit.
 <COMPLEX PATTERN>      The combination of pattern and input string generate too many possible
                        matches to manage.
 <CONFLICTING BLOCK     There has been an attempt to reserve a block that was already reserved.
 NUMBERS>
 <CORRUPT OBJECT>       An internal object system error occurred. Contact InterSystems Worldwide
                        Response Center if this error occurs.
 <CORRUPT VOLUME SET>   The volume set is corrupted. Usually, this means the label on the volume set
                        is wrong. Use the LABEL utility to correct it.
 <CP NOT STARTED>       One of the major processes required for proper operation of the system failed
                        to start. This is potentially a very serious system error; notify your system
                        manager.
 <DATABASE MAP LABEL>   There is an invalid label in a database map block.
 <DATABASE>             InterSystems IRIS has detected degradation in this database (this is potentially
                        a very serious system error; notify your system manager).
 <DIRECTORY>            There is no such directory on the target system, no InterSystems IRIS
                        database, the InterSystems IRIS database is not mounted, or the database
                        is locked by another configuration. For further details, refer to $ZERROR.
 <DISCONNECT>           A TCP disconnect has been detected while a long-duration request is being
                        processed.
 <DISKHARD>             InterSystems IRIS has encountered an uncorrectable disk hardware error
                        (this may also be the result of a database problem; notify your system
                        manager).



266                                                                          InterSystems Error Reference
                                                                                 General System Error Messages


 Error Code                    Description
 <DIVIDE>                      There has been an attempt to divide by zero.
 <DOMAINSPACERETRY>            Repeated attempts to contact the domain space master have failed.
 <DSCON>                       There has been an attempt to read from a disconnected terminal.
 <DSKFUL>                      An attempt to write data to a disk file failed because the file reached its
                               maximum size; some of the data was written but not all.
 <DUPLICATEARG>                There has been an attempt use $SORTBEGIN with an ancestor or descendent
                               of an already-defined $SORTBEGIN global.
 <DYNAMIC LIBRARY LOAD>        An error has occurred during an attempt to load a dynamic library via callout.
                               See messages.log for additional information.
 <ECODETRAP>                   A user-generated software trap was generated by setting the $ECODE system
                               variable to a non-null string value.
 <EDITED>                      Incorrect modification of a routine has resulted in a mismatch, such as two
                               copies of a routine with the same name but different timestamps, or the class
                               routine does not match the class descriptor. For example, compiling a routine,
                               then using ZLOAD and ZSAVE on the routine would result in a timestamp
                               mismatch. Also, if the connection to the data server suffers a network outage
                               (neither application server nor data server shuts down), the routines
                               downloaded from the data server are marked as if they had been edited.
 <ENDOFFILE>                   There has been an attempt to read past the end-of-file marker of a sequential
                               file.
 <ERRTRAP>                     There are insufficient system resources remaining to run an error trap
                               procedure.
 <EXTERNAL INTERRUPT>          Another process has attempted to interrupt this process.
 <FILEFULL>                    InterSystems IRIS attempted to allocate a disk block for more global data or
                               routine storage, but the attempt failed because the InterSystems IRIS
                               database is full and could not be expanded.
 <FRAMESTACK>                  The routine has too many nested calls to Do, For, Xecute, New, or
                               user-written functions. For further details, refer to $ZERROR.
 <FUNCTION>                    The specified function does not exist or is being used improperly.
 <GARBAGE COLLECTOR            One of the processes that reclaims space in the database has failed. This is
 FAILED>                       potentially a very serious system error; notify your system manager.
 <HALTED>                      An internal error message.
 <ILLEGAL VALUE>               There has been an attempt to use a negative value where one is not allowed,
                               such as, for $X or $Y.
 <INSUFFICIENT CLASS           A class cannot be used because InterSystems IRIS has run out of shared
 MEMORY>                       memory.
 <INTERNAL OBJECT              An internal object system error. Contact InterSystems Worldwide Response
 ERROR>                        Center if this error occurs.
 <INTERRUPT>                   A user has interrupted the routine. (In many implementations, the user has
                               pressed CTRL-C.)




InterSystems Error Reference                                                                                 267
System Error Messages


 Error Code                Description
 <INVALID ARGUMENT>        There is an invalid argument prototype in the zfentry specification of a callout
                           function.
 <INVALID BIT STRING>      The bit string used in a bit string operation is not valid.
 <INVALID CLASS>           There has been an attempt to use a class that has been corrupted. Recompile
                           the class and try again.
 <INVALID FILE VARIABLE>   A file variable was expected but none was supplied.
 <INVALID GLOBAL           A global reference failed length validation.
 REFERENCE>
 <INVALID OREF>            No object with the specified OREF is currently in memory.
 <INVALID SELECT LIST>     A SELECT list was expected but not supplied.
 <INVALID TYPE>            An OREF has been used where not allowed.
 <Java Exception>          An exception occurred during a call into the Java runtime environment.
 <Java VM not loaded>      No Java Virtual Machine is available.
 <LABELREDEF>              A routine has a duplicate label within it. Labels must be unique within the
                           routine.
 <LANGUAGE MISMATCH>       While compiling and inserting code into an existing routine, the current
                           language mode differs from that of the routine.
 <LICENSE ALLOCATION       There has been an attempt to exceed the operational user limit imposed on
 EXCEEDED>                 this instance with the $SYSTEM.License.SetUserLimit(InstanceUserLimit)
                           API.
 <LICENSE LIMIT            There has been an attempt to exceed the number of users allowed by the
 EXCEEDED>                 active InterSystems IRIS license, either on the current IRIS instance or in
                           total among the set of instances sharing the license.
 <LICENSE SERVER           The license server is unreachable at the moment. Check your network.
 UNAVAILABLE>
 <LIST>                    An improperly-formed list has been used.
 <LOCKLOST>                Some locks once owned by this job have been reset.
 <LOGIN INHIBITED>         The system is initializing. No users are permitted to begin work.
 <MAGTAPE>                 A magnetic tape operation encountered an error. Check $ZA.
 <MAXARRAY>                There are too many subscripts at this level.
 <MAXINCREMENT>            An attempt to $INCREMENT a variable did not change its value.
 <MAX LOCKS>               The maximum lock count (32766) has been exceeded.
 <MAXNUMBER>               An arithmetic operation has produced a number larger than the implementation
                           allows.
 <MAX ROUTINES>            There are no slots available to allocate to invoke a new routine.
 <MAXSCOPE>                There has been an attempt to issue more than 31 levels of New commands.




268                                                                              InterSystems Error Reference
                                                                               General System Error Messages


 Error Code                    Description
 <MAXSTRING>                   There has been an attempt to specify or create a data string longer than the
                               string length limit. Attempting to concatenate strings that would result in a
                               string exceeding this maximum string size results in a <MAXSTRING> error.
 <METHOD DOES NOT              The method does not exist in the specified class or the class of the specified
 EXIST>                        object. For further details, refer to $ZERROR.
 <METHOD NOT                   The method exists, but is not supported in this context. For example, a nested
 SUPPORTED>                    call to %ToJSON() where the referenced object is not a dynamic object or
                               array.
 <MNEMONICSPACE>               There has been an attempt to use control mnemonics for a device with no
                               associated mnemonic space.
 <NAKED>                       There has been an attempt to use a naked global reference when the naked
                               state was undefined.
 <NAME>                        There is invalid syntax in a name.
 <NAMEADD>                     There has been an overflow of device name table, resulting from the Open
                               command.
 <NAMESPACE>                   The specified namespace is undefined or not active.
 <NESTED TOO DEEP>             This error is signaled when processing %DynamicArray and %DynamicObject
                               blocks where the nesting level is too deep.
 <NETFORMAT>                   There has been an error in a network message. The remote system found
                               fault with the format of a request. Call your support center to resolve this
                               serious error.
 <NETGLOREF>                   There has been an error in a network message. The remote system found
                               fault with the format of a request. Call your support center to resolve this
                               serious error.
 <NETJOBMAX>                   Another high-speed networking process cannot be added.This is usually due
                               to an insufficient number of global buffers.
 <NETLOCK>                     A ObjectScript Lock command has been attempted to a remote computer
                               whose remote system index is greater than 31. To correct, redefine your
                               network configuration to include fewer than 32 remote computers.
 <NETRETRY>                    An operation failed at the network level in a way that could be immediately
                               retried.
 <NETSRVFAIL>                  During a transaction COMMIT or a Set, Kill, ZKill command, a client system
                               has detected that one of the servers involved in the transaction has restarted
                               while the transaction was open.
 <NETWORK DATA UPDATE          An asynchronous network error occurred and updates sent over the network
 FAILED - BLOCKNUMBER>         were lost because the remote system attempted to refer to a block that is
                               outside the bounds of the database; notify your system manager.
 <NETWORK DATA UPDATE          An asynchronous network error occurred and updates sent over the network
 FAILED - CLIENT-SERVER        were lost because a network request could not be processed due to
 MISMATCH>                     incompatibility between the client and server.




InterSystems Error Reference                                                                              269
System Error Messages


 Error Code                Description
 <NETWORK DATA UPDATE      An asynchronous network error occurred and updates sent over the network
 FAILED - CLUSTERFAILED>   were lost because a cluster member failed during global buffer lock
                           processing.
 <NETWORK DATA UPDATE      An asynchronous network error occurred and updates sent over the network
 FAILED - DATABASE>        were lost because InterSystems IRIS on the server has detected degradation
                           in this database. This is potentially a very serious system error; notify your
                           system manager.
 <NETWORK DATA UPDATE      An asynchronous network error occurred and updates sent over the network
 FAILED - DIRECTORY>       were lost because the referenced directory is not on the remote system.
 <NETWORK DATA UPDATE      An asynchronous network error occurred and updates sent over the network
 FAILED - DISKHARD>        were lost because InterSystems IRIS on the server has encountered an
                           uncorrectable disk hardware error. This may also be the result of a database
                           problem; notify your system manager.
 <NETWORK DATA UPDATE      An asynchronous network error occurred and updates sent over the network
 FAILED - FILEFULL>        were lost because InterSystems IRIS on the server has encountered a
                           <FILEFULL> error.
 <NETWORK DATA UPDATE      An asynchronous network error occurred and updates sent over the network
 FAILED - MAXSTRING>       were lost because InterSystems IRIS on the server has encountered an
                           attempt to specify or create a data string longer than the implementation
                           allows (32,767 characters).
 <NETWORK DATA UPDATE      An asynchronous network error occurred and updates sent over the network
 FAILED - NETFORMAT>       were lost because the remote system found fault with the format of a request.
                           Call your support center to resolve this serious error.
 <NETWORK DATA UPDATE      An asynchronous network error occurred and updates sent over the network
 FAILED - NETGLOREF>       were lost because the remote system found fault with the format of a request.
                           Call your support center to resolve this serious error.
 <NETWORK DATA UPDATE      An asynchronous network error occurred and updates sent over the network
 FAILED - NETVERSION>      were lost because the client and server systems are running different ECP
                           versions, which cannot accept each other's message format.
 <NETWORK DATA UPDATE      An asynchronous network error occurred and updates sent over the network
 FAILED - PROTECT>         were lost because a <PROTECT> error occurred.
 <NETWORK DATA UPDATE      An asynchronous network error occurred and updates sent over the network
 FAILED - STRINGSTACK>     were lost because a <STRINGSTACK> error occurred.
 <NETWORK DATA UPDATE      An asynchronous network error occurred and updates sent over the network
 FAILED - STRMISMATCH>     were lost because there has been an internal error handling big strings over
                           the network.
 <NETWORK DATA UPDATE      An asynchronous network error occurred and updates sent over the network
 FAILED - SUBSCRIPT>       were lost because a <SUBSCRIPT> error occurred.
 <NETWORK DATA UPDATE      An asynchronous network error occurred and updates sent over the network
 FAILED - SYSTEM>          were lost because a <SYSTEM> error occurred on the server. Either there
                           has been an attempt to do something not allowed by the operating system
                           or ECP. Or there is an error condition in InterSystems IRIS, in which case
                           you should notify your support center with as much information as possible.




270                                                                           InterSystems Error Reference
                                                                                 General System Error Messages


 Error Code                    Description
 <NETWORK DATA UPDATE          An asynchronous network error occurred and updates sent over the network
 FAILED - WIDECHAR>            were lost because a <WIDECHAR> error occurred.
 <NETWORK DATA UPDATE          An asynchronous network error occurred and updates sent over the network
 FAILED>                       were lost. The reasons for the loss are undetermined. Call your support center
                               to resolve this serious error.
 <NETWORK UNLICENSED>          The application has attempted to access a remote directory, but there is no
                               license for InterSystems IRIS networking.
 <NETWORK>                     Typically, one of the following has occurred: the network timeout has expired;
                               the local port has gone down; the node being accessed is down; or the remote
                               server connection is disabled.
 <NLS TABLE>                   There has been an attempt to perform NLS translation using data that is not
                               proper for the conversion table.
 <NO CURRENT OBJECT>           There is no current object.
 <NO MAILBOX>                  A resource needed for interprocess communication is unavailable.
 <NO SOURCE>                   A source line is missing from a routine in the routine source global.
 <NODEV>                       There has been an attempt to a write-only device, or write to a read-only
                               device, with interjob communication.
 <NOJOB>                       There has been an attempt to specify an incorrect process number in a View
                               command, or an error occurred in a Job command.
 <NOLINE>                      There has been an attempt to refer to a nonexistent routine line.
 <NORESTART>                   The application or function cannot be restarted.
 <NOROUTINE>                   There has been an attempt to refer to a nonexistent routine. For further details,
                               refer to $ZERROR.
 <NOSYS>                       There has been an attempt to make an extended or implicit reference to a
                               remote system that is not reachable in the current network configuration. The
                               remote system is not in the tables.
 <NOT PRIMARY VOLUME>          Volume sequence is not 1; the volume label disagrees with the function of
                               the volume.
 <NOTOPEN>                     The device cannot be opened, or there has been an attempt to use an
                               unopened device.
 <NULL VALUE>                  A null string appears where one is not allowed.
 <OBJECT DISPATCH>             A non-multidimensional object property was supplied to a function that can
                               only take a multidimensional object property. For further details, refer to
                               $DATA or $GET.
 <OUT OF $ZF HEAP              The $ZF heap lacks the necessary available space to support one of the
 SPACE>                        input or output parameters being passed between InterSystems IRIS and the
                               external program invoked via the $ZF function.
 <PARAMETER>                   The number of parameters passed to a labeled line by a user-written function
                               reference or a Do command exceeded the number of formal parameters
                               declared for the labeled line.




InterSystems Error Reference                                                                                 271
System Error Messages


 Error Code              Description
 <PRIVATE METHOD>        There has been an attempt to invoke a private and, therefore, unavailable
                         method.
 <PRIVATE PROPERTY>      There has been an attempt to access a private and, therefore, unavailable
                         property.
 <PROPERTY DOES NOT      The property is not part of the class of the specified object. For further details,
 EXIST>                  refer to $ZERROR.
 <PROTECT>               There has been an attempt to do something with a global (Read, Write, or
                         Kill) for which there was no authorization; or there has been an attempt to
                         use a View command which modifies memory, $View, or modifying a
                         SYS.Database property; or there has been an attempt to use a nonexistent
                         directory, possibly with extended global syntax, or some other protection
                         violation occurred.
                         A common cause of this error is attempting to write to a database that has
                         been dismounted or to which the user does not have permission to access.
                         For further details, refer to $ZERROR.
 <RANGE>                 A bit or list position is out of allowable range.
 <READ>                  The record cannot be read.
 <RECOMPILE>             A routine has been compiled under a different version of InterSystems IRIS
                         or an InterSystems legacy product. It cannot be loaded onto this system with
                         %RIMF, which transfers object code. Transfer it as source code (using %RO
                         and %RI) and then recompile it.
 <REGULAR EXPRESSION>    There has been an error in the syntax of a regular expression (an invalid or
                         ambiguous regular expression string, or a regular expression that specifies
                         an unimplemented feature).
 <REMOTE CLASS EDITED>   There has been an attempt to use an object hosted on a remote system
                         whose class has been recompiled from a remote system since the object
                         was created.
 <REMOTE CLASS           There has been an attempt to use an object hosted on a remote system
 RECOMPILED>             whose class has been recompiled from the local system since the object was
                         created.
 <REMOTE EXECUTE         A method or routine called from $System.IS.Execute() tried to read from the
 INVALID READ>           current device. This type of I/O is forbidden because it will disrupt the
                         communication channel with the client.
 <REMOTE EXECUTE         A method or routine called from $System.IS.Execute() tried to write to the
 INVALID WRITE >         current device. This type of I/O is forbidden because it will disrupt the
                         communication channel with the client.
 <RESJOB>                A process was intentionally terminated.
 <ROLLFAIL>              InterSystems IRIS has encountered an error processing a call to TRollBack.
                         This error means that InterSystems IRIS is not sure whether one or more
                         remote machines actually processed the rollback.




272                                                                            InterSystems Error Reference
                                                                                General System Error Messages


 Error Code                    Description
 <ROUTINELOAD>                 An error occurred in loading a routine. This can indicate that the routine’s
                               OBJ code (object code) is corrupt, which can possibly lead to database
                               degradation. Contact your system manager. This error can also indicate that
                               no routine buffers are available (they are being held by other processes) and
                               the timeout period (roughly 100 seconds) has expired.
 <SELECT>                      A $Select function contains no true condition.
 <SHARED MEM HEAP>             The request for shared memory cannot be satisfied. To avoid this error, the
                               system could be reconfigured with more heap space allocated.
 <SLMSPAN>                     There has been an attempt to kill a global across a subscript level mapping
                               boundary.
 <STACK>                       The argument stack is out of room or contains an incorrect type.
 <STORE>                       The process ran out of memory. If you expect the process to use a lot of
                               memory, try doubling or quadrupling the available memory for the process.
                               If the error goes away, then the process needed more memory. If the error
                               persists, then you need to figure out why it is using so much memory. Refer
                               to the $STORAGE special variable for further details.
 <STRINGSTACK>                 An expression is too long, there are too many expressions in an argument
                               for a single command, or an expression contains many very long strings.
                               Simplify the expression.
 <STRMISMATCH>                 There has been an internal error handling big strings over the network.
 <SUBSCRIPT>                   A subscript has an illegal value or a global reference is too long. For further
                               details, refer to $ZERROR. For more information on maximum length of global
                               references, see “Determining the Maximum Length of a Subscript ”.
 <SWIZZLE FAIL>                You have opened an oref and then attempted to swizzle in another related
                               object which could not be referenced. This may be due to the deletion of the
                               related object from disk or another process holding a lock on the related
                               object.
 <SYNTAX>                      There is a syntax error (an error in the formation of a language construct,
                               such as a misspelled or missing keyword).
 <SYSTEM>                      Either there has been an attempt to do something not allowed by the operating
                               system, or there is an error condition in InterSystems IRIS, in which case you
                               should notify your support center with as much information as possible.
 <TCPWRITE>                    A timeout has occurred on a TCP write operation.
 <TERMINATOR>                  There has been an attempt to read on a terminal or device in image mode
                               with no terminator and it was not a fixed-length read.
 <THROW>                       A THROW has been issued, but no CATCH expression has been found on
                               the call stack. For further details, refer to $ZERROR.
 <TOO MANY CLASSES>            This process has attempted to access too many active classes.
 <TOO MANY LONG                Too many intermediate long strings are present on the string stack.
 STRINGS>
 <TOO MANY OREFS>              This process has attempted to create too many simultaneously open objects.




InterSystems Error Reference                                                                                 273
System Error Messages


 Error Code             Description
 <TOO MANY USERS OF     Too many processes are trying to use a particular class simultaneously (more
 CLASS>                 than 65561).
 <TOO MANY USERS>       Too many users are attempting to use the system at the same time.
 <TOOMANYFILES>         InterSystems IRIS is unable to open a file because the underlying operating
                        system has run out of file descriptors.
 <TRANSACTION LEVEL>    The application has too many nested transactions pending.
 <TRANSLATE>            InterSystems IRIS has read an input value for which it has no translation
                        value. It therefore carries out the Default Action defined on the Translation
                        tab of the InterSystems IRIS NLS utility.
 <TRANSLOST>            A distributed transaction initiated by this job has been asynchronously rolled
                        back by the server.
 <UNDEFINED>            There has been a reference to an undefined variable. For further details, refer
                        to $ZERROR.
 <UNIMPLEMENTED>        There has been an attempt to use either an unimplemented function or an
                        unimplemented argument of a legitimate command or function.
 <UNIMPLEMENTED         The use of a floating-point number is not supported in this context.
 DOUBLE>
 <UNKNOWN ERROR>        An unexpected error has occurred. Call your support center to resolve this
                        serious error.
 <UNLICENSED>           The available license key does not permit the requested operation, for
                        example, trying to create an encrypted database with an entry license.
 <VALUE OUT OF RANGE>   The value is outside the maximum or minimum permissible range.
 <VOLUME IS NOT         The volume does not have the required formatting.
 FORMATTED>
 <VOLUME SET ALREADY    There has been an attempt to format an InterSystems IRIS database that is
 CREATED>               already formatted.
 <WIDE CHAR>            InterSystems IRIS read a multibyte character where a 1-byte character was
                        expected.
 <WRITE DEMON FAILED>   The write daemon is unable to continue. Call your support center to resolve
                        this serious error.
 <WRITE>                The record cannot be written.
 <WRONG NAMESPACE>      There is an attempt to load the class from a private implied namespace.
 <ZDDIF>                A DATEDIFF operation was attempted with an invalid date.
 <ZDPT2>                A DATEPART operation was attempted with an invalid date.
 <ZTRAP>                There has been an attempt to issue a ZTrap command with no argument.




274                                                                         InterSystems Error Reference
                                                                                      ISO 11756-1999 Standard Errors




4.2 ISO 11756-1999 Standard Errors
ObjectScript supports ISO 11756-1999 standard errors. These errors are returned to the $ECODE special variable.
Table 4–2: ISO 11756-1999 Standard Error Messages

 Message Text        Meaning
 M1                  Naked indicator undefined.
 M2                  Invalid $FNUMBER code string combination.
 M3                  $RANDOM argument less than 1.
 M4                  No true condition in $SELECT.
 M5                  Line reference less than 0 (zero).
 M6                  Undefined local variable.
 M7                  Undefined global variable.
 M8                  Undefined special variable.
 M9                  Divide by zero.
 M10                 Invalid pattern match range.
 M11                 No parameters passed.
 M12                 Invalid line reference (negative offset).
 M13                 Invalid line reference (line not found).
 M14                 Line level not one (1). (DO command.)
 M15                 Undefined index variable. (FOR command.)
 M16                 QUIT with an argument not allowed.
 M17                 QUIT with an argument required.
 M18                 Fixed-length READ not greater than 0 (zero).
 M19                 Cannot merge a tree or subtree into itself.
 M20                 Line must have a formal parameter list.
 M21                 Formal parameter list name duplication.
 M22                 SET or KILL to ^$GLOBAL structured system variable name (SSVN) when data in global.
 M23                 SET or KILL to ^$JOB structured system variable name (SSVN) for nonexistent job
                     number.
 M24                 Change to collation algorithm while subscripted local variables defined.
 M26                 Nonexistent environment (nonexistent namespace).
 M27                 Attempt to roll back a transaction that is not restartable.
 M28                 Mathematical function, parameter out of range.
 M29                 SET or KILL on structured system variable name (SSVN) not allowed by implementation.




InterSystems Error Reference                                                                                      275
System Error Messages


 Message Text      Meaning
 M30               Reference to global variable with different collating sequence within a collating algorithm.
 M31               Device control mnemonic expression used for a device without a mnemonic space being
                   selected.
 M32               Device control mnemonic used in user-defined mnemonic space which has no associated
                   line.
 M33               SET or KILL to ^$ROUTINE when the specified routine exists.
 M35               Device does not support mnemonic spaces. (OPEN or USE command.)
 M36               Incompatible mnemonic spaces. (OPEN or USE command.)
 M37               READ from device identified by null string.
 M38               Invalid structured system variable name (SSVN) subscript.
 M39               Invalid $NAME argument.
 M40               Call by reference in the actual parameter list in JOB command.
 M41               Invalid LOCK argument within a transaction.
 M42               Invalid QUIT within a transaction.
 M43               Invalid range value ($X or $Y). (SET command.)
 M44               Invalid command outside a transaction.
 M45               Invalid GOTO reference.
 M57               A label is defined more than once in a routine.
 M58               Too few formal parameters.




276                                                                                 InterSystems Error Reference
5
Messages Related to Productions
The following tables list the error codes associated with productions for InterSystems IRIS® data platform.




5.1 Production Errors
 Error Code                                                   Description
 ErrAdapterAlreadyConnected                                   Adapter already connected
 ErrBPCancelled                                               BusinessProcess cancelled
 ErrBPCanNotOpen                                              Can not open BusinessProcess '%1'
 ErrBPLASyncTimeoutMustBeOnSync                               ASynchronous Call timeout should be specified on
                                                              <sync> tag, ignored
 ErrBPLBadExpressionValue                                     The indirect expression cannot be evaluated"
 ErrBPLEnumeration                                            '%1' must be in enumeration '%2' for activity '%3'
 ErrBPLInvalidContextSuperclass                               The context superclass '%1' is invalid as it is NOT a
                                                              primary subclass of Ens.BP.Context
 ErrBPLInvalidLoopContext                                     '%1' cannot be used outside a containing loop
                                                              construct
 ErrBPLLabelNameNotUnique                                     Label named '%1' is not unique, branch would be
                                                              ambiguous
 ErrBPLLabelNotInScope                                        Cannot branch to label '%1' because the label is not
                                                              in scope
 ErrBPLNodeMissing                                            Missing '%1' for activity '%2'
 ErrBPLNodeValidation                                         '%1' must NOT be empty string for activity '%2'
 ErrBPLThrownFault                                            %1
 ErrBPTerminated                                              Terminating BP %1 #%2 due to error: %3
 ErrBusinessDispatchNameNotRegistered                         Business dispatch name '%1' is not registered to run
 ErrCanNotAcquireJobLock                                      Can not acquire lock for job registration global in job
                                                              '%1'



InterSystems Error Reference                                                                                       277
Messages Related to Productions


 Error Code                       Description
 ErrCanNotAcquireJobRootLock      Can not acquire lock for job registration global
 ErrCanNotAcquireLaunchLock       Can not acquire lock to run Ens.Job:Launch()
 ErrClassNotConcrete              '%1' is not a concrete class
 ErrClassNotDefined               '%1' is not a defined class
 ErrClassNotDerived               '%1' is not derived from class '%2'
 ErrConfigDisabled                Configuration item '%1' is disabled
 ErrCredentialsAlreadyExists      "Credentials with name '%1' already exists
 ErrDocImport                     %1
 ErrDTLCannotBeCompiled           The DTL contains errors which prevent it from being
                                  compiled"
 ErrDTLEnumeration                '%1' must be in enumeration '%2' for action '%3'
 ErrDTLNodeValidation             '%1' must NOT be empty string for action '%2'
 ErrDTSMultiSignature             Signature error in %1: input %2 does not match '%3'
 ErrDTSSignature                  Signature error in %1: input '%2' does not match '%3'
 ErrException                     %1logged as '%2' number %3
 ErrFailureTimeout                FailureTimeout of %1 seconds exceeded in %3; status
                                  from last attempt was %2
 ErrFTPConnectFailed              FTP: Failed to connect to server '%1'
                                  (msg='%2',code=%3)
 ErrFTPDeleteFailed               FTP: Failed Delete file '%1' (msg='%2',code=%3)
 ErrFTPDirectoryChangeFailed      FTP: Failed to change to directory '%1'
                                  (msg='%2',code=%3)
 ErrFTPGetDirectoryFailed         FTP: Failed GetDirectory (msg='%1',code=%2)
 ErrFTPGetFailed                  FTP: Failed to Get file '%1' (msg='%2',code=%3)
 ErrFTPListFailed                 FTP: Failed List for %1 (msg='%2',code=%3)
 ErrFTPLogoutFailed               FTP: Failed to log out from server '%1'
                                  (msg='%2',code=%3)
 ErrFTPModeChangeFailed           FTP: Failed to set connection to '%1' mode
                                  (msg='%2',code=%3)
 ErrFTPNameListFailed             FTP: Failed NameList for '%1' (msg='%2',code=%3)
 ErrFTPPutFailed                  FTP: Failed to Put file '%1' (msg='%2',code=%3)
 ErrFTPRenameFailed               FTP: Failed Rename file '%1' (msg='%2',code=%3)
 ErrGeneral                       %1
 ErrInConnectionLost              Lost %1 connection on %2 - detected via %3
 ErrInvalidAssign                 Cannot specify '%1' for '%2'
 ErrInvalidBPL                    Invalid BPL



278                                                             InterSystems Error Reference
                                                                      Production Errors


 Error Code                    Description
 ErrInvalidBPLDiagram          Invalid BPL Diagram: '%1'
 ErrInvalidDateTimeFormat      Invalid Date/Time format
 ErrInvalidDTL                 Invalid DTL
 ErrInvalidDurationFormat      Invalid Duration format
 ErrInvalidProduction          Invalid Production
 ErrIWay                       iWay XTE Error: %1 (%2)
 ErrIWayNoStatus               Failed to find %1 object in iWay XTE response stream
                               '%2'
 ErrJobFailed                  JOB command failed
 ErrJobNotStopped              Job '%1' failed to stop within %2 seconds
 ErrJobsNotStopped             The following jobs failed to stop within %2 seconds:
                               %1
 ErrKeyWithAppend              'key' attribute must not be specified when 'type'
                               attribute is 'append'
 ErrKeyWithClear               'key' attribute must not be specified when 'type'
                               attribute is 'clear'
 ErrKeyWithInsert              'key' attribute must be specified when 'type' attribute
                               is 'insert'
 ErrKeyWithRemove              'key' attribute must be specified when 'type' attribute
                               is 'remove'
 ErrMissingBPL                 Missing BPL XDATA block, NO EXECUTABLE CODE
                               GENERATED
 ErrNoCallerCredentials        "No Credentials property present in %1
 ErrNoClassname                -no Classname given-
 ErrNoCredentials              Unable to find Credentials for ID name '%1'
 ErrNoCredentialsSystemName    Unable to find Credentials for ID name '%1' : %2
 ErrNoElementContent           Cannot Find Element Content
 ErrNoFileFound                No File Found
 ErrNoMsgBody                  MessageBody does not exist for MessageHeader
                               #%1
 ErrNoObjFromStream            Failed to find element %1 / class %2 in Stream '%3'
 ErrNoObjFromString            Failed to find element %1 / class %2 in String '%3'
 ErrNoRawInputObj              No raw input object for '%1'
 ErrNoResponseClass            No Response Classname is assigned for Request
                               class %1
 ErrNoSQLColumns               No Columns in Query '%1'
 ErrNoSQLCursor                No open Cursor for Query '%1'



InterSystems Error Reference                                                         279
Messages Related to Productions


 Error Code                                Description
 ErrNoSQLStatement                         No Statement Executed for Query '%1'
 ErrNotImplemented                         Method %1.%2() not implemented
 ErrNotRetryable                           Non-Retryable %3 error (%2) received after %1
                                           seconds
 ErrNoWebProtocol                          Unsupported Protocol '%1'
 ErrObjectAlreadyExists                    Object ID '%1' of class '%2' already exists
 ErrOutConnectException                    Exception occured while making %2 connection %3
                                           : %1
 ErrOutConnectExpired                      %2 Connect timeout period (%1) expired for %3
 ErrOutConnectFailed                       %2 Connect failed for %3 with error %1
 ErrOutConnectionLost                      Lost %1 connection to %2 - detected via %3
 ErrOutNotConnected                        %1 connection to %2 is not open in %3
 ErrParameterInvocationInvalid             Parameter value for INVOCATION in invalid in class
                                           '%1'
 ErrProductionAlreadyRunning               Production '%1' is already running
 ErrProductionMismatchInDeferredResponse   Production name mismatch while sending deferred
                                           response
 ErrProductionNetworkedMismatch            Production '%1' is already running on a different
                                           machine in the network, a production of a different
                                           name can not be started
 ErrProductionNotQuiescent                 InterSystems IRIS can not become quiescent
 ErrProductionNotRegistered                Failed to open Production definition '%1': %2
 ErrProductionNotRunning                   No production is running
 ErrProductionNotShutdownCleanly           Production '%1' was not shutdown cleanly
 ErrProductionQuiescent                    InterSystems IRIS is in quiescent state
 ErrProductionSettingInvalid               Production setting '%2' for item '%1' is invalid
 ErrProductionSuspendedMismatch            Production '%1' was suspended, a new production of
                                           a different name can not be started
 ErrRequestNotHandled                      Request message '%1' not handled
 ErrRetryable                              Retryable %3 error (%2) received after %1 seconds
 ErrRulesetLoadFailed                      RuleSet %1 failed to load: %2
 ErrRulesetNotFound                        RuleSet %1 cannot be found
 ErrSOAPConfigClass                        SOAP service %1 cannot be invoked because its
                                           associated class must match. The class found is %2
 ErrSOAPConfigName                         SOAP class %1 cannot be invoked because there is
                                           no Ensemble service configured with this name




280                                                                    InterSystems Error Reference
                                                                               Workflow Errors


 Error Code                           Description
 ErrSOAPConfigType                    SOAP service %1 cannot be invoked because it is
                                      not a service
 ErrSQLParmCount                      Execute called with a different number of input
                                      parameters (%1) than SQLDescribeParameters()
                                      demands (%2)
 ErrSuspending                        Suspending message %1 as requested by message
                                      handler with status: %2
 ErrTCPListen                         Unable to open TCP/IP port %1 within timeout %2 -
                                      Details: %3
 ErrTCPReadBlockSize                  TCP Read(%2) with timeout period (%1) failed with :
                                      %3
 ErrTCPReadBlockSizeTimeoutExpired    TCP block size Read (%2) timeout period (%1)
                                      expired
 ErrTCPReadTimeoutExpired             TCP Read(%2) timeout period (%1) expired
                                      (charset='%3')
 ErrTCPTerminatedReadTimeoutExpired   TCP Read timeout (%1) expired waiting for terminator
                                      %2, data received ='%3'
 ErrTelnetConnectFailed               Telnet: Failed to connect to Telnet server at %1, error
                                      code %2
 ErrTelnetFindFailed                  Telnet: Failed to find %1 string(s): '%2', status %3)
 ErrTelnetLoginFailed                 Telnet: Login attempt to %1 resulted in Failure Notice
                                      '%2'
 ErrTerminate                         InterSystems IRIS system termination request
                                      detected
 ErrUnsupportedRequestType            Request type %1 is not in %2 signature '%3'
 ErrValueWithClear                    'value' attribute must not be specified when 'type'
                                      attribute is 'clear'
 ErrValueWithRemove                   'value' attribute must not be specified when 'type'
                                      attribute is 'remove'
 ErrXDataBlockNotDefined              XDATA block '%2' is not defined in class '%1'
 ErrXMLValidation                     Error in XML Validation: %1 %2




5.2 Workflow Errors
 Error Code                           Description
 ErrGeneral                           %1
 ErrNoRoleSet                         Unable to create RoleSet
 ErrNoUserSet                         Unable to create UserSet



InterSystems Error Reference                                                                  281
Messages Related to Productions


 Error Code                       Description
 ErrNoUsersFound                  No Users found to assign Task to
 ErrRoleUndefined                 Workflow Role '%1' not defined
 ErrTaskAlreadyAssigned           Task '%1' is already assigned
 ErrTaskAssignedToOther           Task '%1' is assigned to another User '%2'
 ErrTaskCreateFailure             Unable to create TaskHandler '%1'
 ErrTaskWrongType                 TaskHandler class '%1' has wrong Type
 ErrUserUndefined                 Workflow User '%1' not defined




5.3 XPATH Transformation Errors
 Error Code                       Description
 XPathDOMResult                   XPath dom result returned when single value
                                  requested
 XPathMultipleResults             XPath expression evaluation returned multiple results
 XPathNOResult                    XPath expression evaluation didn't return any results




5.4 Electronic Data Interchange (EDI) Errors
 Error Code                       Description
 ErrMapBuild1                     %1 BuildMap error: %2
 ErrMapBuilds                     %1 BuildMap errors; first: %2
 ErrMapDocType                    No %1 schema structure is defined for DocType '%2'
 ErrMapRequired                   Missing required %1 element at segment %2
 ErrMapRequiredUnion              Missing required %1 union element at segment %2
 ErrMapSeg                        Segment '%1' not mapped by schema
 ErrMapSegCount                   Missing required count (%1) for %2 segment at
                                  segment %3
 ErrMapSegUnrecog                 Unrecognized Segment %1 found after segment %2
 ErrMapWildSegUnrecog             Unrecognized '%3' Segment %1 found after segment
                                  %2
 ErrMapWildSegUnrecogAfterWild    Unrecognized '%3' Segment %1 found after '%3'
                                  segment %2
 InvalidCategoryName              Category name %1 is invalid
 InvalidDocType                   Document Type '%1' is invalid



282                                                         InterSystems Error Reference
                                                 HL7 Version 2 Message Routing Errors


 Error Code                    Description
 InvalidDocumentTypeName       Document Type Name '%1' is invalid
 InvalidSegmentTypeName        Segment name '%1' is invalid
 UnknownCategoryName           Category name %1 is unknown
 UnknownDocumentTypeName       Document Type Name '%2' not found in Document
                               Category '%1'
 UnknownSegmentTypeName        Segment name '%1' is unknown




5.5 HL7 Version 2 Message Routing Errors
 Error Code                    Description
 ErrAckSeqNum                  ACKing to MSH Sequence Number query
 ErrEndBlock                   Received unexpected EndBlock '%1' in input "%3",
                               expected '%2'
 ErrGeneral                    %1
 ErrStartBlock                 Received unexpected StartBlock '%1' in input "%3",
                               expected '%2'




5.6 X12 Standard Exchange Format (SEF) File Errors
 Error Code                    Description
 FileNotExists                 EDI Schema definition file '%1' does not exist
 NodeEnumeration               %1 value '%2' is not in enumeration %3
 NodeIdentification            for Node %1
 NodeValidation                %1 value '%2' Failed Validation for Node %3




5.7 X12 Message Routing Errors
 Error Code                    Description
 BadBINLength                  Binary '%1' segment contains invalid length value %2;
                               text:'%3'
 BinaryLeftover                Binary segment contains extra text '%1'
 CannotDetermineSchema         Schema cannot be determined, cannot validate
                               transaction




InterSystems Error Reference                                                     283
Messages Related to Productions


 Error Code                         Description
 CannotRespond                      Not enough data to Generate valid Response
 ConstraintViolation                Constraint violated: %1 for: %2
 ControlSegment                     Referenced SetSegment %1 is a Control Segment
 ControlSegmentNameMandatory        Control Segment name must NOT be empty
 ControlVersionUnsupported          This control version: %1 NOT supported; found in
                                    segment %2 at %3
 DuplicateControlNumber             Duplicate Interchange Control Number %1 for Sender
                                    %2
 DuplicateSegmentRef                Segment reference: %1 already exists
 DuplicateTSControlNumber           Duplicate Transaction Set Control Number %1
 ElementNameMandatory               Element Name cannot be empty
 EmptyElement                       Element %1 has empty value in segment %2
 ExistsElement                      Element %1 has non-empty value in segment %2
 ExpectedDelimiter                  Expected delimiter Ascii %1; in segment %2
 ExpectedSegment                    Expected %1 Segment; got segment: '%2' at %3
 FatalInterchangeError              Fatal X12 Interchange Error
 GroupControlNumberMismatch         Group control number mismatch, expected %1,
                                    received %2 at: %3
 ImplementationKeyReserved          Implementation key ISC reserved for use by
                                    InterSystems Corporation
 IncorrectFunctionalGroupCount      Number of included functional groups mismatch,
                                    expected: %1 tallied: %2 at: %3
 IncorrectSegmentCount              Number of included segments count is incorrect,
                                    expected %1, tallied: %2 at: %3
 IncorrectTransactionCount          Number of included transactions count is incorrect,
                                    expected %1, tallied: %2 at: %3
 IndexImmutable                     Cannot modify by index, current access mode is by
                                    Path
 InterchangeControlNumberMismatch   Interchange control number mismatch, expected %1,
                                    received %2 at: %3
 InvalidCode                        Element %1, code value %2 at segment: %3 is invalid
 InvalidComponentReference          Invalid component in path %1
 InvalidComponentSeparator          Invalid Component Element separator 'Ascii %1' in
                                    segment '%2' at %3
 InvalidCompositeElement            Composite Element: %1 is not valid for segment: %2
 InvalidDataSeparator               Invalid Data Element separator 'Ascii %1' in segment:
                                    at '%2' at %3




284                                                           InterSystems Error Reference
                                                             X12 Message Routing Errors


 Error Code                    Description
 InvalidExponent               Exponent Is Invalid must be signed/unsigned integer
 InvalidHSC                    Invalid Hierarchical Structure Code %1
 InvalidIndex                  Invalid syntax in property path %1, repetition index
                               MUST be 1 or Greater
 InvalidItemName               Item name %1 is invalid
 InvalidItemReference          Invalid item in path %1
 InvalidNumericValue           Invalid numeric value: %1
 InvalidPropertyPath           Property Path %1 is invalid
 InvalidRepetitionSeparator    Invalid Repetition separator 'Ascii %1' in segment '%2'
                               at %3
 InvalidSegmentItem            Item: %1 is not valid for segment: %2
 InvalidSegmentName            Segment name '%1' in segment '%2' is badly formed
                               at %3
 InvalidSegmentRef             Segment reference: %1 is invalid
 InvalidSegmentTerminator      Invalid Segment Terminator 'Ascii %1' in segment
                               '%2' at %3
 InvalidSegmentType            Segment Type %1 at %3 not allowed after segment
                               %2
 InvalidType                   Both Category and TName must be present in
                               transaction set type reference %1
 ISATruncated                  Interchange Header (ISA) segment is too short (must
                               be 106 characters); found %1:'%2' at %3
 ItemNotBinary                 Referenced Item: %1 is NOT binary
 ItemNotComposite              Referenced Item: %1 is NOT a Composite Value
 MaxIndex                      Repetition index exceeds maximum : %1
 NotUsedHasValue               Item %1 marked as not used, has non-empty value
 PathImmutable                 Cannot modify by path, current access mode is by
                               Index
 SchemaUnresolved              Cannot use path as schema is unresolved (DocType
                               Not Set or Invalid?)
 SegmentDoesNotExist           Segment ID: % does not exist in segment storage
 SegmentImmutable              Segment is immutable, cannot modify
 SegmentRuleViolated           %1 Rule %2 Violated for segment: %3
 TA1OrGroupNotSeen             At Least one TA1 Acknowledgment or Functional
                               Group MUST be included in Interchange
 TA1ValidationFailed           Validation error occured for element: %1 of TA1
                               acknowledgment at segment: %2




InterSystems Error Reference                                                       285
Messages Related to Productions


 Error Code                            Description
 TransactionImmutable                  TransactionSet is immutable, cannot modify
 TransactionSetControlNumberMismatch   TransactionSet control number mismatch, expected
                                       %1 received: %2 at: %3
 UnexpectedElement                     Too many elements in segment %1
 UnexpectedEOD                         Unexpected end of data after '%1' at %2 : %3
 UnexpectedEODBinary                   Unexpected end of data while reading binary segment
                                       after '%1'
 UnhandledTA1                          Unable to process TA1 see segment: %2
 UnknownBinarySegment                  Unrecognized Binary Segment %1
 UnknownComponentReference             Unrecognized component in path %1
 UnknownElementName                    Unrecognized element name: %1
 UnknownHSC                            Unrecognized Hierarchical Structure Code %1
 UnknownItemName                       Item name %1 is unknown
 UnknownItemReference                  Unrecognized item in path %1
 UnknownSender                         Unknown Sender
 ValidateComposite                     Cannot Validate Composite




5.8 DICOM Message Routing Errors
 Error Code                            Description
 AbstractSyntaxNotSupported            Abstract Syntax '%1' is NOT supported
 BadCalledAET                          The Called AET has an invalid value
 BadCallingAET                         The Calling AET has an invalid value
 BadCharacter                          Expected '%1' found '%2' in property reference '%3'
                                       at position '%4'
 BadTagValue                           The tag value '%1' must be 4 hexadecimal digits in
                                       property reference '%2' at position '%3'
 ContextMismatch                       Context IDs in successive message fragments don't
                                       match
 ConvertToXML                          Unable to convert DICOM file '%1' to XML
 DataElementIsNotASequence             The dataelement '%1' in property reference '%2' at
                                       position '%3' is not of type 'sequence'
 DataSetTagNotFound                    The 'data-set' element could not be found in the XML
                                       meta data
 DataValueFailsVMConstraint            Data Value for Tag '%1' failed value multiplicity
                                       constraint '%2'



286                                                                InterSystems Error Reference
                                                                DICOM Message Routing Errors


 Error Code                           Description
 DataValueFailsVRConstraint           Data Value for Tag '%1' failed value representation
                                      constraint '%2'
 FileNameForStoreOperationNotFound    The file name for the C-STORE operation could not
                                      be determined
 InvalidFileFormat                    The Dicom File appears to contain invalid data
 InvalidMessageHandler                Message Handler must be a type of
                                      EnsLib.DICOM.Util.MessageHandler
 InvalidPropertyReference             The property reference '%1' is invalid
 MaxAbstractSyntaxCountExceeded       Maximum number of Abstract Syntax items exceeded
 MaxApplicationContextCountExceeded   Maximum number of Application Context items
                                      exceeded
 MaxReceivedPDULen                    Received PDU Length of '%1' exceeds negotiated
                                      maximum of '%2'
 MaxTransferSyntaxCountExceeded       Maximum number of Transfer Syntax items exceeded
 MaxUserInfoItemsExceeded             Maximum number of User Information items exceeded
 MaxUserMaxLenCountExceeded           Maximum number of User MaxLen items exceeded
 MessageIncomplete                    Message '%1' - incomplete
 NoActiveAssociation                  No Active Association for Calling-AET '%1 and
                                      Called-AET '%2'
 NoAssociationDefinedForPeers         No AssociationContext defined for Calling-AET '%1'
                                      and Called-AET '%2'
 PDUBadLength                         PDU '%1' - Item '%2', expected length of '%3',
                                      received '%4'
 PDUBadValue                          PDU '%1' - Item '%2', expected value of '%3', received
                                      '%4'
 PeerAssociationNoLongerExists        The Peer Association no longer exists, processing
                                      cannot continue
 PeerClosedConnection                 Peer closed connection
 PeerRejectedAssociation              Peer rejected Association. Source: '%1' Reason: '%2'
 PeerRequestedAbort                   Peer requested Association Abort
 SyntaxError                          Syntax Error in property reference '%1' at position
                                      '%2'
 TimedOutWaitingForResponseFromPeer   Timed-out waiting for response from peer
 TransferSyntaxNotSupported           Transport Syntax '%1' is NOT supported
 UnableToConnectToPeer                Unable to Connect to peer '%1 : '%2'
 UnableToCreateDirectory              UnableToCreateDirectory '%1'
 UnexpectedAdapterState               Protocol Error, Adapter is in state '%1', expected state
                                      '%2'



InterSystems Error Reference                                                                287
Messages Related to Productions


 Error Code                       Description
 UnexpectedItem                   Unexpected Item type '%1' received
 UnexpectedMessage                Unexpected Message type '%1' received
 UnexpectedPDU                    Unexpected PDU type '%1' received
 UnrecognizedAbstractSyntax       The Abstract Syntax '%1' is unrecognized
 UnrecognizedCommandReceived      Unrecognized (unsupported) command '%1' received
 UnrecognizedDataElement          The Data Element '%1' is unrecognized
 UnrecognizedTag                  The Data Element Tag '%1' is unrecognized
 UnrecognizedTransferSyntax       The Transfer Syntax '%1' is unrecognized
 VDOCPropertyDoesNotExist         The property specified by property path %1 does not
                                  exist




288                                                        InterSystems Error Reference
