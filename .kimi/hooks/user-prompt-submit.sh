#!/bin/bash
# user-prompt-submit.sh — Elite Role hook for Kimi CLI 1.43+
#
# Event: UserPromptSubmit  (C1 schema: kimi_cli/hooks/events.py:64)
# Payload: {hook_event_name, session_id, cwd, prompt}
#
# Purpose: cache the most recent user prompt to disk, keyed by
# session_id, so PreToolUse can read it later to enforce the L4 PEV
# [APPROVED] gate (C4). The hook NEVER blocks — caching is its only
# job — so use exit 0 unconditionally.

set -euo pipefail

INPUT=$(cat 2>/dev/null || echo '{}')

SESSION_ID=$(printf '%s' "$INPUT" | python3 -c "
import sys, json
try:
    print(json.load(sys.stdin).get('session_id', ''))
except Exception:
    pass
" 2>/dev/null || echo "")

if [ -z "$SESSION_ID" ]; then
    exit 0
fi

PROMPT=$(printf '%s' "$INPUT" | python3 -c "
import sys, json
try:
    print(json.load(sys.stdin).get('prompt', ''))
except Exception:
    pass
" 2>/dev/null || echo "")

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
STATE_DIR="$PROJECT_ROOT/.kimi/state"
mkdir -p "$STATE_DIR" 2>/dev/null || exit 0

# Atomic write so a concurrent PreToolUse never reads a half-written file.
TMP="$STATE_DIR/.prompt-${SESSION_ID}.tmp.$$"
trap 'rm -f "$TMP"' EXIT
printf '%s' "$PROMPT" >"$TMP"
mv "$TMP" "$STATE_DIR/prompt-${SESSION_ID}.txt"
trap - EXIT

exit 0
