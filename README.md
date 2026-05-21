# Elite Role Constitution

> A set of rules, hooks, and skills for **Kimi CLI 1.43+** that makes the AI
> follow strict engineering discipline: plan before acting, cite evidence,
> never write secrets, save state between sessions.

[![Integrity Check](https://github.com/Evil-Null/elite-role-constitution/actions/workflows/integrity.yml/badge.svg)](https://github.com/Evil-Null/elite-role-constitution/actions/workflows/integrity.yml)

---

## What this is

A repository of plain text files (markdown + bash) you point Kimi CLI at.
It turns the default Kimi agent into one that:

- Refuses to modify a file without you typing `[APPROVED]` first.
- Refuses to write to `.env`, `id_rsa`, `*.pem`, `*.tfstate`, `kubeconfig`,
  and similar sensitive files — including via `bash > .env` redirects.
- Refuses to commit obvious secrets (AWS keys, OpenAI/Anthropic keys,
  GitHub PATs, private-key PEM headers, etc.) found in proposed content.
- Saves task state to `memory/RESUME.md` so the next session continues
  from where you left off.
- Runs an internal self-check before claiming "done" (the L6 rule:
  "list 3 ways this could be wrong").

There is no magic. It is configuration files, eight shell scripts, and
one system prompt that Kimi loads via `--agent-file`. You can read every
line.

---

## What this is not

- It does not make the AI smarter. The model is whatever you point Kimi at.
- It does not replace a human reviewer for production code.
- It does not have multi-week stress-test data. Most validation is from
  the AI checking its own behaviour. That is openly stated; see the
  *Honest limitations* section.
- It does not work as well outside Kimi 1.43+. A paste-in fallback is
  documented in `SYSTEM_PROMPT_INSTALL.md` §6 for other CLIs but loses
  the hooks.

---

## Install

```bash
git clone https://github.com/Evil-Null/elite-role-constitution.git
cd elite-role-constitution
bash install.sh --yes
```

`install.sh` runs eight ordered steps, each opt-in via y/n prompt unless
you passed `--yes`:

1. **Prerequisites** — Kimi CLI 1.43+, python3, optional shellcheck.
2. **Repository integrity** — runs `SYSTEM_INTEGRITY_CHECK.sh` (11 checks).
3. **Hook permissions** — `chmod +x` on the hook scripts (skips the
   `_patterns.sh` helper that is sourced, not executed).
4. **Flow skill validation** — imports `kimi_cli.skill.flow.mermaid` and
   verifies every `SKILL.md` flow block parses. Catches the Kimi 1.44
   `rfind('>')` arrow-finder bug at install time instead of at runtime.
5. **Skill symlinks** *(optional)* — links the four skills under
   `~/.kimi/skills/` so they discover from any project.
6. **Hook wire-up** *(optional)* — appends the ten `[[hooks]]` blocks to
   `~/.kimi/config.toml` (with a timestamped backup of the existing file).
7. **Doctrine launcher** *(optional)* — installs `~/.local/bin/kimi-elite`
   (a wrapper for scripts / non-interactive use) and offers to add an
   `alias kimi='command kimi --agent-file <repo>/agent/elite.yaml'` block
   to `~/.bashrc` and `~/.zshrc`. Without this step, `kimi` loads the
   default agent and the hooks fire host-wide without the doctrine
   system prompt loaded — the "half-installed" state.
8. **Live probe** — sends a one-word probe through `kimi --agent-file ...`
   and (if the launcher is installed) through `kimi-elite`. Reports
   `INSTALLED` / `WRAPPED` if the deployment is live.

Useful flags:

```bash
bash install.sh --yes           # accept all defaults (skills+hooks+launcher)
bash install.sh --skills-only   # only skill symlinks, skip hooks+launcher
bash install.sh --hooks-only    # only hooks wire-up, skip skills+launcher
bash install.sh --no-launcher   # skip the kimi-elite wrapper + alias
bash install.sh --no-probe      # skip the live API probe at the end
```

Then start a session. If you accepted step 7 (recommended), plain
`kimi` already loads the doctrine in any directory:

```bash
kimi                                           # alias path (interactive)
kimi-elite                                     # wrapper path (scripts/cron)
kimi --agent-file agent/elite.yaml             # manual path (always works)
```

Confirm the doctrine is live by tailing the log after your first turn:

```bash
tail -1 ~/.kimi/logs/kimi.*.log | grep "Loading agent"
# expected: Loading agent: <repo>/agent/elite.yaml   (not .../kimi_cli/agents/default/)
```

---

## How to use

Type one of these in the Kimi session.

### Text triggers (natural language)

| You type | What happens |
|---|---|
| `plan only: <task>` | AI outputs a `[PLAN]` with acceptance criteria, pre-mortem, and risk score. **No file is changed** until you reply `[APPROVED]`. |
| `[APPROVED]` | Releases the plan gate. AI proceeds with what it just proposed. |
| `[APPROVED] <scope>` | Partial approval — only the named scope (e.g. `[APPROVED] Phase A only`). |
| `REJECT — <reason>` | Rejects the plan. AI iterates with the reason. |
| `challenge-grade <subject>` | Full 6-lens review (Architect / Implementer / Risk / QA / Final Arbiter / Red Team) with evidence per lens, ≥800-word audit. |
| `audit mode` | AI self-reviews its recent responses against L1–L7 and reports drift. |
| `save state` | Writes `memory/RESUME.md` + `memory/CONTEXT.md` so the next session can continue. |
| `resume` | Reads `memory/{README,RESUME,CONTEXT,ASSUMPTIONS}.md` and summarises where you left off. |
| `rollup memory` | Archives stale entries from active memory files into `memory/archive/` per `ROLLUP_POLICY.md`. |
| `light effort` (or `quick check`) | Skip the planning ceremony for trivial tasks. L1–L7 still apply. |
| `stop` (or `escalate`) | Hard pause. AI declares state, saves it, and waits for your decision. |

### Slash commands (Kimi-native)

| You type | What happens |
|---|---|
| `/skill:elite-role` | Loads the full doctrine reference (`SKILL.md` + four reference files) into context. |
| `/flow:audit-mode` | Runs the audit ritual as a Mermaid-driven multi-turn flow. |
| `/flow:challenge-grade` | Runs the 6-lens challenge as a multi-turn flow with anti-self-deception block. |
| `/flow:save-state` | Runs the memory-autosave ritual (also fires automatically via the `SessionEnd` hook). |

A complete Georgian usage guide is in [`USAGE_KA.md`](./USAGE_KA.md).

---

## The seven rules (L1–L7)

These are loaded into Kimi's system prompt on every turn. They map to
sections in `01_ELITE_ROLE.md` §C.6.

| Label | Rule |
|---|---|
| L1 | UNKNOWN = STOP. If a fact is not verified, ask. "Pretty sure" is not a green light. |
| L2 | Cite evidence. "I checked" is not evidence; file:line or command output is. |
| L3 | 6-lens review on non-trivial output. One objection blocks delivery. |
| L4 | Plan → Execute → Verify. Max 3 iterations before escalating to you. |
| L5 | Risk score = Probability (1-5) × Impact (1-5). ≥13 escalates; ≥19 stops. |
| L6 | Before "done", list three ways the output could be wrong. Address each. |
| L7 | Never fabricate, never skip plans, never auto-approve, never batch unrelated changes. |

---

## Repo map (93 files across 4 layers)

Doctrine, deployment, runtime, validation:

```
agent/                   Kimi entry: kimi --agent-file agent/elite.yaml
.kimi/skills/            Four auto-discovered skills (one + three flows)
.kimi/hooks/             Ten lifecycle scripts wired into ~/.kimi/config.toml
memory/                  Bounded task state (active + archive)
tests/                   Test scenarios and compact/resume harnesses
archive/                 Historical material (SYSTEM_PLAN.md)
.github/workflows/       CI: shellcheck, hook smoke tests, integrity check
01_ELITE_ROLE.md         The doctrine itself
KIMI_PROTOCOL.md         Why Kimi 1.43+ and how it maps to skills/hooks
SYSTEM_PROMPT_INSTALL.md Step-by-step deployment guide
SYSTEM_INTEGRITY_CHECK.sh Repo self-test (11 checks, runs in CI)
install.sh               One-command installer
USAGE_KA.md              Georgian user guide
README.md                This file
```

The file count is enforced — `README.md` declares it and the integrity
check fails if `git ls-files | wc -l` does not match.

---

## Self-test

```bash
bash SYSTEM_INTEGRITY_CHECK.sh
```

Eleven checks run: file-count match, version alignment, memory thresholds,
archive marker, context-guard hook presence, etc. The expected output ends
with `=== ALL CHECKS PASS ===`.
GitHub Actions runs the same script plus `shellcheck` and hook smoke tests
on every push to `main`.

---

## Honest limitations

This is what I can prove versus what I cannot:

| Claim | Status |
|---|---|
| The hooks run and block what they say they block. | Verified by smoke tests in `.github/workflows/integrity.yml`. |
| The agent loads in Kimi 1.43.0 and follows L1–L7. | Verified by a four-probe live test on 2026-05-18 (recorded in `memory/AUDIT_LOG.md` E10). |
| 30 V-IDs PASS. | All thirty were checked by an LLM observing itself in one session. That is not the same as multi-session empirical proof. Three more V-IDs (V-31/V-32/V-33) are explicitly pending real stress-test execution. |
| Phase 1 stress test (70 tasks over 7 days). | Day 1 manual + Days 2-7 synthetic via `tests/stress-harness.sh` (60 mechanical tasks through `kimi --print`). Result: **55/60 PASS = 91.7%** (≥ 90% acceptance MET). Caveat: synthetic single-machine run, not calendar-week organic; Drift + Staleness columns are honestly N/A. |
| Independent review. | Two cycles: **IND1** (Tier 3, four subagent reviewers — 24 findings, 9 critical, all fixed) and **IND2** (Tier 2, isolated Kimi K2 / Moonshot — 1 flaw raised on doctrine §6, applied). Logged in `memory/AUDIT_LOG.md`. |

Best for: long-running engineering work where forgotten rules and
hallucinated certainty cost money.
Overkill for: quick questions and one-shot tasks. Use `light effort` for
those.

---

## License

See the repository for license terms or contact the maintainer.
