Using the %Dictionary Classes
                              Version 2026.1
                               2026-04-20




   InterSystems Corporation One Congress Street Boston MA 02114 www.intersystems.com
Using the %Dictionary Classes
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
        Using the %Dictionary Classes............................................................................................................. 1
            1 Introduction to Class Definition Classes ....................................................................................... 1
            2 Browsing Class Definitions ........................................................................................................... 2
            3 Modifying Class Definitions ......................................................................................................... 3
            4 See Also ......................................................................................................................................... 3




Using the %Dictionary Classes                                                                                                                                        iii
Using the %Dictionary Classes
This topic discusses the class definition classes, a set of persistent classes that provide object and SQL access to all class
definitions.




1 Introduction to Class Definition Classes
The class definition classes provide object and SQL access to all class definitions. Using these classes, you can program-
matically examine class definitions, modify class definitions, create new classes, and even write programs that automatically
generate documentation. These classes are contained within the %Dictionary package.

Note:     There is an older set of class definition classes defined within the %Library package. These are maintained for
          compatibility with existing applications. New code should make use of the classes within the %Dictionary package.
          Make sure that you specify the correct package name when using these classes or you may inadvertently use the
          wrong class.

There are two parallel sets of class definition classes: those that represent defined classes and those that represent compiled
classes.
A defined class definition represents the definition of a specific class. It includes only information defined by that class; it
does not include information inherited from superclasses. In addition to providing information about classes in the dictionary,
these classes can be used to programmatically alter or create new class definitions.
A compiled class definition includes all of the class members that are inherited from superclasses. A compiled class definition
object can only be instantiated from a class that has been compiled. You cannot save a compiled class definition.
This page discusses defined class definitions exclusively, though the operation of the compiled class definitions is similar.
The family of class definition classes that represent defined classes includes:

 Class                                        Description
 %Dictionary.ClassDefinition                  Represents a class definition. Contains class keywords as well as
                                              collections containing class member definitions.
 %Dictionary.ForeignKeyDefinition             Represents a foreign key definition within a class.
 %Dictionary.IndexDefinition                  Represents an index definition within a class.
 %Dictionary.MethodDefinition                 Represents a method definition within a class.
 %Dictionary.ParameterDefinition              Represents a parameter definition within a class.
 %Dictionary.PropertyDefinition               Represents a property definition within a class.
 %Dictionary.QueryDefinition                  Represents a query definition within a class.
 %Dictionary.TriggerDefinition                Represents an SQL trigger definition within a class.




Using the %Dictionary Classes                                                                                                 1
Browsing Class Definitions


Important:      To reiterate, the content of an uncompiled class definition (as an instance of the %Dictionary.ClassDefinition)
                is not necessarily the same as the content of a compiled class definition (as an instance of
                %Dictionary.CompiledClass). The %Dictionary.ClassDefinition class provides an API to inspect or change
                the definition of the class — it does not ever represent the compiled class with inheritance resolved;
                %Dictionary.CompiledClass, on the other hand, does represent the compiled class with inheritance resolved.

                For example, if you are trying to determine the value of a particular keyword in a class definition, use the
                keywordnameIsDefined() method from %Dictionary.ClassDefinition (such as OdbcTypeIsDefined() or
                ServerOnlyIsDefined()). If this boolean method returns false, then the keyword is not explicitly defined
                for the class. If you check the value of the keyword for the class definition, it will be the default value.
                However, after compilation (which includes inheritance resolution), the value of the keyword is determined
                by inheritance and may differ from the value as defined.




2 Browsing Class Definitions
You can use the SQL pages of the Management Portal to browse the class definition classes.
Similarly, you can programmatically browse through the class definitions using the same techniques you would use to
browse any other kind of data: you can use dynamic SQL and you can instantiate persistent objects that represent specific
class definitions.
For example, from within an InterSystems IRIS® data platform process, you can get a list of all classes defined within the
dictionary for the current namespace by using the %Dictionary.ClassDefinition:Summary() query:

ObjectScript
    set stmt=##class(%SQL.Statement).%New()
    set status = stmt.%PrepareClassQuery("%Dictionary.ClassDefinition","Summary")
    if $$$ISERR(status) {write "%Prepare failed:" do $SYSTEM.Status.DisplayError(status) quit}

  set rset=stmt.%Execute()
  if (rset.%SQLCODE '= 0) {write "%Execute failed:", !, "SQLCODE ", rset.%SQLCODE, ": ", rset.%Message
 quit}

  while rset.%Next()
  {
    write rset.%Get("Name"),!
  }
  if (rset.%SQLCODE < 0) {write "%Next failed:", !, "SQLCODE ", rset.%SQLCODE, ": ", rset.%Message
quit}

This sample method will write the names of all the classes visible in the current namespace (including classes in the system
library). You can filter out unwanted classes using the various columns returned by the
%Dictionary.ClassDefinition:Summary() query.
You can get detailed information about a specific class definition by opening a %Dictionary.ClassDefinition object for the
class and observing its properties. The ID used to store %Dictionary.ClassDefinition objects is the class name:

ObjectScript
 Set cdef = ##class(%Dictionary.ClassDefinition).%OpenId("Sample.Person")
 Write cdef.Name,!

 // get list of properties
 Set count = cdef.Properties.Count()
 For i = 1:1:count {
     Write cdef.Properties.GetAt(i).Name,!
 }

Note that you must fully qualify class names with their package name or the call to %OpenId() will fail.




2                                                                                            Using the %Dictionary Classes
                                                                                                  Modifying Class Definitions




3 Modifying Class Definitions
You can modify an existing class definition by opening a %Dictionary.ClassDefinition object, making the desired changes,
and saving it using the %Save() method.
You can create a new class by creating a new %Dictionary.ClassDefinition object, filling in its properties and saving it. When
you create %Dictionary.ClassDefinition object, you must pass the name of the class via the %New() command. When you
want to add a member to the class (such as a property or method), you must create the corresponding definition class
(passing its %New() command a string containing "class_name.member_name") and add the object to the appropriate
collection within the %Dictionary.ClassDefinition object.
For example:

ObjectScript
    Set cdef = ##class(%Dictionary.ClassDefinition).%New("MyApp.MyClass")
    If $SYSTEM.Status.IsError(cdef) {
        Do $system.Status.DecomposeStatus(%objlasterror,.Err)
        Write !, Err(Err)
    }
    Set cdef.Super = "%Persistent,%Populate"

    // add a Name property
    Set pdef = ##class(%Dictionary.PropertyDefinition).%New("MyClass:Name")
    If $SYSTEM.Status.IsError(pdef) {
        Do $system.Status.DecomposeStatus(%objlasterror,.Err)
        Write !,Err(Err)
    }

    Do cdef.Properties.Insert(pdef)

    Set pdef.Type="%String"

    // save the class definition object
    Do cdef.%Save()




4 See Also
•     Defining Classes
•     Top Level Class Syntax and Keywords




Using the %Dictionary Classes                                                                                               3
