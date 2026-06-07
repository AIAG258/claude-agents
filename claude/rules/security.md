## Security Rules — Always Active

OWASP Top 10 — applies to all engineering agents and code review.

- **Never hardcode** secrets, tokens, API keys, or credentials in source code. Use `.env` (gitignored) for dev, Secret Manager / Key Vault / Workload Identity for prod.
- **Never log** sensitive data — passwords, tokens, PII, full request bodies that may contain credentials.
- **Parameterized queries only** — no raw SQL string interpolation. Use SQLAlchemy `text()` with bound parameters or ORM methods.
- **API input validation** — Pydantic v2 (backend) or Zod (frontend) on every endpoint and form. Validate at the system boundary.
- **Auth behind an interface** — keep auth behind a factory/provider layer. Never import auth SDKs (`msal`, `ldap3`, `authlib`, etc.) directly in business logic; isolate them in the auth layer. Auth code is owned by **developer**.
- **Encryption at rest** — secrets and config files encrypted with AES-256-GCM. Master key from `DATA_DIR/master.key` or Secret Manager.
- **Privacy compliance** — personal data handling must be explicit and documented. Right to erasure, data minimization, purpose limitation. Apply applicable privacy regulations (GDPR, CCPA, etc.) for your deployment jurisdiction.
- **TLS verification ON** — never `verify=False` on `httpx`/`requests` in production code. For custom CA chains, point the client at a CA bundle (`verify="/path/to/ca.pem"` or `REQUESTS_CA_BUNDLE`/`SSL_CERT_FILE`) instead of disabling verification.
- **No SSL/TLS bypass** in code committed to repo — even for "testing".
