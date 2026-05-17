# ASSUMPTIONS.md — Risk Registry

> **Role:** Tracked assumptions with confidence and impact. Surfaces hidden risk.  
> **Read:** At session start, before executing on assumptions, during verification.  
> **Updated:** When assumption declared, verified, or proven wrong.  
> **Authority:** Risk (Rank 6) — decisions depend on this.

---

## Active Assumptions (Status: ACTIVE or CONFIRMED)

```
A1: Kimi CLI supports static system prompt loading via manual paste or project config
  Declared: 2026-05-17T04:00+04:00
  Context: Required for protocol deployment; no runtime loader exists
  Confidence: HIGH
  Impact if Wrong: System cannot enforce L1-L7 without prompt loading
  Risk Score: P2 × I5 = 10
  Verification Plan: Test system prompt paste in Kimi CLI; verify AI acknowledges laws
  Verified: NO
  Status: ACTIVE

A2: Tool use (read/write files) is available in Kimi CLI for memory file operations
  Declared: 2026-05-17T04:00+04:00
  Context: Required for memory system function
  Confidence: HIGH
  Impact if Wrong: Memory files cannot be read/written; continuity breaks
  Risk Score: P2 × I5 = 10
  Verification Plan: Attempt file read/write in Kimi CLI; verify success
  Verified: NO
  Status: ACTIVE

A3: User will run validation tests (TEST_SCENARIOS.md) before declaring system operational
  Declared: 2026-05-17T04:00+04:00
  Context: Validation matrix shows 25 UNTESTED items
  Confidence: MED
  Impact if Wrong: System deployed untested; drift and failures undetected
  Risk Score: P3 × I4 = 12
  Verification Plan: Explicit validation checklist in SYSTEM_PROMPT_INSTALL.md
  Verified: NO
  Status: ACTIVE

A4: Context window (~128K tokens) is sufficient for system prompt + task execution
  Declared: 2026-05-17T04:00+04:00
  Context: System prompt is ~500-800 tokens; tasks vary
  Confidence: MED
  Impact if Wrong: Context exhaustion; frequent `/compact` or session restarts
  Risk Score: P3 × I4 = 12
  Verification Plan: Monitor context usage during first 10 tasks
  Verified: NO
  Status: ACTIVE

A5: Memory file read/write latency is acceptable for turn-by-turn workflow
  Declared: 2026-05-17T04:00+04:00
  Context: Each turn may read 4 files and write 2-5 files
  Confidence: HIGH
  Impact if Wrong: Workflow becomes slow and frustrating
  Risk Score: P2 × I3 = 6
  Verification Plan: Measure perceived latency during first session
  Verified: NO
  Status: ACTIVE
```

## Risk Score Rules

- **Score ≥ 13:** Must escalate to user before proceeding
- **Score ≥ 19:** STOP. Do not proceed without explicit override
- **Confidence LOW on critical path:** Must verify or escalate
- **Stale (> 7 days old, ACTIVE):** Re-verify or downgrade

## Drift Check

Every session start, scan for:
- ACTIVE assumptions > 7 days old → flag as STALE
- CONFIRMED assumptions with new contradictory evidence → flag
- FALSIFIED assumptions still referenced elsewhere → flag

## Current Risk Summary

| Assumption | Score | Action Required |
|---|---|---|
| A1 | 10 | Verify prompt loading works |
| A2 | 10 | Verify tool use works |
| A3 | 12 | Ensure user knows validation is required |
| A4 | 12 | Monitor context usage |
| A5 | 6 | Monitor latency |

**Highest Risk:** A3 and A4 (score 12). Close to escalation threshold (13).
