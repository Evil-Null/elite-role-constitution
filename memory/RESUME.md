# RESUME.md — Session Checkpoint

> **Role:** Cross-session bridge. Where we stopped.  
> **Read:** At start of every new session.  
> **Updated:** At session end, when context critical, or when user says "save state."  
> **Authority:** Checkpoint (Rank 5)

---

## Session Info

**Saved At:** [Timestamp]
**Saved By:** [AI / User trigger]
**Reason:** [Session end / Context critical / User request]

## Active Task Summary

**Goal:** [One sentence]
**Status:** [IN PROGRESS / BLOCKED / COMPLETE]
**Phase:** [PLAN / EXECUTE / VERIFY / DELIVER]

## Progress

**Last Completed:** [Description of last done step]
**Next Pending:** [Description of next step to do]
**Pending Count:** [N steps remaining]

## Critical State

```
Must-know on resume:
  • Active assumptions: [A1, A2, ...]
  • Active decisions: [D1, D2, ...]
  • Risk items (≥7): [R1, R2, ...]
  • Blockers: [none / description]
  • Modified files: [list]
```

## Files Modified This Session

```
  [NEW] /path/to/file — [purpose]
  [MOD] /path/to/file — [change]
```

## Resume Instructions for AI

1. Read this file first on new session
2. Read CONTEXT.md for full operational state
3. Read ASSUMPTIONS.md for active risks
4. Summarize restored state to user
5. Ask user to confirm or update direction
6. Do NOT execute until user confirms understanding

## User Confirmation (Filled on resume)

```
Resumed At: [timestamp]
User Confirmed: [YES / Updated direction: ...]
AI Summary: [What AI understood from resume]
```
