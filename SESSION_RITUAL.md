# SESSION_RITUAL — Turn-by-Turn Operating Discipline

> **Role:** Step-by-step ritual for each phase of work. Not a state machine — a checklist.  
> **Read:** When ritual is unclear, during training, or when behavior drifts.  
> **Updated:** Never. Read-only reference.  
> **Authority:** Protocol (Rank 2)

---

## Ritual 1: First Session Start

```
1. User starts new Kimi CLI session
2. AI receives system prompt (contains L1-L7)
3. User says: "resume" or "read context first"
4. AI reads memory/README.md → RESUME.md → CONTEXT.md → ASSUMPTIONS.md
5. AI summarizes to user:
   "Resuming. Active task: [X]. Last completed: [Y]. Next: [Z]. Pending assumptions: [A1, A2]."
6. User confirms or updates
7. AI confirms understanding
8. Normal work begins
```

## Ritual 2: Normal Work Cycle (Standard Turn)

```
1. User sends message
2. AI mental self-check (during thinking):
   □ Do I fully understand? If no → CLARIFY
   □ Am I certain? If no → declare UNKNOWN
   □ Am I about to fabricate? If yes → STOP
3. AI classifies task (mental inference):
   □ Routine question? → Brief answer + evidence
   □ Task execution? → PLAN → [APPROVED] → EXECUTE → VERIFY → DELIVER
   □ System design? → PLAN → [APPROVED] → ARCHITECT → VERIFY → DELIVER
   □ Ambiguous? → Ask questions. Do not guess.
4. AI produces response per Response Contract
5. AI updates memory/CONTEXT.md if state changed
6. AI updates memory/ASSUMPTIONS.md if assumptions declared
```

## Ritual 3: Pre-Compact

```
1. AI detects context ≥ 60% OR user runs `/compact`
2. AI says: "Context approaching limit. Executing compact ritual."
3. AI writes memory/COMPACT_STATE.md:
   □ Active task summary
   □ Last completed step
   □ Next step
   □ Active assumptions (A1, A2...)
   □ Risk items (score ≥ 7)
   □ Modified files list
4. AI writes memory/RESUME.md (if not current)
5. AI confirms: "Compact-safe. State persisted."
6. User runs `/compact`
```

## Ritual 4: Post-Compact

```
1. Conversation history compressed
2. AI reads memory/COMPACT_STATE.md
3. AI reads memory/RESUME.md
4. AI reads memory/CONTEXT.md
5. AI confirms rehydration:
   "State restored. Active task: [X]. Next: [Y]. Assumptions: [Z]."
6. User confirms or updates
7. Normal work resumes
```

## Ritual 5: End-Session Save

```
1. User says "end session" or context critical
2. AI writes memory/CONTEXT.md (final state)
3. AI writes memory/RESUME.md:
   □ Active task summary
   □ Last completed step
   □ Next pending step
   □ Active assumptions
   □ Risk items
   □ Modified files
4. AI says: "Session saved. To resume, start new session and say 'resume'."
5. Session ends
```

## Ritual 6: Next-Session Resume

```
1. User starts new session
2. User says: "resume"
3. AI reads memory/README.md → RESUME.md → CONTEXT.md → ASSUMPTIONS.md
4. AI presents summary:
   "Resumed from [timestamp]. Task: [X]. Last: [Y]. Next: [Z]. Assumptions: [A1]."
5. User confirms: "Yes, continue" OR provides update
6. AI confirms understanding
7. Normal work resumes
```

## Ritual 7: Audit Ritual

```
1. User says: "audit mode" or "audit your discipline"
2. AI reviews last 3 responses against L1-L7:
   □ Any unverified claims? (L2 violation)
   □ Any proceeded-on-uncertainty? (L1 violation)
   □ Any skipped verification? (L4 violation)
   □ Any missing assumptions? (L7 violation)
3. AI checks memory/ASSUMPTIONS.md for stale items (> 7 days)
4. AI checks memory/DECISIONS.md for conflicts
5. AI reports findings:
   "Audit complete. Violations: [N]. Stale assumptions: [N]. Status: [PASS / NEEDS ATTENTION]."
6. If violations found → propose remediation
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
1. AI runs mental V1-V8 checklist:
   □ V1 Structural integrity
   □ V2 Semantic coherence
   □ V3 Safety scan
   □ V4 Output quality
   □ V5 Spec compliance
   □ V6 Regression check
   □ V7 Edge cases
   □ V8 Evidence integrity
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
