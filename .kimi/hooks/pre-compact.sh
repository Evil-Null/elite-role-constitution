#!/bin/bash
# pre-compact.sh — Elite Role hook for Kimi CLI 1.43+
#
# Event: PreCompact
# Purpose: AUTOMATICALLY write memory/COMPACT_STATE.md before compaction.
# The snapshot is written to the project cwd (from stdin JSON), NOT to
# the elite-role-constitution repo. This fixes the design flaw where the
# hook only emitted a reminder that the agent could never act on during
# automatic compaction.

set -euo pipefail

INPUT=$(cat 2>/dev/null || echo '{}')
TRIGGER=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('trigger','manual'))" 2>/dev/null || echo "manual")
TOKEN_COUNT=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('token_count','?'))" 2>/dev/null || echo "?")
CWD=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('cwd',''))" 2>/dev/null || echo "")

if [ -z "$CWD" ] || [ ! -d "$CWD" ]; then
    echo "WARN: PreCompact — no valid cwd in event payload, cannot write COMPACT_STATE.md" >&2
    exit 0
fi

cd "$CWD"

# If no memory/ dir exists, nothing to snapshot
if [ ! -d "memory" ]; then
    echo "PreCompact: no memory/ dir in $CWD — skipping snapshot"
    exit 0
fi

# Extract active task from CONTEXT.md if it exists
TASK=""
if [ -f "memory/CONTEXT.md" ]; then
    TASK=$(grep -i "^## Active Task\|^## Current Phase" "memory/CONTEXT.md" | head -2 | sed 's/^## //' | tr '\n' '; ' || true)
fi

# Extract latest assumptions if they exist
ASSUMPTIONS=""
if [ -f "memory/ASSUMPTIONS.md" ]; then
    ASSUMPTIONS=$(tail -n 5 "memory/ASSUMPTIONS.md" 2>/dev/null | grep "^- \|^[0-9]\. " | head -3 || true)
fi

# Write COMPACT_STATE.md
TIMESTAMP=$(date -Iseconds)
cat > "memory/COMPACT_STATE.md" <<EOF
# COMPACT_STATE

> **Generated:** $TIMESTAMP  
> **Trigger:** $TRIGGER · **Token count:** $TOKEN_COUNT  
> **Max Size:** 40 lines

## Active Task
${TASK:-"(not recorded in CONTEXT.md)"}

## Key Assumptions
${ASSUMPTIONS:-"(none recorded)"}

## Files Present
EOF

for f in memory/CONTEXT.md memory/RESUME.md memory/ASSUMPTIONS.md memory/DECISIONS.md memory/AUDIT_LOG.md; do
    if [ -f "$f" ]; then
        echo "- $f: $(wc -l <"$f") lines" >> "memory/COMPACT_STATE.md"
    fi
done

echo "" >> "memory/COMPACT_STATE.md"
echo "---" >> "memory/COMPACT_STATE.md"
echo "PreCompact: COMPACT_STATE.md written ($(wc -l <"memory/COMPACT_STATE.md") lines)"
exit 0
