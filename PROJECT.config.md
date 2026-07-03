# PROJECT.config.md — ⭐ EDIT THIS ONE FILE PER PROJECT

> This is the single source of truth for the build toolkit. Every prompt reads it.
> Fill every field. Leave a field as `—` only if it genuinely does not apply.
> Placeholders referenced by prompts look like `{{FIELD_NAME}}`.

---

## VOICE
<!-- banglish | english | bilingual -->
VOICE: banglish

## PROJECT
- PROJECT_NAME: 
- ONE_LINE_GOAL: 
- OWNER: 
- PROJECT_MODE: <!-- greenfield (নতুন, code নেই) | brownfield (existing repo, code আছে) -->
- CURRENT_PHASE: <!-- user_stories | architecture | abstract_design | codegen | research_report | security_test -->
- REPO_LAYOUT: <!-- monorepo packages OR single app; list top-level dirs -->

## TECH_STACK
<!-- one per line: "Area: choice" -->
- Language: 
- Framework: 
- Datastore: 
- Cache: 
- AI/ML: 
- External services: 
- Tests: 
- Lint/Type: 

## STRUCTURE_RULES
<!-- where things go; the module pattern; what lives in shared/core -->
- 
- 

## NAMING
- Files: 
- Classes: 
- Constants: <!-- where they live -->
- Env vars: <!-- where they're read; ban bare os.getenv in business logic? -->

## DOMAIN_RULES
<!-- the non-obvious, project-specific truths that code MUST encode.
     HeyHomeX examples: "price $0 valid (foreclosure)", "Haversine not Euclidean",
     "budget < 10_000 means thousands". Put YOUR equivalents here. -->
- 
- 

## DO
- 
- 

## DONT
<!-- include any string that should be auto-flagged on sight,
     e.g. a hardcoded IP/credential, a forbidden import, inline HTML in main.py -->
- 
- 

## FLAG_ON_SIGHT
<!-- exact strings/patterns to flag immediately if seen in code -->
- 

## KNOWLEDGE_GRAPH
<!-- Graphify (বা similar) use করলে ভরো; নাহলে TOOL: none রাখো।
     _base.md §1a এই field গুলো দিয়ে কাজের আগে graph থেকে grounding টানে (SOFT)।
     Graphify হলে নিচের exact syntax টাই ব্যবহার করো — `graphify update` AST-only
     (কোনো LLM key লাগে না) এবং build.sh codegen phase এ নিজে চালায়। -->
- TOOL: none           <!-- graphify | none -->
- OUT_DIR:             <!-- graphify হলে: graphify-out/ (এটাই CLI-র default) -->
- QUERY_CMD:           <!-- graphify হলে: graphify query "{{question}}" --graph graphify-out/graph.json -->

## SPEC
<!-- Built-in OpenSpec-style spec layer। External CLI লাগে না।
     _base.md §1b এই folder থেকে project.md + active change এর delta পড়ে (SOFT)। -->
- DIR: openspec/       <!-- spec root; default openspec/ -->
- ACTIVE_CHANGE:       <!-- এখন যে change এ কাজ হচ্ছে, e.g. add-user-auth (খালি = none) -->

## REPORT_INPUTS
<!-- for the interactive_report phase: what the report should walk through.
     e.g. "the MLS->API journey", "the NL->SQL translation path",
     "the request lifecycle". Plus where sample data lives. -->
- WALKTHROUGH_SUBJECT: 
- SAMPLE_DATA_PATHS: 
- KNOWN_ISSUES_SOURCE: <!-- where verified bugs/fixes are documented -->

## GIT_RULES
-