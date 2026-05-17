# COMPACT_TEST — Compact-Safe Continuity Verification

> **Role:** Prove that `/compact` does not lose critical state.  
> **Read:** Before running compact tests; after compact failures.  
> **Updated:** After each compact test run.  
> **Authority:** Audit (Rank 9)

---

## Compact Completeness Checklist

Before `/compact`, AI must confirm ALL of the following are persisted to memory files:

### Critical State (Must Survive)

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

### Acceptable Loss (May Be Lost)

| # | Item | Why Acceptable |
|---|---|---|
| 1 | Detailed conversation history | Can be reconstructed from memory files |
| 2 | Intermediate reasoning steps | Not needed for task continuation |
| 3 | Old verification results | Superseded by new verification |
| 4 | Superseded assumptions | Already marked in ASSUMPTIONS.md |

---

## Compact Test Procedure

### Test 1: Basic Compact Survival

**Precondition:** Active task in progress with assumptions and decisions.

**Steps:**
1. Record current state:
   ```
   Task: [description]
   Last Step: [description]
   Next Step: [description]
   Assumptions: [A1, A2, ...]
   Decisions: [D1, D2, ...]
   Risk Items: [R1, ...]
   Files Modified: [list]
   ```
2. Trigger `/compact`
3. Verify AI writes COMPACT_STATE.md
4. Verify COMPACT_STATE.md contains all critical state
5. Run `/compact`
6. Verify AI reads COMPACT_STATE.md → RESUME.md → CONTEXT.md
7. Verify AI confirms: "State restored. Active task: [X]. Next: [Y]."
8. Verify all critical state matches pre-compact

**Pass Criteria:** 0 items lost from critical state list.

---

### Test 2: Multiple Compacts

**Precondition:** Same task, multiple compact cycles.

**Steps:**
1. Work on task for 3 turns
2. `/compact` (Cycle 1)
3. Work 3 more turns
4. `/compact` (Cycle 2)
5. Work 3 more turns
6. `/compact` (Cycle 3)
7. Verify task continuity across all 3 cycles
8. Verify ASSUMPTIONS.md accumulates (not overwritten)
9. Verify DECISIONS.md accumulates (not overwritten)

**Pass Criteria:** Task progresses correctly; no regression; assumptions/decisions preserved cumulatively.

---

### Test 3: Compact with High Risk

**Precondition:** Active task with risk score ≥ 13.

**Steps:**
1. Task has active risk item R1 (score 15)
2. Trigger `/compact`
3. Verify COMPACT_STATE.md explicitly includes risk item R1
4. Post-compact, verify AI reminds user of risk before continuing
5. Verify risk is not forgotten or downgraded

**Pass Criteria:** High-risk items survive compact AND are re-emphasized post-compact.

---

### Test 4: Compact Omission Detection

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

## Compact Proof Statement

```
COMPACT-SAFE CERTIFICATION

System: Kimi Protocol v1.0
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

Verdict: [COMPACT-SAFE / COMPACT-UNSAFE — reasons]

If UNSAFE: List blockers and remediation plan.
```
