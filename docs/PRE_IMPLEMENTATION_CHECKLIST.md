# Pre-Implementation Checklist

> **Engineer reference document** — engineering agents (developer, frontend-engineer, llm-engineer, data-engineer) already have these rules in their prompts. This checklist is also useful for human review by the project lead.

Engineers answer these questions **before writing code** for each task. The goal is to catch contract, spec, and framework mismatches before they become code review findings.

---

## Checklist

### 0. Have I restated the goal, surfaced assumptions, and planned verifiable steps?
Restate the task in one line against the acceptance criteria in `specs/features/<feature>.md`. If anything is ambiguous, **state the assumption explicitly** — do not silently resolve it; a contract or data-shape ambiguity goes to **software-architect** first. For non-trivial tasks, write a short step→verify plan (each step maps to an acceptance criterion + how you'll confirm it) and implement only what the criteria require — no speculative scope. See `rules/execution-fidelity.md`.

### 1. Which error codes does the contract define for my endpoint?
Read `specs/contracts/api-contracts.yaml` — list every error code and HTTP status in the 4xx/5xx responses section for your endpoint. Your implementation must return these exact codes and shapes.

### 2. Could framework-level validation bypass the contract error format?
Many frameworks intercept validation constraints and return errors in their own format (e.g., FastAPI returns HTTP 422 with `{"detail": [...]}` for `Query`/`Path` constraints). If the contract defines a specific error code and HTTP status, use **manual validation in the handler body** so the response matches the contract exactly.

**FastAPI example — wrong:**
```python
@router.get("/search")
async def search(q: str = Query(..., max_length=100)):  # returns 422 in framework format
    ...
```

**FastAPI example — right:**
```python
@router.get("/search")
async def search(q: str):
    if len(q) > 100:
        return _error_response(
            status=400,
            code="SEARCH_TOO_LONG",
            message="Search query exceeds 100 characters",
        )
    ...
```

### 3. Does this feature require persisted UI state?
Read the acceptance criteria in `specs/features/<feature>.md`. If any criterion says state must survive **navigation, page reload, or component unmount** — use a persistence mechanism that satisfies the requirement (URL query parameters via `useSearchParams`, session storage, or app-level state via Zustand). **Do not use `useState`** when ephemeral component state cannot fulfil the acceptance criteria — component state is lost on unmount.

### 4. Are the acceptance criteria stricter than the task summary?
The task description in `implementation-tasks.json` is a summary. The acceptance criteria in the feature spec (`specs/features/<feature>.md`) are the **binding requirement**. Read both. When they conflict, the **feature spec wins**.

### 5. Is there any validation path without a documented contract error?
If you add input validation that can return an error, check that the contract documents the error code for that case. If not — flag to **software-architect** before implementing, so the contract is updated first. An undocumented error code is a contract gap that blocks **tester** from writing assertions against the contract.

---

## Adjacency Checklist (when work crosses domains)

If your task touches an adjacent domain, hand off **before** writing code:

| You touch... | Hand off to... |
|---|---|
| LLM/RAG/prompts/vector store (`backend/app/providers/llm/`, `services/ai/`) | **llm-engineer** |
| OLAP schemas, ETL pipelines, vector bulk ingestion | **data-engineer** |
| Frontend styling/themes, dark/light themes, glassmorphism, design tokens | **frontend-engineer** |
| Architecture/contract change | **software-architect** (updates contract first) |

If you touch only your own domain, proceed.
