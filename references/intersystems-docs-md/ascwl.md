    Secure Custom Web
    Application Logins
                           Version 2026.1
                            2026-04-20




InterSystems Corporation One Congress Street Boston MA 02114 www.intersystems.com
Secure Custom Web Application Logins
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
        Secure Custom Web Application Logins.............................................................................................. 1
            1 About Creating a Custom Zen Login Page .................................................................................... 1
            2 See Also ......................................................................................................................................... 1




Secure Custom Web Application Logins                                                                                                                                 iii
Secure Custom Web Application Logins
In addition to REST applications, InterSystems products support CSP applications and Zen applications; Zen applications
are legacy only. When creating custom login pages for CSP and Zen applications, it is important that you follow recommended
protocols. These protocols provide greater security and minimize incompatibilities on upgrades to new products or versions.




1 About Creating a Custom Zen Login Page
When creating a custom Zen login page, use the <loginForm> component as described in Controlling Access to Applications
in Developing Zen Applications.

Important:      When creating a custom login page, you must use the <loginForm> component. Other approaches for
                creating login pages in Zen applications can cause problems of various kinds.
                If you have written custom login pages that do not use the <loginForm> component and you apply any
                changes from InterSystems that upgrade or secure your instance, your login pages may fail without error
                messages. For example, users may attempt to log in with valid usernames and passwords, but their logins
                will fail without any visible cause. This situation may indicate that you need to change your custom login
                to use the required approach.




2 See Also
•   Introduction to CSP-based Web Applications




Secure Custom Web Application Logins                                                                                     1
