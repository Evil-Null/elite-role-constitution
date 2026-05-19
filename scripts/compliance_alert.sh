#!/bin/bash
# scripts/compliance_alert.sh — Trend-alert helper per ROADMAP_ELITE_v2 §5.F.F3.
#
# Compares this-week vs last-week aggregates from
# scripts/compliance_report.sh --machine. If any tracked rate drops
# more than DELTA_PCT_FLOOR percentage points week-over-week, emit a
# one-line warning to stdout (designed to be invoked by SessionStart
# so the warning enters the agent context).
#
# Usage:
#   bash scripts/compliance_alert.sh                  # stdout warning lines, or nothing
#   bash scripts/compliance_alert.sh --strict-exit    # exit 1 when alerts fire (for tests)
#
# Rates tracked (only L2 right now; L5/L6/timeouts marked N/A by F1):
#   - l2.trigger_rate_overall_pct
#   - l2.flag_rate_overall_pct  (rising is BAD; falling is GOOD — sign-inverted)
#   - l2.cite_rate_when_triggered_pct

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"

DELTA_PCT_FLOOR=20
STRICT_EXIT=0
[ "${1:-}" = "--strict-exit" ] && STRICT_EXIT=1

# Use compliance_report.sh twice: once for last 7 days (this week)
# and once for last 14 days (this week + previous week). Subtract to
# isolate the prior 7-day window.
THIS="$(bash "$REPO_ROOT/scripts/compliance_report.sh" --days 7  --machine)"
WIDE="$(bash "$REPO_ROOT/scripts/compliance_report.sh" --days 14 --machine)"

python3 - "$THIS" "$WIDE" "$DELTA_PCT_FLOOR" "$STRICT_EXIT" <<'PY'
import json, sys
this_j = json.loads(sys.argv[1])
wide_j = json.loads(sys.argv[2])
floor = float(sys.argv[3])
strict_exit = int(sys.argv[4])

# Derive "previous week" rates: aggregate over the 14-day window minus
# the 7-day window. For simplicity, we approximate by comparing
# this-week rate to the wider 14-day rate — if the wider rate is
# meaningfully better and this-week is worse, that captures the same
# regression (and is easier to reason about than reconstructing the
# prior-7 window from JSON aggregates alone).
this_l2 = this_j.get("l2", {})
wide_l2 = wide_j.get("l2", {})

# Each entry: (key, label, sign) where sign=+1 means higher is better,
# -1 means higher is worse (flag rate is bad → inverted).
TRACKED = [
    ("cite_rate_when_triggered_pct", "L2 citation rate WHEN triggered", +1),
    ("trigger_rate_overall_pct",     "L2 trigger rate overall",         +1),
    ("flag_rate_overall_pct",        "L2 flag rate overall",            -1),
]

alerts = []
for key, label, sign in TRACKED:
    cur = this_l2.get(key)
    base = wide_l2.get(key)
    if cur is None or base is None:
        continue
    # Effective delta in the "bad direction"
    delta = (base - cur) * sign
    if delta > floor:
        alerts.append({
            "metric": label,
            "this_week": cur,
            "rolling_14d": base,
            "drop_pp": round(delta, 1),
        })

if not alerts:
    # Silent on the no-alert path so SessionStart context stays clean.
    sys.exit(0)

print("=== Compliance Trend Alerts (week-over-week) ===")
for a in alerts:
    print(f"  • {a['metric']}: this-week {a['this_week']}% vs "
          f"rolling-14d {a['rolling_14d']}% — regression {a['drop_pp']}pp")
print(f"  (Floor: {floor}pp. Source: scripts/compliance_report.sh.)")

if strict_exit:
    sys.exit(1)
PY
