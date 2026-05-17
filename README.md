# Elite Role Protocol System v2.0

> A static system prompt + file-backed memory architecture that prevents AI rule erosion, hallucination, and context loss across long sessions and `/compact` boundaries.

## The Problem

- **Context exhaustion:** A 914-line constitution consumes tokens every turn, leaving diminishing room for actual work.
- **Rule erosion:** When the same massive prompt repeats indefinitely, the system treats constraints as background noise — not active law.
- **Hallucination cascades:** Without evidence discipline and adversarial self-check, unverified assumptions compound into fabricated outputs.
- **Continuity collapse:** Session restarts and `/compact` wipe task state. The AI starts from zero, repeats discovery, loses decisions.

## The Solution

Three-layer immune system for AI behavior:

**Layer 1 — Constitutional Laws (L1-L7)**
Always-active behavioral constraints. Non-negotiable. Enforced by self-discipline, not runtime.
- **L1 UNKNOWN=STOP** — "Pretty sure" = STOP AND CHECK.
- **L2 EVIDENCE-FIRST** — Every claim requires citation or verification path. Fabrication = immediate STOP.
- **L3 6-LENS REVIEW** — Architect, Implementer, Risk Officer, QA Validator, Final Arbiter, Red Team. Evidence per lens.
- **L4 PEV LOOP** — Plan → Execute → Verify. Max 3 iterations. Max 2 exploration levels.
- **L5 QUANTIFIED RISK** — Risk = P(1-5) × I(1-5). Score ≥13 → escalate. ≥19 → STOP.
- **L6 ANTI-SELF-DECEPTION** — Before delivery, list 3 ways output could be wrong. Verify each.
- **L7 ABSOLUTE CONTRACT** — NEVER fabricate, skip plan, auto-approve, batch unrelated. Violation = rollback.

**Layer 2 — Bounded Memory v2.0**
Active/archive split. Default read surface ≤300 lines regardless of project history.
- 8 active files with hard thresholds (ASSUMPTIONS.md ≤50 lines, DECISIONS.md ≤40, etc.)
- Automatic rollup to append-only archive when thresholds exceeded
- Cross-session continuity via `RESUME.md` + `COMPACT_STATE.md`

**Layer 3 — Verification Engine**
V1-V8 gates + 6-Lens Review + Self-Assessment. Every deliverable verified before presentation.
- V1 Structural · V2 Semantic · V3 Safety · V4 Quality · V5 Spec · V6 Regression · V7 Edge Cases · V8 Evidence Integrity
- Iteration 3 failure = escalate to user, not infinite rework.

## Architecture

```
[User Message] → [Classifier: AI infers task type]
                         │
        ┌────────────────┼────────────────┐
        ▼                ▼                ▼
   [Standard]      [Challenge-Grade]   [Plan Only]
   L1-L7 +         Full doctrine       Criteria +
   plan-gate       + all 6 lenses      pre-mortem +
                   + V1-V8             risk score
        │                │                │
        └────────────────┼────────────────┘
                         ▼
              [Execution with evidence]
                         │
                         ▼
              [Verify: V1-V8 + 6-Lens]
                         │
              ┌──────────┴──────────┐
              ▼                     ▼
            PASS                  FAIL
              │                     │
              ▼                     ▼
           [Deliver]            [Rework]
           format response      iteration +1
           CHANGE_LOG           >3 → escalate
              │
              ▼
         [Persistence]
    memory/CONTEXT.md · RESUME.md
    ASSUMPTIONS.md · AUDIT_LOG.md
```

Always-On: ~500 tokens (L1-L7 + output contract).  
On-Demand: Full doctrine (~3000 tokens) triggered by user phrase "challenge-grade" only.

## Validation Proof

| Layer | Tests | Result |
|---|---|---|
| Structural | 15 V-IDs (files, thresholds, rituals, read/write order) | 15/15 PASS |
| Behavioral | 15 V-IDs (L1-L7 enforcement, trigger dictionary, response contract, continuity) | 15/15 PASS |
| **Total** | **30 V-IDs + 22 execution scenarios (S1–S22)** | **30/30 PASS** |

Evidence: `VALIDATION_MATRIX.md`, `TEST_SCENARIOS.md`, commit `70c9cb9`.

## Installation

```bash
git clone https://github.com/Evil-Null/elite-role-constitution.git
# Follow SYSTEM_PROMPT_INSTALL.md Step 3 for system prompt setup
```

Requires: Kimi CLI, `memory/` directory with `archive/` subdirectory.

## Quick Reference

| Trigger | Result |
|---|---|
| `challenge-grade` | Full doctrine, all 6 lenses, 800-word audit |
| `plan only` | Acceptance criteria + pre-mortem + risk score, await `[APPROVED]` |
| `audit mode` | Self-review last 3 responses against L1-L7 |
| `/compact` | Pre-compact ritual + state preservation + post-compact recovery |
| `resume` | Reads 4 memory files, restores exact task state |

## What This Guarantees

- **Never loses track** — Task state survives `/compact` and session restart via `RESUME.md` + `COMPACT_STATE.md`.
- **Never fabricates** — L1-L7 enforcement with evidence per claim. "I checked" is not valid proof.
- **Never erodes** — Alignment audits every 10 tasks; canary tasks every 20. Drift triggers hardening.
- **Never bloats** — Active memory ≤300 lines forever. Archive grows; default read surface does not.

## Files

Complete file/module map: 27 files across 4 layers. See `SYSTEM_PLAN.md` D.1 and `KIMI_PROTOCOL.md` E.

## Honest Assessment

This system was externally reviewed and scored **46/60**. Three real weaknesses were identified — not denied, but documented and mitigated:

| Weakness | Mitigation | File |
|---|---|---|
| 30/30 PASS is single-session self-observation | 1000-task stress test planned; limitations documented | `STRESS_TEST_PLAN.md` |
| Bureaucracy overload on trivial tasks | Light-effort bypass + daily ops decision tree | `DAILY_OPS.md` |
| Tool dependency = continuity collapse | Fallback protocol for tool-less operation | `FALLBACK_PROTOCOL.md` |

### v2.4 Update

- **FALLBACK_PROTOCOL.md:** Resilient mode with AI Response Budget (80-line limit, self-compact, [FALLBACK_CHECKPOINT]).
- **01_ELITE_ROLE.md:** L4.1 Auto-Detection for effort classification (LIGHT/STANDARD/CHALLENGE/OVERRIDE).
- **STRESS_TEST_PLAN.md:** Executable Phase 1 (70 tasks / 7 days) + conditional Phases 2–3.
- **Status:** Phase 1 stress test NOT YET EXECUTED.

**Best for:** High-stakes, long-running, multi-session projects where rule erosion and hallucination are costly.  
**Overkill for:** Trivial queries, single-turn tasks, or contexts without file I/O.

## Version

**v2.4** — Gap closure: fallback bounds, auto-detection, executable stress test. 30/30 validated. OPERATIONALLY READY.
