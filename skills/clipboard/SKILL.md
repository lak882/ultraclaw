# clipboard

Persistent clipboard storage for chatbot outputs and code snippets.

## Overview

Saves content to timestamped markdown files in `~/clipboard/` for easy retrieval. Each clipboard entry is a separate file with format: `YYYYMMDD_HHMMSS_clipboard.md`

## Usage

### Save to clipboard
When the user says "copy this" or "save to clipboard", save the content:
```bash
python3 ~/.claude/skills/clipboard/scripts/clipboard.py save "<content>"
```

Or with heredoc for multi-line content:
```bash
python3 ~/.claude/skills/clipboard/scripts/clipboard.py save <<'EOF'
<multi-line content>
EOF
```

### Pull latest clipboard
```bash
/clipboard pull
# or
python3 ~/.claude/skills/clipboard/scripts/clipboard.py pull
```

### List recent clipboards
```bash
python3 ~/.claude/skills/clipboard/scripts/clipboard.py list
python3 ~/.claude/skills/clipboard/scripts/clipboard.py list --count 10
```

### Get specific clipboard
```bash
python3 ~/.claude/skills/clipboard/scripts/clipboard.py get 20260407_233000
```

## Workflow

1. **User says**: "Copy that JSON config to clipboard"
2. **Assistant saves**: `python3 ~/.claude/skills/clipboard/scripts/clipboard.py save '<json>'`
3. **User says**: "/clipboard pull"
4. **Assistant reads**: Latest file from `~/clipboard/`

## File Format

Each clipboard file:
```markdown
# Clipboard Entry
Saved: 2026-04-07 23:30:00

---

<content here>
```

## Common Use Cases

- Copy JSON configurations from chatbot
- Save code snippets from responses
- Store command outputs
- Save connection strings
- Preserve formatted text

## Script Reference

All operations use `~/.claude/skills/clipboard/scripts/clipboard.py`:

- `save <content>` - Save content to new clipboard file
- `save --stdin` - Read content from stdin
- `pull` - Output latest clipboard content
- `list` - List recent clipboard files (default: 5)
- `list --count N` - List N most recent files
- `get <timestamp>` - Get specific clipboard by timestamp
- `delete <timestamp>` - Delete specific clipboard file
- `clear --older-than 7d` - Clear old clipboard entries

## Example Session

```bash
# Assistant saves JSON config
$ python3 ~/.claude/skills/clipboard/scripts/clipboard.py save '{"host": "localhost", "port": 80}'
✓ Saved to ~/clipboard/20260407_233015_clipboard.md

# User retrieves it later
$ /clipboard pull
{
  "host": "localhost",
  "port": 80
}

# List recent clipboards
$ python3 ~/.claude/skills/clipboard/scripts/clipboard.py list
20260407_233015_clipboard.md  (2 minutes ago)
20260407_232800_clipboard.md  (5 minutes ago)
20260407_230145_clipboard.md  (30 minutes ago)
```

## Integration with Other Skills

The clipboard skill integrates naturally with:
- **iris-install**: Copy connection strings
- **interclaw**: Save server configs
- Any chatbot output that needs to be preserved

## Notes

- Clipboard files never expire automatically (manual cleanup only)
- All content is plain text (markdown formatted)
- Files are timestamped for easy identification
- Use `--stdin` for saving command outputs: `some-command | clipboard.py save --stdin`
