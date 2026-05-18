#!/bin/bash
# pre-tool-use.sh — Elite Role hook for Kimi CLI 1.43+
#
# Event: PreToolUse  (matcher: WriteFile|StrReplaceFile)
# Purpose: enforce two doctrine checks before any file mutation —
#   1. Protect sensitive files (.env, credentials, ssh keys) per L7
#   2. Run a quick V3-security grep on the proposed new content
#
# Hook protocol: exit 2 + stderr = BLOCK (LLM receives stderr as
# correction). Exit 0 + stdout = ALLOW (stdout added to context).
# Structured JSON on stdout can declare permissionDecision = deny.

set -euo pipefail

INPUT=$(cat)

# Extract the file path the tool is about to touch
FILE=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    print(d.get('tool_input', {}).get('file_path', ''))
except Exception:
    print('')
" 2>/dev/null || echo "")

if [ -z "$FILE" ]; then
    # Nothing to check
    exit 0
fi

# Check 1 — Protected file glob
case "$FILE" in
    *.env|*.env.*|*credentials*|*id_rsa*|*id_ed25519*|*.pem|*.key)
        cat <<EOF >&2
BLOCKED by elite-role PreToolUse hook (L7 Absolute Contract):
File '$FILE' matches the protected-file pattern.

Sensitive files (.env, credentials, SSH keys, certificates) must
not be modified by the agent. If you need to update one, do it
manually outside this session, or update a .env.example /
credentials.example sibling and document the required keys.

To override this guard for a single turn, the user must explicitly
acknowledge the risk in their next message.
EOF
        exit 2
        ;;
esac

# Check 2 — V3 security grep on new content (for WriteFile / StrReplaceFile)
CONTENT=$(echo "$INPUT" | python3 -c "
import sys, json
try:
    d = json.load(sys.stdin)
    ti = d.get('tool_input', {})
    # Different tools carry content under different keys
    for k in ('content','new_string','replacement','text'):
        if k in ti and ti[k]:
            print(ti[k]); break
except Exception:
    pass
" 2>/dev/null || echo "")

if [ -n "$CONTENT" ]; then
    # Cheap heuristic — block obvious secret leaks
    if echo "$CONTENT" | grep -qE 'AKIA[0-9A-Z]{16}|sk-[A-Za-z0-9]{32,}|ghp_[A-Za-z0-9]{36}|-----BEGIN (RSA |EC |OPENSSH )?PRIVATE KEY-----'; then
        cat <<EOF >&2
BLOCKED by elite-role PreToolUse hook (L7 Absolute Contract):
The proposed content for '$FILE' looks like a secret or private key
(matched AWS key pattern, OpenAI key prefix, GitHub PAT prefix, or
private-key PEM header).

If this is a deliberate example/fixture, replace the literal value
with an obvious placeholder (e.g., 'AKIA…REDACTED…' or
'sk-EXAMPLE…') before re-running the tool.
EOF
        exit 2
    fi
fi

# All checks passed — allow
exit 0
