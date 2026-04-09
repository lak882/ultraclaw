Create or update JSON adapter classes from a JSON payload structure and wire them into a production.

Usage: /json-adapter <description>

Given a JSON structure (inline or from a file), generates or updates:
- `%JSON.Adaptor` message classes (serial sub-objects + top-level Ens.Request)
- A custom HTTP service to receive and deserialize JSON
- A file operation to write received JSON to disk
- A production wiring them together

Steps:

1. **Analyze JSON and plan classes.** Map JSON to ObjectScript types:

   | JSON | ObjectScript |
   |------|-------------|
   | String | `%String(MAXLEN = 200)` |
   | Number (int) | `%Integer` |
   | Number (decimal) | `%Numeric` |
   | Boolean | `%Boolean` |
   | Nested object | Serial class (`%SerialObject + %JSON.Adaptor + %XML.Adaptor`) |
   | Array of objects | `list Of <Serial>` |
   | Array of strings | `list Of %String` |

   **All classes must extend `%XML.Adaptor`** in addition to `%JSON.Adaptor` — without it, IRIS cannot display message contents in Visual Trace (ERROR #6249). Property names match JSON field names (camelCase). Use `%JSONFIELDNAME` for snake_case fields.

2. **Generate all classes** (parallel agents for messages, service, operation). Push leaf classes first.
   - HTTP service: `EnableStandardRequests=1` (Host), `PoolSize=0`, `OneWay=1`
   - Create FileDrop directories for file operation
   - Generate production class, push, compile, start

3. **Test** with `send_json.py`. Verify HTTP 202, check `MessageBodyClassName` and event log.
