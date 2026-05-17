# DECISIONS.md — Active Choice Registry

> **Role:** ACTIVE and recent decisions only. SUPERSEDED/>30-day-old decisions are archived.  
> **Read:** When current task involves previous choices.  
> **Updated:** After every significant decision.  
> **Authority:** Historical (Rank 7) — reference, not override.  
> **Max Size:** 40 lines. Exceed → trigger rollup to `archive/decisions_archive.md`.

---

## Active Decisions

```
D1: Protocol approach over runtime architecture — ACTIVE — 2026-05-17
D2: File-based memory over context-only continuity — ACTIVE — 2026-05-17
D3: Validation-first deployment — ACTIVE — 2026-05-17
D4: Bounded multi-layer memory structure (active + archive + policy) — ACTIVE — 2026-05-17
```

## Usage Rule

When encountering a similar situation:
1. Reference the decision: "Per D3, we decided [X] because [Y]."
2. Ask: "Has context changed enough to reconsider?"
3. If yes → new decision, log as D[new]
4. If no → follow existing without re-debate

## Archive Reference

- **Archived decisions:** 15
- **Archive location:** `memory/archive/decisions_archive.md`
- **Last rollup:** N/A
