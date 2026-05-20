# Portable Skills — Claude Code Instructions

## Skill System

This project has a skill library at `.github/skills/`. Skills enforce workflow, safety, and quality rules for specific task domains.

**Before starting any task:**
1. Read `.github/skills/SKILL_MAP.md` — it is the central source of truth.
2. Determine the task domain (see table below).
3. Read each applicable skill file before planning or editing anything.

### Mandatory Skills (load for every task)

| Skill | Path |
|---|---|
| scope-creep-guard | `.github/skills/scope-creep-guard/SKILL.md` |
| detailed-chat-output | `.github/skills/detailed-chat-output/SKILL.md` |

### Task-Triggered Skills (load when the task matches)

| Task Domain | Skills to Load |
|---|---|
| Documentation authoring or planning doc updates | `documentation-cohesion/SKILL.md` |
| Manual testing guides, runbooks, or validation checklists | `manual-testing-guides/SKILL.md` |
| Workflow/instruction file changes, skill creation, or skill map updates | `repo-workflow/SKILL.md`, `skill-map-governance/SKILL.md` |
| Any task that edits files, config, or process docs | `verification-gate/SKILL.md` |
| Progress log, commit log, or logging surface updates | `workflow-logging/SKILL.md` |
| Commits being pushed to remote | `remote-commit-logging/SKILL.md` |
| Repeated errors, stale docs, or avoidable rework patterns | `self-improvement-loop/SKILL.md`, `skill-improvement-loop/SKILL.md` |

### How to Apply Skills

Reading a skill is not enough — enforce its rules. If a skill defines a procedure, follow it step by step. If a skill defines an allow-list and deny-list, check your planned edits against both before touching any file.

---

## Self-Improvement System

### Session Start — Check First
**Before doing anything else**, read `.claude/pending-improvements.md`. If it has unresolved entries:
1. Address each item (run `skill-improvement-loop`, update skills, re-run smoke test)
2. Delete the resolved section from the file
3. Then proceed with the user's task

### Push Notifications to Your Phone
All three hooks send push notifications to your configured ntfy channel.
Set `NTFY_CHANNEL_URL` in `scripts/notify.sh` to your ntfy.sh topic URL.
- **PostToolUse** (after matching edits): "Verification: N error(s) after editing..."
- **Stop** (session end): "Done — N verification error(s)" or "Done — no errors"
- **Notification** (approval needed): "Claude Code is waiting for your approval or input"

If notifications don't arrive: check `.claude/notification_log.txt` for what Claude Code sent.

### Automatic Verification (PostToolUse Hook)
`scripts/post-edit-check.sh` runs after every Edit/Write and executes configured checks for the edited file. It:
- Matches the edited file against `CHECK_DEFINITIONS` in `.claude/config`
- Runs the configured command at the detected root (rate-limited per check/root)
- Writes errors to `.claude/session_errors.tmp`
- Sends a push notification if errors are found

### Automatic Verification (Stop Hook)
`scripts/session-end.sh` runs at the end of every session. It:
- Runs configured checks for modified files and logs verification results
- Appends a structured entry to `.claude/debugging_log.md`
- Calls `scripts/analyze-patterns.sh` to scan for recurring error patterns and skill gaps
- **Auto-flags `skill-improvement-loop`** if the error threshold is exceeded

### Debugging Log
`.claude/debugging_log.md` is the persistent record of implementation errors and skill gaps.
When you make a mistake (wrong logic, missed edge case, verification error), append an entry using the template in that file.

### Pattern Threshold — When to Trigger Skill Improvement
Run `skill-improvement-loop` when **any** of these conditions are true:
- The Stop hook auto-flags it (2+ errors in a session)
- The same error code appears in `.claude/debugging_log.md` 2 or more times
- A skill failed to auto-load for a task it clearly covers

### Running the Smoke Test
After any skill is created, renamed, or reworded, run:
```
bash scripts/implicit-skill-smoke-test.sh
```
A failing test = a skill has a trigger gap. Fix the description or "When to Use" wording, then re-run until all tests pass.

### Tunable Thresholds (`.claude/config`)
- `CHECK_DEFINITIONS` — list of verification checks keyed by file patterns and commands
- `CHECK_TIMEOUT_SECS` — max seconds for each check command (default: 45)
- `CHECK_OUTPUT_LINES` — max lines captured per check output (default: 40)
- `ERROR_THRESHOLD` — session errors before skill-improvement flag (default: 2)
- `POST_EDIT_RATE_LIMIT_SECS` — seconds between post-edit check runs (default: 30)
- `PATTERN_ERROR_CODE_MIN` — same error code N+ times to flag (default: 2)
- `PATTERN_FILE_ERROR_MIN` — same file N+ error mentions to flag (default: 3)
- `SKILL_GAP_ESCALATE_MIN` — same skill in gap entries N+ times for urgent escalation (default: 2)

---

## Operating Requirements

- Research and plan before implementation. Read the relevant skill files first.
- Execute in small verifiable steps. After each burst of edits, check against the declared scope.
- Summarize across all work done. Call out deviations, ambiguous assumptions, and residual risks explicitly.

---

## Project-Specific Instructions

<!-- ─────────────────────────────────────────────────────────────────────────────
  CUSTOMIZE THIS SECTION for your project.
  Add:
    - Core mission and project philosophy
    - Architecture guardrails (what must never be violated)
    - Sources of truth (canonical docs your agent must read)
    - Additional task-triggered skills specific to your project
  ──────────────────────────────────────────────────────────────────────────── -->

### Core Mission

<!-- e.g.: Preserve <project>'s <key invariant> while implementing or changing any subsystem. -->

### Architecture Guardrails

<!-- e.g.: Never call third-party APIs directly from the client. Always route through the proxy. -->

### Sources of Truth

<!-- e.g.:
- docs/ARCHITECTURE.md
- docs/API_CONTRACT.md
When unsure, align changes to these docs or explicitly call out the mismatch.
-->

### Additional Task-Triggered Skills

<!-- Add project-specific skill rows to this table once you create them:
| Task Domain | Skills to Load |
|---|---|
| ... | ... |
-->

---

## Delivery Contract

Final response order:
1. Outcome
2. Changes made
3. Verification performed
4. Deviations or ambiguities
5. Residual risks and next steps

Be explicit about what was not validated and why.
