#!/bin/bash
# pre-shell.sh — Elite Role hook for Kimi CLI 1.43+
#
# Event: PreToolUse  (matcher: Shell)
# Purpose: close the bypass gap for Shell-tool writes.
#
# v3.0: C4 state dir uses global ~/.kimi/state/elite-role/ via _lib.sh.

set -euo pipefail
shopt -s nocasematch

HOOKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HOOKS_DIR/_patterns.sh"
source "$HOOKS_DIR/_lib.sh"

# C4 L4 PEV approval check — duplicated from pre-tool-use.sh.
c4_check_approval() {
    local session_id="$1"
    local state_dir
    state_dir=$(er_get_state_dir)
    local strict_sentinel="$state_dir/c4-strict-mode"
    local prompt_file="$state_dir/prompt-${session_id}.txt"
    [ -z "$session_id" ] && return 0
    [ ! -f "$prompt_file" ] && return 0
    local prompt
    prompt="$(cat "$prompt_file" 2>/dev/null || echo '')"
    [ -z "$prompt" ] && return 0
    if printf '%s' "$prompt" | grep -qE '\[APPROVED\]|\blight effort\b|\bchallenge-grade\b'; then
        return 0
    fi
    if [ -f "$strict_sentinel" ]; then
        cat <<EOF >&2
BLOCKED by elite-role pre-shell hook (L4 PEV gate — strict mode):
The current user prompt does not contain an approval token. State-
mutating shell commands require [APPROVED] in the user's most recent
message, or "light effort" / "challenge-grade".

Override: re-send with [APPROVED] appended, OR disable strict mode:
  rm $strict_sentinel
EOF
        return 2
    fi
    cat <<EOF >&2
elite-role · L4 PEV advisory (shell):
  State-mutating shell command fired without an [APPROVED] token in
  the user's most recent message. Activate strict-block mode:
    touch $strict_sentinel
EOF
    return 0
}

INPUT="$(cat)"

# Fail-closed on parse failure
if ! printf '%s' "$INPUT" | python3 -c "import sys,json; json.load(sys.stdin)" 2>/dev/null; then
    echo "BLOCKED by elite-role pre-shell hook: malformed JSON payload (fail-closed)." >&2
    exit 2
fi

CMD="$(printf '%s' "$INPUT" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('command', ''))
except Exception:
    pass
" 2>/dev/null || true)"

if [ -z "$CMD" ]; then
    exit 0
fi

# C4 — apply L4 PEV gate only to state-mutating shell patterns.
if printf '%s' "$CMD" | grep -qE '(>>?|tee|^cp\b|^mv\b|^install\b|sed -i|sed --in-place|dd\s+of=|\b(rm|shred|truncate|chmod|chown|chgrp)\b)'; then
    SESSION_ID="$(printf '%s' "$INPUT" | python3 -c "
import sys, json
try: print(json.load(sys.stdin).get('session_id',''))
except Exception: pass
" 2>/dev/null || echo "")"
    if ! c4_check_approval "$SESSION_ID"; then
        exit 2
    fi
fi

is_protected() {
    local raw="$1"
    local base="${raw##*/}"
    local real
    real="$(readlink -f "$raw" 2>/dev/null || printf '%s' "$raw")"
    local real_base="${real##*/}"
    local safe
    for safe in "${WHITELIST_PATTERNS[@]}"; do
        case "$base"      in $safe) return 1 ;; esac
        case "$real_base" in $safe) return 1 ;; esac
    done
    local pat
    for pat in "${PROTECTED_PATTERNS[@]}"; do
        case "$base"      in $pat) return 0 ;; esac
        case "$real_base" in $pat) return 0 ;; esac
    done
    return 1
}

is_catastrophic() {
    local raw="$1"
    local norm="${raw%/}"
    [ -z "$norm" ] && norm="/"
    local cp
    for cp in "${CATASTROPHIC_PATHS[@]}"; do
        [ "$norm" = "$cp" ] && return 0
    done
    return 1
}

TARGETS="$(KIMI_PRESHELL_CMD="$CMD" python3 <<'PY' 2>/dev/null || true
import os, shlex, re
cmd = os.environ.get('KIMI_PRESHELL_CMD', '')
try:
    tokens = shlex.split(cmd, posix=True)
except ValueError:
    tokens = cmd.split()
targets = []
i = 0
while i < len(tokens):
    t = tokens[i]
    if t in ('>', '>>', '&>'):
        if i + 1 < len(tokens): targets.append(tokens[i+1])
        i += 2; continue
    m = re.match(r'^[12&]?>{1,2}(.+)$', t)
    if m and m.group(1) and m.group(1) not in ('&1', '&2'):
        targets.append(m.group(1))
    if t == 'tee' or t.endswith('/tee'):
        j = i + 1
        while j < len(tokens) and not tokens[j].startswith('-'):
            targets.append(tokens[j]); j += 1
    if t.startswith('of='):
        targets.append(t[3:])
    if t in ('cp', 'mv', 'install') or t.endswith('/cp') or t.endswith('/mv') or t.endswith('/install'):
        j = len(tokens) - 1
        while j > i and tokens[j].startswith('-'):
            j -= 1
        if j > i: targets.append(tokens[j])
    if t == 'sed' or t.endswith('/sed'):
        for u in tokens[i+1:]:
            if not u.startswith('-'):
                targets.append(u)
    if t in ('rm', 'shred', 'truncate') or t.endswith('/rm') or t.endswith('/shred') or t.endswith('/truncate'):
        for u in tokens[i+1:]:
            if not u.startswith('-'):
                targets.append(u)
    if t in ('chmod', 'chown', 'chgrp') or t.endswith('/chmod') or t.endswith('/chown') or t.endswith('/chgrp'):
        j = i + 1
        while j < len(tokens) and tokens[j].startswith('-'):
            j += 1
        if j < len(tokens):
            j += 1
        for u in tokens[j:]:
            if not u.startswith('-'):
                targets.append(u)
    i += 1
for tg in targets:
    if tg:
        print(tg)
PY
)"

while IFS= read -r tgt; do
    [ -z "$tgt" ] && continue
    if is_catastrophic "$tgt"; then
        cat <<EOF >&2
BLOCKED by elite-role pre-shell hook (L7 Absolute Contract — catastrophic):
Shell command targets a catastrophic system path: '$tgt'
Full command was:
  $CMD

The path '$tgt' is on the catastrophic-paths list.
No agent operation is permitted against them.
EOF
        exit 2
    fi
    if is_protected "$tgt"; then
        cat <<EOF >&2
BLOCKED by elite-role pre-shell hook (L7 Absolute Contract):
Shell command targets a protected file: '$tgt'
Full command was:
  $CMD

Sensitive files (.env, credentials, SSH keys, certificates, kubeconfig,
terraform state, etc.) must not be modified by the agent.
EOF
        exit 2
    fi
done <<< "$TARGETS"

exit 0
