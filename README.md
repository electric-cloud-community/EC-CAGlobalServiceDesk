EC-CAGlobalServiceDesk
======================

Plugin version 0.0.1.0

Revised on 15, 2020

* * *

Contents
========

*   [Overview](#overview)
*   [Plugin Configuration](#CreateConfiguration)
*   [Plugin Procedures](#procedures)

*   [Copy Change Request](#CopyChangeRequest)
*   [Submit for Approval Change Request](#SubmitforApprovalChangeRequest)
*   [Approve Change Order Request](#ApproveChangeOrderRequest)

*   [Release Notes](#releaseNotes)

Overview
========

This plugin integrates with CA Global Service Desk.

Plugin Configurations
=====================

Plugin configurations are sets of parameters that apply across some or all of the plugin procedures. They reduce repetition of common values, create predefined parameter sets for end users, and securely store credentials where needed. Each configuration is given a unique name that is entered in designated parameters on procedures that use them.  
  

### Creating Plugin Configurations

To create plugin configurations in CloudBees Flow, do these steps:

*   Go to **Administration** > **Plugins** to open the Plugin Manager.
*   Find the EC-CAGlobalServiceDesk-0.0.1.0 row.
*   Click **Configure** to open the Configurations page.
*   Click **Create Configuration** as per the description of parameters below.
Configuration Parameters

| Parameter | Description |
| --- | --- |
| **Configuration Name** | Unique name for the configuration |
| Description | Configuration description |
| **REST Endpoint** | REST API Endpoint |
| **Bearer Token** | Service Account Password to connect to GSD. |
| **Service Account Name** | The Service Account Name |
| **Auth Token URL** | Auth Token URL |
| HTTP Proxy | A proxy server URL that should be used for connections. |
| Proxy Authorization | Username and password for proxy. |
| Check Connection? | If checked, a connection endpoint and credentials will be tested before save. The configuration will not be saved if the test fails. |
| Debug Level | This option sets debug level for logs. If info is selected, only summary information will be shown, for debug, there will be some debug information and for trace the whole requests and responses will be shown. |

Plugin Procedures
=================

**IMPORTANT** Note that the names of Required parameters are marked in **_bold italics_** in the parameter description table for each procedure.

Copy Change Request
-------------------

This procedure copy change request

### Copy Change Request Parameters

| Parameter | Description |
| --- | --- |
| **Configuration Name** | Previously defined configuration for the plugin |
| **Source Change Order** | Source Change Order# |
| **Audit User ID** | Audit User ID |
| **Schedule Start Date** | ScheduleStartDate |
| **Schedule Start Time** | ScheduleStartTime |
| **Schedule Duration** | ScheduleDuration |
| **Verification StartDate** | VerificationStartDate |
| **Verification Start Time** | VerificationStartTime |
| **Verification Duration** | VerificationDuration |
| **Backout Duration** | BackoutDuration |
| **Impact** | Impact |
| **Risk** | Risk |
| **Change Type** | Changetype |
| **CAB** | CAB |
| **Require Privilege Access** | RequirePrivilegeAccess |
| **Outside SchMaint Window** | OutsideSchMaintWindow |
| **ITSANFR Cmpltd** | ITSANFRCmpltd |
| **NFRMP Ref Num** | NFRMPRefNum |
| **Clarity PrjIdList** | ClarityPrjIdList |
| **Optional AttrVals** | OptionalAttrVals |
| **Config Items List** | ConfigItemsList |
| **PC Records** | PCRecords |

#### Output Parameters

| Parameter | Description |
| --- | --- |
| referenceNumber | the new reference number that generated. |
| restResult | Rest Call Result |

Submit for Approval Change Request
----------------------------------

This procedure Submit for Approval change request

### Submit for Approval Change Request Parameters

| Parameter | Description |
| --- | --- |
| **Configuration Name** | Previously defined configuration for the plugin |
| **Reference Number** | Change Request Number# |
| **Submitted For Approval By** | Submitted For Approval By |

#### Output Parameters

| Parameter | Description |
| --- | --- |
| restResult | Rest Call Result |

Approve Change Order Request
----------------------------

This procedure Approve change order request

### Approve Change Order Request Parameters

| Parameter | Description |
| --- | --- |
| **Configuration Name** | Previously defined configuration for the plugin |
| **Reference Number** | Change Request Number# |
| **Approved By** | Approved By |
| **Approver Group** | Approver Group |
| **Approval Status** | Approval Status |
| **Comment** | Comment |
| **CAB Review** | CAB Review |

#### Output Parameters

| Parameter | Description |
| --- | --- |
| restResult | Rest Call Result |

Release Notes
=============

### EC-CAGlobalServiceDesk 0.0.1

*   Introduced EC-CAGlobalServiceDesk plugin.