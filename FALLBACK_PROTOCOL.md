# FALLBACK_PROTOCOL — Tool-Less Resilient Mode

> **Role:** Degraded continuity when file I/O is unavailable.  
> **Read:** When WriteFile fails or tools are disabled.  
> **Updated:** v2.4  
> **Max Size:** 80 lines.

---

## Activation

AI detects tool unavailability when:
- WriteFile returns error or timeout
- ReadFile returns "tool not available"
- User says: "tools don't work"

**Declaration:** "FALLBACK MODE — degraded continuity, no persistence. L1-L7 still binding."

---

## Protocol

| Normal | Fallback |
|---|---|
| Write COMPACT_STATE.md | AI outputs [FALLBACK_CHECKPOINT] in response |
| Write RESUME.md | AI outputs checkpoint at session end |
| Read 4 memory files | User pastes relevant sections; AI tracks mentally |
| Automatic rollup | AI enforces 80-line response budget; self-compact at msg 10 |

---

## AI Response Budget

- **Max 80 lines per response** in fallback mode.
- AI mentally tracks cumulative response lines.
- At ~500 total lines: declare "COMPACT REQUIRED" and output [FALLBACK_CHECKPOINT].

---

## Self-Compact Ritual (Every 10th Message)

1. Summarize last 9 exchanges into 3 lines.
2. Output: `[FALLBACK_COMPACT] 3-line summary`
3. Reset mental line counter.

---

## Session Summary Protocol

At session end, output:

```
[FALLBACK_CHECKPOINT]
Active Task: [summary]
Assumptions: [A1, A2...]
Decisions: [D1...]
Drift Check: [violations if any]
Next Step: [explicit]
```

---

## L1-L7 Persistence (Still Binding)

L1. UNKNOWN = STOP  
L2. EVIDENCE-FIRST (cite sources verbally; no fabricated paths)  
L3. 6-LENS REVIEW (mental; evidence per lens declared in response)  
L4. PEV LOOP (max 3 iterations; max 2 exploration)  
L5. QUANTIFIED RISK (P×I; ≥13 escalate; ≥19 STOP)  
L6. ANTI-SELF-DECEPTION (3 ways wrong; declared in response)  
L7. ABSOLUTE CONTRACT (never fabricate, skip plan, auto-approve, batch unrelated)

---

## Recovery Ritual

When tools return:
1. AI declares: "Tools restored. Re-syncing from manual context."
2. User provides any saved [FALLBACK_CHECKPOINT] text.
3. AI writes RESUME.md and COMPACT_STATE.md from context.
4. Normal mode resumes.

---

## Honest Caveat

**Fallback is DEGRADED, not equal to normal mode.**
- No automatic threshold enforcement.
- No archive rollup.
- Historical lookup unavailable.
- Session continuity depends on user copy/paste discipline.
- 80-line budget and self-compact are SIMULATED bounds, not file-enforced.
