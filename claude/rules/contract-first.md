## Contract-First Rule

`specs/contracts/api-contracts.yaml` is the **single source of truth** for all API interfaces.

- All endpoints, request/response schemas, status codes, error codes, and auth requirements are defined in this file (OpenAPI 3.1 format)
- Backend routes (FastAPI), Pydantic models, frontend API calls, TypeScript types, and Zod schemas must match the contract exactly
- Any deviation from the contract is a defect
- To add or change an endpoint, update the contract via **software-architect** first — never implement an uncontracted endpoint
- **code-reviewer** validates contract compliance; **tester** writes contract compliance tests against it
- **Framework validation gotcha:** when contract defines a specific error code at HTTP 4xx with `ErrorResponse` shape, do NOT use FastAPI `Query`/`Path` constraints (`min_length`, `max_length`, `regex`, `ge`, `le`) — they return HTTP 422 in framework's `{"detail": [...]}` format and bypass the contract. Use explicit manual validation in handler body.

If `specs/contracts/api-contracts.yaml` does not exist (ad-hoc work, prototypes, internal-only utilities), this rule does not apply — but flag any work that crosses the API boundary as needing contract definition.
