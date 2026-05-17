# COMPACT_TEST — Compact-Safe Continuity Verification v2.0

> **Role:** Prove that `/compact` does not lose critical state AND does not bloat operational read surface.  
> **Read:** Before running compact tests; after compact failures.  
> **Updated:** After each compact test run.  
> **Authority:** Audit (Rank 9)

---

## Compact Completeness Checklist

Before `/compact`, AI must confirm ALL critical state is persisted:

| # | Item | Persisted To | Verification Method |
|---|---|---|---|
| 1 | Current task goal and scope | CONTEXT.md + COMPACT_STATE.md | Read back and confirm match |
| 2 | Last completed step | CONTEXT.md + COMPACT_STATE.md | Read back and confirm match |
| 3 | Next pending step | CONTEXT.md + COMPACT_STATE.md | Read back and confirm match |
| 4 | Active assumptions (with IDs) | ASSUMPTIONS.md + COMPACT_STATE.md | Count assumptions before/after |
| 5 | Active decisions (with IDs) | DECISIONS.md + COMPACT_STATE.md | Count decisions before/after |
| 6 | Risk items (score ≥ 7) | ASSUMPTIONS.md + COMPACT_STATE.md | Verify high-risk items preserved |
| 7 | Modified files list | CONTEXT.md + COMPACT_STATE.md | List files before/after |
| 8 | Blockers (if any) | CONTEXT.md + COMPACT_STATE.md | Verify blocker description preserved |

### Acceptable Loss

| # | Item | Why Acceptable |
|---|---|---|
| 1 | Detailed conversation history | Reconstructed from memory files |
| 2 | Intermediate reasoning steps | Not needed for task continuation |
| 3 | Old verification results | Superseded by new verification |
| 4 | Superseded assumptions | Already archived if rollup occurred |

---

## Test 1: Basic Compact Survival

**Precondition:** Active task in progress with assumptions and decisions.

**Steps:**
1. Record current state (task, last step, next step, assumptions, decisions, risks, files)
2. Trigger `/compact`
3. Verify AI writes COMPACT_STATE.md
4. Verify COMPACT_STATE.md contains all critical state
5. Run `/compact`
6. Verify AI reads COMPACT_STATE.md → RESUME.md → CONTEXT.md
7. Verify AI confirms: "State restored. Active task: [X]. Next: [Y]."
8. Verify all critical state matches pre-compact

**Pass Criteria:** 0 items lost from critical state list.

---

## Test 2: Multiple Compacts Without Bloat

**Precondition:** Same task, multiple compact cycles.

**Steps:**
1. Work on task for 3 turns
2. `/compact` (Cycle 1)
3. Work 3 more turns
4. `/compact` (Cycle 2)
5. Work 3 more turns
6. `/compact` (Cycle 3)
7. Work 3 more turns
8. `/compact` (Cycle 4)
9. Work 3 more turns
10. `/compact` (Cycle 5)
11. Verify task continuity across all 5 cycles
12. Verify default read path (README + RESUME + CONTEXT + ASSUMPTIONS) ≤ 300 lines
13. Verify archive files exist and contain historical data
14. Verify active files are within thresholds per ROLLUP_POLICY.md

**Pass Criteria:**
- Task progresses correctly; no regression
- Default read path ≤ 300 lines after 5 compacts
- No active file exceeds its threshold
- Archive files contain correct historical data

---

## Test 3: Compact with Rollup Trigger

**Precondition:** Active file (e.g., ASSUMPTIONS.md) is near threshold.

**Steps:**
1. Populate ASSUMPTIONS.md with 7 active assumptions (near 8-item threshold)
2. Add 1 more assumption during work
3. Trigger `/compact`
4. Verify AI checks thresholds BEFORE writing COMPACT_STATE.md
5. Verify rollup triggered (stale assumptions archived)
6. Verify COMPACT_STATE.md written with correct post-rollup state
7. Verify archive file contains archived assumptions
8. Post-compact, verify active file is under threshold

**Pass Criteria:** Rollup occurs during pre-compact ritual; no data loss; active file bounded.

---

## Test 4: Compact with High Risk

**Precondition:** Active task with risk score ≥ 13.

**Steps:**
1. Task has active risk item R1 (score 15)
2. Trigger `/compact`
3. Verify COMPACT_STATE.md explicitly includes risk item R1
4. Post-compact, verify AI reminds user of risk before continuing
5. Verify risk is not forgotten or downgraded

**Pass Criteria:** High-risk items survive compact AND are re-emphasized post-compact.

---

## Test 5: Compact Omission Detection

**Precondition:** AI attempts compact but misses an item.

**Steps:**
1. Introduce active task with 3 assumptions
2. Trigger `/compact`
3. Manually verify COMPACT_STATE.md has only 2 assumptions
4. On post-compact read, AI should detect mismatch:
   "Mismatch detected: ASSUMPTIONS.md has 3 active assumptions, COMPACT_STATE.md has 2. Reading full state from authoritative source (ASSUMPTIONS.md)."
5. Verify AI reads ASSUMPTIONS.md to recover missing item

**Pass Criteria:** Missing item detected and recovered from authoritative source.

---

## Test 6: Rollup Correctness During Compact

**Precondition:** Multiple old assumptions/decisions exist.

**Steps:**
1. Create 5 active assumptions, 3 FALSIFIED assumptions in ASSUMPTIONS.md
2. Create 4 active decisions, 2 SUPERSEDED decisions in DECISIONS.md
3. Create 6 audit entries in AUDIT_LOG.md
4. Trigger `/compact`
5. Verify pre-compact rollup archives:
   - 3 FALSIFIED assumptions → archive/assumptions_archive.md
   - 2 SUPERSEDED decisions → archive/decisions_archive.md
   - 1 oldest audit entry → archive/audit_archive.md
6. Verify active files now contain only active/recent entries
7. Verify COMPACT_STATE.md reflects post-rollup state
8. Post-compact, verify continuity with correct active state

**Pass Criteria:**
- Correct entries archived
- Active files bounded
- No active entry lost
- Archive entries preserved with full content

---

## Test 7: No Critical State Lost During Archival

**Precondition:** Task with multiple assumptions and decisions.

**Steps:**
1. Create task with 10 assumptions (mix of ACTIVE, CONFIRMED, FALSIFIED)
2. Create task with 8 decisions (mix of ACTIVE, SUPERSEDED)
3. Trigger `/compact` with rollup
4. After archival, verify:
   - All ACTIVE assumptions still in ASSUMPTIONS.md
   - All CONFIRMED/FALSIFIED assumptions in archive with full metadata
   - All ACTIVE decisions still in DECISIONS.md
   - All SUPERSEDED decisions in archive with full metadata
5. Post-compact, verify AI can reference any active assumption/decision by ID
6. Verify archived entries can be retrieved by reading archive files

**Pass Criteria:** Zero data loss during archival. Active layer correct. Archive layer complete.

---

## Compact Proof Statement

```
COMPACT-SAFE CERTIFICATION

System: Kimi Protocol v2.0
Date: [YYYY-MM-DD]
Tester: [Name]

Tests Run: [N]
Tests Passed: [N]
Tests Failed: [N]

Critical State Items Verified:
  [✓] Task goal survives
  [✓] Last step survives
  [✓] Next step survives
  [✓] Active assumptions survive
  [✓] Active decisions survive
  [✓] Risk items survive
  [✓] Modified files survive
  [✓] Blockers survive

Bloat Resistance Verified:
  [✓] Default read path ≤ 300 lines after 5 compacts
  [✓] Active files within thresholds
  [✓] Archive files contain correct historical data
  [✓] Rollup triggers correctly during compact
  [✓] No data lost during archival

Verdict: [COMPACT-SAFE / COMPACT-UNSAFE — reasons]

If UNSAFE: List blockers and remediation plan.
```
