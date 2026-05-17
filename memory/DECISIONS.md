# DECISIONS.md — Choice Log

> **Role:** Historical record of significant choices. Prevents re-debating.  
> **Read:** When current task involves previous choices.  
> **Updated:** After every significant decision.  
> **Authority:** Historical (Rank 7) — reference, not override.

---

## Active Decisions

```
D1: Protocol approach over runtime architecture
  Date: 2026-05-17T04:47+04:00
  Context: FORENSIC_AUDIT.md revealed SYSTEM_PLAN.md was 30% self-projected runtime infrastructure (kernel, loader, classifier, state machine) incompatible with Kimi CLI
  Decision: Adopt manual Human-AI Collaboration Protocol instead of imaginary AI runtime OS
  Reasoning: Kimi CLI is a chat interface, not an agent platform. Runtime infrastructure cannot execute. Manual protocol with static prompt + user triggers + file memory is the only deployable approach.
  Alternatives Rejected:
    - Keep SYSTEM_PLAN.md as-is → Rejected: constitutionally impure, not Kimi-native
    - Build custom wrapper/script → Rejected: out of scope, user wants native CLI usage
  Risk Accepted: Less architectural elegance; more user discipline required
  Related Assumptions: A1, A2
  Status: ACTIVE

D2: File-based memory over context-only continuity
  Date: 2026-05-17T05:00+04:00
  Context: Kimi CLI has no persistence between sessions; conversation history is lost on restart
  Decision: Use external markdown files in memory/ directory for state continuity
  Reasoning: Files survive session boundaries; can be read on resume; provide audit trail. Context-only approach loses state on restart.
  Alternatives Rejected:
    - Rely on conversation history → Rejected: lost on session restart
    - Use single summary file → Rejected: insufficient granularity for assumptions/decisions
  Risk Accepted: File I/O overhead; user must manage file directory
  Related Assumptions: A2, A5
  Status: ACTIVE

D3: Validation-first deployment
  Date: 2026-05-17T05:10+04:00
  Context: System structurally complete but operationally untested
  Decision: Create comprehensive validation harness (matrix + scenarios + tests) before declaring operational
  Reasoning: Elite standard demands evidence of correctness. Untested system risks drift and failure in production use.
  Alternatives Rejected:
    - Declare operational immediately → Rejected: no evidence of correctness
    - Test ad-hoc → Rejected: insufficient coverage; no reproducibility
  Risk Accepted: Delayed deployment; additional documentation overhead
  Related Assumptions: A3
  Status: ACTIVE

D4: 7-file memory structure
  Date: 2026-05-17T05:00+04:00
  Context: Need to separate concerns: state, checkpoint, decisions, assumptions, audit, compact recovery
  Decision: Create 7 distinct memory files with clear authority hierarchy
  Reasoning: Separation prevents duplication, enables drift detection, allows granular updates. Single file would become unwieldy.
  Alternatives Rejected:
    - Single MEMORY.md → Rejected: no separation of concerns; hard to audit
    - 3 files only → Rejected: insufficient granularity for assumptions and decisions
  Risk Accepted: More files to manage; requires discipline to update consistently
  Related Assumptions: A5
  Status: ACTIVE
```

## Usage Rule

When encountering a situation similar to a logged decision:
1. Reference the decision: "Per D3, we previously decided [validation-first] because [evidence required]."
2. Ask: "Has context changed enough to reconsider?"
3. If yes → treat as new decision, log as D[new]
4. If no → follow existing decision without re-debate
