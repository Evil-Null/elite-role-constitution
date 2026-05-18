# canon/ — Single Source of Truth

> **Role:** Holds machine-readable canonical declarations of every fact that
> appears in more than one place in the repo (hook count, protected-file
> patterns, threshold numbers, L1-L7 → §-section mapping).
> **Read:** Before editing any "derived" block in README, install.sh,
> SYSTEM_PROMPT_INSTALL, 01_ELITE_ROLE.md §C.6, or .kimi/hooks/_patterns.sh.
> **Updated:** When a canonical fact actually changes. After every change
> here: `bash generate.sh && git diff --exit-code`.
> **Authority:** Protocol (Rank 2) — supersedes any "derived" location.
> **Max Size:** N/A — index file, intentionally unbounded.

---

## Files

| File | What it declares | Consumers |
|---|---|---|
| `hooks.yaml` | All Kimi lifecycle hooks (event, matcher, script, timeout, doc) | `~/.kimi/config.toml`, README, SYSTEM_PROMPT_INSTALL, install.sh, `.kimi/hooks.example.toml` |
| `patterns.yaml` | Protected-file glob patterns + secret-content regexes | `.kimi/hooks/_patterns.sh` (sourced by `pre-tool-use.sh` and `pre-shell.sh`) |
| `thresholds.yaml` | Memory-file `Max Size` caps, compact ratios, P×I bounds, doctrinal-warning % | `ROLLUP_POLICY.md`, `SYSTEM_INTEGRITY_CHECK.sh`, doctrine docs |
| `laws.yaml` | L1-L7 → §-section anchor mapping | `01_ELITE_ROLE.md` §C.6 table |

## Marker Convention

Derived files contain explicit `<<< canon-generated:<name> >>>` … `<<< /canon-generated:<name> >>>` markers around generated blocks. Hand-edits outside those markers are preserved by the generator; edits INSIDE them are silently overwritten on the next run. Format per file type:

- Shell / TOML: `# <<< canon-generated:hooks >>>`
- Markdown: `<!-- canon-generated:hooks-start -->` / `<!-- canon-generated:hooks-end -->`

## Workflow

1. Edit `canon/<file>.yaml`.
2. `bash generate.sh` (idempotent).
3. `git diff` — review derived files.
4. `git add` both canon source + derived → single commit.
5. CI gate (`.github/workflows/integrity.yml`) runs the same `generate.sh && git diff --exit-code` and fails if a manual edit to a derived block was missed.

## Why this exists

Phase B of `ROADMAP_ELITE_v2.md` makes drift "impossible by construction." Prior to canon, the hook count was duplicated in 4 places (README ×2, SYSTEM_PROMPT_INSTALL, install.sh) and drifted to "Eight" / "Nine" mismatches. The protected-pattern set was duplicated between `pre-tool-use.sh` and `pre-shell.sh` with `pre-shell.sh` quietly missing `gcloud-key*.json`, `secring.gpg`, and `*.credentials.*` — a security-relevant divergence. Canon removes that whole class of bug.

## Scope

This directory does NOT replace the doctrine (`01_ELITE_ROLE.md`, `KIMI_PROTOCOL.md`). It holds only **derivable data**. Narrative, rationale, and discretionary engineering judgment live in the doctrine files.
