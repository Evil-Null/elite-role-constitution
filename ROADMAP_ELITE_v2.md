# ROADMAP_ELITE_v2 — Strategic Architectural Roadmap

> **Role:** Doctrine-compliant strategic plan to close *architectural* gaps identified by the 2026-05-18 elite-grade deep audit. Builds on `IMPROVEMENT_PLAN.md` v1.1 (shipped) and supersedes its scope.
> **Status:** Phase **A** ✅ shipped 2026-05-18 (commits 472f54d…382bdd8 + bdf40f8). Phase **B** ✅ shipped 2026-05-18 (commits eeec1fb…93ef2bb + 1a92fc5 hotfix). Phases C–G remain `PROPOSED` — no further file in this repo is modified by phases C–G until the user replies with `[APPROVED] <phase scope>`.
> **Read:** Before opening any commit attributed to this roadmap. Re-read at the start of each phase.
> **Updated:** Only while `Status: PROPOSED`. Once any phase commits land, this file is the contract — amendments require an explicit change-log entry (§12) and `[APPROVED]`.
> **Authority:** Protocol (Rank 2) — governed by `01_ELITE_ROLE.md` (Rank 3 Doctrine) and `memory/README.md` (Authority Map).
> **Max Size:** 700 lines. Exceed → rollup per `memory/ROLLUP_POLICY.md`; do not split into v3 without `[APPROVED]`.
> **Conventions:** Georgian narrative · English identifiers / commit messages / commands / file paths · Conventional Commits.

---

## 0. ეს გეგემა რას აკეთებს და რას არ აკეთებს

### 0.1 Supersedence ვექტორი

`IMPROVEMENT_PLAN.md` v1.1 დახურა *სუფერფიციული* ხარვეზები 2026-05-18 5-eye audit-დან:
- `FALLBACK_PROTOCOL.md` line-cap violation → fixed
- `SYSTEM_INTEGRITY_CHECK.sh` root-scan vacuum → fixed
- README ↔ git file count drift → reconciled
- V-31/V-32/V-33 labels normalized

ეს roadmap (v2.0) **არ ცვლის** v1.1-ის ძირითად ციტატებს, არამედ ემატება მას ერთი layer ზემოთ: **სტრუქტურულ ხარვეზებს**, რომელიც surface audit-მა ვერ დაინახა, რადგან მისი scope-ი structural critique არ იყო. სამ კატეგორიად:

| Layer | რა გადაჭრის | რატომ surface audit-მა ვერ ნახა |
|---|---|---|
| **Drift-prevention** | "Single Source of Truth" violations (e.g., "8 vs 9 hooks") | Surface audit ფიქსირდება ხედული ფაქტი-ცვლილებაზე, არა მის წყაროზე |
| **Real enforcement** | L1–L6 mechanical guard rail-ის ცარიელი ფენა | "best-effort reinforcement" სხეულში, არ ჩანდა ცარიელი spot-ად |
| **External validation** | Self-validation tautology + single-vendor monoculture | Self-audit-ი თვითონ აღიარებს, მაგრამ არ ცვლის თამაშის წესს |

### 0.2 რას `არ` შეიცავს ეს გეგმა (Non-Scope)

- **L1–L7 doctrinal redesign.** Concept-ი მართებულია; enforcement-ი არასრულია. Doctrine ხელშეუხებლად რჩება.
- **Memory layering rewrite.** Bounded-active-archive pattern-ი მუშაობს. Threshold ციფრები arbitrary მაგრამ "good enough"-ია.
- **Hook security level downgrade.** `fail-closed-on-parse`, `shlex`, atomic `mv`, symlink resolve — production-grade. ეს ფენა *მხოლოდ* იზრდება, არ მცირდება.
- **Multi-tenant / team rewrite.** Single-operator design-ის გადარჩება შემდეგი ფაზის გადაწყვეტილებაა.
- **Kimi CLI fork / upstream patches.** Hook fail-open at 30s და payload-ის ცარიელი ნაწილები (Stop hook does not see response text) — ეს Kimi 1.43+ Beta-ის ლიმიტებია. Workaround-ი — heuristic.

---

## 1. მომხმარებლის მოთხოვნები — ჩათვლის ცხრილი

| ID | Requirement | Status | Evidence |
|---|---|---|---|
| **U1** | Compact threshold runtime უნდა იყოს 0.70 (max 0.75), 0.85 ძალიან მჭიდრო | ✅ DONE — current session | `~/.kimi/config.toml:35` → `compaction_trigger_ratio = 0.70` |
| **U2** | Doctrinal warning უნდა ჩამოვიდეს buffer-ის შესანახად | ✅ DONE — current session | `KIMI_PROTOCOL.md` H.2 → 40–50%; `00_ROLE.md:371`, `01_ELITE_ROLE.md:571` updated; `DECISIONS.md` D8 logged |
| **U3** | გეგმა fixed უნდა იყოს, ნაბიჯ-ნაბიჯ, არცერთი task გამორჩენის გარეშე | 🟠 IN-PROGRESS — ეს ფაილი | რეგისტრაცია README + FILE_UPDATE_RULES (Phase A6) |
| **U4** | Plan უნდა აშენდეს ისე, როგორც 15-წლის elite ინჟინერი ააშენებდა | 🟠 IN-PROGRESS — ეს ფაილი | Per-task pre-mortem + acceptance + rollback + P×I + evidence (ქვემოთ) |
| **U5** | რა გასაუმჯობესებელია — full enumeration | ✅ ENUMERATED | Phase A–G ქვემოთ; non-scope §0.2 |

U1+U2 უკვე shipped-ია. U3+U4+U5 ამ roadmap-ის deliverable-ია.

---

## 2. მიზანი (Goal)

ერთი წინადადებით: **"`elite-role-constitution`-ის aspirational doctrine-ი mechanically self-validating system-ად ვაქციოთ ერთი quarter-ის ფარგლებში — drift impossible-by-construction-ით, L6 reinforcement → L6 verification-ით, და single-vendor → cross-vendor მტკიცებულებით."**

გაზომვადი outcome-ი 90 დღის შემდეგ:

1. ნებისმიერი doctrine-ცვლილება, რომელიც სამ ფაილში დუბლირდება (e.g., hook count, threshold), **იჭრება CI-ში** ერთი ერთეულის ცვლის გარეშე.
2. AI-ის Stop hook **ფაქტობრივად ჩერდება** (exit-2) თუ L6 anti-self-deception block-ი response-ში არ არის (Kimi payload-ის შესაძლებლობიდან გამომდინარე — fallback heuristic).
3. ≥1 Tier-2 (different-vendor) review-ი **დასრულებული** doctrine-ის წინააღმდეგ, ≥1 specific flaw-ით.
4. Compliance telemetry-ის **first sample** კოლექციდდება — ფაქტობრივი მტკიცებულება "L2 citation rate X%".

---

## 3. შეზღუდვები (Constraints)

| შეზღუდვა | აღწერა | რა გავლენას ახდენს გეგმაზე |
|---|---|---|
| Single operator | მხოლოდ ერთი მომხმარებელი | Tier-1 (human peer) review impossible-ია; Tier-2 minimum |
| Budget cap | API calls გარე LLM-ებზე ბევრი არ უნდა იყოს | Cross-vendor automation deferred (Phase D3 OPTIONAL) |
| Time budget | ~90 დღე Phase A–F, Phase G optional | Phase E (stress) ფიზიკურად საჭიროებს 6 დღეს |
| Kimi 1.43+ Beta | Hook payload incomplete, 30s fail-open | Real L6 enforcement (Phase C) — heuristic, არა absolute |
| No vendor diversity locally | მხოლოდ Claude აქ ხელმისაწვდომი | Tier-2 ხელით (user-mediated) — შეცდომა CI automation-ში |
| No production-traffic ranking | არცერთი user-ი ცოცხალ traffic-ად ვერ მონაწილეობს | A/B canary impractical (Phase G deferred) |

---

## 4. Evidence Base — რის საფუძველზე ვაშენებთ

ყოველი finding-ი ცოცხალი მტკიცებულებიდან — არ ვცემთ თავ-ციტატებს, ვცემთ command-output-ს.

| Finding-ID | Claim | Verification command | Result (2026-05-18 evening) |
|---|---|---|---|
| **F1** | Hooks 9 (active config), 8 documented in 3 places | `grep -c '^\[\[hooks\]\]' ~/.kimi/config.toml` + `grep -nE "Eight\|All 8\|8 hook" README.md SYSTEM_PROMPT_INSTALL.md install.sh` | 9 active; "Eight" / "All 8" in 3 files; README internally contradictory (line 19 "Eight", line 34 "nine") |
| **F2** | CONTEXT.md stale | `grep -nE "Started\|Updated" memory/CONTEXT.md` | Both 2026-05-17T11:45+04:00 — Phase E (2026-05-18) and IND1 (2026-05-18) not reflected |
| **F3** | Audit log host-scoped, doctrine project-scoped | `head -5 .kimi/audit/post-tool-use-20260518.log` | First entry: `/var/www/dedoplistsqaro-marketplace/e2e/16-upload-flow.spec.ts` (foreign work_dir) |
| **F4** | Marketplace work_dir doctrine-empty | `ls /var/www/dedoplistsqaro-marketplace/.kimi/` | No such dir; runtime compact happened (context_1.jsonl 820 KB) without doctrinal snapshot |
| **F5** | Protected-pattern duplication | `diff <(sed -n '93,100p' .kimi/hooks/pre-tool-use.sh) <(sed -n '50,56p' .kimi/hooks/pre-shell.sh)` | Both list same pattern set, no shared source |
| **F6** | STRESS_LOG only Day 1 | `ls memory/STRESS_LOG_DAY_*.md` | One file: DAY_1 |
| **F7** | Audit `Last rollup` stale | `grep "Last rollup" memory/AUDIT_LOG.md` | `2026-05-17T06:45+04:00`; ≥6 entries added since |
| **F8** | Doctrine:enforcement = 4.5:1 | `wc -l *.md memory/*.md` vs `wc -l .kimi/hooks/*.sh install.sh SYSTEM_INTEGRITY_CHECK.sh` | 4965 vs 1109 |
| **F9** | Smoke tests cover 2 of N protected patterns | `.github/workflows/integrity.yml` lines 36–55 | Only `.env` write + `> .env` redirect; kubeconfig / id_rsa / RSA PEM / xox tokens NEVER tested |
| **F10** | Stop hook cannot read response | `.kimi/hooks/stop.sh:1-30` + Kimi 1.43+ payload schema | Hook receives stop reason, no message body — L6 enforcement is reminder-only |
| **F11** | Single-vendor R6 mitigation | `memory/AUDIT_LOG.md` IND1 entry | 4 Claude subagents, no Tier-2 | 

---

## 5. ფაზური გეგმა

ფაზები ერთიმეორის შემდეგ. შემდეგი ფაზა არ იწყება სანამ წინა-ფაზაში ყველა task-ის Acceptance Criteria აქტიურდება და verification-report-ი ჩაიდება commit body-ში.

| Phase | Theme | Tasks | Estimated effort | Blocks next phase? |
|---|---|---|---|---|
| **A** | Quick Hygiene | 7 (A1–A7) | 1–2 sessions | YES — drift cleanup must precede generator |
| **B** | Drift Elimination | 9 (B1–B9) | 1 week | YES — generator must exist before C edits doctrine |
| **C** | Real Enforcement | 5 (C1–C5) | 2 weeks | YES — telemetry needs hook signals |
| **D** | External Validation | 3 (D1–D3) | ongoing | NO — parallel to E/F |
| **E** | Stress & Coverage | 10 (E1–E10) | 7 elapsed days | NO — parallel |
| **F** | Observability | 3 (F1–F3) | 1 week | NO |
| **G** | Versioning & Canary | 3 (G1–G3) | OPTIONAL, 2 weeks | — |

### 5.A Phase A — Quick Hygiene

> *"Surface debt-ი ცარიელდება სანამ structural რეფაქტორი იწყება. Phase A კომიტდება ერთ სესიაში."*

#### A1 — `memory/CONTEXT.md` refresh

- **Goal:** Phase E + IND1 closure-ის შემდეგ state-ის ცოცხალი snapshot. v1.1 plan ხურდება, v2.0 plan იხსნება.
- **Pre-mortem:**
  1. Content overflow 60-line cap → mitigation: line-count check pre-write.
  2. Lose historical detail → mitigation: archive `archive/contexts/2026-05-17.md` if user wants the snapshot.
  3. Active Task description misaligns with PostCompact `FIRST_WORD` check → mitigation: pick Active Task token that appears in both CONTEXT and any future COMPACT_STATE.
- **Acceptance criteria:**
  - [ ] `wc -l memory/CONTEXT.md` ≤ 60
  - [ ] `Updated:` line ≥ 2026-05-18
  - [ ] `Active Task:` reflects v2.0 roadmap execution
  - [ ] `File State` table matches `wc -l` of each tracked memory file
- **Rollback:** `git checkout memory/CONTEXT.md`
- **P×I:** 1 × 2 = **2** (Low)
- **Evidence required:** `git diff memory/CONTEXT.md` in commit body
- **Owner:** Claude (with `[APPROVED]`)
- **Depends on:** none

#### A2 — README.md internal contradiction fix

- **Goal:** README.md line 19 "Eight" → "Nine" (line 34 already correct).
- **Pre-mortem:**
  1. Sub-phrase reuse breaks search → mitigation: grep for "Eight" in whole repo afterwards, ensure 0 hits outside historical archives.
  2. README "57 files across" stale after this commit → mitigation: not affected (no file added).
- **Acceptance criteria:**
  - [ ] `grep -c "Eight" README.md` = 0
  - [ ] `grep -c "[Nn]ine lifecycle hooks" README.md` ≥ 1
- **Rollback:** trivial revert
- **P×I:** 1 × 2 = **2**
- **Evidence:** grep output in commit body
- **Owner:** Claude
- **Depends on:** none

#### A3 — SYSTEM_PROMPT_INSTALL.md "Eight" → "Nine"

- Same as A2 for `SYSTEM_PROMPT_INSTALL.md:117`. **P×I:** 1×2.

#### A4 — install.sh "All 8 hook scripts" → "All 9 hook scripts"

- **Goal:** `install.sh:125` text update.
- **Pre-mortem:** install.sh-ი ფიქსირდება executable check loop-ში; სტრიქონი strictly cosmetic — execution invariant.
- **Acceptance:** `grep -c "All 8 hook" install.sh` = 0; `grep -c "All 9 hook" install.sh` ≥ 1; `bash -n install.sh` clean.
- **P×I:** 1×2.

#### A5 — `memory/AUDIT_LOG.md` rollup-timestamp refresh

- **Goal:** `Last rollup` ხაზი → ბოლო ფაქტობრივი rollup ან მკაფიო "no rollup since" note.
- **Pre-mortem:** ცარიელი rollup metadata არ ფარავს real rollup-ის ცარიელობას → mitigation: comment in commit body specifies "metadata-only update, no entries moved".
- **Acceptance:** timestamp გადახედული; entries count უცვლელი.
- **P×I:** 2×1 = **2**.

#### A6 — Roadmap registration

- **Goal:** ეს ფაილი ფორმალურად რეგისტრირდეს inventory-ში.
- **Sub-tasks:**
  - A6a: `README.md` `Repo map (57 files across ...)` → bump to 58; add line `ROADMAP_ELITE_v2.md ← Strategic roadmap, supersedes IMPROVEMENT_PLAN.md v1.1 scope`
  - A6b: `FILE_UPDATE_RULES.md` File Operation Matrix → add row for `ROADMAP_ELITE_v2.md` (read when executing phases; write only while PROPOSED; max 700).
  - A6c: `memory/AUDIT_LOG.md` → entry recording v2.0 inception.
- **Pre-mortem:**
  1. README count drifts again → mitigation: `git ls-files | wc -l` immediately before commit; bake the exact number.
  2. `FILE_UPDATE_RULES.md` exceeds its `Max Size` (currently no cap declared, but anti-bloat principle applies) → mitigation: one row only, ≤2 lines added.
  3. AUDIT_LOG-ში entry-ის დამატება გადააცილებს 50-line cap-ს → mitigation: pre-write line-count check; rollup if exceeded.
- **Acceptance:** all 3 files touched, no cap violation, `bash SYSTEM_INTEGRITY_CHECK.sh` passes.
- **Rollback:** revert single commit; SYSTEM_INTEGRITY_CHECK.sh confirms structural cleanup.
- **P×I:** 2 × 2 = **4**
- **Evidence:** integrity script output + git diff in commit body.
- **Depends on:** A2–A5 (so README count update is atomic).

#### A7 — Marketplace work_dir decision (DECISION-ONLY, no code)

- **Goal:** დადგინდეს Finding F4-ის გადაჭრის გზა. ეს არის **decision task**, არა code task — Phase A-ში დევს, რომ Phase B (drift) დაიწყოს მკაფიო target-ით.
- **Three options to choose between:**
  - **Option α — Deploy doctrine to marketplace:** `install.sh --target /var/www/dedoplistsqaro-marketplace`. Marketplace იღებს memory + hooks. **Trade-off:** მფლობელობა / scope.
  - **Option β — Global fallback `~/.kimi/memory/`:** Host-wide doctrine memory for any work_dir. **Trade-off:** scope creep, conflict with project-specific memory.
  - **Option γ — Honest scope:** Document the limitation in `KIMI_PROTOCOL.md` — "doctrine is project-scoped; marketplace runs outside doctrine on purpose." **Trade-off:** marketplace remains unprotected, but architectural integrity preserved.
- **Pre-mortem of decision itself:**
  1. Wrong choice without owner discussion → mitigation: explicit user `[APPROVED] A7-<option>`.
  2. Decision logged but not applied → mitigation: A7 closure requires `DECISIONS.md` D9 entry citing chosen option.
- **Acceptance:** D9 entry exists in `memory/DECISIONS.md` referencing one of α/β/γ.
- **P×I:** 4 × 3 = **12** if delayed indefinitely (marketplace work continues unprotected); 1 × 1 = **1** if explicitly chosen γ.

### 5.B Phase B — Drift Elimination

> *"Layer 1 from elite review: derive what you can, don't write what you can derive."*

#### B1 — `canon/` directory scaffold

- **Goal:** Create `canon/` directory with empty schemas + README explaining the contract.
- **Files created:**
  - `canon/README.md` — "this directory is the single source of truth for all derivable artifacts"
  - `canon/.gitkeep`
- **Acceptance:** dir exists in git; `canon/README.md` ≤ 50 lines.
- **P×I:** 1 × 1 = **1**
- **Depends on:** A6.

#### B2 — `canon/hooks.yaml`

- **Goal:** Single declaration of every hook: name, event, matcher, script path, timeout, doc-string.
- **Schema:**
  ```yaml
  hooks:
    - name: session-start
      event: SessionStart
      matcher: ""
      script: .kimi/hooks/session-start.sh
      timeout: 10
      doc: "Inject default-read-order files into context"
  ```
- **Acceptance:** 9 entries in file; `yq '.hooks | length' canon/hooks.yaml` = 9.
- **Pre-mortem:** YAML syntax error → mitigation: CI validates with `yq` before merge.
- **P×I:** 1 × 2 = **2**
- **Depends on:** B1.

#### B3 — `canon/patterns.yaml`

- **Goal:** Single declaration of protected-file patterns + secret-content regexes (currently duplicated in `pre-tool-use.sh` and `pre-shell.sh`).
- **Schema:**
  ```yaml
  protected_files:
    block:
      - "*.env"
      - "*.env.*"
      # ...
    whitelist:
      - "*.env.example"
      # ...
  secrets:
    - name: aws_access_key
      regex: 'AKIA[0-9A-Z]{16}|ASIA[0-9A-Z]{16}'
    - name: openai_legacy
      regex: 'sk-(ant-)?[A-Za-z0-9_-]{20,}'
    # ...
  ```
- **Acceptance:** All 23 currently-duplicated patterns present once.
- **P×I:** 2 × 3 = **6**
- **Depends on:** B1.

#### B4 — `canon/thresholds.yaml`

- **Goal:** Single source for: memory file Max Size caps; compact ratios; P×I bounds; doctrine-warning %.
- **Acceptance:** all numeric thresholds referenced in `ROLLUP_POLICY.md`, `~/.kimi/config.toml`, doctrine docs are derived from this file.
- **P×I:** 2 × 3 = **6**

#### B5 — `canon/laws.yaml`

- **Goal:** L1–L7 → §-section mapping (currently manual table in `01_ELITE_ROLE.md` §C.6).
- **Acceptance:** 7 entries, each with `id`, `section_anchor`, `one_line_definition`.
- **P×I:** 1 × 2 = **2**

#### B6 — `generate.sh` script

- **Goal:** Idempotent generator that reads `canon/*.yaml` and emits:
  - `~/.kimi/config.toml` `[[hooks]]` blocks (from `hooks.yaml`)
  - `.kimi/hooks/_patterns.sh` (sourced common file from `patterns.yaml`)
  - README.md "Repo map" + hook count line (from `hooks.yaml` + `git ls-files`)
  - `SYSTEM_PROMPT_INSTALL.md` hook count
  - `install.sh` hook count line
  - L1–L7 mapping table in `01_ELITE_ROLE.md` §C.6
- **Pre-mortem:**
  1. Generator overwrites manual edits → mitigation: generator emits to a marked block (`<!-- BEGIN GENERATED: hooks -->`...`<!-- END GENERATED -->`); manual edits outside the block survive.
  2. Generator produces non-idempotent output (different output for same input) → mitigation: CI runs `generate.sh && git diff --exit-code`; must be empty.
  3. Cross-platform `yq` dependency → mitigation: pin to python `pyyaml` instead, no extra CLI.
- **Acceptance:**
  - [ ] `bash generate.sh && git diff --exit-code` passes on fresh checkout
  - [ ] All "8 vs 9" mismatch impossible by construction
- **Rollback:** revert commit; manual edits restored from git history.
- **P×I:** 3 × 4 = **12**
- **Depends on:** B2–B5.

#### B7 — Refactor `pre-tool-use.sh` + `pre-shell.sh` to source common patterns

- **Goal:** Both scripts `source .kimi/hooks/_patterns.sh` for the protected pattern list. Code duplication (F5) ფიზიკურად შეუძლებელი ხდება.
- **Acceptance:** `diff <(sed -n '93,100p' pre-tool-use.sh) <(sed -n '50,56p' pre-shell.sh)` is N/A — both files reference `${PROTECTED_PATTERNS[@]}` from sourced file.
- **CI check:** smoke tests still pass (negative case must still block).
- **P×I:** 2 × 4 = **8**
- **Depends on:** B6.

#### B8 — CI check: generated diff empty

- **Goal:** `.github/workflows/integrity.yml` runs `bash generate.sh` and asserts `git diff --exit-code`. If any committed artifact diverges from canon-derived form, CI fails.
- **Acceptance:** PR with manual edit to README hook-count line → CI fails until canon is updated.
- **P×I:** 1 × 4 = **4**
- **Depends on:** B6.

#### B9 — Documentation pointer

- **Goal:** `README.md` + `01_ELITE_ROLE.md` reference `canon/` as the single source. Manual edits to derived blocks are explicitly forbidden in CONTRIBUTING.
- **Acceptance:** `grep "canon/" README.md 01_ELITE_ROLE.md` ≥ 2.
- **P×I:** 1 × 2 = **2**

### 5.C Phase C — Real Enforcement

> *"Layer 2 from elite review: turn L1–L6 from inspirational into mechanical guard rails."*

#### C1 — Kimi 1.43+ payload introspection

- **Goal:** დადგინდეს, რა ფაქტობრივი ველებია Stop hook stdin-ში — შეიცავს თუ არა agent response text-ს.
- **Method:** Add `cat > .kimi/audit/stop-payload-$(date +%s).json` ერთჯერ in `stop.sh`, run any kimi session, inspect. Then revert the dump.
- **Acceptance:** documented payload schema in `agent/elite.system.md` Hooks section.
- **Pre-mortem:** payload-ი sensitive context-ის შემცველი → mitigation: dump removed immediately after inspection; user-facing inspection only.
- **P×I:** 2 × 3 = **6**
- **Depends on:** Phase B closed.

#### C2 — Stop hook upgrade: L2 citation heuristic

- **Goal:** თუ response შეიცავს "verified" / "confirmed" / "checked" / "I made sure" და არ შეიცავს file path : line, ან code-fence citation → emit warning to stderr.
- **Pre-mortem:**
  1. False positives on natural language → mitigation: warning-only (exit 0), not blocking; only emits to stderr (advisory).
  2. Payload-ი არ შეიცავს response → mitigation: skip silently, log "payload incomplete".
  3. Heuristic-ი ეშინია elite-grade-ის — overfits to phrasing → mitigation: scope to STATE-MUTATING turns only (when PreToolUse fired); skip pure-read turns.
- **Acceptance:** advisory message in audit log for ≥80% of test cases where response makes uncited claim.
- **P×I:** 3 × 3 = **9**
- **Depends on:** C1.

#### C3 — Stop hook: L6 3-ways-wrong heuristic

- **Goal:** Mutating turn-ში თუ response არ შეიცავს "3 ways" / "could be wrong" / "anti-self-deception" → exit 2 (block) **only if** payload provides response text; otherwise advisory warning.
- **Acceptance:** test case: response without 3-ways → exit 2 verified.
- **P×I:** 3 × 4 = **12**
- **Depends on:** C1, C2.

#### C4 — PreToolUse `[APPROVED]` gate for state mutation (L4 PEV)

- **Goal:** PreToolUse hook reads the last 5 user messages from session state; if state-mutating tool is invoked AND last user message does not contain `[APPROVED]` AND tool is not on the auto-approved list → exit 2.
- **Pre-mortem:**
  1. Hook cannot access session state → mitigation: requires C1 payload introspection; if not feasible, this task DEFERS to Phase G.
  2. Auto-approve list grows uncontrolled → mitigation: list defined in `canon/thresholds.yaml`; review on every CI run.
  3. Read-only sessions blocked → mitigation: only state-mutating tools (`WriteFile`, `StrReplaceFile`, `MultiEdit`, certain `Shell` patterns).
- **Acceptance:** turn that writes README without `[APPROVED]` → blocked.
- **P×I:** 4 × 4 = **16** — high impact, requires careful integration.
- **Depends on:** C1.

#### C5 — Telemetry signal collection

- **Goal:** Each PostToolUse + Stop event appends one JSONL line to `.kimi/audit/signals-YYYYMMDD.jsonl` with: ts, tool, has_cite (bool), has_risk_score (bool), has_3_ways (bool), turn_blocked (bool).
- **Acceptance:** week of data → aggregate report shows % per signal.
- **P×I:** 2 × 3 = **6**
- **Depends on:** C2, C3.

### 5.D Phase D — External Validation

> *"Layer 3 from elite review: break self-validation tautology with heterogeneous eyes."*

#### D1 — Tier-2 Review SOP

- **Goal:** `independent-validation.md` (or new section) defines exact procedure: which files to feed, which prompt, what counts as "specific flaw".
- **Acceptance:** SOP document ≤200 lines; reproducible.
- **P×I:** 1 × 3 = **3**

#### D2 — First Tier-2 manual review

- **Goal:** User-mediated: copy 01_ELITE_ROLE.md + this ROADMAP into GPT-4 / Gemini / Kimi K2 (direct, outside Claude wrapper) with SOP prompt. Receive ≥1 specific flaw. Log in `memory/AUDIT_LOG.md` as IND2.
- **Acceptance:** IND2 entry exists; ≥1 flaw recorded; AI proposes mitigation; mitigation either applied or explicitly declined-with-reason.
- **Pre-mortem:**
  1. Vendor outputs vague "looks good" → mitigation: SOP prompts for specific lines and assumptions to challenge.
  2. Flaw is unactionable → mitigation: SOP requires "actionable evidence: file:line".
  3. Flaw is already addressed elsewhere → mitigation: cross-check against this ROADMAP first.
- **P×I:** 3 × 3 = **9** if skipped (confirmation bias persists); 1 × 1 = **1** if executed.

#### D3 — CI Cross-Vendor Audit (OPTIONAL)

- **Goal:** Quarterly automated cross-vendor probe (cost-bounded, e.g., ≤$5/month).
- **Acceptance:** GH Action firing 1×/quarter; results PR-commented.
- **P×I:** 2 × 3 = **6** (deferred unless user opts in)

### 5.E Phase E — Stress & Coverage

> *"Layer 5 from elite review: validation can't be 1/7 of the design and call it 'production-ready'."*

#### E1–E6 — STRESS_LOG_DAY_2..7

- **Goal:** Per-day 10-task stress (3 light + 5 standard + 2 challenge) per `STRESS_TEST_PLAN.md`. One markdown file per day.
- **Acceptance:** Each file ≤60 lines, every task with PASS/FAIL + risk score; aggregate by day 7.
- **Pre-mortem:**
  1. User fatigue → mitigation: spread across calendar week; not all in one day.
  2. Task drift (different categories than spec) → mitigation: tasks pre-classified before execution.
- **P×I per day skipped:** 4 × 3 = **12** (long-term drift unproven)

#### E7 — V-31 Fallback over 15-message conversation

- **Goal:** Real long-context drift test per `VALIDATION_MATRIX.md:178`.
- **Acceptance:** logged turn-by-turn record; pass criteria match V-31 spec.
- **P×I:** 3 × 3 = **9**

#### E8 — V-32 Light-effort without explicit trigger

- **Goal:** Test that AI defers heavy ritual when context-classifies as light without explicit `light effort` phrase.
- **Acceptance:** documented decision per V-32.
- **P×I:** 2 × 2 = **4**

#### E9 — V-33 70-task / 7-day stress (umbrella for E1–E6)

- **Goal:** Aggregate report after E1–E6 finish.
- **Acceptance:** all 70 tasks logged, pass rate ≥90%, fail-analysis included.
- **P×I:** 4 × 3 = **12**

#### E10 — Hook pattern coverage smoke tests

- **Goal:** `.github/workflows/integrity.yml` smoke-test block expanded to cover: id_rsa, kubeconfig, gcloud-key, `*.tfstate`, `-----BEGIN OPENSSH PRIVATE KEY-----` in content, `xoxb-` token, `sk-ant-` key, `AKIA...`, `AIza...`.
- **Acceptance:** ≥10 negative cases tested (vs current 2).
- **P×I:** 2 × 4 = **8**
- **Depends on:** B7 (so refactored hooks still pass).

### 5.F Phase F — Observability

> *"Layer 4 from elite review: data, not vibes."*

#### F1 — Telemetry aggregator script

- **Goal:** `scripts/compliance_report.sh` reads `.kimi/audit/signals-*.jsonl`, emits weekly report:
  - L2 citation rate (% of mutating turns with explicit cite)
  - L5 risk score rate
  - L6 3-ways-wrong rate
  - Hook timeout incidents
- **Acceptance:** `bash scripts/compliance_report.sh` outputs table with last 7 days.
- **P×I:** 1 × 3 = **3**
- **Depends on:** C5.

#### F2 — Weekly dashboard markdown

- **Goal:** `memory/compliance/YYYY-WW.md` — generated from F1 output. Bounded by ROLLUP_POLICY.
- **Acceptance:** ≥1 weekly file exists after 7 days of telemetry.
- **P×I:** 1 × 2 = **2**

#### F3 — Trend alerting

- **Goal:** If any signal drops >20pp week-over-week → emit warning in next SessionStart hook.
- **Acceptance:** synthetic test (forge prior week's data) triggers alert.
- **P×I:** 2 × 3 = **6**

### 5.G Phase G — Versioning & Canary (OPTIONAL)

> *"Layer 5 from elite review: doctrine itself needs feature flags."*

#### G1 — `canon/v2.x/` directory layout

- **Goal:** `canon/v2.0/`, `canon/v2.1/`... + `canon/HEAD` symlink. `generate.sh --version v2.0` reads explicit version.
- **Acceptance:** two versions coexist; HEAD switchable.
- **P×I:** 2 × 3 = **6**

#### G2 — `install.sh --canary <version>`

- **Goal:** Deploy a non-HEAD version to a specific work_dir only.
- **Acceptance:** marketplace gets v2.1 while root stays v2.0; rollback works.
- **P×I:** 3 × 4 = **12** — careful, mutates global config.

#### G3 — `install.sh --rollback`

- **Goal:** Restore prior `~/.kimi/config.toml.bak.*`. Already exists semi-manually; formalize.
- **Acceptance:** one-command revert verified.
- **P×I:** 2 × 4 = **8**

---

## 6. Cross-cutting Concerns (apply to every task)

1. **One Conventional Commit per task.** No bundling. Commit subject: `<type>(<scope>): <task-ID> <one-line>`. Body: pre-mortem outcome, evidence, rollback note.
2. **Atomic file writes.** Hook scripts and generator use same-FS tempfile + `mv` rename. No partial writes.
3. **Doctrine-self-application.** This plan obeys L1–L7:
   - L1: any unknown found mid-execution → STOP, surface to user.
   - L2: every Acceptance Criteria has a verifiable command.
   - L3: each Phase passes the 6-Lens before its first commit (mental, recorded in commit body).
   - L4: this plan is the `[PLAN]`; phase execution awaits `[APPROVED]`.
   - L5: every task has P×I; ≥13 escalates to dedicated discussion; ≥19 not present here by design.
   - L6: §9 below.
   - L7: no fabrication, no skip plan, no auto-approve, no batch unrelated.
4. **Idempotency.** Every phase must be re-runnable on a fresh checkout to produce the same artifact.
5. **Reversibility.** Every commit has rollback note. No commit lands without verified revert path.
6. **Bounded surface.** No phase grows the active read surface beyond `ROLLUP_POLICY.md` budget (≤300 lines total active memory).
7. **Bilingual respect.** Narrative Georgian; identifiers and code English; commit messages English (Conventional Commits).

---

## 7. Aggregate Acceptance Criteria (90-day verdict)

ეს roadmap-ი წარმატებულია, თუ 90 დღის შემდეგ ცოცხალში ვერიფიცირდება ყველა შემდეგი:

- [ ] **Drift impossible.** `bash generate.sh && git diff --exit-code` passes in CI.
- [ ] **L6 mechanical.** Stop hook actually exits 2 on a synthetic L6-violation case (or documents Kimi payload limitation precisely).
- [ ] **External eye.** ≥1 IND2 entry in `memory/AUDIT_LOG.md`.
- [ ] **Stress baseline.** 7-day stress complete (E1–E6) or formally renegotiated.
- [ ] **Telemetry exists.** ≥1 weekly compliance report generated.
- [ ] **No regressions.** All v1.1 IMPROVEMENT_PLAN guarantees still hold (SYSTEM_INTEGRITY_CHECK.sh green).
- [ ] **Marketplace decision recorded.** D9 in DECISIONS.md.

---

## 8. Plan-level Pre-Mortem — სამი გზა, რომლითაც ეს გეგმა ვერ მუშაობს

### M1: Phase B generator over-engineers

**Failure mode:** `canon/*.yaml` + generator გახდება ცალკე subsystem უფრო რთული ვიდრე ის რასაც აშენებს.
**Trigger signal:** `generate.sh` > 300 lines, ან canon schema > 5 ფაილი.
**Mitigation:**
- Phase B kickoff-ში hard cap: generator ≤250 lines python.
- Canon ≤5 yaml files. თუ მე-6 საჭიროა — STOP, რეფაქტორ canon.
- Optimization toolset: `pyyaml` მხოლოდ (no `jinja2`, no plugins, no helpers).

### M2: Phase C runs into Kimi payload-შეზღუდვებს

**Failure mode:** C1 ფიქსირდება — Stop hook payload-ში არ არის response text. C2/C3 აღარ შესაძლებელია mechanically.
**Trigger signal:** C1 inspection აჩვენებს payload-ში მხოლოდ `{stop_reason: ...}`.
**Mitigation:**
- Pre-decision: C2/C3 fallback-ი — advisory warnings on PRE-tool-use heuristics (input → tool input → potential L2/L6 risk).
- Document Kimi limitation in `agent/elite.system.md`; submit upstream feature request.
- DEFER C4 (PEV gate) to Phase G (versioning) where canary-deployment-ი ფარავს რისკს.

### M3: User abandons mid-execution

**Failure mode:** Phase A ჩაიდება, B იწყება, შემდეგ თვის შემდეგ user attention shifts. Half-shipped state.
**Trigger signal:** No commits in this roadmap's commit-message scope for ≥14 days after a Phase opens.
**Mitigation:**
- Each phase closeable independently. No phase opens until previous phase committed and verified.
- `ROADMAP_ELITE_v2.md` itself has explicit `Status:` line. If user wants pause: `Status: PAUSED — <date> — <reason>`.
- Auto-archive policy: if `Status: PAUSED` ≥30 days, hook-emit reminder at SessionStart.

---

## 9. Anti-Self-Deception — სამი გზა, რომლითაც ჩემი ანალიზი არასწორია

### W1: 4.5:1 doctrine:enforcement ratio არ არის bug, ფიჩერია

**Argument:** `agent/elite.system.md:79` ღიად ამბობს "best-effort mechanical reinforcement". თუ doctrine მართებულად აცხადებს თავს inspirational framework-ად და არა enforced runtime-ად, მაშინ ჩემი კრიტიკა misframes the system.
**Counter-check:** ეს roadmap არ აიძულებს doctrine-ს enforced-ად დაირქმეს. Phase C *არ* აცხადებს "სრულ enforcement"-ს; ის ცდილობს რეალური guard rail-ის შემოღებას რეალური trade-off-ის გათვალისწინებით. თუ C1 აჩვენებს რომ ეს Kimi-ში შეუძლებელია → M2 mitigation activates.

### W2: Tier-2 cross-vendor "ცარიელია" claim — შესაძლოა exaggeration

**Argument:** Tier-3 (same-vendor different-session) ცარიელი არ არის. Subagent isolation-ი რეალურია; 4 reviewer-ი reality-check-ის ვალენტობას ფასობს, თუნდაც confirmation bias არსებობდეს.
**Counter-check:** Phase D *არ* ცვლის Tier-3-ის ღირებულებას — ის ემატება Tier-2-ს რეპერტუარს. ღია trade-off; cost vs coverage.

### W3: Phase F (telemetry) over-engineering for single-operator

**Argument:** Compliance dashboard-ი ცარიელია თუ მხოლოდ ერთი ადამიანი ხედავს. Manual review უფრო ეფექტიანი.
**Counter-check:** Phase F1 specifies *script*, არა dashboard. ერთი ბრძანება ერთ ცხრილს უწევს print. Threshold-ი F3-ში: only triggers reminder, არ აპირებს რომ ვინმე dashboard-ი წაიკითხოს.

---

## 10. Approval Gates

ეს გეგმა PROPOSED-ია. ცვლილებები მოხდება მხოლოდ `[APPROVED]`-ის შემდეგ. ფორმატი:

| Trigger | Effect |
|---|---|
| `[APPROVED] A` | Phase A executes (A1–A7) |
| `[APPROVED] A+B` | Phase A then B sequentially |
| `[APPROVED] A1,A2,A3` | Specific tasks only, partial Phase A |
| `[APPROVED] full` | All phases A–F (G is opt-in only) |
| `[APPROVED] full + G` | Including canary/versioning |
| `REJECT — <reason>` | Plan revised; new `[APPROVED]` required after edit |
| `PAUSE — <reason>` | `Status: PAUSED — <date> — <reason>` set; no commits |

**Note:** Phase A is intentionally pre-classified as housekeeping with P×I ≤ 4 per task. The user may opt to pre-approve all of Phase A by saying `[APPROVED] A`, then individually gate B–G.

---

## 11. Registration — ეს ფაილი როგორ ერთვება inventory-ში

**A6 task-ის concrete deliverable:**

1. **`README.md`** ცვლილებები:
   - ხაზი 183: `## Repo map (57 files across 4 layers)` → `## Repo map (58 files across 4 layers)`
   - "Operational layer" section-ში დაემატება: `ROADMAP_ELITE_v2.md       ← Strategic roadmap (this file)`
2. **`FILE_UPDATE_RULES.md`** File Operation Matrix-ში new row:
   ```
   | ROADMAP_ELITE_v2.md | When executing v2.0 phases | While Status: PROPOSED; archives to archive/improvement_plans/ when all phases ship or are abandoned | AI or user | Overwrite while proposed; archive after | 700 |
   ```
3. **`memory/AUDIT_LOG.md`** new entry:
   ```
   E11: ROADMAP_ELITE_v2.md inception — strategic plan addressing structural gaps beyond v1.1 IMPROVEMENT_PLAN scope — 2026-05-18 — PROPOSED
   ```
4. **`memory/DECISIONS.md`** new entry:
   ```
   D9: ROADMAP_ELITE_v2.md added as supplementary plan to IMPROVEMENT_PLAN.md v1.1; scope is structural (Layer 1-6), not surface — ACTIVE — 2026-05-18
   ```

ეს ცვლილებები ხდება ერთ commit-ში, A6 task-ის ფარგლებში, `[APPROVED] A6` ან `[APPROVED] A`-ის შემდეგ.

---

## 12. Change Log

- **v2.0** — 2026-05-18 — initial proposal from elite-grade architectural audit (current session). User-confirmed requirements U1–U5 captured; Phases A–G drafted with per-task pre-mortem, acceptance, rollback, P×I, evidence. Status: PROPOSED.
- **v2.0-a** — 2026-05-18 — Phase A shipped (commits 472f54d…382bdd8 + bdf40f8). Status updated in §0.
- **v2.0-b** — 2026-05-18 — Phase B shipped (commits eeec1fb…93ef2bb + 1a92fc5 hotfix + aed1f52 hygiene).
- **v2.0-C1** — 2026-05-18 — **Phase C task C1 closed via source inspection** (not instrumentation). Read `kimi_cli/hooks/events.py` + `runner.py` + `engine.py` from the installed kimi-cli 1.44.0 package. Complete payload schema for all 12 hook events recorded in `agent/elite.system.md` "Per-event Input Payload Schema" section. Key findings that refine C2–C5 scope:
  - **C3 (L6 3-ways-wrong block):** NOT ACHIEVABLE for primary agent — `Stop` payload exposes only `{hook_event_name, session_id, cwd, stop_hook_active}`, no response text. M2 fallback from §8 ACTIVATES: keep current advisory-reminder semantics. Plan P×I lowered from 3×4=12 to 1×2=2 (advisory-only scope).
  - **C2 (L2 citation):** PARTIALLY ACHIEVABLE. `PostToolUse.tool_output` IS visible — a hook can scan tool output for uncited claim patterns, but cannot scan the agent's narrative outside tool calls. Plan rescoped to "advisory PostToolUse-based heuristic," P×I 3×3=9 stays.
  - **C4 (PEV [APPROVED] gate):** FULLY ACHIEVABLE. `UserPromptSubmit` payload contains the full `prompt` string. Design: register a UserPromptSubmit hook that caches the last prompt to a file; existing PreToolUse hook reads cache, blocks state-mutating tools when `[APPROVED]` is absent. P×I 4×4=16 unchanged.
  - **C5 (telemetry):** UNCHANGED. PostToolUse + Stop events provide enough signal fields.
  - **Block protocol:** Two equivalent block forms confirmed (`exit 2 + stderr` AND `exit 0 + JSON {"hookSpecificOutput":{"permissionDecision":"deny",...}}`). All existing hooks use the first; future hooks may use either.
  - **Fail-open:** Confirmed at 30s timeout per hook in `runner.py`. Aggregate `block` wins from any matching hook (`engine.py`).
- **v2.0-D** — 2026-05-19 — **Phase D closed.** D1 ✅ (SOP + bundle generator), D2 ✅ (Tier-2 cross-vendor review via isolated Kimi K2 → IND2 in AUDIT_LOG.md → flaw applied: doctrine §6 exception list extended). **D3 DEFERRED** by operator choice (commit references — D11 in `memory/DECISIONS.md` 2026-05-19): the manual D2 flow (`build-tier2-bundle.sh` + isolated `kimi --print`) covers the periodic-review need; quarterly automation is not yet load-bearing. D3 will be revisited if operator wants quarterly cadence or an org policy mandates automated cross-vendor checks. The OPTIONAL flag in §5.D.D3 already documented this possibility; this entry records the actual choice on the record. Phase E next.
- **v2.0-D2** — 2026-05-19 — **Phase D task D2 closed via isolated Kimi K2 review** (different vendor: Moonshot ≠ Anthropic). Bundle (`build-tier2-bundle.sh` @ commit 30bfea7, 7 files, 176 KB) was fed to `kimi --print --quiet` running under `HOME=/tmp/kimi-tier2-home` with all `[[hooks]]` blocks stripped from the temp `config.toml` and skills dir pointed at an empty directory — so neither host hooks nor the elite-role skill could bias the session. First wall-clock at 300 s timeout mid-analysis; finding was extracted from `wire.jsonl` thinking trace and re-verified by grep against the live repo. IND2 entry in `memory/AUDIT_LOG.md`. **Flaw raised:** `01_ELITE_ROLE.md:350` (Doctrine §6) 400-word cap exception list ("technical spec or audit report") missed `deep mode / challenge-grade review`, contradicting `KIMI_PROTOCOL.md:420` (G.4 ladder: deep 800). Severity P3×I2=6. **Mitigation applied** (not declined): `01_ELITE_ROLE.md:350` and `:738` exception clauses extended to name "deep-mode / challenge-grade review" and to cite G.4 as the authoritative ladder. The protocol now refines the doctrine instead of contradicting it. D3 (CI cross-vendor automation, OPTIONAL) untouched.
- **v2.0-D1** — 2026-05-19 — **Phase D task D1 closed.** Tier-2 SOP added to `.kimi/skills/elite-role/references/independent-validation.md` (sections 1–6: artifact bundle, verbatim reviewer prompt, "specific flaw" definition, response handling, IND<N> Tier-2 log template, pass criteria). File grew 78 → 192 lines, under the 200-line cap. `build-tier2-bundle.sh` added at repo root — small generator that concatenates the 7 artifact files with `=== FILE: <path> ===` headers and emits a single bundle for paste into a different-vendor LLM. Script is shellcheck clean; bundle output is **not** committed (regenerable; commit SHA at review time is the durable reference). D2 (first user-mediated execution) is the next step; D3 (CI cross-vendor) remains OPTIONAL pending operator opt-in.
- **v2.0-C** — 2026-05-19 — **Phase C closed.** C2 (PostToolUse L2 citation heuristic, commit 6b899f2), C3 (stop.sh honesty about L6 mechanical limit, commit 61f2c47), C5 (telemetry signals, bundled with C2), and C4 (PEV `[APPROVED]` gate, this commit) all shipped. Hook script count 9 → 10 (`user-prompt-submit.sh` added); derived files (`README.md`, `install.sh`, `.kimi/hooks.example.toml`) regenerated by `generate.sh`. **C4 acceptance-honesty footnote:** the ROADMAP §5.C.C4 acceptance line ("turn that writes README without `[APPROVED]` → blocked") is met *only* when the `.kimi/state/c4-strict-mode` sentinel exists. By default the gate is **advisory** (stderr warning, exit 0) — a deliberate choice to avoid breaking flow during the first week of deployment. Operator opts in to enforcement with `touch .kimi/state/c4-strict-mode`. Smoke-tested 5/5 (allow-with-token, advisory-warn-without-token, strict-block-without-token, pre-shell strict-block, pre-shell pure-read pass-through). `.kimi/state/` added to `.gitignore` — per-session cache is transient, not history. Auto-approve list (mentioned in C4 pre-mortem #2) NOT introduced: the mutation matcher in `pre-shell.sh` already restricts the gate to actual mutating patterns, and `pre-tool-use.sh` registers only on `WriteFile|StrReplaceFile|MultiEdit` — the matcher itself is the allowlist. If telemetry surfaces false positives, the matcher (canon-managed) is the place to narrow them.

---

## 13. Quick-Reference Index

| ნაჭერი | ხაზი |
|---|---|
| Supersedence vs IMPROVEMENT_PLAN.md v1.1 | §0 |
| User requirements (compact 0.70 confirmed) | §1 |
| Goal (90-day outcome) | §2 |
| Constraints (Kimi Beta, single operator) | §3 |
| Evidence base (F1–F11) | §4 |
| Phase A — Quick hygiene | §5.A |
| Phase B — Drift elimination | §5.B |
| Phase C — Real enforcement | §5.C |
| Phase D — External validation | §5.D |
| Phase E — Stress & coverage | §5.E |
| Phase F — Observability | §5.F |
| Phase G — Versioning & canary | §5.G |
| Plan-level pre-mortem | §8 |
| Anti-self-deception | §9 |
| Approval syntax | §10 |
| Registration deliverable | §11 |
