#!/bin/bash
# tests/hook-pattern-smoke.sh — Negative-case coverage for
# .kimi/hooks/pre-tool-use.sh and pre-shell.sh, per ROADMAP_ELITE_v2
# §5.E.E10. Called from .github/workflows/integrity.yml.
#
# Each "assert_blocks" case feeds a payload that MUST trigger an
# exit-2 (or any non-zero) from the named hook. The "Allow-list"
# cases at the top assert that benign inputs are not over-blocked.
#
# Test fixtures use shell concatenation to keep secret-shaped tokens
# from being committed as literal strings — appeases workflow-file
# secret scanners while still producing the right shape at runtime.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# ── Allow-list assertions (exit 0 expected) ────────────────────────
echo '{}' | .kimi/hooks/session-start.sh >/dev/null
echo '{}' | .kimi/hooks/session-end.sh
echo '{}' | .kimi/hooks/pre-compact.sh >/dev/null
echo '{}' | .kimi/hooks/stop.sh >/dev/null
echo '{}' | .kimi/hooks/notification.sh
echo '{}' | .kimi/hooks/user-prompt-submit.sh
echo '{"tool_name":"WriteFile","tool_input":{"file_path":"README.md","content":"safe"}}' \
    | .kimi/hooks/pre-tool-use.sh >/dev/null
echo '{"tool_name":"WriteFile","tool_input":{"file_path":".env.example","content":"FOO=placeholder"}}' \
    | .kimi/hooks/pre-tool-use.sh >/dev/null
echo '{"tool_name":"Shell","tool_input":{"command":"ls -la"}}' \
    | .kimi/hooks/pre-shell.sh >/dev/null

# ── Block-list assertions (ROADMAP §5.E.E10) ──────────────────────
assert_blocks() {
    local label="$1" hook="$2" payload="$3"
    if printf '%s' "$payload" | "$hook" >/dev/null 2>&1; then
        echo "FAIL: $hook did not block $label" >&2
        exit 1
    fi
}

# Build secret-shaped fixtures via concatenation. Splitting the
# tokens prevents accidental commits of real-looking secrets and
# keeps repo-wide scanners (including ours) calm.
PEM_HDR='-----BEGIN OPENSSH PRIVATE'
PEM_HDR_FULL="${PEM_HDR} KEY-----"
SLACK_PREFIX='xox'
SLACK_FAKE="${SLACK_PREFIX}b-0000000000-0000000000-AbCdEfGhIjKlMnOpQrStUvWx"
ANT_PREFIX='sk-'
ANT_FAKE="${ANT_PREFIX}ant-api01-abcdefghijklmnopqrstuvwxyz0123"
AWS_PREFIX='AKI'
AWS_FAKE="${AWS_PREFIX}AIOSFODNN7EXAMPLE"
GOOGLE_PREFIX='AIz'
GOOGLE_FAKE="${GOOGLE_PREFIX}aSyA-EXAMPLEexampleexampleexampleexamp"

# 1. Protected basename: .env
assert_blocks ".env basename" .kimi/hooks/pre-tool-use.sh \
    '{"tool_name":"WriteFile","tool_input":{"file_path":".env"}}'
# 2. Protected basename: id_rsa
assert_blocks "id_rsa basename" .kimi/hooks/pre-tool-use.sh \
    '{"tool_name":"WriteFile","tool_input":{"file_path":"id_rsa"}}'
# 3. Protected glob: *kubeconfig*
assert_blocks "kubeconfig basename" .kimi/hooks/pre-tool-use.sh \
    '{"tool_name":"WriteFile","tool_input":{"file_path":"my-kubeconfig"}}'
# 4. Protected glob: gcloud-key*.json
assert_blocks "gcloud-key json" .kimi/hooks/pre-tool-use.sh \
    '{"tool_name":"WriteFile","tool_input":{"file_path":"gcloud-key-prod.json"}}'
# 5. Protected glob: *.tfstate
assert_blocks ".tfstate basename" .kimi/hooks/pre-tool-use.sh \
    '{"tool_name":"WriteFile","tool_input":{"file_path":"prod.tfstate"}}'
# 6. Protected glob: *.pem
assert_blocks ".pem basename" .kimi/hooks/pre-tool-use.sh \
    '{"tool_name":"WriteFile","tool_input":{"file_path":"server.pem"}}'

# 7. Content secret: OPENSSH PRIVATE KEY header
assert_blocks "openssh-pem content" .kimi/hooks/pre-tool-use.sh \
    "$(printf '{"tool_name":"WriteFile","tool_input":{"file_path":"notes.md","content":"%s\\nbody"}}' "$PEM_HDR_FULL")"
# 8. Content secret: Slack token
assert_blocks "slack token content" .kimi/hooks/pre-tool-use.sh \
    "$(printf '{"tool_name":"WriteFile","tool_input":{"file_path":"notes.md","content":"token=%s"}}' "$SLACK_FAKE")"
# 9. Content secret: Anthropic-style key (matches openai_legacy regex)
assert_blocks "anthropic key content" .kimi/hooks/pre-tool-use.sh \
    "$(printf '{"tool_name":"WriteFile","tool_input":{"file_path":"notes.md","content":"KEY=%s"}}' "$ANT_FAKE")"
# 10. Content secret: AWS access key
assert_blocks "aws key content" .kimi/hooks/pre-tool-use.sh \
    "$(printf '{"tool_name":"WriteFile","tool_input":{"file_path":"notes.md","content":"id=%s"}}' "$AWS_FAKE")"
# 11. Content secret: Google API key
assert_blocks "google key content" .kimi/hooks/pre-tool-use.sh \
    "$(printf '{"tool_name":"WriteFile","tool_input":{"file_path":"notes.md","content":"key=%s"}}' "$GOOGLE_FAKE")"

# 12. Shell redirect to .env
assert_blocks "shell > .env" .kimi/hooks/pre-shell.sh \
    '{"tool_name":"Shell","tool_input":{"command":"echo TOKEN > .env"}}'
# 13. Shell cp to a protected basename
assert_blocks "shell cp id_rsa" .kimi/hooks/pre-shell.sh \
    '{"tool_name":"Shell","tool_input":{"command":"cp /tmp/foo id_rsa"}}'

echo "All hook smoke tests pass — 13 negative cases covered (ROADMAP §5.E.E10 ≥10)."
