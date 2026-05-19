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

## Tier-2 SOP — User-mediated cross-vendor review

This is the reproducible procedure for Tier 2 (different-vendor LLM).
It is **user-mediated** by design: a different vendor cannot be
called from inside this conversation, so the operator copy-pastes
the artifact bundle into the external chat themselves.

### 1. Artifact bundle (what to feed the external reviewer)

Feed exactly these files, in this order, prefixed with a one-line
filename header so the reviewer can cite `file:line`:

| # | File | Why it is in the bundle |
|---|---|---|
| 1 | `01_ELITE_ROLE.md` | Authoritative L1–L7 doctrine the system claims to enforce. |
| 2 | `KIMI_PROTOCOL.md` | Runtime deployment surface; reviewer can cross-check claim ↔ mechanism. |
| 3 | `ROADMAP_ELITE_v2.md` | What the maintainers say the system *will* be and what trade-offs they accepted. |
| 4 | `memory/AUDIT_LOG.md` | Recent history including prior IND entries — prevents re-raising closed findings. |
| 5 | `canon/hooks.yaml` + `canon/patterns.yaml` + `canon/thresholds.yaml` | The single source of truth for derivable facts; reviewer can spot doctrine ↔ canon drift. |

Do **not** feed `agent/elite.system.md` (it is generated from the
above) or `memory/COMPACT_STATE.md` (ephemeral). Keeping the bundle
narrow makes the review reproducible week-over-week.

### 2. Reviewer prompt (copy verbatim into the external chat)

```
You are a Tier-2 independent reviewer of an AI-discipline framework
called Elite Role Constitution. You are NOT in the same context as
the framework's primary agent (Claude). Your job: find at least ONE
specific, actionable flaw the framework's own self-validation
missed.

Ground rules:
1. A "specific flaw" cites a concrete file:line and names what is
   wrong about it — for example, "ROADMAP_ELITE_v2.md:347 promises
   X but no hook implements it" or "01_ELITE_ROLE.md §16 P×I bounds
   contradict canon/thresholds.yaml line 76".
2. Vague verdicts ("looks well-designed", "could be more rigorous")
   do not count. Reject them in yourself before sending.
3. If your candidate flaw is already named in ROADMAP_ELITE_v2.md
   §8 (Plan-level pre-mortem) or §9 (Trade-offs) or in
   memory/AUDIT_LOG.md, it is already on record — keep looking.
4. Output format, strict:

   FLAW <n>: <one-sentence summary>
   EVIDENCE: <file>:<line> — <verbatim quote ≤ 2 lines>
   WHY IT MATTERS: <concrete failure mode, not abstract risk>
   PROPOSED MITIGATION: <one of: fix-here / new-task / accept-with-rationale>
   SEVERITY: P×I where P,I ∈ {1..5}

5. Report 1–3 flaws total. Quality > quantity. End your message
   with the literal line "END-OF-REVIEW".

Bundle below. Each file is preceded by a header of the form
"=== FILE: <path> ===" so you can cite lines accurately.
```

### 3. What counts as a "specific flaw"

| Counts | Does not count |
|---|---|
| `file:line` reference + verbatim quote | "the doctrine could be more rigorous" |
| Names a concrete failure mode | "this might be a risk" |
| Not in `memory/AUDIT_LOG.md` already | Re-raising a closed IND finding |
| Not on `ROADMAP_ELITE_v2.md` §8/§9 pre-mortem list | An accepted trade-off |
| Actionable: fix-here / new-task / accept-with-rationale | "consider revisiting" |

If the external reviewer returns only non-counting findings, the
operator re-prompts once with: *"Each of your findings was either
already in our pre-mortem or non-actionable. Please re-read the
ground rules and produce one finding that survives rules 1, 3, and
4."* If that second attempt still misses, log it as **W-IND2**
(weak IND2) and try a different vendor.

### 4. Response handling

For each `FLAW <n>`:

- **Apply** — open a new commit `fix(ind2): <flaw summary>`. Cite
  the IND2 entry in the commit body.
- **Decline-with-reason** — add an entry to `memory/DECISIONS.md`
  naming the flaw and the rationale (typically: already mitigated
  by §X; cost of fix exceeds P×I; superseded by Phase Y).

Either choice is acceptable. Silently ignoring a flaw is **not**.

### 5. IND<N> log entry — Tier-2 template

Append to `memory/AUDIT_LOG.md` Recent Entries block:

```
IND2: <artifact-set> — Tier-2 <vendor/model> — <YYYY-MM-DD> —
     <count> flaws raised, <count> applied / <count> declined /
     <count> rejected as non-counting; W-IND2 if downgraded.
```

Example:

```
IND2: 01_ELITE_ROLE.md + ROADMAP + canon/*.yaml — Tier-2 GPT-4o —
     2026-05-19 — 2 flaws raised, 1 applied (commit abc1234),
     1 declined (DECISIONS.md D11: accepted trade-off per §9.W2).
```

### 6. When Tier-2 is "passed"

Tier 2 is a *coverage* check, not a *correctness* check: passing
means the external eye produced ≥ 1 counting flaw and the operator
either applied or explicitly declined it. R6 score then drops to
the same level Tier 3 already reached (P3 × I2 = 6) **plus** the
cross-vendor coverage bit flips. Tier 2 does **not** replace
Tier 3 — both should be live (see ROADMAP §9 W2).

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
