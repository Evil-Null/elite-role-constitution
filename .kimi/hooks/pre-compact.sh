#!/bin/bash
# pre-compact.sh — Elite Role hook for Kimi CLI 1.43+
#
# Event: PreCompact  (trigger reason in stdin JSON)
# Purpose: emit a context snapshot before Kimi compresses history, so
# the post-compact verification has something to compare against. The
# snapshot goes to stdout (added to context per exit-0 contract), NOT
# to a file — writing memory/COMPACT_STATE.md from a hook risks
# violating its 40-line cap with stale residue.
#
# The agent is still expected to perform the doctrinal compact ritual
# in the response (see SESSION_RITUAL.md Ritual 3-4). This hook is the
# *trigger reminder*, not the substitute.

set -euo pipefail

INPUT=$(cat 2>/dev/null || echo '{}')
TRIGGER=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('trigger','manual'))" 2>/dev/null || echo "manual")
TOKEN_COUNT=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('token_count','?'))" 2>/dev/null || echo "?")

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

echo "=== Elite Role · PreCompact snapshot ==="
echo "Trigger: $TRIGGER · Token count: $TOKEN_COUNT · At: $(date -Iseconds)"
echo ""
echo "Per SESSION_RITUAL.md Ritual 3:"
echo "1. Confirm active assumptions are recorded in memory/ASSUMPTIONS.md"
echo "2. Confirm current task is captured in memory/CONTEXT.md"
echo "3. Write memory/COMPACT_STATE.md before compaction proceeds"
echo "4. PostCompact will verify the state survived"
echo ""

# Surface key indicators
for f in memory/CONTEXT.md memory/COMPACT_STATE.md memory/ASSUMPTIONS.md; do
    if [ -f "$f" ]; then
        echo "$f: $(wc -l <"$f") lines"
    fi
done

exit 0
