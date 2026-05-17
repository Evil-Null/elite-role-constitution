# FALLBACK_PROTOCOL — Tool-Less Mode

> **Role:** Degraded continuity when file I/O is unavailable.  
> **Read:** When WriteFile fails or tools are disabled.  
> **Updated:** When fallback mechanics change.  
> **Max Size:** 60 lines.

---

## Activation

AI detects tool unavailability when:
- WriteFile returns error or timeout
- ReadFile returns "tool not available"
- User says: "tools don't work"

**Declaration:** "FALLBACK MODE — reduced continuity, no persistence. L1-L7 still active."

## Protocol

| Normal | Fallback |
|---|---|
| Write COMPACT_STATE.md | User pastes compact state manually |
| Write RESUME.md | User copies/pastes checkpoint text |
| Read 4 memory files | User pastes relevant sections |
| Automatic rollup | Manual deletion of old entries |

## User-Assisted Compact

1. AI summarizes active state in response
2. User copies text to local file or note
3. After `/compact`, user pastes summary back
4. AI resumes from pasted context

## Recovery

When tools return:
1. AI declares: "Tools restored. Re-syncing from manual context."
2. User provides any saved state text
3. AI writes RESUME.md and COMPACT_STATE.md from context
4. Normal mode resumes

## Limitations

- No automatic threshold enforcement
- No archive rollup
- Historical lookup unavailable
- Session continuity depends on user copy/paste discipline
