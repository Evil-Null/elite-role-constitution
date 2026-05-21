#!/bin/bash
# pre-tool-use.sh — Elite Role hook for Kimi CLI 1.43+
#
# Event: PreToolUse  (matcher: WriteFile|StrReplaceFile|MultiEdit)
# Purpose: enforce L7 (Absolute Contract) at the file-mutation boundary.
#
# v3.0: C4 state dir uses global ~/.kimi/state/elite-role/ via _lib.sh.

set -euo pipefail
shopt -s nocasematch

HOOKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$HOOKS_DIR/_patterns.sh"
source "$HOOKS_DIR/_lib.sh"

# C4 L4 PEV approval check (advisory by default; strict-mode via sentinel).
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
BLOCKED by elite-role PreToolUse hook (L4 PEV gate — strict mode):
The current user prompt does not contain an approval token. State-
mutating tools require [APPROVED] in the user's most recent message,
or "light effort" / "challenge-grade".

Override: re-send with [APPROVED] appended, OR disable strict mode:
  rm $strict_sentinel
EOF
        return 2
    fi
    cat <<EOF >&2
elite-role · L4 PEV advisory:
  State-mutating tool fired without an [APPROVED] token in the user's
  most recent message. Doctrine asks non-routine mutations to be
  plan-gated. If non-routine, request [APPROVED] for the next turn.
  Activate strict-block mode:  touch $strict_sentinel
EOF
    return 0
}

INPUT="$(cat)"

# ── 1. Fail closed on parse failure ─────────────────────────────────
if ! printf '%s' "$INPUT" | python3 -c "import sys,json; json.load(sys.stdin)" 2>/dev/null; then
    cat <<'EOF' >&2
BLOCKED by elite-role PreToolUse hook (R3 #1 — fail-closed on parse error):
The hook received malformed or empty JSON on stdin. Per L7 Absolute
Contract, security guards do not silently bypass on unparseable input.
This is almost certainly a bug in the tool wrapper, not malicious; rerun
the same call once more, and if the error persists, file a bug.
EOF
    exit 2
fi

# ── 1b. C4 — L4 PEV approval gate ───────────────────────────────────
SESSION_ID="$(printf '%s' "$INPUT" | python3 -c "
import sys, json
try: print(json.load(sys.stdin).get('session_id',''))
except Exception: pass
" 2>/dev/null || echo "")"

if ! c4_check_approval "$SESSION_ID"; then
    exit 2
fi

# ── 2. Collect every plausible path from the payload ────────────────
PATHS="$(printf '%s' "$INPUT" | python3 -c "
import json, sys
try:
    d = json.load(sys.stdin)
    ti = d.get('tool_input', {})
    out = []
    for k in ('file_path', 'path', 'target_file', 'filename'):
        v = ti.get(k)
        if isinstance(v, str) and v:
            out.append(v)
    edits = ti.get('edits') or ti.get('changes')
    if isinstance(edits, list):
        for e in edits:
            if not isinstance(e, dict): continue
            for k in ('file_path', 'path'):
                v = e.get(k)
                if isinstance(v, str) and v:
                    out.append(v)
    for p in out:
        print(p)
except Exception as ex:
    sys.stderr.write(f'pre-tool-use payload parse error: {ex}\\n')
    sys.exit(1)
" 2>/dev/null || true)"

# ── 3. Protected-file matcher ───────────────────────────────────────
check_protected() {
    local raw="$1"
    local real
    real="$(readlink -f "$raw" 2>/dev/null || printf '%s' "$raw")"
    local base="${raw##*/}"
    local real_base="${real##*/}"

    local safe_p
    for safe_p in "${WHITELIST_PATTERNS[@]}"; do
        case "$base"      in $safe_p) return 1 ;; esac
        case "$real_base" in $safe_p) return 1 ;; esac
    done

    local pat
    for pat in "${PROTECTED_PATTERNS[@]}"; do
        case "$base"      in $pat) return 0 ;; esac
        case "$real_base" in $pat) return 0 ;; esac
    done
    return 1
}

while IFS= read -r p; do
    [ -z "$p" ] && continue
    if check_protected "$p"; then
        cat <<EOF >&2
BLOCKED by elite-role PreToolUse hook (L7 Absolute Contract):
Path '$p' matches the protected-file pattern (sensitive credentials,
SSH keys, certificates, .env, terraform state, kubeconfig, etc.).

Sensitive files must not be modified by the agent. If you need to
update one, do it manually outside this session, or update a
.env.example / credentials.example sibling and document the
required keys.

To override this guard for a single turn, the user must explicitly
acknowledge the risk in their next message.
EOF
        exit 2
    fi
done <<< "$PATHS"

# ── 4. V3 secret-pattern scan on proposed content ───────────────────
CONTENT="$(printf '%s' "$INPUT" | python3 -c "
import json, sys
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
            if not isinstance(e, dict): continue
            for k in ('new_string', 'content', 'replacement'):
                v = e.get(k)
                if isinstance(v, str): parts.append(v)
    print('\\n---ELITE_HOOK_SEP---\\n'.join(parts))
except Exception:
    pass
" 2>/dev/null || true)"

if [ -n "$CONTENT" ]; then
    if printf '%s' "$CONTENT" | grep -qE -- "$SECRET_REGEX_ANY"; then
        cat <<'EOF' >&2
BLOCKED by elite-role PreToolUse hook (L7 Absolute Contract):
The proposed content looks like a secret or private key (matched
one of: AWS access key, OpenAI legacy/project key, Anthropic key,
GitHub PAT, Google API key, Slack token, Stripe live key, or a
private-key PEM header — including DSA / EC / OPENSSH / RSA /
ENCRYPTED / PGP variants).

If this is a deliberate example or fixture, replace the literal
value with an obvious placeholder (e.g. 'AKIA...REDACTED...' or
'sk-EXAMPLE...') and rerun the tool.
EOF
        exit 2
    fi
fi

echo "elite-role PreToolUse: allowed (paths=$(printf '%s' "$PATHS" | wc -l | tr -d ' '), content-bytes=${#CONTENT})"
exit 0
