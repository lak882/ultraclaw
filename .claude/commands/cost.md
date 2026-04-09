Show token cost for the command that was just run.

Usage: /cost

## Frontend Auto-Display

The chatbot frontend automatically renders a cost banner at the top of every assistant message using real token counts from the API's usage events. The banner includes the InterSystems icon, input/output tokens, duration, and estimated cost.

Format: `[ISC icon] · Xm Ys · $Z.ZZ · ~Xk tokens in · ~Yk tokens out`

If the response starts with "finished", the banner becomes:
`[ISC icon] · finished · Xm Ys · $Z.ZZ · ~Xk tokens in · ~Yk tokens out`

This is handled entirely by the frontend — no special output from Claude is needed for the banner.

## When invoked explicitly as /cost

Output a single line with the estimated cost for the preceding command:

```
Xm Ys · $Z.ZZ · ~Xk tokens in · ~Yk tokens out
```

Rules:
- Estimate input and output tokens for the preceding command
- Round token counts to nearest 1k
- Use pricing from `config/orchestrator.json` `cost.pricing` (default: $3/MTok input, $15/MTok output)
- Output ONLY that one line. Nothing else.
