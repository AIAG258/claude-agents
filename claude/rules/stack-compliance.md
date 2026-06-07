## Stack Compliance Rules — Always Active

Canonical stack — authoritative source: **`docs/TECH_STACK.md`**.

### Backend
- **FastAPI + Python 3.12 + SQLAlchemy 2.0 async**
- Layering: `api/v1/` → `services/` → `models/`. Routes = HTTP only. Services = business logic. No DB queries in routes.
- **LiteLLM mandatory** for all LLM calls — never import `openai`, `anthropic`, `google.generativeai` directly. Pin `httpx<0.28`.
- **StorageProvider** interface — never import `boto3`, `google.cloud.storage`, `azure.storage.blob` directly in business logic.
- **VectorProvider** interface — never instantiate `qdrant-client` directly in services.
- Provider Abstraction (Strategy + Factory) for all external services.
- Async endpoints (`async def`).
- Type hints on all signatures, docstrings on public functions.

### Frontend
- **React 18 + TypeScript strict + Vite + Zustand + TanStack Query**
- Zustand for auth/app state. TanStack Query for server data. **No Redux**.
- React Hook Form + Zod for all forms — `z.infer<>` for type derivation.
- TanStack Query for data fetching — **never `useEffect + fetch`**.
- Configurable design system: dark and light theme variants via CSS custom properties. Brand color and theme names configured per project. Owned by **frontend-engineer**.
- CSS custom properties + `[data-theme="dark"|"light"]` (or project-specific names) for theme switching.

### Error Format
All API error responses must match the contract `ErrorResponse` schema:
```json
{"error": {"code": "MACHINE_READABLE_CODE", "message": "Human-readable message", "details": [...]}}
```

### Free choice — no ADR needed
The user's explicit instruction wins immediately for these, and agents adopt it without ceremony:
- **Hosting / deployment target** — Cloud Run, Vercel, Railway, Fly.io, Render, container hosts, etc. `/ship` produces artifacts matched to whatever the user picks.
- **Database / backend-as-a-service** — Supabase, Neon, managed Postgres, PlanetScale, etc. Prefer accessing SQL through SQLAlchemy; when the user picks a BaaS (e.g. Supabase auth/storage/realtime), using that provider's SDK is acceptable — keep it tidy behind a small module rather than scattered through business logic.

When the user names one of the above, just use it. No ADR.

### Requires ADR
Bigger pivots away from the core language/framework still need an explicit ADR in `specs/adr/` with trade-off analysis, authorized by **software-architect**:
- Swapping the **backend framework/language** (e.g. FastAPI → Django/Node/Go).
- Swapping the **frontend framework** (e.g. React/Vite → Next.js/Svelte/Vue).
- Dropping a core cross-cutting pattern (LiteLLM gateway, error format) without replacement.

If unsure whether something needs an ADR, default to: hosting + DB = free, language/framework core = ADR.
