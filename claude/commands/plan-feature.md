Plan a new feature using the AI R&D Squad 3-phase workflow (Phase 1 — Spec).

## What to do

1. Invoke **business-analyst** with the feature request below — produces `specs/prd.md` + `specs/features/<name>.md`. BA runs in **Lean Mode by default** (PRD sections 1–5 + acceptance criteria; no Lean Canvas / revenue / segments). Use **Full Mode** (Lean Canvas + 8-section PRD) only if the user asks for a full business analysis or it's a genuinely new product/Initiative with unclear market.
2. After business-analyst completes, invoke **software-architect** — produces `specs/architecture.md`, `specs/contracts/api-contracts.yaml` (OpenAPI 3.1), `specs/tasks/implementation-tasks.json` (sole owner), `specs/deployment-requirements.md`, ADRs if needed
3. Present **Gate A** summary to the user for approval

## Feature request

$ARGUMENTS

## Expected artifacts after this command

- `specs/prd.md` — PRD with 8 sections, Given/When/Then acceptance criteria
- `specs/features/<feature-name>.md` — one FRD per required feature
- `specs/architecture.md` — architecture with handoff notes per agent
- `specs/contracts/api-contracts.yaml` — OpenAPI 3.1 contract
- `specs/tasks/implementation-tasks.json` — task breakdown with agent assignments
- `specs/deployment-requirements.md` — what is needed beyond feature code to run/deploy
- `specs/adr/*.md` — only if non-standard decisions were made

## Gate A

After both agents complete, present to the user:
- PRD summary (3-5 bullets)
- Architecture decisions + API contract shape (paths, schemas, error codes)
- Deployment requirements (what is stubbed/mocked, what is needed for deploy)
- ADRs (if any)
- Theme decision: **dark** (dev tools, dashboards) or **light** (content-heavy, docs)
- **Ask: "Continue to Build, revise, or stop?"**
- Record decision in `specs/gate-decisions.md` and update `Status:` in affected specs
