Guide the user through a structured interview to build a requirements document for `/poc`.

Usage: /interview [package-name]

This is a multi-turn conversational command. Ask questions one section at a time, confirm answers, then generate a Markdown requirements document compatible with `/poc`.

---

## Interview Flow

Walk through the sections below **in order**. Ask one section at a time. After the user answers, summarize what you captured and move to the next section. Provide examples and sensible defaults at each step to keep things moving.

If the user provides a package name as an argument, use it. Otherwise, ask for it during the interview.

---

### Section 1: Project Overview

Ask:
- **What is the project/client name?** (e.g., "El Rio Health", "St. Clair Hospital")
- **One-sentence summary of the integration goal?** (e.g., "Route vaccine administration messages from EMR to the state immunization registry")
- **How many builds/use cases?** Explain that each "build" is an independent interface flow (inbound -> process -> outbound). Most POCs have 1-3 builds.

Example prompt:
> Let's start with the basics. What is the client or project name, and can you give me a one-sentence summary of what this integration needs to do? Also, how many separate interface builds are we looking at? (Most POCs have 1 to 3 builds of increasing complexity.)

---

### Section 2: For Each Build (repeat for each build)

For each build, ask the following sub-questions. Number each build (Build 1, Build 2, etc.) and give it a short descriptive title.

#### 2a: Systems and Direction
- **What is the source system?** (name, e.g., "Epic EMR", "Lab System", "PACS")
- **What is the target system?** (name, e.g., "State Registry", "Rad Ltd", "Epic")
- **What is the direction?** Inbound to Health Connect, then outbound. Clarify if there are multiple targets (fan-out).

#### 2b: Message Types
- **What HL7 message type(s)?** Provide options with brief descriptions:
  - `ADT` — Admit/Discharge/Transfer (patient movements)
  - `ORM` — Orders (lab, imaging, pharmacy)
  - `ORU` — Results (lab results, imaging reports)
  - `VXU` — Vaccine administration
  - `MDM` — Medical documents
  - `SIU` — Scheduling
  - `RDS` — Pharmacy dispense
  - `DFT` — Financial transactions
  - Other / custom
- **What HL7 version?** (default: 2.5.1, other common: 2.3, 2.3.1, 2.4)
- **What specific event types?** Follow up based on message type:
  - ADT: A01 (admit), A02 (transfer), A03 (discharge), A04 (register), A08 (update), A34 (merge), A40 (merge), other?
  - ORM: O01 (general order)
  - ORU: R01 (result)
  - VXU: V04 (vaccine record)
  - Ask only for the relevant message type.
- **Any custom Z-segments?** If yes, ask for segment name and field definitions.

#### 2c: Transport Protocols
- **Inbound transport?** Options:
  - `TCP/MLLP` — standard HL7 over TCP with MLLP framing (most common)
  - `HTTP/HTTPS` — HL7 over HTTP POST
  - `File` — pick up files from a directory (simplest for POC)
  - `SFTP` — secure file transfer polling
  - `FTP` — file transfer polling
  - `REST API` — JSON/XML over HTTP
  - Default for POC: **File** (easiest to test)
- **Outbound transport?** Same options. Default for POC: **File**

#### 2d: Transformations (DTL)
- **What field mappings or transformations are needed?** Ask specifically:
  - Any fields that need to be **copied from one location to another**?
  - Any fields that need **string manipulation**? (replace characters, truncate, concatenate)
  - Any fields that need **code translation via lookup table**? (e.g., facility code -> facility name)
  - Any fields that need **conditional logic**? (e.g., "if MSH-3.1 = X, set ORC-1 = Y")
  - Any fields to **remove or clear**?
  - Any **date/time format conversions**?
  - Should unmapped fields **pass through** (copy) or be **excluded** (new)?

If the user is unsure, suggest: "For a POC, a common pattern is to copy all fields and selectively modify a few. We can start with that."

#### 2e: Lookup Tables
- **Any code translation tables needed?** Examples:
  - Facility code -> SIIS client ID
  - Provider ID -> provider name
  - Department code -> department name
  - Insurance plan code -> plan name
- For each table, ask for:
  - Table name
  - A few sample key-value pairs (at least 3-4)

#### 2f: Routing Logic
- **Any message filtering?** (e.g., "only send ORM messages, drop ORU messages")
- **Any field-based routing?** (e.g., "route to different targets based on MSH-3.1")
- **Fan-out?** (send to multiple targets)
- **Any messages that should be explicitly dropped/filtered out?**

#### 2g: Naming
- **Suggested names for components:** Offer defaults based on what the user described:
  - Business Service: `From_<SourceSystem>` (e.g., `From_VaccineSource`)
  - Business Operation: `To_<TargetSystem>` (e.g., `To_ASIIS`)
  - Router: `From_<SourceSystem>_Router`
  - Let the user override if they have preferences.

---

### Section 3: Package and Deployment

Ask:
- **Package name?** (e.g., `ElRio.POC`, `StClair.POC`). If provided as argument, confirm it.
- **Server name?** (from `config/servers.json` — list available servers if possible)
- **Namespace?** (e.g., `HSLIB`, `CLAUDE`, `USER`)

---

### Section 4: Special Requirements (Optional)

Ask if any of these apply:
- **Error handling** — custom error routing, alert notifications?
- **Acknowledgments** — need to send ACKs back to source?
- **File archival** — archive processed files?
- **Logging** — enhanced logging or audit requirements?
- **Security** — authentication on HTTP endpoints, SSL/TLS?
- **Other** — anything else not covered above?

Say: "These are all optional for a POC. If none apply, just say 'none' and we'll move on."

---

## Document Generation

After all sections are complete, generate a Markdown document matching the format that `/poc` expects. Use the El Rio POC document as a structural template.

### Document Structure

```markdown
# <Client/Project Name>

# Integration Engine
Proof of Concept

<Today's Date>

# Overview of the Integration Engine Proof of Concept

<1-2 paragraph overview based on Section 1 answers>

# Proof of Concept Scope and Deliverables

<Summary paragraph listing all builds>

## Build N: <Build Title>

<Description paragraph explaining the flow>

## Steps to Execute Build

- We will create an inbound <transport> HL7 Business Service (**<ServiceName>**) configured with <transport details>.
- We will create a <transport> HL7 Business Operation (**<OperationName>**) configured with <transport details>.
- We will create a Business Process (**<RouterName>**) to handle routing and transformation logic.
- We will create a Business Rule with the following specifications:
  - <routing conditions>
- We will create a Lookup Table (**<TableName>**) with the following mappings:
  - <key> -> <value>
  - ...
- We will build a Data Transformation with the following specifications:
  - <field mapping 1>
  - <field mapping 2>
  - ...

## The Measure of Success

- We will show the Visual Trace of a test HL7 <message type> message as it flows from the <transport> Business Service (**<ServiceName>**), through the transformation and routing logic, and finally out to the <transport> Business Operation (**<OperationName>**).
- We will show the Business Rule that <routing description>.
- We will show the Data Transformation that <transformation description>.
- We will show the inbound and outbound adapter settings including:
  - <inbound adapter details>
  - <outbound adapter details>

(repeat for each build)

# Assumptions

- This Proof-of-Concept demonstration will be built by InterSystems.
- Sample messages will be created to demonstrate and test the PoC.
- Any code authored for this project is not warranted to be of production quality.
```

### Key Rules for Document Generation

1. Use the **exact component names** the user confirmed in Section 2g.
2. Spell out **every transformation step** explicitly (field path, operation, lookup table name).
3. Include **lookup table mappings** inline in the "Steps to Execute Build" section.
4. Specify **transport protocols** clearly (TCP/MLLP, HTTP, SFTP, File) in both the description and steps.
5. Specify the **HL7 version and message type** (e.g., "2.5.1 VXU_V04") so `/poc` knows which schema to pull.
6. If the user said "File" for transport, write "File-based" in the steps (not TCP/MLLP).

---

## Save and Handoff

1. Save the generated document to `poc-examples/md/<package-name-lowercase>-requirements.md`
   - Example: `poc-examples/md/elrio-poc-requirements.md`
2. Display the full document for user review.
3. Ask: **"Does this look right? Want me to make any changes before we proceed?"**
4. After confirmation, ask: **"Ready to build? I can run `/poc poc-examples/md/<filename>.md <PackageName> <Namespace>` to start building."**
5. If the user says yes, output the `/poc` command for them to run:
   ```
   /poc poc-examples/md/<filename>.md <PackageName> <Namespace>
   ```
