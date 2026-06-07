Run a code review on the current implementation using the **code-reviewer** agent.

## What to do

1. Invoke **code-reviewer** on the current implementation
2. The reviewer reads: `specs/architecture.md`, `specs/contracts/api-contracts.yaml`, `specs/tasks/implementation-tasks.json`, `specs/features/<feature>.md`, and source code in `backend/` and `frontend/`
3. Review output goes to `specs/reviews/<feature-name>-review.md` (or `specs/reviews/adhoc-YYYY-MM-DD-<slug>.md` for ad-hoc)

## Status outcomes

- **PASS** → Ready for tester. Invoke **tester** if not yet run.
- **CONDITIONAL** → Ready for tester with noted suggestions (warnings non-blocking).
- **FAIL** → Route back to relevant engineer with specific findings. After fix, re-invoke this command for focused re-review (max 1 fix cycle, then escalate).

## Additional context

$ARGUMENTS
