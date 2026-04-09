---
name: clipboard
description: Save and retrieve chatbot outputs to/from persistent clipboard
---

Manage persistent clipboard storage for chatbot outputs.

## Usage

When the user says `/clipboard pull`, read the latest clipboard entry:

```bash
python3 ~/.claude/skills/clipboard/scripts/clipboard.py pull
```

When the user asks to "copy" or "save to clipboard", save content:

```bash
python3 ~/.claude/skills/clipboard/scripts/clipboard.py save "<content>"
```

For multi-line content, use heredoc:

```bash
python3 ~/.claude/skills/clipboard/scripts/clipboard.py save <<'EOF'
<multi-line content>
EOF
```

## Commands

- `/clipboard pull` - Read latest clipboard
- `/clipboard list` - Show recent clipboard entries
- `/clipboard get <timestamp>` - Get specific entry

## Trigger Phrases

Save to clipboard when user says:
- "copy this"
- "save to clipboard"
- "put this in clipboard"
- "clipboard that"
- "save that for me"

Pull from clipboard when user says:
- `/clipboard pull`
- "what's in my clipboard"
- "show me the latest clipboard"
- "pull from clipboard"

## Example Flow

**User**: "Copy that JSON config to clipboard"

**You execute**:
```bash
python3 ~/.claude/skills/clipboard/scripts/clipboard.py save '{"host":"localhost","port":80}'
```

**You say**: "✓ Saved to clipboard"

---

Later...

**User**: "/clipboard pull"

**You execute**:
```bash
python3 ~/.claude/skills/clipboard/scripts/clipboard.py pull
```

**You say**: "Here's your clipboard content:" and show the output.

## Important Notes

1. **Always use the script** - Don't manually read/write clipboard files
2. **Deterministic pull** - Always use `clipboard.py pull` to get latest
3. **Preserve formatting** - Use heredoc for code/configs to preserve newlines
4. **Timestamp format** - YYYYMMDD_HHMMSS (e.g., 20260407_233015)
5. **File location** - All clipboards in `~/clipboard/`

## Advanced Usage

List recent entries:
```bash
python3 ~/.claude/skills/clipboard/scripts/clipboard.py list --count 10
```

Get specific entry:
```bash
python3 ~/.claude/skills/clipboard/scripts/clipboard.py get 20260407_233015
```

Clear old entries:
```bash
python3 ~/.claude/skills/clipboard/scripts/clipboard.py clear --older-than 30
```
