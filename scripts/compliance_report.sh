#!/bin/bash
# scripts/compliance_report.sh — Aggregate .kimi/audit/signals-*.jsonl
# into a 7-day compliance report per ROADMAP_ELITE_v2 §5.F.F1.
#
# Usage:
#   bash scripts/compliance_report.sh              # last 7 days, stdout
#   bash scripts/compliance_report.sh --days 30    # last 30 days
#   bash scripts/compliance_report.sh --machine    # one-line JSON (for F3)
#
# Schema consumed (emitted by .kimi/hooks/post-tool-use.sh per C5):
#   {"ts":"<iso>", "event":"PostToolUse", "session_id":"...",
#    "tool":"WriteFile|StrReplaceFile|Shell|...",
#    "l2_trigger":bool, "l2_has_cite":bool, "l2_flagged":bool}
#
# Honest scope (per ROADMAP §12 v2.0-C1):
#   - L2 citation signals: COMPUTABLE — emitted by post-tool-use.sh
#   - L5 risk-score declarations: NOT COMPUTABLE — Stop hook payload
#     does not include response text in Kimi 1.43+/1.44.0
#   - L6 3-ways-wrong block: NOT COMPUTABLE — same reason
#   - Hook timeout incidents: NOT COMPUTABLE from JSONL alone;
#     would need PostToolUseFailure event emission (deferred to a
#     future C-phase task or Phase F.F1b)
#
# These N/A categories are reported as such, not hidden. Honesty
# about scope is L7 / L6.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AUDIT_DIR="$REPO_ROOT/.kimi/audit"

DAYS=7
MACHINE=0
while [ $# -gt 0 ]; do
    case "$1" in
        --days)   DAYS="$2"; shift 2 ;;
        --days=*) DAYS="${1#*=}"; shift ;;
        --machine) MACHINE=1; shift ;;
        --help|-h)
            sed -n '2,20p' "$0"
            exit 0
            ;;
        *) echo "compliance_report.sh: unknown arg: $1" >&2; exit 2 ;;
    esac
done

# Collect the jsonl files for the window. The hook uses UTC YYYYMMDD;
# we match the last N days by date arithmetic in python (portable).
FILES_LIST="$(python3 - "$DAYS" "$AUDIT_DIR" <<'PY'
import os, sys
from datetime import datetime, timedelta, timezone

days = int(sys.argv[1])
audit_dir = sys.argv[2]
today = datetime.now(timezone.utc).date()
window = {(today - timedelta(days=i)).strftime('%Y%m%d') for i in range(days)}
if not os.path.isdir(audit_dir):
    sys.exit(0)
for name in sorted(os.listdir(audit_dir)):
    if not name.startswith('signals-') or not name.endswith('.jsonl'):
        continue
    day = name[len('signals-'):-len('.jsonl')]
    if day in window:
        print(os.path.join(audit_dir, name))
PY
)"

# Compute aggregates in one python pass (sorted by tool for stable output).
SUMMARY_JSON="$(python3 - "$DAYS" <<PY
import sys, json
from collections import Counter, defaultdict

days = int(sys.argv[1])
files = """${FILES_LIST}""".strip().splitlines()

total = 0
by_tool = Counter()
l2_trigger_count = 0
l2_cited_count = 0
l2_flagged_count = 0
malformed = 0
by_session = set()
by_day = Counter()

for path in files:
    try:
        with open(path) as fh:
            for line in fh:
                line = line.strip()
                if not line:
                    continue
                try:
                    obj = json.loads(line)
                except Exception:
                    malformed += 1
                    continue
                total += 1
                by_tool[obj.get('tool', '?')] += 1
                if obj.get('session_id'):
                    by_session.add(obj['session_id'])
                ts = obj.get('ts', '')
                if len(ts) >= 10:
                    by_day[ts[:10]] += 1
                if obj.get('l2_trigger') is True:
                    l2_trigger_count += 1
                    if obj.get('l2_has_cite') is True:
                        l2_cited_count += 1
                if obj.get('l2_flagged') is True:
                    l2_flagged_count += 1
    except FileNotFoundError:
        continue

# Computed rates — honest with zero-division.
def pct(num, den):
    return None if den == 0 else round(100.0 * num / den, 1)

l2_cite_rate_when_triggered = pct(l2_cited_count, l2_trigger_count)
l2_flag_rate_overall = pct(l2_flagged_count, total)
l2_trigger_rate_overall = pct(l2_trigger_count, total)

print(json.dumps({
    "window_days": days,
    "files": len(files),
    "total_calls": total,
    "malformed_lines": malformed,
    "distinct_sessions": len(by_session),
    "by_tool": dict(by_tool.most_common()),
    "by_day": dict(sorted(by_day.items())),
    "l2": {
        "trigger_rate_overall_pct": l2_trigger_rate_overall,
        "flag_rate_overall_pct": l2_flag_rate_overall,
        "cite_rate_when_triggered_pct": l2_cite_rate_when_triggered,
        "trigger_count": l2_trigger_count,
        "cited_count": l2_cited_count,
        "flagged_count": l2_flagged_count,
    },
    "l5": {"status": "N/A — Stop hook payload lacks response text (ROADMAP §12 v2.0-C1)"},
    "l6": {"status": "N/A — same reason as L5"},
    "hook_timeouts": {"status": "N/A — PostToolUseFailure event not yet wired (defer to F1b)"},
}))
PY
)"

if [ "$MACHINE" -eq 1 ]; then
    printf '%s\n' "$SUMMARY_JSON"
    exit 0
fi

# Human-readable markdown table.
python3 - <<PY
import json
s = json.loads("""$SUMMARY_JSON""")
print("# Compliance Report")
print()
print(f"- Window: last **{s['window_days']} days**")
print(f"- Source files: {s['files']}")
print(f"- Total PostToolUse calls: **{s['total_calls']}**")
print(f"- Distinct sessions: {s['distinct_sessions']}")
print(f"- Malformed JSONL lines: {s['malformed_lines']}")
print()
print("## L2 Citation Signals")
print()
print("| Metric | Value |")
print("|---|---|")
l2 = s['l2']
def fmt(v): return "N/A (no data)" if v is None else f"{v}%"
print(f"| Trigger rate (overall) | {fmt(l2['trigger_rate_overall_pct'])} |")
print(f"| Flag rate (overall) — trigger AND no cite | {fmt(l2['flag_rate_overall_pct'])} |")
print(f"| Citation rate WHEN triggered | {fmt(l2['cite_rate_when_triggered_pct'])} |")
print(f"| Raw counts | trigger={l2['trigger_count']}, cited={l2['cited_count']}, flagged={l2['flagged_count']} |")
print()
print("## Per-tool Breakdown")
print()
print("| Tool | Calls |")
print("|---|---|")
for tool, n in s['by_tool'].items():
    print(f"| {tool} | {n} |")
if not s['by_tool']:
    print("| (no calls in window) | 0 |")
print()
print("## Per-day Volume")
print()
print("| Day (UTC) | Calls |")
print("|---|---|")
for day, n in s['by_day'].items():
    print(f"| {day} | {n} |")
if not s['by_day']:
    print("| (no calls in window) | 0 |")
print()
print("## Not Computable This Cycle")
print()
print("| Signal | Why |")
print("|---|---|")
print(f"| L5 risk-score declaration rate | {s['l5']['status']} |")
print(f"| L6 3-ways-wrong rate | {s['l6']['status']} |")
print(f"| Hook timeout incidents | {s['hook_timeouts']['status']} |")
print()
print("---")
print()
print("_Generated by scripts/compliance_report.sh — honest scope per ROADMAP_ELITE_v2 §5.F.F1._")
PY
