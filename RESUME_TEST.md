# RESUME_TEST — Session Continuity Verification

> **Role:** Prove that resumed sessions faithfully restore previous state.  
> **Read:** Before running resume tests; after continuity failures.  
> **Updated:** After each resume test run.  
> **Authority:** Audit (Rank 9)

---

## Resume Completeness Checklist

At session resume, AI must read and verify ALL of the following:

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
| 6 | memory/AUDIT_LOG.md | User requests audit | Historical context for drift detection |

---

## Resume Test Procedure

### Test 1: Basic Resume

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
5. Verify AI summarizes: "Resumed. Task: Design API schema. Last: Defined user endpoints. Next: Define auth endpoints. Assumptions: A1 (token-based auth, HIGH)."
6. Verify AI asks: "Confirm or update direction?"
7. User confirms: "Yes, continue"
8. AI proceeds with auth endpoints

**Pass Criteria:** Exact task state restored; user confirmation obtained; execution continues correctly.

---

### Test 2: Resume with User Update

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
   - Treats next step as new planning phase
   - Re-evaluates risk if needed

**Pass Criteria:** Direction change handled gracefully; assumptions updated; no stale logic carried forward.

---

### Test 3: Resume Mismatch Detection

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

### Test 4: Resume with Stale Assumptions

**Precondition:** ASSUMPTIONS.md has assumption > 7 days old.

**Steps:**
1. Create assumption A1 with timestamp 8 days ago
2. End session
3. Start new session, send "resume"
4. Verify AI flags stale assumption:
   "Warning: Assumption A1 is 8 days old (status: ACTIVE). Recommend re-verification."
5. AI asks user: "Is A1 still valid?"

**Pass Criteria:** Stale assumption detected; user alerted; re-verification requested.

---

### Test 5: Resume Without Prior Session

**Precondition:** No previous session; RESUME.md has default/empty state.

**Steps:**
1. Start fresh project with no prior work
2. Send: "resume"
3. Verify AI reads RESUME.md
4. Verify AI reports: "No active session found. RESUME.md shows no pending tasks. What would you like to work on?"
5. AI does NOT invent previous state

**Pass Criteria:** Empty state handled gracefully; no hallucination of previous work.

---

### Test 6: Multi-Session Task

**Precondition:** Same task spans 3 sessions.

**Steps:**
1. Session 1: Plan API schema → save state
2. Session 2: Resume → define user endpoints → save state
3. Session 3: Resume → define auth endpoints → complete → log audit
4. Verify AUDIT_LOG.md shows all 3 sessions as one completed task
5. Verify no state loss between sessions

**Pass Criteria:** Task completes across 3 sessions with zero state loss.

---

## Resume Proof Statement

```
RESUME-SAFE CERTIFICATION

System: Kimi Protocol v1.0
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

Verdict: [RESUME-SAFE / RESUME-UNSAFE — reasons]

If UNSAFE: List blockers and remediation plan.
```
