/// Skill repository loader.
/// Reads CLAUDE.md, SKILL.md, and on-demand reference/command files from the
/// deployed skill tree at ${cspdir}/interclaw/. Mirrors the Claude Code /
/// OpenClaw pattern of bootstrapping an agent with a top-level "operating
/// manual" and letting it pull reference material lazily as tool calls.
Class InterClaw.Skill.Loader Extends %RegisteredObject
{

/// Default root where the skill repo is deployed.
/// Overridable via ^InterClaw.Config("SkillRoot").
ClassMethod Root() As %String
{
    Set root = $Get(^InterClaw.Config("SkillRoot"))
    If root = "" Set root = $System.Util.InstallDirectory() _ "csp/interclaw"
    Return root
}

/// Build the short system prompt. No CLAUDE.md inline — the operating
/// manual ships once per session as a first user message via
/// BuildBootstrapMessage(). Mirrors OpenClaw: short system prompt, bootstrap
/// injected as a cacheable user-content block on the first turn only.
ClassMethod BuildSystemPrompt() As %String
{
    Set prompt = "You are InterClaw, an IRIS-native agent running inside an InterSystems IRIS production. You assist a healthcare IT professional with integration development on InterSystems IRIS and HealthShare." _ $Char(10) _ $Char(10)
    Set prompt = prompt _ "COMMUNICATION: Speak in complete sentences. Never use emojis. Never use em dashes or double hyphens. Lead with the answer, then supporting detail. Be brief. Present structured data (facts, metrics, comparisons) in markdown tables. Professional and respectful tone. When you do not know something, say so and offer to investigate. Do not pad responses with filler or repeat back what the user said." _ $Char(10) _ $Char(10)
    Set prompt = prompt _ "TOOLS: run_sql, list_docs, get_doc, production_status, get_schema, put_class, compile_class, test_dtl, echo, exec (Python with embedded `iris` in scope), spawn_agent (fork parallel sub-agents), enter_plan_mode / exit_plan_mode (gate destructive tools behind user approval), list_skill_files, read_skill_file." _ $Char(10) _ $Char(10)
    Set prompt = prompt _ "SKILL REPO: The skill repo under .claude/ is your operating manual. For task-specific detail call read_skill_file on:" _ $Char(10)
    Set prompt = prompt _ "  .claude/CLAUDE.md  — full project conventions (package naming, DTL gotchas, ZEN editor URLs, etc.)" _ $Char(10)
    Set prompt = prompt _ "  .claude/skills/interclaw/SKILL.md  — skill overview + command table" _ $Char(10)
    Set prompt = prompt _ "  .claude/skills/interclaw/{dtl,bpl,rules,production,data,infra,web}/  — topic references" _ $Char(10)
    Set prompt = prompt _ "  .claude/commands/<name>.md  — slash-command specs" _ $Char(10) _ $Char(10)
    Set prompt = prompt _ "WORKFLOW: Before any non-trivial change (DTL, rule, BPL, production edit), enter_plan_mode, outline the steps, then exit_plan_mode once the user approves. Always get_schema before writing a DTL. Call native IRIS tools directly — do not shell out to Python scripts under scripts/. For destructive operations, prefer put_class + compile_class + test_dtl over raw exec." _ $Char(10) _ $Char(10)
    Set prompt = prompt _ "SQL RULES (NON-NEGOTIABLE): Every SQL query goes through the typed `run_sql` tool. You must NEVER use `exec` or `iris.sql.exec(...)` from Python to run SQL — the `run_sql` tool exists specifically for this purpose and returns results already JSON-encoded. If you find yourself writing `iris.sql.exec(...)` inside `exec`, stop and use `run_sql` instead. IRIS SQL quirks: negated predicates must parenthesize the full comparison, e.g. `WHERE NOT (Name %STARTSWITH 'Foo')` — `WHERE Name NOT %STARTSWITH 'Foo'` is a syntax error. `%STARTSWITH` takes a string literal, not a parameter. Use `TOP N` after `SELECT` for limiting rows (IRIS does not accept `LIMIT`). For filtering user-namespace classes, query `%Dictionary.ClassDefinition WHERE Name %STARTSWITH 'YourPkg'` directly — do NOT use `RoutineMgr_StudioOpenDialog`." _ $Char(10)
    Return prompt
}

/// Build the one-shot bootstrap user message. Sent once, at session creation,
/// so subsequent turns reuse it from the transcript (and Anthropic's prefix
/// cache) instead of re-paying the cost in the system prompt.
ClassMethod BuildBootstrapMessage() As %String
{
    Set claude = ..ReadFile(".claude/CLAUDE.md", 60000)
    If $Extract(claude, 1, 6) = "Error:" Return ""
    Return "<operating-manual source='.claude/CLAUDE.md'>" _ $Char(10) _ claude _ $Char(10) _ "</operating-manual>" _ $Char(10) _ $Char(10) _ "Acknowledge by waiting silently for the user's actual first message. Do not greet or summarize the manual."
}

/// List files in a directory under the skill repo. Returns JSON.
ClassMethod ListFiles(relPath As %String) As %String [ Language = python ]
{
    import os, json
    # Inline Root() resolution so we don't need iris.cls
    try:
        import iris
        root = str(iris.gref("InterClaw.Config").get("SkillRoot") or "")
    except Exception:
        root = ""
    if not root:
        # Fall back to a well-known path
        import subprocess
        root = "/usr/local/InterSystems/INTERCLAW-TEST/csp/interclaw"
    rel = str(relPath or "").lstrip("/")
    if ".." in rel.split("/"):
        return json.dumps({"error": "relative traversal not allowed"})
    target = os.path.join(root, rel) if rel else root
    if not os.path.isdir(target):
        return json.dumps({"error": f"not a directory: {rel}"})
    entries = []
    for name in sorted(os.listdir(target)):
        full = os.path.join(target, name)
        try:
            entries.append({
                "name": name,
                "is_dir": os.path.isdir(full),
                "size": os.path.getsize(full) if os.path.isfile(full) else None,
            })
        except Exception:
            continue
    return json.dumps({"path": rel or ".", "entries": entries})
}

/// Read a file from the skill repo. Returns its text (truncated).
ClassMethod ReadFile(relPath As %String, maxBytes As %Integer = 40000) As %String [ Language = python ]
{
    import os
    try:
        import iris
        root = str(iris.gref("InterClaw.Config").get("SkillRoot") or "")
    except Exception:
        root = ""
    if not root:
        root = "/usr/local/InterSystems/INTERCLAW-TEST/csp/interclaw"
    rel = str(relPath or "").lstrip("/")
    if ".." in rel.split("/"):
        return "Error: relative traversal not allowed"
    target = os.path.join(root, rel)
    if not os.path.isfile(target):
        return f"Error: not a file: {rel}"
    try:
        mb = int(maxBytes) if maxBytes else 40000
        with open(target, "r", encoding="utf-8", errors="replace") as f:
            data = f.read(mb + 1)
        if len(data) > mb:
            return data[:mb] + f"\n... (truncated at {mb} chars)"
        return data
    except Exception as e:
        return f"Error: {type(e).__name__}: {e}"
}

}
