#!/bin/bash
# tests/compliance-smoke.sh — Acceptance harness for Phase F:
#   F1 (scripts/compliance_report.sh)
#   F2 (scripts/compliance_dashboard.sh)
#   F3 (scripts/compliance_alert.sh) + session-start.sh integration
#
# Called from .github/workflows/integrity.yml.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

# Use an isolated audit directory so accumulated real signals do not
# break the zero-data assertion. The override is honored by both
# compliance_report.sh and compliance_dashboard.sh via the
# COMPLIANCE_AUDIT_DIR env var.
AUDIT_DIR="$(mktemp -d /tmp/compliance-smoke-XXXXXX)"
export COMPLIANCE_AUDIT_DIR="$AUDIT_DIR"
TODAY="$(TZ=UTC date -u +%Y%m%d)"
PRIOR="$(python3 -c 'import datetime; print((datetime.date.today() - datetime.timedelta(days=8)).strftime("%Y%m%d"))')"

# Always tear down the isolated audit dir at exit.
trap 'rm -rf "$AUDIT_DIR"; exit 0' EXIT

# ── F1 no-data path ────────────────────────────────────────────────
F1_EMPTY="$(bash scripts/compliance_report.sh)"
if ! printf '%s' "$F1_EMPTY" | grep -q 'Total PostToolUse calls: \*\*0\*\*'; then
    echo "FAIL: F1 zero-data path did not emit 'Total PostToolUse calls: **0**'" >&2
    exit 1
fi

# ── F1 with-data path ──────────────────────────────────────────────
ISO_NOW="$(python3 -c 'import datetime; print(datetime.datetime.now(datetime.timezone.utc).isoformat())')"
cat > "$AUDIT_DIR/signals-${TODAY}.jsonl" <<EOF
{"ts":"${ISO_NOW}","event":"PostToolUse","session_id":"smk","tool":"WriteFile","l2_trigger":true,"l2_has_cite":true,"l2_flagged":false}
{"ts":"${ISO_NOW}","event":"PostToolUse","session_id":"smk","tool":"WriteFile","l2_trigger":true,"l2_has_cite":false,"l2_flagged":true}
{"ts":"${ISO_NOW}","event":"PostToolUse","session_id":"smk","tool":"Shell","l2_trigger":false,"l2_has_cite":false,"l2_flagged":false}
EOF

F1_FULL="$(bash scripts/compliance_report.sh)"
if ! printf '%s' "$F1_FULL" | grep -q 'Total PostToolUse calls: \*\*3\*\*'; then
    echo "FAIL: F1 with-data path expected 3 calls, got: $F1_FULL" >&2
    exit 1
fi
if ! printf '%s' "$F1_FULL" | grep -qE 'Trigger rate.*\| 66\.7%'; then
    echo "FAIL: F1 trigger rate expected 66.7% (2/3)" >&2
    printf '%s\n' "$F1_FULL" >&2
    exit 1
fi

# ── F2 — dashboard write + cap ─────────────────────────────────────
DASH_OUT="$(bash scripts/compliance_dashboard.sh)"
if ! printf '%s' "$DASH_OUT" | grep -qE 'Wrote memory/compliance/[0-9]{4}-W[0-9]+\.md'; then
    echo "FAIL: F2 dashboard did not produce expected path" >&2
    exit 1
fi
bash scripts/compliance_dashboard.sh --check >/dev/null

# ── F3 — synthetic regression triggers alert ──────────────────────
ISO_PRIOR="$(python3 -c 'import datetime; print((datetime.datetime.now(datetime.timezone.utc) - datetime.timedelta(days=8)).isoformat())')"
: > "$AUDIT_DIR/signals-${PRIOR}.jsonl"
for _ in 1 2 3 4 5 6 7 8 9 10; do
    printf '{"ts":"%s","event":"PostToolUse","session_id":"prior","tool":"WriteFile","l2_trigger":true,"l2_has_cite":true,"l2_flagged":false}\n' \
        "$ISO_PRIOR" >> "$AUDIT_DIR/signals-${PRIOR}.jsonl"
done
: > "$AUDIT_DIR/signals-${TODAY}.jsonl"
for _ in 1 2 3 4 5 6 7 8 9 10; do
    printf '{"ts":"%s","event":"PostToolUse","session_id":"now","tool":"WriteFile","l2_trigger":true,"l2_has_cite":false,"l2_flagged":true}\n' \
        "$ISO_NOW" >> "$AUDIT_DIR/signals-${TODAY}.jsonl"
done

ALERT_OUT="$(bash scripts/compliance_alert.sh)"
if ! printf '%s' "$ALERT_OUT" | grep -q 'L2 citation rate WHEN triggered'; then
    echo "FAIL: F3 alert did not fire on synthetic 100% → 0% regression" >&2
    printf '%s\n' "$ALERT_OUT" >&2
    exit 1
fi
if bash scripts/compliance_alert.sh --strict-exit >/dev/null 2>&1; then
    echo "FAIL: F3 --strict-exit returned 0 on a regression" >&2
    exit 1
fi

# ── F3 — session-start.sh embeds the alert ────────────────────────
SS_OUT="$(echo '{}' | .kimi/hooks/session-start.sh)"
if ! printf '%s' "$SS_OUT" | grep -q 'Compliance Trend Alerts'; then
    echo "FAIL: session-start.sh did not embed F3 alert when one fires" >&2
    exit 1
fi

echo "All Phase F smoke tests pass — F1 (zero+full), F2 (write+check), F3 (alert+strict+SessionStart)."
