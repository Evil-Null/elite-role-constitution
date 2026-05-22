#!/bin/bash
# session-start.sh — Elite Role hook for Kimi CLI 1.43+
#
# Event: SessionStart  (matcher: startup|resume)
# Purpose: project the doctrine's "default read order" — load README,
# RESUME, CONTEXT, ASSUMPTIONS — into the agent context so the AI does
# not have to remember to do it.
#
# v3.0: cwd-aware — loads memory from the current working directory
# (from JSON payload), not hardcoded to elite-role-constitution.

set -euo pipefail

INPUT=$(cat 2>/dev/null || echo '{}')
# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_lib.sh"

CWD=$(er_get_cwd "$INPUT")
cd "$CWD"

# Default read order per memory/README.md Authority Hierarchy.
READ_ORDER=(memory/README.md memory/RESUME.md memory/CONTEXT.md memory/ASSUMPTIONS.md)

# Per-file inlined-content cap. The hook's stdout is appended to the
# agent's context; an unconstrained `cat` of a bloated memory file
# would silently inflate the session prompt by tens of KB (R2 #9).
# Files larger than this cap are truncated with an explicit marker so
# the loss is visible, not silent.
MAX_INLINE_LINES=120

echo "=== Elite Role · SessionStart memory context ==="
echo ""
echo "Project root: $CWD"
echo "Loaded at:    $(TZ=UTC date -u -Iseconds)"
echo ""

for f in "${READ_ORDER[@]}"; do
    if [ -f "$f" ]; then
        LINES="$(awk 'END{print NR}' "$f")"
        echo "--- $f ($LINES lines) ---"
        if [ "$LINES" -gt "$MAX_INLINE_LINES" ]; then
            head -n "$MAX_INLINE_LINES" "$f"
            echo "[...truncated by SessionStart hook at $MAX_INLINE_LINES lines; full file is $LINES lines. Read it directly if needed.]"
        else
            cat "$f"
        fi
        echo ""
    else
        echo "--- $f (MISSING; L1 UNKNOWN=STOP applies if this file is required) ---"
        echo ""
    fi
done

echo "=== end of memory context ==="

# F3 — compliance trend alert (per ROADMAP §5.F.F3). The script
# inspects .kimi/audit/signals-*.jsonl, compares this-week to the
# rolling 14-day window, and emits a warning if any tracked rate
# regressed > 20pp. Silent on the no-alert path so a clean session
# stays clean. Failure of the alert script itself must not block the
# session — wrap in `|| true`.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
if [ -x "$PROJECT_ROOT/scripts/compliance_alert.sh" ]; then
    bash "$PROJECT_ROOT/scripts/compliance_alert.sh" 2>/dev/null || true
fi

exit 0
