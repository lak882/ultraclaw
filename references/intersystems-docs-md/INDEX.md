# InterSystems Documentation Index

This directory contains converted markdown documentation from InterSystems IRIS. Use this index to quickly find relevant documentation.

## Core Language & Development

| File | Topic | Use For |
|------|-------|---------|
| `objectscript.md` | ObjectScript Language Guide | ObjectScript syntax, commands, functions |
| `objectscript-reference.md` | ObjectScript Reference | Complete language reference |
| `objects.md` | Using Objects | Object-oriented programming in ObjectScript |
| `object-oriented-programming.md` | OOP Concepts | Classes, inheritance, methods, properties |
| `dictionary-classes.md` | %Dictionary Classes | Programmatic class definition and introspection |
| `classes-page.md` | Class Explorer | Working with the classes page in Management Portal |
| `globals-page.md` | Globals Explorer | Working with globals in Management Portal |
| `globals-sizing.md` | Global Storage Analysis | Analyzing global storage usage |

## SQL & Data

| File | Topic | Use For |
|------|-------|---------|
| `sql.md` | SQL Usage Guide | SQL queries, tables, views |
| `sql-reference.md` | SQL Reference | Complete SQL syntax reference |
| `sql-optimization.md` | SQL Performance | Query optimization overview |
| `sql-optimization-practices.md` | SQL Best Practices | Performance tuning techniques |
| `sql-processing.md` | SQL Internals | How IRIS processes SQL statements |
| `data-management.md` | Data Management | Data storage, databases, namespaces |

## Interoperability & Integration

| File | Topic | Use For |
|------|-------|---------|
| `interoperability-guide.md` | Getting Started | Introduction to productions and interoperability |
| `business-process-language.md` | BPL | Visual business processes |
| `data-transformations.md` | DTL | Data transformation language |
| `hl7.md` | HL7 Interface | HL7 v2 messaging |
| `messaging.md` | Message Routing | Message handling and routing |
| `rest-services.md` | REST APIs | REST web services |
| `soap-services.md` | SOAP Services | SOAP web services |
| `business-services.md` | Business Services | Inbound adapters and services |
| `production-configuration.md` | Production Setup | Configuring and managing productions |

## System Administration

| File | Topic | Use For |
|------|-------|---------|
| `server-migration.md` | Migration | Upgrading and migrating IRIS instances |
| `deployment.md` | Deployment | Deploying applications and code |
| `docker.md` | Containers | Running IRIS in Docker |
| `cloud-deployment.md` | Cloud | Cloud deployment strategies |
| `high-availability.md` | HA/DR | High availability and disaster recovery |
| `configuration-merge.md` | Config Management | Configuration merge files (CPF) |
| `package-manager.md` | IPM | InterSystems Package Manager |

## Security

| File | Topic | Use For |
|------|-------|---------|
| `authentication.md` | Authentication | User authentication methods |
| `authorization.md` | Authorization | Access control and permissions |
| `auditing.md` | Audit Logs | Security auditing and logging |
| `encryption.md` | Encryption | Data encryption at rest and in transit |

## Development Tools

| File | Topic | Use For |
|------|-------|---------|
| `ide-setup.md` | IDE Configuration | Setting up development environment |
| `code-scanning.md` | Code Quality | Scanning for deprecated code |
| `populate-utility.md` | Test Data | Generating test data with %Populate |
| `business-intelligence-toolkit.md` | BI Tools | Business intelligence features |
| `adaptive-analytics.md` | Analytics | Adaptive analytics capabilities |

## Quick Reference

### When Building Interoperability Solutions:
1. Start with `interoperability-guide.md` for architecture
2. Use `hl7.md` for HL7 message handling
3. Reference `data-transformations.md` for DTL syntax
4. Check `business-process-language.md` for BPL patterns
5. Consult `messaging.md` for routing logic

### When Writing ObjectScript:
1. Check `objectscript.md` for syntax
2. Use `objectscript-reference.md` for function details
3. Reference `objects.md` for class patterns
4. Consult `sql.md` for embedded SQL

### When Optimizing Performance:
1. Start with `sql-optimization.md` for overview
2. Apply `sql-optimization-practices.md` techniques
3. Understand internals via `sql-processing.md`
4. Analyze storage with `globals-sizing.md`

### When Deploying:
1. Review `deployment.md` for process
2. Check `server-migration.md` for upgrades
3. Use `docker.md` for containers
4. Reference `configuration-merge.md` for automation

## Search Tips

- For **HL7 schemas**: See `hl7.md`
- For **DTL syntax**: See `data-transformations.md`
- For **BPL activities**: See `business-process-language.md`
- For **Routing rules**: See `messaging.md`
- For **REST APIs**: See `rest-services.md`
- For **SQL optimization**: See `sql-optimization-practices.md`
- For **Class definition**: See `dictionary-classes.md`
- For **Global operations**: See `objectscript.md`
- For **Production configuration**: See `production-configuration.md`
- For **Security setup**: See `authentication.md` and `authorization.md`

## File Naming Convention

Files are named descriptively to match their content:
- Core language docs: `objectscript.md`, `sql.md`, `objects.md`
- Interoperability: `hl7.md`, `data-transformations.md`, `business-process-language.md`
- Admin/deployment: `deployment.md`, `docker.md`, `server-migration.md`
- Lowercase with hyphens for multi-word topics

All original PDF files are preserved in `../intersystems-docs/` with their original codes (e.g., `GCOS.pdf`, `EGDV.pdf`).
