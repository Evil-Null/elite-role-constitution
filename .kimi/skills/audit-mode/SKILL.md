---
name: audit-mode
description: |
  Multi-step self-audit ritual. Reviews the last 3 to 5 assistant
  responses (or a user-specified subject) against the L1-L7
  Constitutional Laws and reports drift, missed gates, or unstated
  assumptions. Invoke with `/flow:audit-mode` for the automated
  flow, or `/skill:audit-mode` to load this as a reference.
type: flow
tags: [role, audit, governance, L1-L7]
---

# Audit Mode — Flow

This flow walks the agent through a structured self-review against the
Elite Role Constitution. It is the doctrinal equivalent of the user
phrase `audit mode`. Each diamond node lets the agent branch by
emitting `<choice>branch name</choice>` in its response.

```mermaid
flowchart TD
    A([BEGIN]) --> B[Scope: identify the subject of the audit — last N responses, a specific commit range, or a named artifact. State N or the range explicitly.]
    B --> C[Load skills/elite-role/references/5-eye-review.md and review the Constitutional Laws L1-L7 from agent/elite.system.md.]
    C --> D[For each Law L1-L7 list ONE concrete piece of evidence from the subject that confirms compliance, OR mark NOT APPLICABLE with reason.]
    D --> E{Any Law without evidence or any NOT APPLICABLE that should have applied?}
    E -->|Yes — drift found| F[List each gap with: Law number, specific line/file/turn, severity, suggested remediation.]
    E -->|No — clean| G[Run the 6th Lens — Red Team adversarial pass on the subject AND on this audit. Find at least one weakness the 5 default lenses missed.]
    F --> G
    G --> H[Score residual risk P×I per skills/elite-role/references/quantified-risk.md. Note any score >= 13.]
    H --> I[Write the audit narrative: subject, findings, P×I, recommended actions, ALWAYS include 3 ways this audit itself could be wrong.]
    I --> J[Append one entry to memory/AUDIT_LOG.md in the standard format: E<N>: <subject> — <date> — PASS:n/WEAK:n/FAIL:n — Risk:<n> — Iter:<n> — Files:<count>.]
    J --> K([END])
```

## When this flow fires

- The user types `audit mode` or invokes `/flow:audit-mode`
- A long-running session crosses a checkpoint (e.g., every ~10 task
  completions) and the doctrine's "alignment audit" cadence applies
- A turn produced a P × I ≥ 13 outcome and the user has not asked
  for a remediation yet

## What NOT to do in this flow

- Skip Red Team. The 6th lens exists exactly because the 5 defaults
  share confirmation bias.
- Inflate the "evidence" column with adjectives ("looks fine",
  "seems compliant"). Each cell must cite file:line or a specific
  turn.
- Forget the L6 self-deception check on the *audit itself*.

## Output contract

The flow produces a narrative + one row appended to
`memory/AUDIT_LOG.md`. The narrative is in the user's language
(Georgian by default) but the AUDIT_LOG row is the conventional
English format used elsewhere in the file.
