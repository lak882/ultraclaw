Edit an existing Claude Code skill file.

Usage: /edit-skill <skill-name> [file-path]

Steps:
1. Parse "$ARGUMENTS" -- extract skill name (required) and optional file path within the skill.
2. Locate the skill directory at `.claude/skills/<skill-name>/`.
3. If the skill directory does not exist, report the error and list available skills from `.claude/skills/`.
4. If no file path is given, default to `SKILL.md`.
5. Read the target file with the Read tool.
6. Ask the user what changes they would like to make.
7. Apply the requested edits with the Edit tool.
8. Report what was changed (1-2 sentences, no full source dump).
