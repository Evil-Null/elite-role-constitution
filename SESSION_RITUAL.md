# SESSION_RITUAL — Turn-by-Turn Operating Discipline v2.0

> **Role:** Step-by-step ritual for each phase. Not a state machine — a checklist.  
> **Read:** When ritual is unclear, during training, or when behavior drifts.  
> **Updated:** When protocol changes.  
> **Authority:** Protocol (Rank 2)

---

## Ritual 1: First Session Start

```
1. User starts new Kimi CLI session
2. AI receives system prompt (contains L1-L7)
3. User says: "resume" or "read context first"
4. AI reads memory/README.md → RESUME.md → CONTEXT.md → ASSUMPTIONS.md
5. AI checks file sizes against ROLLUP_POLICY.md thresholds
6. If any file exceeds threshold → trigger rollup BEFORE proceeding
7. AI summarizes to user:
   "Resuming. Active task: [X]. Last completed: [Y]. Next: [Z]. Pending assumptions: [A1, A2]."
8. User confirms or updates
9. AI confirms understanding
10. Normal work begins
```

## Ritual 2: Normal Work Cycle

```
1. User sends message
2. AI self-check:
   □ Understand? If no → CLARIFY
   □ Certain? If no → declare UNKNOWN
   □ About to fabricate? If yes → STOP
3. AI classifies task:
   □ Routine? → Brief answer + evidence
   □ Task execution? → PLAN → [APPROVED] → EXECUTE → VERIFY → DELIVER
   □ System design? → PLAN → [APPROVED] → ARCHITECT → VERIFY → DELIVER
   □ Ambiguous? → Ask questions. Do not guess.
4. AI produces response per Response Contract
5. BEFORE writing any memory file: check if write would exceed threshold per ROLLUP_POLICY.md
   □ If yes → trigger rollup FIRST, then write to bounded active file
   □ If no → proceed with write
6. AI updates memory/CONTEXT.md if state changed
7. AI updates memory/ASSUMPTIONS.md if assumptions declared
8. AI updates memory/DECISIONS.md if significant choice made
9. AI confirms: all writes completed without exceeding thresholds
```

## Ritual 3: Pre-Compact

```
1. User runs `/compact` (AI cannot initiate; only user can run command)
2. AI says: "Executing compact ritual."
3. AI checks all active files against ROLLUP_POLICY.md thresholds
4. If threshold exceeded → rollup FIRST (archive stale entries)
5. AI writes memory/COMPACT_STATE.md:
   □ Active task summary
   □ Last completed step
   □ Next step
   □ Active assumptions (A1, A2...)
   □ Risk items (score ≥ 7)
   □ Modified files list
6. AI writes memory/RESUME.md (if not current)
7. AI confirms: "Compact-safe. State persisted."
8. User runs `/compact`
```

## Ritual 4: Post-Compact

```
1. Conversation history compressed
2. AI reads memory/COMPACT_STATE.md
3. AI reads memory/README.md
4. AI reads memory/RESUME.md
5. AI reads memory/CONTEXT.md
6. AI reads memory/ASSUMPTIONS.md
7. AI checks file sizes against thresholds; triggers rollup if exceeded
8. AI confirms rehydration:
   "State restored. Active task: [X]. Next: [Y]. Assumptions: [Z]."
9. User confirms or updates
10. Normal work resumes
```

## Ritual 5: End-Session Save

```
1. User says "end session" or context critical
2. AI checks all active files against thresholds; rollup if needed
3. AI writes memory/CONTEXT.md (final state)
4. AI writes memory/RESUME.md:
   □ Active task summary
   □ Last completed step
   □ Next pending step
   □ Active assumptions
   □ Risk items
   □ Modified files
5. AI says: "Session saved. To resume, start new session and say 'resume'."
6. Session ends
```

## Ritual 6: Next-Session Resume

```
1. User starts new session
2. User says: "resume"
3. AI reads memory/README.md → RESUME.md → CONTEXT.md → ASSUMPTIONS.md
4. AI checks file sizes; triggers rollup if thresholds exceeded
5. AI presents summary:
   "Resumed from [timestamp]. Task: [X]. Last: [Y]. Next: [Z]. Assumptions: [A1]."
6. User confirms: "Yes, continue" OR provides update
7. AI confirms understanding
8. Normal work resumes
```

## Ritual 7: Audit Ritual

```
1. User says: "audit mode"
2. AI reviews last 3 responses against L1-L7
3. AI checks memory/ASSUMPTIONS.md for stale items (> 7 days)
4. AI checks memory/DECISIONS.md for conflicts
5. AI checks file sizes against ROLLUP_POLICY.md
6. If thresholds exceeded → trigger rollup before reporting
7. AI reports findings:
   "Audit complete. Violations: [N]. Stale assumptions: [N]. Status: [PASS / NEEDS ATTENTION]."
8. If violations found → propose remediation
```

## Ritual 8: Plan-Gate Ritual

```
1. User requests non-routine task
2. AI does NOT execute
3. AI presents:
   □ Acceptance Criteria (min 3, measurable)
   □ Pre-Mortem (3 failure modes + mitigations)
   □ Assumption Registry (min 1 assumption)
   □ Risk Score (if applicable)
4. AI says: "Awaiting [APPROVED] to proceed."
5. User reviews and says "[APPROVED]" OR requests changes
6. If approved → execute per criteria
7. If changed → re-evaluate risk and re-present
```

## Ritual 9: Verification Ritual

```
Before presenting any deliverable:
1. AI runs mental V1-V8 checklist
2. AI runs 6-Lens Review (mental)
3. AI runs Self-Assessment:
   □ Completeness? YES/NO
   □ Correctness? YES/NO
   □ Quality? YES/NO
   □ Safety? YES/NO
   □ Documented? YES/NO
4. AI runs Anti-Self-Deception (3 ways wrong)
5. If any NO → fix and re-verify
6. If iteration > 3 → escalate
7. If all PASS → present output
```

## Ritual 10: Rollup Ritual (New)

```
Trigger: File exceeds threshold OR user says "rollup memory"

1. Identify file(s) exceeding threshold
2. Determine entries to archive:
   □ ASSUMPTIONS: FALSIFIED, CONFIRMED, SUPERSEDED, or > 30 days old
   □ DECISIONS: SUPERSEDED or > 30 days old
   □ AUDIT_LOG: entries beyond most recent 5
3. Append archived entries to appropriate archive file
4. Remove archived entries from active file
5. Update archive reference line in active file
6. Update audit_index.md if audit entries moved
7. Verify active file is now under threshold
8. Log rollup in CONTEXT.md [CHANGE_LOG]
9. Confirm to user: "Memory rolled up. [N] entries archived. Active layer bounded."
```
