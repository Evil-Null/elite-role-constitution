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
    # R3 #7 fix: the hook used to print "L1 applies" and exit 0, which
    # is exactly the doctrinal contradiction L1 forbids. A missing
    # snapshot IS the unknown state — block the continuation until the
    # agent writes the file.
    cat <<'EOF' >&2
BLOCKED by elite-role PostCompact hook (L1 UNKNOWN=STOP):
memory/COMPACT_STATE.md is missing — the compact ritual did not
produce a snapshot. Continuing now would silently lose cross-compact
continuity. Write the snapshot first (SESSION_RITUAL.md Ritual 3),
then re-run the compact.
EOF
    exit 2
fi

# Sanity-check the file's freshness and shape.
# NB: same `|| echo` fix as session-end.sh (R2 #4).
LINES=$(awk 'END{print NR}' memory/COMPACT_STATE.md)
MAX="$(grep -oP '(?<=^> \*\*Max Size:\*\* )\d+(?= lines)' memory/COMPACT_STATE.md 2>/dev/null | head -1 || true)"
MAX="${MAX:-40}"

if [ "$LINES" -gt "$MAX" ]; then
    echo "WARN: memory/COMPACT_STATE.md is $LINES lines > $MAX cap"
    echo "      Rotate per ROLLUP_POLICY.md before further compact cycles."
fi

# Cross-check: COMPACT_STATE should mention the same active task as CONTEXT.
# Use grep -F (fixed-string) plus -- so a task token starting with "-" or
# containing regex metacharacters cannot inject options or break the
# regex (R2 #6).
if [ -f memory/CONTEXT.md ]; then
    TASK_IN_CTX=$(grep -i "active task\|current task" memory/CONTEXT.md | head -1 || echo "")
    if [ -n "$TASK_IN_CTX" ]; then
        FIRST_WORD=$(echo "$TASK_IN_CTX" | awk -F': ' '{print $2}' | awk '{print $1}')
        if [ -n "$FIRST_WORD" ] && ! grep -qiF -- "$FIRST_WORD" memory/COMPACT_STATE.md; then
            echo "WARN: CONTEXT.md mentions task '$FIRST_WORD' but COMPACT_STATE.md does not"
            echo "      — verify the compact snapshot is for the current task."
        fi
    fi
fi

echo "PostCompact: COMPACT_STATE.md present, $LINES/$MAX lines."
exit 0
