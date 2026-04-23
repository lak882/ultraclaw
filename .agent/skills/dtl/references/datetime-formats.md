# ConvertDateTime Format Specifiers

Reference for `..ConvertDateTime(value, inputFormat, outputFormat)` — the DTL utility function that converts between datetime string formats.

Docs: https://docs.intersystems.com/irislatest/csp/docbook/DocBook.UI.Page.cls?KEY=ECONFIG_settings_time_stamp_spec

## Format Specifiers

### Date Components

| Code | Description | Example |
|------|-------------|---------|
| `%Y` | 4-digit year | `2026` |
| `%y` | 2-digit year | `26` |
| `%m` | 2-digit month (01–12) | `04` |
| `%q` | 1- or 2-digit month, no leading zero (1–12) | `4` |
| `%b` | Abbreviated month name | `Apr` |
| `%B` | Full month name | `April` |
| `%d` | 2-digit day of month (01–31) | `01` |
| `%e` | 1- or 2-digit day, no leading zero (1–31) | `1` |
| `%j` | Day of year (001–366) | `091` |
| `%a` | Abbreviated weekday name | `Wed` |
| `%A` | Full weekday name | `Wednesday` |

### Time Components

| Code | Description | Example |
|------|-------------|---------|
| `%H` | 2-digit hour, 24h (00–23) | `14` |
| `%k` | 1- or 2-digit hour, 24h, no leading zero (0–23) | `9` |
| `%I` | 2-digit hour, 12h (01–12) | `02` |
| `%l` | 1- or 2-digit hour, 12h, no leading zero (1–12) | `2` |
| `%M` | 2-digit minute (00–59) | `30` |
| `%S` | 2-digit second (00–59) | `45` |
| `%N` | Fractional seconds (variable precision) | `123` |
| `%p` | AM/PM (uppercase) | `PM` |
| `%P` | am/pm (lowercase) | `pm` |

### Special / Internal Formats

| Code | Description | Example |
|------|-------------|---------|
| `%Q` | `$HOROLOG` format (days,seconds) | `66810,52245` |
| `%J` | Julian date number | `2460767` |
| `%F` | ISO date shorthand (`%Y-%m-%d`) | `2026-04-01` |
| `%T` | ISO time shorthand (`%H:%M:%S`) | `14:30:45` |

### Wildcards / Input-Only Tokens

These are used **only in the input format** to skip/ignore characters during parsing:

| Code | Description |
|------|-------------|
| `%i` | Ignore next character in input |
| `%?` | Match any single character |
| `%*` | Match any sequence of characters until the next token |

### Literal Characters

| Code | Description |
|------|-------------|
| `%%` | Literal `%` sign |
| `%n` | Newline |
| `%t` | Tab |

Any character not preceded by `%` is treated as a literal (e.g., `-`, `/`, `:`, `T`, spaces).

## Common HL7 / Healthcare Format Strings

| Format String | Description | Example Output |
|---------------|-------------|----------------|
| `%Y%m%d` | HL7 date (compact) | `20260401` |
| `%Y%m%d%H%M%S` | HL7 datetime (compact) | `20260401143045` |
| `%Y%m%d%H%M%S%N` | HL7 datetime with fractional seconds | `20260401143045123` |
| `%Y-%m-%d` | ISO 8601 date | `2026-04-01` |
| `%Y-%m-%dT%H:%M:%S` | ISO 8601 datetime | `2026-04-01T14:30:45` |
| `%m/%d/%Y` | US date | `04/01/2026` |
| `%d/%m/%Y` | European date | `01/04/2026` |
| `%m-%d-%Y` | US date with dashes | `04-01-2026` |
| `%b %d, %Y` | Human-readable date | `Apr 01, 2026` |
| `%B %e, %Y` | Full month date | `April 1, 2026` |
| `%H:%M:%S` | 24h time | `14:30:45` |
| `%I:%M:%S %p` | 12h time with AM/PM | `02:30:45 PM` |
| `%Q` | $HOROLOG internal | `66810,52245` |

## DTL Usage Examples

### HL7 compact date → ISO date
```xml
<assign value='..ConvertDateTime(source.{PID:DateTimeofBirth}, "%Y%m%d", "%Y-%m-%d")' property='target.BirthDate' action='set'/>
```

### HL7 datetime → ISO datetime
```xml
<assign value='..ConvertDateTime(source.{PID:DateTimeofBirth}, "%Y%m%d%H%M%S", "%Y-%m-%dT%H:%M:%S")' property='target.BirthDateTime' action='set'/>
```

### HL7 date → US display format
```xml
<assign value='..ConvertDateTime(source.{PID:DateTimeofBirth}, "%Y%m%d", "%m/%d/%Y")' property='target.DisplayDate' action='set'/>
```

### US date → HL7 compact date
```xml
<assign value='..ConvertDateTime(source.{PID:DateTimeofBirth}, "%m/%d/%Y", "%Y%m%d")' property='target.{PID:DateTimeofBirth}' action='set'/>
```

### HL7 datetime → $HOROLOG (for ObjectScript date math)
```xml
<assign value='..ConvertDateTime(source.{MSH:DateTimeOfMessage}, "%Y%m%d%H%M%S", "%Q")' property='context.HorologValue' action='set'/>
```

### $HOROLOG → HL7 datetime
```xml
<assign value='..ConvertDateTime(context.HorologValue, "%Q", "%Y%m%d%H%M%S")' property='target.{MSH:DateTimeOfMessage}' action='set'/>
```

### ISO datetime → HL7 compact (stripping punctuation)
```xml
<assign value='..ConvertDateTime(source.Timestamp, "%Y-%m-%dT%H:%M:%S", "%Y%m%d%H%M%S")' property='target.{MSH:DateTimeOfMessage}' action='set'/>
```

### Extract just the date portion from a datetime
```xml
<assign value='..ConvertDateTime(source.{PID:DateTimeofBirth}, "%Y%m%d%H%M%S", "%Y%m%d")' property='target.DateOnly' action='set'/>
```

### Handle variable-length HL7 timestamps
HL7 timestamps can be 8, 12, or 14+ characters. Use `%*` in the input format to ignore trailing characters:
```xml
<!-- Accept YYYYMMDD, YYYYMMDDHHMM, or YYYYMMDDHHMMSS — output just the date -->
<assign value='..ConvertDateTime(source.{PID:DateTimeofBirth}, "%Y%m%d%*", "%Y-%m-%d")' property='target.BirthDate' action='set'/>
```

### Human-readable date for display
```xml
<assign value='..ConvertDateTime(source.{PID:DateTimeofBirth}, "%Y%m%d", "%B %e, %Y")' property='target.DisplayDate' action='set'/>
<!-- Output: "April 1, 2026" -->
```
