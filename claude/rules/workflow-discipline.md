## Workflow Discipline Rules — Always Active

Applies to **teamlead** orchestration and to all engineering agents working in `specs/`-driven flows.

### Ownership
- `specs/tasks/implementation-tasks.json` — **structure** (task creation, IDs, agent assignments, dependencies, acceptance criteria) is owned **solely by software-architect**
- Task **status** is updated by the agent completing that lifecycle step:
  - engineer (developer / frontend-engineer / llm-engineer / data-engineer) → `"implemented"`
  - code-reviewer → `"reviewed"`
  - tester → `"tested"`
- **business-analyst** does NOT create task breakdowns, agent assignments, or API-level details (those belong to software-architect)
- **teamlead** does NOT modify task structure — only sequences agent invocations

### Gates
- **Gate A** (after Phase 1) and **Gate B** (after Phase 2) are mandatory for Pattern 1 (New Feature) and Pattern 2 (AI Feature)
- Pattern 3 (Bug Fix) and Pattern 4 (Refactor) skip gates — rely on code review + QA instead
- **Pattern 5 (Fast Path)** collapses the two gates into **one light confirmation** before ship — for small, well-scoped tasks (≤~3–4 files, no large schema change, no cross-agent redesign). Review + QA are NOT skipped.
- Trivial-task carve-out: Pattern 1/2 tasks ≤3 files with no new endpoints, no DB schema change, no cross-agent dependency may skip gates
- **Spike (`/spike`)** has no gates — it is throwaway feasibility work, not delivery
- Every gate decision recorded in `specs/gate-decisions.md` before proceeding past the gate

### Review-Before-QA
- code-reviewer runs **before** tester — always
- tester only receives work with `"reviewed"` status (PASS or CONDITIONAL)
- tester **never** receives FAIL code — teamlead routes back to engineer
- Code review fix loop: max 1 cycle, then escalate to human
- QA failure loop: max 1 cycle, then escalate to human
- Both loops are separate — both may occur in the same build cycle

### Artifacts
- Every agent must write its output files **before** handoff
- If a required upstream file is missing, do not proceed — notify teamlead
- All specs go in the `specs/` directory (per `docs/HANDOFF_PROTOCOL.md`)
- Spec file Status fields update to match gate outcomes (e.g., `Approved — Gate A`, `Approved — Gate B (Deploy)`, `Revision requested`)

### Verification Before Completion
- Engineers may not mark tasks `"implemented"` without running the relevant verification (server start, linter, type check, unit test, migration apply)
- **code-reviewer must EXECUTE static checks** (lint / typecheck / build), not only read code — and record the actual command output in the review. A failing build or typecheck is a FAIL. Reviewer uses **static, non-destructive commands only** (no long-running server, no DB mutation).
- **tester must run an end-to-end integration smoke test** before marking `"tested"` — boot backend+frontend together and put one real request through the whole stack (e.g. frontend → API → DB → back).
- Tester may not mark tasks `"tested"` without **executing** tests and recording counts (passed/failed/skipped — numbers required, not "tests pass")
- "Should work", "looks correct", "logically valid" — not acceptable. **Evidence only.**

### Run Isolation (who runs the app, when)
- **code-reviewer** runs only static/non-destructive commands (lint, typecheck, build, `pytest --collect-only`). It never starts a long-running server.
- **tester** is the **only** agent that boots the running application. It starts after the reviewer's static checks are done — never two processes on the same port at once.
- The tester must **tear down** anything it boots when finished, and must not start a service if its port is already in use.
- Detect verification commands **from the project** (e.g. `ruff`/`mypy`/`pytest` for Python, package.json scripts for JS) — do not hardcode.
