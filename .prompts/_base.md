# _base.md — Shared rules every phase inherits

> এই file টা সব phase prompt এর শুরুতে mentally load করো। প্রতিটা prompt এই
> base এর উপর দাঁড়ানো।

---

## 0. Voice

`PROJECT.config.md > VOICE` honor করো:
- `banglish` → casual Banglish, direct, mixed Bengali/English (default)।
- `english` → clear professional English।
- `bilingual` → headings English, explanation Banglish।

## 0.5 Project mode (greenfield vs brownfield) — সব phase এই দুটো case সামলাবে

`PROJECT.config.md > PROJECT_MODE` পড়ো। Field খালি/`—` হলে CONTEXT এ source
code আছে কিনা দেখে নিজে infer করো (code আছে → brownfield, খালি repo → greenfield)।

- **greenfield** (নতুন, code নেই):
  - "existing module পড়ো / discover real components" টাইপ rule গুলো **skip** করো —
    কিছু নেই পড়ার মতো। তার বদলে `architecture` / `abstract_design` phase এর output
    (অথবা config এর DOMAIN_RULES, TECH_STACK) কে source-of-truth ধরো।
  - codegen এ "next component" মানে design এ planned পরের component — scratch থেকে লেখো।
  - report এ system এখনো বানানো হয়নি — তাই report টা **planned/intended journey**
    দেখাবে, slide এ `PLANNED — not yet built` badge দেবে। Bug/finding নেই,
    তাই findings section বদলে "design risks / open decisions" দেখাও।
  - Truth policy বহাল: কোনো component কে "implemented" বলো না যতক্ষণ না file আছে।

- **brownfield** (existing repo, code আছে):
  - আগের মতোই — CONTEXT থেকে real components, formulas, known issues discover করো।
  - codegen এর আগে existing pattern/convention মিলিয়ে নাও, তারপর নতুন component যোগ করো।
  - report এ real findings/bugs দেখাও (verifiable হতে হবে, dummy নয়)।

দুই mode এই: একবারে এক unit, tracker discipline, truth policy unchanged।

## 1. Context load (প্রতি run এ, ব্যতিক্রম নেই)

```
read: PROJECT.config.md        ← identity, stack, rules
read: CLAUDE.md                ← workflow
read: .tracker/progress.md     ← কী বাকি
read: .prompts/code_quality.md ← always active baseline
```
তারপর phase-specific inputs (নিচে প্রতিটা prompt বলে দেবে)।

## 1a. Graphify grounding (সব phase এ baseline — SOFT)

`PROJECT.config.md > KNOWLEDGE_GRAPH` পড়ো।

- `TOOL: none` (বা block খালি) হলে → grounding skip করো, কাজ চালিয়ে যাও। কোনো error নয়।
- `TOOL` সেট থাকলে → কাজের আগে graph থেকে relevant entities/relationships টানো:
  ```
  run: {{KNOWLEDGE_GRAPH.QUERY_CMD}}   ← config এ দেওয়া query/command
  read: {{KNOWLEDGE_GRAPH.OUT_DIR}}/   ← graph dump/export এখানে থাকলে
  ```
  যা পেলে তা **ground-truth** ধরো — component নাম, relationship, domain fact
  graph এর সাথে মিলিয়ে নাও, যাতে hallucinate না করো।
- **SOFT enforcement:** graph query fail করলে বা খালি ফিরলে → এক লাইনে warn করো
  (`⚠ graph grounding unavailable — proceeding from config + code`) আর কাজ চালিয়ে যাও।
  কখনো এই কারণে build থামাবে না।
- যা graph থেকে এসেছে বনাম যা code/config থেকে — দরকার হলে clearly আলাদা করো।

## 1b. Spec layer (OpenSpec-style, built-in — SOFT)

এই toolkit এর নিজের lightweight spec layer আছে (external CLI লাগে না)। Spec গুলো
থাকে `{{SPEC.DIR}}` (default `openspec/`) এ:
```
openspec/
├── project.md          ← spec "constitution": non-negotiable constraints
├── specs/              ← current accepted source-of-truth specs
└── changes/
    └── <change-name>/   ← প্রতি change = এক folder
        ├── proposal.md  ← কী বদলাচ্ছে, কেন
        ├── specs.md     ← delta: ADDED / MODIFIED / REMOVED requirements
        ├── design.md    ← interface/schema decisions
        └── tasks.md     ← ছোট ছোট implementable steps
```

প্রতি run এ:
- `openspec/project.md` থাকলে পড়ো — এর constraint গুলো `DOMAIN_RULES` এর সমান weight।
- **codegen এর আগে:** active change এর `specs.md` (delta) + `tasks.md` পড়ো। যা spec এ
  agreed শুধু তাই implement করো।
- **SOFT enforcement:** কোনো spec/active change না থাকলে → warn করো
  (`⚠ no spec found for this change — proceeding, consider running the spec phase first`)
  আর কাজ চালিয়ে যাও। থামাবে না।
- নতুন/বদলানো requirement এলে delta হিসেবে লেখো (পুরো spec rewrite নয়): শুধু
  `## ADDED`, `## MODIFIED`, `## REMOVED` section এ লাইন যোগ করো।
- Change accept/done হলে delta টা `openspec/specs/` এ merge করো, change folder archive করো।

## 2. Placeholder resolution

`{{FIELD}}` দেখলে `PROJECT.config.md` থেকে value নাও। Field `—` হলে ওই অংশ skip
করো, কখনো invent করো না।

## 3. One unit per run

একবারে একটা component / stage / slide। Token ceiling এ আটকে যেও না — driver
আবার call করবে। কাজ শেষে STOP।

## 4. Tracker discipline

Run শেষে `.tracker/progress.md` আপডেট: কী করলাম, কী বাকি, কোনো blocker। পরের
session যেন cold-start না হয়।

## 5. Truth policy

- যা inputs এ আছে শুধু তাই claim করো। না থাকলে `unverified` label দাও, বানিয়ে বলো না।
- Sample data না থাকলে real schema match করে dummy বানাতে পারো — কিন্তু `dummy`
  বলে clearly mark করো। **Findings/bugs/metrics কখনো dummy নয়** — verifiable হতে হবে।

## 6. Guardrails (config থেকে)

- `FLAG_ON_SIGHT` এর কিছু দেখলে থামো, flag করো।
- `DONT` violate করো না।
- Formula change → test + research_report update।

## 7. Output hygiene

- File path গুলো real এবং consistent রাখো।
- প্রতি run শেষে print করো: কী করলাম + কী বাকি + self-check result।
