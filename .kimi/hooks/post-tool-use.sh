#!/bin/bash
# post-tool-use.sh — Elite Role hook for Kimi CLI 1.43+
#
# Event: PostToolUse  (matcher: WriteFile|StrReplaceFile|Shell)
# Purpose:
#   (1) light-touch audit trail — one line per state-changing tool call;
#   (2) C2 L2 advisory heuristic — scan tool_input content for uncited
#       claim patterns and emit a warning to stderr if the content makes
#       a "verified" / "confirmed" / etc. claim without an obvious
#       citation marker (file:line, code-fence, URL). PostToolUse stderr
#       does NOT block (block requires exit 2 from this hook); the
#       warning is fed to the agent's next-turn context as a soft cue.
#   (3) C5 telemetry — emit one JSONL line per call to
#       .kimi/audit/signals-YYYYMMDD.jsonl with the L2 signal bool.
# Failures here must not block the turn.

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

# Extract written content (for WriteFile / StrReplaceFile) for L2 scan.
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
    print('\n'.join(parts))
except Exception:
    pass
" 2>/dev/null || echo "")

# L2 citation heuristic — trigger word present AND no citation marker.
# Triggers: verified, confirmed, checked, tested, should work, I made sure
# Citation markers: file:line  OR  `backtick code`  OR  http URL
L2_HAS_CITE="false"
L2_FLAGGED="false"
if [ -n "$CONTENT" ]; then
    if printf '%s' "$CONTENT" | grep -qiE '\b(verified|confirmed|i checked|tested|should work|i made sure)\b'; then
        # Trigger present — does the content contain a citation marker too?
        # shellcheck disable=SC2016  # backtick inside single-quoted regex is intentional, not a subshell.
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

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOG_DIR="$PROJECT_ROOT/.kimi/audit"
mkdir -p "$LOG_DIR" 2>/dev/null || exit 0

# Pin filename + in-file timestamp to UTC.
LOG_FILE="$LOG_DIR/post-tool-use-$(TZ=UTC date -u +%Y%m%d).log"
printf '%s | %s | %s\n' "$(TZ=UTC date -u -Iseconds)" "$TOOL" "$FILE" >>"$LOG_FILE" 2>/dev/null || true

# C5 telemetry — one JSONL line per call.
SIGNALS_FILE="$LOG_DIR/signals-$(TZ=UTC date -u +%Y%m%d).jsonl"
SESSION_ID=$(echo "$INPUT" | python3 -c "import sys,json; print(json.load(sys.stdin).get('session_id',''))" 2>/dev/null || echo "")
printf '{"ts":"%s","event":"PostToolUse","session_id":"%s","tool":"%s","l2_trigger":%s,"l2_has_cite":%s,"l2_flagged":%s}\n' \
    "$(TZ=UTC date -u -Iseconds)" "$SESSION_ID" "$TOOL" \
    "$([ -n "$CONTENT" ] && printf '%s' "$CONTENT" | grep -qiE '\b(verified|confirmed|i checked|tested|should work|i made sure)\b' && echo true || echo false)" \
    "$L2_HAS_CITE" "$L2_FLAGGED" \
    >>"$SIGNALS_FILE" 2>/dev/null || true

# Always allow (PostToolUse cannot block; only emits advisory).
exit 0
