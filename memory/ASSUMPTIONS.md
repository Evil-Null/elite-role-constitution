# ASSUMPTIONS.md — Risk Registry

> **Role:** Tracked assumptions with confidence and impact. Surfaces hidden risk.  
> **Read:** At session start, before executing on assumptions, during verification.  
> **Updated:** When assumption declared, verified, or proven wrong.  
> **Authority:** Risk (Rank 6) — decisions depend on this.

---

## Assumption Format

```
A[ID]: [Statement of what is assumed]
  Declared: [YYYY-MM-DD HH:MM]
  Context: [Why this assumption exists]
  Confidence: [HIGH / MED / LOW]
  Impact if Wrong: [What breaks if assumption is false]
  Risk Score: [If quantified: P(1-5) × I(1-5) = Score]
  Verification Plan: [How to confirm or falsify]
  Verified: [YES / NO / PARTIAL / PENDING]
  Verified At: [timestamp or "pending"]
  Status: [ACTIVE / CONFIRMED / FALSIFIED / STALE]
```

---

## Active Assumptions (Status: ACTIVE or CONFIRMED)

```
A1: [Statement]
  Declared: [timestamp]
  Context: [why]
  Confidence: [HIGH/MED/LOW]
  Impact if Wrong: [description]
  Risk Score: [P × I = Score]
  Verification Plan: [how]
  Verified: [NO]
  Status: ACTIVE
```

## Falsified / Stale Assumptions

```
A0: [Statement]
  Declared: [timestamp]
  Confidence: [MED]
  Impact if Wrong: [description]
  Verified: YES
  Verified At: [timestamp]
  Status: FALSIFIED
  Consequence: [What had to change because assumption was wrong]
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
