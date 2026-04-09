---
allowed-tools: Bash, Read
description: Authenticate InterClaw with a Bedrock API key, storing it securely in IRIS %Wallet.
---

Authenticate InterClaw with a Bedrock API key. The key is stored securely in the IRIS %Wallet (encrypted IRISSECURITY database).

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
cd "/usr/local/InterSystems/interop-agent-orchestrator" && curl -s -X POST http://localhost/api/interclaw/api/authenticate \
  -H "Content-Type: application/json" \
  -d '{"key": "<KEY>", "region": "<REGION>"}'
```

Replace `<KEY>` with the actual key and `<REGION>` with the region (default `us-east-1`).

### Step 2: Parse the response

The API returns JSON:
```json
{
  "success": true,
  "message": "Bedrock key stored in wallet",
  "key_prefix": "ABSK...xxxx",
  "wallet_stored": true
}
```

### Step 3: Report result

- If `wallet_stored` is `true`: "Key stored securely in IRIS %Wallet (`InterClaw.BedrockKey`)."
- If `wallet_stored` is `false`: "Failed to store key in wallet." Show the error.
- If `wallet_warning` is present, mention it as a note.
- Show the `key_prefix` from the response.
- If the response contains `error`, display it.

### Step 4: Verify auth status

```bash
cd "/usr/local/InterSystems/interop-agent-orchestrator" && curl -s http://localhost/api/interclaw/api/auth-status
```

Report: authenticated status, provider, region, and storage backend (wallet vs env).

## Important

- **NEVER** display the full API key in any output — always use the masked `key_prefix`.
- The key is immediately available in the running process — no restart needed.
- Keys are stored ONLY in %Wallet — no `.env` files or other plaintext storage.
