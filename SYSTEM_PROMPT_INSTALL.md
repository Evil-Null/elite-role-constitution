# SYSTEM PROMPT INSTALL — Kimi CLI 1.43+ Deployment Guide v3.0

> **Role:** Exact instructions for activating the elite protocol in Kimi CLI 1.43.0+.
> **Read:** Before first use; when reinstalling; when upgrading Kimi CLI.
> **Updated:** When the agent file, skill, or hook surface changes.
> **Authority:** Protocol (Rank 2)

---

## Why this guide changed in v3.0 (2026-05-18)

Versions v2.x of this guide instructed users to **paste a long system prompt** into Kimi's settings, because the older Kimi CLI was understood to be a "sequential chat interface with a static system prompt." Live verification against **Kimi CLI 1.43.0** showed that to no longer be accurate — Kimi now ships with agent files, Anthropic-compatible Skills, Flow Skills, hooks (Beta), MCP, session persistence, and slash commands (see `KIMI_PROTOCOL.md` §C).

v3.0 therefore deploys the doctrine as **native Kimi artifacts** instead of a paste-in prompt:

- `agent/elite.yaml` — the agent file (`kimi --agent-file …`)
- `agent/elite.system.md` — the deployable system-prompt kernel
- `skills/elite-role/` — auto-discovered skill with reference files
- `skills/{audit-mode,challenge-grade,save-state}/` — Flow Skills
- `.kimi/hooks/*.sh` + `.kimi/hooks.example.toml` — mechanical enforcement

A **paste-in fallback** is still provided in §6 for environments where the project files are unavailable or the Kimi version is older.

---

## Prerequisites

```bash
kimi --version      # must report 1.43.0 or newer
```

If below 1.43, follow §6 (paste-in fallback) instead.

---

## Step 1 — Get the repo on disk

```bash
git clone https://github.com/Evil-Null/elite-role-constitution.git
cd elite-role-constitution
bash SYSTEM_INTEGRITY_CHECK.sh    # expect "ALL CHECKS PASS" (10/10)
chmod +x .kimi/hooks/*.sh         # if the +x bit did not survive a copy/zip
```

---

## Step 2 — Launch Kimi with the elite agent

The primary way to run the doctrine is to launch Kimi pointing at the agent file:

```bash
kimi --agent-file agent/elite.yaml
```

What this does:
1. Loads `agent/elite.system.md` as the system prompt (rendered with
   `${KIMI_NOW}`, `${KIMI_WORK_DIR}`, `${KIMI_SKILLS}`, `${KIMI_AGENTS_MD}`).
2. Inherits the `default` agent's tool surface (Shell, ReadFile,
   WriteFile, Glob, Grep, Agent, AskUserQuestion, SetTodoList,
   EnterPlanMode/ExitPlanMode, etc.).
3. Auto-discovers `skills/elite-role/SKILL.md` from the project root
   (Kimi's project-level skill search scans `.kimi/skills/`,
   `.claude/skills/`, `.agents/skills/` as well, so the in-repo
   `skills/` is picked up directly).
4. Auto-discovers the three Flow Skills under `skills/audit-mode/`,
   `skills/challenge-grade/`, `skills/save-state/`.

Verification (in the Kimi session):

```
/help                     → confirm Kimi loads
/version                  → confirm 1.43+
plan only                 → AI replies with a PLAN, does not execute
challenge-grade audit foo → AI runs the 6-Lens flow with evidence
[APPROVED]                → AI proceeds with the most recent plan
save state                → AI writes memory/RESUME.md + CONTEXT.md
```

---

## Step 3 — Wire up the hooks (optional but recommended)

Hooks are configured in `~/.kimi/config.toml`. Append the contents of
`.kimi/hooks.example.toml` to that file (or merge by hand). Eight
hooks are wired:

| Event | Script | Purpose |
|---|---|---|
| `SessionStart` | `session-start.sh` | Auto-load `memory/{README,RESUME,CONTEXT,ASSUMPTIONS}.md` into context |
| `SessionEnd` | `session-end.sh` | Touch `memory/RESUME.md` with an autosave timestamp |
| `PreCompact` | `pre-compact.sh` | Emit compact-ritual reminder before history compresses |
| `PostCompact` | `post-compact.sh` | Verify `memory/COMPACT_STATE.md` survived and is consistent |
| `PreToolUse` | `pre-tool-use.sh` | Block `.env` / credentials / private-key edits; V3-security grep |
| `PostToolUse` | `post-tool-use.sh` | Append to `.kimi/audit/post-tool-use-YYYYMMDD.log` |
| `Stop` | `stop.sh` | Surface L6 (anti-self-deception) reminder |
| `Notification` | `notification.sh` | Desktop alert on STOP-level escalations |

After editing config, restart Kimi (or use `/setup` to reload).

Verification:

```bash
echo '{"tool_input":{"file_path":".env"}}' | .kimi/hooks/pre-tool-use.sh
# Expect: stderr "BLOCKED by elite-role PreToolUse hook…", exit 2
```

---

## Step 4 — Verify deployment end-to-end

In a fresh `kimi --agent-file agent/elite.yaml` session, run:

| Probe | Expected |
|---|---|
| `/skill:elite-role` | SKILL.md content surfaces; references list visible |
| `/flow:save-state` | Flow runs through the BEGIN→END diagram |
| Type a task | AI responds with the doctrine's response contract (assumptions, evidence per claim, V-gate status, NEXT STEP) |
| Try to edit a `.env` file via the agent | Blocked by PreToolUse hook |
| End the session | RESUME.md has a fresh hook autosave timestamp |

If any probe fails, re-run `bash SYSTEM_INTEGRITY_CHECK.sh` and check
the hook is executable (`ls -la .kimi/hooks/*.sh`).

---

## Step 5 — Make it the default for this project

If you do not want to type `--agent-file` every time, add a shell
function or alias:

```bash
# ~/.bashrc or ~/.zshrc
elite() {
  kimi --agent-file "$(pwd)/agent/elite.yaml" "$@"
}
```

Then `elite` in the project directory starts the elite session;
`elite --print 'tldr the readme'` works for one-shot non-interactive
use.

---

## Step 6 — Paste-in fallback (older Kimi, or non-Kimi)

If you cannot use `--agent-file` (older Kimi, or you are running a
different LLM CLI), paste the body of `agent/elite.system.md` into
the CLI's system-prompt slot. The `${VAR}` placeholders will not be
substituted — replace them by hand or remove the lines.

This path loses:
- Auto-discovered skills (you must `ReadFile` references manually)
- Hooks (no mechanical V3 / memory autosave)
- Flow Skills (no `/flow:audit-mode` etc.)

What still works: L1-L7, the 5-Eye/6-Lens review procedure, the
PEV `[APPROVED]` gate, the trigger phrases.

---

## Step 7 — First-session bootstrap

```
1. cd into the project directory
2. kimi --agent-file agent/elite.yaml
3. Type: save state
4. Confirm: memory/RESUME.md updated, no integrity check failures
5. Type: plan only — design a small task you want to test
6. Confirm: PLAN appears, no mutations yet, awaiting [APPROVED]
7. Type: [APPROVED]
8. Confirm: AI executes per plan and runs V-gates in the response
```

---

## Troubleshooting

| Problem | Likely cause | Fix |
|---|---|---|
| `kimi: command not found` | Not in PATH | `pip install kimi-cli` or follow upstream docs; check `~/.local/bin` |
| `agent file not found` | Wrong cwd | Run from repo root, or pass an absolute path |
| Hooks do not fire | Not configured in `~/.kimi/config.toml` | Append from `.kimi/hooks.example.toml`; restart Kimi |
| Hook blocks every file | `.gitignore` / `pre-tool-use.sh` pattern too greedy | Edit the case statement in `pre-tool-use.sh` |
| Skill not discovered | Project root not detected | Ensure `.git` is present at the project root |
| `Max Size` violations on save | Memory files exceeded their cap | Run rollup per `memory/ROLLUP_POLICY.md` |
| AI proceeds without `[APPROVED]` | System prompt did not load | Check `kimi --agent-file ... --print --version` parses OK |

---

## Uninstall

```bash
# Project-side
rm -rf agent/ skills/ .kimi/

# User-side (if you appended the hooks block to ~/.kimi/config.toml)
# Open that file and remove the [[hooks]] entries pointing into this repo.
```

`memory/` is left alone — its content is operational state, not
installation.
