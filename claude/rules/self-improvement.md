## Self-Improvement Rules — Always Active

The squad gets smarter every project via a journal → harvest → memory loop. This rule governs the **write-during-work** and **read-before-start** behavior for **all agents**. The harvest step itself is owned by **teamlead** (and the `/retro` command).

### Journal — append during work (`specs/journal.md`)
When you hit something worth remembering, append a one-line entry to `specs/journal.md` (create it if missing). Log:
- a non-obvious **problem / error** and how you resolved it,
- a **gotcha** (framework quirk, API limit, config trap, version pin),
- a **workaround** or decision that future work should know about.

Entry format (keep it terse — one line):
```
- [<agent> · <YYYY-MM-DD>] <what happened> → <resolution / takeaway>  (ref: <file or area>)
```
Do **not** log routine success or narrate normal work. Only things that would save the next person (or agent) time. Never put secrets/tokens/PII in the journal.

### Lessons — read before starting
Before starting a task, **read `specs/lessons.md`** if it exists (distilled project lessons from prior phases). Apply what's relevant. This file is written by teamlead during harvest — do not hand-edit it during normal work.

### Two memory tiers (for context, harvest does the writing)
- **`specs/lessons.md`** — project-specific lessons. Written automatically by teamlead at harvest. Lives in the project.
- **`learned-patterns.md`** (this rules folder, always-active globally) — cross-project lessons that apply to all of the user's work. Added by teamlead **only with user approval**, then deployed via `setup.ps1`/`sync.ps1`. Because it's an always-active rule, it loads in every session, every project — keep it tight.

Keep both tiers signal-only. Memory that's read every session costs context budget; noise there hurts everyone.
