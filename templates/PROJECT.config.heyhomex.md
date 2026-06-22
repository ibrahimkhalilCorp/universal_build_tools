# PROJECT.config.md — FILLED EXAMPLE (HeyHomeX)

> This shows what a completed config looks like. Copy `../PROJECT.config.md`,
> not this file, into a new project — this is reference only.

---

## VOICE
VOICE: banglish

## PROJECT
- PROJECT_NAME: HeyHomeX
- ONE_LINE_GOAL: Hawaii-focused real estate search — MLS pipeline + hybrid search API (embedding + BM25 + lifestyle scoring)
- OWNER: Ibrahim Khalil
- PROJECT_MODE: brownfield
- CURRENT_PHASE: codegen
- REPO_LAYOUT: monorepo — `mls_pipeline/` · `homex_api/` · `shared/`

## TECH_STACK
- Language: Python 3.11
- Framework: FastAPI + uvicorn
- Datastore: OpenSearch (hybrid kNN + BM25, RRF fusion); SQLite → PostgreSQL pending
- Cache: Redis (query results, embeddings)
- AI/ML: OpenAI (embeddings, descriptions) · Perplexity Sonar (lifestyle reports)
- External services: RETS / HiCentral MLS · Contabo S3 (photos)
- Tests: pytest + pytest-asyncio
- Lint/Type: ruff · mypy

## STRUCTURE_RULES
- `shared/` — used by both packages; no FastAPI or MLS imports here
- `mls_pipeline/` — pipeline orchestration, MLS fetch, enrichment, indexing
- `homex_api/` — FastAPI app, routers, search service, auth
- Each module follows `router.py · service.py · schemas.py`

## NAMING
- Files: snake_case.py
- Classes: PascalCase
- Constants: UPPER_SNAKE_CASE in `shared/constants.py`
- Env vars: all in a `Config` class — no bare `os.getenv()` in business logic

## DOMAIN_RULES
- MLS listing price `$0` is valid (foreclosure auction)
- Location scoring uses Haversine, never Euclidean (3–5% error at Hawaii lat/lng)
- Cities come from `HAWAII_CITIES` set in `shared/constants.py`
- Budget: raw value `< 10_000` means thousands (e.g. 800 → $800k)

## DO
- Update the tracker every session
- One component per session
- Flag hardcoded IP/credentials immediately
- When a scoring formula changes, update research_report

## DONT
- Business logic in `main.py`
- Bare `os.getenv()` in `service/`
- Change a scoring formula without a test
- Commit `__pycache__/`
- Bare `except:`

## FLAG_ON_SIGHT
- 194.233.87.99
- any hardcoded API key / password
- inline HTML inside main.py

## KNOWLEDGE_GRAPH
- TOOL: graphify
- OUT_DIR: graphify-out/
- QUERY_CMD: graphify query "<question>"

## REPORT_INPUTS
- WALKTHROUGH_SUBJECT: the MLS → API journey (raw RETS → enriched → embedded → indexed → search / details / lifestyle)
- SAMPLE_DATA_PATHS: mls_raw_*.json, mls_enriched_*.json, *_with_embeddings.json, nearby_places_cache.json, pipeline_cache.json, geocode_cache.json
- KNOWN_ISSUES_SOURCE: F-xx fix markers in source + tracker

## GIT_RULES
- No Co-authored-by attribution on commits
