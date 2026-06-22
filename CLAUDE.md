# CLAUDE.md — Universal Build Spine

> তুমি যেকোনো project এ কাজ শুরু করার আগে এই sequence follow করো।
> এই file project-agnostic। সব project-specific জিনিস `PROJECT.config.md` এ।

---

## Every session — প্রতিবার এই order এ

1. **`PROJECT.config.md` পড়ো** — project identity, stack, rules সব এখান থেকে।
2. **`CLAUDE.md` (এই file) পড়ো** — workflow rules।
3. **`.tracker/progress.md` পড়ো** — কোন phase, কোন component বাকি।
4. **`.prompts/_base.md` পড়ো** — সব phase এর shared rule।
5. Current phase এর prompt load করো (`PROJECT.config.md > CURRENT_PHASE`)।
6. **`.prompts/code_quality.md` সবসময় active** — phase নয়, baseline।
7. কাজ করো → একবারে একটা component/stage।
8. Session শেষে `.tracker/progress.md` আপডেট করো।

---

## Placeholder contract

প্রতিটা prompt `{{LIKE_THIS}}` placeholder use করে। সেগুলো `PROJECT.config.md`
এর field থেকে resolve করো। যদি কোনো field `—` থাকে, ওই rule skip করো — invent করো না।

Common placeholders: `{{PROJECT_NAME}} {{ONE_LINE_GOAL}} {{TECH_STACK}}
{{STRUCTURE_RULES}} {{NAMING}} {{DOMAIN_RULES}} {{DO}} {{DONT}} {{FLAG_ON_SIGHT}}
{{REPORT_INPUTS}} {{VOICE}}`।

---

## Phase sequence (default)

0. `spec`            → `.prompts/spec.md`  (OpenSpec-style: align before code; built-in, no CLI)
1. `user_stories`    → `.prompts/user_stories.md`
2. `architecture`    → `.prompts/architecture.md`
3. `abstract_design` → `.prompts/abstract_design.md`
4. `codegen`         → `.prompts/codegen.md`
5. `research_report` → `.prompts/research_report.md`
6. `security_test`   → `.prompts/security_test.md`

Cross-cutting (যেকোনো সময় চালানো যায়):
- `code_quality`       → always-on baseline
- `interactive_report` → `.prompts/interactive_report.md` (journey/audit HTML)

---

## Grounding + spec contract (সব phase, SOFT)

`_base.md §1a` ও `§1b` প্রতি run এ চলে — config বদলালেই on/off:

- **Graphify grounding** (`KNOWLEDGE_GRAPH.TOOL`): সেট থাকলে phase গুলো কাজের আগে
  graph থেকে real entity/relationship টানে যাতে hallucinate না করে। `none` হলে skip।
  fail করলে warn করে চালিয়ে যায় — কখনো block নয়।
- **Spec layer** (`SPEC.DIR`, default `openspec/`): codegen এর আগে active change এর
  delta spec পড়ে; spec না থাকলে warn করে চালিয়ে যায়। নতুন requirement delta আকারে
  (ADDED/MODIFIED/REMOVED) লেখা হয়, পুরো spec rewrite নয়।

দুটোই **soft** — দরকারি grounding/spec না পেলে toolkit থামে না, শুধু সতর্ক করে।

---

## Universal guardrails (সব project এ)

- `PROJECT.config.md > FLAG_ON_SIGHT` এর কোনো string code এ দেখলে **সাথে সাথে flag করো**, কাজ থামিয়ে।
- `PROJECT.config.md > DONT` violate করে এমন কিছু লিখো না।
- Test ছাড়া কোনো scoring/business formula change করো না।
- Secret/credential hardcode করো না।
- একবারে একটা জিনিস — tracker update করো প্রতি session।

## Knowledge graph (যদি config এ থাকে)

`PROJECT.config.md > KNOWLEDGE_GRAPH` যদি `none` না হয়:
- Codebase question এ আগে `{{QUERY_CMD}}` চালাও।
- Code modify করার পর graph update করো।

## Git rules

`PROJECT.config.md > GIT_RULES` follow করো।
