# ASSUMPTIONS.md — Active Risk Registry

> **Role:** ACTIVE assumptions only. FALSIFIED/CONFIRMED/SUPERSEDED assumptions are archived.  
> **Read:** At session start, before executing on assumptions, during verification.  
> **Updated:** When assumption declared, verified, or proven wrong.  
> **Authority:** Risk (Rank 6) — decisions depend on this.  
> **Max Size:** 50 lines. Exceed → trigger rollup to `archive/assumptions_archive.md`.

---

## Active Assumptions

```
A5: Memory file read/write latency is acceptable for turn-by-turn workflow
  Declared: 2026-05-17T04:00+04:00  Status: ACTIVE  Score: P2×I3=6
A6: Challenge-grade response will fit within context window with system prompt loaded
  Declared: 2026-05-17T11:35+04:00  Status: ACTIVE  Score: P3×I3=9
A7: User has permission to create/edit files in working directory
  Declared: 2026-05-17T11:35+04:00  Status: ACTIVE  Score: P2×I4=8
A8: Archive files maintain append-only integrity across rollups
  Declared: 2026-05-17T11:35+04:00  Status: ACTIVE  Score: P2×I3=6
A12: Default read surface remains ≤300 lines after multiple rollups
  Declared: 2026-05-17T11:35+04:00  Status: ACTIVE  Score: P2×I4=8
A13: Session continuity survives user-initiated /compact commands
  Declared: 2026-05-17T11:35+04:00  Status: ACTIVE  Score: P2×I4=8
A14: New session resume correctly restores task state from RESUME.md
  Declared: 2026-05-17T11:35+04:00  Status: ACTIVE  Score: P3×I4=12
A15: Rollup trigger activates before write when threshold is exceeded
  Declared: 2026-05-17T11:35+04:00  Status: ACTIVE  Score: P2×I3=6
```

## Risk Score Rules

- **≥13:** Escalate to user. **≥19:** STOP. **Stale (>7 days ACTIVE):** Flag for re-verify.

## Drift Check

Every session start: flag ACTIVE assumptions > 7 days old as STALE.

## Archive Reference

- **Archived assumptions:** 27
- **Archive location:** `memory/archive/assumptions_archive.md`
- **Last rollup:** 2026-05-17T11:35+04:00
