# Workspace Instructions

These instructions are always-on for work in this repository.

## Project Context

<!-- ─────────────────────────────────────────────────────────────────────────────
  CUSTOMIZE THIS SECTION for your project.
  Add your project-specific:
    - Mission and philosophy
    - Architecture guardrails that must never be violated
    - Sources of truth (canonical docs)
  ──────────────────────────────────────────────────────────────────────────── -->

## Agent Operating Requirements

- Research and plan before implementation.
- Load `.github/skills/scope-creep-guard/SKILL.md` for every task before planning or edits and enforce its boundary checks.
- Load `.github/skills/detailed-chat-output/SKILL.md` for every task before planning or edits and follow its output rules.
- Execute in small verifiable steps and iterate until the task is fully complete.
- Use additional sessions when necessary; do not stop at partial completion.
- Compact conversation context whenever context usage exceeds about 65 percent during long-running iteration.
- At completion, summarize across all sessions involved in the task, not only the latest session.
- If the agent deviated from plan, used ambiguous assumptions, or encountered uncertainty, report it explicitly in the final output.

## Delivery and Reporting Contract

- Final response order:
  - outcome
  - changes made
  - verification performed
  - deviations/ambiguities
  - residual risks and next steps
- Be explicit about what was not validated and why.
- Prefer concise, factual progress updates while working.

## Customization Hygiene

- If changing any skill files, update `.github/skills/SKILL_MAP.md` in the same change.
- Keep skill/instruction guidance narrow and avoid duplicating the same rule in multiple places without reason.
- If these instructions become stale after architecture changes, update this file first, then dependent skills/prompts.
