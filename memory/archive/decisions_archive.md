# decisions_archive.md — Historical Decisions

> **Role:** Archive for decisions that are SUPERSEDED or > 30 days old.  
> **Read:** Only when searching historical decisions or reconstructing rationale.  
> **Updated:** During rollup when active DECISIONS.md exceeds threshold.  
> **Authority:** Archive (Rank 10) — reference only.

---

## Archived Decisions

```
D5: Use YAML frontmatter for all memory files
  Date: 2026-05-10T04:00+04:00
  Status: SUPERSEDED
  Context: Initial design assumed structured metadata was needed
  Decision: Use YAML frontmatter in all memory files
  Reasoning: YAML enables programmatic parsing
  Alternatives Rejected: Plain markdown (later chosen)
  Risk Accepted: Added complexity for human readability
  Related Assumptions: A12

D6: Adopt conventional commits format
  Date: 2026-05-10T04:00+04:00
  Status: SUPERSEDED
  Context: Standardizing commit messages
  Decision: Use conventional commits (feat:, fix:, docs:, etc.)
  Reasoning: Industry standard, enables changelog generation
  Alternatives Rejected: Descriptive free-form commits
  Risk Accepted: Steeper learning curve
  Related Assumptions: A8

D7: Implement 6-Lens Review for every response
  Date: 2026-05-11T04:00+04:00
  Status: SUPERSEDED
  Context: Ensuring maximum quality on all output
  Decision: 6-Lens Review mandatory for every single response
  Reasoning: Prevents any quality slip
  Alternatives Rejected: Lens review only for deliverables
  Risk Accepted: Excessive latency on routine questions; user fatigue
  Related Assumptions: A18

D8: Use OAuth 2.0 for all authentication
  Date: 2026-05-11T04:00+04:00
  Status: SUPERSEDED
  Context: Designing auth module for API integration
  Decision: Implement OAuth 2.0 flow
  Reasoning: Modern standard, supports third-party integrations
  Alternatives Rejected: Token-based auth (later chosen)
  Risk Accepted: Complexity of OAuth flow
  Related Assumptions: A13

D9: Store memory in JSON format
  Date: 2026-05-11T04:00+04:00
  Status: SUPERSEDED
  Context: Considering structured storage for memory
  Decision: Use JSON for archive files
  Reasoning: Machine-readable, schema-validatable
  Alternatives Rejected: Markdown (later chosen)
  Risk Accepted: Reduced human readability
  Related Assumptions: A15

D10: Auto-commit after every turn
  Date: 2026-05-12T04:00+04:00
  Status: SUPERSEDED
  Context: Ensuring no work is lost
  Decision: Git commit after every AI response
  Reasoning: Maximum durability
  Alternatives Rejected: Commit at session end or milestones
  Risk Accepted: Repository noise, excessive commit history
  Related Assumptions: A23

D11: Use 1-10 risk scale
  Date: 2026-05-12T04:00+04:00
  Status: SUPERSEDED
  Context: Simpler risk scoring
  Decision: P(1-5) × I(1-5) but display as 1-10
  Reasoning: Easier for users to understand
  Alternatives Rejected: Full 1-25 scale
  Risk Accepted: Loss of granularity at high end
  Related Assumptions: A19

D12: Single flat memory directory
  Date: 2026-05-12T04:00+04:00
  Status: SUPERSEDED
  Context: Simplest possible structure
  Decision: All memory files in one directory
  Reasoning: Minimal complexity
  Alternatives Rejected: Active/archive split (later chosen)
  Risk Accepted: Unbounded growth, no separation of concerns
  Related Assumptions: A20

D13: Append-only AUDIT_LOG.md
  Date: 2026-05-13T04:00+04:00
  Status: SUPERSEDED
  Context: Preserving complete history
  Decision: Never archive or delete audit entries
  Reasoning: Complete audit trail
  Alternatives Rejected: Bounded audit log with archive
  Risk Accepted: File grows without bound, eventually unreadable
  Related Assumptions: A21

D14: Require 5 acceptance criteria for plan-gate
  Date: 2026-05-13T04:00+04:00
  Status: SUPERSEDED
  Context: Ensuring thorough planning
  Decision: Minimum 5 acceptance criteria per plan
  Reasoning: More criteria = better defined done-state
  Alternatives Rejected: 3 criteria minimum
  Risk Accepted: Planning overhead, criterion inflation
  Related Assumptions: A24

D15: Time-based rollup (every 24 hours)
  Date: 2026-05-13T04:00+04:00
  Status: SUPERSEDED
  Context: Preventing memory bloat
  Decision: Archive stale entries every 24 hours automatically
  Reasoning: Regular maintenance prevents accumulation
  Alternatives Rejected: Threshold-driven rollup
  Risk Accepted: May archive still-relevant entries; requires clock
  Related Assumptions: A25

D16: Include [REASONING] section in response contract
  Date: 2026-05-13T04:00+04:00
  Status: SUPERSEDED
  Context: Transparency in AI decision-making
  Decision: Add [REASONING] between [EVIDENCE] and [OUTPUT]
  Reasoning: Users want to understand AI thought process
  Alternatives Rejected: Keep 6-section contract
  Risk Accepted: Response bloat, reasoning may be post-hoc rationalization
  Related Assumptions: A22

D17: Auto-detect context usage and self-trigger compact
  Date: 2026-05-14T04:00+04:00
  Status: SUPERSEDED
  Context: Preventing context exhaustion
  Decision: AI monitors context and triggers compact automatically
  Reasoning: Proactive management
  Alternatives Rejected: User-driven compact only
  Risk Accepted: Impossible in Kimi CLI — no context metrics exposed
  Related Assumptions: A17

D18: Use single RESUME.md for all state
  Date: 2026-05-14T04:00+04:00
  Status: SUPERSEDED
  Context: Simplifying memory system
  Decision: Store all state in RESUME.md only
  Reasoning: Single file is simpler
  Alternatives Rejected: Multi-file separation (later chosen)
  Risk Accepted: No separation of concerns; hard to audit
  Related Assumptions: None

D19: Manual archive only — no automatic rollup
  Date: 2026-05-15T04:00+04:00
  Status: SUPERSEDED
  Context: Avoiding complexity
  Decision: Only archive when user explicitly requests
  Reasoning: Simplest possible system
  Alternatives Rejected: Automatic threshold-driven rollup (later chosen)
  Risk Accepted: Files grow unbounded; user must remember to archive
  Related Assumptions: None

D1: Protocol approach over runtime architecture
  Date: 2026-05-17T04:00+04:00
  Status: SUPERSEDED
  Context: Initial system design debate
  Decision: Protocol approach over runtime architecture
  Reasoning: Kimi CLI is sequential chat, not agent runtime
  Alternatives Rejected: Runtime architecture with module loader
  Risk Accepted: Less automation, more user collaboration
  Related Assumptions: None

D2: File-based memory over context-only continuity
  Date: 2026-05-17T04:00+04:00
  Status: ACTIVE→ARCHIVED
  Context: Session continuity design
  Decision: File-based memory over context-only continuity
  Reasoning: New sessions start blank; files provide handoff
  Alternatives Rejected: Context-only (lost on restart)
  Risk Accepted: File I/O latency, user must manage files
  Related Assumptions: None

D3: Validation-first deployment
  Date: 2026-05-17T04:00+04:00
  Status: ACTIVE→ARCHIVED
  Context: Deployment strategy
  Decision: Validation-first deployment
  Reasoning: Prove system works before claiming readiness
  Alternatives Rejected: Deploy-then-fix
  Risk Accepted: Delayed deployment if validation fails
  Related Assumptions: None
```

## Archive Metadata

- **Created:** 2026-05-17
- **Last Rollup:** 2026-05-17T11:35+04:00
- **Total Archived:** 18
- **Source File:** memory/DECISIONS.md
