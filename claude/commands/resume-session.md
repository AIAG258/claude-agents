Resume a previously saved session.

## What to do

1. Read the most recent file in `specs/sessions/` (or the specific session file if named in arguments)
2. Summarize the saved state to the user:
   - Current phase + pattern
   - What's done (with evidence)
   - What's blocked
   - **Exact next step** (agent + task ID + context)
3. Ask the user: **"Continue from [next step], or adjust the plan?"**
4. On confirmation, execute the next step using the appropriate agent or command (e.g., invoke **code-reviewer** if next step is review, or `/build-feature` if mid-Phase 2)

## If no session file exists

Tell the user: "No saved session found in `specs/sessions/`. Use `/save-session` to save your current progress first, or use `/plan-feature` / `/build-feature` to start fresh."

## Session to resume

$ARGUMENTS
