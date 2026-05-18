# Quantified Risk — P × I Scoring

> Source: `01_ELITE_ROLE.md` L5. Operational procedure only here.

## The scoring matrix

| | I=1 trivial | I=2 minor | I=3 moderate | I=4 major | I=5 catastrophic |
|---|---|---|---|---|---|
| **P=5 near-certain** | 5 | 10 | **15 ESC** | **20 STOP** | **25 STOP** |
| **P=4 likely** | 4 | 8 | 12 | **16 ESC** | **20 STOP** |
| **P=3 possible** | 3 | 6 | 9 | 12 | **15 ESC** |
| **P=2 unlikely** | 2 | 4 | 6 | 8 | 10 |
| **P=1 rare** | 1 | 2 | 3 | 4 | 5 |

- **Score ≥ 13:** escalate — surface the risk to the user with the
  numeric score, three mitigation options, and a recommendation.
- **Score ≥ 19:** STOP — do not propose this as a self-approved path.
  Only the user can authorise the action, and only after seeing the
  score.

## How to score

- **Probability (P):** What is the chance this risk materialises if
  we ship the change as-is? Use base rates when available
  ("similar refactors broke X in 3 of last 10 commits → P=3-4").
- **Impact (I):** If it does materialise, what is the worst plausible
  outcome? Anchor to concrete consequences: lost data, user-visible
  downtime, security breach scope.
- Avoid scoring everything 2×2=4 to dodge escalation. That is L6
  (anti-self-deception) territory — three ways the score could be
  too low.

## Recording

Inline in plans:

```
| # | Risk | P | I | Score | Mitigation |
|---|---|---|---|---|---|
| R1 | ... | 2 | 3 | 6 | ... |
| R2 | ... | 5 | 3 | 15→ESC | ... (escalation note) |
```

In `memory/ASSUMPTIONS.md` and `memory/AUDIT_LOG.md`, prefer the
shorthand: `Risk:<n>` or `P:<x>×I:<y>=<z>`.

## Common scoring traps

1. **Anchoring on Impact alone.** "It's only a 1-line fix, score is
   low." Probability of breaking *something else* may be high.
2. **Single-axis catastrophizing.** Scoring 1×5=5 because "the
   impact would be terrible" while ignoring how unlikely it is.
   Document the probability rationale.
3. **Self-serving downscoring.** If you find yourself rounding down
   to stay below 13, you have triggered L6 — list 3 ways the higher
   score might be the right one.

## Trade-off vs. risk

Risk scoring is **separate** from trade-off evaluation. A change can
have a low risk score and still be the wrong choice on cost / value /
maintainability grounds (Tech Lead lens). Do not collapse the two.
