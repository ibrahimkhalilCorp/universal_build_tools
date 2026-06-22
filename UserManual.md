# UserManual.md — Universal Project Build Toolkit

> এক toolkit, যত project। নতুন বা পুরনো — দুটোতেই চলে। তুমি শুধু একটা config
> ভরো আর একটা command চালাও; toolkit বাকিটা নিজে সামলায়।
>
> এই manual টা একটাই reference — setup, সব command, Graphify + spec layer,
> pros & cons, আর কী আটকালে কী করবে।

---

## 1. এটা আসলে কী

একটা portable build system যা যেকোনো repo তে বসিয়ে দিলে পুরো phased workflow
(user stories → architecture → design → codegen → research → security) **এবং** একটা
interactive HTML audit/journey report — সব ওই project এর জন্য তৈরি করে দেয়।

কোনো কিছু একটা নির্দিষ্ট project এ hardcoded নয়। সব project-specific জিনিস
থাকে **একটাই file** এ — `PROJECT.config.md`। Prompt গুলো `{{PLACEHOLDER}}` দিয়ে
সেখান থেকে value টেনে নেয়। Config বদলাও → একই toolkit অন্য project ধরে।

**মূল নীতি:** *এক toolkit, যত project — প্রতিবার শুধু `PROJECT.config.md` বদলাও;
prompts / driver এ কখনো হাত দিও না।*

---

## 2. ভেতরে কী আছে

```
universal_build_tools/
├── UserManual.md            ← তুমি এখানে
├── README.md                ← short overview
├── NEW_PROJECT.md           ← নতুন (greenfield) project checklist
├── EXISTING_PROJECT.md      ← চলতি (brownfield) repo checklist
│
├── PROJECT.config.md        ← ⭐ একমাত্র file যেটা per-project তুমি ভরো
├── CLAUDE.md                ← universal spine (workflow order)
│
├── auto.sh                  ← ⚡ এক command — সব নিজে চালায়
├── build.sh                 ← এক phase করে চালানোর driver
│
├── .prompts/
│   ├── _base.md             ← সব phase এর shared rule (mode, grounding, spec)
│   ├── spec.md              ← OpenSpec-style spec layer (built-in)
│   ├── user_stories.md
│   ├── architecture.md
│   ├── abstract_design.md
│   ├── codegen.md
│   ├── research_report.md
│   ├── security_test.md
│   ├── code_quality.md      ← always-on baseline
│   └── interactive_report.md← universal journey/audit HTML generator
│
├── .tracker/
│   └── progress.template.md ← session-continuity tracker
│
└── templates/               ← pre-filled example configs
    ├── PROJECT.config.example.md      (generic TaskFlow API)
    ├── PROJECT.config.heyhomex.md     (pipeline + hybrid search API)
    ├── PROJECT.config.aaizaql.md      (NL→SQL library)
    └── PROJECT.config.proactive_ai.md (multi-tenant rec platform)
```

---

## 3. কোথায় বসাবে (Option B — পরিষ্কার repo)

Toolkit কে নিজের subfolder এ রাখো যাতে repo root পরিষ্কার থাকে:

```
YourRepo/
├── _build_tools/        ← toolkit এখানে copy করো (এখান থেকে চালাও)
│   ├── auto.sh  build.sh  PROJECT.config.md  CLAUDE.md
│   ├── .prompts/  .tracker/  templates/
├── yourcode/            ← তোমার আসল code (এটাই CONTEXT)
├── tests/
└── ...
```

driver নিজের folder নিজে খুঁজে নেয় (`BASH_SOURCE`), তাই কোথা থেকে চালাও তাতে
কিছু যায় আসে না। CONTEXT (তোমার repo) দাও `../` দিয়ে।

```bash
cp -r universal_build_tools  YourRepo/_build_tools
cd YourRepo/_build_tools
```

---

## 4. ⚡ Quick start — এক command

বেশিরভাগ সময় শুধু এটাই লাগবে:

```bash
cd _build_tools
./auto.sh ../                 # ../ = তোমার আসল repo
# অথবা নাম + max_stages সহ:
./auto.sh ../ myproj 12
```

`auto.sh` নিজে যা করে:
1. **mode detect** — `PROJECT_MODE` config এ না থাকলে repo দেখে বোঝে
   (code file পেলে brownfield, খালি হলে greenfield)।
2. **graph + spec ধরে** — configured থাকলে use করে, না থাকলে soft skip।
3. **ঠিক ক্রমে phase চালায়**:
   - greenfield → `spec → user_stories → architecture → abstract_design →
     codegen → research_report → security_test → report`
   - brownfield → `spec → codegen → research_report → security_test → report`
4. প্রতি phase `build.sh` দিয়ে চলে; tracker দেখে এক phase শেষ হলে পরেরটা ধরে।

আলাদা করে কিছু বলতে হয় না। ভালো output চাইলে আগে config টা ভরে নাও (§6)।

---

## 5. এক phase করে চালানো (manual control)

পুরো sequence না চালিয়ে একটা নির্দিষ্ট phase চালাতে চাইলে:

```bash
./build.sh <phase> <context> [system_name] [max_stages]
```

| Command | কী করে |
| --- | --- |
| `./build.sh spec ../` | OpenSpec-style spec layer (proposal→delta→design→tasks) |
| `./build.sh user_stories ../` | user stories লেখায় |
| `./build.sh architecture ../` | architecture design |
| `./build.sh abstract_design ../` | interfaces / schemas |
| `./build.sh codegen ../` | একটা একটা component implement |
| `./build.sh research_report ../` | decisions document |
| `./build.sh security_test ../ myproj 6` | security audit + tests |
| `./build.sh report ../ myproj 10` | interactive HTML report |

**`max_stages` (শেষ সংখ্যা):** driver সর্বোচ্চ কতবার loop চালাবে (এক pass = এক stage)।
এটা **upper limit, target নয়** — tracker এর সব box টিক হলে আগেই থামে। ছোট project → 8,
বড় (অনেক surface) → 12–15। না দিলে default 10।

কেন এক stage করে? বড় HTML report এক response এ চাইলে token ceiling এ skeleton হয়ে
ভেঙে যায়। তাই driver এক stage করে চালায়, প্রতিবার tracker এ progress রাখে — মাঝে
থামলেও পরেরবার যেখানে ছিল সেখান থেকে শুরু।

---

## 6. একমাত্র যে file তুমি ভরবে — `PROJECT.config.md`

| Field | লাগে? | কী লিখবে |
| --- | --- | --- |
| `VOICE` | optional | `banglish` / `english` / `bilingual` (default banglish) |
| `PROJECT_NAME` | **must** | project এর নাম |
| `ONE_LINE_GOAL` | **must** | এক লাইনে কী করে |
| `PROJECT_MODE` | recommended | `greenfield` / `brownfield` (খালি রাখলে auto detect) |
| `TECH_STACK` | **must** | language, framework, datastore, AI/ML, tests |
| `STRUCTURE_RULES` | ভালো | কোন folder এ কী, module pattern |
| `NAMING` | ভালো | file/class/constant/env convention |
| `DOMAIN_RULES` | **must** | project এর non-obvious নিয়ম যা code এ থাকতেই হবে |
| `DO` / `DONT` | ভালো | কী করবে / কী নিষেধ |
| `FLAG_ON_SIGHT` | ভালো | দেখলে সাথে সাথে flag করার মতো exact string |
| `KNOWLEDGE_GRAPH` | optional | Graphify use করলে; নাহলে `TOOL: none` |
| `SPEC` | optional | spec folder + active change name |
| `REPORT_INPUTS` | report এ must | কোন journey দেখাবে + sample data কোথায় |
| `GIT_RULES` | optional | commit/branch নিয়ম |

দ্রুত শুরু: `templates/` থেকে কাছাকাছি একটা example copy করে নিজেরটা বানাও।

```bash
cp templates/PROJECT.config.example.md  PROJECT.config.md   # generic
# অথবা .heyhomex.md / .aaizaql.md / .proactive_ai.md
```

### WALKTHROUGH_SUBJECT — report কোন journey দেখাবে

report নিজেই system এর type ধরে নেয়; তুমি শুধু subject টা দাও:

| Project type | WALKTHROUGH_SUBJECT |
| --- | --- |
| API / backend | "request lifecycle: auth → validate → service → DB → response" |
| Data / ETL pipeline | "pipeline stages: fetch → transform → enrich → load" |
| Library / SDK | "public API → main algorithm → result" |
| ML / scoring | "feature extraction → model/formula → score breakdown" |
| CLI tool | "command parse → execute → output" |
| Full-stack | "user action → frontend → API → DB → render" |

---

## 7. greenfield vs brownfield (নতুন বনাম চলতি)

| জিনিস | greenfield (নতুন, code নেই) | brownfield (চলতি repo) |
| --- | --- | --- |
| codegen | design থেকে scratch এ লেখে | existing pattern মিলিয়ে যোগ করে |
| report journey | planned/intended (`PLANNED` badge) | real, যা code এ আছে |
| findings | "design risks / open decisions" | real verifiable bugs/findings |
| source of truth | architecture/abstract_design output | আসল repo এর code |
| auto phase ক্রম | পুরো design chain সহ | design skip, সরাসরি codegen→audit→report |

এই switch টা `_base.md §0.5` নিজে সামলায়। তুমি শুধু `PROJECT_MODE` ঠিক দাও — বা
খালি রাখো, `auto.sh` detect করে নেবে। বিস্তারিত: `NEW_PROJECT.md` / `EXISTING_PROJECT.md`।

---

## 8. Graphify grounding (optional, SOFT)

কাজের আগে toolkit graph থেকে real entity/relationship টেনে নেয় যাতে hallucinate
না করে। সব phase এ চলে (codegen, report, spec, architecture)।

চালু করতে `PROJECT.config.md > KNOWLEDGE_GRAPH`:
```
- TOOL: graphify
- OUT_DIR: .graphify/                      # graph dump/export এখানে
- QUERY_CMD: graphify query --scope {{module}}   # তোমার আসল command
```
- `TOOL: none` → grounding skip, কিছু হয় না।
- query fail/খালি ফিরলে → এক লাইন warn দিয়ে কাজ চলতে থাকে। **কখনো build থামায় না (SOFT)।**

> ⚠ `QUERY_CMD` ও `OUT_DIR` এ তোমার আসল Graphify setup এর exact command/path বসাও।
> Default টা placeholder — এটা তোমার integration অনুযায়ী বদলাতে হবে।

---

## 9. Spec layer — OpenSpec-style, built-in (optional, SOFT)

External CLI বা npm লাগে না। সব markdown, থাকে `openspec/` (config এ `SPEC.DIR`):

```
openspec/
├── project.md              ← spec "constitution": non-negotiable constraint
├── specs/                  ← current accepted source-of-truth specs
└── changes/
    └── <change-name>/
        ├── proposal.md      ← কী বদলাচ্ছে, কেন
        ├── specs.md         ← DELTA: ADDED / MODIFIED / REMOVED requirements
        ├── design.md        ← interface/schema decisions
        └── tasks.md         ← ছোট implementable steps
```

- `./build.sh spec ../` চালালে এই structure বানায়/বাড়ায়।
- codegen এর আগে active change এর delta পড়ে — যা agreed শুধু তাই বানায়।
- spec না থাকলে → warn করে কাজ চালিয়ে যায় (**SOFT** — থামে না)।
- নতুন requirement **delta** আকারে (ADDED/MODIFIED/REMOVED) যোগ হয়, পুরো spec
  rewrite নয় — brownfield এ history পরিষ্কার থাকে।
- change done হলে delta টা `specs/` এ merge হয়, change folder archive এ যায়।

---

## 10. কীভাবে data দেবে (report এর dataset)

তিনভাবে:
1. **config এ path** — `REPORT_INPUTS > SAMPLE_DATA_PATHS: sample_data/ratings.csv`।
   driver পুরো repo `--add-dir` করে, তাই Claude পড়ে নেয়।
2. **`sample_data/` folder** context এর ভেতরে রেখে উপরের মতো path দাও।
3. **data নেই?** Claude real schema মিলিয়ে dummy বানায় আর slide এ
   `SAMPLE DATA — illustrative` badge দেয়। report আটকায় না।

⚠ dummy **শুধু dataset** এর জন্য। Bug / finding / formula কখনো বানানো হয় না — সব real।

---

## 11. ✅ Pros

- **এক command (`auto.sh`)** — mode detect, graph, spec, পুরো phase chain নিজে চালায়।
- **সত্যিকারের universal** — config বদলালেই নতুন project; prompt/driver অপরিবর্তিত।
- **নতুন + পুরনো দুটোতেই** — greenfield/brownfield নিজে ধরে, behavior বদলায়।
- **Token-ceiling proof** — এক stage করে চলে, তাই বড় HTML report skeleton হয়ে ভাঙে না।
- **Session-safe** — tracker এ progress থাকে; মাঝে থামলেও cold-start হয় না।
- **Grounded** — Graphify থাকলে real component এর নামে কাজ করে, কম hallucination।
- **Spec-anchored** — built-in OpenSpec-style layer drift কমায়, কোনো external dep ছাড়া।
- **Soft enforcement** — graph/spec না থাকলেও কখনো আটকায় না, শুধু warn করে।
- **Self-contained report** — একটা `.html`, inline CSS/JS, double-click এ খোলে।
- **Truth policy** — findings/formula কখনো dummy নয়; শুধু dataset dummy হতে পারে (marked)।

## ⚠ Cons / সীমা

- **Claude CLI লাগে** — `auto.sh`/`build.sh` লোকালে `claude` command ধরে চলে।
- **Output তত ভালো যত ভালো config** — খালি config দিলে report দুর্বল; ভরা must field গুরুত্বপূর্ণ।
- **Graphify integration তোমার দিকে** — `QUERY_CMD`/`OUT_DIR` তোমার আসল setup
  অনুযায়ী বসাতে হবে; default placeholder কাজ করবে না।
- **Spec layer পাতলা** — full OpenSpec CLI এর validation/diff নেই; এটা lightweight markdown convention।
- **Multi-stage = একাধিক CLI call** — বড় report এ সময় ও token খরচ বেশি (এটাই trade-off,
  skeleton এড়াতে)।
- **Auto-detect heuristic** — code file খুঁজে mode ধরে; অস্বাভাবিক repo layout এ
  `PROJECT_MODE` explicit দেওয়া ভালো।
- **dummy dataset confusion** — sample data না দিলে report এ illustrative data থাকে;
  reader কে badge দেখে বুঝতে হয় এটা real নয়।

---

## 12. কী আটকালে কী করবে (troubleshooting)

| উপসর্গ | কারণ / সমাধান |
| --- | --- |
| `PROJECT.config.md missing` | config ভরা হয়নি — template copy করো |
| `No prompt at .prompts/...` | phase নাম ভুল — §5 এর তালিকা দেখো |
| report ~900 lines এ থেমে গেছে | build শেষ হয়নি — `max_stages` বাড়াও, আবার চালাও |
| report এ illustrative data | sample data দাওনি — `SAMPLE_DATA_PATHS` ভরো |
| mode ভুল ধরছে | `PROJECT_MODE` explicit সেট করো |
| graph warning আসছে | `KNOWLEDGE_GRAPH` খালি/ভুল — `TOOL: none` দাও বা `QUERY_CMD` ঠিক করো |
| spec warning আসছে | চাইলে আগে `./build.sh spec ../`; নাহলে উপেক্ষা করো (soft) |
| `claude: command not found` | Claude CLI install/PATH ঠিক করো |
| progress জমছে না | `.tracker/` write-able কিনা দেখো |

---

## 13. .gitignore এ যোগ করো (চাইলে)

```
_build_tools/.tracker/
build_output/
```

---

## 14. মনে রাখার মতো ৪টা জিনিস

1. **config বদলালেই নতুন project ধরে** — কিন্তু report তত ভালো যত ভালো context দাও;
   সবসময় আসল repo টা CONTEXT হিসেবে দাও (`../`)।
2. **toolkit এর core file (prompts/driver) বদলাতে হবে না** — শুধু `PROJECT.config.md`।
3. **Graphify + spec দুটোই soft** — না থাকলে কাজ থামবে না, শুধু warn আসবে।
4. **findings/formula কখনো dummy নয়** — সব verifiable; শুধু dataset dummy হতে পারে (badge সহ)।
