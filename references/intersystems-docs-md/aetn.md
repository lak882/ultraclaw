(Legacy) Using ^%ETN for
      Error Logging
                             Version 2026.1
                              2026-04-20




  InterSystems Corporation One Congress Street Boston MA 02114 www.intersystems.com
(Legacy) Using ^%ETN for Error Logging
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
        (Legacy) Using ^%ETN for Error Logging......................................................................................... 1




(Legacy) Using ^%ETN for Error Logging                                                                                                      iii
(Legacy) Using ^%ETN for Error Logging
An older style of error logging uses the ^%ETN utility, described here for reference.
The ^%ETN utility logs an exception to the application error log and then exits. You can invoke ^%ETN (or one of its
entry points) as a utility:

ObjectScript
    DO ^%ETN

Or you can set the $ZTRAP special variable equal to ^%ETN (or one of its entry points):

ObjectScript
    SET $ZTRAP="^%ETN"

You can specify ^%ETN or one of its entry points:
•    FORE^%ETN (foreground) logs an exception to the standard application error log, and then exits with a HALT. This
     invokes a rollback operation. This is the same operation as ^%ETN.
•    BACK^%ETN (background) logs an exception to the standard application error log, and then exits with a QUIT. This
     does not invoke a rollback operation.
•    LOG^%ETN logs an exception to the standard application error log, and then exits with a QUIT. This does not invoke
     a rollback operation. The exception can be a standard %Exception.SystemException, or a user-defined exception.
     To define an exception, set $ZERROR to a meaningful value prior to calling LOG^%ETN; this value will be used
     as the Error Message field in the log entry. You can also specify a user-defined exception directly into LOG^%ETN:
     DO LOG^%ETN("This is my custom exception"); this value will be used as the Error Message field in the
     log entry. If you set $ZERROR to the null string (SET $ZERROR="") LOG^%ETN logs a <LOG ENTRY> error.
     If you set $ZERROR to <INTERRUPT> (SET $ZERROR="<INTERRUPT>") LOG^%ETN logs an <INTERRUPT
     LOG> error.
     LOG^%ETN returns a %List structure with two elements: the $HOROLOG date and the Error Number.

The following example uses the recommended coding practice of immediately copying $ZERROR into a variable.
LOG^%ETN returns a %List value:

ObjectScript
    SET err=$ZERROR
    /* error handling code */
    SET rtn = $$LOG^%ETN(err)
    WRITE "logged error date: ",$LIST(rtn,1),!
    WRITE "logged error number: ",$LIST(rtn,2)

Calling LOG^%ETN or BACK^%ETN automatically increases the available process memory, does the work, and then
restores the original $ZSTORAGE value. However, if you call LOG^%ETN or BACK^%ETN following a <STORE>
error, restoring the original $ZSTORAGE value might trigger another <STORE> error. For this reason, the system retains
the increased available memory when these ^%ETN entry points are invoked for a <STORE> error.




(Legacy) Using ^%ETN for Error Logging                                                                                 1
