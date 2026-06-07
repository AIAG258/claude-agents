# AI R&D Squad — Canonical Tech Stack

> **Authoritative source** for the canonical tech stack.
> All agents reference this file. Do not duplicate this content in agent prompts.

Last updated: 2026-05-07 | Version: 2.1.0

> **Platform-agnostic principle:** Applications are built so they can deploy to any cloud (GCP, AWS, Azure) or on-prem. All cloud services accessed via Provider Abstraction pattern — application code never imports cloud SDKs directly.

---

## Backend

| Layer | Technology | Version | Notes |
|---|---|---|---|
| Framework | FastAPI | 0.115+ | Async-first, auto OpenAPI, Pydantic integration |
| Runtime | Python | 3.12+ | Modern typing (`X \| Y`, not `Union[X, Y]`) |
| ASGI server | Uvicorn | 0.32+ | Production-grade async ASGI |
| Config/validation | Pydantic v2 | 2.10+ | `model_validate`, not `parse_obj` |
| ORM | SQLAlchemy | 2.0+ async | `AsyncSession` + `async_sessionmaker` |
| DB migrations | Alembic | 1.14+ | Auto-generate; run on startup |
| PostgreSQL driver | asyncpg | 0.30+ | Fastest async PostgreSQL driver |
| SQL Server driver | pymssql | 2.3+ | Legacy systems — no ODBC dependency |
| Managed DB connector | cloud-sql-python-connector / platform equivalent | — | Secure managed-DB connection (when applicable) |
| HTTP client | httpx | 0.23+ | Async; **pin <0.28 with LiteLLM** |
| Encryption | cryptography | 43+ | AES-256-GCM for secrets at rest |
| Testing | pytest + pytest-asyncio | 8+ / 0.25+ | Async test support |
| Env vars | python-dotenv | 1.0+ | Local `.env` loading |

---

## LLM Gateway

**LiteLLM is mandatory.** Never call provider SDKs directly.

| Layer | Technology | Version | Notes |
|---|---|---|---|
| LLM gateway | LiteLLM | 1.55+ | **Mandatory** |
| Provider SDKs | openai, google-cloud-aiplatform, etc. | — | Called by LiteLLM internally |
| Cloud auth | Platform-specific auth library | — | Service account / Workload Identity / managed identity |

```python
# CORRECT — same code for all providers
await litellm.acompletion(model="azure/gpt-4o", messages=[...])
await litellm.acompletion(model="vertex_ai/gemini-1.5-pro", messages=[...])
await litellm.acompletion(model="bedrock/anthropic.claude-v2", messages=[...])

# WRONG — never this
from openai import AsyncOpenAI
import anthropic
```

### Model Tiers

| Tier | When | Examples |
|---|---|---|
| Heavy reasoning | Complex analysis, multi-step reasoning | `azure/gpt-4o`, `vertex_ai/claude-opus-4-6`, `bedrock/claude-opus-4-6` |
| Balanced | Most production use cases | `azure/gpt-4o-mini`, `vertex_ai/gemini-1.5-pro` |
| Simple / high-volume | Classification, extraction, throughput | `azure/gpt-35-turbo`, `vertex_ai/gemini-1.5-flash` |

---

## Auth

**Pattern**: `AuthProtocol` → concrete providers → `AuthFactory.create(type)`

Business logic **never** imports auth SDKs directly. Concrete providers configured per-project.

| Provider | Technology | When |
|---|---|---|
| Microsoft Entra ID (Azure AD) | MSAL 1.31+ | Cloud-hosted apps, Office365 integration |
| On-premise LDAP/AD | ldap3 2.9+ | On-prem or hybrid deployments |
| OIDC (alternative) | oidc-client-ts, Okta SDK, Keycloak | When neither MSAL nor ldap3 fits |
| Custom JWT | PyJWT / jose | When OIDC/LDAP unavailable |

Owned by **developer** — keep all auth SDKs isolated behind the auth layer.

### Frontend Auth

Library depends on identity provider:
- OIDC (Entra ID, Okta, Keycloak): `@azure/msal-react`, `oidc-client-ts`, `@auth0/auth0-react`
- Always redirect-based login, not popup.

---

## Cache & Database

| Service | Technology | Notes |
|---|---|---|
| Cache | Redis 7+ | Optional — app degrades gracefully without it |
| Python client | redis 5.2+ | `redis.asyncio` for async |
| Database | PostgreSQL 16+ | JSONB, ACID, async support |

---

## Storage Providers

**Pattern**: `StorageProvider` interface (`.upload()`, `.download()`, `.delete()`) → `StorageFactory.create(type)`

| Provider | Technology | When |
|---|---|---|
| GCS (primary) | google-cloud-storage 2.18+ | GCP-hosted projects |
| S3-compatible | boto3 1.35+ | S3, MinIO, on-prem object storage |
| Azure Blob | azure-storage-blob 12.22+ | Azure-hosted projects |

---

## Vector Store

**Pattern**: `VectorProvider` interface (`.upsert()`, `.search()`, `.delete()`) → factory selects implementation.

| Provider | Technology | When |
|---|---|---|
| Self-hosted / Cloud | qdrant-client 1.12+ | Local dev, on-prem, managed Qdrant |
| GCP managed | google-cloud-aiplatform | Vertex AI Matching Engine |

---

## Frontend

| Layer | Technology | Version | Notes |
|---|---|---|---|
| Framework | React | 18+ | Hooks-based |
| Language | TypeScript | 5.6+ | Strict mode mandatory |
| Build tool | Vite | 6.0+ | Fast HMR, ESM-native |
| Client state | Zustand | 5.0+ | Auth/app state |
| Server state | TanStack Query | 5.60+ | All API/server data |
| Forms | React Hook Form | 7.53+ | No re-render per keystroke |
| Schema validation | Zod | 3.23+ | Define once → form + TS types via `z.infer<>` |
| Routing | React Router DOM | 7.0+ | SPA routing |
| Prod server | Nginx | — | Static serving + reverse proxy to API |
| E2E testing | Playwright | 1.58+ | Cross-browser, TypeScript-native |
| Component testing | Vitest + Testing Library | latest | Unit + component tests |
| Auth | Per-project library | — | See Auth section |
| Visual style | **Configurable design system** | — | Dark (glassmorphism) and light (subtle shadows) variants via CSS custom properties. Brand color via `--brand-accent`. Owned by **frontend-engineer**. |
| i18n | react-i18next | latest | English default. Add locales in `frontend/src/locales/{en,...}.json` as needed. |

---

## Design System

Two theme variants. Brand color is set via `--brand-accent` CSS variable — replace with your value.

| Variant | Use cases | Key tokens |
|---|---|---|
| **Dark** | AI tools, dashboards, dev panels | bg `#0a0a0a`/`#050508`/`#111114`, surface `rgba(255,255,255,0.05)`, glassmorphism with `backdrop-filter: blur(12px)`, white text |
| **Light** | Documentation portals, content-heavy interfaces, accessibility-priority | bg `#ffffff`/`#fafafa`/`#f5f5f7`, surface `#ffffff` with subtle shadows, `#1a1a1a` text, NO glassmorphism |

CSS strategy: `[data-theme="dark"]` / `[data-theme="light"]` on root with custom properties — components write generic style. Set `--brand-accent: <your-color>` in the root to configure branding.

---

## Infrastructure

### Cloud Services (Platform-Agnostic)
| Category | Purpose | Examples |
|---|---|---|
| Containerization | Docker + Docker Compose | Same image dev and prod |
| Container platform | Deployment target | Cloud Run, container hosts, ECS/Fargate, Kubernetes, PaaS |
| Container registry | Docker image storage | Artifact Registry, ECR, ACR, self-hosted registry |
| Managed database | Managed PostgreSQL 16+ | Cloud SQL, RDS, Azure DB for PostgreSQL |
| Secrets management | Production secrets | Secret Manager, AWS Secrets Manager, Azure Key Vault |
| Object storage | File/object storage | GCS, S3, Azure Blob |

### Local Dev
| Layer | Technology | Notes |
|---|---|---|
| Local dev | docker-compose.dev.yml | Adds PostgreSQL + Redis |
| Production | docker-compose.yml | Standalone (backend + frontend) for non-K8s targets |

### CI/CD
**GitHub Actions** (default). GitHub ops via the **github-sync** skill (plan-then-confirm).

Mandatory pipeline stages: `build → lint → test (pytest + Playwright) → security scan (Trivy + Bandit) → deploy`

### Deployment
The `/ship` command produces deployment artifacts (Dockerfile, build/runtime config, env/secrets checklist, CI workflow) and pushes via github-sync. The actual deploy — Cloud Run, a container host, or another PaaS — is run by the user or their CI, matched to the chosen platform.

### Rollback
Use platform-native rollback (Cloud Run: revision traffic shifting; container hosts: redeploy previous image tag; PaaS: deployment slots). Document specific rollback commands in the deployment RUNBOOK.

---

## Canonical Monorepo Structure

```
project-name/
├── backend/
│   ├── app/
│   │   ├── api/v1/            # FastAPI routers, one per domain
│   │   ├── auth/              # AuthProtocol + concrete providers + AuthFactory
│   │   ├── config/            # Config loader + AES-256-GCM encryption
│   │   ├── core/              # Security utils, exceptions, bootstrap logic
│   │   ├── models/            # SQLAlchemy 2.0 async models (OLTP — developer-owned)
│   │   ├── providers/
│   │   │   ├── llm/           # LiteLLM provider (llm-engineer-owned)
│   │   │   ├── storage/       # Storage provider implementations
│   │   │   ├── vector/        # Vector provider implementations (llm-engineer-owned)
│   │   │   └── cache/         # Redis provider
│   │   └── services/
│   │       ├── ai/            # AI service logic (llm-engineer + developer shared)
│   │       └── [domain]/      # Business logic per domain (developer-owned)
│   ├── alembic/               # DB migrations (run on startup)
│   └── tests/
│       ├── unit/
│       ├── integration/
│       └── contract/          # Contract compliance tests
├── frontend/
│   └── src/
│       ├── api/               # API client + typed endpoint functions
│       ├── components/
│       │   └── ui/            # Base UI primitives (dark / light themed)
│       ├── hooks/             # Custom React hooks
│       ├── pages/             # Route-level page components
│       ├── stores/            # Zustand stores (auth, app state)
│       └── locales/           # i18n — en.json + additional locales as needed
├── infra/
│   └── docker/
│       ├── docker-compose.yml
│       ├── docker-compose.dev.yml
│       └── .env.example
├── deploy/                    # Deployment config (when needed — Dockerfile, CI, platform config)
├── specs/                     # File-based agent handoff (see HANDOFF_PROTOCOL.md)
└── docs/
    ├── ARCHITECTURE.md
    ├── API.md
    ├── DEPLOYMENT.md
    └── CONTEXT.md
```

---

## Key Architectural Patterns

### 1. Provider Abstraction (Strategy + Factory)
```
providers/<category>/
├── protocol.py        # Abstract interface (Protocol class)
├── factory.py         # Factory.create(type, config) → provider
├── <provider_a>.py
└── <provider_b>.py
```
Business logic only imports the Protocol. Never imports concrete providers outside the factory.

### 2. Two-Phase Startup (Bootstrap Pattern)
```
Deploy → config.enc exists?
  NO  → Setup Mode  (Wizard → writes encrypted config.enc)
  YES → Operational Mode (decrypt → DB connect → Alembic → Redis → ready)
```
Config in `config.enc` (AES-256-GCM). Never store initial config in DB.

### 3. OLTP/OLAP Boundary
- **OLTP** (transactional schemas) → `backend/app/models/` → **developer**
- **OLAP** (analytical schemas, AI datasets) → analytical models or separate schema → **data-engineer**

### 4. Health Check Contract
```
GET /health → {"status": "ok", "version": "x.y.z"}
GET /ready  → {"status": "ok", "db": "ok", "redis": "ok|degraded|unavailable"}
```
