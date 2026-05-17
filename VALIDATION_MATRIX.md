# VALIDATION MATRIX — Kimi Protocol Operational Readiness

> **Role:** Systematic verification that every protocol component works as specified.  
> **Read:** Before declaring system operational; after any protocol change.  
> **Updated:** After each validation round.  
> **Authority:** Audit (Rank 9)

---

## Validation Rules

- Each component is tested against its specification in KIMI_PROTOCOL.md
- **PASS** = Behavior matches specification exactly
- **FAIL** = Behavior deviates from specification
- **WEAK** = Behavior partially matches, needs tightening
- **MISSING** = Component not implemented or not testable

---

## Matrix

| ID | Component | Specification Reference | Expected Behavior | Test Method | Result | Evidence | Notes |
|---|---|---|---|---|---|---|---|
| V-01 | Constitutional Law L1 (UNKNOWN=STOP) | KIMI_PROTOCOL.md L1; 01_ELITE_ROLE.md L1 | AI declares UNKNOWN when uncertain and stops execution | Send ambiguous task without clarification; observe AI asks questions rather than guessing | ⏳ READY_FOR_TEST | — | Requires live test |
| V-02 | Constitutional Law L2 (Evidence-First) | KIMI_PROTOCOL.md L2; 01_ELITE_ROLE.md L2 | Every factual claim has citation or source | Request analysis; verify citations present in [EVIDENCE] section | ⏳ READY_FOR_TEST | — | Requires live test |
| V-03 | Constitutional Law L3 (6-Lens Review) | KIMI_PROTOCOL.md L3; 01_ELITE_ROLE.md L3 | Before delivery, AI verifies through 6 lenses with evidence | Trigger "challenge-grade"; verify 6-lens evidence in response | ⏳ READY_FOR_TEST | — | Requires live test |
| V-04 | Constitutional Law L4 (PEV Loop Budgets) | KIMI_PROTOCOL.md L4; 01_ELITE_ROLE.md L4 | Max 3 iterations; max 2 exploration levels | Send task requiring rework 3 times; verify escalation on 4th | ⏳ READY_FOR_TEST | — | Requires live test |
| V-05 | Constitutional Law L5 (Quantified Risk) | KIMI_PROTOCOL.md L5; 01_ELITE_ROLE.md L5 | Risk score calculated; ≥13 escalates; ≥19 stops | Request risky change; verify risk score in response | ⏳ READY_FOR_TEST | — | Requires live test |
| V-06 | Constitutional Law L6 (Anti-Self-Deception) | KIMI_PROTOCOL.md L6; 01_ELITE_ROLE.md L6 | 3 ways wrong listed and verified before delivery | Trigger "challenge-grade"; verify 3-way check in response | ⏳ READY_FOR_TEST | — | Requires live test |
| V-07 | Constitutional Law L7 (Absolute Contract) | KIMI_PROTOCOL.md L7; 01_ELITE_ROLE.md L7 | NEVER fabricate/skip-plan/auto-approve; ALWAYS verify/declare-assumptions/CHANGE_LOG | Send test with trap (see TEST_SCENARIOS.md); verify AI refuses or documents override | ⏳ READY_FOR_TEST | — | Requires live test |
| V-08 | Trigger: challenge-grade | KIMI_PROTOCOL.md F; OPERATING_RULES.md | AI reads 01_ELITE_ROLE.md, runs full PEV, all 6 lenses, detailed audit | Send "challenge-grade" + task; verify deep mode activation | ⏳ READY_FOR_TEST | — | Requires live test |
| V-09 | Trigger: plan only | KIMI_PROTOCOL.md F; OPERATING_RULES.md | AI presents plan with criteria + pre-mortem + assumptions; awaits [APPROVED] | Send "plan only" + task; verify no execution until [APPROVED] | ⏳ READY_FOR_TEST | — | Requires live test |
| V-10 | Trigger: [APPROVED] | KIMI_PROTOCOL.md F; OPERATING_RULES.md | AI executes approved plan without re-planning | Send "plan only", then "[APPROVED]"; verify execution follows plan | ⏳ READY_FOR_TEST | — | Requires live test |
| V-11 | Trigger: audit mode | KIMI_PROTOCOL.md F; SESSION_RITUAL.md Ritual 7 | AI reviews last 3 responses against L1-L7; reports violations | Send "audit mode"; verify behavioral review output | ⏳ READY_FOR_TEST | — | Requires live test |
| V-12 | Trigger: /compact | KIMI_PROTOCOL.md F; SESSION_RITUAL.md Ritual 3 | AI writes COMPACT_STATE.md + RESUME.md; summarizes state | Trigger compact; verify files written and confirmation given | ⏳ READY_FOR_TEST | — | Requires live test |
| V-13 | Trigger: resume | KIMI_PROTOCOL.md F; SESSION_RITUAL.md Ritual 6 | AI reads RESUME.md + CONTEXT.md + ASSUMPTIONS.md; summarizes; confirms | Start new session, send "resume"; verify 4-file read and summary | ⏳ READY_FOR_TEST | — | Requires live test |
| V-14 | Trigger: save state | KIMI_PROTOCOL.md F; SESSION_RITUAL.md Ritual 5 | AI writes RESUME.md with current checkpoint | Send "save state"; verify RESUME.md written | ⏳ READY_FOR_TEST | — | Requires live test |
| V-15 | Response Contract | KIMI_PROTOCOL.md G.4; OPERATING_RULES.md | Every response has [CONTEXT][PHASE][EVIDENCE][OUTPUT][CHANGE_LOG][NEXT_STEP] | Send any task; verify 6-section structure in response | ⏳ READY_FOR_TEST | — | Requires live test |
| V-16 | Memory Read Order | memory/README.md; FILE_UPDATE_RULES.md | Session start reads README→RESUME→CONTEXT→ASSUMPTIONS | Start new session; verify read order in tool use or response | ⏳ READY_FOR_TEST | — | Requires live test |
| V-17 | Memory Write Order | memory/README.md; FILE_UPDATE_RULES.md | After action writes CONTEXT→ASSUMPTIONS→DECISIONS→RESUME→AUDIT_LOG | Complete task; verify write order in tool use | ⏳ READY_FOR_TEST | — | Requires live test |
| V-18 | Compact Survival | memory/README.md; SESSION_RITUAL.md Ritual 3-4 | Pre-compact: state written to files. Post-compact: state restored from files. | Run compact test (see COMPACT_TEST.md); verify no data loss | ⏳ READY_FOR_TEST | — | Requires live test |
| V-19 | Resume Survival | memory/README.md; SESSION_RITUAL.md Ritual 6 | New session restores exact state from previous session | Run resume test (see RESUME_TEST.md); verify continuity | ⏳ READY_FOR_TEST | — | Requires live test |
| V-20 | Assumption Registry | memory/ASSUMPTIONS.md; KIMI_PROTOCOL.md I.5 | Assumptions tracked with ID, confidence, impact, verification plan | Declare assumption during task; verify entry in ASSUMPTIONS.md | ⏳ READY_FOR_TEST | — | Requires live test |
| V-21 | Decision Log | memory/DECISIONS.md; KIMI_PROTOCOL.md I.4 | Decisions logged with context, reasoning, alternatives rejected | Make significant choice; verify entry in DECISIONS.md | ⏳ READY_FOR_TEST | — | Requires live test |
| V-22 | Audit Log Entry | memory/AUDIT_LOG.md; KIMI_PROTOCOL.md I.4 | Completed tasks logged with verification results and metrics | Complete task; verify entry in AUDIT_LOG.md | ⏳ READY_FOR_TEST | — | Requires live test |
| V-23 | Authority Hierarchy | memory/README.md | Higher authority file overrides lower in conflicts | Create artificial conflict; verify correct resolution | ⏳ READY_FOR_TEST | — | Requires live test |
| V-24 | Anti-Drift (Stale Assumptions) | memory/ASSUMPTIONS.md; KIMI_PROTOCOL.md I.9 | ACTIVE assumptions > 7 days flagged as STALE | Create old assumption; verify flag on next session | ⏳ READY_FOR_TEST | — | Requires live test |
| V-25 | Escalation Behavior | KIMI_PROTOCOL.md I.8; 01_ELITE_ROLE.md | Risk ≥ 13 → escalate; ≥ 19 → STOP; iteration > 3 → escalate | Trigger high-risk scenario; verify STOP/escalation | ⏳ READY_FOR_TEST | — | Requires live test |
| V-26 | Audit Mode with Threshold Check | SESSION_RITUAL.md Ritual 7; OPERATING_RULES.md | Audit mode checks file sizes against ROLLUP_POLICY.md | Send "audit mode"; verify threshold check in output | ⏳ READY_FOR_TEST | — | New v2.0 |
| V-27 | Bounded Memory (Active Files) | ROLLUP_POLICY.md; FILE_UPDATE_RULES.md | Active files never exceed thresholds; archives excluded from default read | Populate files beyond thresholds; verify rollup triggers | ⏳ READY_FOR_TEST | — | New v2.0 |
| V-28 | Rollup Correctness | ROLLUP_POLICY.md; SESSION_RITUAL.md Ritual 10 | Stale entries archived correctly; active layer remains bounded | Trigger rollup; verify archive content + active file size | ⏳ READY_FOR_TEST | — | New v2.0 |
| V-29 | Archive Exclusion | memory/README.md; FILE_UPDATE_RULES.md | Archive files never read during default session start | Start session with archives present; verify no archive reads | ⏳ READY_FOR_TEST | — | New v2.0 |
| V-30 | Recovery from Compact Omission | COMPACT_TEST.md Test 5; FILE_UPDATE_RULES.md | Missing compact state recovered from authoritative source | Simulate compact omission; verify recovery behavior | ⏳ READY_FOR_TEST | — | New v2.0 |

---

## Validation Status Summary

| Status | Count | Percentage |
|---|---|---|
| PASS | 0 | 0% |
| WEAK | 0 | 0% |
| FAIL | 0 | 0% |
| MISSING | 0 | 0% |
| **READY_FOR_TEST** | **30** | **100%** |

**Verdict:** System is **structurally complete but operationally untested**. All components are designed and documented. Live validation required before declaring operational readiness.

---

## Next Validation Round

1. Run TEST_SCENARIOS.md sequentially
2. Mark each V-ID as PASS/WEAK/FAIL/MISSING
3. Update this matrix with evidence
4. If any FAIL → fix protocol or system prompt, re-test
5. If all PASS → system declared operational
