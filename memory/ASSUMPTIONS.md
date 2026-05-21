# ASSUMPTIONS.md — Active Risk Registry

> **Role:** ACTIVE assumptions only. FALSIFIED/CONFIRMED/SUPERSEDED assumptions are archived.  
> **Read:** At session start, before executing on assumptions, during verification.  
> **Updated:** When assumption declared, verified, or proven wrong.  
> **Authority:** Risk (Rank 6) — decisions depend on this.  
> **Max Size:** 50 lines. Exceed → trigger rollup to `archive/assumptions_archive.md`.

---

## Active Assumptions

```
A12: Default read surface remains ≤300 lines after multiple rollups
  Declared: 2026-05-17T11:35+04:00  Status: ACTIVE  Score: P2×I4=8
A13: Session continuity survives user-initiated /compact commands
  Declared: 2026-05-17T11:35+04:00  Status: ACTIVE  Score: P2×I4=8
A14: New session resume correctly restores task state from RESUME.md
  Declared: 2026-05-17T11:35+04:00  Status: ACTIVE  Score: P3×I4=12
A15: Rollup trigger activates before write when threshold is exceeded
  Declared: 2026-05-17T11:35+04:00  Status: ACTIVE  Score: P2×I3=6
A16: context-guard.sh cwd-from-payload correctly locates COMPACT_STATE.md in foreign work_dirs
  Declared: 2026-05-21T02:40+04:00  Status: ACTIVE  Score: P2×I4=8
A17: COMPACT_STATE.md mtime < 5 min is sufficient proxy for save-state ritual freshness
  Declared: 2026-05-21T02:40+04:00  Status: ACTIVE  Score: P3×I4=12
A18: STOP gate (exit 2) will correctly block AI turn in live Kimi session at 67% threshold
  Declared: 2026-05-21T02:50+04:00  Status: ACTIVE  Score: P3×I5=15
```

## Risk Score Rules

- **≥13:** Escalate to user. **≥19:** STOP. **Stale (>7 days ACTIVE):** Flag for re-verify.

## Drift Check

Every session start: flag ACTIVE assumptions > 7 days old as STALE.

## Archive Reference

- **Archived assumptions:** 31
- **Archive location:** `memory/archive/assumptions_archive.md`
- **Last rollup:** 2026-05-21T02:50+04:00
