#!/bin/bash
# notification.sh — Elite Role hook for Kimi CLI 1.43+
#
# Event: Notification  (matcher: permission_prompt / general)
# Purpose: send a desktop notification when the agent needs human
# attention (L5 escalations, permission prompts, STOP-level risks).
# Falls back to a stderr log if no desktop notifier is available.

set -euo pipefail

INPUT=$(cat 2>/dev/null || echo '{}')
TITLE=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('title','Kimi CLI · Elite Role'))" 2>/dev/null || echo "Kimi CLI · Elite Role")
BODY=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('body','Attention needed'))" 2>/dev/null || echo "Attention needed")
SEVERITY=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('severity','info'))" 2>/dev/null || echo "info")

# Linux: notify-send (libnotify). macOS: osascript. Fall back to stderr.
if command -v notify-send >/dev/null 2>&1; then
    notify-send -u "$SEVERITY" "$TITLE" "$BODY" 2>/dev/null || true
elif command -v osascript >/dev/null 2>&1; then
    osascript -e "display notification \"$BODY\" with title \"$TITLE\"" 2>/dev/null || true
else
    echo "[elite-role notification:$SEVERITY] $TITLE — $BODY" >&2
fi

exit 0
