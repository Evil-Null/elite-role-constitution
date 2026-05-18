---
name: save-state
description: |
  Explicit "save state" ritual — writes the current task, active
  assumptions, recent decisions, and checkpoint to the memory files
  so the next session can pick up. Invoke with `/flow:save-state`
  or by typing the user phrase `save state`. Also runs implicitly
  via the SessionEnd hook.
type: flow
tags: [memory, continuity, session, save-state]
---

# Save-State — Flow

This flow makes explicit the "memory autosave" ritual described in
`SESSION_RITUAL.md`. The flow updates each active memory file
deterministically; the `SessionEnd` hook covers the case where the
user forgets to invoke it.

```mermaid
flowchart TD
    A([BEGIN]) --> B[Read memory/README.md to confirm the Authority Hierarchy and Default Read Order are still current.]
    B --> C[Update memory/CONTEXT.md - Overwrite the active task, progress percentage, active registry of files in scope, and current blockers. Max 60 lines.]
    C --> D[Update memory/RESUME.md - Overwrite with a concise checkpoint - what was just completed, what is next, what the next session must read first. Max 40 lines.]
    D --> E{Were any assumptions declared or falsified this session?}
    E -->|Yes| F[Append to memory/ASSUMPTIONS.md - active section. Rotate to archive if file would exceed 50 lines per ROLLUP_POLICY.md.]
    E -->|No| G[Skip ASSUMPTIONS.md.]
    F --> H{Were any significant decisions made?}
    G --> H
    H -->|Yes| I[Append to memory/DECISIONS.md with justification. Rotate to archive if file would exceed 40 lines.]
    H -->|No| J[Skip DECISIONS.md.]
    I --> K{Did this session complete one or more discrete tasks?}
    J --> K
    K -->|Yes| L[Append to memory/AUDIT_LOG.md in the E<N> format. Rotate if would exceed 50 lines.]
    K -->|No| M[Skip AUDIT_LOG.md.]
    L --> N[Run bash SYSTEM_INTEGRITY_CHECK.sh and confirm 10/10 PASS. If any check failed, surface the failure to the user before declaring save complete.]
    M --> N
    N --> O[Report - one line per file actually updated, with new size vs cap. Do not announce skipped files.]
    O --> P([END])
```

## When this flow fires

- User types `save state`
- User invokes `/flow:save-state`
- Pre-compact ritual (SESSION_RITUAL.md Ritual 3) reaches its
  save step
- Detected risk that the session may end soon (e.g., long-running
  task at >= 80% completion and user has not interacted in a while)

## Why threshold compliance is mandatory

Every memory file has a self-declared `Max Size: N lines`. Writing
past the cap without rotating violates the file's own contract.
`SYSTEM_INTEGRITY_CHECK.sh` checks #3 and #10 enforce this; the
save-state flow must respect the same constraints.

## Side effects out of scope

- This flow does NOT touch the agent's session id or `--session`
  semantics. Kimi CLI 1.43+ handles those natively.
- This flow does NOT trigger `/compact`. That is a separate user
  decision; the pre-compact ritual is its own flow if one is
  written later.
