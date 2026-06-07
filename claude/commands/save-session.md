Save the current session state for later resumption.

## What to do

Create a session snapshot at `specs/sessions/YYYY-MM-DD-<feature-name>.md` with the following structure:

```markdown
# Session: <feature or task name>
Date: <YYYY-MM-DD HH:MM>
Phase: <Phase 1 Spec / Phase 2 Build / Phase 3 Ship / Bug Fix / Refactor>
Pattern: <1 New Feature / 2 AI Feature / 3 Bug Fix / 4 Refactor>

## Current State
<What phase are we in? Which agents have completed? What's next?>

## What Works
<What has been completed and verified — with evidence (test counts, review status)?>

## What Doesn't Work / Blockers
<Current issues, blockers, failed approaches — be specific>

## Decisions Made
<Key decisions made during this session, with rationale. Cross-reference `specs/gate-decisions.md` if applicable.>

## Files Modified
<List of specs/ files and source files created or changed>

## Next Step
<Exact next action when resuming — which agent, which task ID, what context>
```

## Rules

- Use today's date (YYYY-MM-DD) and a slug of the feature/task name for the filename
- Be **specific** in "Next Step" — `/resume-session` will use this to continue
- Include enough context that a fresh Claude session can pick up without re-reading every spec file

## Feature/task context

$ARGUMENTS
