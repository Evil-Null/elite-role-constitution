# Memory System — Authority Map

> **Role:** Root navigation. Defines hierarchy, read order, and active/archive split.  
> **Read:** Session start, after `/compact`.  
> **Updated:** Only when memory architecture changes.  
> **Max Size:** 60 lines.

---

## Authority Hierarchy

| Rank | File | Authority | Load Mode |
|---|---|---|---|
| 1 | `README.md` | Structural | Mandatory |
| 2 | `KIMI_PROTOCOL.md` | Constitutional | Conditional |
| 3 | `01_ELITE_ROLE.md` | Doctrinal | Conditional |
| 4 | `CONTEXT.md` | Operational | Mandatory |
| 5 | `RESUME.md` | Checkpoint | Mandatory |
| 6 | `ASSUMPTIONS.md` | Risk (active) | Mandatory |
| 7 | `DECISIONS.md` | Historical (active) | Conditional |
| 8 | `COMPACT_STATE.md` | Recovery | Conditional |
| 9 | `AUDIT_LOG.md` | Audit (recent) | Conditional |
| 10 | `archive/*` | Archive | Never default |
| 11 | `ROLLUP_POLICY.md` | Governance | Never default |

**Conflict:** Higher rank wins. Same rank → newer timestamp wins. Unclear → escalate to user.

---

## Default Read Order

```
1. README.md     → structure
2. RESUME.md     → checkpoint
3. CONTEXT.md    → current task
4. ASSUMPTIONS.md → active risks
```

**Do NOT proceed until all 4 are read and summarized.**

## Conditional Reads

- `DECISIONS.md` → task involves previous choices
- `AUDIT_LOG.md` → auditing recent work
- `COMPACT_STATE.md` → after `/compact`
- `archive/*` → historical lookup only
- `ROLLUP_POLICY.md` → when rollup behavior questioned

## Write Order (After Actions)

```
1. CONTEXT.md      → always
2. ASSUMPTIONS.md  → if assumptions changed
3. DECISIONS.md    → if choice made
4. RESUME.md       → session end / critical
5. AUDIT_LOG.md    → task completed
```

## Bounded Memory Guarantee
Active files are capped per `ROLLUP_POLICY.md`. Archives excluded from default reads. After 10,000 tasks, session start still reads ≤300 lines.
