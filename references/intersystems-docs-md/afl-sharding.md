InterSystems IRIS Demo:
Deploy a Sharded Cluster
                            Version 2026.1
                             2026-04-20




 InterSystems Corporation One Congress Street Boston MA 02114 www.intersystems.com
InterSystems IRIS Demo: Deploy a Sharded Cluster
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
        InterSystems IRIS Demo: Deploy a Sharded Cluster......................................................................... 1
            1 How Can Sharding Help You? ....................................................................................................... 1
            2 How Does Sharding Work? ........................................................................................................... 1
            3 More Sharded Cluster Options ...................................................................................................... 2
            4 Learn More About Sharding .......................................................................................................... 3


        List of Figures
             Figure 1: A Basic Sharded Cluster ................................................................................................... 2




InterSystems IRIS Demo: Deploy a Sharded Cluster                                                                                                       iii
InterSystems IRIS Demo: Deploy a
Sharded Cluster
This page introduces you to the InterSystems IRIS® data platform sharding feature and its use in a sharded cluster to hori-
zontally scale InterSystems IRIS for data volume.




1 How Can Sharding Help You?
We are all managing more data than ever before and being asked to do more with it — and the response times demanded
are growing ever shorter. Each business-specific workload presents different challenges to the data platform on which it
operates — and as workloads grow, those challenges become even more acute.
InterSystems IRIS includes a comprehensive set of capabilities to scale your applications, which can be applied alone or
in combination, depending on the nature of your workload and the specific performance challenges it faces. One of these,
sharding, partitions both data and its associated cache across a number of servers, providing flexible, inexpensive performance
scaling for queries and data ingestion while maximizing infrastructure value through highly efficient resource utilization.
An InterSystems IRIS sharded cluster can provide significant performance benefits for a wide variety of applications, but
especially for those with workloads that include one or more of the following:
•   High-volume or high-speed data ingestion, or a combination.
•   Relatively large data sets, queries that return large amounts of data, or both.
•   Complex queries that do large amounts of data processing, such as those that scan a lot of data on disk or involve sig-
    nificant compute work.

Each of these factors on its own influences the potential gain from sharding, but the benefit may be enhanced where they
combine. For example, a combination of all three factors — large amounts of data ingested quickly, large data sets, and
complex queries that retrieve and process a lot of data — makes many of today’s analytic workloads very good candidates
for sharding.
Note that these characteristics all have to do with data; the primary function of InterSystems IRIS sharding is to scale for
data volume. But a sharded cluster can also include features that scale for user volume, when workloads involving some
or all of these data-related factors also experience a very high query volume from large numbers of users. And sharding
can be combined with vertical scaling as well. With InterSystems IRIS, you can create just the right overall scaling solution
for your workload’s performance challenges.




2 How Does Sharding Work?
The heart of the sharded architecture is the partitioning of data and its associated cache across a number of systems. A
sharded cluster partitions large database tables horizontally — that is, by row — across multiple InterSystems IRIS instances,
called data nodes, while allowing applications to access these tables through any one of those instances. Each data node’s
share of the cluster’s sharded data is called a shard. This architecture provides three advantages:
•   Parallel processing



InterSystems IRIS Demo: Deploy a Sharded Cluster                                                                             1
More Sharded Cluster Options


    Queries are run in parallel on the data nodes, with the results combined, and returned to the application as full query
    results, significantly enhancing execution speed in many cases.
•   Partitioned caching
    Each data node has its own dedicated cache, rather than a single instance’s cache serving the entire data set, which
    greatly reduces the risk of overflowing the cache and forcing performance-degrading disk reads.
•   Parallel loading
    Data can be loaded onto the data nodes in parallel, reducing cache and disk contention between the ingestion workload
    and the query workload and improving the performance of both.

A federated software component called the sharding manager keeps track of which data is on which data nodes and directs
queries accordingly. Nonsharded data is stored on the first data node configured, called data node 1 (which also stores code
and metadata). From the perspective of the application SQL, the distinction between sharded and nonsharded tables is
totally transparent.
                                             Figure 1: A Basic Sharded Cluster



                                                           application connections...




                                                                    table
                                                             master namespace...
                        sharding manager




                                                                                                    shard master data server




                       shard data servers




                            data shard            data shard                       data shard                       data shard
                        shard namespace...    shard namespace...               shard namespace...               shard namespace...




3 More Sharded Cluster Options
Additional options for a sharded cluster include the following:
•   You can add data nodes at any time and rebalance existing sharded data across the expanded set of data nodes. Rebal-
    ancing cannot coincide with queries and updates, and so can take place only when the sharded cluster is offline and
    no other sharded operations are possible. (See Add Nodes and Rebalance Data.)




2                                                                                       InterSystems IRIS Demo: Deploy a Sharded Cluster
                                                                                               Learn More About Sharding


•   To add high availability for the data on the cluster, you can deploy data nodes as mirrored failover pairs. (See Mirror
    for High Availability.)
•   For advanced use cases in which extremely low query latencies are required, potentially at odds with a constant influx
    of data, compute nodes can be added to provide a transparent caching layer for servicing queries. When a cluster
    includes compute nodes, read-only queries are automatically executed in parallel on the compute nodes, rather than
    on the data nodes; all write operations (insert, update, delete, and DDL operations) continue to be executed on the data
    nodes. This division of labor separates the query and data ingestion workloads while maintaining the advantages of
    parallel processing and distributed caching, improving the performance of both. (See Deploy Compute Nodes.)




4 Learn More About Sharding
To learn more about sharding, see
•   Introduction to Sharding (online course)
•   Sharding Basics (online course)
•   Deploying InterSystems IRIS in Containers and the Cloud (learning path)
•   Scalability Guide




InterSystems IRIS Demo: Deploy a Sharded Cluster                                                                          3
