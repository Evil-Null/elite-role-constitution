#!/bin/bash
# session-end.sh — Elite Role hook for Kimi CLI 1.43+
#
# Event: SessionEnd  (matcher: reason)
# Purpose: capture the "save state" ritual — write a minimal checkpoint
# into memory/RESUME.md without violating its 40-line cap. Heavier
# writes (DECISIONS.md, AUDIT_LOG.md) are left to the agent's explicit
# discretion, since the hook lacks the semantic context to summarise
# task progress correctly.
#
# Protocol: exit 0 (allow); stdout NOT added to context for SessionEnd.
# The hook side-effects (file writes) are the deliverable.

set -euo pipefail

# Consume stdin (payload not used by this hook)
cat >/dev/null || true

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

if [ ! -f memory/RESUME.md ]; then
    # Don't create the file from scratch — that's a structural change
    # outside the hook's mandate. Just exit.
    exit 0
fi

# Touch the "Last updated" line if present without exceeding the cap.
# This is a minimal, idempotent mutation. The agent is still
# responsible for the *content* of the checkpoint.
TIMESTAMP=$(date -Iseconds)

# If RESUME.md has a "**Last hook autosave:**" line, update it; otherwise
# append one line (only if doing so stays under the declared cap).
# NB: `|| echo "40"` after a pipe never fires (head returns 0 on empty
# input). Default with parameter expansion AFTER the pipe is the only
# correct pattern (R2 #4).
MAX="$(grep -oP '(?<=^> \*\*Max Size:\*\* )\d+(?= lines)' memory/RESUME.md 2>/dev/null | head -1 || true)"
MAX="${MAX:-40}"
CURRENT=$(awk 'END{print NR}' memory/RESUME.md)

if grep -q "^\*\*Last hook autosave:\*\*" memory/RESUME.md; then
    # Cross-platform sed in-place (BSD/GNU agnostic)
    tmpf=$(mktemp)
    sed "s|^\*\*Last hook autosave:\*\*.*|**Last hook autosave:** $TIMESTAMP|" memory/RESUME.md >"$tmpf"
    mv "$tmpf" memory/RESUME.md
elif [ "$CURRENT" -lt "$MAX" ]; then
    printf '\n**Last hook autosave:** %s\n' "$TIMESTAMP" >>memory/RESUME.md
fi

exit 0
