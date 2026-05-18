#!/bin/bash
# session-start.sh — Elite Role hook for Kimi CLI 1.43+
#
# Event: SessionStart  (matcher: startup|resume)
# Purpose: project the doctrine's "default read order" — load README,
# RESUME, CONTEXT, ASSUMPTIONS — into the agent context so the AI does
# not have to remember to do it.
#
# Protocol: Kimi pipes a JSON context object on stdin; we ignore the
# payload here because the action is independent of the trigger source.
# stdout on exit 0 is added to the agent context; exit 2 would block.

set -euo pipefail

# Consume stdin so the parent does not block on a closed pipe.
cat >/dev/null || true

# Resolve project root from this script's location.
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

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
echo "Project root: $PROJECT_ROOT"
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
exit 0
