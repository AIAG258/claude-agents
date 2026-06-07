Prepare for deployment using the AI R&D Squad workflow (Phase 3 — Ship). Manual shortcut — teamlead runs this logic automatically after Gate B "Deploy".

## Prerequisites

Verify before proceeding:
- Gate B has been approved by the user
- `specs/reviews/<feature>-review.md` exists with Status: PASS or CONDITIONAL
- tester has executed tests and reported counts (passed/failed/skipped)
- `specs/deployment-requirements.md` exists — review it to determine infrastructure needs

If prerequisites are not met, tell the user which steps are missing.

## What to do

1. Read `specs/deployment-requirements.md` to determine the target platform and any infrastructure changes.
2. Produce the deployment artifacts appropriate to the target (e.g. Dockerfile, build/runtime config, environment/secrets checklist, CI workflow). Keep them minimal and aligned to the chosen platform — confirm specifics with the user when the target is ambiguous.
3. Run a final pre-ship check: build succeeds, tests pass, no secrets in committed files, env/config documented.
4. Push via the **`github-sync` skill** (plan-then-confirm). Do not push automatically — present the plan first.

The actual deploy step (Cloud Run, a container host, a PaaS, etc.) is performed by the user or their CI; this command's job is to leave the repo in a clean, deployable state.

## Deployment context

$ARGUMENTS
