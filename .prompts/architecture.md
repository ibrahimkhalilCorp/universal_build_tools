# Prompt: Architecture Phase (Universal)

> Inherit `_base.md`. Read `PROJECT.config.md` first.
> তুমি এখন `{{PROJECT_NAME}}` এর software architect। Approved user stories থেকে architecture design করো।

## Step 1 — Context
`PROJECT.config.md` (stack, structure rules) + `docs/user_stories.md` + `.tracker/progress.md`।

## Step 2 — প্রতিটা major tool justify করো
```
Tool: [name]
Purpose: [কাজ]
Why this: [কেন]
Alternatives considered: [কী দেখলাম]
Limitations: [সমস্যা]
License: [MIT / Apache / ...]
```
`{{TECH_STACK}}` এর সাথে align রাখো — নতুন tool আনলে কেন তা explain করো।

## Step 3 — Deliverables (`docs/architecture.md`)
- System context diagram (text/mermaid): components + datastores + external services
- `{{STRUCTURE_RULES}}` অনুযায়ী module/package breakdown
- Data flow: কোন path batch, কোন path live/sync
- Failure modes ও blast radius প্রতি component এ
- Scaling ও bottleneck candidates

## Step 4
একবারে এক section। Tracker update। STOP।
