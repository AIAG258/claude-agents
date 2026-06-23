# KPM Technologies AI R&D Squad — Handoff Protocol

> Defines how agents communicate via the `specs/` directory.
> All agents that read/write spec files must follow this protocol.

---

## Upstream Validation Rules

Before an agent starts work, it must verify required upstream files exist:

1. **Check required upstream files** exist on disk and are non-empty
   - `specs/architecture.md` — minimum 10 lines
   - Other spec files — minimum 5 lines
2. **If a required upstream file is missing or empty:**
   - DO NOT proceed
   - Notify **teamlead**: *"Upstream artifact `specs/X.md` is missing. Run [agent] first."*
3. **Optional upstream files** (e.g., `specs/codebase-analysis.md`) — read if exist, proceed without them if not

---

## Output Rules

When an agent completes work and writes output:

1. **Write the output file** at the defined path (e.g., `specs/architecture.md`)
2. **Verify the file is complete** before handoff — incomplete outputs block downstream agents
3. **Update `Status:` field** in affected spec documents to reflect lifecycle stage (e.g., `Approved — Gate A`, `Implemented`, `Reviewed — PASS`)

---

## Dependency Graph

```
specs/strategy/discovery-brief.md + risk-analysis.md (solution-strategist, MAIN thread)
  → specs/strategy/prior-art.md (prior-art-scout, subagent)
  → specs/strategy/discovery-summary.md (teamlead) → 🛑 GATE 0
specs/prd.md (business-analyst)
  → specs/features/*.md (business-analyst)
  → specs/architecture.md (software-architect)
    → specs/tasks/implementation-tasks.json (software-architect — sole owner)
    → specs/adr/*.md (software-architect, conditional)
    → specs/contracts/api-contracts.yaml (software-architect)
    → specs/deployment-requirements.md (software-architect)
    → specs/codebase-analysis.md (codebase-intelligence — required for Pattern 3 & 4)
      → implementation code (developer / frontend-engineer / llm-engineer / data-engineer)
        → specs/reviews/<feature>-review.md (code-reviewer)
          → FAIL? → back to engineer → code-reviewer (max 1 fix cycle)
          → PASS/CONDITIONAL → test code (tester) → e2e smoke test
            → tester reports counts → teamlead → Gate B
              → memory harvest: specs/journal.md → specs/lessons.md (+ learned-patterns.md on approval)
```

Cross-cutting files (not phase-gated):
- `specs/journal.md` — appended by **all agents** during work (problems/gotchas)
- `specs/lessons.md` — written by **teamlead** at harvest; read by agents before starting
- `specs/spikes/*.md` — optional findings reports from `/spike`

---

## 4-Phase Development Workflow

### Phase 0 — Discovery & Prior Art (front of `/startprocess`; optional elsewhere)
```
solution-strategist (MAIN thread, interactive) → prior-art-scout (subagent) → 🛑 HUMAN APPROVAL GATE 0
```
- **solution-strategist** runs **in the main thread** (interactive dialogue — a spawned subagent cannot converse). Outputs: `specs/strategy/discovery-brief.md`, `specs/strategy/risk-analysis.md`
- **prior-art-scout** is **spawned as a subagent**. Outputs: `specs/strategy/prior-art.md` (patterns + authors' mistakes + license check)
- **Batched-question escalation:** downstream subagents that lack a critical fact return grouped questions to the main thread instead of guessing; teamlead relays, collects answers, re-invokes.

**Gate 0:** **teamlead** consolidates Phase 0 into `specs/strategy/discovery-summary.md` and presents idea + top risks + prior-art adopt/avoid + open questions. Asks user to continue, revise, or stop. solution-strategist is skipped for pure bug fixes.

### Phase 1 — Spec
```
business-analyst → software-architect → 🛑 HUMAN APPROVAL GATE A
```
- **business-analyst** outputs: `specs/prd.md`, `specs/features/`, optional `specs/lean-canvas.md`, `specs/uat-criteria.md`
- **software-architect** outputs: `specs/architecture.md`, `specs/adr/`, `specs/contracts/api-contracts.yaml`, `specs/tasks/implementation-tasks.json`, `specs/deployment-requirements.md`

> **Note:** `specs/tasks/implementation-tasks.json` is owned solely by **software-architect**. business-analyst does NOT create it.

**Gate A:** **teamlead** summarizes PRD, architecture, deployment requirements, theme decision (dark/light). Asks user to continue, revise, or stop.

### Phase 2 — Build
```
[llm-engineer if AI feature] → developer + frontend-engineer + [data-engineer if needed] → code-reviewer → tester → 🛑 HUMAN APPROVAL GATE B
```
Outputs: implementation code, `specs/reviews/<feature>-review.md`, test code (`backend/tests/`, `frontend/tests/`)

**Code Review Fix Loop:** If code-reviewer returns FAIL, work goes back to the relevant engineer for fixes (max 1 cycle). tester only runs after PASS or CONDITIONAL.

**QA Failure Loop:** If tester finds implementation bugs (not test bugs), teamlead routes failure back to the relevant engineer. Engineer fixes, tester re-runs failed tests (max 1 cycle). Gate B is not presented until tester passes or failure is escalated.

**Gate B Revision:** If user says "Revise":
- Minor (no contract/schema change) → engineer → code-reviewer → tester → Gate B
- Contract/architecture change → software-architect → engineers → code-reviewer → tester → Gate B
- Scope change → business-analyst → software-architect → resume Phase 2

### Phase 3 — Ship (optional)
```
Gate B "Deploy" → teamlead reads specs/deployment-requirements.md
  → run /ship logic: produce deployment artifacts (Dockerfile, build/runtime config, env/secrets checklist, CI)
  → push via github-sync (plan-then-confirm)
  → actual deploy (Cloud Run / container host / PaaS) run by user or CI
```
No separate approval gate — deployment decision made at Gate B.

---

## Human Approval Checkpoints

**teamlead** must STOP at these gates for Pattern 1 (New Feature) and Pattern 2 (AI Feature). **Gate 0** applies whenever Phase 0 runs (always via `/startprocess`); **Gate A** and **Gate B** are always mandatory:

| Gate | When | What teamlead presents | User options |
|---|---|---|---|
| **0** | After Phase 0 (if run) | Idea summary, top 3 risks, prior-art adopt/avoid + licensing, open questions (`specs/strategy/discovery-summary.md`) | Continue / Revise / Stop |
| **A** | After Phase 1 | PRD summary (3-5 bullets), architecture decisions, API contract shape, ADRs (if any), theme decision | Continue / Revise / Stop |
| **B** | After Phase 2 | Implementation summary, code review findings, QA results (numbers required), open issues, risks | Deploy / Revise / Stop |

After each gate decision:
1. Record decision (date, feature, outcome, notes) in `specs/gate-decisions.md`
2. Update `Status:` field in affected spec documents

Pattern 3 (Bug Fix) and Pattern 4 (Refactor) skip gates — validated through code review + QA instead.

For trivial tasks within Pattern 1/2 (≤3 files, no new endpoints, no DB schema change, no cross-agent dependency), gates may be skipped.

**Pattern 5 (Fast Path)** collapses Gate A + Gate B into **one light confirmation** for small, well-scoped tasks (lean BA → architect-lite → engineer → executive review → smoke test). Review + QA stay. **Spike (`/spike`)** has no gates — throwaway feasibility work.

**Executive verification (Phase 2):** code-reviewer must **execute** lint/typecheck/build (static, non-destructive) and record output — a failing build/typecheck is a FAIL. tester must run an **end-to-end integration smoke test** (boot the stack, one real round-trip) before `tested`. Run isolation: tester is the only agent that boots the running app, starts after the reviewer's static checks, and tears down what it boots.

**Memory harvest (end of phase):** teamlead distills `specs/journal.md` → project lessons auto-written to `specs/lessons.md`; cross-project lessons proposed for user approval → `rules/learned-patterns.md` (then `sync.ps1`). Also available via `/retro`.

---

## Contract-First Protocol

`specs/contracts/api-contracts.yaml` is the **single source of truth** for all API contracts (OpenAPI 3.1).

- **Produced by:** software-architect (mandatory output)
- **Consumed by:**
  - **developer** — implements endpoints exactly as specified
  - **frontend-engineer** — derives API calls and TS types from contract
  - **code-reviewer** — validates implementation matches contract
  - **tester** — validates endpoints match contract (paths, methods, schemas, status codes, error codes)

**Rule:** No agent may deviate from `api-contracts.yaml` without **software-architect** revising the contract first.

---

## Agent Activation by Pattern

### Phase 0 — Discovery (mandatory via `/startprocess`, optional elsewhere)
| Agent | Trigger |
|---|---|
| **solution-strategist** | Fuzzy/high-stakes idea before spec — runs in the **main thread**, interactive. Skipped for pure bug fixes. |
| **prior-art-scout** | After solution-strategist, before software-architect — spawned subagent; also useful in refactors. |

### Required in Pattern 3 (Bug Fix) & Pattern 4 (Refactor)
| Agent | Trigger |
|---|---|
| **codebase-intelligence** | Always first step — analyzes codebase before any code change |

### On-Demand Specialists
| Agent | Trigger |
|---|---|
| **llm-engineer** | AI/LLM features, RAG, prompts (runs BEFORE developer in Pattern 2) |
| **data-engineer** | ETL, OLAP, vector ingestion, AI dataset prep |
| **docs-writer** | After significant feature completion |

### Manual / Squad-Internal
| Agent | Trigger |
|---|---|
| **squad-configurator** | Create new agents/skills/tools, audit existing agents |

---

## Specs Directory Layout

```
specs/
├── strategy/                       # Phase 0 (solution-strategist + prior-art-scout + teamlead)
│   ├── discovery-brief.md          # solution-strategist
│   ├── risk-analysis.md            # solution-strategist
│   ├── prior-art.md                # prior-art-scout
│   └── discovery-summary.md        # teamlead (Gate 0 dossier)
├── prd.md                          # business-analyst
├── lean-canvas.md                  # business-analyst (optional, early-stage)
├── uat-criteria.md                 # business-analyst (optional, pre-launch)
├── features/                       # business-analyst (one file per feature)
│   └── <feature-name>.md
├── architecture.md                 # software-architect
├── adr/                            # software-architect (conditional)
│   └── YYYY-MM-DD-<decision>.md
├── contracts/
│   └── api-contracts.yaml          # software-architect (OpenAPI 3.1)
├── tasks/
│   └── implementation-tasks.json   # software-architect (sole owner)
├── deployment-requirements.md      # software-architect
├── codebase-analysis.md            # codebase-intelligence (Pattern 3 & 4)
├── reviews/                        # code-reviewer
│   └── <feature>-review.md
├── sessions/                       # /save-session output
│   └── YYYY-MM-DD-<name>.md
├── ai/
│   └── prompts/                    # llm-engineer (versioned prompts)
│       └── v<N>/
│           └── <purpose>.md
└── gate-decisions.md               # teamlead (Gate A/B decision log)
```

---

## Example Workflow

1. **business-analyst** writes `specs/prd.md`, `specs/features/`
2. **software-architect** reads `specs/prd.md` → continues
   - Writes `specs/architecture.md`, `specs/contracts/api-contracts.yaml`, creates `specs/tasks/implementation-tasks.json` (sole owner), `specs/deployment-requirements.md`
3. **🛑 Gate A** — teamlead presents to user
4. **codebase-intelligence** (Pattern 3/4 only) verifies `specs/architecture.md` exists → continues
   - Writes `specs/codebase-analysis.md`
5. **developer** verifies `specs/architecture.md` and `specs/contracts/api-contracts.yaml` exist → continues
   - Implements code, updates task status in `specs/tasks/implementation-tasks.json`
6. **code-reviewer** reads tasks with status `"implemented"` → reviews → writes `specs/reviews/<feature>-review.md` → updates status to `"reviewed"`
7. **tester** reads tasks with status `"reviewed"` → writes + executes tests → reports counts → updates status to `"tested"`
8. **🛑 Gate B** — teamlead presents to user with execution evidence
