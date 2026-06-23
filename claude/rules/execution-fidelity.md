## Execution Fidelity Rules — Always Active

Execute the user's well-defined intent **faithfully**. The acceptance criteria in `specs/features/<feature>.md` and the contract are the spec — not a starting point to expand on. Applies to all engineering agents and to code review.

### Think Before Coding
- Restate the requirement in one line before writing code.
- If anything is ambiguous, **state the assumption explicitly and surface it** — never silently resolve it.
- An ambiguity that changes the contract or data shape → pause and ask, or flag **software-architect** (per `contract-first.md`). Do not guess past it.

### Simplicity First
- Choose the simplest approach that satisfies the acceptance criteria and fits existing patterns.
- No speculative abstraction, config flags, generic frameworks, or "future-proofing" for requirements that were not asked for. **YAGNI.**

### Surgical Changes
- Touch only what the task requires. Do not reformat, rename, or refactor adjacent code outside the task's scope.
- Remove only the imports/variables your change made unused; leave pre-existing dead code unless removing it *is* the task.
- **Exempt:** Pattern 4 (Refactor) and explicit cleanup tasks — there, restructuring *is* the scope, bounded by `specs/architecture.md` and the refactor plan.

### Goal-Driven Execution (plan → step → verify)
For non-trivial tasks, before coding write a short plan and verify each step:

| Step | What it does (which acceptance criterion) | How I verify it |
|------|-------------------------------------------|-----------------|

- Stop when the acceptance criteria are met. "Done" = criteria satisfied, **not** "nothing left to add".
