Run the full KPM Technologies AI R&D Squad lifecycle end-to-end — from a raw idea to (optionally) shipped — with three human gates as the only stopping points.

This is the umbrella command. It chains **Phase 0 (Discovery)** in front of the existing 4-phase / 3-gate workflow and drives **teamlead** through the whole thing autonomously. All human interaction is front-loaded into Phase 0 so the middle can run without halting.

## Raw idea

$ARGUMENTS

## How to run

### ⚠️ Execution model (read first)
- **Stage 0 runs in the MAIN thread, interactively.** Adopt the **solution-strategist** persona (`claude/agents/solution-strategist.md`) yourself and hold a real back-and-forth with the user. Do NOT spawn solution-strategist as a subagent — a spawned subagent cannot have a dialogue.
- **Stages 1+ run as spawned subagents** (they do not need live user input).
- **Batched-question escalation:** if a downstream subagent genuinely lacks a critical fact, it returns with grouped questions instead of guessing. Relay them to the user in the main thread, get answers, then re-invoke that agent with the answers. Never let a subagent dead-end on a missing decision.

### Stage 0 — Discovery (main thread, interactive)
Act as **solution-strategist**. Take the raw idea plus any documents/plan the user brings. Interrogate it on two lenses — **domain immersion** (step into the real worker's shoes; surface what the user has not defined or solved) and **AI/system failure modes**. Ask in batches of 3–5, dig on vague answers, keep going until the idea is de-risked. Then write:
- `specs/strategy/discovery-brief.md`
- `specs/strategy/risk-analysis.md`

### Stage 1 — Prior art (spawn subagent)
Spawn **prior-art-scout** (opus). It researches public solutions against the risks, critiques what the original authors missed, runs the mandatory license check, and writes:
- `specs/strategy/prior-art.md`

### 🛑 Gate 0 — Discovery review
**teamlead** consolidates Stage 0 + Stage 1 into a short dossier `specs/strategy/discovery-summary.md` (idea summary + top risks + prior-art adopt/avoid + open questions) and presents it. **Ask: "Continue to spec, revise, or stop?"** Do NOT proceed without explicit approval. Record the decision in `specs/gate-decisions.md` (`## Gate 0 — YYYY-MM-DD`). This is where the user confirms the idea makes sense before any spec work.

### Stage 2 — Spec (spawn subagents) → 🛑 Gate A
Run the existing **Phase 1** (`/plan-feature` logic): **business-analyst** (reads the discovery brief) → **software-architect**. Present **Gate A** (Continue / Revise / Stop).

### Stage 3 — Build (spawn subagents, parallel) → 🛑 Gate B
On Gate A "Continue", run the existing **Phase 2** (`/build-feature` logic): [llm-engineer if AI] → **developer + frontend-engineer in parallel** → **code-reviewer** (fix loop) → **tester** (+ e2e smoke). Present **Gate B** (Deploy / Revise / Stop).

### Stage 4 — Ship (optional)
On Gate B "Deploy", run **`/ship`** logic (deployment artifacts + github-sync, plan-then-confirm).

## Flow summary

```
Stage 0  solution-strategist (MAIN thread, interactive) → discovery-brief.md + risk-analysis.md
Stage 1  prior-art-scout (subagent, opus)               → prior-art.md
🛑 Gate 0  teamlead dossier (discovery-summary.md)       → Continue / Revise / Stop
Stage 2  business-analyst → software-architect           → 🛑 Gate A
Stage 3  developer + frontend-engineer (parallel) → code-reviewer → tester → 🛑 Gate B
Stage 4  ship (optional)
```

## Expected artifacts

- `specs/strategy/discovery-brief.md` — clarified, de-risked idea (solution-strategist)
- `specs/strategy/risk-analysis.md` — risk-per-row with open questions (solution-strategist)
- `specs/strategy/prior-art.md` — critical prior-art + license verdicts (prior-art-scout)
- `specs/strategy/discovery-summary.md` — Gate 0 dossier (teamlead)
- then all standard Phase 1/2 artifacts (PRD, features, architecture, contract, tasks, reviews, tests)

## Notes
- Gates are explicit stops by design — they are the user's three control points (Gate 0 / A / B).
- For a quick feasibility unknown, prefer `/spike` first. For a small, clear task, `/plan-feature` (or Fast Path) is lighter than the full `/startprocess`.
