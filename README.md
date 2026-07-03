# Universal Project Build Toolkit

> 📖 **পুরো instructions, সব command, Graphify + OpenSpec, troubleshooting** → `UserManual.md`।
> এই README টা short overview — এক নজরে কী আছে, কীভাবে শুরু করবে।

A portable, project-agnostic build system. যেকোনো repo তে drop করো, একটা config ভরো —
পুরো phased workflow (user stories → architecture → design → codegen → research → security)
আর **interactive HTML audit/journey report** সেই project এর জন্য তৈরি।

কিছুই hardcoded নয়। সব project-specific জিনিস থাকে **`PROJECT.config.md`** এ।
Prompt গুলো `{{PLACEHOLDER}}` দিয়ে সেখান থেকে value টেনে নেয়।

> **নতুন project?** → `NEW_PROJECT.md`
> **চলতি repo তে নতুন feature?** → `EXISTING_PROJECT.md`
> **মূল নীতি:** এক toolkit, যত project — প্রতিবার শুধু `PROJECT.config.md` বদলাও।

---

## ⚠️ কোথায় command চালাবে (আগে এটা পড়ো!)

| জায়গা | চলবে? | কারণ |
|---|---|---|
| **Git Bash (MINGW64)** / Linux/macOS terminal | ✅ হ্যাঁ | `.sh` script গুলো bash-এ চলে |
| PowerShell / CMD | ❌ না | bash script natively চলে না |
| **Claude Code session-এর ভেতরে** | ❌ **কখনোই না** | `build.sh` **নিজেই** `claude -p` call করে। Claude-এর ভেতর থেকে চালালে Claude হয়ে যায় executor — নিজের judgment-এ background-এ পাঠায়, নিজেই প্রশ্নের উত্তর দেয়, unpredictable behavior হয় (বাস্তবে ঘটেছে) |

**সঠিক নিয়ম:** Git Bash খোলো → `cd _build_tools` → `./build.sh <phase> ../` — ব্যাস।
Claude শুধু script-এর *ভেতর থেকে* nested worker হিসেবে ডাকা হবে, executor হিসেবে না।

**Reset দরকার?** পুরনো project-state (tracker, spec changes) এক command-এ মুছতে: `./reset.sh ../` (stale `openspec/project.md`-ও ধরে ফেলবে)।

**Citation ঠিক আছে কিনা check করতে চাও?** generated docs (architecture.md ইত্যাদি)-এ US-N reference গুলো `docs/user_stories.md`-এর বিপরীতে verify করতে: `./check_citations.sh ../`। Undefined number ধরবে automatically; valid-but-wrong-meaning number গুলোর জন্য side-by-side text দেখাবে যাতে মানুষ দ্রুত eyeball করতে পারে (পুরোপুরি automated না, কিন্তু অনেক দ্রুত)।

**Tracker আর disk out-of-sync মনে হচ্ছে?** `codegen`/`abstract_design` phase-এ `build.sh` প্রতি pass-এ actual file listing prompt-এ inject করে দেয় — nested session-কে তার নিজের context-compression বা tracker-এর ভুলের উপর নির্ভর করতে হয় না, disk-ই ground truth।

---

## ⚡ এক command (auto)

বেশিরভাগ ক্ষেত্রে এটাই লাগবে — toolkit নিজে greenfield/brownfield detect করে,
Graphify grounding টানে, built-in spec layer চালায়, তারপর পুরো phase sequence শেষ করে:

```bash
cd _build_tools
./auto.sh ../              # ../ = তোমার আসল repo
./auto.sh ../ myproj 12   # নাম + max_stages দিতে চাইলে
```

আলাদা একটা phase চালাতে চাইলে `build.sh` আছে (নিচে দেখো)।

---

## ভেতরে কী আছে

```
universal_build_tools/
├── README.md                   ← you are here
├── UserManual.md               ← পুরো manual (setup → advanced)
├── NEW_PROJECT.md              ← নতুন (greenfield) project checklist
├── EXISTING_PROJECT.md         ← চলতি (brownfield) repo + feature add checklist
│
├── PROJECT.config.md           ← ⭐ একমাত্র file যেটা per-project তুমি ভরো
├── CLAUDE.md                   ← universal spine (workflow order, grounding rules)
│
├── auto.sh                     ← ⚡ এক command — mode detect, সব phase নিজে চালায়
├── build.sh                    ← এক phase করে চালানোর driver
│
├── .prompts/
│   ├── _base.md                ← সব phase এর shared rule (mode, grounding, spec)
│   ├── spec.md                 ← built-in OpenSpec-style spec layer
│   ├── user_stories.md
│   ├── architecture.md
│   ├── abstract_design.md
│   ├── codegen.md
│   ├── research_report.md
│   ├── security_test.md
│   ├── code_quality.md         ← always-on baseline
│   └── interactive_report.md   ← universal journey/audit HTML generator
│
├── .tracker/
│   └── progress.template.md    ← session-continuity tracker
│
└── templates/                  ← pre-filled example configs (closest টা নিয়ে শুরু করো)
    ├── PROJECT.config.example.md       (generic "TaskFlow API")
    ├── PROJECT.config.heyhomex.md      (pipeline + hybrid search API)
    ├── PROJECT.config.aaizaql.md       (NL→SQL library)
    └── PROJECT.config.proactive_ai.md  (multi-tenant recommendation platform)
```

---

## কোথায় বসাবে (Option B — পরিষ্কার repo)

Toolkit কে নিজের subfolder এ রাখো যাতে repo root পরিষ্কার থাকে:

```
YourRepo/
├── _build_tools/         ← toolkit এখানে copy করো (এখান থেকে চালাও)
│   ├── auto.sh  build.sh  PROJECT.config.md  CLAUDE.md
│   ├── .prompts/  .tracker/  templates/
├── yourcode/             ← তোমার আসল code (এটাই CONTEXT)
├── tests/
└── ...
```

Driver নিজের folder নিজে খুঁজে নেয় (`BASH_SOURCE`), তাই যেকোনো directory থেকে
চালালেও কাজ করে। Report যায় `../build_output/<name>_report.html` এ।

---

## Quick setup

**নতুন project (greenfield):**

```bash
cp -r universal_build_tools  YourRepo/_build_tools
cd YourRepo/_build_tools
cp templates/PROJECT.config.example.md  PROJECT.config.md   # closest template নাও
# PROJECT.config.md ভরো → PROJECT_MODE: greenfield
./auto.sh ../  myproject
```

**চলতি repo তে feature add (brownfield):**

```bash
cp -r universal_build_tools  YourRepo/_build_tools
cd YourRepo/_build_tools
cp templates/PROJECT.config.<closest>.md  PROJECT.config.md
# PROJECT_MODE: brownfield দাও
# SPEC.ACTIVE_CHANGE: <your-feature>  (kebab-case, e.g. add-export-csv)

# বড় feature হলে আগে spec দেখে নাও:
./build.sh spec ../ myproject 6       # proposal → delta specs → design → tasks
# tasks.md review করো, তারপর:
./build.sh codegen ../ myproject 12
# অথবা সব এক সাথে:
./auto.sh ../  myproject 12
```

Template বেছে নেওয়ার guide:

| Repo এর ধরন | Template |
|---|---|
| pipeline / full-stack / API + data | `heyhomex` |
| library / SDK / package | `aaizaql` |
| multi-tenant / service / platform | `proactive_ai` |
| generic | `example` |

---

## build.sh — phase by phase

```bash
./build.sh <phase> <context> [system_name] [max_stages]

# উদাহরণ:
./build.sh spec          ../ myproject 6
./build.sh user_stories  ../ myproject 10
./build.sh architecture  ../ myproject 10
./build.sh abstract_design ../ myproject 10
./build.sh codegen       ../ myproject 12
./build.sh research_report ../ myproject 10
./build.sh security_test ../ myproject 8
./build.sh report        ../ myproject 12
```

`max_stages` হলো upper limit — tracker complete হলে আগেই থামে।

**greenfield phase sequence:** `spec → user_stories → architecture → abstract_design → codegen → research_report → security_test → report`

**brownfield phase sequence:** `spec → codegen → research_report → security_test → report`

---

## দুটো জিনিস যা এটাকে "universal" করে

**১. Config-driven, hardcoded নয়।**
প্রতিটা prompt শুরু হয় `PROJECT.config.md` পড়ে। Config বদলাও → একই prompts অন্য
system ধরে। Placeholder লেখা হয় `{{LIKE_THIS}}` দিয়ে।

**২. Report generator system-shaped, project-specific নয়।**
`interactive_report.md` model কে বলে target system এর real component, pipeline stage,
formula, known issue নিজে discover করতে — তারপর সেগুলো দিয়ে slide বানাতে।
Pipeline হলে pipeline দেখায়, library হলে call graph, API হলে request lifecycle।
একই skeleton, ভিন্ন filling।

---

## Graphify + OpenSpec (built-in)

**Graphify (grounding):** Claude যাতে existing code এর আসল component নাম/relationship
হ্যালুসিনেট না করে। `KNOWLEDGE_GRAPH.TOOL: graphify` config এ দিলে প্রতি phase
graph query করে ground-truth টানে। না থাকলে `TOOL: none` — কোনো error নেই, config
থেকে চলে।

**OpenSpec (spec layer):** Code লেখার আগে change এ align করার lightweight layer —
পুরো spec rewrite নয়, শুধু delta। `spec` phase চালালে বানায়:

```
openspec/changes/<feature-name>/
├── proposal.md   ← কী + কেন
├── specs.md      ← ADDED / MODIFIED / REMOVED (delta only)
├── design.md     ← interface/schema/endpoint decision
└── tasks.md      ← implementable step list (codegen এক এক করে নেবে)
```

বিস্তারিত → `UserManual.md`।