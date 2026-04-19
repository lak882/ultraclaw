---
allowed-tools: Bash, Read
description: Authenticate InterClaw with a Bedrock API key, storing it securely in Ens.Config.Credentials.
---

Authenticate InterClaw with a Bedrock API key. The key is stored securely in `Ens.Config.Credentials` as the "InterClaw.Bedrock" credential (password field is masked in the Management Portal).

Usage: /authenticate <BEDROCK_KEY> [--region <region>]

## Argument parsing

Parse "$ARGUMENTS":
- First argument: the Bedrock API key (must start with `ABSK`)
- Optional `--region <region>` flag (default: `us-east-1`)

If no key is provided, tell the user:
> Usage: `/authenticate <BEDROCK_KEY>` — provide your AWS Bedrock bearer token (starts with ABSK).

## Validation

1. The key must start with `ABSK`. If not, say: "Invalid key format. Bedrock keys start with ABSK."
2. Never display the full key. Always mask it as `ABSK...last4` in all output.

## Execution

### Step 1: Call the authenticate API

```bash
curl -s -X POST http://localhost/api/interclaw/api/authenticate \
  -H "Content-Type: application/json" \
  -d '{"key": "<KEY>", "region": "<REGION>"}'
```

Replace `<KEY>` with the actual key and `<REGION>` with the region (default `us-east-1`).

### Step 2: Parse the response

The API returns JSON:
```json
{
  "success": true,
  "message": "Bedrock key stored in credential InterClaw.Bedrock",
  "key_prefix": "ABSK...xxxx",
  "credential_stored": true
}
```

### Step 3: Report result

- If `credential_stored` is `true`: "Key stored in credential `InterClaw.Bedrock`."
- If `credential_stored` is `false`: "Failed to store key." Show the error.
- If `credential_warning` is present, mention it as a note.
- Show the `key_prefix` from the response.
- If the response contains `error`, display it.

### Step 4: Verify auth status

```bash
curl -s http://localhost/api/interclaw/api/auth-status
```

Report: authenticated status, provider, region, and storage backend (credential vs env).

## Important

- **NEVER** display the full API key in any output — always use the masked `key_prefix`.
- The key is immediately available in the running process — no restart needed.
- Keys are stored in `Ens.Config.Credentials` — no `.env` files or other plaintext storage.
