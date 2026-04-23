---
name: improving-skills
description: Runbook for testing an existing skill by running a single test prompt through fresh chat sessions N times, comparing outputs, then revising the skill's SKILL.md based on observed failures. Use when a skill is suspected of failing to trigger, giving wrong guidance, or drifting out of date. Triggers on "test this skill", "improve skill X", "why isn't skill X triggering", "skill audit", "verify skill works".
tools: [read_file, write_file, run_sql, xecute]
---

# improving-skills

Evidence-based skill improvement. Rather than rewriting a skill on a hunch, **run it** against a representative prompt in fresh chat sessions, observe what fails, and edit the SKILL.md to fix only what observably broke.

## When to use

- A skill exists but the model doesn't load it when it should.
- A skill loads but produces incorrect output (wrong tool, wrong shape, missed a gotcha).
- A skill's description doesn't match the triggers users actually use.
- A workflow change has made the skill's body stale.

## When NOT to use

- One-off anecdotal failure. Reproduce it first (at least 2 of N runs) before editing.
- You want to add a feature. That is new authoring, not improvement.
- The skill hasn't been exercised yet at all. Exercise it once, then decide if it needs improving.

## The loop

Each cycle has four steps. Do them in order. Do not skip.

### Step 1: pick a test prompt

Pick one concrete user request that SHOULD trigger the skill. Write it down as the exact text a user would type. Example for `record-map`:

```
I have a CSV file of patients (MRN, last, first, DOB, gender). Build me a RecordMap for it.
```

Good test prompts are:

- Realistic (mirrors real user language, not "please use skill X")
- Specific enough that the correct output is unambiguous
- Neutral on which skill to use (so triggering is the test, not the assumption)

### Step 2: run N fresh chat turns

For each iteration (default: 3), open a **new** chat and issue the test prompt. Fresh context each time — no prior turn bleed.

#### Open a new chat

Call `exec:` with a curl-equivalent? No. Use the chat REST directly:

```
exec: Set req = ##class(%Net.HttpRequest).%New()
      Set req.Server = "localhost"
      Set req.Port = 80
      Set req.ContentType = "application/json"
      Do req.EntityBody.Write("{""prompt"":""<test-prompt>"",""model"":""opus"",""namespace"":""ULTRACLAW""}")
      Set sc = req.Post("/interclaw-test/api/interclaw/production/api/start")
      Set body = ""
      Do req.HttpResponse.Data.Rewind()
      While 'req.HttpResponse.Data.AtEnd { Set body = body _ req.HttpResponse.Data.Read(32000) }
      Set %result = body
```

Record the `chat_id` returned.

#### Poll for completion

The events poll endpoint format varies by REST class. Inspect `InterClaw.REST.Chat` first with `read_class` to find the right route and params before polling. Common shape:

```
exec: Set req = ##class(%Net.HttpRequest).%New()
      Set req.Server = "localhost"
      Set req.Port = 80
      Set sc = req.Get("/interclaw-test/api/interclaw/production/api/events?chat_id=<id>")
      ... read body as above ...
```

Poll every 2 seconds until the response body contains `"done":true` or similar terminal signal. Hard cap: 60 seconds per iteration.

#### Capture per iteration

For each run, record:
- Which skills were loaded (look for `read_file` calls on `.agent/skills/<name>/SKILL.md` in the trace)
- Which tools were called, with what args
- The final `output` text
- Whether the run produced an error or hit the iteration cap

### Step 3: compare outputs across iterations

Lay the N outputs side-by-side. Ask three questions:

**Q1. Did the right skill load?**
- Expected skill: the one you're testing.
- Look in the tool-call log for a `read_file` on `.agent/skills/<target>/SKILL.md`.
- If it didn't load in any iteration → description isn't trigger-dense enough. Fix: add more trigger phrases to the `description:` field (not the body; the body is invisible until loaded).
- If it loaded in 1 of 3 → inconsistent triggering. Same fix: tighter description.
- If it loaded in 3 of 3 but produced bad output → body issue, not routing.

**Q2. Did the output match what the skill teaches?**
- Pull the skill body with `read_file`.
- Compare the model's output to the workflow the body describes.
- If output skipped a step (e.g. skipped schema pull before writing a DTL) → the skill didn't emphasize that step strongly enough. Fix: reorder to put the critical step first, mark it with "CRITICAL" or "always".
- If output hallucinated a field or tool → the skill needs a stronger "never do X" constraint.

**Q3. Are the N runs consistent with each other?**
- If three runs produce three different workflows → skill guidance is ambiguous. Fix: add a decision tree or single-path prescription.
- If three runs all produce the same wrong thing → the skill is wrong, not ambiguous. Fix the content.

### Step 4: edit and re-test

Make the **smallest** edit that addresses the observed failure. Resist the urge to refactor the whole skill.

- Description edits (trigger phrases): use `write_file` on the SKILL.md.
- Body edits (workflow, gotchas): use `write_file` on the SKILL.md or the relevant `references/*.md`.
- Never edit a skill you haven't tested. The Iron Law: no skill modification without observed failure evidence.

After editing, run Step 2 again with the same test prompt. The skill is improved when:

- It loads in ≥ 2 of 3 runs where it didn't before, OR
- Its outputs converge on the same correct workflow where they used to diverge, OR
- A specific reported gotcha no longer occurs.

Record the before/after counts. If behavior didn't change, revert the edit and try a different fix.

## Anti-patterns to avoid

- **Editing without running.** You don't know what's broken until you reproduce the failure.
- **Editing more than one thing per cycle.** If you change description AND body AND references in one pass, you can't tell which fix worked.
- **Over-relying on "CRITICAL" / "IMPORTANT" / "MUST".** Works once. Works less the second time. Doesn't stack.
- **Fighting the model's output instead of the skill's description.** The model behaves correctly given the description it sees. If behavior is wrong, the description is the bug.

## Common fixes by symptom

| Symptom | Fix in SKILL.md |
|---|---|
| Skill never loads | Expand `description:` with 3-5 more natural-language trigger phrases |
| Skill loads but wrong tool used | Body's tool table is unclear; restate "use X tool for Y" |
| Output skips a step | Move step earlier in body, prefix with "ALWAYS" |
| Output uses wrong field path | Add a forbidden-values section; list specific wrong patterns |
| Output inconsistent across runs | Replace prose with a single prescriptive ordered list |
| Skill description is long but still misses | Description is too generic; add specific trigger phrases from the test prompts that failed |

## Example session

> User: the `record-map` skill isn't triggering when I ask for a CSV parser.
>
> Model:
> 1. `read_file` `.agent/skills/record-map/SKILL.md` to read the current body.
> 2. Run the test prompt 3× (with "I have a CSV file..." — issue POST /api/start, poll).
> 3. Observed: skill loaded 0 of 3 times. The description lists "delimited file", "flat file" as triggers but not "CSV file" as a bare phrase.
> 4. Edit: add "CSV file" and "CSV parser" to the trigger list in `description:`.
> 5. Re-run 3×. Skill now loads 3 of 3.
> 6. Report: "`description:` expanded with `CSV file`/`CSV parser` trigger phrases. Verified 3/3 load rate."

## See also

- Each skill's own body — load with `read_file` before testing it
- `InterClaw.REST.Chat.cls` via `read_class` — confirms the current chat REST route shape before polling
