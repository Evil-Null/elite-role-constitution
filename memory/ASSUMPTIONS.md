# ASSUMPTIONS.md — Active Risk Registry

> **Role:** ACTIVE assumptions only. FALSIFIED/CONFIRMED/SUPERSEDED assumptions are archived.  
> **Read:** At session start, before executing on assumptions, during verification.  
> **Updated:** When assumption declared, verified, or proven wrong.  
> **Authority:** Risk (Rank 6) — decisions depend on this.  
> **Max Size:** 50 lines. Exceed → trigger rollup to `archive/assumptions_archive.md`.

---

## Active Assumptions

```
A1: Kimi CLI supports static system prompt loading via manual paste or project config
  Declared: 2026-05-17T04:00+04:00  Status: ACTIVE  Score: P2×I5=10
A2: Tool use (read/write files) is available in Kimi CLI for memory file operations
  Declared: 2026-05-17T04:00+04:00  Status: ACTIVE  Score: P2×I5=10
A3: User will run validation tests before declaring system operational
  Declared: 2026-05-17T04:00+04:00  Status: ACTIVE  Score: P3×I4=12
A4: Context window (~128K tokens) is sufficient for system prompt + task execution
  Declared: 2026-05-17T04:00+04:00  Status: ACTIVE  Score: P3×I4=12
A5: Memory file read/write latency is acceptable for turn-by-turn workflow
  Declared: 2026-05-17T04:00+04:00  Status: ACTIVE  Score: P2×I3=6
```

## Risk Score Rules

- **≥13:** Escalate to user. **≥19:** STOP. **Stale (>7 days ACTIVE):** Flag for re-verify.

## Drift Check

Every session start: flag ACTIVE assumptions > 7 days old as STALE.

## Archive Reference

- **Archived assumptions:** 0
- **Archive location:** `memory/archive/assumptions_archive.md`
- **Last rollup:** N/A
