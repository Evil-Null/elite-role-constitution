# Memory System — Root Navigation & Authority Map

> **Role:** Root memory layer. Single source of truth for file hierarchy, read order, and authority levels.  
> **Read:** At every session start, after `/compact`, and when memory structure is unclear.  
> **Updated:** Only when the memory system architecture itself changes.  
> **Standard:** Challenge-Grade, Compact-Safe, Drift-Resistant

---

## File Authority Hierarchy

Files are ranked by authority. Higher authority overrides lower authority in conflicts.

| Rank | File | Authority Level | Why |
|---|---|---|---|
| 1 | `memory/README.md` | **Structural** | Defines the system itself. Only changed when memory architecture changes. |
| 2 | `KIMI_PROTOCOL.md` | **Constitutional** | The collaboration protocol. Source of truth for behavior. |
| 3 | `01_ELITE_ROLE.md` | **Doctrinal** | Full challenge-grade constitution. Authoritative reference. |
| 4 | `memory/CONTEXT.md` | **Operational** | Current task state. Most frequently updated. |
| 5 | `memory/RESUME.md` | **Checkpoint** | Session break state. Bridges sessions. |
| 6 | `memory/ASSUMPTIONS.md` | **Risk** | Tracked assumptions. Decisions depend on this. |
| 7 | `memory/DECISIONS.md` | **Historical** | Past choices. Reference, not override. |
| 8 | `memory/COMPACT_STATE.md` | **Recovery** | Post-compact snapshot. Temporary authority. |
| 9 | `memory/AUDIT_LOG.md` | **Archive** | Completed tasks. Read-only for operational decisions. |

**Conflict Resolution Rule:** If two files disagree, higher authority wins. If same authority, newer timestamp wins. If timestamp unclear, escalate to user.

---

## Read Order (Mandatory)

At **every session start** or **after `/compact`**, read files in this exact order:

```
READ ORDER:
1. memory/README.md     (you are reading it now — confirms structure)
2. memory/RESUME.md     (where we left off — critical for continuity)
3. memory/CONTEXT.md    (current task state — what we are doing now)
4. memory/ASSUMPTIONS.md (active risks — what could go wrong)
```

**Do NOT proceed with task execution until all 4 files are read and summarized.**

---

## Read Order (Conditional)

Read these **only when relevant**:

```
CONDITIONAL READS:
• memory/DECISIONS.md     → When current task involves previous choices
• memory/AUDIT_LOG.md     → When auditing past work or detecting drift
• memory/COMPACT_STATE.md → After `/compact` to verify continuity
• KIMI_PROTOCOL.md        → When protocol behavior is questioned
• 01_ELITE_ROLE.md        → When user triggers "challenge-grade" or "deep mode"
```

---

## Write Order (After Significant Actions)

When updating memory, write in this order to maintain consistency:

```
WRITE ORDER:
1. memory/CONTEXT.md      (always — current state)
2. memory/ASSUMPTIONS.md  (if assumptions declared or verified)
3. memory/DECISIONS.md    (if significant choice made)
4. memory/RESUME.md       (if session ending or context critical)
5. memory/AUDIT_LOG.md    (if task completed)
```

---

## Mandatory vs Conditional Files

| File | Mandatory Read | Mandatory Write | Condition |
|---|---|---|---|
| `memory/README.md` | Every session start | Never (structural) | Always read first |
| `memory/RESUME.md` | Every session start | Session end / context critical | Always |
| `memory/CONTEXT.md` | Every session start | After every significant action | Always |
| `memory/ASSUMPTIONS.md` | Every session start | When assumption changes | Always |
| `memory/DECISIONS.md` | When relevant | After significant choice | Conditional |
| `memory/COMPACT_STATE.md` | After `/compact` | After `/compact` | Conditional |
| `memory/AUDIT_LOG.md` | When auditing | After task completion | Conditional |

---

## Compact-Safe Guarantees

`/compact` compresses conversation history but **must never compress memory files**.

**Pre-Compact Ritual:**
1. Write `memory/COMPACT_STATE.md` with active state summary
2. Verify `memory/RESUME.md` is current
3. Verify `memory/CONTEXT.md` is current
4. Confirm: "Compact-safe. Critical state persisted to memory files."

**Post-Compact Ritual:**
1. Read `memory/COMPACT_STATE.md`
2. Read `memory/RESUME.md`
3. Read `memory/CONTEXT.md`
4. Confirm: "State rehydrated. Active task: [summary]. Next step: [step]."

**What Must Survive Compact:**
- Current task goal and scope
- Last completed step
- Next pending step
- Active assumptions (with IDs)
- Active decisions
- Risk items (score ≥ 7)
- Modified files list

**What May Be Lost (acceptable):**
- Detailed conversation history
- Intermediate reasoning steps
- Old verification results
- Superseded assumptions

---

## Anti-Drift Controls

| Check | Method | Frequency |
|---|---|---|
| Forgotten task | RESUME.md + CONTEXT.md read at start | Every session |
| Stale assumption | ASSUMPTIONS.md timestamp check | Every session |
| Conflicting decision | DECISIONS.md search for related topics | When relevant |
| Resume mismatch | Compare RESUME.md summary vs user description | Every resume |
| Compact omission | COMPACT_STATE.md completeness check | After every compact |
| File freshness | Timestamp validation (all memory files < 30 days) | Every session |
| Authority conflict | Check hierarchy when files disagree | On demand |

---

## Quick Reference

```
SESSION START:
  READ:  memory/README.md → RESUME.md → CONTEXT.md → ASSUMPTIONS.md
  THEN:  Confirm understanding with user

SESSION END:
  WRITE: CONTEXT.md → RESUME.md (full checkpoint)

/COMPACT:
  WRITE: COMPACT_STATE.md → RESUME.md
  READ:  COMPACT_STATE.md → RESUME.md → CONTEXT.md (after compact)

TASK COMPLETE:
  WRITE: CONTEXT.md → ASSUMPTIONS.md → DECISIONS.md → AUDIT_LOG.md
```
