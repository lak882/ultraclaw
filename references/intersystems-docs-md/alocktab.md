Managing the Lock Table
                            Version 2025.3
                             2026-03-23




 InterSystems Corporation One Congress Street Boston MA 02114 www.intersystems.com
Managing the Lock Table
PDF generated on 2026-03-23
InterSystems IRIS Version 2025.3
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
        Managing the Lock Table...................................................................................................................... 1
           1 Available Tools for Managing the Lock Table ............................................................................... 1
           2 Viewing Locks in the Management Portal .................................................................................... 1
           3 Removing Locks in the Management Portal ................................................................................. 3
           4 ^LOCKTAB Utility ....................................................................................................................... 3
           5 See Also ......................................................................................................................................... 4




Managing the Lock Table                                                                                                                                             iii
Managing the Lock Table
This topic discusses tools for viewing and managing the lock table in InterSystems products. (Also see Monitoring Locks.)




1 Available Tools for Managing the Lock Table
You may find it necessary to view locks and (occasionally) remove them. InterSystems provides the following tools for
this:
•     The Locks page of the Management Portal. Here you can view locks and remove locks.
•     The ^LOCKTAB utility.
•     The %SYS.LockQuery class, which lets you read lock table information.
•     The SYS.Lock class, which is available in the %SYS namespace

For information on the latter two classes, see the class reference.




2 Viewing Locks in the Management Portal
You can view all of the locks currently held or requested (waiting) system-wide using the Management Portal. From the
Management Portal, select System Operation, select Locks, then select View Locks. The View Locks window displays a list
of locks (and lock requests) in alphabetical order by directory (Directory) and within each directory in collation sequence
by lock name (Reference). Each lock is identified by its process id (Owner), displays the user name that the operating system
gave to the process when it was created (OS User Name), and has a ModeCount (lock mode and lock increment count). You
may need to use the Refresh icon to view the most current list of locks and lock requests. For further details on this interface
see Monitoring Locks.
ModeCount can indicate a held lock by a specific Owner process on a specific Reference. The following are examples of
ModeCount values for held locks:

    ModeCount                         Description
    Exclusive                         An exclusive lock, non-escalating (LOCK +^a(1))
    Shared                            A shared lock, non-escalating (LOCK +^a(1)#"S")
    Exclusive_e                       An exclusive escalating lock (LOCK +^a(1)#"E")
    Exclusive_E                       An exclusive/shared escalated lock, as a result of the number of locks on
                                      various nodes of this global exceeding the lock threshold
    Shared_e                          A shared escalating lock (LOCK +^a(1)#"SE")
    Shared_E                          A shared escalated lock, as a result of the number of locks on various nodes
                                      of this global exceeding the lock threshold




Managing the Lock Table                                                                                                       1
Viewing Locks in the Management Portal


    ModeCount                          Description
    Exclusive->Delock                  An exclusive lock in a delock state. The lock has been unlocked, but release
                                       of the lock is deferred until the end of the current transaction. This can be
                                       caused by either a standard unlock (LOCK -^a(1)) or a deferred unlock
                                       LOCK -^a(1)#"D").

    Exclusive,Shared                   Both a shared lock and an exclusive lock (applied in any order). Can also
                                       specify escalating locks; for example, Exclusive_e,Shared_e
    Exclusive/n                        An incremented exclusive lock (LOCK +^a(1) issued n times). If the lock
                                       count is 1, no count is shown (but see below). Can also specify an
                                       incrementing shared lock; for example, Shared/2.
    Exclusive/n->Delock                An incremented exclusive lock in a delock state. All of the increments of the
                                       lock have been unlocked, but release of the lock is deferred until the end of
                                       the current transaction. Within a transaction, unlocks of individual increments
                                       release those increments immediately; the lock does not go into a delock
                                       state until an unlock is issued when the lock count is 1. This ModeCount
                                       value, a incremented lock in a delock state, occurs when all prior locks are
                                       unlocked by a single operation, either by an argumentless LOCK command
                                       or a lock with no lock operation indicator (LOCK ^xyz(1)).
    Exclusive/1+1e                     Two exclusive locks, one non-escalating, one escalating. Increment counts
                                       are kept separately on these two types of exclusive locks. Can also specify
                                       shared locks; for example, Shared/1+1e.
    Exclusive/n,Shared/m               Both a shared lock and an exclusive lock, both with integer increments.

A held lock ModeCount can, of course, represent any combination of shared or exclusive, escalating or non-escalating locks
— with or without increments. An Exclusive lock or a Shared lock (escalating or non-escalating ) can be in a Delock state.
ModeCount can indicate a process waiting for a lock, such as WaitExclusiveExact. The following are ModeCount
values for waiting lock requests:

    ModeCount                        Description
    WaitSharedExact                  Waiting for a shared lock on exactly the same lock, either held or
                                     previously-requested: LOCK +^a(1,2)#"S" is waiting on lock ^a(1,2)
    WaitExclusiveExact               Waiting for an exclusive lock on exactly the same lock, either held or
                                     previously-requested: LOCK +^a(1,2) is waiting on lock ^a(1,2)
    WaitSharedParent                 Waiting for a shared lock on the parent of a held or previously-requested lock:
                                     LOCK +^a(1)#"S" is waiting on lock ^a(1,2)

    WaitExclusiveParent              Waiting for an exclusive lock on the parent of a held or previously-requested
                                     lock: LOCK +^a(1) is waiting on lock ^a(1,2)
    WaitSharedChild                  Waiting for a shared lock on the child of a held or previously-requested lock:
                                     LOCK +^a(1,2)#"S" is waiting on lock ^a(1)

    WaitExclusiveChild               Waiting for an exclusive lock on the child of a held or previously-requested
                                     lock: LOCK +^a(1,2) is waiting on lock ^a(1)


ModeCount indicates the lock (or lock request) that is blocking this lock request. This is not necessarily the same as Reference,
which specifies the currently held lock that is at the head of the lock queue on which this lock request is waiting. Reference
does not necessarily indicate the requested lock that is immediately blocking this lock request.




2                                                                                                     Managing the Lock Table
                                                                                Removing Locks in the Management Portal


ModeCount can indicate other lock status values for a specific Owner process on a specific Reference. The following are
these other ModeCount status values:

 ModeCount                                            Description
 LockPending                                          An exclusive lock is pending. This status may occur while the
                                                      server is in the process of granting the exclusive lock. You
                                                      cannot delete a lock that is in a lock pending state.
 SharePending                                         A shared lock is pending. This status may occur while the
                                                      server is in the process of granting the shared lock.You cannot
                                                      delete a lock that is in a lock pending state.
 DelockPending                                        An unlock is pending. This status may occur while the server
                                                      is in the process of unlocking a held lock. You cannot delete
                                                      a lock that is in a lock pending state.
 Lost                                                 A lock was lost due to network reset.


Select Display Owner’s Routine Information to enable the Routine column, which provides the name of the routine that the
owner process is executing, prepended with the current line number being executed within that routine.
Select Show SQL Options, and then select a namespace from the Show SQL Table Names for Namespace list, to enable the
SQL Table Name column. This column provides the name of the SQL table associated with each process in the selected
namespace. If the process is not associated with an SQL table, this column value is empty.
The View Locks window cannot be used to remove locks.




3 Removing Locks in the Management Portal
Important:      Rather than removing a lock, the best practice is to identify and then terminate the process that created the
                lock. Removing a lock can have a severe impact on the system, depending on the purpose of the lock.

To remove (delete) locks currently held on the system, go to the Management Portal, select System Operation, select Locks,
then select Manage Locks. For the desired process (Owner) click either Remove or Remove All Locks for Process.
Removing a lock releases all forms of that lock: all increment levels of the lock, all exclusive, exclusive escalating, and
shared versions of the lock. Removing a lock immediately causes the next lock waiting in that lock queue to be applied.
You can also remove locks using the SYS.Lock.DeleteOneLock() and SYS.Lock.DeleteAllLocks() methods.
Removing a lock requires WRITE permission. Lock removal is logged in the audit database (if enabled); it is not logged
in messages.log.




4 ^LOCKTAB Utility
You can also view and delete (remove) locks using the ^LOCKTAB utility in the %SYS namespace.

Important:      Rather than removing a lock, the best practice is to identify and then terminate the process that created the
                lock. Removing a lock can have a severe impact on the system, depending on the purpose of the lock.

You can execute ^LOCKTAB in either of the following forms:



Managing the Lock Table                                                                                                       3
See Also


•   DO ^LOCKTAB: allows you to view and delete locks. It provides letter code commands for deleting an individual
    lock, deleting all locks owned by a specified process, or deleting all locks on the system.
•   DO View^LOCKTAB: allows you to view locks. It does not provide options for deleting locks.

Note that these utility names are case-sensitive.
The following Terminal session example shows how ^LOCKTAB displays the current locks:

%SYS>DO ^LOCKTAB

                                        Node Name: MYCOMPUTER
                        LOCK table entries at 07:22AM 01/13/2018
                      16767056 bytes usable, 16774512 bytes available.

Entry Process          X#    S# Flg     W# Item Locked
   1) 4900              1                  ^["^^c:\intersystems\iris\mgr\"]%SYS("CSP","Daemon")
   2) 4856              1                  ^["^^c:\intersystems\iris\mgr\"]ISC.LMFMON("License Monitor")
   3) 5016              1                  ^["^^c:\intersystems\iris\mgr\"]ISC.Monitor.System
   4) 5024              1                  ^["^^c:\intersystems\iris\mgr\"]TASKMGR
   5) 6796              1                  ^["^^c:\intersystems\iris\mgr\user\"]a(1)
   6) 6796             1e                  ^["^^c:\intersystems\iris\mgr\user\"]a(1,1)
   7) 6796                    2          1 ^["^^c:\intersystems\iris\mgr\user\"]b(1)Waiters: 3120(XC)
   8) 3120              2                  ^["^^c:\intersystems\iris\mgr\user\"]c(1)
   9) 2024              1     1            ^["^^c:\intersystems\iris\mgr\user\"]d(1)

Command=>

In the ^LOCKTAB display, the X# column lists exclusive locks held, the S# column lists shared locks held. The X# or
S# number indicates the lock increment count. An “e” suffix indicates that the lock is defined as escalating. A “D” suffix
indicates that the lock is in a delock state; the lock has been unlocked, but is not available to another process until the end
of the current transaction. The W# column lists number of waiting lock requests. As shown in the above display, process
6796 holds an incremented shared lock ^b(1). Process 3120 has one lock request waiting this lock. The lock request is for
an exclusive (X) lock on a child (C) of ^b(1).
Enter a question mark (?) at the Command=> prompt to display the help for this utility. This includes further description
of how to read this display and letter code commands to delete locks (if available).

Note:      You cannot delete a lock that is in a lock pending state, as indicated by the Flg column value.

Enter Q to exit the ^LOCKTAB utility.




5 See Also
•   Locking and Concurrency Control
•   Details of Lock Requests and Deadlocks




4                                                                                                   Managing the Lock Table
