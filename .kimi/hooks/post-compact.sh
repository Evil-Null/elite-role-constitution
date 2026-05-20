#!/bin/bash
# post-compact.sh — Elite Role hook for Kimi CLI 1.43+
#
# Event: PostCompact
# Purpose: verify COMPACT_STATE.md in the PROJECT cwd (from stdin JSON),
# not the elite-role-constitution repo. Uses cwd field from Kimi's event
# payload so it works regardless of where the hook script lives.

set -euo pipefail

INPUT=$(cat 2>/dev/null || echo '{}')
CWD=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('cwd',''))" 2>/dev/null || echo "")

if [ -z "$CWD" ] || [ ! -d "$CWD" ]; then
    echo "WARN: PostCompact — no valid cwd in event payload, skipping verification" >&2
    exit 0
fi

cd "$CWD"

echo "=== Elite Role · PostCompact verification ==="

if [ ! -f "memory/COMPACT_STATE.md" ]; then
    cat <<'EOF' >&2
BLOCKED by elite-role PostCompact hook (L1 UNKNOWN=STOP):
memory/COMPACT_STATE.md is missing — the compact ritual did not
produce a snapshot. Continuing now would silently lose cross-compact
continuity.
EOF
    exit 2
fi

LINES=$(awk 'END{print NR}' memory/COMPACT_STATE.md)
MAX="$(grep -oP '(?<=^> \*\*Max Size:\*\* )\d+(?= lines)' memory/COMPACT_STATE.md 2>/dev/null | head -1 || true)"
MAX="${MAX:-40}"

if [ "$LINES" -gt "$MAX" ]; then
    echo "WARN: memory/COMPACT_STATE.md is $LINES lines > $MAX cap"
    echo "      Rotate per ROLLUP_POLICY.md before further compact cycles."
fi

if [ -f "memory/CONTEXT.md" ]; then
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
