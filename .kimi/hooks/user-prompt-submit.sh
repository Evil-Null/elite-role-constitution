#!/bin/bash
# user-prompt-submit.sh — Elite Role hook for Kimi CLI 1.43+
#
# Event: UserPromptSubmit  (C1 schema: kimi_cli/hooks/events.py:64)
# Payload: {hook_event_name, session_id, cwd, prompt}
#
# Purpose: cache the most recent user prompt to disk, keyed by
# session_id, so PreToolUse can read it later to enforce the L4 PEV
# [APPROVED] gate (C4). The hook NEVER blocks.
#
# v3.0: uses global state dir (~/.kimi/state/elite-role/) instead of
# hardcoded elite-role-constitution repo path.

set -euo pipefail

INPUT=$(cat 2>/dev/null || echo '{}')
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_lib.sh"

SESSION_ID=$(er_get_session_id "$INPUT")

if [ -z "$SESSION_ID" ]; then
    exit 0
fi

PROMPT=$(er_json_str "$INPUT" "prompt")

STATE_DIR=$(er_get_state_dir)

# Atomic write so a concurrent PreToolUse never reads a half-written file.
TMP="$STATE_DIR/.prompt-${SESSION_ID}.tmp.$$"
trap 'rm -f "$TMP"' EXIT
printf '%s' "$PROMPT" >"$TMP"
mv "$TMP" "$STATE_DIR/prompt-${SESSION_ID}.txt"
trap - EXIT

exit 0
