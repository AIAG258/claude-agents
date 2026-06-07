# AI R&D Squad — Agent Team Manifest

## Team Identity

**AI R&D Squad**. Customize this section with your team name, contact, and lead.

## Language Policy

Respond in the language the user uses. Documentation default: English.

## Primary Tech Stack

FastAPI/Python 3.12+, React 18/TS/Vite/Zustand/TanStack, LiteLLM (mandatory gateway), SQLAlchemy 2.0 async, pytest+Playwright. Configurable design system (dark/light themes, brand color via CSS variables). Full spec: `docs/TECH_STACK.md`.

---

## Agent Roster & Delegation Matrix

### Core Workflow Agents

| Agent | Domain | When to Invoke |
|-------|--------|----------------|
| **teamlead** | Orchestration, pattern selection (1-4), Gate A/B enforcement | Complex multi-step projects, ambiguous requirements, sprint planning |
| **business-analyst** | Lean Canvas, UAT, PRD with Given/When/Then (Phase 1 step 1) | New initiatives, user stories, UAT planning, PRD writing |
| **software-architect** | System design, OpenAPI 3.1 contracts, ADRs, task breakdown (Phase 1 step 2). Sole owner of `implementation-tasks.json` | Architecture, API contracts, scaling decisions |
| **developer** | Python/FastAPI implementation (multi-language) | Features, bug fixes, implementing architect designs |
| **frontend-engineer** | React/TS/Zustand/TanStack + configurable design system (dark/light themes, CSS variables) | All UI implementation, redesign, theme decisions |
| **code-reviewer** | PASS/CONDITIONAL/FAIL review + fix loop | After every implementation, before tester |
| **tester** | Unit/integration/E2E/contract tests with execution evidence | After code-reviewer PASS/CONDITIONAL |

### Pattern 3/4 Required

| Agent | Domain | When to Invoke |
|-------|--------|----------------|
| **codebase-intelligence** | Codebase analysis, drift detection, safe placement | Mandatory first step in bug fix and refactor |

### On-Demand Specialists

| Agent | Domain | When to Invoke |
|-------|--------|----------------|
| **llm-engineer** | LiteLLM gateway, RAG, prompt engineering, vector store | AI/LLM features — runs BEFORE developer in Pattern 2 |
| **data-engineer** | ETL pipelines, OLAP schemas, vector ingestion, AI dataset prep | Data-heavy work, analytical schemas, bulk vector upsert |
| **docs-writer** | Technical documentation in Markdown | After significant feature completion |
| **squad-configurator** | Agent/skill/tool creation (CREATE) + audit (AUDIT) | New agents/skills, prompt optimization, squad audit |

### Delegation Rules

1. **teamlead** orchestrates — invoke first for complex multi-step projects; it selects pattern and routes
2. **software-architect** advises structure; **developer** + **frontend-engineer** implement
3. **frontend-engineer** owns ALL frontend styling AND React — developer defers; covers both dark and light theme variants
4. **llm-engineer** owns `providers/llm/`, `providers/vector/`, `services/ai/` — runs BEFORE developer in Pattern 2
5. **data-engineer** owns OLAP schemas and ETL — developer owns OLTP only
6. **code-reviewer** runs after ANY implementation, before tester
7. **tester** only receives `"reviewed"` status (PASS or CONDITIONAL); never FAIL
8. **codebase-intelligence** is mandatory first step in Pattern 3 (bug fix) and Pattern 4 (refactor)
9. **docs-writer** after any significant feature completed
10. Git ops (push/pull/PR/branch on GitHub) → **github-sync skill** (plan-then-confirm)
11. When in doubt → ask user or invoke **teamlead**

---

## Workflow Patterns — 3 Phases, 2 Gates

> Protocol: `docs/HANDOFF_PROTOCOL.md`. Pre-flight: `docs/PRE_IMPLEMENTATION_CHECKLIST.md`.

**Pattern 1 — New Feature:** `business-analyst → software-architect → 🛑 Gate A → developer + frontend-engineer → code-reviewer → tester → 🛑 Gate B → deploy`

**Pattern 2 — AI Feature:** `business-analyst → software-architect → 🛑 Gate A → llm-engineer → developer + frontend-engineer → code-reviewer → tester → 🛑 Gate B → deploy`

**Pattern 3 — Bug Fix:** `codebase-intelligence → [engineer] → code-reviewer → tester`

**Pattern 4 — Refactor:** `codebase-intelligence → software-architect → [engineers] → code-reviewer → tester`

**Pattern 5 — Fast Path (opt-in, small tasks):** `lean BA → architect-lite → [engineer] → code-reviewer → tester → 🛑 one light confirm`. Review + QA stay; the two gates collapse to one. Full path is the default for real projects.

**Spike (`/spike`):** throwaway feasibility POC — no contract, no gates. Use when you can't plan first.

> **code-reviewer executes** lint/typecheck/build (not just reads). **tester runs an end-to-end smoke test** (boots the stack, one real round-trip) before `tested`. Reviewer = static only; tester = the only one that boots the running app.

> **Self-improvement loop:** agents append gotchas to `specs/journal.md` during work; teamlead harvests at end of phase (or via `/retro`) → project lessons auto-written to `specs/lessons.md`, cross-project lessons added to `rules/learned-patterns.md` **with user approval** (then `sync.ps1`).

---

## File-Based Handoff (`specs/`)

| File | Owner | Purpose |
|---|---|---|
| `specs/prd.md` + `specs/features/*.md` | business-analyst | PRD with Given/When/Then |
| `specs/architecture.md` | software-architect | Architecture, DB design, handoff notes per agent |
| `specs/contracts/api-contracts.yaml` | software-architect | OpenAPI 3.1 single source of truth |
| `specs/tasks/implementation-tasks.json` | software-architect (sole owner) | Task breakdown with agent assignments |
| `specs/deployment-requirements.md` | software-architect | Current state, must-have, should-have |
| `specs/adr/*.md` | software-architect | Architecture Decision Records |
| `specs/codebase-analysis.md` | codebase-intelligence | Pattern 3/4 only |
| `specs/reviews/*.md` | code-reviewer | PASS/CONDITIONAL/FAIL + findings |
| `specs/gate-decisions.md` | teamlead | Gate A/B decision log |
| `specs/ai/prompts/v<N>/*.md` | llm-engineer | Versioned LLM prompts |
| `specs/journal.md` | all agents (append) | Running log of problems/gotchas during work |
| `specs/lessons.md` | teamlead (harvest) | Distilled project lessons, read before starting |
| `specs/spikes/*.md` | spike executor | Optional spike findings reports |

Task lifecycle: `pending → implemented → reviewed → tested`

---

## Shared Conventions

**Code Style:** Python type hints on all signatures, docstrings on public functions, async endpoints (`async def`), `.env` for secrets (always gitignored).

**Error Handling:** No silent exceptions. HTTP 401/403/404/500. Contract `ErrorResponse`: `{"error": {"code": "...", "message": "...", "details": [...]}}`. Log detail server-side; never expose internals to users.
