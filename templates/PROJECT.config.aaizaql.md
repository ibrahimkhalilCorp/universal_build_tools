# PROJECT.config.md — FILLED (AaizaQL)

> Pre-filled from the public PyPI page (aaizaql 0.1.2). Verify the —/TODO fields
> against the actual repo before a full run, since some internals aren't public.
> Copy this to your repo root as `PROJECT.config.md`.

---

## VOICE
VOICE: banglish

## PROJECT
- PROJECT_NAME: AaizaQL
- ONE_LINE_GOAL: Open-source Natural-Language→SQL Python library — RAG, self-correction, SQL security gate, multi-turn memory, plugin connectors, query federation
- OWNER: Ibrahim Khalil
- CURRENT_PHASE: codegen
- REPO_LAYOUT: single Python package — `aaizaql/` (core, connectors, llm, security, memory, rag), `tests/`

## TECH_STACK
- Language: Python 3.11+ (3.11 / 3.12 / 3.13)
- Framework: library (no web framework in core); CLI via `aaizaql query`
- Datastore: target DBs via connectors — SQLite, PostgreSQL, MySQL, Snowflake, DuckDB
- Cache: — (session history kept in-memory, limit AAIZAQL_SESSION_HISTORY_LIMIT)
- AI/ML: LLM providers — Groq (default), Anthropic Claude, OpenAI, Ollama (local); vector store Chroma or Qdrant for RAG
- External services: LLM provider APIs; `sqlglot` for SQL parsing
- Tests: pytest
- Lint/Type: ruff · mypy   <!-- TODO: confirm from repo -->

## STRUCTURE_RULES
- Connectors implement `DatabaseConnector` (connect / execute / get_schema) and register in `connectors.REGISTRY` — adding a DB needs zero core changes
- LLM providers behind a provider interface; selected via `AAIZAQL_LLM_PROVIDER`
- Security gate is a mandatory stage every generated SQL passes before execution
- Config read from `AAIZAQL_*` env vars OR passed to `QueryEngine(...)` — single config surface

## NAMING
- Files: snake_case.py
- Classes: PascalCase (e.g. `QueryEngine`, `DatabaseConnector`)
- Constants: UPPER_SNAKE_CASE
- Env vars: all prefixed `AAIZAQL_`, resolved in one config layer (no bare os.getenv in core logic)

## DOMAIN_RULES
- SQL whitelist: only `SELECT` and `WITH` may execute — everything else rejected
- Multi-statement blocking: e.g. `SELECT 1; DROP TABLE x` must be rejected
- Prompt-injection scan runs on the user's NL question before generation
- Structural parse via `sqlglot` to catch disguised dangerous statements (not just regex)
- Enum/code mappings are ALWAYS injected into context, never left to RAG to maybe-retrieve
- Self-correction loop: on DB error, feed error back to LLM and retry up to AAIZAQL_MAX_SELF_CORRECTION_RETRIES (default 3)
- Per-user credential delegation (do NOT share one DB cred across users — the Vanna CVE-2024-5565 class of bug)

## DO
- Update the tracker every session
- One module/connector/provider per session
- Every generated SQL must pass the security gate before execute — no bypass path
- Add a test when changing the security gate, self-correction, or enum-injection logic

## DONT
- Let any non-SELECT/WITH statement reach the DB
- Hardcode an API key or DSN in source — env/config only
- Share a single DB credential across users
- Bare `except:` around SQL execution (swallowing errors breaks self-correction)
- Trust RAG alone for enum/code mappings

## FLAG_ON_SIGHT
- any hardcoded LLM API key (gsk_…, sk-…) or database DSN literal
- raw string-concatenated SQL built from user input (injection path)
- an execute path that skips the security gate

## KNOWLEDGE_GRAPH
- TOOL: graphify        <!-- if you set it up for this repo; else: none -->
- OUT_DIR: graphify-out/
- QUERY_CMD: graphify query "<question>"

## REPORT_INPUTS
- WALKTHROUGH_SUBJECT: the NL→SQL→result journey — user question → injection scan → RAG context + enum injection → LLM SQL generation → security gate (whitelist / sqlglot parse / multi-statement block) → execute on connector → self-correction retry loop → DataFrame + chart + summary
- SAMPLE_DATA_PATHS: tests/fixtures/ (sample schema + Q→SQL pairs); use the README's sales.db-style example as the hero query "Show top 5 customers by revenue last quarter"
- KNOWN_ISSUES_SOURCE: GitHub issues + TODO/FIXME in source + the Vanna-vs-AaizaQL comparison (security gaps it explicitly fixes)

## GIT_RULES
- Do not add Co-authored-by attribution to commits
