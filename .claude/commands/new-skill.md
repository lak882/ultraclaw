Create a new custom Claude Code skill.

Usage: /new-skill <name> [description]

Steps:
1. Parse "$ARGUMENTS" -- extract skill name (required) and optional one-line description.
2. Validate the name: lowercase, hyphens allowed, no spaces or special characters.
3. Check if `.claude/skills/<name>/` already exists. If so, report that the skill already exists and suggest `/edit-skill` instead.
4. Create the skill directory and SKILL.md:
   ```
   .claude/skills/<name>/SKILL.md
   ```
   With YAML frontmatter:
   ```markdown
   ---
   name: <name>
   description: <description or "Custom skill — update this description.">
   ---

   # <Name>

   <!-- Add skill instructions here. Claude Code will follow these when the skill is active. -->
   ```
5. Report success. The new skill will appear in the Skills Editor sidebar and in the available skills list automatically.
