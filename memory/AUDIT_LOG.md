# AUDIT_LOG.md — Task History & Drift Detection

> **Role:** Archive of completed tasks. Enables trend analysis and behavioral audit.  
> **Read:** When auditing past work, detecting drift, or reviewing performance.  
> **Updated:** After task completion.  
> **Authority:** Archive (Rank 9) — read-only for operational decisions.

---

## Entry Format

```
ENTRY [ID]: [Task Title]
  Completed: [YYYY-MM-DD HH:MM]
  Duration: [N turns / N sessions]
  Task Type: [Routine / Execution / Design / Critical]
  
  Request Summary:
    [What user asked for]
  
  Delivered:
    [What was produced]
  
  Verification Result:
    V1 Structural:   [PASS / FAIL]
    V2 Semantic:     [PASS / FAIL]
    V3 Safety:       [PASS / FAIL]
    V4 Quality:      [PASS / FAIL]
    V5 Spec:         [PASS / FAIL]
    V6 Regression:   [PASS / FAIL]
    V7 Edge Cases:   [PASS / FAIL]
    V8 Evidence:     [PASS / FAIL]
    Overall:         [PASS / FAIL]
  
  Issues Found:
    [None / list with severity]
  
  Assumptions Used:
    [A1, A2, ...]
  
  Decisions Made:
    [D1, D2, ...]
  
  Risk Score:
    [Highest risk score encountered]
  
  Iterations:
    [N] (max allowed: 3)
  
  Files Changed:
    [NEW] /path
    [MOD] /path
    [DEL] /path
```

---

## Completed Tasks

```
[Entries appended here]
```

## Drift Detection Queries

Run these checks periodically:

1. **Verification skip rate:** Count entries with overall FAIL / Count total entries → Target < 5%
2. **Iteration average:** Sum iterations / Count entries → Target ≤ 1.5
3. **Assumption falsification rate:** Count entries with falsified assumptions / Count entries → Target < 10%
4. **Escalation rate:** Count entries with escalation / Count entries → Target < 15%
5. **Override rate:** Count entries with "user insisted" / Count entries → Target < 10%

**Trend analysis:** If any metric degrades over 5 consecutive entries → trigger audit mode.
