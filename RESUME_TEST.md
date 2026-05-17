# RESUME_TEST — Session Continuity Verification v2.0

> **Role:** Prove that resumed sessions faithfully restore previous state even with archives present.  
> **Read:** Before running resume tests; after continuity failures.  
> **Updated:** After each resume test run.  
> **Authority:** Audit (Rank 9)

---

## Resume Completeness Checklist

At session resume, AI must read and verify:

### Mandatory Read (Session Start)

| # | File | Purpose | What Must Be Restored |
|---|---|---|---|
| 1 | memory/README.md | Confirm structure | Memory system architecture understood |
| 2 | memory/RESUME.md | Where we left off | Session checkpoint with task summary |
| 3 | memory/CONTEXT.md | Current state | Active task, last step, next step, blockers |
| 4 | memory/ASSUMPTIONS.md | Active risks | Pending assumptions with confidence and impact |

### Conditional Read (If Relevant)

| # | File | When | Purpose |
|---|---|---|---|
| 5 | memory/DECISIONS.md | Task involves previous choices | Avoid re-debating settled questions |
| 6 | memory/AUDIT_LOG.md | User requests recent audit | Short-term drift detection |
| 7 | memory/archive/* | Explicit historical lookup | Long-term trend analysis |

**Archive files MUST NOT be read during default resume.**

---

## Test 1: Basic Resume

**Precondition:** Previous session ended with active task.

**Steps:**
1. End Session A with:
   ```
   Task: Design API schema
   Last Step: Defined user endpoints
   Next Step: Define auth endpoints
   Assumptions: A1 (token-based auth, confidence HIGH)
   ```
2. Start new Session B
3. Send: "resume"
4. Verify AI reads all 4 mandatory files
5. Verify AI does NOT read archive files by default
6. Verify AI summarizes: "Resumed. Task: Design API schema. Last: Defined user endpoints. Next: Define auth endpoints. Assumptions: A1 (token-based auth, HIGH)."
7. Verify AI asks: "Confirm or update direction?"
8. User confirms: "Yes, continue"
9. AI proceeds with auth endpoints

**Pass Criteria:** Exact task state restored; no archive reads; user confirmation obtained; execution continues correctly.

---

## Test 2: Resume with Archives Present

**Precondition:** Previous session ended with active task AND archives exist.

**Steps:**
1. Session A: Complete 10 tasks (so audit archive has entries)
2. Session A: Create 15 assumptions (so assumption archive has entries)
3. Session A: Create 12 decisions (so decision archive has entries)
4. End Session A with active task
5. Start Session B
6. Send: "resume"
7. Verify AI reads only 4 mandatory files (README, RESUME, CONTEXT, ASSUMPTIONS)
8. Verify AI does NOT read archive/assumptions_archive.md, archive/decisions_archive.md, or archive/audit_archive.md
9. Verify default read surface ≤ 300 lines
10. Verify AI correctly restores active task state
11. User explicitly asks: "What was assumption A3 from two weeks ago?"
12. Verify AI reads archive/assumptions_archive.md to answer

**Pass Criteria:**
- Default resume reads ≤ 300 lines
- Archives excluded from default path
- Active state correctly restored
- Archives accessible on explicit request

---

## Test 3: Resume with User Update

**Precondition:** Previous session ended with active task.

**Steps:**
1. End Session A with task X
2. Start Session B
3. Send: "resume"
4. AI summarizes state
5. User responds: "Direction changed. We are now using OAuth instead of token-based auth."
6. Verify AI:
   - Acknowledges change
   - Updates ASSUMPTIONS.md (A1 superseded, A2 added)
   - If thresholds exceeded, triggers rollup
   - Treats next step as new planning phase
   - Re-evaluates risk if needed

**Pass Criteria:** Direction change handled gracefully; assumptions updated; no stale logic carried forward; rollup triggered if needed.

---

## Test 4: Resume Mismatch Detection

**Precondition:** RESUME.md and CONTEXT.md have conflicting information.

**Steps:**
1. Manually edit RESUME.md to say "Next step: X"
2. Manually edit CONTEXT.md to say "Next step: Y"
3. Start new session, send "resume"
4. Verify AI detects conflict:
   "Conflict detected: RESUME.md says next step is X, CONTEXT.md says Y. CONTEXT.md has higher operational authority (Rank 4 vs 5). Using CONTEXT.md. Confirm: next step is Y?"
5. User confirms or resolves

**Pass Criteria:** Conflict detected; authority hierarchy applied; user consulted.

---

## Test 5: Stale Assumption Detection After Archival

**Precondition:** ASSUMPTIONS.md has assumption > 7 days old, archives exist.

**Steps:**
1. Create assumption A1 with timestamp 8 days ago, status ACTIVE
2. Run rollup so old assumptions are archived
3. End session
4. Start new session, send "resume"
5. Verify AI flags stale assumption:
   "Warning: Assumption A1 is 8 days old (status: ACTIVE). Recommend re-verification."
6. AI asks user: "Is A1 still valid?"
7. Verify AI does not confuse archived assumptions with active ones

**Pass Criteria:** Stale assumption detected; user alerted; archive/active boundary respected.

---

## Test 6: Resume Without Prior Session

**Precondition:** No previous session; RESUME.md has default/empty state.

**Steps:**
1. Start fresh project with no prior work
2. Send: "resume"
3. Verify AI reads RESUME.md
4. Verify AI reports: "No active session found. RESUME.md shows no pending tasks. What would you like to work on?"
5. AI does NOT invent previous state
6. Verify AI does not read archive files

**Pass Criteria:** Empty state handled gracefully; no hallucination; no unnecessary archive reads.

---

## Test 7: Multi-Session Task with Archives

**Precondition:** Same task spans 3 sessions, archives accumulate.

**Steps:**
1. Session 1: Plan API schema → save state
2. Session 2: Resume → define user endpoints → create 8 assumptions → save state
3. Session 3: Resume → define auth endpoints → complete → log audit
4. Verify AUDIT_LOG.md shows last 5 entries (Session 3 task in recent)
5. Verify archive/audit_archive.md contains older entries from Sessions 1-2
6. Verify no state loss between sessions
7. Verify default resume in Session 3 reads ≤ 300 lines

**Pass Criteria:** Task completes across 3 sessions with zero state loss; archives correctly populated; read path bounded.

---

## Test 8: Authority Conflict Between Active and Archived Layers

**Precondition:** Active file and archive file contain entry with same ID.

**Steps:**
1. Create decision D1 in DECISIONS.md, mark ACTIVE
2. Later, mark D1 as SUPERSEDED
3. Run rollup — D1 moves to archive/decisions_archive.md
4. Accidentally re-create D1 in DECISIONS.md (duplicate ID)
5. Start new session, task involves D1
6. Verify AI detects duplicate:
   "Duplicate ID detected: D1 exists in both active DECISIONS.md and archive/decisions_archive.md. Archive wins (older, authoritative). Active copy is stale. Removing from active file."
7. Verify AI removes stale copy from active file
8. Verify AI references archived D1 correctly

**Pass Criteria:** Duplicate detected; archive authority respected; active file cleaned.

---

## Resume Proof Statement

```
RESUME-SAFE CERTIFICATION

System: Kimi Protocol v2.0
Date: [YYYY-MM-DD]
Tester: [Name]

Tests Run: [N]
Tests Passed: [N]
Tests Failed: [N]

Continuity Verified:
  [✓] Task goal restored
  [✓] Progress position restored
  [✓] Next step clear
  [✓] Assumptions restored
  [✓] Decisions restored
  [✓] Risk items preserved
  [✓] User confirmation obtained
  [✓] Stale items detected
  [✓] Conflicts detected
  [✓] Multi-session tasks complete

Bounded Memory Verified:
  [✓] Default resume reads ≤ 300 lines
  [✓] Archives excluded from default path
  [✓] Archives accessible on explicit request
  [✓] Archive/active authority conflicts resolved correctly

Verdict: [RESUME-SAFE / RESUME-UNSAFE — reasons]

If UNSAFE: List blockers and remediation plan.
```
