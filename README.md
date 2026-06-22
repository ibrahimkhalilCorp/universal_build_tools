# Universal Project Build Toolkit

> 📖 **পুরো instructions, সব command, pros & cons, troubleshooting** → `UserManual.md` দেখো।
> এই README টা short overview মাত্র।

A portable, project-agnostic build system. Drop it into **any**
repo, fill in one config file, and you get the whole phased workflow — user stories →
architecture → design → codegen → research → security — plus the **interactive HTML
audit/journey report** generator, working for that project.

Nothing here is hardcoded to any one project. Everything project-specific lives in
**`PROJECT.config.md`**. The prompts read placeholders like `{{PROJECT_NAME}}`,
`{{TECH_STACK}}`, `{{DOMAIN_RULES}}` from it.

---

> **নতুন project শুরু করছ?** এক পাতার checklist দেখো → `NEW_PROJECT.md`।
> **চলতি (existing) repo তে বসাচ্ছ?** → `EXISTING_PROJECT.md`।
> মূল কথা: এক toolkit, যত project — প্রতিবার শুধু `PROJECT.config.md` বদলাও
> (আর `PROJECT_MODE: greenfield | brownfield` সেট করো)।

## ⚡ এক command (auto)

বেশিরভাগ সময় এটাই লাগবে — toolkit নিজে mode detect করে, graph + spec ধরে,
আর পুরো phase sequence নিজে চালায়:

```bash
cd _build_tools
./auto.sh ../              # ../ = তোমার আসল repo
# অথবা: ./auto.sh ../ myproj 12   (নাম + max_stages)
```

`auto.sh` যা করে: greenfield/brownfield detect → graph grounding (থাকলে) →
built-in spec layer → ঠিক ক্রমে phase গুলো (`spec → … → codegen → … → report`)।
কিছু আলাদা করে বলতে হয় না। আলাদা একটা phase চালাতে চাইলে নিচের `build.sh` আছে।

## What's inside

```
universal_build_tools/
├── README.md                  ← you are here
├── PROJECT.config.md          ← ⭐ THE ONLY FILE YOU EDIT PER PROJECT
├── CLAUDE.md                  ← universal spine (reads PROJECT.config.md)
├── build.sh                   ← stage-looping driver (any phase, any project)
├── .prompts/
│   ├── _base.md               ← shared rules every phase inherits
│   ├── user_stories.md
│   ├── architecture.md
│   ├── abstract_design.md
│   ├── codegen.md
│   ├── research_report.md
│   ├── security_test.md
│   ├── code_quality.md        ← always-on baseline
│   └── interactive_report.md  ← the universal journey/audit HTML generator
├── .tracker/
│   └── progress.template.md
└── templates/
    ├── PROJECT.config.example.md   ← simple filled example (generic "TaskFlow API")
    └── PROJECT.config.heyhomex.md  ← richer real-world example (domain rules, formulas)
```

---

## Where to put the toolkit (Option B — clean repo)

Keep the toolkit in its own subfolder so your repo root stays clean:

```
AaizaQL/                     ← your repo
├── _build_tools/            ← drop the toolkit here
│   ├── build.sh
│   ├── PROJECT.config.md
│   ├── CLAUDE.md
│   ├── .prompts/  .tracker/  templates/
├── aaizaql/                 ← your real code  (this is the CONTEXT)
├── tests/
└── ...
```

Run it **from inside `_build_tools/`**, pointing CONTEXT at the parent repo:

```bash
cd _build_tools
./build.sh report ../ aaizaql 10
```

- The driver finds its own folder, so toolkit files (config, prompts, tracker)
  resolve no matter where you launch it from.
- The report is written to `../build_output/aaizaql_report.html` by default.
  Override with `OUT_DIR=/some/path ./build.sh report ../ aaizaql 10`.
- The tracker lives in `_build_tools/.tracker/`. Add `_build_tools/.tracker/`
  to `.gitignore` if you don't want progress notes committed.

---

## 60-second setup for a new project

1. **Copy** `universal_build_tools/` into your repo root (or keep it as a sibling and
   point `--add-dir` at the repo).
2. **Fill in** `PROJECT.config.md` — name, goal, stack, structure rules, domain rules,
   "what NOT to do" list. This is the *only* file you change. Use
   `templates/PROJECT.config.example.md` (simple) or
   `templates/PROJECT.config.heyhomex.md` (richer) as a reference.
3. **Pick a language** for the prompts: keep the Banglish voice or set
   `VOICE: english` in the config (the `_base.md` honors it).
4. **Run a phase**:
   ```bash
   ./build.sh codegen ./           # implement next component
   ./build.sh report  ./ myproject # build the interactive HTML report
   ```
5. The driver loops one stage per Claude CLI call until the tracker says DONE —
   this is what lets the big HTML report finish instead of collapsing into a skeleton.

---

## The two things that make this "universal"

1. **Config-driven, not hardcoded.** Every prompt opens by reading `PROJECT.config.md`
   and `CLAUDE.md`. Swap the config, and the same prompts target a different system.
   Placeholders are written `{{LIKE_THIS}}` and resolved from the config.

2. **The report generator is system-shaped, not project-specific.** `interactive_report.md`
   asks the model to discover the *target system's* real components, pipeline stages,
   formulas, and known issues from the inputs, then build the slides around those.
   For a pipeline project it shows the pipeline; for a library it shows the call graph;
   for an API it shows the request lifecycle. Same skeleton, different skeleton-filling.

See `PROJECT.config.md` for the full field list and `.prompts/interactive_report.md`
for how the report adapts per system.
