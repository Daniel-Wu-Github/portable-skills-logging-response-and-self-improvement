# Portable Skills — Logging, Response, and Self-Improvement

A drop-in skill system for Claude Code and GitHub Copilot that provides:
- **11 reusable skills** for scope control, documentation, testing, verification, logging, and self-improvement
- **Automatic verification checks** after every edit (configurable per language)
- **Session-end reporting** with verification summaries and skill-improvement auto-flagging
- **Push notifications** via ntfy.sh when Claude needs approval or finishes working
- **Commit log automation** via a pre-push git hook
- **Pattern analysis** that surfaces recurring errors and skill gaps across sessions

---

## Quick Setup (5 steps)

### 1. Copy this folder into your repo root

```bash
cp -r portable-skills-logging-response-and-self-improvement/. your-repo/
```

Or clone and copy:
```bash
git clone <this-repo> && cp -r portable-skills-logging-response-and-self-improvement/. your-repo/
```

### 2. Set your ntfy.sh notification channel

Edit `scripts/notify.sh` and replace `YOUR_CHANNEL_NAME`:
```bash
NTFY_URL="https://ntfy.sh/YOUR_CHANNEL_NAME"
```
Subscribe to that topic in the [ntfy app](https://ntfy.sh) on your phone.
Or set the env var: `export NTFY_CHANNEL_URL="https://ntfy.sh/my-project-alerts"`

### 3. Make scripts executable

```bash
chmod +x scripts/*.sh .githooks/pre-commit .githooks/pre-push
```

### 4. Enable git hooks

```bash
git config core.hooksPath .githooks
```

### 5. Customize agent context for your project

Open `CLAUDE.md`, `GEMINI.md`, and `context.md`, then fill in the **Project-Specific Instructions** (or placeholders) at the bottom:
- Core mission and project philosophy
- Architecture guardrails
- Sources of truth (canonical docs)
- Any additional project-specific skills you create

Do the same for `.github/copilot-instructions.md`.

---

## What's Included

```
.github/
  copilot-instructions.md       — always-on Copilot agent instructions
  skills/
    SKILL_MAP.md                — central skill registry (read this first)
    scope-creep-guard/          — prevents out-of-scope edits (mandatory every task)
    documentation-cohesion/     — keeps docs naturally integrated
    manual-testing-guides/      — authors reproducible test guides
    skill-map-governance/       — keeps skill catalog in sync
    verification-gate/          — enforces verification before completion
    workflow-logging/           — captures material decisions and changes
    remote-commit-logging/      — automates commit history via pre-push hook
    detailed-chat-output/       — structures responses for traceability (mandatory every task)
    self-improvement-loop/      — fixes recurring mistakes and stale docs
    skill-improvement-loop/     — evaluates and rewrites skills with trigger gaps
    repo-workflow/              — manages instruction files and workflow surfaces
.claude/
  settings.json                 — hooks: PostToolUse (checks), Stop (session-end), Notification
  config                        — tunable thresholds and check definitions
  debugging_log.md              — persistent error and skill gap record
  pending-improvements.md       — auto-populated action queue (checked at session start)
.githooks/
  pre-commit                    — blocks accidental secret commits
  pre-push                      — auto-logs pushed commits to logging/commit_log.md
scripts/
  notify.sh                     — ntfy.sh push notifications
  notify-approval.sh            — Notification hook (approval needed)
  post-edit-check.sh            — PostToolUse hook (verification checks)
  session-end.sh                — Stop hook (checks + pattern analysis + notify)
  analyze-patterns.sh           — scans log for recurring errors and skill gaps
  update-skill-memory.sh        — updates memory/ files from debug log entries
  implicit-skill-smoke-test.sh  — validates skill auto-loading with golden prompts
logging/
  progress_log.md               — structured agent workflow change log
  commit_log.md                 — append-only pushed commit history
memory/
  skill_effectiveness.md        — per-skill scores and miss counts
  debugging_patterns.md         — recurring root cause patterns
CLAUDE.md                       — Claude Code instructions (customize Project-Specific section)
GEMINI.md                       — Gemini agent context template
context.md                      — shared project context template
```

---

## Adding Project-Specific Skills

1. Create `.github/skills/<your-skill-name>/SKILL.md` with frontmatter:
   ```markdown
   ---
   name: your-skill-name
   description: "Use when [specific trigger condition]."
   ---
   ```
2. Add it to `.github/skills/SKILL_MAP.md` registry and selection order.
3. Add it to the task-triggered table in `CLAUDE.md`.
4. Add golden tests for it in `scripts/implicit-skill-smoke-test.sh`.
5. Run `bash scripts/implicit-skill-smoke-test.sh` — all tests must pass.

---

## How the Self-Improvement Loop Works

1. **Every edit to a matching file** → `post-edit-check.sh` runs configured checks, sends notification on error.
2. **Every session end** → `session-end.sh` runs configured checks for modified files, appends to `debugging_log.md`, runs `analyze-patterns.sh`.
3. **`analyze-patterns.sh`** → surfaces recurring error codes, hot files, and skill gap entries into `pending-improvements.md`.
4. **Session start** → Claude reads `pending-improvements.md` first and resolves flagged items before any task.
5. **2+ skill gap mentions** → `skill-improvement-loop` is auto-flagged, Claude rewrites the skill, runs smoke test.

---

## Smoke Test

Verify all skills auto-load correctly for their intended task types:

```bash
bash scripts/implicit-skill-smoke-test.sh
```

Run this after adding or modifying any skill. All tests must pass before the change is complete.
