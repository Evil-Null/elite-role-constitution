#!/bin/bash
# pre-shell.sh — Elite Role hook for Kimi CLI 1.43+
#
# Event: PreToolUse  (matcher: Shell)
# Purpose: close the bypass gap identified by independent review #3
# (R3 Finding 3) — the WriteFile-only PreToolUse hook could not see
# Shell-tool writes like `cat secrets > .env` or `cp creds /tmp/`.
#
# Strategy: parse the command for write-side syntax (>, >>, tee, cp,
# mv, install, sed -i, dd of=, install -m...) and run the same
# protected-file matcher on every plausible target path.

set -euo pipefail
shopt -s nocasematch

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

# Reuse the same protected pattern set as pre-tool-use.sh. Kept inline so
# the two hooks can evolve together without an extra include layer.
is_protected() {
    local raw="$1"
    local base="${raw##*/}"
    local real
    real="$(readlink -f "$raw" 2>/dev/null || printf '%s' "$raw")"
    local real_base="${real##*/}"
    # shellcheck disable=SC2254  # case-glob expansion is intentional
    for safe in '*.env.example' '*.env.sample' '*.env.template' '*.env.dist' '*.env.test'; do
        case "$base" in $safe) return 1 ;; esac
    done
    local pat
    for pat in \
        '*.env' '*.env.*' '*.envrc' '*.envrc.*' \
        '*credentials' '*credentials.*' \
        'id_rsa*' 'id_dsa*' 'id_ecdsa*' 'id_ed25519*' '*authorized_keys*' \
        '*.pem' '*.key' '*.p12' '*.pfx' '*.crt' '*.cer' '*.jks' \
        '*.gpg' '*.asc' '*.netrc' '*pgpass*' '*.npmrc' '*.pypirc' \
        '*kubeconfig*' '*service-account*.json' '*.tfstate' '*.tfstate.*'
    do
        # shellcheck disable=SC2254  # case-glob expansion is intentional
        case "$base"      in $pat) return 0 ;; esac
        # shellcheck disable=SC2254
        case "$real_base" in $pat) return 0 ;; esac
    done
    return 1
}

# Tokenise the command line so we can examine each argument. Use python
# shlex for robust quoting handling instead of trying to do it in bash.
# The command is passed via env var so the heredoc cannot steal stdin.
TARGETS="$(KIMI_PRESHELL_CMD="$CMD" python3 <<'PY' 2>/dev/null || true
import os, shlex, re

cmd = os.environ.get('KIMI_PRESHELL_CMD', '')
try:
    tokens = shlex.split(cmd, posix=True)
except ValueError:
    # Unbalanced quotes — fall back to whitespace split
    tokens = cmd.split()

targets = []
i = 0
while i < len(tokens):
    t = tokens[i]
    # Redirection forms: >, >>, &> with the next token as target
    if t in ('>', '>>', '&>'):
        if i + 1 < len(tokens): targets.append(tokens[i+1])
        i += 2; continue
    # Combined form like >file or 2>file
    m = re.match(r'^[12&]?>{1,2}(.+)$', t)
    if m and m.group(1) and m.group(1) not in ('&1', '&2'):
        targets.append(m.group(1))
    # tee / dd of= / install -m ... target / sed -i target / cp / mv
    if t == 'tee' or t.endswith('/tee'):
        # everything after this token that doesn't start with - is a target
        j = i + 1
        while j < len(tokens) and not tokens[j].startswith('-'):
            targets.append(tokens[j]); j += 1
    if t.startswith('of='):
        targets.append(t[3:])
    if t in ('cp', 'mv', 'install') or t.endswith('/cp') or t.endswith('/mv') or t.endswith('/install'):
        # last non-option token is the destination
        j = len(tokens) - 1
        while j > i and tokens[j].startswith('-'):
            j -= 1
        if j > i: targets.append(tokens[j])
    if t == 'sed' or t.endswith('/sed'):
        # sed -i, sed --in-place — argument after the script(s) is the file
        # Conservatively: any later token that exists in the filesystem
        for u in tokens[i+1:]:
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
    if is_protected "$tgt"; then
        cat <<EOF >&2
BLOCKED by elite-role pre-shell hook (L7 Absolute Contract):
Shell command targets a protected file: '$tgt'
Full command was:
  $CMD

Sensitive files (.env, credentials, SSH keys, certificates, kubeconfig,
terraform state, etc.) must not be modified by the agent — including
indirectly via Shell redirection or copy. If you need to edit one of
these, do it manually outside this session.
EOF
        exit 2
    fi
done <<< "$TARGETS"

exit 0
