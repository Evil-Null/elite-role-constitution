---
name: challenge-grade
description: |
  Full elite challenge-grade review. Runs every lens of the 6-Lens
  protocol on a named artifact (file, plan, decision, output) and
  produces an >= 800-word audit with explicit evidence per claim
  and an anti-self-deception block. Invoke with `/flow:challenge-grade`.
type: flow
tags: [role, audit, 6-lens, challenge-grade, governance]
---

# Challenge-Grade Review — Flow

The flow below is the operationalisation of the user phrase
`challenge-grade` defined in `01_ELITE_ROLE.md`. It is heavier than
`/flow:audit-mode` — every lens runs with full evidence, every
gate is explicit, and the output is meant to be defensible against
external review.

```mermaid
flowchart TD
    A([BEGIN]) --> B[State the subject explicitly: file path, plan ID, decision, or commit. Quote the exact thing being graded.]
    B --> C[Load skills/elite-role/references/5-eye-review.md AND skills/elite-role/references/quantified-risk.md.]
    C --> D[Lens 1 - Architect. Output: 1-3 questions asked + concrete evidence + verdict PASS or OBJECTION.]
    D --> E[Lens 2 - Developer. Same format.]
    E --> F[Lens 3 - Security. Same format. Include V3 scan results.]
    F --> G[Lens 4 - QA. Same format. Include edge cases enumerated.]
    G --> H[Lens 5 - Tech Lead. Same format. Include trade-off matrix.]
    H --> I{Any of the 5 lenses returned OBJECTION?}
    I -->|Yes| J[Stop the flow. Surface the objection with its evidence, propose a path to PASS, and request user direction.]
    I -->|No| K[Lens 6 - Red Team adversarial pass. Find AT LEAST 3 weaknesses the previous 5 lenses missed or under-weighted. Each weakness gets a P×I score.]
    K --> L{Any Red Team finding with P×I ≥ 13?}
    L -->|Yes| M[Escalate per L5. The output is NOT challenge-grade-passing yet. Document the finding and propose mitigation.]
    L -->|No| N[Anti-self-deception block. List 3 concrete ways this entire review could be wrong: missed lens, miscalibrated risk, biased framing.]
    M --> N
    N --> O[Final verdict and recommendation. Word count target: ≥ 800 words for the narrative.]
    O --> P[Append AUDIT_LOG.md entry tagged 'challenge-grade'. Append assumptions surfaced to memory/ASSUMPTIONS.md.]
    P --> Q([END])
```

## When this flow fires

- User types `challenge-grade` followed by a subject
- User invokes `/flow:challenge-grade`
- A proposed change has P × I >= 13 from a prior light review and
  needs upgrade to full challenge-grade analysis

## Why each lens is mandatory

The doctrine treats omission of any lens as L7 (Absolute Contract)
violation. "I checked everything mentally" is not evidence. If a
lens does not apply (e.g., a doc-only change has no Security
surface), the flow still must produce a `Lens 3 — N/A: doc-only,
no code path` line — silently skipping is the failure mode.

## Output structure

```
# Challenge-Grade Review · <subject>
## Lens 1 — Architect
  Question: ...
  Evidence: <file>:<line> or <command output>
  Verdict: PASS / OBJECTION
## Lens 2 — Developer ...
## ...
## Lens 6 — Red Team
  Attack 1: ... (P×I = <n>)
  Attack 2: ...
  Attack 3: ...
## Anti-self-deception
  Way 1: ...
  Way 2: ...
  Way 3: ...
## Verdict
  ... (recommendation)
```

## Cost notice

Challenge-grade reviews are deliberately expensive (≥ 800 words,
6 lenses with evidence). They are not the default — the user must
ask for them explicitly, or the doctrine must require them via
`P×I >= 13` upgrade rule.
