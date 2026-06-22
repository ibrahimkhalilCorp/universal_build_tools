# NEW_PROJECT.md — নতুন project এ toolkit বসানোর checklist

> এক toolkit, যত project। প্রতিবার শুধু এই পাতাটা ফলো করো। prompts / CLAUDE.md /
> _base.md / build.sh — এগুলোতে কখনো হাত দিতে হবে না।

---

## ⚡ TL;DR (৪ ধাপ)

```bash
# 1. toolkit copy করো project এর subfolder এ
cp -r universal_build_tools  YourProject/_build_tools

# 2. একটা example config বেছে নিয়ে PROJECT.config.md বানাও
cd YourProject/_build_tools
cp templates/PROJECT.config.example.md  PROJECT.config.md   # generic
# অথবা templates/PROJECT.config.aaizaql.md / .heyhomex.md দেখে নিজেরটা লেখো

# 3. PROJECT.config.md ভরো (নিচের checklist দেখে)

# 4. চালাও
./build.sh report ../ yourproject 10
# report বের হবে → YourProject/build_output/yourproject_report.html
```

---

## ✅ PROJECT.config.md এ যা যা ভরতে হবে

### অবশ্যই (এগুলো ছাড়া report দুর্বল হবে)
- [ ] **PROJECT_NAME** — project এর নাম
- [ ] **ONE_LINE_GOAL** — এক লাইনে কী করে
- [ ] **TECH_STACK** — language, framework, datastore, AI/ML, tests
- [ ] **REPORT_INPUTS > WALKTHROUGH_SUBJECT** — report এ কোন journey দেখাবে
      (যেমন: "request lifecycle", "the NL→SQL pipeline", "the build→deploy flow")
- [ ] **DOMAIN_RULES** — project এর non-obvious নিয়ম যা code এ থাকতেই হবে

### ভরলে report অনেক ভালো হয়
- [ ] **STRUCTURE_RULES** — কোন folder এ কী থাকে, module pattern
- [ ] **NAMING** — file/class/constant/env convention
- [ ] **DONT** + **FLAG_ON_SIGHT** — কী নিষেধ, কী দেখলে সাথে সাথে flag
- [ ] **REPORT_INPUTS > SAMPLE_DATA_PATHS** — real sample data কোথায়
- [ ] **REPORT_INPUTS > KNOWN_ISSUES_SOURCE** — verified bug/fix কোথা থেকে

### Optional
- [ ] **VOICE** — banglish / english / bilingual (default banglish)
- [ ] **KNOWLEDGE_GRAPH** — graphify use করলে; নাহলে `none`
- [ ] **GIT_RULES**, **OWNER**, **REPO_LAYOUT**, **CURRENT_PHASE**

---

## 🎯 কোন project এ কী "journey" দেখাবে (WALKTHROUGH_SUBJECT)

report নিজেই system এর type ধরে নেয় — তুমি শুধু subject টা লিখে দাও:

| Project type            | WALKTHROUGH_SUBJECT এ যা লিখবে                                  |
| ----------------------- | -------------------------------------------------------------- |
| API / backend service   | "the request lifecycle: auth → validate → service → DB → response" |
| Data / ETL pipeline     | "the pipeline stages: fetch → transform → enrich → load"       |
| Library / SDK           | "the core call path from public API → main algorithm → result" |
| ML / scoring system     | "feature extraction → model/formula → score breakdown"         |
| CLI tool                | "command parse → execute → output"                             |
| Full-stack app          | "user action → frontend → API → DB → response render"          |

ঠিকঠাক না বুঝলে কাছাকাছি একটা দাও — report এর "ADAPT TO THE SYSTEM" rule বাকিটা সামলে নেবে।

---

## 📊 Data কীভাবে দেবে (report এর hero dataset)

তিনভাবে — যেটা সুবিধা:

1. **Config এ path দাও** (সহজ): `REPORT_INPUTS > SAMPLE_DATA_PATHS` এ repo-র ভেতরের
   file path লিখো। driver পুরো repo `--add-dir` করে, তাই Claude পড়ে নেবে।
   ```
   SAMPLE_DATA_PATHS: sample_data/ratings.csv
   ```
2. **একটা `sample_data/` ফোল্ডার বানাও** context এর ভেতরে, CSV/JSON রাখো, উপরের মতো path দাও।
3. **Data নেই? সমস্যা নেই** — Claude real schema মিলিয়ে dummy বানাবে আর slide এ
   "SAMPLE DATA — illustrative" badge দেবে (`DATA_MODE="dummy"`)। report আটকাবে না।

⚠️ **dummy শুধু dataset এর জন্য।** Bug / finding / formula কখনো বানানো হয় না — সব real repo থেকে।

---

## 🔢 build.sh এর শেষ সংখ্যাটা (max_stages) কী

`./build.sh report ../ myproj 12` — এখানে `12` = driver সর্বোচ্চ কতবার loop চালাবে
(এক pass = এক stage)। এটা **upper limit, target নয়** — tracker এর সব box টিক হলে
আগেই থেমে যায়। ছোট project → 8, বড় project (অনেক surface) → 12-15। না দিলে default 10.

একই toolkit দিয়ে অন্য phase ও চালানো যায়:

```bash
./build.sh user_stories   ../          # user stories লেখাও
./build.sh architecture   ../          # architecture design
./build.sh abstract_design ../         # interfaces / schemas
./build.sh codegen        ../          # একটা একটা component implement
./build.sh research_report ../         # decisions document করো
./build.sh security_test  ../ myproj 6 # security audit + tests
./build.sh report         ../ myproj 10 # interactive HTML report
```

প্রতিটা phase `.tracker/` এ progress রাখে, তাই session এর মাঝে থামলেও পরেরবার
যেখানে ছিল সেখান থেকে শুরু করবে।

---

## 🧹 .gitignore এ যোগ করো (যদি commit করতে না চাও)

```
_build_tools/.tracker/
build_output/
```

---

## ⚠️ মনে রাখার মতো ৩টা জিনিস

1. **config বদলালেই নতুন project ধরে** — কিন্তু report তত ভালো যত ভালো context দাও।
   তাই সবসময় আসল repo টা context হিসেবে দাও (`../` দিয়ে যেটা যাচ্ছে)।
2. **example config এ `TODO: confirm from repo` থাকলে** — repo খুলে একবার মিলিয়ে নাও।
   public page সব internal দেখায় না।
3. **toolkit এর কোনো core file (prompts/driver) বদলাতে হবে না।** শুধু config।
   ব্যতিক্রম: একদম অন্যরকম কিছু চাইলে `interactive_report.md` এর stage list টা
   tweak করতে পারো — কিন্তু ৯৫% ক্ষেত্রে দরকার হবে না।
