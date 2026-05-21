#!/bin/bash
# post-tool-use.sh — Elite Role hook for Kimi CLI 1.43+
#
# Event: PostToolUse
# Purpose: audit trail + L2 citation heuristic + C5 telemetry.
#
# v3.0: audit logs are written to the current project's .kimi/audit/
# (cwd from JSON payload), not hardcoded to elite-role-constitution.

set -euo pipefail

INPUT=$(cat)
# shellcheck disable=SC1091
source "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/_lib.sh"

TOOL=$(er_json_str "$INPUT" "tool_name")
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

CONTENT=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    ti = d.get('tool_input', {})
    parts = []
    for k in ('content', 'new_string', 'replacement', 'text'):
        v = ti.get(k)
        if isinstance(v, str): parts.append(v)
    edits = ti.get('edits') or ti.get('changes')
    if isinstance(edits, list):
        for e in edits:
            if isinstance(e, dict):
                for k in ('new_string','content','replacement'):
                    v = e.get(k)
                    if isinstance(v, str): parts.append(v)
    print('\\n'.join(parts))
except Exception:
    pass
" 2>/dev/null || echo "")

L2_HAS_CITE="false"
L2_FLAGGED="false"
if [ -n "$CONTENT" ]; then
    if printf '%s' "$CONTENT" | grep -qiE '\b(verified|confirmed|i checked|tested|should work|i made sure)\b'; then
        # shellcheck disable=SC2016
        if printf '%s' "$CONTENT" | grep -qE '[a-zA-Z0-9_./-]+:[0-9]+|`[^`]+`|https?://'; then
            L2_HAS_CITE="true"
        else
            L2_FLAGGED="true"
            cat <<EOF >&2
elite-role · L2 advisory (post-tool-use):
  Content written by this tool call uses "verified" / "confirmed" /
  similar trigger language but contains no obvious citation marker
  (file:line, \`backtick\`, or URL). This is a soft heuristic; if you
  cited evidence verbally outside the tool input, this warning can be
  ignored. Otherwise, add the citation inline.
  Tool: $TOOL  Target: $FILE
EOF
        fi
    fi
fi

CWD=$(er_get_cwd "$INPUT")
LOG_DIR="$CWD/.kimi/audit"
mkdir -p "$LOG_DIR" 2>/dev/null || exit 0

LOG_FILE="$LOG_DIR/post-tool-use-$(TZ=UTC date -u +%Y%m%d).log"
printf '%s | %s | %s\n' "$(TZ=UTC date -u -Iseconds)" "$TOOL" "$FILE" >>"$LOG_FILE" 2>/dev/null || true

SIGNALS_FILE="$LOG_DIR/signals-$(TZ=UTC date -u +%Y%m%d).jsonl"
SESSION_ID=$(er_get_session_id "$INPUT")
printf '{"ts":"%s","event":"PostToolUse","session_id":"%s","tool":"%s","l2_trigger":%s,"l2_has_cite":%s,"l2_flagged":%s}\n' \
    "$(TZ=UTC date -u -Iseconds)" "$SESSION_ID" "$TOOL" \
    "$([ -n "$CONTENT" ] && printf '%s' "$CONTENT" | grep -qiE '\b(verified|confirmed|i checked|tested|should work|i made sure)\b' && echo true || echo false)" \
    "$L2_HAS_CITE" "$L2_FLAGGED" \
    >>"$SIGNALS_FILE" 2>/dev/null || true

exit 0
