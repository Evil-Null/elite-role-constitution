#!/bin/bash
# context-guard.sh — Elite Role hook for Kimi CLI 1.43+
#
# Event: UserPromptSubmit (before every user turn)
# Purpose: Monitor context token usage and warn BEFORE automatic compaction
# destroys session continuity. Reads live token_count from Kimi CLI's
# context file and surfaces an early-warning block when approaching the
# compaction threshold.
#
# Math: max_context_size * compaction_trigger_ratio = compaction point.
#       We warn at (trigger_ratio - 0.03) so the agent has time to run
#       the save-state ritual before Kimi auto-compacts.
#
# Hook protocol: exit 0 = allow; stdout appended to agent context.

set -euo pipefail

INPUT=$(cat 2>/dev/null || echo '{}')
SESSION_ID=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('session_id',''))" 2>/dev/null || echo "")

# If we cannot identify the session, silently allow.
if [ -z "$SESSION_ID" ]; then
    exit 0
fi

# Locate the context file for this session.
CONTEXT_FILE=$(find ~/.kimi/sessions -path "*/${SESSION_ID}/context.jsonl" -type f 2>/dev/null | head -1)
if [ -z "$CONTEXT_FILE" ] || [ ! -f "$CONTEXT_FILE" ]; then
    exit 0
fi

# Extract the latest token_count from _usage records.
TOKEN_COUNT=$(grep '"_usage"' "$CONTEXT_FILE" 2>/dev/null | tail -1 | python3 -c "
import sys, json
try:
    print(json.load(sys.stdin).get('token_count', 0))
except Exception:
    print(0)
" 2>/dev/null || echo "0")

# Validate numeric token count.
if ! [[ "$TOKEN_COUNT" =~ ^[0-9]+$ ]] || [ "$TOKEN_COUNT" -eq 0 ]; then
    exit 0
fi

# Read model configuration from Kimi CLI config.
CONFIG_FILE="${HOME}/.kimi/config.toml"
MAX_CTX=262144
RATIO=0.85

if [ -f "$CONFIG_FILE" ]; then
    CFG_MAX=$(grep -oP '(?<=^max_context_size = )\d+' "$CONFIG_FILE" 2>/dev/null | head -1 || true)
    CFG_RATIO=$(grep -oP '(?<=^compaction_trigger_ratio = )[0-9.]+' "$CONFIG_FILE" 2>/dev/null | head -1 || true)
    [ -n "$CFG_MAX" ] && MAX_CTX="$CFG_MAX"
    [ -n "$CFG_RATIO" ] && RATIO="$CFG_RATIO"
fi

# Compute early-warning threshold: 3 percentage points BEFORE compaction trigger.
# If the user configured a custom trigger ratio (e.g. 0.70), we still warn
# 3 pp early (0.67).
WARNING_RATIO=$(python3 -c "r = float('$RATIO') - 0.03; print(r if r > 0 else 0.50)" 2>/dev/null || echo "0.82")
WARNING_TOKENS=$(python3 -c "print(int($MAX_CTX * $WARNING_RATIO))" 2>/dev/null || echo "0")

# Only warn if we have crossed the threshold.
if [ "$TOKEN_COUNT" -ge "$WARNING_TOKENS" ]; then
    PERCENT=$(python3 -c "print(f'{(int($TOKEN_COUNT) / int($MAX_CTX)) * 100:.1f}')" 2>/dev/null || echo "?")
    COMPACT_AT=$(python3 -c "print(int(int($MAX_CTX) * float($RATIO)))" 2>/dev/null || echo "?")

    cat <<EOF
╔════════════════════════════════════════════════════════════════════╗
║  ⚠️  CONTEXT GUARD — Session approaching compaction threshold      ║
╠════════════════════════════════════════════════════════════════════╣
║  Token usage:  ${TOKEN_COUNT} / ${MAX_CTX}  (${PERCENT}%)                        ║
║  Auto-compact triggers at: ${RATIO}  (~${COMPACT_AT} tokens)                      ║
║  Warning threshold: ${WARNING_TOKENS} tokens                                       ║
╠════════════════════════════════════════════════════════════════════╣
║  ACTION REQUIRED: Perform the save-state ritual NOW, before        ║
║  automatic compaction silently truncates context continuity.       ║
║                                                                    ║
║  1. Update memory/CONTEXT.md  → current task + progress            ║
║  2. Update memory/ASSUMPTIONS.md → active risks + P×I scores      ║
║  3. Update memory/DECISIONS.md → recent choices                    ║
║  4. Write memory/COMPACT_STATE.md → compact-safe snapshot          ║
║  5. Update memory/RESUME.md → checkpoint summary                   ║
║  6. Confirm: "State persisted. Ready for compact."                 ║
╚════════════════════════════════════════════════════════════════════╝
EOF
fi

exit 0
