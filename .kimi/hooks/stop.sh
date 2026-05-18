#!/bin/bash
# stop.sh — Elite Role hook for Kimi CLI 1.43+
#
# Event: Stop  (turn end, no error)
# Purpose: act as the doctrine's "L6 anti-self-deception check"
# reminder. The hook cannot read the response content itself, so it
# cannot verify L6 was performed — but it can keep the procedure
# visible by emitting a structured reminder into context for the next
# turn.

set -euo pipefail

INPUT=$(cat 2>/dev/null || echo '{}')
ACTIVE=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('stop_hook_active',False))" 2>/dev/null || echo "false")

# Prevent infinite-recursion if Kimi re-invokes after our reminder.
if [ "$ACTIVE" = "True" ] || [ "$ACTIVE" = "true" ]; then
    exit 0
fi

cat <<'EOF'
elite-role · Stop reminder
  L6 anti-self-deception: before declaring the task done, the response
  must have listed 3 concrete ways the result could be wrong, with a
  one-line rebuttal for each. If this turn mutated state and that
  check is missing, raise it before the next user turn.
EOF

exit 0
