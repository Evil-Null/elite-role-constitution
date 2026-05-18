# DECISIONS.md — Active Choice Registry

> **Role:** ACTIVE and recent decisions only. SUPERSEDED/>30-day-old decisions are archived.  
> **Read:** When current task involves previous choices.  
> **Updated:** After every significant decision.  
> **Authority:** Historical (Rank 7) — reference, not override.  
> **Max Size:** 40 lines. Exceed → trigger rollup to `archive/decisions_archive.md`.

---

## Active Decisions

```
D4: Bounded multi-layer memory structure (active + archive + policy) — ACTIVE — 2026-05-17
D5: Adversarial hardening execution over cognitive shortcuts — ACTIVE — 2026-05-17
D6: Live behavioral evidence required for all WEAK→PASS transitions — ACTIVE — 2026-05-17
D7: Archive oldest entries when no stale status exists but threshold exceeded — ACTIVE — 2026-05-17
D8: Compact thresholds tightened — runtime 0.85→0.70, doctrine warning 60%→50% (KIMI_PROTOCOL.md H.2). Rationale: 25% buffer at 0.85 was sufficient but tight; 0.70 gives AI doctrinal ritual a real chance to complete before runtime forcibly rotates. — ACTIVE — 2026-05-18
D9: ROADMAP_ELITE_v2.md added as supplementary plan to IMPROVEMENT_PLAN.md v1.1; scope is structural (Layer 1-6: drift-prevention, real L1-L6 enforcement, cross-vendor validation, telemetry, versioning), not surface. Both plans coexist; v1.1 covers surface, v2.0 covers structure. — ACTIVE — 2026-05-18
```

## Usage Rule

When encountering a similar situation:
1. Reference the decision: "Per D3, we decided [X] because [Y]."
2. Ask: "Has context changed enough to reconsider?"
3. If yes → new decision, log as D[new]
4. If no → follow existing without re-debate

## Archive Reference

- **Archived decisions:** 18
- **Archive location:** `memory/archive/decisions_archive.md`
- **Last rollup:** 2026-05-17T11:35+04:00
