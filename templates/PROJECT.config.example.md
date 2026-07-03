# PROJECT.config.md — FILLED EXAMPLE (TaskFlow API — generic)

> A simple, neutral example so you can see the shape on an ordinary project.
> For a richer real-world example with domain rules and scoring formulas, see
> `PROJECT.config.heyhomex.md`. Copy `../PROJECT.config.md` into your project —
> these two are reference only.

---

## VOICE
VOICE: english

## PROJECT
- PROJECT_NAME: TaskFlow
- ONE_LINE_GOAL: A small team task-tracking API — projects, tasks, assignees, due dates, comments
- OWNER: (your name)
- PROJECT_MODE: greenfield
- CURRENT_PHASE: codegen
- REPO_LAYOUT: single app — `app/` with module folders, `tests/`

## TECH_STACK
- Language: Python 3.11
- Framework: FastAPI + uvicorn
- Datastore: PostgreSQL (SQLAlchemy)
- Cache: Redis (sessions, rate limiting)
- AI/ML: —
- External services: SendGrid (email notifications)
- Tests: pytest
- Lint/Type: ruff · mypy

## STRUCTURE_RULES
- Each feature is a module: `app/<feature>/` with `router.py · service.py · schemas.py`
- DB models in `app/<feature>/models.py`; no business logic in models
- Shared helpers in `app/core/`; no feature imports inside `core/`

## NAMING
- Files: snake_case.py
- Classes: PascalCase
- Constants: UPPER_SNAKE_CASE in `app/core/constants.py`
- Env vars: all read in `app/core/config.py` — no bare `os.getenv()` in services

## DOMAIN_RULES
- A task cannot be assigned to someone who is not a member of its project
- Due dates are stored in UTC; never store naive datetimes
- A completed task is immutable except for its `comments`
- Overdue = `due_date < now()` AND status != "done"

## DO
- Update the tracker every session
- One module/component per session
- Validate every request body with a Pydantic schema
- Write a happy + edge + failure test per endpoint

## DONT
- Business logic in `main.py`
- Raw f-string SQL — use parameterized queries / the ORM
- Bare `except:`
- Commit `__pycache__/` or `.env`

## FLAG_ON_SIGHT
- any hardcoded password / API key / connection string
- a literal database URL in code instead of `Config`

## KNOWLEDGE_GRAPH
- TOOL: none
- OUT_DIR: —           <!-- if graphify: graphify-out/ -->
- QUERY_CMD: —         <!-- if graphify: graphify query "{{question}}" --graph graphify-out/graph.json -->

## REPORT_INPUTS
- WALKTHROUGH_SUBJECT: the request lifecycle (auth → validate → service → DB → response) for "create task" and "list overdue tasks"
- SAMPLE_DATA_PATHS: tests/fixtures/*.json
- KNOWN_ISSUES_SOURCE: GitHub issues + TODO/FIXME markers in source

## GIT_RULES
- Conventional commit messages (feat: / fix: / chore:)