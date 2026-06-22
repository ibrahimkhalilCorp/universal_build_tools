# Prompt: Spec Phase (Universal, OpenSpec-style, Built-in)

> Inherit `.prompts/_base.md`. Read `PROJECT.config.md` first.
> তুমি এখন `{{PROJECT_NAME}}` এর spec author। কোনো code লেখার আগে human ও AI
> একটা change এর উপর **align** করো — proposal → delta specs → design → tasks।
> External CLI লাগে না; সব কিছু `{{SPEC.DIR}}` (default `openspec/`) এ markdown।

## কেন এই phase

AI coding unpredictable হয় যখন requirement শুধু chat এ থাকে। এই phase একটা
পাতলা spec layer দেয়: ছোট, focused change, প্রতিটা নিজের folder এ, delta আকারে —
যাতে drift কমে আর brownfield repo তে পুরো spec rewrite করতে না হয়।

## Step 1 — Context

```
read: PROJECT.config.md            ← stack, domain rules, SPEC block
read: {{SPEC.DIR}}/project.md      ← spec constitution (না থাকলে এই run এ বানাও)
read: {{SPEC.DIR}}/specs/          ← current accepted specs (brownfield এ থাকতে পারে)
read: .tracker/progress.md
```
Graphify on থাকলে (`KNOWLEDGE_GRAPH.TOOL != none`) — `_base.md §1a` মতো graph
থেকে relevant entity/relationship টেনে নাও, যাতে spec বাস্তব component এর নামে লেখা হয়।

## Step 2 — project.md না থাকলে আগে সেটা (এক বারই)

`{{SPEC.DIR}}/project.md` তে non-negotiable constraint লেখো — stack choice,
structure rules, domain rules এর সারাংশ। এটা প্রতিটা future change এ inject হবে।
`PROJECT.config.md` থেকেই বেশিরভাগ টেনে আনো — duplicate truth বানিও না।

## Step 3 — Active change এর folder (একবারে একটা change)

`ACTIVE_CHANGE` = `{{SPEC.ACTIVE_CHANGE}}`। খালি হলে proposal থেকে একটা
kebab-case নাম দাও (e.g. `add-user-auth`)। Folder:
`{{SPEC.DIR}}/changes/<change-name>/`। নিচের file গুলো এক run এ এক করে এগোও:

```
proposal.md   ← কী বদলাচ্ছে + কেন (২–৫ লাইন), scope, out-of-scope
specs.md      ← DELTA only — পুরো spec নয়:
                ## ADDED Requirements
                - REQ: ...
                ## MODIFIED Requirements
                - REQ (was → now): ...
                ## REMOVED Requirements
                - REQ: ... (কেন সরছে)
design.md     ← interface/schema/endpoint decisions; alternatives + tradeoff
tasks.md      ← ছোট, implementable step list (codegen এগুলো এক এক করে নেবে)
```

## Step 4 — Rules

- **Delta discipline:** existing requirement বদলালে MODIFIED এ লেখো, পুরো spec
  copy করো না। নতুন হলে ADDED। এতে brownfield এ history পরিষ্কার থাকে।
- `project.md` ও `{{DOMAIN_RULES}}` এর সাথে conflict হলে — থামো, flag করো, invent করো না।
- greenfield হলে: specs/ খালি, তাই প্রায় সবই ADDED। brownfield হলে: আগে
  `specs/` পড়ে তবেই delta লেখো।
- এক run = এক file (বা এক file এর এক section)। শেষে tracker update, STOP।

## Step 5 — Accept / merge (change done হলে)

`tasks.md` এর সব box টিক হলে: `changes/<name>/specs.md` এর delta কে
`{{SPEC.DIR}}/specs/` এ merge করো (ADDED যোগ, MODIFIED apply, REMOVED বাদ),
তারপর change folder কে `{{SPEC.DIR}}/changes/archive/` এ সরাও। Tracker update।
