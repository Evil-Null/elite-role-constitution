# CONTEXT.md — Active Task State

> **Role:** Current operational state only. Overwrite entirely each update.  
> **Read:** Session start, after `/compact`, when context unclear.  
> **Updated:** After every significant state change.  
> **Authority:** Operational (Rank 4).  
> **Max Size:** 60 lines.

---

## Current Task

**Goal:** Implement 3-phase context-guard hook + fix critical cwd bug + wire hooks into ~/.kimi/config.toml
**Status:** ✅ context-guard.sh (3-phase warn/stop/ack) DONE — ✅ pre-compact.sh auto-write DONE — ✅ cwd fix DONE — ✅ config.toml wired DONE
**Started:** 2026-05-21
**Updated:** 2026-05-21

## Progress

**Last:** 
- `context-guard.sh`: Phase 1 warn (exit 0), Phase 2 STOP (exit 2 if no fresh COMPACT_STATE.md < 5 min), Phase 3 compact handled by pre-compact.sh
- `pre-compact.sh`: Auto-writes COMPACT_STATE.md + emits elite recovery protocol to AI context
- CRITICAL BUG FIX: context-guard.sh now reads `cwd` from JSON payload (was hardcoded to repo root, breaking ritual ack in foreign work_dirs)
- `~/.kimi/config.toml`: 11 hooks wired, `hooks = []` removed, backup saved
- All 12 hook scripts syntax OK, generate.sh --check PASS, SYSTEM_INTEGRITY_CHECK 11/11 PASS

**Next:** Monitor CI after push; verify live behavior at 65%/67%/70% thresholds in real session
**Blocked By:** None.

## Validation Results (2026-05-21)

- 10-payload deep test: all critical hooks PASS
- context-guard Phase 3 STOP/ack: ✅ verified with real COMPACT_STATE.md mtime check
- pre-compact auto-write + recovery message: ✅ verified
- canon/derived sync (generate.sh --check): ✅ PASS
- shellcheck: N/A locally (not installed) — CI covers
- SYSTEM_INTEGRITY_CHECK: 11/11 PASS
- ~/.kimi/config.toml hooks: 11 blocks registered, no TOML conflict

## File State

| File | Lines | Threshold | Status |
|---|---|---|---|
| memory/README.md | 59 | 60 | ✅ |
| memory/RESUME.md | 31 | 40 | ✅ |
| memory/CONTEXT.md | this turn | 60 | overwriting |
| memory/ASSUMPTIONS.md | 44 | 50 | ✅ |
| memory/DECISIONS.md | 36 | 40 | updating |
| .kimi/hooks/*.sh | 12 scripts | — | ✅ syntax OK |
| canon/hooks.yaml | 11 hooks | — | ✅ sync |

## Blockers

None.
