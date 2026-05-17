# FILE_UPDATE_RULES — Read/Write Authority & Anti-Loss Protocol

> **Role:** Defines exactly when each file is read, written, and by whom. Prevents stale data and missed updates.  
> **Read:** When unsure about file operations.  
> **Updated:** Never. Read-only reference.  
> **Authority:** Protocol (Rank 2)

---

## File Operation Matrix

| File | Read When | Write When | Who | Must Never Store |
|---|---|---|---|---|
| `memory/README.md` | Every session start; after `/compact`; when memory structure unclear | When memory architecture changes | AI or user | Operational state (it's structural) |
| `memory/RESUME.md` | Every session start | Session end; context critical; user says "save state" | AI via tool | Outdated state (always overwrite) |
| `memory/CONTEXT.md` | Every session start; after `/compact` | After every significant action or state change | AI via tool | Duplicate of RESUME.md (must be distinct) |
| `memory/ASSUMPTIONS.md` | Every session start; before executing on assumptions | When assumption declared, verified, or falsified | AI via tool | Falsified assumptions without status (must mark FALSIFIED) |
| `memory/DECISIONS.md` | When current task involves previous choices | After significant choice | AI via tool | Unilateral decisions without user input (must note if user overrode) |
| `memory/COMPACT_STATE.md` | After `/compact` only | During `/compact` ritual only | AI via tool | Long-term state (temporary, recovery-only) |
| `memory/AUDIT_LOG.md` | When auditing; when drift suspected | After task completion | AI via tool | Incomplete tasks (only completed entries) |
| `OPERATING_RULES.md` | When refreshing discipline | Never (read-only) | User/AI | Temporary rules (must be constitutional) |
| `SESSION_RITUAL.md` | When ritual unclear | Never (read-only) | User/AI | Situational exceptions (must be universal) |
| `KIMI_PROTOCOL.md` | When protocol behavior questioned | Never (read-only reference) | User/AI | Implementation hacks (must be protocol-grade) |
| `01_ELITE_ROLE.md` | When "challenge-grade" triggered | Never (read-only) | AI via tool | Edits (authoritative reference) |

---

## Write Rules (Mandatory)

### Rule 1: CONTEXT.md After Every Significant Action

**Significant action includes:**
- Task started or completed
- Decision made
- Assumption declared
- File created/modified/deleted
- Blocker discovered or resolved
- Risk score changed

**Format:** Append or overwrite with current state. Never leave stale.

### Rule 2: RESUME.md Before Session End

**Trigger conditions:**
- User says "end session"
- Context usage ≥ 90%
- User says "save state"

**Format:** Overwrite entirely. Never append. Old state is irrelevant.

### Rule 3: ASSUMPTIONS.md When Risk Changes

**Trigger conditions:**
- New assumption declared
- Assumption verified (confirmed or falsified)
- Assumption becomes stale (> 7 days)
- Risk score recalculated

**Format:** Update existing entry or append new. Mark old status clearly.

### Rule 4: DECISIONS.md After Choice

**Trigger conditions:**
- Significant choice made (affects scope, approach, or acceptance criteria)
- User overrides AI recommendation
- Previous decision superseded

**Format:** Append new entry. Mark old entry SUPERSEDED if applicable.

### Rule 5: COMPACT_STATE.md During Compact Only

**Trigger:** `/compact` command
**Format:** Overwrite entirely. Temporary snapshot.
**After compact:** Read once, then rely on RESUME.md and CONTEXT.md.

### Rule 6: AUDIT_LOG.md After Completion Only

**Trigger:** Task complete + verification passed
**Format:** Append entry. Never overwrite.
**Incomplete tasks:** Do NOT log. Wait for completion.

---

## Read Rules (Mandatory)

### Rule 1: Session Start Mandatory Read

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
• AUDIT_LOG.md    → user requests audit or drift check
• COMPACT_STATE.md → after `/compact`
• KIMI_PROTOCOL.md → protocol behavior questioned
• 01_ELITE_ROLE.md → user triggers "challenge-grade"
```

### Rule 3: Freshness Check

Before relying on any memory file:
- Check timestamp. If > 7 days old → treat with skepticism
- If > 30 days old → request user confirmation before acting
- If file missing → create with initial template

---

## Anti-Duplication Strategy

| Information | Authoritative Source | Duplicates Allowed? |
|---|---|---|
| Current task state | `memory/CONTEXT.md` | NO (RESUME.md summarizes, doesn't duplicate details) |
| Session checkpoint | `memory/RESUME.md` | NO (overwrite entirely) |
| Assumptions | `memory/ASSUMPTIONS.md` | NO (single registry) |
| Decisions | `memory/DECISIONS.md` | NO (append-only, no duplicates) |
| Completed tasks | `memory/AUDIT_LOG.md` | NO (append-only) |
| Compact snapshot | `memory/COMPACT_STATE.md` | YES (overwrite, temporary) |

**If same information found in two files:**
1. Check authority hierarchy (README.md > CONTEXT.md > RESUME.md)
2. Check timestamps (newer wins)
3. If conflict unresolved → ask user

---

## Anti-Loss Checklist

Before every file write, confirm:

- [ ] File path is correct (memory/ not root/)
- [ ] Content is complete (no truncated entries)
- [ ] Status fields are filled (ACTIVE, CONFIRMED, FALSIFIED, etc.)
- [ ] Timestamps are present
- [ ] No sensitive data (passwords, keys, tokens)
- [ ] No hallucinated references (files that don't exist)

After every file write, confirm:

- [ ] Write succeeded (verify by reading back if possible)
- [ ] No syntax errors in markdown
- [ ] Related files updated (e.g., CONTEXT.md updated when ASSUMPTIONS.md changes)
