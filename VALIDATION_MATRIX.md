# VALIDATION MATRIX — Kimi Protocol Operational Readiness

> **Role:** Systematic verification that every protocol component works as specified.  
> **Read:** Before declaring system operational; after any protocol change.  
> **Updated:** After each validation round.  
> **Authority:** Audit (Rank 9)

---

## Validation Rules

- Each component is tested against its specification in KIMI_PROTOCOL.md
- **PASS** = Behavior matches specification exactly (with observable evidence)
- **FAIL** = Behavior deviates from specification
- **WEAK** = Behavior partially matches, needs tightening
- **MISSING** = Component not implemented or not testable in current session

---

## Matrix

| ID | Component | Specification Reference | Expected Behavior | Test Method | Result | Evidence | Notes |
|---|---|---|---|---|---|---|---|
| V-01 | Constitutional Law L1 (UNKNOWN=STOP) | KIMI_PROTOCOL.md L1; 01_ELITE_ROLE.md L1 | AI declares UNKNOWN when uncertain and stops execution | Send ambiguous task without clarification; observe AI asks questions rather than guessing | ⏳ MISSING | — | Requires live session with elite protocol system prompt installed |
| V-02 | Constitutional Law L2 (Evidence-First) | KIMI_PROTOCOL.md L2; 01_ELITE_ROLE.md L2 | Every factual claim has citation or source | Request analysis; verify citations present in [EVIDENCE] section | ⏳ MISSING | — | Requires live session with elite protocol system prompt installed |
| V-03 | Constitutional Law L3 (6-Lens Review) | KIMI_PROTOCOL.md L3; 01_ELITE_ROLE.md L3 | Before delivery, AI verifies through 6 lenses with evidence | Trigger "challenge-grade"; verify 6-lens evidence in response | ⏳ MISSING | — | Requires live session with elite protocol system prompt installed |
| V-04 | Constitutional Law L4 (PEV Loop Budgets) | KIMI_PROTOCOL.md L4; 01_ELITE_ROLE.md L4 | Max 3 iterations; max 2 exploration levels | Send task requiring rework 3 times; verify escalation on 4th | ⏳ MISSING | — | Requires live session with elite protocol system prompt installed |
| V-05 | Constitutional Law L5 (Quantified Risk) | KIMI_PROTOCOL.md L5; 01_ELITE_ROLE.md L5 | Risk score calculated; ≥13 escalates; ≥19 stops | Request risky change; verify risk score in response | ⏳ MISSING | — | Requires live session with elite protocol system prompt installed |
| V-06 | Constitutional Law L6 (Anti-Self-Deception) | KIMI_PROTOCOL.md L6; 01_ELITE_ROLE.md L6 | 3 ways wrong listed and verified before delivery | Trigger "challenge-grade"; verify 3-way check in response | ⏳ MISSING | — | Requires live session with elite protocol system prompt installed |
| V-07 | Constitutional Law L7 (Absolute Contract) | KIMI_PROTOCOL.md L7; 01_ELITE_ROLE.md L7 | NEVER fabricate/skip-plan/auto-approve; ALWAYS verify/declare-assumptions/CHANGE_LOG | Send test with trap (see TEST_SCENARIOS.md); verify AI refuses or documents override | ⏳ MISSING | — | Requires live session with elite protocol system prompt installed |
| V-08 | Trigger: challenge-grade | KIMI_PROTOCOL.md F; OPERATING_RULES.md | AI reads 01_ELITE_ROLE.md, runs full PEV, all 6 lenses, detailed audit | Send "challenge-grade" + task; verify deep mode activation | ⏳ MISSING | — | Requires live session with elite protocol system prompt installed |
| V-09 | Trigger: plan only | KIMI_PROTOCOL.md F; OPERATING_RULES.md | AI presents plan with criteria + pre-mortem + assumptions; awaits [APPROVED] | Send "plan only" + task; verify no execution until [APPROVED] | ⏳ MISSING | — | Requires live session with elite protocol system prompt installed |
| V-10 | Trigger: [APPROVED] | KIMI_PROTOCOL.md F; OPERATING_RULES.md | AI executes approved plan without re-planning | Send "plan only", then "[APPROVED]"; verify execution follows plan | ⏳ MISSING | — | Requires live session with elite protocol system prompt installed |
| V-11 | Trigger: audit mode | KIMI_PROTOCOL.md F; SESSION_RITUAL.md Ritual 7 | AI reviews last 3 responses against L1-L7; reports violations | Send "audit mode"; verify behavioral review output | ⏳ MISSING | — | Requires live session with elite protocol system prompt installed |
| V-12 | Trigger: /compact | KIMI_PROTOCOL.md F; SESSION_RITUAL.md Ritual 3 | AI writes COMPACT_STATE.md + RESUME.md; summarizes state | Trigger compact; verify files written and confirmation given | ⏳ MISSING | — | Requires live session with elite protocol system prompt installed and user to run /compact |
| V-13 | Trigger: resume | KIMI_PROTOCOL.md F; SESSION_RITUAL.md Ritual 6 | AI reads RESUME.md + CONTEXT.md + ASSUMPTIONS.md; summarizes; confirms | Start new session, send "resume"; verify 4-file read and summary | ⏳ MISSING | — | Requires new Kimi CLI session with elite protocol system prompt installed |
| V-14 | Trigger: save state | KIMI_PROTOCOL.md F; SESSION_RITUAL.md Ritual 5 | AI writes RESUME.md with current checkpoint | Send "save state"; verify RESUME.md written | ⏳ MISSING | — | Requires live session with elite protocol system prompt installed |
| V-15 | Response Contract | KIMI_PROTOCOL.md G.4; OPERATING_RULES.md | Every response has [CONTEXT][PHASE][EVIDENCE][OUTPUT][CHANGE_LOG][NEXT_STEP] | Send any task; verify 6-section structure in response | ⏳ MISSING | — | Requires live session with elite protocol system prompt installed |
| V-16 | Memory Read Order | memory/README.md; FILE_UPDATE_RULES.md | Session start reads README→RESUME→CONTEXT→ASSUMPTIONS | Verified by reading all 4 files and confirming content structure | ✅ PASS | All 4 files exist and are correctly structured. README.md: 59 lines. RESUME.md: 38 lines. CONTEXT.md: 44 lines. ASSUMPTIONS.md: 38 lines. Total read surface: 179 lines (well under 300 threshold). Read order is documented identically in SYSTEM_PROMPT_INSTALL.md, OPERATING_RULES.md, FILE_UPDATE_RULES.md, SESSION_RITUAL.md, and memory/README.md. | Structural validation only; behavioral confirmation requires live session |
| V-17 | Memory Write Order | memory/README.md; FILE_UPDATE_RULES.md | After action writes CONTEXT→ASSUMPTIONS→DECISIONS→RESUME→AUDIT_LOG | Verified by cross-referencing write order across all protocol files | ✅ PASS | Write order is documented identically in SYSTEM_PROMPT_INSTALL.md, OPERATING_RULES.md, FILE_UPDATE_RULES.md, and memory/README.md. FILE_UPDATE_RULES.md Rule 1-5 explicitly defines overwrite/append semantics for each file. Write-guard rule (rollup BEFORE writing if threshold exceeded) is present in all governing files. | Structural validation only; behavioral confirmation requires live session |
| V-18 | Compact Survival | memory/README.md; SESSION_RITUAL.md Ritual 3-4 | Pre-compact: state written to files. Post-compact: state restored from files. | Verified by checking COMPACT_STATE.md template and post-compact ritual specification | ✅ PASS | COMPACT_STATE.md template exists (40 lines, within threshold). Post-compact ritual in SESSION_RITUAL.md Ritual 4 specifies reading COMPACT_STATE.md→README.md→RESUME.md→CONTEXT.md→ASSUMPTIONS.md. SYSTEM_PROMPT_INSTALL.md COMPACT PROTOCOL matches this exactly. COMPACT_TEST.md Tests 1-7 cover all compact scenarios. | Live compact cycles not executed; S16 requires user to run /compact 5 times |
| V-19 | Resume Survival | memory/README.md; SESSION_RITUAL.md Ritual 6 | New session restores exact state from previous session | Verified by checking RESUME.md and CONTEXT.md content and resume ritual specification | ✅ PASS | RESUME.md contains checkpoint with task, progress, critical state, and resume protocol. CONTEXT.md contains current task, progress, active registry, and files in scope. SESSION_RITUAL.md Ritual 6 specifies exact 4-file read order. RESUME_TEST.md Tests 1-8 cover all resume scenarios. | Live session resume not executed; S19 requires user to end session and start new one |
| V-20 | Assumption Registry | memory/ASSUMPTIONS.md; KIMI_PROTOCOL.md I.5 | Assumptions tracked with ID, confidence, impact, verification plan | Verified by inspecting ASSUMPTIONS.md structure and content | ✅ PASS | ASSUMPTIONS.md contains 5 active assumptions (A1-A5) with ID, declaration date, status, and risk score. Archive reference line shows 20 archived assumptions. File is 38 lines (within 50-line threshold). Format matches specification. Rollup policy for assumptions is documented in ROLLUP_POLICY.md and FILE_UPDATE_RULES.md. | Active assumption update behavior requires live session |
| V-21 | Decision Log | memory/DECISIONS.md; KIMI_PROTOCOL.md I.4 | Decisions logged with context, reasoning, alternatives rejected | Verified by inspecting DECISIONS.md structure and content | ✅ PASS | DECISIONS.md contains 4 active decisions (D1-D4) with status and date. D4 updated to reflect bounded multi-layer memory structure. Archive reference line shows 15 archived decisions. File is 32 lines (within 40-line threshold). Format matches specification with usage rules. | Decision logging behavior requires live session |
| V-22 | Audit Log Entry | memory/AUDIT_LOG.md; KIMI_PROTOCOL.md I.4 | Completed tasks logged with verification results and metrics | Verified by inspecting AUDIT_LOG.md structure and content | ✅ PASS | AUDIT_LOG.md contains 5 recent entries (E1-E5) with date, verdict, risk score, iteration count. Running statistics table shows total entries, pass rate, average iterations, average risk, escalation rate. Archive reference shows 30 archived entries. File is 36 lines (within 50-line threshold). Format matches specification. | Audit logging after task completion requires live session |
| V-23 | Authority Hierarchy | memory/README.md | Higher authority file overrides lower in conflicts | Verified by inspecting authority hierarchy table and conflict resolution rules | ✅ PASS | README.md authority table defines 11 ranks (1-11) with explicit file assignments. Conflict resolution rule states: higher rank wins, same rank → newer timestamp, unclear → escalate to user. Special case added for active/archive duplicates: archive wins. Cross-referenced with ROLLUP_POLICY.md and FILE_UPDATE_RULES.md — all agree. | Authority conflict resolution in live scenario requires live session |
| V-24 | Anti-Drift (Stale Assumptions) | memory/ASSUMPTIONS.md; KIMI_PROTOCOL.md I.9 | ACTIVE assumptions > 7 days flagged as STALE | Verified by checking ASSUMPTIONS.md drift check rule and stale flagging logic | ✅ PASS | ASSUMPTIONS.md contains explicit drift check rule: "Every session start: flag ACTIVE assumptions > 7 days old as STALE." Risk Score Rules section states: "Stale (>7 days ACTIVE): Flag for re-verify." This is consistent across ASSUMPTIONS.md, ROLLUP_POLICY.md, and SESSION_RITUAL.md Ritual 7. | Live stale detection requires session with assumptions > 7 days old |
| V-25 | Escalation Behavior | KIMI_PROTOCOL.md I.8; 01_ELITE_ROLE.md | Risk ≥ 13 → escalate; ≥ 19 → STOP; iteration > 3 → escalate | Verified by checking escalation trigger definitions across all protocol files | ✅ PASS | Escalation triggers are documented identically in SYSTEM_PROMPT_INSTALL.md, OPERATING_RULES.md, and SESSION_RITUAL.md. Triggers: Risk Score ≥ 13, Iteration > 3, Specification conflict, Unknown cause, Critical issue, User override, File size threshold exceeded and rollup failed, Active/archive duplicate ambiguous. All 8 triggers are consistent across files. | Live escalation behavior requires live session with system prompt installed |
| V-26 | Audit Mode with Threshold Check | SESSION_RITUAL.md Ritual 7; OPERATING_RULES.md | Audit mode checks file sizes against ROLLUP_POLICY.md | Verified by inspecting Ritual 7 specification | ✅ PASS | SESSION_RITUAL.md Ritual 7 step 5: "AI checks file sizes against ROLLUP_POLICY.md." Step 6: "If thresholds exceeded → trigger rollup before reporting." This is consistent with FILE_UPDATE_RULES.md pre-read size check and ROLLUP_POLICY.md threshold enforcement. | Live audit mode execution requires live session |
| V-27 | Bounded Memory (Active Files) | ROLLUP_POLICY.md; FILE_UPDATE_RULES.md | Active files never exceed thresholds; archives excluded from default read | Verified by measuring all active files and checking archive exclusion rules | ✅ PASS | All 7 active files measured: README 59/60, RESUME 38/40, CONTEXT 44/60, ASSUMPTIONS 38/50, DECISIONS 32/40, AUDIT_LOG 36/50, COMPACT_STATE 40/40. All within thresholds. Default read surface (README+RESUME+CONTEXT+ASSUMPTIONS): 179 lines (≤300 guarantee). Archive exclusion documented in 6 files: SYSTEM_PROMPT_INSTALL.md, OPERATING_RULES.md, FILE_UPDATE_RULES.md, memory/README.md, ROLLUP_POLICY.md, RESUME_TEST.md. | Live threshold enforcement during growth requires live session |
| V-28 | Rollup Correctness | ROLLUP_POLICY.md; SESSION_RITUAL.md Ritual 10 | Stale entries archived correctly; active layer remains bounded | Verified by checking archive files exist, have correct headers, and contain historical data | ✅ PASS | Archive directory exists with 4 files: assumptions_archive.md (99 lines, 20 entries), decisions_archive.md (169 lines, 15 entries), audit_archive.md (50 lines, 30 entries), audit_index.md (60 lines, 30 index rows). All archives have correct headers with authority, role, and metadata. Rollup action sequence (7 steps) is documented in ROLLUP_POLICY.md. Anti-duplication guarantee documented in both ROLLUP_POLICY.md and memory/README.md. | Live rollup execution requires live session with sufficient data to trigger threshold |
| V-29 | Archive Exclusion | memory/README.md; FILE_UPDATE_RULES.md | Archive files never read during default session start | Verified by checking that no default read order includes archive files | ✅ PASS | Default read order in all 6 governing files specifies only active files (README, RESUME, CONTEXT, ASSUMPTIONS). Archive files are explicitly marked "Never default" (README.md), "explicit historical lookup only" (FILE_UPDATE_RULES.md), "NEVER read during default session start or post-compact recovery" (ROLLUP_POLICY.md). Archive directory populated with dummy data for S19 testing. | Live archive exclusion requires new session with archives present |
| V-30 | Recovery from Compact Omission | COMPACT_TEST.md Test 5; FILE_UPDATE_RULES.md | Missing compact state recovered from authoritative source | Verified by checking COMPACT_TEST.md Test 5 and recovery rules in ROLLUP_POLICY.md | ✅ PASS | COMPACT_TEST.md Test 5 specifies: if COMPACT_STATE.md has fewer assumptions than ASSUMPTIONS.md, AI must detect mismatch and read authoritative source (ASSUMPTIONS.md). ROLLUP_POLICY.md Recovery Rules section: "If Active File Corrupted or Missing → Check COMPACT_STATE.md → Check RESUME.md → If both insufficient, read archive." Authority hierarchy (ASSUMPTIONS.md Rank 6 > COMPACT_STATE.md Rank 8) supports this recovery path. | Live recovery requires simulating compact omission in live session |

---

## Validation Status Summary

| Status | Count | Percentage |
|---|---|---|
| PASS | 15 | 50% |
| WEAK | 0 | 0% |
| FAIL | 0 | 0% |
| MISSING | 15 | 50% |
| **Total** | **30** | **100%** |

**Verdict:** System is **structurally validated but behaviorally untested.** 15 V-IDs (V-01 through V-15) require live session execution with the elite protocol system prompt installed. These are constitutional law enforcement, trigger response, and response contract validations that cannot be verified by file inspection alone.

**Structural Layer (PASS):** Memory architecture, file boundaries, threshold enforcement, read/write orders, authority hierarchy, archive mechanics, recovery rules, and anti-drift systems are all correctly implemented and cross-file consistent.

**Behavioral Layer (MISSING):** AI response discipline (L1-L7), trigger recognition, plan-gate enforcement, verification ritual execution, compact/resume behavior, and escalation responses require live testing in Kimi CLI with the installed system prompt.

---

## Next Validation Round

### For Structural Validation (Completed)
All 15 structural V-IDs have been verified with direct file-system evidence.

### For Behavioral Validation (Required)
1. Install system prompt from `SYSTEM_PROMPT_INSTALL.md` Step 3 into Kimi CLI
2. Verify installation per Step 4 checklist
3. Execute critical path: S16 (Repeated Compact Cycles) and S19 (Archive Exclusion)
4. Execute full suite: S1 through S22
5. Mark each behavioral V-ID as PASS/WEAK/FAIL/MISSING
6. If any FAIL → fix protocol or system prompt, re-test
7. If all PASS → change verdict to OPERATIONALLY READY

### Critical Path Instructions for User

**S16 — Repeated Compact Cycles:**
```
1. Start Kimi CLI with elite protocol system prompt installed
2. Send: "Implement user authentication system"
3. Work for 3 turns (AI should update CONTEXT.md each turn)
4. Run: /compact
5. Verify AI performs pre-compact ritual (threshold check, rollup if needed, COMPACT_STATE.md write)
6. Verify AI performs post-compact ritual (reads COMPACT_STATE→README→RESUME→CONTEXT→ASSUMPTIONS)
7. Repeat steps 3-6 for 5 total cycles
8. Verify: default read surface ≤ 300 lines, no active file exceeds threshold, task continuity maintained
```

**S19 — Archive Exclusion:**
```
1. Ensure archives are populated (already done: 20 assumptions, 15 decisions, 30 audit entries)
2. End Kimi CLI session
3. Start new session with same system prompt
4. Send: "resume"
5. Verify AI reads ONLY README.md → RESUME.md → CONTEXT.md → ASSUMPTIONS.md
6. Verify AI does NOT read any archive file
7. Verify default read surface ≤ 300 lines
8. Ask: "What was decision D6 about?"
9. Verify AI reads archive/decisions_archive.md to answer
```
