# FILE_UPDATE_RULES — Read/Write Authority & Anti-Loss Protocol v2.0

> **Role:** Defines exactly when each file is read, written, and by whom. Prevents stale data, missed updates, and unbounded growth.  
> **Read:** When unsure about file operations.  
> **Updated:** When memory architecture changes.  
> **Authority:** Protocol (Rank 2)

---

## File Operation Matrix

| File | Read When | Write When | Who | Mode | Max Lines |
|---|---|---|---|---|---|
| `memory/README.md` | Every session start; after `/compact` | Memory architecture changes | AI or user | Overwrite | 60 |
| `memory/RESUME.md` | Every session start | Session end; pre-compact; "save state" | AI | Overwrite | 40 |
| `memory/CONTEXT.md` | Every session start; after `/compact` | After every significant state change | AI | Overwrite | 60 |
| `memory/ASSUMPTIONS.md` | Every session start; before executing on assumptions | Assumption declared/verified/falsified | AI | Overwrite active; append archive | 50 |
| `memory/DECISIONS.md` | When task involves previous choices | After significant choice | AI | Overwrite active; append archive | 40 |
| `memory/AUDIT_LOG.md` | When auditing recent work | After task completion | AI | Overwrite active (last 5); append archive | 50 |
| `memory/COMPACT_STATE.md` | After `/compact` only | During `/compact` ritual only | AI | Overwrite | 40 |
| `memory/ROLLUP_POLICY.md` | When rollup behavior questioned | Architecture changes | AI or user | Overwrite | N/A |
| `memory/archive/*.md` | Historical lookup only | During rollup | AI | Append | N/A |
| `OPERATING_RULES.md` | Refreshing discipline | Never (read-only) | User/AI | Read-only | N/A |
| `SESSION_RITUAL.md` | Ritual unclear | Never (read-only) | User/AI | Read-only | N/A |
| `KIMI_PROTOCOL.md` | Protocol behavior questioned | Never (read-only) | User/AI | Read-only | N/A |
| `01_ELITE_ROLE.md` | "challenge-grade" triggered | Never (read-only) | AI | Read-only | N/A |

---

## Write Rules (Mandatory)

### Rule 1: CONTEXT.md — Overwrite, Always Current

**Trigger:** Any significant state change.
**Format:** Overwrite entirely. Never append. Old state is irrelevant.
**Max:** 60 lines. If exceeded, summarize old completed work, keep only current task.

### Rule 2: RESUME.md — Overwrite, Checkpoint Only

**Trigger:** Session end, pre-compact, "save state".
**Format:** Overwrite entirely. Never append.
**Max:** 40 lines.

### Rule 3: ASSUMPTIONS.md — Active Layer, Archive Stale

**Trigger:** New assumption, verification, falsification, stale flag.
**Format:** Overwrite active section with ACTIVE assumptions only.
**Rollup:** If file > 50 lines or > 8 active assumptions, archive FALSIFIED/CONFIRMED/SUPERSEDED to `archive/assumptions_archive.md`.
**Anti-bloat:** Never keep inactive assumptions in active file.

### Rule 4: DECISIONS.md — Active Layer, Archive Old

**Trigger:** Significant choice, user override, superseded decision.
**Format:** Overwrite active section with ACTIVE + last 3 decisions.
**Rollup:** If file > 40 lines or > 6 decisions, archive SUPERSEDED/>30-day-old to `archive/decisions_archive.md`.

### Rule 5: AUDIT_LOG.md — Recent Only, Archive History

**Trigger:** Task complete + verification passed.
**Format:** Overwrite active section with last 5 entries + running statistics.
**Rollup:** If file > 50 lines or > 5 entries, archive older entries to `archive/audit_archive.md`. Update `archive/audit_index.md`.
**Never append directly to active file.**

### Rule 6: COMPACT_STATE.md — Temporary Only

**Trigger:** `/compact` command.
**Format:** Overwrite entirely. Temporary snapshot.
**After compact:** Read once, then rely on RESUME.md and CONTEXT.md.

### Rule 7: Archive Files — Append Only

**Trigger:** Rollup from active file.
**Format:** Append entries to appropriate archive. Never overwrite archive.
**Read:** Only when explicitly searching historical data.

---

## Read Rules (Mandatory)

### Rule 1: Default Session Start (Mandatory)

```
MUST READ (in order):
1. memory/README.md     (confirms structure)
2. memory/RESUME.md     (where we left off)
3. memory/CONTEXT.md    (current state)
4. memory/ASSUMPTIONS.md (active risks)
```

**Do NOT skip.** Even if user says "just do this quick thing," read RESUME.md and CONTEXT.md first.

### Rule 2: Conditional Read

```
READ IF:
• DECISIONS.md    → current task involves previous choices
• AUDIT_LOG.md    → user requests audit of recent work
• COMPACT_STATE.md → after `/compact`
• archive/*       → explicit historical lookup only
• ROLLUP_POLICY.md → rollup behavior questioned
```

### Rule 3: Pre-Read Size Check

Before reading any file:
- Check if file exceeds threshold per ROLLUP_POLICY.md
- If exceeded, trigger rollup BEFORE reading
- This prevents reading oversized files

### Rule 4: Freshness Check

Before relying on any memory file:
- Timestamp > 7 days old → treat with skepticism
- Timestamp > 30 days old → request user confirmation before acting
- File missing → create with initial template

---

## Anti-Duplication Strategy

| Information | Authoritative Source | Duplicates Allowed? |
|---|---|---|
| Current task state | `memory/CONTEXT.md` | NO |
| Session checkpoint | `memory/RESUME.md` | NO |
| Active assumptions | `memory/ASSUMPTIONS.md` | NO |
| Active decisions | `memory/DECISIONS.md` | NO |
| Recent audit entries | `memory/AUDIT_LOG.md` | NO |
| Historical assumptions | `memory/archive/assumptions_archive.md` | NO |
| Historical decisions | `memory/archive/decisions_archive.md` | NO |
| Historical audits | `memory/archive/audit_archive.md` | NO |
| Compact snapshot | `memory/COMPACT_STATE.md` | YES (overwrite) |

**If same ID found in active + archive:** Archive wins. Delete from active.

---

## Anti-Loss Checklist

Before every file write:

- [ ] Path correct (memory/ or memory/archive/)
- [ ] Content complete (no truncated entries)
- [ ] Status fields filled (ACTIVE, CONFIRMED, FALSIFIED, etc.)
- [ ] Timestamps present
- [ ] No sensitive data
- [ ] File size under threshold (trigger rollup if needed)

After every file write:

- [ ] Write succeeded (verify by reading back)
- [ ] No markdown syntax errors
- [ ] Related files updated
- [ ] Archive file updated if rollup occurred
