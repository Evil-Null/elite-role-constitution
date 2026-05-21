#!/bin/bash
# session-end.sh — Elite Role hook for Kimi CLI 1.43+
#
# Event: SessionEnd  (matcher: reason)
# Purpose: capture the "save state" ritual — write a minimal checkpoint
# into memory/RESUME.md without violating its 40-line cap.
#
# v3.0: cwd-aware — updates RESUME.md in the current working directory
# (from JSON payload), not hardcoded to elite-role-constitution.

set -euo pipefail

INPUT=$(cat 2>/dev/null || echo '{}')
# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_lib.sh"

CWD=$(er_get_cwd "$INPUT")
cd "$CWD"

if [ ! -f memory/RESUME.md ]; then
    # Don't create the file from scratch — that's a structural change
    # outside the hook's mandate. Just exit.
    exit 0
fi

# Touch the "Last updated" line if present without exceeding the cap.
TIMESTAMP=$(date -Iseconds)

MAX="$(grep -oP '(?<=^> \*\*Max Size:\*\* )\d+(?= lines)' memory/RESUME.md 2>/dev/null | head -1 || true)"
MAX="${MAX:-40}"
CURRENT=$(awk 'END{print NR}' memory/RESUME.md)

if grep -q "^\*\*Last hook autosave:\*\*" memory/RESUME.md; then
    tmpf="memory/.RESUME.md.hook.$$"
    # shellcheck disable=SC2064
    trap "rm -f '$tmpf'" EXIT
    sed "s|^\*\*Last hook autosave:\*\*.*|\*\*Last hook autosave:\*\* $TIMESTAMP|" memory/RESUME.md >"$tmpf"
    mv "$tmpf" memory/RESUME.md
    trap - EXIT
elif [ "$CURRENT" -lt "$MAX" ]; then
    printf '\n**Last hook autosave:** %s\n' "$TIMESTAMP" >>memory/RESUME.md
fi

exit 0
