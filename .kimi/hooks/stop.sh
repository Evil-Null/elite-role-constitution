#!/bin/bash
# stop.sh — Elite Role hook for Kimi CLI 1.43+
#
# Event: Stop  (turn end, no error)
# Purpose: act as the doctrine's "L6 anti-self-deception check"
# reminder. The Stop payload exposes only {hook_event_name, session_id,
# cwd, stop_hook_active} (verified C1, kimi_cli/hooks/events.py:73);
# the agent's response text is NOT visible, so L6 cannot be
# mechanically verified for the primary agent. The hook keeps the
# procedure visible by emitting a structured reminder. SubagentStop
# (response IS visible there) would be where mechanical verification
# could land in a future phase.

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

  (Mechanical enforcement is not possible here — Stop payload omits the
  response text by Kimi design. See agent/elite.system.md §"Hook Engine
  Semantics" for the full schema and the C2 PostToolUse fallback that
  scans tool_output for uncited-claim heuristics.)
EOF

exit 0
