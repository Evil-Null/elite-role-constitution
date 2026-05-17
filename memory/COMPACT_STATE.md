# COMPACT_STATE.md — Post-Compact Recovery Snapshot

> **Role:** Temporary recovery state after `/compact`. Bridges compressed context.  
> **Read:** Immediately after `/compact` command.  
> **Updated:** Only during `/compact` ritual.  
> **Authority:** Recovery (Rank 8) — temporary, superseded by RESUME.md and CONTEXT.md after rehydration.

---

## Compact Event

**Compacted At:** [Timestamp]
**Context Before:** [Approximate usage %]
**Trigger:** [User / AI reminder]

## Active Task Snapshot

**Goal:** [One sentence — must survive compact]
**Phase:** [PLAN / EXECUTE / VERIFY]
**Last Completed:** [One sentence]
**Next Step:** [One sentence]

## Critical State Preservation

```
What was active before compact:
  • Task: [summary]
  • Pending assumptions: [A1, A2]
  • Pending decisions: [D1]
  • Risk items (≥7): [R1]
  • Modified files: [list]
  • Blockers: [none / description]
```

## Rehydration Checklist

After `/compact`, read this file and confirm:

- [ ] Task goal understood
- [ ] Last completed step known
- [ ] Next step clear
- [ ] Active assumptions identified
- [ ] Risk items noted
- [ ] No blockers forgotten

**If any unchecked → read RESUME.md and CONTEXT.md for full state.**

## Post-Compact Confirmation

```
Rehydrated At: [timestamp]
AI Confirm: [State restored. Active task: X. Next: Y.]
User Confirm: [YES / Correction: ...]
```
