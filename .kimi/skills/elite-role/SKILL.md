---
name: elite-role
description: |
  Elite Challenge-Grade Operating Constitution for Kimi CLI 1.43+ —
  L1-L7 Constitutional Laws, 5-Eye / 6-Lens Review, PEV Loop, V1-V8
  Verification, Quantified Risk (P×I). Auto-loads when a task involves
  audit, review, plan-only mode, challenge-grade work, doctrine
  enforcement, or memory-state continuity. Reference files explain the
  individual procedures; the kernel of the doctrine lives in the agent
  system prompt (agent/elite.system.md).
tags: [role, doctrine, audit, governance, verification]
---

# Elite Role — Quick Reference

This skill provides the operational references for the **Elite
Challenge-Grade Operating Constitution** described in `01_ELITE_ROLE.md`
and deployed via `agent/elite.yaml` + `agent/elite.system.md`. When in
doubt during a turn, **load the specific reference file that matches the
problem**, do not paraphrase from memory.

## When to load this skill

- The user invokes `/skill:elite-role` or `/flow:audit-mode` /
  `/flow:challenge-grade` / `/flow:save-state`
- The user types one of the trigger phrases: `challenge-grade`,
  `plan only`, `audit mode`, `save state`, `light effort`
- The current task involves: code review of non-trivial changes,
  architectural decisions, security-relevant changes, memory-file
  rotation, P×I risk scoring above 6
- A 5-Eye lens objection has been raised and you need the procedure to
  resolve it

## References (load on demand)

- **`references/5-eye-review.md`** — Architect, Developer, Security, QA,
  Tech Lead lenses + the 6th adversarial Red Team lens. When to use
  each, what evidence each requires, the conflict-resolution rule.
- **`references/pev-loop.md`** — Plan → Execute → Verify cycle, the
  `[APPROVED]` gate, iteration limits, when to call `EnterPlanMode`.
- **`references/quantified-risk.md`** — P × I scoring procedure,
  escalation thresholds (≥13 escalate, ≥19 STOP), recording template.
- **`references/independent-validation.md`** — R6 mitigation: how to
  obtain and record a second-eye pass for high-stakes outputs. Why
  `INDEPENDENT_VALIDATION.md`'s 12-check list exists.

## How references are loaded

Each reference is plain Markdown. Read it with `ReadFile`. Once loaded
into context, follow it verbatim for the current turn; do not improvise
on a documented procedure.

```
ReadFile skills/elite-role/references/5-eye-review.md
```

## Authority

- This skill is the **operational toolbox**.
- The **doctrinal source** is `01_ELITE_ROLE.md` in the repo root
  (rank 3 in `memory/README.md` Authority Hierarchy).
- The **deployment kernel** is `agent/elite.system.md` (loaded by
  `agent/elite.yaml`).
- When the skill and the doctrinal source disagree, the doctrinal
  source wins; report the drift so the skill can be fixed.

## Companion artifacts

- `agent/elite.yaml` — Kimi agent file (`kimi --agent-file ...`)
- `.kimi/hooks/` — mechanical enforcement (V1-V8, memory autosave)
- `memory/` — bounded operational state (CONTEXT, RESUME, ASSUMPTIONS,
  DECISIONS, AUDIT_LOG, COMPACT_STATE)
- `IMPROVEMENT_PLAN.md` — current remediation roadmap (Phase E
  delivered the runtime adaptation that makes this skill possible)
