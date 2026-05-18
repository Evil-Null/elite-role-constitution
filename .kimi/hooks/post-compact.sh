#!/bin/bash
# post-compact.sh — Elite Role hook for Kimi CLI 1.43+
#
# Event: PostCompact
# Purpose: verify that the doctrinal compact ritual produced a coherent
# memory/COMPACT_STATE.md. If the file is missing or stale, surface a
# correction request to the agent (stderr → exit 2 would block; we use
# stdout + exit 0 so the user can decide).

set -euo pipefail

cat >/dev/null || true

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

echo "=== Elite Role · PostCompact verification ==="

if [ ! -f memory/COMPACT_STATE.md ]; then
    echo "WARN: memory/COMPACT_STATE.md is missing — the compact ritual"
    echo "      did not write a snapshot. L1 (UNKNOWN=STOP) applies for"
    echo "      any cross-compact continuity claim. Recommend rewriting"
    echo "      the file before resuming the task."
    exit 0
fi

# Sanity-check the file's freshness and shape
LINES=$(wc -l <memory/COMPACT_STATE.md)
MAX=$(grep -oP '(?<=^> \*\*Max Size:\*\* )\d+(?= lines)' memory/COMPACT_STATE.md 2>/dev/null | head -1 || echo "40")

if [ "$LINES" -gt "$MAX" ]; then
    echo "WARN: memory/COMPACT_STATE.md is $LINES lines > $MAX cap"
    echo "      Rotate per ROLLUP_POLICY.md before further compact cycles."
fi

# Cross-check: COMPACT_STATE should mention the same active task as CONTEXT
if [ -f memory/CONTEXT.md ]; then
    TASK_IN_CTX=$(grep -i "active task\|current task" memory/CONTEXT.md | head -1 || echo "")
    if [ -n "$TASK_IN_CTX" ]; then
        FIRST_WORD=$(echo "$TASK_IN_CTX" | awk -F': ' '{print $2}' | awk '{print $1}')
        if [ -n "$FIRST_WORD" ] && ! grep -qi "$FIRST_WORD" memory/COMPACT_STATE.md; then
            echo "WARN: CONTEXT.md mentions task '$FIRST_WORD' but COMPACT_STATE.md does not"
            echo "      — verify the compact snapshot is for the current task."
        fi
    fi
fi

echo "PostCompact: COMPACT_STATE.md present, $LINES/$MAX lines."
exit 0
