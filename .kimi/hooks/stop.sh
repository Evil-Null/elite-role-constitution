#!/bin/bash
# stop.sh — Elite Role hook for Kimi CLI 1.43+
#
# Event: Stop
# Purpose: L6 anti-self-deception reminder.
#
# v3.0: sources _lib.sh for consistency (cwd-aware if future needs arise).

set -euo pipefail

INPUT=$(cat 2>/dev/null || echo '{}')
# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_lib.sh"

ACTIVE=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('stop_hook_active',False))" 2>/dev/null || echo "false")

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
