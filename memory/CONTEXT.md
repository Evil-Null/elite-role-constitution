# CONTEXT.md — Active Task State

> **Role:** Operational state. What we are doing right now.  
> **Read:** At every session start, after `/compact`, when task context is unclear.  
> **Updated:** After every significant discovery, decision, or state change.  
> **Authority:** Operational (Rank 4)

---

## Current Task

**Goal:** [One sentence describing what we are trying to achieve]
**Status:** [PLANNING / EXECUTING / VERIFYING / BLOCKED / COMPLETE]
**Started:** [Timestamp]
**Last Updated:** [Timestamp]

## Last Completed Step

**Step:** [Description of what was last done]
**Evidence:** [Verification result or reference]
**Completed At:** [Timestamp]

## Next Step

**Step:** [Description of what must be done next]
**Depends On:** [Previous step / nothing / assumption X]
**Blocked By:** [None / specific blocker]

## Active Files

```
Files in scope:
  [NEW]     /path/to/new/file      — [purpose]
  [MOD]     /path/to/modified/file — [change description]
  [DEL]     /path/to/deleted/file  — [deletion reason]
```

## Active Assumptions

```
A1: [assumption text] — Confidence: [HIGH/MED/LOW] — ID from ASSUMPTIONS.md
A2: [assumption text] — Confidence: [HIGH/MED/LOW] — ID from ASSUMPTIONS.md
```

## Active Decisions

```
D1: [decision summary] — From DECISIONS.md
D2: [decision summary] — From DECISIONS.md
```

## Risk Items (Score ≥ 7)

```
R1: [risk description] — Score: [X] — From ASSUMPTIONS.md
```

## Blockers

```
[None / specific blocker with description and required action]
```

## Notes

```
[Any transient notes, reminders, or observations not fitting above]
```
