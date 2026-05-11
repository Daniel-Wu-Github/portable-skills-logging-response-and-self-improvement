# Debugging Log

Persistent record of implementation errors, skill gaps, and debugging patterns captured across Claude Code sessions.

Each session boundary is written automatically by `scripts/session-end.sh` (Stop hook).
Inline entries are written manually using the template below.

---

## How to Read This Log

- **Session End** entries: auto-written on every Stop, captures TypeScript errors and skill-improvement flags
- **Debug Entry** entries: structured records of specific bugs — what symptom, what root cause, which skill missed it
- **Pattern Flag** entries: written when the same error type appears 2+ times — triggers `skill-improvement-loop`

---

## Entry Template (for manual capture)

```
### Debug Entry — YYYY-MM-DD

**Task:** one-line task description
**File:** path/to/file.ts:line
**Symptom:** what the bug looked like in practice
**Root cause:** what was actually wrong
**Active skills:** which skills were loaded
**Skill gap:** which skill should have caught this but didn't, and why
**Resolution:** what the fix was
**Lesson:** what rule/check should be added to which skill
```

---

## Skill Gap Trigger Rule

When the same skill gap appears **2 or more times** in this log, run `skill-improvement-loop`:
1. Score the failing skill using the 0-2 rubric (trigger quality, scope fit, outcome support, noise control)
2. If total < 7/8: rewrite the description and tighten the "When to Use" section
3. Update `.github/skills/SKILL_MAP.md` if scope changed
4. Update `CLAUDE.md` task-triggered table if the triggering domain changed
5. Re-run `scripts/implicit-skill-smoke-test.sh` to verify the fix

---

## Sessions

<!-- Session entries are appended below by session-end.sh -->
