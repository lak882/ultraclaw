# Anthropic Messages API — Tool `input_schema` Reference

**Captured:** 2026-04-21T22:06:51Z
**Source:** derived from `references/openclaw/src/agents/anthropic-transport-stream.ts` and `references/openclaw/src/agents/pi-tool-definition-adapter.ts`
**Applies to:** `POST https://api.anthropic.com/v1/messages` with `anthropic-version: 2023-06-01`

## Where it lives in the request

Tools are declared at the top level of the request body under `tools[]`. Each element carries a name, a description, and an `input_schema` describing the arguments the model may send back in a `tool_use` block.

```json
{
  "model": "claude-opus-4-7",
  "system": "...",
  "messages": [ ... ],
  "tools": [
    {
      "name": "exec",
      "description": "Run a shell command ...",
      "input_schema": { ... JSON Schema ... }
    }
  ]
}
```

| Path | Type | Required | Meaning |
|------|------|----------|---------|
| `tools` | array | no | Omit for turns that should not use tools |
| `tools[i].name` | string | yes | Wire name. Stable across turns. Regex: `^[a-zA-Z0-9_-]{1,64}$` |
| `tools[i].description` | string | yes (effectively) | Prompt text the model reads. This is the authoritative "what does it do" source; there is no output schema. |
| `tools[i].input_schema` | object | yes | JSON Schema describing the arguments object. Root MUST be `type: "object"`. |

## Shape of `input_schema`

`input_schema` is a subset of JSON Schema Draft 2020-12. The root is always an object; `properties` and `required` are the only fields Anthropic strictly requires, but standard JSON Schema keywords are honored.

```json
{
  "type": "object",
  "properties": {
    "command":   { "type": "string",  "description": "Shell command to run." },
    "workdir":   { "type": "string",  "description": "Absolute working directory." },
    "timeout":   { "type": "number",  "description": "Timeout in ms.", "minimum": 0 },
    "background":{ "type": "boolean", "description": "Return immediately." },
    "env": {
      "type": "object",
      "description": "Extra environment variables.",
      "additionalProperties": { "type": "string" }
    },
    "action": {
      "type": "string",
      "enum": ["status", "list", "add", "update", "remove", "run"],
      "description": "Which sub-operation to perform."
    }
  },
  "required": ["command"]
}
```

### Root (always required)

| Key | Value | Notes |
|-----|-------|-------|
| `type` | `"object"` | Must be `object`. Not `array`, not a union. |
| `properties` | object of `<name, schema>` | The argument set the tool accepts. |
| `required` | array of strings | Subset of `properties` keys. Missing/empty is allowed but strongly discouraged. |
| `additionalProperties` | `true` \| `false` \| schema | Defaults to `true` in JSON Schema; set `false` to reject stray keys. Some providers tighten this automatically; others do not. |
| `description` | string | Optional; usually put on each property instead. |

### Property schema shapes

| `type` | Required sub-keys | Common optional sub-keys |
|--------|-------------------|--------------------------|
| `string` | — | `enum`, `description`, `minLength`, `maxLength`, `pattern` |
| `number` \| `integer` | — | `minimum`, `maximum`, `multipleOf`, `description` |
| `boolean` | — | `description` |
| `object` | `properties` (for structured data) | `required`, `additionalProperties`, `description` |
| `array` | `items` (a schema) | `minItems`, `maxItems`, `description` |

### Nested objects

Objects may nest as deep as your data demands. Each nested level repeats the `{ type: "object", properties, required? }` shape.

```json
{
  "type": "object",
  "properties": {
    "job": {
      "type": "object",
      "properties": {
        "schedule": {
          "type": "object",
          "properties": {
            "kind": { "type": "string", "enum": ["at", "every", "cron"] },
            "at":   { "type": "string", "description": "ISO-8601 instant" },
            "everyMs": { "type": "number" },
            "expr": { "type": "string", "description": "Cron expression" }
          },
          "required": ["kind"]
        },
        "payload": {
          "type": "object",
          "properties": {
            "kind": { "type": "string", "enum": ["systemEvent", "agentTurn"] },
            "text": { "type": "string" },
            "message": { "type": "string" }
          },
          "required": ["kind"]
        }
      },
      "required": ["schedule", "payload"]
    }
  },
  "required": ["job"]
}
```

### Arrays

```json
{
  "type": "array",
  "items": {
    "type": "object",
    "properties": {
      "id":   { "type": "string" },
      "qty":  { "type": "integer", "minimum": 1 }
    },
    "required": ["id", "qty"]
  },
  "minItems": 1
}
```

## Guardrails (openclaw conventions, broadly applicable)

These rules come from `references/openclaw/src/agents/tools/CLAUDE.md` and are driven by real-world provider quirks. They apply anywhere you want the same schema to work across Anthropic, OpenAI, Vertex, Bedrock, XAI, etc.

| Rule | Reason |
|------|--------|
| Root must be `type: "object"` | Providers reject non-object roots. |
| No `Type.Union` / `anyOf` / `oneOf` / `allOf` anywhere | OpenAI, Vertex, and XAI reject compound schemas. Use a flat schema with a `kind`/`action` discriminator and validate per-action at runtime. |
| Prefer `{ type:"string", enum:[...] }` over unions | Encodes discriminated choices without `anyOf`. |
| Use `Type.Optional(...)` instead of `X \| null` | Nullable unions are another `anyOf` trap. |
| Avoid raw `format` keyword | Some validators treat it as reserved and reject the schema. |
| Keep `description` on every non-trivial property | There is no output schema; descriptions are how the model learns expected input and output shapes. |
| Set `additionalProperties: false` when you know the set | Prevents the model from inventing keys. Some providers (XAI) strip `minLength` / `maxLength` too — don't rely on string length constraints for correctness. |

## How openclaw's Typebox maps onto this

Authors write Typebox; the wire form above is generated at request time by a one-line converter.

```ts
// references/openclaw/src/agents/anthropic-transport-stream.ts:394
return tools.map(tool => ({
  name: tool.name,
  description: tool.description,
  input_schema: {
    type: "object",
    properties: tool.parameters.properties || {},
    required:   tool.parameters.required   || [],
  },
}));
```

Because Typebox emits JSON-Schema-shaped objects, the mapping is a field rename (`parameters` -> `input_schema`), not a translation. The "no `Type.Union`" rule exists precisely so this pass-through stays valid.

## What the model sends back

The tool schema only governs the **input** side. When Claude decides to use a tool, it emits a content block:

```json
{ "type": "tool_use", "id": "toolu_01ABC...", "name": "exec", "input": { "command": "ls -la" } }
```

`input` matches the `input_schema`. Your handler returns a result that gets shipped back as a **user** message:

```json
{
  "role": "user",
  "content": [
    {
      "type": "tool_result",
      "tool_use_id": "toolu_01ABC...",
      "content": [ { "type": "text", "text": "..." } ],
      "is_error": false
    }
  ]
}
```

There is no declared output schema on the tool — the model interprets `tool_result.content` freely, relying on the `description` you wrote for the tool.

## Cross-provider field mapping (for reference)

| Provider | List field | Name field | Description field | Input schema field |
|----------|-----------|-----------|-------------------|--------------------|
| Anthropic Messages | `tools[]` | `name` | `description` | `input_schema` |
| OpenAI Chat/Responses | `tools[]` | `function.name` | `function.description` | `function.parameters` |
| Bedrock Converse | `toolConfig.tools[].toolSpec` | `name` | `description` | `inputSchema.json` |
| Vertex / Gemini | `tools[0].function_declarations[]` | `name` | `description` | `parameters` |
| Ollama (OpenAI-compatible) | `tools[]` | `function.name` | `function.description` | `function.parameters` |

The schema body itself is JSON Schema in every case; only the envelope differs.

## Minimal working example

```json
{
  "model": "claude-opus-4-7",
  "max_tokens": 1024,
  "messages": [
    { "role": "user", "content": "What is the weather in Chicago?" }
  ],
  "tools": [
    {
      "name": "get_weather",
      "description": "Get the current weather for a location.",
      "input_schema": {
        "type": "object",
        "properties": {
          "location": {
            "type": "string",
            "description": "City name or 'City, State' pair."
          },
          "units": {
            "type": "string",
            "enum": ["metric", "imperial"],
            "description": "Temperature units to use."
          }
        },
        "required": ["location"]
      }
    }
  ]
}
```
