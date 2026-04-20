# Lookup Tables Reference

Lookup Tables are key-value mappings used in data transformations and business logic. They're the standard way to do code-to-code translation in HealthShare (e.g., mapping facility codes, gender codes, HL7 values).

## Storage

Lookup tables are stored in the `Ens.Util.LookupTable` global:
```
^Ens.LookupTable("TableName", "Key") = "Value"
```

## Using in DTL

The `..Lookup()` method is available in all DTL transforms:

```xml
<!-- Simple lookup -->
<assign value='..Lookup("GenderMap", source.{PID:AdministrativeSex})' property='target.Gender.Code' action='set'/>

<!-- Lookup with default value -->
<assign value='..Lookup("GenderMap", source.{PID:AdministrativeSex}, "U")' property='target.Gender.Code' action='set'/>

<!-- Reverse lookup (value → key) -->
<assign value='..LookupReverse("GenderMap", "Female")' property='target.{PID:AdministrativeSex}' action='set'/>
```

## Using in ObjectScript

```objectscript
// Direct global access
Set tValue = $Get(^Ens.LookupTable("GenderMap", "M"), "Unknown")

// Using the macro (recommended)
Set tValue = ##class(Ens.Util.FunctionSet).Lookup("GenderMap", "M", "Unknown")

// Or via SQL
// SELECT Value FROM Ens_Util.LookupTable WHERE TableName = 'GenderMap' AND KeyName = 'M'
```

## Populating Lookup Tables

### Via Management Portal

Interoperability → Lookup Tables → New/Edit. Provides a GUI for adding key-value pairs.

### Via ObjectScript

```objectscript
// Set individual values
Set ^Ens.LookupTable("GenderMap", "M") = "Male"
Set ^Ens.LookupTable("GenderMap", "F") = "Female"
Set ^Ens.LookupTable("GenderMap", "U") = "Unknown"
Set ^Ens.LookupTable("GenderMap", "O") = "Other"

// Or use the API
Do ##class(Ens.Util.LookupTable).%SetValue("GenderMap", "M", "Male")
```

### Via SQL

**IMPORTANT: Use individual INSERT statements.** Multi-row INSERT (`VALUES (...), (...), (...)`) is NOT supported and returns `SQLCODE: -25`. Each entry requires its own INSERT:

```sql
INSERT INTO Ens_Util.LookupTable (TableName, KeyName, DataValue)
VALUES ('GenderMap', 'M', 'Male')

INSERT INTO Ens_Util.LookupTable (TableName, KeyName, DataValue)
VALUES ('GenderMap', 'F', 'Female')
```

When using ``exec` tool`, run each INSERT as a separate call — ObjectScript `For` loops in single-line `--code` arguments have syntax limitations.

### Via Import (CSV)

You can import lookup tables from CSV via the Management Portal or programmatically:

```objectscript
ClassMethod ImportLookupTable(pFileName As %String, pTableName As %String) As %Status
{
    Set tFile = ##class(%File).%New(pFileName)
    Do tFile.Open("R")
    While 'tFile.AtEnd {
        Set tLine = tFile.ReadLine()
        Set tKey = $Piece(tLine, ",", 1)
        Set tValue = $Piece(tLine, ",", 2)
        Set ^Ens.LookupTable(pTableName, tKey) = tValue
    }
    Do tFile.Close()
    Return $$$OK
}
```

## Common HealthShare Lookup Tables

| Table Name | Purpose | Example Keys → Values |
|------------|---------|----------------------|
| `GenderMap` | HL7 gender codes to display | M→Male, F→Female, U→Unknown |
| `FacilityMap` | Facility code translation | FAC01→General Hospital, FAC02→Children's |
| `MaritalStatusMap` | Marital status codes | S→Single, M→Married, D→Divorced |
| `RaceMap` | Race code mapping | 2106-3→White, 2054-5→Black |
| `InsuranceMap` | Insurance plan code mapping | BC01→Blue Cross Basic |
| `HL7MessageTypes` | Accepted message types | ADT→1, ORM→1, ORU→1 |

## Querying All Keys in a Table

```objectscript
// Iterate all entries
Set tKey = ""
For {
    Set tKey = $Order(^Ens.LookupTable("GenderMap", tKey), 1, tValue)
    Quit:tKey=""
    Write tKey, " = ", tValue, !
}
```

Via SQL:
```sql
SELECT KeyName, DataValue
FROM Ens_Util.LookupTable
WHERE TableName = 'GenderMap'
ORDER BY KeyName
```

## Listing All Tables

```sql
SELECT DISTINCT TableName FROM Ens_Util.LookupTable ORDER BY TableName
```

## Exporting a Lookup Table

```objectscript
ClassMethod ExportLookupTable(pTableName As %String, pFileName As %String) As %Status
{
    Set tFile = ##class(%File).%New(pFileName)
    Do tFile.Open("WSN")
    Set tKey = ""
    For {
        Set tKey = $Order(^Ens.LookupTable(pTableName, tKey), 1, tValue)
        Quit:tKey=""
        Do tFile.WriteLine(tKey _ "," _ tValue)
    }
    Do tFile.Close()
    Return $$$OK
}
```

## Using with the Atelier API

Lookup tables can be queried and populated via the Atelier SQL endpoint:

```bash
(use the equivalent tool; see the surrounding text)
```
