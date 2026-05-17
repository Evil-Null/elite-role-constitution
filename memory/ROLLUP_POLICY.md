# ROLLUP_POLICY.md — Bounded Memory Governance

> **Role:** Defines thresholds, triggers, and mechanics for keeping the operational memory layer bounded.  
> **Read:** Once per architecture change, or when rollup behavior is questioned.  
> **Updated:** Only when threshold rules change.  
> **Authority:** Governance — governed by memory/README.md (structural authority).

---

## Core Axiom

**The active read path must remain small and deterministic regardless of project history.**

After 1 task or 10,000 tasks, the default session-start read surface must not exceed ~300 lines total.

---

## Active Layer Boundaries

| File | Max Lines | Max Items | What Happens at Threshold |
|---|---|---|---|
| `memory/ASSUMPTIONS.md` | 50 | 8 active assumptions | Archive FALSIFIED/CONFIRMED/SUPERSEDED to `archive/assumptions_archive.md` |
| `memory/DECISIONS.md` | 40 | 6 decisions | Archive SUPERSEDED/>30-day-old to `archive/decisions_archive.md` |
| `memory/AUDIT_LOG.md` | 50 | 5 entries | Archive older entries to `archive/audit_archive.md`; update `archive/audit_index.md` |
| `memory/README.md` | 60 | N/A | Restructure to remove examples/verbosity; keep authority map + read order only |
| `memory/CONTEXT.md` | 60 | N/A | Summarize old completed work; keep current task only |
| `memory/RESUME.md` | 40 | N/A | Overwrite entirely; never append |
| `memory/COMPACT_STATE.md` | 40 | N/A | Overwrite entirely; temporary only |
| `memory/STRESS_LOG_DAY_*.md` | 60 | N/A | Overwrite entirely; one per stress test day |

**Total active read surface target: ≤300 lines.**

---

## Archive Layer Rules

| Archive File | Load Mode | Read Condition | Write Mode |
|---|---|---|---|
| `archive/assumptions_archive.md` | Conditional | When searching historical assumptions | Append |
| `archive/decisions_archive.md` | Conditional | When searching historical decisions | Append |
| `archive/audit_archive.md` | Conditional | When auditing old tasks or trend analysis | Append |
| `archive/audit_index.md` | Conditional | When looking up specific entry without reading full archive | Overwrite index |

**Archive files are NEVER read during default session start or post-compact recovery.**

---

## Rollup Triggers

### Automatic Triggers (Mandatory Checks)

1. **Pre-Compact Ritual** — Before writing COMPACT_STATE.md, check all active files against thresholds. Roll up if exceeded.
2. **End-Session Ritual** — Before writing final RESUME.md, check all active files. Roll up if exceeded.
3. **Pre-Read Size Check** — Before reading any active file, if file exceeds its threshold, trigger rollup first.

### Manual Triggers

- User says: `rollup memory`, `archive stale entries`
- AI detects file size violation during normal operation

### Rollup Action Sequence

```
STEP 1: Identify entries to archive (status = FALSIFIED/CONFIRMED/SUPERSEDED, or age > 30 days)
STEP 2: Append identified entries to appropriate archive file
STEP 3: Remove archived entries from active file
STEP 4: Add "Archive Reference" line to active file with count and link
STEP 5: Update audit_index.md if audit entries moved
STEP 6: Verify active file is now under threshold
STEP 7: Log rollup event in CONTEXT.md [CHANGE_LOG]
```

---

## Recovery Rules

### If Archive Needed During Operation

When a task requires historical context:
1. Read active file first (fast, bounded)
2. If entry not found, read archive file (conditional, larger)
3. If still not found, report: "Historical entry not in archive. May be lost or pre-dates archival system."

### If Active File Corrupted or Missing

1. Check COMPACT_STATE.md for last known good snapshot
2. Check RESUME.md for checkpoint summary
3. If both insufficient, read archive for relevant historical entries
4. Rebuild active file from archive + current task knowledge
5. Log recovery event in CONTEXT.md

### If Archive File Missing

1. Active layer is still authoritative for current work
2. Historical continuity is degraded but not blocked
3. Report to user: "Archive file [name] missing. Historical lookup unavailable. Current work unaffected."
4. Create empty archive file with header to prevent future errors

---

## Anti-Duplication Guarantee

An entry must NEVER exist in both active and archive simultaneously.

- After rollup: active contains only ACTIVE/current entries
- Archive contains only historical entries
- If both contain same ID → archive wins (it was archived first, active is stale copy)
- Resolution: delete from active, keep in archive

---

## Threshold Enforcement

**No file may exceed its threshold for more than one turn.**

If a write would cause a file to exceed its threshold:
1. Rollup BEFORE writing
2. Then write to now-bounded active file
3. This prevents any single turn from creating an oversized file

---

## Version

**Policy Version:** 2.0  
**Effective:** 2026-05-17  
**Governed By:** memory/README.md (structural authority)
