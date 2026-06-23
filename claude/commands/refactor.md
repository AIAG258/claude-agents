Refactor existing code using the KPM Technologies AI R&D Squad refactor workflow (Pattern 4).

## What to do

1. **Run existing test suite first** — record pass/fail counts as baseline
2. Invoke **codebase-intelligence** — codebase mapping, drift detection, refactor opportunities → `specs/codebase-analysis.md`
3. Invoke **software-architect** — design the refactored architecture
   - If architect changes `api-contracts.yaml`, present **Gate A** before proceeding (this becomes a contract change)
4. Invoke relevant engineers (developer / frontend-engineer / llm-engineer / data-engineer) to implement the refactoring tasks
5. Invoke **code-reviewer** — focus on:
   - **No external behavior change** (this is the refactor invariant)
   - Contract still matched
   - Proper abstractions, no over-engineering
6. Invoke **tester** — focus on **regression**: existing tests still pass, new minimal targeted tests only if extracted/refactored module has no direct coverage
7. **Compare test results to baseline** — confirm no regressions

## Refactor request

$ARGUMENTS

## Key constraint

The refactor must **not change external API behavior**. If API surface changes are needed, that's a new feature (`/plan-feature`), not a refactor. Tester does not expand into full test suite creation — refactor scope is limited.

No gates for Pattern 4 — refactors rely on baseline-comparison + code review + QA instead.
