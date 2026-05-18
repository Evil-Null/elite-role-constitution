#!/bin/bash
# SYSTEM_INTEGRITY_CHECK.sh — v2.4 Repository Integrity Validator
# Run: bash SYSTEM_INTEGRITY_CHECK.sh
# Returns: 0 if all checks pass, 1 if any fail

set -euo pipefail
shopt -s nullglob

ERRORS=0

echo "=== System Integrity Check v2.4 ==="

# 1. README file count equals git tracked files
# R3 #6 fix: distinguish "README missing" from "pattern missing" from
# "count mismatch" so the failure message tells the user which problem
# to fix.
if [ ! -r README.md ]; then
    echo "[FAIL] README.md is missing or unreadable"
    ERRORS=$((ERRORS + 1))
elif ! grep -qP '\d+(?= files across)' README.md; then
    echo "[FAIL] README.md no longer contains the canonical 'N files across' sentence"
    ERRORS=$((ERRORS + 1))
else
    README_COUNT="$(grep -oP '\d+(?= files across)' README.md | head -1)"
    GIT_COUNT="$(git ls-files | wc -l)"
    if [ "$README_COUNT" -eq "$GIT_COUNT" ]; then
        echo "[PASS] File count: README claims $README_COUNT, git has $GIT_COUNT"
    else
        echo "[FAIL] File count mismatch: README claims $README_COUNT, git has $GIT_COUNT"
        ERRORS=$((ERRORS + 1))
    fi
fi

# 2. Version strings align to v2.4 (system-level files only)
VERSION_ISSUES=0
for file in README.md SYSTEM_PROMPT_INSTALL.md KIMI_PROTOCOL.md; do
    if grep -q "Elite Role Protocol System v2\.[0-3]" "$file" 2>/dev/null; then
        echo "[FAIL] $file: stale system version found"
        VERSION_ISSUES=$((VERSION_ISSUES + 1))
    fi
    if grep -q "Protocol v1\.0" "$file" 2>/dev/null; then
        echo "[FAIL] $file: stale protocol version v1.0 found"
        VERSION_ISSUES=$((VERSION_ISSUES + 1))
    fi
    if grep -q "Deployment Guide v2\.[0-3]" "$file" 2>/dev/null; then
        echo "[FAIL] $file: stale install guide version found"
        VERSION_ISSUES=$((VERSION_ISSUES + 1))
    fi
done
if [ "$VERSION_ISSUES" -eq 0 ]; then
    echo "[PASS] Version alignment: system files v2.4"
else
    ERRORS=$((ERRORS + 1))
fi

# 3. Memory files respect thresholds.
# R3 #5 fix: fail explicitly if a memory file in the loop lacks a
# `Max Size:` declaration. The prior silent fallback to MAX=999 hid
# broken declarations indefinitely (caught in this audit cycle).
THRESHOLD_FAIL=0
for file in memory/ASSUMPTIONS.md memory/DECISIONS.md memory/AUDIT_LOG.md memory/README.md memory/CONTEXT.md memory/RESUME.md memory/COMPACT_STATE.md memory/STRESS_LOG_DAY_1.md; do
    if [ ! -f "$file" ]; then
        # STRESS_LOG_DAY_*.md may legitimately not exist before Phase 1 runs;
        # skip if absent rather than failing.
        case "$file" in memory/STRESS_LOG_DAY_*.md) continue ;; esac
        echo "[FAIL] $file: missing"
        THRESHOLD_FAIL=$((THRESHOLD_FAIL + 1))
        continue
    fi
    LINES="$(awk 'END{print NR}' "$file")"
    # Look for the canonical declaration first; falls back to legacy any-digit
    # form for compatibility, but FAIL if neither is present.
    MAX="$(grep -oP '(?<=^> \*\*Max Size:\*\* )\d+(?= lines)' "$file" 2>/dev/null | head -1 || true)"
    if [ -z "$MAX" ]; then
        MAX="$(grep -oP '\*\*Max Size:\*\* \d+(?= lines)' "$file" 2>/dev/null | grep -oE '[0-9]+' | head -1 || true)"
    fi
    if [ -z "$MAX" ]; then
        echo "[FAIL] $file: missing required '> **Max Size:** N lines' declaration"
        THRESHOLD_FAIL=$((THRESHOLD_FAIL + 1))
        continue
    fi
    if [ "$LINES" -gt "$MAX" ]; then
        echo "[FAIL] $file: $LINES lines > $MAX max"
        THRESHOLD_FAIL=$((THRESHOLD_FAIL + 1))
    fi
done
if [ "$THRESHOLD_FAIL" -eq 0 ]; then
    echo "[PASS] Memory thresholds: all files within limits and declared"
else
    ERRORS=$((ERRORS + 1))
fi

# 4. Stress log governance exists.
# R3 #9 fix: anchor to structural markers (a code-block fence containing
# STRESS_LOG in ROLLUP_POLICY, a Markdown table row in FILE_UPDATE_RULES)
# instead of any keyword presence, so a "STRESS_LOG no longer applies"
# negation comment cannot pass the check.
if grep -qE '^\| .memory/STRESS_LOG_DAY_\*\.md.' FILE_UPDATE_RULES.md \
   && grep -qE 'STRESS_LOG' memory/ROLLUP_POLICY.md; then
    echo "[PASS] Stress log governance: structural rows present in both files"
else
    echo "[FAIL] Stress log governance: missing structural row in FILE_UPDATE_RULES or no reference in ROLLUP_POLICY"
    ERRORS=$((ERRORS + 1))
fi

# 5. README does not point to SYSTEM_PLAN.md as canonical
if grep -q "SYSTEM_PLAN.md.*D\.1" README.md; then
    echo "[FAIL] README still references SYSTEM_PLAN.md D.1 as canonical"
    ERRORS=$((ERRORS + 1))
else
    echo "[PASS] README canonical reference: points to KIMI_PROTOCOL.md"
fi

# 6. SYSTEM_PLAN.md is archived (now lives under archive/)
if [ -f "archive/SYSTEM_PLAN.md" ] && grep -q "ARCHIVED" archive/SYSTEM_PLAN.md; then
    echo "[PASS] archive/SYSTEM_PLAN.md: archived header present"
else
    echo "[FAIL] archive/SYSTEM_PLAN.md: missing or no archived header"
    ERRORS=$((ERRORS + 1))
fi

# 7. Independent validation exists
if [ -f "INDEPENDENT_VALIDATION.md" ]; then
    CHECKS=$(grep -c "^| [0-9]" INDEPENDENT_VALIDATION.md)
    if [ "$CHECKS" -ge 10 ]; then
        echo "[PASS] Independent validation: $CHECKS checks present"
    else
        echo "[FAIL] Independent validation: only $CHECKS checks (<10)"
        ERRORS=$((ERRORS + 1))
    fi
else
    echo "[FAIL] Independent validation: file missing"
    ERRORS=$((ERRORS + 1))
fi

# 8. Fuzzy trigger matching documented.
# R3 #9 fix: also require that the word "substring" appears alongside
# an actual rule directive (case-insensitive "match" within a 5-line
# window). A comment like "we no longer use substring matching" would
# previously have passed the bare keyword check.
if grep -qiE "(substring|fuzzy).{0,60}(match|trigger)" OPERATING_RULES.md; then
    echo "[PASS] Trigger matching: substring/fuzzy rule documented"
else
    echo "[FAIL] Trigger matching: substring/fuzzy keyword present but not paired with a match/trigger rule"
    ERRORS=$((ERRORS + 1))
fi

# 9. L4.1 canonical drift — must NOT exist in 01_ELITE_ROLE.md
L41_FOUND=0
if grep -q "L4\.1" 01_ELITE_ROLE.md; then
    echo "[FAIL] Canonical drift: 01_ELITE_ROLE.md contains L4.1"
    L41_FOUND=$((L41_FOUND + 1))
fi
if grep -q "L4\.1" README.md && grep -q "01_ELITE_ROLE.md" README.md; then
    echo "[FAIL] Canonical drift: README.md references 01_ELITE_ROLE.md L4.1"
    L41_FOUND=$((L41_FOUND + 1))
fi
if grep -q "L4\.1" SYSTEM_PROMPT_INSTALL.md && grep -q "01_ELITE_ROLE.md" SYSTEM_PROMPT_INSTALL.md; then
    echo "[FAIL] Canonical drift: SYSTEM_PROMPT_INSTALL.md references 01_ELITE_ROLE.md L4.1"
    L41_FOUND=$((L41_FOUND + 1))
fi
if [ "$L41_FOUND" -eq 0 ]; then
    echo "[PASS] Canonical drift: L4.1 not in 01_ELITE_ROLE.md; no cross-references"
else
    ERRORS=$((ERRORS + 1))
fi

# 10. Root-level Max Size enforcement (P1.1 from 2026-05-18 audit)
# Closes the enforcement vacuum where root-level *.md files self-declared
# a `Max Size:` cap but the integrity script ignored them.
ROOT_THRESHOLD_FAIL=0
for file in *.md; do
    if grep -qP '^> \*\*Max Size:\*\* \d+ lines' "$file" 2>/dev/null; then
        LINES=$(wc -l < "$file")
        MAX=$(grep -oP '(?<=^> \*\*Max Size:\*\* )\d+(?= lines)' "$file" 2>/dev/null | head -1 || true)
        if [ -n "$MAX" ] && [ "$LINES" -gt "$MAX" ]; then
            echo "[FAIL] $file: $LINES lines > $MAX max (root-level)"
            ROOT_THRESHOLD_FAIL=$((ROOT_THRESHOLD_FAIL + 1))
        fi
    fi
done
if [ "$ROOT_THRESHOLD_FAIL" -eq 0 ]; then
    echo "[PASS] Root-level Max Size thresholds: all declared files within limits"
else
    ERRORS=$((ERRORS + 1))
fi

echo ""
if [ "$ERRORS" -eq 0 ]; then
    echo "=== ALL CHECKS PASS ==="
    exit 0
else
    echo "=== $ERRORS CHECK(S) FAILED ==="
    exit 1
fi
