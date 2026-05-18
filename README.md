# Elite Role Constitution

> **A doctrine-grade governance framework that turns Kimi CLI 1.43+ into an audit-defensible AI engineering partner.**
> No more rule erosion. No more hallucinated certainty. No more lost context across `/compact`. Plan-gated execution, evidence-cited claims, mechanically-enforced V-gates — by default, on every turn.

[![Integrity Check](https://github.com/Evil-Null/elite-role-constitution/actions/workflows/integrity.yml/badge.svg)](https://github.com/Evil-Null/elite-role-constitution/actions/workflows/integrity.yml)
&nbsp;Status: **operationally ready** · Last live verification: **2026-05-18 on Kimi CLI 1.43.0**

---

## Why this exists

LLM coding assistants are good at the *first* turn and degrade over the *fiftieth*. The doctrine is forgotten, evidence is replaced by "I'm pretty sure", risky changes go un-flagged, and a `/compact` wipes the task state mid-feature. Generic system prompts cannot enforce engineering discipline because **discipline is a runtime concern**, not a text one.

This repo deploys discipline as code:

- **A formal 7-law constitution** (`L1-L7`) that survives compression, sessions, and context exhaustion.
- **An Anthropic-compatible Agent Skill bundle** that Kimi auto-discovers and loads only when the conversation demands it.
- **Nine lifecycle hooks** that fire automatically: blocking writes to `.env` / `id_rsa` / `.tfstate`, enforcing post-compact state, requiring the doctrinal `[APPROVED]` gate before mutations.
- **Three Flow Skills** (`/flow:audit-mode`, `/flow:challenge-grade`, `/flow:save-state`) that drive multi-turn rituals from Mermaid diagrams.
- **A self-auditing repo** — `SYSTEM_INTEGRITY_CHECK.sh` validates the framework's own contracts on every push; GitHub Actions enforces it.

---

## Quick start (60 seconds)

```bash
git clone https://github.com/Evil-Null/elite-role-constitution.git
cd elite-role-constitution
bash install.sh --yes        # idempotent; backs up your ~/.kimi/config.toml
kimi --agent-file agent/elite.yaml
```

That single launch loads the agent file, auto-discovers the four skills under `.kimi/skills/`, and wires the nine lifecycle hooks. The first message you can send is:

```
plan only: design a function that reverses a linked list
```

You should see a `[PLAN]` block with acceptance criteria, pre-mortem, P×I risk score, and `[STOP] Awaiting [APPROVED]` — proof the doctrine is active.

---

## The L1-L7 Constitutional Laws

| Law | Name | Binding rule |
|---|---|---|
| **L1** | UNKNOWN = STOP | If a fact is not verified, stop and ask. "Pretty sure" is a STOP signal, not a green light. |
| **L2** | EVIDENCE-FIRST | Every claim cites a source (file:line, command output, or explicit user statement). "I checked" is not evidence. |
| **L3** | 6-LENS REVIEW | Architect / Implementer / Risk Officer / Quality Validator / Final Arbiter / Red Team. One objection blocks output. |
| **L4** | PEV LOOP | Plan → Execute → Verify. Non-routine work waits for `[APPROVED]`. Max 3 iterations, max 2 exploration rounds. |
| **L5** | QUANTIFIED RISK | Score = P (1-5) × I (1-5). ≥13 escalates; ≥19 is a hard STOP. |
| **L6** | ANTI-SELF-DECEPTION | Before claiming "done," list 3 ways the result could be wrong. Address each. |
| **L7** | ABSOLUTE CONTRACT | Never fabricate, never skip plans, never auto-approve, never batch unrelated changes. |

These map to specific sections of `01_ELITE_ROLE.md`; see §C.6 there for the canonical mapping table.

---

## Architecture

```
┌─────────────────────────────────────────────────────────────────────┐
│                      kimi --agent-file agent/elite.yaml              │
└──────────────────────────────┬──────────────────────────────────────┘
                               │
       ┌───────────────────────┼───────────────────────┐
       ▼                       ▼                       ▼
  agent/elite.system.md   .kimi/skills/           .kimi/hooks/
  (L1-L7 kernel,          (auto-discovered:      (9 lifecycle scripts:
   output contract,        elite-role,            SessionStart loads
   ${KIMI_NOW} etc.)       audit-mode,            memory; PreToolUse
                           challenge-grade,        blocks .env writes;
                           save-state)             PostCompact blocks
                                                   if state missing;
                                                   Stop reminds L6;
                                                   pre-shell.sh guards
                                                   Shell-tool writes)
       │                       │                       │
       └───────────────────────┼───────────────────────┘
                               ▼
              ┌──────────────────────────────────┐
              │   Bounded Memory (memory/*.md)   │
              │   active ≤ 300 lines forever,    │
              │   archive grows separately       │
              └──────────────────────────────────┘
                               │
                               ▼
                  ┌───────────────────────────┐
                  │  SYSTEM_INTEGRITY_CHECK   │
                  │  10/10 PASS gate on every │
                  │  push (GitHub Actions)    │
                  └───────────────────────────┘
```

Always-on system prompt: **~500 tokens** (L1-L7 kernel + output contract).
On-demand skills + references: **loaded only when triggered** (skill auto-discovery + `/skill:` / `/flow:` commands).

---

## Trigger phrases

| You type | What happens |
|---|---|
| `plan only: <task>` | AI outputs `[PLAN]` + P×I risk, **does not mutate state** until you reply `[APPROVED]`. |
| `challenge-grade <subject>` | Full 6-Lens review with ≥800-word audit, evidence per lens, Red Team adversarial pass, anti-self-deception. |
| `audit mode` | Self-review last N responses against L1-L7, report drift, append to `memory/AUDIT_LOG.md`. |
| `save state` | Write `memory/CONTEXT.md` + `memory/RESUME.md` so the next session resumes cleanly. |
| `light effort` | Skip the bureaucracy for trivial tasks; L1-L7 still binding. |
| `[APPROVED]` | Release the PEV gate for the last proposed plan. |
| `/skill:elite-role` | Load the full doctrine reference. |
| `/flow:audit-mode` · `/flow:challenge-grade` · `/flow:save-state` | Run a Mermaid-driven multi-turn ritual. |

---

## What the hooks actually do

Each hook is a self-contained shell script under `.kimi/hooks/`, wired into `~/.kimi/config.toml` by `install.sh`:

| Hook | Matcher | Effect |
|---|---|---|
| `SessionStart` | (any) | Auto-injects `memory/{README,RESUME,CONTEXT,ASSUMPTIONS}.md` into the new session, capped at 120 lines per file with a visible truncation marker. |
| `SessionEnd` | (any) | Updates the `**Last hook autosave:**` timestamp in `memory/RESUME.md` atomically. |
| `PreCompact` | (any) | Surfaces the compact ritual reminder before history is compressed. |
| `PostCompact` | (any) | **Blocks (exit 2)** if `memory/COMPACT_STATE.md` is missing — L1 UNKNOWN=STOP. |
| `PreToolUse` | `WriteFile\|StrReplaceFile\|MultiEdit` | Fails closed on parse error. Case-insensitive protected-file match against `.env`, `id_rsa`, `id_dsa`, `id_ecdsa`, `*.pem`, `*.p12`, `*.tfstate`, `kubeconfig`, etc. Exempts `*.env.example`. V3 secret-pattern scan covers AWS, OpenAI legacy + project, Anthropic, GitHub PAT (classic + fine-grained), Google API, Slack, Stripe, and every common private-key PEM header. Resolves symlinks before matching. |
| `PreToolUse` | `Shell` | Same protections, applied to `> .env`, `tee`, `cp`, `mv`, `sed -i`, `dd of=` targets via `python shlex` parsing. |
| `PostToolUse` | `WriteFile\|StrReplaceFile\|Shell` | UTC-stamped audit trail under `.kimi/audit/`. |
| `Stop` | (any) | Reminds the agent to include the L6 (3-ways-wrong) block before declaring done. |
| `Notification` | (any) | Desktop alert via `notify-send` (Linux) / `osascript` (macOS, argv-passing — **not** string interpolation, so the body cannot inject AppleScript). Stderr fallback if both notifiers exist-but-fail. |

CI lints and smoke-tests every hook on push.

---

## Validation status

| Layer | Tests | Result |
|---|---|---|
| Structural V-IDs (V-16 – V-30) | 15 (files, thresholds, rituals, read/write order) | **15 / 15 PASS** |
| Behavioral V-IDs (V-01 – V-15) | 15 (L1-L7 enforcement, trigger dictionary, output contract, continuity) | **15 / 15 PASS** |
| Behavioral stress (V-31 – V-33) | 3 (fallback drift, trivial-task bypass, 70-task marathon) | **PLANNED — multi-day, outside 30/30 scope** |
| Integrity check (this repo's own contract) | 10 (file count, version alignment, memory thresholds, archive header, …) | **10 / 10 PASS at every commit on `main`** |
| Independent reviewer pass (IND1, 2026-05-18) | 4 parallel subagents, 24 findings, 9 CRITICAL → all triaged + fixed | **R6 score 15 → 6** |
| Live runtime probes (Kimi CLI 1.43.0) | 4 (alive, skill discovery, doctrine recall, PEV gate held) | **4 / 4 PASS** |

Evidence is in `VALIDATION_MATRIX.md`, `tests/`, `memory/AUDIT_LOG.md` (entry `IND1`), and the commit history.

---

## What this guarantees

- **Never loses track.** Task state survives `/compact` and session restart via `RESUME.md` + `COMPACT_STATE.md` + Kimi-native `--continue`.
- **Never fabricates.** L1-L7 enforcement with evidence per claim. "I checked" is not valid proof.
- **Never erodes.** Alignment audits every 10 tasks; canary tasks every 20; integrity check enforces 10/10 on every push.
- **Never bloats.** Active memory ≤300 lines forever. Archive grows; default read surface does not.
- **Never silently bypasses safety.** All security guards fail closed on parse error, malformed payload, or missing prerequisites.

---

## Honest limitations

This system was externally reviewed in two cycles:

| Cycle | Date | Score / Result |
|---|---|---|
| External Principal Architect (single eye) | 2026-05-17 | **46 / 60** with 3 documented weaknesses |
| IND1: 4 parallel independent subagents | 2026-05-18 | **24 findings, 9 CRITICAL, all addressed** in commits `a8b0f3d` → `aaf5ff9` |

Three real weaknesses remain documented (not hidden):

| Weakness | Mitigation | Where to read |
|---|---|---|
| 30/30 PASS is still single-session self-observation by an LLM | Stress test plan + IND1 cycle (Tier 3 mitigation per `independent-validation.md`) | `STRESS_TEST_PLAN.md`, `memory/AUDIT_LOG.md` entry `IND1` |
| Bureaucracy overload on trivial tasks | `light effort` bypass + daily-ops decision tree | `DAILY_OPS.md` |
| Tool dependency = continuity collapse | Tool-less FALLBACK protocol, degraded-mode operation | `FALLBACK_PROTOCOL.md` |

**Best for:** High-stakes, long-running, multi-session engineering work where rule erosion and hallucination are costly.
**Overkill for:** Trivial queries, single-turn tasks, or environments without file I/O.

---

## Repo map (57 files across 4 layers)

```
agent/                     ← Kimi 1.43+ deployment entry
  elite.yaml               (kimi --agent-file ...)
  elite.system.md          (L1-L7 kernel, ~110 lines, uses ${KIMI_*})

.kimi/                     ← Kimi-native runtime artifacts
  skills/elite-role/       (doctrine + 4 references; auto-discovered)
  skills/audit-mode/       (Flow Skill — /flow:audit-mode)
  skills/challenge-grade/  (Flow Skill — /flow:challenge-grade)
  skills/save-state/       (Flow Skill — /flow:save-state)
  hooks/*.sh               (9 lifecycle scripts; shellcheck clean)
  hooks.example.toml       (copy into ~/.kimi/config.toml)

memory/                    ← Bounded operational state
  README.md                (Authority Hierarchy)
  RESUME.md · CONTEXT.md   (cross-session continuity)
  ASSUMPTIONS.md · DECISIONS.md · AUDIT_LOG.md
  COMPACT_STATE.md         (post-/compact recovery)
  ROLLUP_POLICY.md         (governance — when to archive)
  archive/                 (append-only history)
  STRESS_LOG_DAY_*.md      (Phase 1 stress test results)

tests/                     ← Validation harness
  TEST_SCENARIOS.md · COMPACT_TEST.md · RESUME_TEST.md

archive/SYSTEM_PLAN.md     ← Historical (pre-v2.4 design)

.github/workflows/         ← CI: lint + smoke + integrity on push
00_ROLE.md                 ← Source doctrine (Georgian working doc)
01_ELITE_ROLE.md           ← Iron Constitution v4.0 (with §C.6 L1-L7 mapping)
KIMI_PROTOCOL.md           ← Deployment protocol
SYSTEM_PROMPT_INSTALL.md   ← Step-by-step deploy guide v3.0
SYSTEM_INTEGRITY_CHECK.sh  ← The self-audit (10/10 PASS contract)
FORENSIC_AUDIT.md          ← Historical audit + A.0 revision
IMPROVEMENT_PLAN.md        ← Post-audit roadmap (v1.1, Phase A-E shipped)
INDEPENDENT_VALIDATION.md  ← 12-check independent-reviewer list
VALIDATION_MATRIX.md       ← 30 V-IDs + V-31/V-32/V-33 scope notes
STRESS_TEST_PLAN.md        ← Phase 1 protocol
FALLBACK_PROTOCOL.md       ← Tool-less degraded mode
DAILY_OPS.md               ← Light-effort decision tree
SESSION_RITUAL.md          ← Compact / resume / save rituals
OPERATING_RULES.md         ← Trigger dictionary + fuzzy match
FILE_UPDATE_RULES.md       ← Per-file read/write contract
USAGE_KA.md                ← ქართულად მომხმარებლის გზამკვლევი

install.sh                 ← One-command deployer (idempotent)
```

Full file inventory matches `git ls-files | wc -l` (enforced by integrity check #1).

---

## Contributors

- **[Evil-Null / EvilNull](https://github.com/Evil-Null)** — author and maintainer of the doctrine, system architecture, and the v2.4 + Phase A-E deployment.

---

## License

See repository root for license terms (or contact the maintainer for unlicensed use).

---

## Version

**v2.4** · Operational kernel + Kimi 1.43+ native deployment + IND1-validated remediation.
30/30 within-scope V-IDs PASS · V-31/V-32/V-33 deliberately pending behavioral stress test · documented caveats · OPERATIONALLY READY.

For step-by-step deployment, see `SYSTEM_PROMPT_INSTALL.md`.
For Georgian-language usage instructions (**როდის გამოვიყენო, რა დროს, რას ნიშნავს**), see `USAGE_KA.md`.
