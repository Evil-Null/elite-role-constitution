#!/bin/bash
# post-tool-use.sh — Elite Role hook for Kimi CLI 1.43+
#
# Event: PostToolUse  (matcher: WriteFile|StrReplaceFile|Shell)
# Purpose: light-touch audit trail — record one line per state-changing
# tool call into a *separate* log (not memory/AUDIT_LOG.md, which has a
# semantic structure the agent owns). Failures here must not block the
# turn.

set -euo pipefail

INPUT=$(cat)
TOOL=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('tool_name',''))" 2>/dev/null || echo "?")
FILE=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    ti = d.get('tool_input', {})
    for k in ('file_path','command','path'):
        if k in ti and ti[k]:
            v = str(ti[k])[:200]; print(v); break
except Exception:
    pass
" 2>/dev/null || echo "")

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOG_DIR="$PROJECT_ROOT/.kimi/audit"
mkdir -p "$LOG_DIR" 2>/dev/null || exit 0

# Pin both filename and in-file timestamp to UTC so log rotation does
# not depend on the host's $TZ setting (R2 #8).
LOG_FILE="$LOG_DIR/post-tool-use-$(TZ=UTC date -u +%Y%m%d).log"

printf '%s | %s | %s\n' "$(TZ=UTC date -u -Iseconds)" "$TOOL" "$FILE" >>"$LOG_FILE" 2>/dev/null || true

# Always allow
exit 0
