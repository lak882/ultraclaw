                    About TLS
                           Version 2026.1
                            2026-04-20




InterSystems Corporation One Congress Street Boston MA 02114 www.intersystems.com
About TLS
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
       About TLS............................................................................................................................................... 1
          1 InterSystems IRIS Support for TLS .............................................................................................. 1
          2 Which TLS Versions Does My Instance of InterSystems IRIS Support? ..................................... 2




About TLS                                                                                                                                                           iii
About TLS
Transport Layer Security (TLS) provides strong protection for communication between pairs of entities. It allows you to
perform authentication, data integrity protection, and data encryption. It is the successor to the secure sockets layer (SSL).
InterSystems recommends using the latest available version of TLS compatible with InterSystems IRIS.

Note:     In InterSystems documentation, the terms SSL/TLS and SSL are equivalent to TLS.

A TLS connection uses a client/server model; two entities establish a TLS connection through a TLS handshake. When
two entities complete the handshake, this means that:
•   The client has authenticated the server.
•   If the server requires client authentication, this has happened. (If the client and the server have both authenticated each
    other, this is known as mutual authentication.)
•   The client and server have agreed upon session keys. (Session keys are the keys for use with a symmetric-key algorithm
    that allow the entities to protect data during subsequent communications.)
•   Subsequent communication can be encrypted.
•   The integrity of subsequent communication can be verified.

The cipher suites of the client and server specify how these activities occur as part of the handshake or are supported for a
protected connection. Specifically, a peer’s cipher suites specify what features and algorithms it supports. The client proposes
a set of possible ciphers for use; from among those proposed, the server selects one. (If there are no common ciphers between
the client and server, the handshake fails.)
To perform the handshake, TLS typically uses public-key cryptography (though it can use other means, such as the Diffie-
Hellman protocol). With public-key cryptography, each peer (either the client or the server) has a public key and a private
key. The private key is a sensitive secret value and the public key is a widely published value; typically, the public key is
encapsulated in a certificate, which also contains identifying information about the holder, such as a name, organization,
location, issuer validity, and so on. For InterSystems IRIS, a TLS configuration (described in About Configurations)
specifies a named set of TLS-related values, including a certificate file, a private key file, and an optional set of cipher
suites.
If successful, the handshake creates session keys that are used to protect subsequent communications.
While InterSystems IRIS and applications require various interactions with TLS, the end-user typically has no such direct
interactions. For example, a browser uses TLS to establish a secure connection with a specified web site by requiring that
the site (the server, in this case) authenticate itself to the browser (which occurs unbeknownst to the browser’s user) and
the lock icon that appears in the browser is designed to indicate that TLS is protecting the connection.




1 InterSystems IRIS Support for TLS
InterSystems IRIS supports TLS to secure several types of connections:
•   From various client applications that interact with the InterSystems IRIS superserver (including ODBC and JDBC).
•   From Telnet clients that interact with the Telnet server.




About TLS                                                                                                                     1
Which TLS Versions Does My Instance of InterSystems IRIS Support?


•    For use with TCP connections where an InterSystems IRIS instance is the client or server (or an InterSystems IRIS
     instance is at each end).
•    With the Enterprise Cache Protocol (ECP). For information on using TLS with ECP, see Securing Application Server
     Connections to a Data Server with TLS.

As a server, InterSystems IRIS accepts connections and establishes the use of TLS; as a client, InterSystems IRIS is able
to connect to servers that require the use of TLS. In all cases, InterSystems IRIS uses what is called a TLS configuration,
which specifies the various characteristics of an InterSystems IRIS instance as part of an TLS connection. To learn more
about how to configure TLS, see Configuring TLS.




2 Which TLS Versions Does My Instance of InterSystems
IRIS Support?
The versions of TLS that are available for an InterSystems IRIS instance depend on several factors:
1.   Your operating system:
     •   On Windows, InterSystems IRIS is bundled with its own OpenSSL binary, which supports TLSv1.2 and TLSv1.3.
     •   On other operating systems, InterSystems IRIS uses the OpenSSL libraries made available by your vendor. These
         libraries determine the versions of the TLS protocol your operating system supports. For details, consult your
         vendor's documentation.

2.   Any further restrictions that the operating system vendor has placed on supported versions of the protocol.
3.   The minimum supported version of TLS for this version of InterSystems IRIS. For this release, it is TLS v1.0.

For containers, the supported versions of TLS depend on the operating system and version of the container host.

Important:       Because the protocols vary by operating system version, two instances of the same version of InterSystems
                 IRIS may not support the same versions of the TLS protocol.




2                                                                                                               About TLS
