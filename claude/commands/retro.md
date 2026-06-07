Run a memory harvest — distill the working journal into durable lessons (manual trigger for the self-improvement loop). teamlead also runs this automatically at the end of each phase; `/retro` lets you run it any time.

## What to do

1. Read `specs/journal.md` (the running log agents appended during work). If it's missing or empty, tell the user there's nothing to harvest and stop.
2. **Distill** a small number of durable lessons. **Filter hard** — only recurring, systemic, or genuinely reusable insights. Drop one-off noise. Quality over quantity.
3. **Two-tier write:**
   - **Project lessons → write automatically** to `specs/lessons.md` (one line each; create the file if missing; do not duplicate existing entries).
   - **Cross-project lessons** (apply to all the user's work — e.g. recurring API/integration gotchas, automation patterns) → **propose them to the user**. Only on approval, append to `{{SQUAD_HOME}}\claude\rules\learned-patterns.md` (the `SQUAD_HOME` env var points at the repo), then **remind the user to run `sync.ps1`** so it deploys to `~/.claude/rules/`.
4. Keep entries one-liners with a pointer. Never dump raw journal content into a lessons file. Never write secrets/PII.
5. Optionally, after a clean harvest, note in the journal that entries up to this point were harvested (so the next harvest doesn't re-process them).

## Entry formats

Project (`specs/lessons.md`):
```
- [<area> · <YYYY-MM-DD>] <lesson>  (ref: <file/area>)
```
Global (`learned-patterns.md`, after approval):
```
- [<area> · added <YYYY-MM-DD>] <lesson>  (why: <rationale>)
```

## Scope

$ARGUMENTS
