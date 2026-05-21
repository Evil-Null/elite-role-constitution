# assumptions_archive.md — Historical Assumptions

> **Role:** Archive for assumptions no longer active (FALSIFIED, CONFIRMED, SUPERSEDED).  
> **Read:** Only when searching historical assumptions or reconstructing decision rationale.  
> **Updated:** During rollup when active ASSUMPTIONS.md exceeds threshold.  
> **Authority:** Archive (Rank 10) — reference only.

---

## Archived Assumptions

```
A6: Kimi CLI supports project-level .kimi/ config directory
  Declared: 2026-05-10T04:00+04:00  Status: CONFIRMED  Score: P1×I3=3
  Verified: YES — tested on 2026-05-12

A7: GitHub CLI (gh) is installed and authenticated
  Declared: 2026-05-10T04:00+04:00  Status: CONFIRMED  Score: P1×I4=4
  Verified: YES — gh auth status confirmed

A8: Repository should use conventional commits format
  Declared: 2026-05-10T04:00+04:00  Status: SUPERSEDED  Score: P2×I2=4
  Superseded by D2 on 2026-05-11: user prefers descriptive commits over conventional format

A9: Context window is 64K tokens
  Declared: 2026-05-10T04:00+04:00  Status: FALSIFIED  Score: P3×I4=12
  Verified: NO — actual context is ~128K tokens per Kimi documentation

A10: Markdown files should be linted with markdownlint
  Declared: 2026-05-10T04:00+04:00  Status: CONFIRMED  Score: P2×I2=4
  Verified: YES — markdownlint installed and configured

A11: System prompt should be under 500 tokens
  Declared: 2026-05-10T04:00+04:00  Status: FALSIFIED  Score: P3×I5=15
  Verified: NO — minimal prompt with L1-L7 + response contract is ~650 tokens

A12: Memory files should use YAML frontmatter
  Declared: 2026-05-10T04:00+04:00  Status: SUPERSEDED  Score: P2×I3=6
  Superseded by D1 on 2026-05-11: plain markdown is simpler and more readable

A13: OAuth 2.0 is the authentication standard for this project
  Declared: 2026-05-11T04:00+04:00  Status: FALSIFIED  Score: P4×I4=16
  Verified: NO — project uses token-based auth, not OAuth

A14: Validation tests can be automated with shell scripts
  Declared: 2026-05-11T04:00+04:00  Status: FALSIFIED  Score: P3×I4=12
  Verified: NO — Kimi CLI requires manual interaction; no API for automated testing

A15: Archive files should be JSON, not markdown
  Declared: 2026-05-11T04:00+04:00  Status: SUPERSEDED  Score: P2×I3=6
  Superseded by D3 on 2026-05-12: markdown maintains consistency with rest of system

A16: All decisions require user approval
  Declared: 2026-05-11T04:00+04:00  Status: SUPERSEDED  Score: P2×I4=8
  Superseded by D4 on 2026-05-12: routine decisions (file naming, formatting) do not require approval

A17: System should auto-detect context usage and self-trigger compact
  Declared: 2026-05-11T04:00+04:00  Status: FALSIFIED  Score: P4×I5=20
  Verified: NO — Kimi CLI does not expose context usage metrics to AI

A18: 6-Lens Review should be mandatory for every response
  Declared: 2026-05-11T04:00+04:00  Status: SUPERSEDED  Score: P3×I4=12
  Superseded by protocol v2.0: 6-Lens is mandatory for deliverables, optional for routine questions

A19: Risk scoring should use 1-10 scale
  Declared: 2026-05-11T04:00+04:00  Status: FALSIFIED  Score: P2×I3=6
  Verified: NO — protocol specifies P(1-5) × I(1-5) = 1-25 scale

A20: Memory system should use single flat directory
  Declared: 2026-05-12T04:00+04:00  Status: SUPERSEDED  Score: P2×I3=6
  Superseded by D4 on 2026-05-17: active/archive split required for bounded memory

A21: COMPACT_STATE.md should be append-only
  Declared: 2026-05-12T04:00+04:00  Status: FALSIFIED  Score: P3×I4=12
  Verified: NO — COMPACT_STATE.md is temporary overwrite-only per FILE_UPDATE_RULES.md

A22: Response contract should include [REASONING] section
  Declared: 2026-05-12T04:00+04:00  Status: SUPERSEDED  Score: P2×I2=4
  Superseded by protocol v2.0: 6-section contract (CONTEXT, PHASE, EVIDENCE, OUTPUT, CHANGE_LOG, NEXT_STEP)

A23: All files should be committed after every turn
  Declared: 2026-05-12T04:00+04:00  Status: FALSIFIED  Score: P3×I4=12
  Verified: NO — excessive commits create noise; commit at session end or significant milestone

A24: Plan-gate should require 5 acceptance criteria
  Declared: 2026-05-12T04:00+04:00  Status: SUPERSEDED  Score: P2×I3=6
  Superseded by protocol v2.0: minimum 3 criteria, not 5

A25: Rollup should happen automatically every 24 hours
  Declared: 2026-05-13T04:00+04:00  Status: FALSIFIED  Score: P3×I3=9
  Verified: NO — rollup is threshold-driven, not time-driven

A1: Kimi CLI supports static system prompt loading via manual paste or project config
  Declared: 2026-05-17T04:00+04:00  Status: CONFIRMED  Score: P2×I5=10
  Verified: YES — confirmed in SYSTEM_PROMPT_INSTALL.md Step 2

A2: Tool use (read/write files) is available in Kimi CLI for memory file operations
  Declared: 2026-05-17T04:00+04:00  Status: FALSIFIED  Score: P2×I5=10
  Verified: NO — tool use confirmed available, but this was test assumption for S17

A9: Threshold detection logic triggers before write, not after
  Declared: 2026-05-17T11:35+04:00  Status: CONFIRMED  Score: P2×I4=8
  Verified: YES — FILE_UPDATE_RULES.md Rule 6 and ROLLUP_POLICY.md Section 4 enforce pre-write check

A10: COMPACT_STATE.md recovery reads authoritative source on mismatch
  Declared: 2026-05-17T11:35+04:00  Status: CONFIRMED  Score: P3×I4=12
  Verified: YES — COMPACT_TEST.md Test 5 and ROLLUP_POLICY.md Recovery Rules confirm

A11: Rollup policy correctly identifies stale entries by status and age
  Declared: 2026-05-17T11:35+04:00  Status: FALSIFIED  Score: P2×I3=6
  Verified: NO — policy identifies by status but age >30 days also required; gap found in testing

A3: User will run validation tests before declaring system operational
  Declared: 2026-05-17T04:00+04:00  Status: ACTIVE→ARCHIVED  Score: P3×I4=12
  Archived: 2026-05-17T11:35+04:00 — aged out during S20 write-guard rollup

A4: Context window (~128K tokens) is sufficient for system prompt + task execution
  Declared: 2026-05-17T04:00+04:00  Status: ACTIVE→ARCHIVED  Score: P3×I4=12
  Archived: 2026-05-17T11:35+04:00 — aged out during S20 write-guard rollup
```

## Archive Metadata

- **Created:** 2026-05-17
- **Last Rollup:** 2026-05-17T11:35+04:00
- **Total Archived:** 27
- **Source File:** memory/ASSUMPTIONS.md

A5: Memory file read/write latency is acceptable for turn-by-turn workflow
  Declared: 2026-05-17T04:00+04:00  Status: CONFIRMED  Score: P2×I3=6
  Verified: YES — 4+ days of active use, no latency issues observed

A6: Challenge-grade response will fit within context window with system prompt loaded
  Declared: 2026-05-17T11:35+04:00  Status: CONFIRMED  Score: P3×I3=9
  Verified: YES — challenge-grade audits completed without truncation

A7: User has permission to create/edit files in working directory
  Declared: 2026-05-17T11:35+04:00  Status: CONFIRMED  Score: P2×I4=8
  Verified: YES — continuous file I/O across all sessions without permission errors

A8: Archive files maintain append-only integrity across rollups
  Declared: 2026-05-17T11:35+04:00  Status: CONFIRMED  Score: P2×I3=6
  Verified: YES — multiple rollups executed, archive append-only preserved
