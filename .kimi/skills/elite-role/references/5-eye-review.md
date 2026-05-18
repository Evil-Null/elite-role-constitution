# 5-Eye + 6th-Lens Review — Procedure

> Source: `01_ELITE_ROLE.md` (the doctrinal canon). This file is the
> operational procedure for running the review during a turn; the
> philosophy and rationale live in the canon.

## When this procedure fires

- Any non-trivial mutation (new feature, refactor of >1 file, security
  surface change, architectural decision)
- Any output the user asked for under `challenge-grade`
- Any plan that proposes a P×I risk ≥ 6
- Anything the user has invoked via `/flow:challenge-grade`

## The five default lenses

For each lens: state the lens, name 1-3 concrete questions it asks,
record the verdict and at least one piece of evidence. **A single
objection from any lens blocks the output.**

| Lens | Asks | Evidence template |
|---|---|---|
| **Architect** | Does this fit the existing structure? Blast radius? Reversibility? | "File X already owns Y; adding Z here couples concerns A and B" |
| **Developer** | Is it idiomatic? Tested? Are there TODOs / dead code? | "grep for FIXME → 0; `bash -n` clean; covers branches 1/2/3" |
| **Security** | New attack surface? Secrets exposed? Injection vectors? | "no eval, no `${user_input}` in shell; `.env` not touched" |
| **QA** | Edge cases? Regression risk? What gets retested? | "edge 1: empty input → handled; edge 2: …; integrity check 10/10 PASS" |
| **Tech Lead** | Trade-offs explicit? Future maintenance cost? Doc consistent? | "preferred option: A (faster). B is cheaper to maintain but +20% latency" |

Each lens **must produce evidence** — not adjectives. "Looks good
to the Architect" is **not** a pass.

## The 6th lens: Red Team

After all five have passed, run an **adversarial pass on your own work**.

**Posture:** You wrote it 5 minutes ago. Confirmation bias is the
default. Find ≥ 3 ways the output is wrong, weak, or self-serving.
Be unkind.

**Output template:**
```
ATTACK #1 — "..."
Severity: P? × I? = ?
Why it's real: ...
Counter-question or amendment: ...
```

If any attack scores ≥ 13, the output is **not yet ready**. Amend or
escalate to the user.

## Mapping to Kimi subagents (1.43+ deployment)

You may run the lenses as Kimi subagents to keep their contexts
isolated:

```
Agent(subagent_type="plan",   description="Architect lens", prompt="…")
Agent(subagent_type="coder",  description="Developer lens", prompt="…")
Agent(subagent_type="explore", description="Security lens", prompt="…")
Agent(subagent_type="explore", description="QA lens",       prompt="…")
Agent(subagent_type="plan",   description="Tech Lead lens", prompt="…")
Agent(subagent_type="explore", description="Red Team lens", prompt="…")
```

Run them in parallel where lenses don't depend on each other's
findings (Architect / Developer / Security can be parallel; QA
benefits from the others' reports; Red Team must be last).

## Conflict resolution

- If two lenses disagree on facts, treat it as evidence missing →
  return to L2 (cite sources) before deciding.
- If two lenses disagree on values (e.g., Security wants tighter
  bounds, Tech Lead wants ergonomics), surface the trade-off to
  the user — do not silently pick.
- If the Red Team contradicts the five default lenses, the Red Team
  wins by default — its existence is the doctrine's anti-bias check.

## Recording

Every challenge-grade review writes one entry to
`memory/AUDIT_LOG.md` (last 5 active; older rotated per
`memory/ROLLUP_POLICY.md`). Template:

```
E<N>: <subject> — <YYYY-MM-DD> — PASS:n/WEAK:n/FAIL:n — Risk:<P×I> — Iter:<n> — Files:<count> mod
```

Optional `## E<N> Detail` paragraph for the audit narrative.
