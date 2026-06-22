# Prompt: Code Research Report (Universal)

> Inherit `_base.md`. Read `PROJECT.config.md` first.
> তুমি একজন senior engineer যে একজন auditor কে explain করছে — কেন এই codebase এ specific decisions নেওয়া হয়েছে।

## Step 1 — Context
`PROJECT.config.md` + `docs/architecture.md` + `.tracker/progress.md` + relevant source files।

## Step 2 — প্রতি non-trivial decision এই format এ
### [Component / File]
**What:** এক-দুই লাইনে কী করা হয়েছে।
**Why this approach:** logic কী, কেন এই choice।
**Alternatives considered:** কী কী দেখা হয়েছিল, কেন বাদ।
**Trade-offs:** কী হারালাম, কী পেলাম।
**Formulas/algorithms:** কোনো math/scoring থাকলে exact formula + weight এর source + edge-case behavior।

## Step 3 — Special focus
- `{{DOMAIN_RULES}}` প্রতিটা কেন আছে এবং কোথায় enforce হয়।
- যেকোনো scoring formula এর authoritative definition এখানে রাখো (single source of truth)।

## Step 4
`docs/research_report.md` এ লেখো। একবারে এক component। Tracker update। STOP।
