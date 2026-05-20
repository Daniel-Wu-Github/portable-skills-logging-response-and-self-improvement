# Progress Log

## How to Use

This log captures material workflow and instruction changes made by AI agents.
Each entry must follow the format below. Entries are added by the agent after material tasks.

## Entry Format

```
## Entry NNN - YYYY-MM-DD - Quick Title

- Task: One-line statement of the original task/request.
- What the agent did: Concrete outcomes.
- How the agent did it: Brief method used (research, files inspected, checks run).
- Files edited:
	- path/to/file1
	- path/to/file2
- Verification:
	- Specific checks the user can run or inspect.
- Task alignment:
	- Fulfillment: How the result satisfies the request.
	- Deviation: "None" or explicit deviation and reason.
```

Rules:
- `NNN` is a zero-padded sequential number (`001`, `002`, ...).
- Date must use ISO format `YYYY-MM-DD`.
- Append new entries in chronological order.
- If no files were edited, set `Files edited` to `- none`.

---

<!-- Entries are appended below -->

## Entry 001 - 2026-05-20 - Generalize verification loop

- Task: Make the self-improvement loop language-agnostic, add GEMINI.md/context.md templates, and make detailed-chat-output always-on.
- What the agent did: Added configurable verification checks with generic error logging, updated skills/instructions to make detailed-chat-output mandatory, and added new agent context templates.
- How the agent did it: Edited scripts and config, aligned documentation and skill map guidance, and ran the smoke test.
- Files edited:
	- .claude/config
	- .claude/debugging_log.md
	- .claude/pending-improvements.md
	- .github/copilot-instructions.md
	- .github/skills/detailed-chat-output/SKILL.md
	- .github/skills/SKILL_MAP.md
	- CLAUDE.md
	- README.md
	- scripts/analyze-patterns.sh
	- scripts/post-edit-check.sh
	- scripts/session-end.sh
	- GEMINI.md
	- context.md
	- logging/progress_log.md
- Verification:
	- `bash scripts/implicit-skill-smoke-test.sh`
- Task alignment:
	- Fulfillment: Language-agnostic checks now drive the loop, detailed-chat-output is mandatory across instructions, and Gemini/context templates are available.
	- Deviation: None
