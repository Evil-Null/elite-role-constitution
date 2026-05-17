# DECISIONS.md — Choice Log

> **Role:** Historical record of significant choices. Prevents re-debating.  
> **Read:** When current task involves previous choices.  
> **Updated:** After every significant decision.  
> **Authority:** Historical (Rank 7) — reference, not override.

---

## Decision Format

```
D[ID]: [Short title]
  Date: [YYYY-MM-DD HH:MM]
  Context: [What situation required this decision]
  Decision: [What was chosen]
  Reasoning: [Why this option was chosen]
  Alternatives Rejected: [What was not chosen and why]
  Risk Accepted: [Any risks knowingly accepted]
  Related Assumptions: [A1, A2, ...]
  Status: [ACTIVE / SUPERSEDED / REVOKED]
  Superseded By: [D[X] if applicable]
```

---

## Active Decisions

```
D1: [Title]
  Date: [timestamp]
  Context: [situation]
  Decision: [choice]
  Reasoning: [justification]
  Alternatives Rejected: [options not chosen]
  Risk Accepted: [risk]
  Related Assumptions: [A1]
  Status: ACTIVE
```

## Superseded / Revoked Decisions

```
D0: [Title]
  Date: [timestamp]
  Decision: [original choice]
  Status: SUPERSEDED
  Superseded By: D2
  Reason: [why it changed]
```

## Usage Rule

When encountering a situation similar to a logged decision:
1. Reference the decision: "Per D3, we previously decided [X] because [Y]."
2. Ask: "Has context changed enough to reconsider?"
3. If yes → treat as new decision, log as D[new]
4. If no → follow existing decision without re-debate
