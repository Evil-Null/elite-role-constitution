# DAILY_OPS — Quick Reference for Personal Use

> **Role:** Decision tree for mode selection. No rituals here — just speed.  
> **Read:** When unsure which mode to use.  
> **Updated:** When triggers change.  
> **Max Size:** 60 lines.

---

## Mode Decision Tree

| Task Type | Mode | Formalism | Time |
|---|---|---|---|
| "Fast question" / "quick check" | Light effort | L1-L7 only, no files, no risk score | <30s |
| Code review, bug fix | Standard | Plan + verify, CHANGE_LOG | 2-5min |
| New feature, architecture | Challenge-grade | Full doctrine, all lenses | 10-30min |
| End of day | Save state | Write RESUME.md, rollup if needed | 1min |
| Morning start | Resume | Read 4 files, confirm state | 1-2min |

## Morning Ritual

```
1. "resume"
2. Check ASSUMPTIONS.md for stale items (>7 days)
```

## End-of-Day Ritual

```
1. "save state"
2. "rollup memory" (if thresholds near)
3. "audit mode" (optional, 1x/week)
```

## Bypass Rules

- User says "quick" or "fast" → light effort automatically
- User says "just do it" → execute with override logged in DECISIONS.md
- User says "end session" → save state, confirm, stop
