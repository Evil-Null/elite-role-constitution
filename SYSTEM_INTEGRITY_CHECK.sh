#!/bin/bash
# SYSTEM_INTEGRITY_CHECK.sh — v2.4 Repository Integrity Validator
# Run: bash SYSTEM_INTEGRITY_CHECK.sh
# Returns: 0 if all checks pass, 1 if any fail

ERRORS=0

echo "=== System Integrity Check v2.4 ==="

# 1. README file count equals git tracked files
README_COUNT=$(grep -oP '\d+(?= files across)' README.md || echo "0")
GIT_COUNT=$(git ls-files | wc -l)
if [ "$README_COUNT" -eq "$GIT_COUNT" ]; then
    echo "[PASS] File count: README claims $README_COUNT, git has $GIT_COUNT"
else
    echo "[FAIL] File count mismatch: README claims $README_COUNT, git has $GIT_COUNT"
    ERRORS=$((ERRORS + 1))
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

# 3. Memory files respect thresholds
THRESHOLD_FAIL=0
for file in memory/ASSUMPTIONS.md memory/DECISIONS.md memory/AUDIT_LOG.md memory/README.md memory/CONTEXT.md memory/RESUME.md memory/COMPACT_STATE.md; do
    LINES=$(wc -l < "$file")
    MAX=$(grep -oP '\d+(?= lines)' "$file" | head -1)
    if [ -z "$MAX" ]; then
        MAX=999
    fi
    if [ "$LINES" -gt "$MAX" ]; then
        echo "[FAIL] $file: $LINES lines > $MAX max"
        THRESHOLD_FAIL=$((THRESHOLD_FAIL + 1))
    fi
done
if [ "$THRESHOLD_FAIL" -eq 0 ]; then
    echo "[PASS] Memory thresholds: all files within limits"
else
    ERRORS=$((ERRORS + 1))
fi

# 4. Stress log governance exists
if grep -q "STRESS_LOG" memory/ROLLUP_POLICY.md && grep -q "STRESS_LOG" FILE_UPDATE_RULES.md; then
    echo "[PASS] Stress log governance: present in ROLLUP_POLICY and FILE_UPDATE_RULES"
else
    echo "[FAIL] Stress log governance: missing from policy or rules"
    ERRORS=$((ERRORS + 1))
fi

# 5. README does not point to SYSTEM_PLAN.md as canonical
if grep -q "SYSTEM_PLAN.md.*D\.1" README.md; then
    echo "[FAIL] README still references SYSTEM_PLAN.md D.1 as canonical"
    ERRORS=$((ERRORS + 1))
else
    echo "[PASS] README canonical reference: points to KIMI_PROTOCOL.md"
fi

# 6. SYSTEM_PLAN.md is archived
if grep -q "ARCHIVED" SYSTEM_PLAN.md; then
    echo "[PASS] SYSTEM_PLAN.md: archived header present"
else
    echo "[FAIL] SYSTEM_PLAN.md: missing archived header"
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

# 8. Fuzzy trigger matching documented
if grep -q "substring" OPERATING_RULES.md; then
    echo "[PASS] Trigger matching: substring/fuzzy documented"
else
    echo "[FAIL] Trigger matching: no substring/fuzzy documentation"
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
