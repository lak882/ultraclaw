    Using the Amazon
   CloudWatch Adapter
                           Version 2026.1
                            2026-04-20




InterSystems Corporation One Congress Street Boston MA 02114 www.intersystems.com
Using the Amazon CloudWatch Adapter
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
       Using the Amazon CloudWatch Adapter............................................................................................. 1
           1 Outbound Adapter Details ............................................................................................................. 1
           2 Built-in Business Operation .......................................................................................................... 1
           3 General AWS Settings ................................................................................................................... 2




Using the Amazon CloudWatch Adapter                                                                                                                       iii
Using the Amazon CloudWatch Adapter
Amazon CloudWatch is an AWS product that allows you to monitor an application by collecting data for specific metrics.
Once you have created a metric in CloudWatch, you can use a business operation in an InterSystems interoperability pro-
duction to update CloudWatch with values for that metric. InterSystems provides a built-in business operation that uses
the CloudWatch outbound adapter to interact with CloudWatch. You also have the option of creating a custom business
operation that uses this adapter. If you are new to interoperability productions, including the use of business operations and
outbound adapters, see Introduction to Interoperability Productions.

Important:         Currently, only the PutMetricData method of the CloudWatch adapter is fully functional. Do not attempt
                   to use the PutMetricAlarm method to work with CloudWatch alarms as this method may change in
                   future releases.




1 Outbound Adapter Details
The class of the CloudWatch outbound adapter is EnsLib.AmazonCloudWatch.OutboundAdapter. Within this class, the
PutMetricData method contains the logic that updates CloudWatch with a value for a specific metric. The signature of
this method is:
Method PutMetricData(namespace As %String, metricName As %String,
           metricValue As %Numeric, metricUnit As %String,
           dims As %String = "") As %Status

Where:
•    namespace is the metric's CloudWatch namespace.

•    metricName is the name of the metric.

•    metricValue is the datapoint being sent to CloudWatch for the specified metric.

•    metricUnit is the unit of measure for the metric value. This unit of measure is required. For a list of valid units, see
     the Amazon CloudWatch JavaDoc reference.
•    dims is a JSON array with name/value pairs that represent the metric's dimensions. For example,
     [{"Name":"StorageType","Value":"StandardStorage"},{"Name":"BucketName","Value":"test-bazco}]




2 Built-in Business Operation
Rather than developing a custom business operation that uses the outbound adapter, you can save time and effort by adding
the EnsLib.AmazonCloudWatch.MetricDataOperation business operation to the interoperability production. Once added,
the production can send a pre-built request that contains the metric data to the business operation. The class of this pre-built
request is EnsLib.AmazonCloudWatch.PutMetricDataRequest.
The business operation contains properties that correspond to the adapter parameters that identify the CloudWatch metric,
for example, name and namespace. Once you have added the business operation to the production, you can set these prop-
erties using the corresponding Management Portal settings. For instructions on adding a business operation to a production,
see Adding Business Hosts.



Using the Amazon CloudWatch Adapter                                                                                           1
General AWS Settings




3 General AWS Settings
The CloudWatch outbound adapter extends a common adapter class that includes general AWS properties. When you add
a business operation that uses the outbound adapter to a production, these AWS properties can be set using the AWS settings
in the Management Portal.
CredentialsFile — If blank, Amazon uses the default credential provider chain to obtain the credentials needed to access
CloudWatch. If you prefer to use an AWS credential file, enter its filepath.
Region — Identifies the AWS region that you want to access. For a list of CloudWatch regions, see Amazon Regions,
Availability Zones, and Local Zones




2                                                                                 Using the Amazon CloudWatch Adapter
