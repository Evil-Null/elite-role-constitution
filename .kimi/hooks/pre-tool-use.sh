#!/bin/bash
# pre-tool-use.sh — Elite Role hook for Kimi CLI 1.43+
#
# Event: PreToolUse  (matcher: WriteFile|StrReplaceFile|MultiEdit, plus
#                     a separate registration for Shell via pre-shell.sh)
# Purpose: enforce L7 (Absolute Contract) at the file-mutation boundary:
#   1. FAIL-CLOSED on JSON parse failure — security guards must not be
#      disabled by malformed input.
#   2. Iterate every plausible path key in tool_input (file_path, path,
#      target_file, filename, edits[*].file_path).
#   3. Case-insensitive protected-file matching with explicit exemption
#      for *.env.example / *.env.sample / *.env.template.
#   4. Resolve symlinks before matching so `ln -s /etc/shadow safe.txt`
#      cannot bypass the guard.
#   5. V3 security grep on content for an expanded secret pattern set.
#
# Hook protocol: exit 0 = allow; exit 2 + stderr = BLOCK; stdout on
# exit 0 is appended to agent context.

set -euo pipefail
shopt -s nocasematch

# Source canon-generated patterns (B7 — single source of truth via canon/patterns.yaml).
# shellcheck source=_patterns.sh disable=SC1091
HOOKS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=/dev/null
source "$HOOKS_DIR/_patterns.sh"

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
    # MultiEdit-style: edits[*].file_path / path
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
    sys.stderr.write(f'pre-tool-use payload parse error: {ex}\n')
    sys.exit(1)
" 2>/dev/null || true)"

# ── 3. Protected-file matcher (case-insensitive, expanded, symlink-resolving) ──

check_protected() {
    local raw="$1"
    local real
    real="$(readlink -f "$raw" 2>/dev/null || printf '%s' "$raw")"
    local base="${raw##*/}"
    local real_base="${real##*/}"

    # Whitelist first: example/sample/template names are conventionally
    # checked into repos with placeholders, not real values. The doctrine
    # names .env.example as the legitimate edit target.
    local safe_p
    for safe_p in "${WHITELIST_PATTERNS[@]}"; do
        # shellcheck disable=SC2254  # case-glob expansion is intentional
        case "$base"      in $safe_p) return 1 ;; esac
        # shellcheck disable=SC2254
        case "$real_base" in $safe_p) return 1 ;; esac
    done

    # Block list — checked against basename so directory clutter does
    # not hide them, AND against the resolved path so symlinks cannot
    # bypass. Patterns come from canon/patterns.yaml via _patterns.sh.
    local pat
    for pat in "${PROTECTED_PATTERNS[@]}"; do
        # shellcheck disable=SC2254  # case-glob expansion is intentional
        case "$base"      in $pat) return 0 ;; esac
        # shellcheck disable=SC2254
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
    # MultiEdit
    edits = ti.get('edits') or ti.get('changes')
    if isinstance(edits, list):
        for e in edits:
            if not isinstance(e, dict): continue
            for k in ('new_string', 'content', 'replacement'):
                v = e.get(k)
                if isinstance(v, str): parts.append(v)
    print('\n---ELITE_HOOK_SEP---\n'.join(parts))
except Exception:
    pass
" 2>/dev/null || true)"

if [ -n "$CONTENT" ]; then
    # Combined secret regex from canon/patterns.yaml (via _patterns.sh).
    # Single grep call replaces the 9-clause chain of the pre-B7 hook;
    # covers AWS, OpenAI (legacy + project), Anthropic, GitHub PAT
    # (classic + fine-grained), Google API, Slack, Stripe live, and
    # every common private-key PEM header.
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

# All checks passed — allow, with a single-line positive audit trail
echo "elite-role PreToolUse: allowed (paths=$(printf '%s' "$PATHS" | wc -l | tr -d ' '), content-bytes=${#CONTENT})"
exit 0
