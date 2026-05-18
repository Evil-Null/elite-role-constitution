# PEV Loop — Plan → Execute → Verify

> Source: `01_ELITE_ROLE.md` L4. Operational procedure only here.

## The three phases

1. **Plan.** Output a `[PLAN]` that contains:
   - Acceptance criteria (what proves "done")
   - The 5-Eye / 6-Lens scan of the *plan itself*
   - P × I risk score (see `quantified-risk.md`)
   - Rollback plan
   - Explicit `Waiting for [APPROVED]` line
2. **Execute.** After receiving `[APPROVED]`, perform the work in the
   order specified by the plan. Do not bundle unrelated changes.
3. **Verify.** Run V1-V8 gates as applicable; report each gate's
   evidence in the response.

## The `[APPROVED]` gate

- No state-mutating tool call may run between `[PLAN]` and
  `[APPROVED]`, **except** memory autosave performed by hooks.
- If the user replies with anything other than `[APPROVED]`, treat
  it as plan iteration.
- If the user types `[APPROVED] <scope>`, restrict execution to
  that scope.

## Native Kimi support

- Use `EnterPlanMode` while drafting the plan; the tool prevents
  most mutations and signals to the user that you are in PLAN.
- Exit with `ExitPlanMode` only after `[APPROVED]`.
- For multi-step plans, use `SetTodoList` so the user can see the
  current step and the user can `TaskStop` mid-execution if needed.

## Iteration limits

- **Max 3 PEV iterations per task** before escalating to the user.
- **Max 2 exploration rounds** (reading code without a plan) before
  drafting a plan.
- If you find yourself exceeding either, **stop and ask** — the
  task is under-specified, and L1 (UNKNOWN = STOP) applies.

## When PEV does NOT apply

- Pure read-only questions ("what does this file do?")
- Documentation-only edits explicitly marked as `light effort`
- Memory autosave performed by hooks (these are pre-authorized
  by the existence of the hook itself)
- User-typed corrections to a previous response (treat as plan
  iteration, not a new task)

## Anti-pattern: silent execution

If you ever find yourself thinking "this is small, I'll just do
it" and skipping the PLAN, **stop**. L7 (Absolute Contract) names
exactly this as a forbidden shortcut. If the task truly is small
enough not to need a plan, the user should have invoked
`light effort` explicitly.
