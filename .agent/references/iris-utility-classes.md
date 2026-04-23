# IRIS Utility Classes Reference

Common utility classes for interoperability development. All are native IRIS classes unless noted.

## Production Management

### Ens.Director

| Method | Purpose | Example |
|--------|---------|---------|
| `GetProductionStatus(.name, .state)` | Query running production | Returns name and state (Running/Stopped/Suspended) |
| `StartProduction(name)` | Start a production | Returns %Status |
| `StopProduction(timeout, force)` | Stop running production | `timeout=30`, `force=1` to kill jobs |
| `RestartProduction(name, timeout, force)` | Stop then start | Combines stop + start |
| `UpdateProduction()` | Reload production config | Call after XDATA changes |

### Ens.Config.Production

| Method | Purpose | Example |
|--------|---------|---------|
| `%OpenId(name)` | Open production instance | For reading XDATA Items |

## HL7 Message Handling

### EnsLib.HL7.Message

| Method | Purpose | Example |
|--------|---------|---------|
| `ImportFromString(text)` | Parse HL7 text into message object | Returns %Status |
| `OutputToString(.output)` | Serialize message to HL7 text | Populates output variable |
| `GetValueAt(path)` | Read field value | `msg.GetValueAt("PID:3.1")` |
| `SetValueAt(value, path)` | Write field value | `msg.SetValueAt("12345", "PID:3.1")` |

### EnsLib.HL7.Schema

| Method | Purpose | Example |
|--------|---------|---------|
| `GetCategoryList(.list)` | List schema categories | `2.5.1`, `2.7`, custom categories |
| `GetMessageStructure(category, type, .structure)` | Get message structure | Returns segment/group tree |

## Lookup Tables

### Ens.Util.LookupTable

| Method | Purpose | Example |
|--------|---------|---------|
| `%ValueExists(table, key)` | Check if key exists | Returns 1/0 |
| `%GetValue(table, key)` | Get value for key | Returns data value |
| `%SetValue(table, key, value)` | Set key-value pair | Persists immediately |
| `%ClearTable(table)` | Delete all entries in table | Wipes the table |
| `%Import(stream, table)` | Import CSV lookup table | Stream with key,value rows |
| `%Export(table, .stream)` | Export table to CSV | Populates stream |

## Event Log and Tracing

### Ens_Util.Log (table)

Query via SQL, not method calls.

**Type field is integer:**
- `2` = Error
- `3` = Warning  
- `4` = Info
- `6` = Alert

**Common query:**
```sql
SELECT TOP 25 TimeLogged, Type, ConfigName, Text 
FROM Ens_Util.Log 
WHERE Type IN (2,3,6) 
ORDER BY ID DESC
```

### Ens.MessageHeader (table)

Query message routing history via SQL.

**Common query:**
```sql
SELECT ID, TimeCreated, SourceConfigName, TargetConfigName, SessionId
FROM Ens.MessageHeader 
WHERE SessionId = ?
ORDER BY ID
```

## Class Compilation and Introspection

### $System.OBJ

| Method | Purpose | Example |
|--------|---------|---------|
| `Compile(name, flags)` | Compile class | `flags="ck-d"` for compile, keep source, display |
| `Delete(name)` | Delete class | Returns %Status |
| `Load(stream, flags)` | Load class from stream | Import class definition |
| `GetPackageList(.list, package)` | List classes in package | Populates list array |

### %Dictionary.ClassDefinition (table)

Query class metadata via SQL.

**Common query:**
```sql
SELECT Name FROM %Dictionary.ClassDefinition 
WHERE Name %STARTSWITH 'Pkg.' 
ORDER BY Name
```

## File Operations

### %File

| Method | Purpose | Example |
|--------|---------|---------|
| `Exists(path)` | Check if file exists | Returns 1/0 |
| `CreateDirectory(path)` | Create directory | Single level |
| `CreateDirectoryChain(path)` | Create nested directories | Recursive mkdir |
| `Delete(path)` | Delete file | Returns 1/0 |
| `GetDirectory(path)` | Extract directory from path | Returns parent directory |

## Status Handling

### $System.Status

| Method | Purpose | Example |
|--------|---------|---------|
| `GetErrorText(sc)` | Convert %Status to text | Returns error message |
| `IsOK(sc)` | Check if %Status is success | Returns 1/0 |
| `IsError(sc)` | Check if %Status is error | Returns 1/0 |
