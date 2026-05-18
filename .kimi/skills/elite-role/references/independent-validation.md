# Independent Validation — R6 mitigation

> Source: `INDEPENDENT_VALIDATION.md` (12-check list) and the
> `IMPROVEMENT_PLAN.md` Red Team analysis (Attack #4 in v1.0 → v1.1
> amendments). Operational procedure only here.

## Why this exists

A single AI reviewer of a single AI's output is the weakest possible
validation. The doctrine names this **R6: single-reviewer recursion**
(P5 × I3 = 15, in the L5 escalate zone). Without an independent eye,
high-stakes outputs are *self-reviewed*, and self-review has a known
failure mode (confirmation bias).

## When R6 must be mitigated before declaring "done"

- Any output the user has framed as `challenge-grade`
- Any audit report or post-mortem that will be acted on
- Any plan with P × I ≥ 13
- Any rewrite of a doctrine file (`01_ELITE_ROLE.md`, `KIMI_PROTOCOL.md`,
  this skill, the agent system prompt)
- Any claim of "fully validated" / "X/X PASS"

## Acceptable independent reviewers

In order of preference (more independent → less independent):

1. **Human peer review.** A second person reads the output and
   either ACKs or marks disagreement inline.
2. **Different-vendor LLM.** Feed the output (not the conversation)
   to a different model family (e.g., GPT, Gemini, Kimi K2 directly)
   and ask it to find ≥ 1 specific flaw not already in the document.
3. **Same-vendor, different session.** A clean Claude session with
   no shared memory, given the artifact and asked for adversarial
   reading. Lower independence (same training, similar biases) but
   still valuable.

A second turn by the same agent in the same conversation **does not
count** — context carryover defeats the purpose.

## How to record an independent pass

Append an entry to `memory/AUDIT_LOG.md` of the form:

```
IND<N>: <artifact> — <reviewer> — <YYYY-MM-DD> — <ACK | objections: a,b,c>
```

Example:

```
IND1: IMPROVEMENT_PLAN.md v1.1 — peer reviewer (Evil-Null) — 2026-05-19 — ACK, one
      note: Phase D.3 Compatibility line could also reference 00_ROLE.md author.
```

After recording, the artifact's R6 risk drops from 15 to ≤ 6.

## When R6 cannot be mitigated this session

- Declare R6 **DEFERRED**, not closed.
- Note the deferral in the response (do not hide it).
- Add an entry to `memory/ASSUMPTIONS.md` so it does not get lost.
- Continue execution **only if the user has explicitly authorised
  it**. The user is the principal; their authorisation overrides
  the procedural gate, but the assumption must be on record.

## The 12-check list

`INDEPENDENT_VALIDATION.md` defines 12 falsifiable checks the
independent reviewer can run. The list is the **definition of**
"thoroughly independently validated":

- 12/12 PASS → R6 closed for this artifact
- < 10 PASS → gaps exist, plan their closure before re-asserting
  "validated"

The reviewer reports PASS/FAIL per check, not a free-form opinion.
That is what makes the validation *measurable*.
