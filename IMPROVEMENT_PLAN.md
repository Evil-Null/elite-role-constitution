# IMPROVEMENT_PLAN — Post-Audit Roadmap v1.1

> **Role:** Authoritative remediation plan derived from 2026-05-18 5-Eye Review (47/60) and self-Red-Team challenge.
> **Read:** Before executing any P0/P1/P2/P3 fix described herein.
> **Updated:** 2026-05-18 (v1.1, pending `[APPROVED]`)
> **Status:** PROPOSED — awaiting user approval before any code change.
> **Max Size:** 260 lines.

---

## 0. Changes from v1.0 → v1.1

Five amendments forced by self-Red-Team challenge (Attacks #1-#6 in challenge log):

1. **NEW Phase 0** — independent reviewer requirement (breaks single-session recursion, Attack #4).
2. **Phase A split** into 3 commits (A.1/A.2/A.3), decoupling enforcement from semantic negotiation (Attack #5).
3. **Phase A.0 simplified** — format inventory done, all 11 declarations are uniform (Attack #2, partially false).
4. **Phase C.2 STRUCK** — memory/ path coupling confirmed; cannot move without breaking doctrine (Attack #3).
5. **NEW §11 Registration** — plan must register itself in README inventory + `FILE_UPDATE_RULES.md` (Attack #6).

---

## 1. Goal

Close the gaps identified by the 2026-05-18 audit while preserving the v2.4 contract surface (L1-L7, V1-V8, 6-Lens, Bounded Memory). The plan does **not** redesign the system; it ships disciplined, reversible patches with regression protection.

## 2. Evidence Base

> **Evidence collected at:** v1.0 draft on 2026-05-18 (pre-Phase-A); refreshed
> 2026-05-18 (post-Phase-E, post-IND1) — both timestamps preserved so
> the historical motivation and the current state are visible side-by-side.
> The "verified by" column below is now reproducible TODAY.

| Claim (v1.0 motivation) | Verification command | Result at v1.0 draft | Result NOW (post-Phase-A/E) |
|---|---|---|---|
| `FALLBACK_PROTOCOL.md` violates its own `Max Size: 80 lines` | `wc -l FALLBACK_PROTOCOL.md` | **92 lines** — violated | **77 lines** — fixed by Phase A.3 (686d5e9) |
| `SYSTEM_INTEGRITY_CHECK.sh` ignores root-level Max Size | Script line 44 loops only `memory/*.md` | Vacuum confirmed | **Closed** by Phase A.1 (e942ec4) — check #10 now scans root |
| Repo file count matches README inventory | `git ls-files \| wc -l` vs README "N files across" | 33 = 33 | **54 = 54** (README + git both 54 after Phase E additions) |
| Phase 1 stress test only Day 1 logged | `ls memory/STRESS_LOG_DAY_*.md` | Only Day 1 | **Still only Day 1** — Days 2-7 still pending (real elapsed time required) |
| V-31/V-32/V-33 NOT TESTED | `VALIDATION_MATRIX.md` lines 178-182 | Confirmed NOT TESTED | **Re-labelled** by Phase B.2 (6904634) → "PLANNED — outside 30/30 scope" |
| `Max Size:` format is uniform | `grep -lE '^> \*\*Max Size:\*\* [0-9]+ lines' *.md memory/*.md` | 11/11 files conform | **11/11** — still conforms (no new files declare `Max Size:`) |
| `memory/` paths are hard-pinned by doctrine | `memory/README.md` lines 14-26 + Default Read Order | Rank chain + Mandatory load list | **Unchanged** — Phase C.2 permanently STRUCK based on this |

---

## 3. Phases

### Phase 0 — Independent Second Pass (BLOCKING)

**0.1.** Before Phase A executes, the user must obtain at least one independent reviewer pass on **this plan**. Acceptable forms:
  - A second Claude session (different conversation, no shared memory) reads v1.1 and either ACK or contradicts.
  - A human peer review (Evil-Null reads top-to-bottom, marks disagreement inline).
  - A different LLM (Kimi, Gemini, GPT) given the plan as input and asked to find ≥1 flaw not already in §13.

**Why blocking:** the original 47/60 audit and this plan are both single-reviewer artifacts; the doctrine's stated weakness #1 is single-session validation. Skipping Phase 0 perpetuates the exact flaw the doctrine names.

**Acceptance:** at least one external reviewer recorded their pass in `memory/AUDIT_LOG.md` with date + verdict + ≥1 specific objection or "no objection."

**Rollback:** N/A — Phase 0 is read-only.

---

### Phase A — Enforcement Closure (target: ≤1 hour, post-Phase-0)

#### A.0. Format inventory (done this session, archived as evidence in §2)

Regex contract: every file declaring `^> \*\*Max Size:\*\* (\d+) lines` is in scope; anything else is out. The grep result in §2 shows the regex matches exactly 11 files (5 root + 6 memory). **No new format normalization required.** If a future file uses a different form, that PR must update both the file convention and the script in one commit.

#### A.1. Extend `SYSTEM_INTEGRITY_CHECK.sh` with root-level threshold check — **standalone commit**

- New check #10: iterate every `*.md` at repo root (excluding `memory/`); extract `Max Size: N lines` via the §A.0 regex; compare `wc -l` to N; fail if `lines > N`.
- Reuses existing `THRESHOLD_FAIL` pattern (lines 43-59), but operates on a different file set.
- **Acceptance:** running the script after A.1 flags `FALLBACK_PROTOCOL.md` (92 > 80), proving the new check fires. **The script is now intentionally RED until A.3 lands** — this is the visible signal that A.3 is required.
- **Commit message:** `fix: SYSTEM_INTEGRITY_CHECK.sh enforces Max Size on root-level *.md (P1.1 from 2026-05-18 audit)`

#### A.2. Script hardening — **standalone commit**

- Add `set -euo pipefail` at the top.
- Run `shellcheck` (install if missing on host); fix warnings without changing logic.
- Add `2>/dev/null` to `grep -oP` calls with ambiguous exit semantics.
- **Acceptance:** `shellcheck SYSTEM_INTEGRITY_CHECK.sh` exits 0; all behavioral semantics preserved (check that A.1 still fires correctly).
- **Commit message:** `harden: shellcheck-clean SYSTEM_INTEGRITY_CHECK.sh with strict pipefail`

#### A.3. Trim `FALLBACK_PROTOCOL.md` to ≤80 lines — **standalone commit, separate negotiation**

- Two candidates discussed with user before commit: (a) collapse "L1-L7 Persistence" block (lines 63-71) into a 3-line reference to `01_ELITE_ROLE.md`; (b) merge "Honest Caveat" bullets.
- **Acceptance:** `wc -l FALLBACK_PROTOCOL.md ≤ 80`; semantic content preserved (diff-review with user); integrity script returns to GREEN (10/10).
- **Commit message:** `fix: bring FALLBACK_PROTOCOL.md within its declared 80-line cap`

**Why split into 3 commits:** A.1 and A.2 are mechanical and unambiguous. A.3 involves taste/semantics. Coupling them blocks the entire fix on a content debate.

**Phase A rollback:** any one commit can be reverted in isolation. If A.3 is reverted alone, the integrity check stays RED — a useful state (visible TODO).

---

### Phase B — Honesty Pass (target: same day or next, after Phase A)

#### B.1. Stress-test claim — explicit user fork

- **(B.1.a)** Text-only honesty patch. `README.md` and `STRESS_TEST_PLAN.md` change headline from "30/30 V-IDs PASS" → "30/30 single-session + Phase 1 in progress (1/7 days)". Commit body must say: *"This is a claim adjustment, not a validation result. To upgrade, complete Phase 1 (see STRESS_TEST_PLAN.md)."* ~15 min.
- **(B.1.b)** Run real Days 2-7. ~10 min/day × 6 days. Generates `memory/STRESS_LOG_DAY_2.md` through `_DAY_7.md`. Cannot be done in a single sitting.

User chooses one at start of Phase B. The plan does NOT pre-pick.

#### B.2. Reconcile V-31/V-32/V-33

- Either execute them, or update `VALIDATION_MATRIX.md` lines 178-182 from "NOT TESTED" to "PLANNED — outside 30/30 scope" and change every "30/30 PASS" headline to "30/30 + 3 pending."
- **Acceptance:** No two files contradict each other on the V-count.

**Phase B success criteria:** `INDEPENDENT_VALIDATION.md`'s 12-check honesty list passes without "skipped" gates.

**Phase B rollback:** trivial — text-only changes.

---

### Phase C — Automation (target: 1 day, separate sitting)

#### C.1. GitHub Actions workflow `.github/workflows/integrity.yml`

- Trigger: `push` to `main`, `pull_request`.
- Single job: install `shellcheck`, run `bash SYSTEM_INTEGRITY_CHECK.sh`; fail PR on non-zero exit.
- ~25 lines of YAML.
- **Acceptance:** A test PR with a deliberately broken file fails CI; clean PR passes.

#### C.2. ~~Memory state decoupling~~ — **STRUCK from plan**

**Reason for removal:** `memory/README.md` lines 14-26 explicitly assign Authority Hierarchy ranks 4-8 to `CONTEXT.md / RESUME.md / ASSUMPTIONS.md / DECISIONS.md / COMPACT_STATE.md` and labels them "Mandatory" load at session start. Default Read Order (line 39) says "Do NOT proceed until all 4 are read." Moving these files to `examples/memory/` would break the doctrine's own startup protocol. R5's impact is therefore I5 (system-breaking), and P3×I5=15 → L5 automatic STOP.

**Replacement:** add a one-paragraph **note** in `README.md` acknowledging the trade-off (committed-with-state shows the user's task state to clones) and recommending clone-time `git rm --cached memory/{CONTEXT,RESUME,COMPACT_STATE}.md` for users who want a fresh start. **No file move.**

**Phase C success criteria:** drift in any tracked doc is caught by CI before merge; cloning-user awareness of memory state is documented.

**Phase C rollback:** delete the workflow file; revert the README note.

---

### Phase D — Cleanup (when bored, low priority)

- **D.1.** Move `SYSTEM_PLAN.md` (ARCHIVED) into `archive/` folder. Update references in README and integrity script's "SYSTEM_PLAN.md ARCHIVED" grep check (line 78).
- **D.2.** Consolidate `TEST_SCENARIOS.md` + `COMPACT_TEST.md` + `RESUME_TEST.md` under `tests/`. Update file inventory.
- **D.3.** Add a `Compatibility:` line to both `00_ROLE.md` files documenting which version of `01_ELITE_ROLE.md` each was generated against.

**Phase D success criteria:** repo's top-level listing ≤25 files; tests centralized.

---

## 4. Sequencing Rules (binding)

1. **Phase 0 must complete before Phase A.** Independent reviewer recorded in `AUDIT_LOG.md`.
2. **Phase A.1 → A.2 → A.3** in order; A.1 fires the new check, A.2 hardens, A.3 fixes the offending file. Each is a separate commit.
3. **Phase B.1.a vs B.1.b** is a user decision at start of Phase B.
4. **Phase C.2 is permanently struck; do not reintroduce without a new audit cycle.**
5. **No phase may skip its rollback plan in the commit body.**

---

## 5. Verification Plan (V1-V8 mapping)

| Gate | Phase A | Phase B | Phase C | Phase D |
|---|---|---|---|---|
| V1 Compilation | `bash -n SYSTEM_INTEGRITY_CHECK.sh` | N/A | `actionlint` (or yamllint) | N/A |
| V2 Type Safety | N/A | N/A | N/A | N/A |
| V3 Security | grep for new shell-injection vectors | N/A | secrets scan in workflow | N/A |
| V4 Code Quality | shellcheck clean | wc-line claims match reality | YAML lint clean | filenames unique |
| V5 Spec Compliance | integrity script PASS 10/10 | INDEPENDENT_VALIDATION.md ALL PASS | CI green on baseline | references updated |
| V6 Regression | re-run prev 9 checks | re-run all 10 checks | run script in CI to confirm parity | full integrity check |
| V7 Edge Cases | empty file, missing `Max Size:`, multi-`Max Size:` collision (none exist now) | conflicting counts caught | broken-PR test passes | broken links caught |
| V8 Independent | Phase 0 reviewer recorded in AUDIT_LOG | second reviewer optional | CI is the independent voice | re-validate |

---

## 6. Risk Ledger (P×I per ROLE L5) — corrected after Red Team

| # | Risk | P | I | Score | Mitigation |
|---|---|---|---|---|---|
| R1 | Trimming `FALLBACK_PROTOCOL.md` loses semantic content | 2 | 3 | 6 | Review-before-trim; diff with semantic compare; preserve L1-L7 link |
| R2 | New check yields false positives | 2 | 2 | 4 | Format is uniform (§A.0 verified); regex pinned to exact phrase |
| R3 | CI added before fix → branch reds out | 2 | 2 | 4 | Phase ordering: A merges before C |
| R4 | User disagrees with B.1.a downgrade, calls it cowardice | 2 | 2 | 4 | Both B.1.a and B.1.b paths offered |
| R5 | ~~Moving memory/ breaks doctrine~~ | — | — | — | **Struck — see §3 C.2** |
| R6 | Single-reviewer plan perpetuates known weakness | 5 | 3 | **15 → L5** | Phase 0 mandatory; cannot proceed without external eye |
| R7 | A.0 regex misses a non-uniform file added later | 2 | 2 | 4 | Convention enforced via PR review; new file must conform |

R6 score 15 is at L5 escalate threshold but **not** STOP (≥19). Mitigation is operational: Phase 0 IS the escalation outcome.

---

## 7. Honest Caveat

- v1.1 is **still** a single-author plan; Phase 0 exists exactly to defeat that. Until Phase 0 records a result in AUDIT_LOG, this plan is provisional.
- Phase A is the only phase with zero negotiation ambiguity.
- The 47/60 audit verdict is also single-reviewer. Phase 0 partially mitigates this for the plan, not the audit.

---

## 8. Self-Deception Check (3 ways v1.1 could still be wrong)

1. **Phase 0 may be performative.** If the "independent reviewer" is just another Claude with the same training, the validation is weaker than I claim. Mitigation: prefer the human peer or a different-vendor LLM path.
2. **Phase A.0 evidence might be stale.** I verified the 11 files this session; a new file added before A.1 lands could break the assumption. Mitigation: A.1 must re-grep on commit and fail if count changes.
3. **C.2 strike might be over-cautious.** Maybe path coupling is fixable with a small `memory/README.md` rewrite. Counter: that rewrite would touch the highest-rank doc and require its own audit cycle; out of scope here.

---

## 9. Approval Gate

This document is a `[PLAN]` per L4 PEV Loop. **No file in the repo will be modified until the user replies with `[APPROVED]`** plus a phase scope (e.g., `[APPROVED] Phase 0 + Phase A only`).

After approval, execution proceeds in §4 order. Each completed phase produces a Conventional Commit with rollback note in the body and a verification report before the next phase begins.

---

## 10. Registration (new in v1.1)

When this plan is approved and the implementation begins, the following must also occur:

- **README.md inventory** updated: regex-driven increment of the `N files across` value to reflect the post-commit `git ls-files | wc -l`. (Historical trajectory: 33 → 34 at v1.0 registration → 35 after CI workflow → 37 after agent/ → 42 after skill bundle → 51 after hooks → 54 after Flow Skills.)
- **`FILE_UPDATE_RULES.md`** gets a new entry for `IMPROVEMENT_PLAN.md` lifecycle: editable only while `Status: PROPOSED`; archives to `archive/improvement_plans/` once all phases ship or are abandoned.
- **`memory/AUDIT_LOG.md`** receives one entry recording v1.0→v1.1 transition and Phase 0 outcome.

---

## 11. Change Log

- **v1.0** — 2026-05-18 — initial draft from session `ace0d0ae` audit, recovered after session crash.
- **v1.1** — 2026-05-18 — five amendments after self-Red-Team challenge: Phase 0 added (R6), Phase A split (Attack #5), Phase A.0 simplified (Attack #2 partially false), Phase C.2 struck (R5 confirmed I5), Registration §10 added (Attack #6).
