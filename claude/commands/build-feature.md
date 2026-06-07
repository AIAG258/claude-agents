Build the planned feature using the AI R&D Squad 3-phase workflow (Phase 2 — Build).

## Prerequisites

Verify these files exist before proceeding:
- `specs/architecture.md`
- `specs/contracts/api-contracts.yaml`
- `specs/tasks/implementation-tasks.json`
- `specs/gate-decisions.md` contains a Gate A "Continue" entry for this feature (if not, warn the user that Phase 1 may not be approved)

If required files are missing, stop and tell the user to run `/plan-feature` first.

## What to do

1. **For AI features (Pattern 2):** invoke **llm-engineer** first — produces `backend/app/providers/llm/`, `providers/vector/`, `services/ai/`
2. Invoke **developer** and **frontend-engineer** in parallel
   - Only invoke agents that have tasks assigned in `implementation-tasks.json`
   - **frontend-engineer** uses theme decided at Gate A (dark or light)
   - Auth/backend work is handled by **developer**
3. After engineers complete, invoke **code-reviewer** — it **executes** lint/typecheck/build (static, non-destructive), not just reads code; records actual output in the review
4. If review status is **FAIL**: re-delegate to relevant engineer, then re-review (max 1 cycle, then escalate)
5. After review **PASS** or **CONDITIONAL**, invoke **tester** — runs unit/contract tests **and an end-to-end integration smoke test** (boots the stack, one real round-trip), then tears down. Tester is the only one that boots the running app; never run it on the same port while review's static checks are running.
6. Present **Gate B** summary to the user
7. After Gate B, run **memory harvest** (distill `specs/journal.md` → `specs/lessons.md`; propose any cross-project lessons for approval)

## Gate B

After all agents complete, present:
- Implementation summary (backend + frontend)
- Code review findings + resolution status (PASS/CONDITIONAL/FAIL)
- QA execution evidence: tests written, executed, **passed/failed/skipped (numbers required)**
- Risks
- **Ask: "Proceed to deployment, revise, or stop?"**
- If tester did not provide execution counts, ask tester to re-run and report before presenting Gate B
- Verify all tasks in scope have status `"tested"` in `implementation-tasks.json` — if any are `"reviewed"` or `"implemented"`, ask the responsible agent to update
- Record decision in `specs/gate-decisions.md` and update `Status:` in affected specs

## Additional context

$ARGUMENTS
