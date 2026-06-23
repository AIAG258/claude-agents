# KPM Technologies AI R&D Squad — Agents, Commands, Rules & Tools Registry

> Offline reference for the team. **Not loaded into Claude Code context** — feel free to be detailed.

**Agents location:** `{{CLAUDE_HOME}}\agents\`
**Commands location:** `{{CLAUDE_HOME}}\commands\`
**Rules location:** `{{CLAUDE_HOME}}\rules\`
**Skills location:** `{{CLAUDE_HOME}}\skills\`
**Tools location:** `{{SQUAD_HOME}}\tools\`

---

## Agents

### Phase 0 — Discovery (idea → de-risked brief)

| Agent | Color | Domain | Model |
|-------|-------|--------|-------|
| **solution-strategist** | amber | Adversarial thinking partner. Two lenses: domain immersion (the real worker's shoes) + AI/system failure modes. **Runs interactively in the main thread — never spawned.** Phase 0 step 1. | opus |
| **prior-art-scout** | violet | Researches public solutions — patterns to adopt AND mistakes the authors missed; mandatory license check. Spawned subagent. Phase 0 step 2. | opus |

### Core Workflow Agents (Phases 1–2)

| Agent | Color | Domain | Model |
|-------|-------|--------|-------|
| **teamlead** | red | Orchestration, pattern selection (1–4), Gate A/B enforcement, agent routing | opus |
| **business-analyst** | cyan | Lean Canvas, UAT, value scoring + PRD with 8 sections + Given/When/Then acceptance criteria. Phase 1 step 1. | inherit |
| **software-architect** | green | System design, OpenAPI 3.1 contracts, DB schema, ADRs, **sole owner of `implementation-tasks.json`**. Phase 1 step 2. | inherit |
| **developer** | purple | Implementation (Python/FastAPI primary, multi-language) including backend auth. Defers UI/LLM/data. | sonnet |
| **frontend-engineer** | blue | Frontend (React/TS/Zustand/TanStack) + configurable design system (dark/light themes, CSS variables) | inherit |
| **code-reviewer** | magenta | Post-implementation review with PASS/CONDITIONAL/FAIL + fix loop (max 1 cycle) | sonnet |
| **tester** | yellow | Unit/integration/E2E/contract tests with execution evidence (counts required) | sonnet |

### Pattern 3/4 Required

| Agent | Color | Domain | Model |
|-------|-------|--------|-------|
| **codebase-intelligence** | teal | Brownfield/legacy analysis, drift detection, safe placement. Required first step in Pattern 3 (bug fix) and Pattern 4 (refactor). | opus |

### On-Demand Specialists

| Agent | Color | Domain | Model |
|-------|-------|--------|-------|
| **llm-engineer** | pink | LiteLLM gateway, RAG, prompt engineering, vector store implementations. Runs BEFORE developer in Pattern 2. | sonnet |
| **data-engineer** | brown | ETL pipelines, OLAP analytical schemas, vector ingestion (chunking, embedding, bulk upsert), AI dataset prep | sonnet |
| **docs-writer** | pink | Technical documentation in Markdown (technical docs, user guides, READMEs, ADRs) | sonnet |
| **squad-configurator** | white | Dual-mode: CREATE (new agents/skills/tools) + AUDIT (review existing) | inherit |

**Total agents: 14**

### Delegation Rules

1. **teamlead** is the orchestrator — invoke first for complex tasks; selects pattern and routes
2. **solution-strategist** runs **interactively in the main thread** (never spawned) — de-risks a raw idea before BA; skipped for pure bug fixes
3. **prior-art-scout** runs after solution-strategist, before software-architect — existing solutions + authors' unforeseen mistakes; **always license-checks** before recommending
4. **software-architect** advises structure; **developer** + **frontend-engineer** implement
5. **developer** handles backend implementation including auth
6. **frontend-engineer** owns ALL frontend styling + React implementation; covers both dark and light themes
7. **llm-engineer** owns `backend/app/providers/llm/`, `providers/vector/`, `services/ai/`; runs BEFORE developer in Pattern 2
8. **data-engineer** owns OLAP schemas and ETL; developer owns OLTP only
9. **code-reviewer** runs AFTER any significant code change, before tester
10. **tester** receives only `"reviewed"` status (PASS/CONDITIONAL); never FAIL
11. **codebase-intelligence** mandatory first step in Pattern 3 (bug fix) and Pattern 4 (refactor)
12. **docs-writer** runs AFTER a feature is complete

---

## Slash Commands

Location: `{{CLAUDE_HOME}}\commands\<name>.md`. Auto-loaded into every session.

| Command | Pattern | What it does |
|---------|---------|-------------|
| `/startprocess <idea>` | Full lifecycle | Phase 0 (solution-strategist in **main thread**, interactive → prior-art-scout subagent) → 🛑 Gate 0 → Phase 1 (BA → architect) → 🛑 Gate A → Phase 2 (engineers parallel → review → test) → 🛑 Gate B → optional ship. All human interaction front-loaded into discovery. |
| `/spike <question>` | Spike | developer/specialist → minimal throwaway POC → findings report. No contract, no gates. For feasibility unknowns before planning. |
| `/plan-feature <description>` | Phase 1 | business-analyst (**Lean Mode** by default: PRD 1-5 + acceptance; Full Mode on request) → software-architect (architecture, contract, task breakdown, deployment requirements, ADRs) → Gate A |
| `/build-feature [context]` | Phase 2 | [llm-engineer if AI] → developer + frontend-engineer (parallel) → code-reviewer (**executes** lint/typecheck/build, fix loop) → tester (**+ e2e smoke test**) → Gate B → memory harvest |
| `/bugfix <description>` | Pattern 3 | codebase-intelligence → relevant engineer → code-reviewer (fix loop) → tester (regression test) |
| `/refactor <description>` | Pattern 4 | baseline test counts → codebase-intelligence → software-architect → engineers → code-reviewer (focus: no behavior change) → tester (regression) |
| `/review-build [context]` | Standalone | code-reviewer on current implementation |
| `/retro [scope]` | Harvest | distill `specs/journal.md` → `specs/lessons.md` (auto); propose cross-project lessons for approval → `learned-patterns.md` |
| `/ship [context]` | Phase 3 | verify prerequisites → produce deployment artifacts (Dockerfile, build/runtime config, CI) → push via github-sync |
| `/save-session [name]` | Persist | snapshot to `specs/sessions/YYYY-MM-DD-<name>.md` |
| `/resume-session [name]` | Resume | reads session file, summarizes state, asks "Continue?" |

> **Fast Path (Pattern 5):** for small, well-scoped tasks teamlead may run a lighter flow (lean BA → architect-lite → engineer → executive review → smoke test → one light confirm gate). Review + QA are never skipped. Full path is the default.

---

## Always-Active Rules

Location: `{{CLAUDE_HOME}}\rules\<name>.md`. Auto-loaded into every session.

| Rule | What it enforces |
|------|-----------------|
| **contract-first.md** | `specs/contracts/api-contracts.yaml` as single source of truth for all API contracts. Any deviation = defect. Framework validation gotcha (FastAPI Query/Path bypass). |
| **security.md** | OWASP Top 10, no hardcoded secrets, parameterized queries, AuthFactory pattern, AES-256-GCM for secrets at rest, privacy compliance, never `verify=False` |
| **stack-compliance.md** | Canonical stack (FastAPI/Python 3.12/SQLAlchemy 2.0 async, React 18/TS strict/Zustand/TanStack, LiteLLM mandatory, Provider Abstraction, error format, CSS variable design system) |
| **workflow-discipline.md** | Task ownership (software-architect = sole owner of implementation-tasks.json), gates + fast-path carve-out, review-before-QA, executive verification (reviewer runs lint/typecheck/build; tester runs e2e smoke), run isolation, fix loop max 1 cycle, evidence-only |
| **accessibility-i18n.md** | WCAG 2.1 AA, keyboard nav, ARIA, color contrast, semantic HTML, react-i18next (English default) |
| **self-improvement.md** | Journal-during-work (`specs/journal.md`), read `specs/lessons.md` before starting; two-tier memory (project auto, global on approval) |
| **learned-patterns.md** | Cross-project memory — durable lessons for the user's domain, loaded every session. Written only via approved harvest. |

---

## Tools

Location: `{{SQUAD_HOME}}\tools\<name>`.

| Tool | Path | Purpose |
|------|------|---------|
| **lean-canvas.md** | `tools\templates\lean-canvas.md` | Lean Canvas template (blank, for completion) |
| **user-story.md** | `tools\templates\user-story.md` | User Story template with AC and UAT scenarios |
| **test-case.md** | `tools\templates\test-case.md` | Test Case template for UAT |
| **requirements-doc.md** | `tools\templates\requirements-doc.md` | Requirements Document template |

---

## Skills

Location: `{{CLAUDE_HOME}}\skills\<name>\SKILL.md`.

| Skill | Trigger | Purpose |
|-------|---------|---------|
| **github-sync** | (see SKILL.md) | Work with GitHub — sync/push/pull, PRs, branches, issues. Plan-then-confirm. |

---

## Reference Documents (`docs/`)

These documents are not deployed to `~/.claude/` — they stay in the repo and agents reference them.

| Document | Path | Contents |
|----------|------|----------|
| **AGENTS_REGISTRY.md** | `docs/AGENTS_REGISTRY.md` | This file — full team overview |
| **TECH_STACK.md** | `docs/TECH_STACK.md` | Authoritative canonical stack (Backend, LLM Gateway, Auth, Cache, Storage, Vector, Frontend, Design System, Infrastructure, Monorepo) |
| **HANDOFF_PROTOCOL.md** | `docs/HANDOFF_PROTOCOL.md` | How agents communicate through the `specs/` directory. Validation rules, dependency graph, 4-phase workflow, gate procedures (Gate 0/A/B), contract-first protocol |
| **PRE_IMPLEMENTATION_CHECKLIST.md** | `docs/PRE_IMPLEMENTATION_CHECKLIST.md` | 5 questions engineers answer before writing code + adjacency checklist |

---

## How to Add a New Agent

1. Create `claude/agents/<name>.md`
2. Frontmatter:
   ```yaml
   ---
   name: <name>
   description: "Short (max ~250 chars). What it does + key trigger phrases."
   model: sonnet  # or inherit, opus, haiku
   color: <color>
   ---
   ```
3. Body: detailed instructions, Team Collaboration section (reference CLAUDE.md > Agent Roster, do not duplicate), reference `docs/TECH_STACK.md`, `docs/HANDOFF_PROTOCOL.md`, examples (loaded ONLY when the agent is invoked)
4. Add row to this registry
5. Update `claude/CLAUDE.md` (Agent Roster table)
6. Run `.\setup.ps1` locally
7. Commit + push

## How to Add a New Tool

1. Create `tools/<name>.py`
2. CLI interface with `argparse` (input/output args, --help)
3. Add row to this registry

## How to Add a New Skill

1. Create `claude/skills/<name>/SKILL.md`
2. Frontmatter with `name`, `description` (specific trigger phrases!), `version`
3. Body: workflow, usage examples, link to tool if applicable
4. Add row to this registry

## How to Add a New Slash Command

1. Create `claude/commands/<name>.md`
2. Body: what it does, which agents it invokes, expected artifacts, conditions
3. Reference `$ARGUMENTS` placeholder for user input
4. Add row to this registry

## How to Add a New Rule

1. Create `claude/rules/<name>.md`
2. Body: short (≤30 lines), actionable, non-overlapping with other rules
3. Add row to this registry
