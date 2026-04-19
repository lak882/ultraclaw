Restore a modified or deleted skill file from the backup.

Usage: /restore-skill <file-path>

The backup directory lives at `.claude/skills/skills-editor/skills-backup/` and contains the original versions of all `.claude/` files.

Steps:
1. Parse "$ARGUMENTS" -- extract the relative file path (e.g., `.claude/commands/send.md` or `.claude/skills/interclaw/SKILL.md`).
2. Strip the `.claude/` prefix to get the backup-relative path.
3. Check if the backup file exists at `.claude/skills/skills-editor/skills-backup/<relative-path>`.
4. If the backup file does not exist, report the error. The file may not have existed at the time the backup was created.
5. If the backup file exists:
   a. Read the backup file content.
   b. Check if the current file exists at the original location.
   c. If the current file exists and differs from backup, show a brief summary of the differences and confirm the restore.
   d. If the current file is missing (deleted), proceed with restoration.
6. Copy the backup file to the original location using the Write tool (or create parent directories if needed).
7. Report success: file restored from backup.
