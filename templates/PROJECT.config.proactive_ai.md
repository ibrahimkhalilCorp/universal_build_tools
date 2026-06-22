# PROJECT.config.md — FILLED (Proactive AI)

> Filled from the project's own docs (README, UserManual, ProactiveAiApiGuide,
> apiend, RESTRUCTURING_GUIDE), v3.2. Verify any `TODO` against the repo before a
> full run. Copy this to the repo root (or `_build_tools/`) as `PROJECT.config.md`.

---

## VOICE
VOICE: banglish

## PROJECT
- PROJECT_NAME: Proactive AI
- ONE_LINE_GOAL: Multi-tenant recommendation platform — auto-ML training (benchmark + Optuna tune), tenant-scoped model registry, promotion/deployment control plane, and authenticated recommendation serving
- OWNER: Ibrahim Khalil
- CURRENT_PHASE: codegen
- REPO_LAYOUT: two top-level apps — `backend/` (FastAPI API, training pipeline, tenants, model registry, deployment, SmartDB) and `frontend/` (Vite/React dashboard served at /app)

## TECH_STACK
- Language: Python 3.11+
- Framework: FastAPI + Pydantic v2 + Uvicorn (backend); React 18 + Vite + React Router + Framer Motion + Recharts (frontend)
- Datastore: tenant-scoped filesystem store under `backend/tenants/<tenant_id>/` (configs, data, models, deployment + job state)
- Cache: Redis + RQ (optional — for persistent jobs + background worker; without it jobs are in-memory and lost on restart)
- AI/ML: NumPy · Pandas · SciPy · scikit-learn · Optuna (tuning); algorithms ALS / BPR / SVD via ALGORITHM_REGISTRY; optional Anthropic Claude for SmartDB query planning + LLM explanations
- External services: SQL connectors (SQLAlchemy, psycopg2, PyMySQL) + NoSQL (MongoDB, DynamoDB) via SmartDB
- Tests: pytest (in `backend/tests/`)
- Lint/Type: TODO — confirm from repo (ruff / mypy not stated in docs)

## STRUCTURE_RULES
- `backend/api/routes/` = validation + transport only; response shapes assembled in `backend/core/*` service files (keep this split)
- `backend/api/gateway/` = auth, tenant context injection, metering, rate limiting
- `backend/core/` subsystems: `pipeline/` (training+serving orchestration), `recommendation/` (strategy + ensemble + inference), `deployment/` (active state, history, rollback), `tenants/` (config, cache, dirs, request context)
- `backend/app_factory.py` assembles middleware/routes/admin/SmartDB/static/Swagger/frontend — keep assembly here, not scattered
- SmartDB lives in `backend/smart_db_csv_builder/`, mounted under `/smart-db-csv/api/...`
- Per-tenant artifacts always under `backend/tenants/<tenant_id>/` — never cross tenant boundaries
- HISTORY: this is a v2→v3 restructure (single-tenant monolith → multi-tenant modular). v2's flat dirs (algorithms/, benchmark/, pipeline/, recommendation/, insights/, optimization/, data_processing/) were relocated under `core/`; v2 `ingestion/` became `smart_db_csv_builder/`; v2 `api/routes.py` split into `api/gateway/` (auth, middleware, metering — all NEW) + `api/routes/`; v2 `main.py` split into `main.py` + `app_factory.py`. The `tenants/` isolation layer is entirely new in v3.

## NAMING
- Files: snake_case.py
- Classes: PascalCase
- Constants: UPPER_SNAKE_CASE (e.g. `ALGORITHM_REGISTRY`, `RATE_LIMIT_RPM`, `MIN_USER_INTERACTIONS`)
- Env vars: settings in `backend/config/settings.py`; feature flags `USE_V3_AUTH / USE_V3_MULTITENANCY / USE_V3_METERING / USE_V3_ROUTES`

## DOMAIN_RULES
- Two auth modes, never mix: admin routes (`/admin/...`) use JWT Bearer from `POST /admin/auth/login`; tenant runtime routes use raw `X-API-Key` (starts with `pai_`)
- Tenant API key is shown EXACTLY ONCE at creation — response carries a "save it now" warning; never recoverable, only rotatable
- Hard tenant isolation: a tenant's data/models/config/deployment must never be readable across tenants (wrong-tenant access → 403)
- Scope hierarchy: `admin:write` expands to all scopes; `admin:read` → `recommend:read` + `models:read`
- Allowed enums are strict: `top_k` / `top_n` / `top_models` ∈ {5, 10}; `algorithm_mode` ∈ {explicit, implicit, hybrid, auto}
- Recommendations need the user to have ≥ MIN_USER_INTERACTIONS (default 3) OR a promoted model — else empty
- Job state v3 = {pending, running, completed, failed}; older/SmartDB jobs use {pending, running, done, failed} — do NOT conflate the two vocabularies
- Rate limit per tenant = `RATE_LIMIT_RPM` (default 60); exceeding → 429
- Deletion rule: a running/pending job cannot be deleted → 409

## DO
- Update the tracker every session
- One subsystem/route/service per session
- Keep route files thin; put response-shape logic in `core/*` services
- Add/adjust a test when changing scoring, strategy, promotion, or deployment-rollback logic
- Treat the once-only API key as a secret in every code path

## DONT
- Put response-assembly business logic in `api/routes/*` (belongs in `core/*`)
- Let tenant data leak across tenants
- Ship `reload=True` Uvicorn to production (dev-only)
- Commit `.env`
- Assume jobs persist without Redis/RQ (they don't)
- Bare `except:` around training/serving (hides job-failure signal)

## FLAG_ON_SIGHT
- default admin creds in non-dev config: `admin` / `admin123`
- `AUTH_SECRET_KEY=replace-me-in-production` (or empty) outside local dev
- any committed `.env` or hardcoded DB password / API key
- the double-`/admin` webhook path `/admin/admin/tenants/{id}/webhook` (real routing quirk — flag for a fix, don't silently copy)
- wildcard CORS in production (`CORS_ORIGINS`)

## KNOWLEDGE_GRAPH
- TOOL: none        <!-- set to graphify + graphify-out/ if you wire it up -->
- OUT_DIR: —
- QUERY_CMD: —

## REPORT_INPUTS
- WALKTHROUGH_SUBJECT: the training-to-serving lifecycle — upload/SQL ingest → feedback profiling (explicit vs implicit) → cleaning → interaction-matrix build → multi-algorithm benchmark (NDCG@K, HitRate@K) → Optuna tuning → tenant model registry → promotion to deployment control plane → recommendation serving (best_promoted / single_model / ensemble_weighted) → explain. Plus the request path: X-API-Key/Bearer → gateway auth + scope check + tenant context + metering/rate-limit → route → core service → response.
- SAMPLE_DATA_PATHS: sample_data/ratings.csv (a ratings CSV with user_id,item_id,rating — the hero dataset the journey runs on; see UserManual Step 4). Also: tenant artifacts under backend/tenants/<tenant_id>/; sample API request/response bodies in ProactiveAiApiGuide.md. If no CSV is present, generate dummy rows matching this schema and mark DATA_MODE="dummy".
- KNOWN_ISSUES_SOURCE: documented quirks (double-`/admin` webhook path, in-memory job volatility without Redis, dev `reload=True`, default admin creds, no committed `.env.example`) + GitHub issues + TODO/FIXME in source

## GIT_RULES
- Do not add Co-authored-by attribution to commits
