---
allowed-tools: Bash, Read
description: Remove the InterClaw Bedrock API key credential.
---

Remove the stored Bedrock API key from `Ens.Config.Credentials` and clear the running environment.

Usage: /deauthenticate

## Execution

### Step 1: Check current auth status

```bash
curl -s http://localhost/api/interclaw/api/auth-status
```

If `authenticated` is `false`, tell the user: "No API key is currently configured." and stop.

### Step 2: Call the deauthenticate API

```bash
curl -s -X DELETE http://localhost/api/interclaw/api/deauthenticate
```

### Step 3: Parse the response

The API returns JSON:
```json
{
  "success": true,
  "credential_removed": true,
  "message": "API key removed"
}
```

### Step 4: Report result

- If `credential_removed` is `true`: "Credential `InterClaw.Bedrock` removed. API key cleared from this process."
- If `credential_removed` is `false`: "No stored credential found. Environment variables cleared for this process."
- If the response contains `error`, display it.

### Step 5: Verify

```bash
curl -s http://localhost/api/interclaw/api/auth-status
```

Confirm `authenticated` is now `false`.
