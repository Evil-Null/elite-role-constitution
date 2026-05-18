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

`install.sh` does three things:

1. Marks all hook scripts executable.
2. Optionally symlinks the four skills under `~/.kimi/skills/`.
3. Optionally appends the nine `[[hooks]]` blocks to `~/.kimi/config.toml`
   (with a timestamped backup of the existing file).

Then start a session:

```bash
kimi --agent-file agent/elite.yaml
```

---

## How to use

Type one of these in the Kimi session:

| You type | What happens |
|---|---|
| `plan only: <task>` | AI outputs a `[PLAN]` with risk score, **does not change any file** until you reply `[APPROVED]`. |
| `[APPROVED]` | Releases the plan gate. AI proceeds with what it just proposed. |
| `challenge-grade <subject>` | Full 6-lens review of the subject (Architect / Implementer / Risk / QA / Final Arbiter / Red Team) with evidence per lens. |
| `save state` | Writes `memory/RESUME.md` and `memory/CONTEXT.md` so the next session can continue. |
| `light effort` | Skip the planning ceremony for trivial tasks. The L1–L7 rules still apply. |
| `audit mode` | AI self-reviews its recent responses against L1–L7 and reports drift. |

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

## Repo layout

57 files across 4 layers (doctrine, deployment, runtime, validation):

```
agent/                   Kimi entry: kimi --agent-file agent/elite.yaml
.kimi/skills/            Four auto-discovered skills (one + three flows)
.kimi/hooks/             Nine lifecycle scripts wired into ~/.kimi/config.toml
memory/                  Bounded task state (active + archive)
tests/                   Test scenarios and compact/resume harnesses
archive/                 Historical material (SYSTEM_PLAN.md)
.github/workflows/       CI: shellcheck, hook smoke tests, integrity check
01_ELITE_ROLE.md         The doctrine itself
KIMI_PROTOCOL.md         Why Kimi 1.43+ and how it maps to skills/hooks
SYSTEM_PROMPT_INSTALL.md Step-by-step deployment guide
SYSTEM_INTEGRITY_CHECK.sh Repo self-test (10 checks, runs in CI)
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

Ten checks run: file-count match, version alignment, memory thresholds,
archive marker, etc. The expected output ends with `=== ALL CHECKS PASS ===`.
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
| Phase 1 stress test (70 tasks over 7 days). | Day 1 logged. Days 2-7 not run yet. |
| Independent review. | One cycle done (IND1, recorded in `memory/AUDIT_LOG.md`): four subagent reviewers found 24 issues, 9 critical, all fixed across commits `a8b0f3d` → `aaf5ff9`. That cycle is "same-vendor different-session" — lower than a human peer review. |

Best for: long-running engineering work where forgotten rules and
hallucinated certainty cost money.
Overkill for: quick questions and one-shot tasks. Use `light effort` for
those.

---

## License

See the repository for license terms or contact the maintainer.
