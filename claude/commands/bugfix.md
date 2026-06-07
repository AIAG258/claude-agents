Fix a bug using the AI R&D Squad bug fix workflow (Pattern 3).

## What to do

1. Invoke **codebase-intelligence** — root cause analysis, drift detection, placement guidance → `specs/codebase-analysis.md`
2. Delegate the fix to the relevant engineer based on the analysis:
   - Backend / auth bug → **developer**
   - Frontend bug → **frontend-engineer**
   - LLM/RAG bug → **llm-engineer**
   - ETL/data bug → **data-engineer**
3. Route through **code-reviewer** (fix loop on FAIL)
4. Hand off to **tester** for regression test (write failing test that reproduces the bug, verify fix makes it pass)

## Bug description

$ARGUMENTS

## Quality checks after fix

- code-reviewer validates the fix
- tester writes regression test for the specific bug, runs full affected test suite, reports counts
- If fix requires a new error code or status not in `api-contracts.yaml`, flag to **software-architect** for contract update before implementing

No gates for Pattern 3 — bug fixes rely on code review + QA instead.
