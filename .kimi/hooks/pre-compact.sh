#!/bin/bash
# pre-compact.sh — Elite Role hook for Kimi CLI 1.43+
#
# Event: PreCompact
# Purpose: AUTOMATICALLY write memory/COMPACT_STATE.md before compaction.
# Also generates a ritual token for post-compact verification.
#
# v3.0 hardening:
#   - Uses _lib.sh helpers (cwd, atomic write, token generation)
#   - Fixes TASK extraction (matches "## Current Task", not just "## Active Task")
#   - Generates random ritual token for bypass resistance

set -euo pipefail

INPUT=$(cat 2>/dev/null || echo '{}')
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_lib.sh"

TRIGGER=$(er_json_str "$INPUT" "trigger")
[ -z "$TRIGGER" ] && TRIGGER="manual"

TOKEN_COUNT=$(er_json_str "$INPUT" "token_count")
[ -z "$TOKEN_COUNT" ] && TOKEN_COUNT="?"

CWD=$(er_get_cwd "$INPUT")

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
    TASK=$(grep -iE "^## Current Task|^## Active Task|^## Current Phase" "memory/CONTEXT.md" | head -2 | sed 's/^## //' | tr '\n' '; ' || true)
fi

# Extract latest assumptions if they exist
ASSUMPTIONS=""
if [ -f "memory/ASSUMPTIONS.md" ]; then
    ASSUMPTIONS=$(tail -n 5 "memory/ASSUMPTIONS.md" 2>/dev/null | grep "^- \|^[0-9]\. " | head -3 || true)
fi

# Generate ritual token for post-compact verification
RITUAL_TOKEN=$(er_generate_ritual_token)

# Write COMPACT_STATE.md atomically
TIMESTAMP=$(date -Iseconds)

{
    cat <<EOF
# COMPACT_STATE

> **Generated:** $TIMESTAMP
> **Trigger:** $TRIGGER · **Token count:** $TOKEN_COUNT
> **Ritual Token:** $RITUAL_TOKEN
> **Max Size:** 40 lines

## Active Task
${TASK:-"(not recorded in CONTEXT.md)"}

## Key Assumptions
${ASSUMPTIONS:-"(none recorded)"}

## Files Present
EOF
    for f in memory/CONTEXT.md memory/RESUME.md memory/ASSUMPTIONS.md memory/DECISIONS.md memory/AUDIT_LOG.md; do
        if [ -f "$f" ]; then
            echo "- $f: $(wc -l <"$f") lines"
        fi
    done
    echo ""
    echo "---"
} | er_atomic_write "memory/COMPACT_STATE.md"

LINES=$(wc -l <"memory/COMPACT_STATE.md")
echo "PreCompact: COMPACT_STATE.md written ($LINES lines)"

# Elite recovery reminder — emitted to AI context via stdout
cat <<'ELITE'
╔════════════════════════════════════════════════════════════════════╗
║  🔄 ELITE RECOVERY — Post-Compact Rehydration Protocol             ║
╠════════════════════════════════════════════════════════════════════╣
║  COMPACT_STATE.md has been auto-written with the latest snapshot. ║
║                                                                    ║
║  RESTORE FULL OPERATIONAL STATE IN THIS ORDER:                    ║
║  1. memory/COMPACT_STATE.md  → task summary + assumptions         ║
║  2. memory/CONTEXT.md        → current task details               ║
║  3. memory/RESUME.md         → checkpoint                         ║
║  4. memory/ASSUMPTIONS.md    → active risks (P×I)                 ║
║  5. memory/DECISIONS.md      → recent choices                     ║
║                                                                    ║
║  Confirm: "Elite state restored. Active task: [X]. Next: [Y]."     ║
╚════════════════════════════════════════════════════════════════════╝
ELITE

exit 0
