#!/bin/bash
# notification.sh — Elite Role hook for Kimi CLI 1.43+
#
# Event: Notification
# Purpose: surface STOP-level escalations (L5 ≥ 19, permission prompts,
# critical failures) to the user. Falls back to a stderr log if no
# desktop notifier is available.
#
# Security fix (R2 #1): never interpolate untrusted JSON fields into a
# string that becomes AppleScript source. osascript receives the payload
# via argv positions instead, eliminating the command-injection vector.

set -euo pipefail

INPUT="$(cat 2>/dev/null || echo '{}')"

TITLE="$(printf '%s' "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('title','Kimi CLI · Elite Role'))" 2>/dev/null || echo "Kimi CLI · Elite Role")"
BODY="$(printf '%s' "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('body','Attention needed'))" 2>/dev/null || echo "Attention needed")"
SEVERITY="$(printf '%s' "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('severity','normal'))" 2>/dev/null || echo "normal")"

# notify-send only accepts low|normal|critical. Map other inputs.
case "$SEVERITY" in
    low|normal|critical) ;;
    info|debug)        SEVERITY="low" ;;
    warning|warn|error|fatal) SEVERITY="critical" ;;
    *)                 SEVERITY="normal" ;;
esac

# Track whether *any* notifier path succeeded so we can fall back to
# stderr when notify-send / osascript exist but fail (no D-Bus, headless,
# Apple Events disabled, etc.). The bonus finding from R3 noted that
# `... || true` was silently swallowing real notifier failures.
DELIVERED=0

if command -v notify-send >/dev/null 2>&1; then
    if notify-send -u "$SEVERITY" -- "$TITLE" "$BODY" 2>/dev/null; then
        DELIVERED=1
    fi
fi

if [ "$DELIVERED" -eq 0 ] && command -v osascript >/dev/null 2>&1; then
    # Pass through argv — AppleScript reads them by index, no string
    # interpolation, no injection surface.
    if osascript - "$TITLE" "$BODY" <<'APPLESCRIPT' 2>/dev/null; then
on run argv
    set theTitle to (item 1 of argv)
    set theBody  to (item 2 of argv)
    display notification theBody with title theTitle
end run
APPLESCRIPT
        DELIVERED=1
    fi
fi

if [ "$DELIVERED" -eq 0 ]; then
    # Neither notifier exists OR both failed at runtime — log to stderr
    # so the failure is visible instead of silently dropped.
    printf '[elite-role notification:%s] %s — %s\n' "$SEVERITY" "$TITLE" "$BODY" >&2
fi

exit 0
