#!/usr/bin/env bash
# session-end.sh
# Runs after each Claude Code session (Stop hook).
# 1. Detects TypeScript packages containing modified files and runs tsc
# 2. Appends a structured session boundary to the debugging log
# 3. Flags skill-improvement-loop if error threshold is exceeded

set -uo pipefail

PROJECT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
LOG_FILE="$PROJECT_DIR/.claude/debugging_log.md"
ERRORS_TMP="$PROJECT_DIR/.claude/session_errors.tmp"
CONFIG_FILE="$PROJECT_DIR/.claude/config"

TS_ERROR_THRESHOLD=2
[[ -f "$CONFIG_FILE" ]] && source "$CONFIG_FILE"
THRESHOLD_TRIGGER="${TS_ERROR_THRESHOLD}"

mkdir -p "$PROJECT_DIR/.claude"

SESSION_DATE="$(date -u +%Y-%m-%d)"
SESSION_TIME="$(date -u +%H:%M:%SZ)"
TS_ERRORS=""
SKILL_FLAG=false

# ─── 1. TypeScript Verification ──────────────────────────────────────────────
MODIFIED_TS="$(cd "$PROJECT_DIR" && git diff --name-only HEAD 2>/dev/null | grep '\.ts$' || true)"

if [[ -n "$MODIFIED_TS" ]]; then
  # Discover unique package roots from modified .ts files
  declare -A PKG_SEEN=()
  while IFS= read -r ts_file; do
    [[ -z "$ts_file" ]] && continue
    full_path="$PROJECT_DIR/$ts_file"
    search_dir="$(dirname "$full_path")"
    pkg_dir=""
    while [[ "$search_dir" != "/" ]]; do
      if [[ -f "$search_dir/tsconfig.json" ]]; then
        pkg_dir="$search_dir"
        break
      fi
      [[ "$search_dir" == "$PROJECT_DIR" ]] && break
      search_dir="$(dirname "$search_dir")"
    done
    # Also check project root
    if [[ -z "$pkg_dir" && -f "$PROJECT_DIR/tsconfig.json" ]]; then
      pkg_dir="$PROJECT_DIR"
    fi
    [[ -z "$pkg_dir" ]] && continue
    [[ -n "${PKG_SEEN[$pkg_dir]:-}" ]] && continue
    PKG_SEEN["$pkg_dir"]=1

    PKG_NAME="$(basename "$pkg_dir")"
    PKG_ERRORS="$(cd "$pkg_dir" && npx tsc --noEmit 2>&1 | head -40 || true)"
    if [[ -n "$PKG_ERRORS" ]]; then
      TS_ERRORS="$TS_ERRORS
### TypeScript Errors ($PKG_NAME)
\`\`\`
$PKG_ERRORS
\`\`\`"
    fi
  done <<< "$MODIFIED_TS"
fi

# ─── 2. Count errors and decide flag ─────────────────────────────────────────
ERROR_COUNT=0
if [[ -n "$TS_ERRORS" ]]; then
  ERROR_COUNT="$(echo "$TS_ERRORS" | grep -c 'error TS' || true)"
fi

PREV_ERROR_COUNT=0
if [[ -f "$ERRORS_TMP" ]]; then
  PREV_ERROR_COUNT="$(grep -c 'error TS' "$ERRORS_TMP" 2>/dev/null || true)"
fi

TOTAL_ERRORS=$(( ERROR_COUNT + PREV_ERROR_COUNT ))
[[ $TOTAL_ERRORS -ge $THRESHOLD_TRIGGER ]] && SKILL_FLAG=true

# ─── 3. Append to debugging log ──────────────────────────────────────────────
{
  echo ""
  echo "---"
  echo "## Session End — $SESSION_DATE $SESSION_TIME"
  echo ""

  if [[ -n "$MODIFIED_TS" ]]; then
    echo "**Modified TypeScript files:**"
    echo "$MODIFIED_TS" | sed 's/^/- /'
    echo ""
  fi

  if [[ -n "$TS_ERRORS" ]]; then
    echo "**Verification Result:** ❌ Errors found ($ERROR_COUNT TypeScript error(s))"
    echo "$TS_ERRORS"
  else
    echo "**Verification Result:** ✅ No TypeScript errors"
  fi

  if [[ -f "$ERRORS_TMP" && -s "$ERRORS_TMP" ]]; then
    echo ""
    echo "**Accumulated session errors:**"
    cat "$ERRORS_TMP"
  fi

  if $SKILL_FLAG; then
    echo ""
    echo "> ⚠️ **AUTO-FLAG:** $TOTAL_ERRORS error(s) this session exceeded threshold ($THRESHOLD_TRIGGER)."
    echo "> Run \`skill-improvement-loop\` before next task — score active skills and update any with trigger gaps."
  fi

  echo ""
} >> "$LOG_FILE"

if [[ -n "$TS_ERRORS" ]]; then
  echo "$TS_ERRORS" >> "$ERRORS_TMP"
fi

# ─── 4. Send ntfy.sh push notification ───────────────────────────────────────
NOTIFY="$PROJECT_DIR/scripts/notify.sh"
if [[ -x "$NOTIFY" ]]; then
  if $SKILL_FLAG; then
    bash "$NOTIFY" \
      "Done — $TOTAL_ERRORS TS error(s). Run skill-improvement-loop before next task." \
      "Claude Code" "high" "warning,claude"
  elif [[ -n "$TS_ERRORS" ]]; then
    bash "$NOTIFY" \
      "Done — TypeScript errors found. Check .claude/debugging_log.md" \
      "Claude Code" "default" "warning,claude"
  else
    bash "$NOTIFY" \
      "Done — no errors." \
      "Claude Code" "default" "white_check_mark,claude"
  fi
fi

# ─── 5. Update skill memory from structured debug entries ────────────────────
UPDATE_MEM="$PROJECT_DIR/scripts/update-skill-memory.sh"
if [[ -x "$UPDATE_MEM" ]]; then
  bash "$UPDATE_MEM" 2>/dev/null || true
fi

# ─── 6. Run pattern analysis ──────────────────────────────────────────────────
ANALYZE="$PROJECT_DIR/scripts/analyze-patterns.sh"
if [[ -x "$ANALYZE" ]]; then
  bash "$ANALYZE" 2>/dev/null || true
fi

if $SKILL_FLAG; then
  echo "⚠️  SESSION END: $TOTAL_ERRORS TS error(s) — skill-improvement-loop flagged"
elif [[ -n "$TS_ERRORS" ]]; then
  echo "⚠️  SESSION END: TypeScript errors found — check .claude/debugging_log.md"
else
  echo "✅ SESSION END: No TypeScript errors"
fi
