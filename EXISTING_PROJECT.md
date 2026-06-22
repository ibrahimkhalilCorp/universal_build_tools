# EXISTING_PROJECT.md — চলতি (brownfield) repo তে toolkit বসানোর checklist

> Code আগে থেকেই আছে। তাই এখানে কাজটা উল্টো: তুমি কিছু "design" করছ না,
> toolkit কে তোমার **আসল repo** টা পড়িয়ে দিচ্ছ যাতে report / codegen / audit
> বাস্তব component এর উপর দাঁড়ায়।

---

## ⚡ TL;DR (৪ ধাপ)

```bash
# 1. toolkit copy করো repo এর subfolder এ (repo root পরিষ্কার থাকে)
cp -r universal_build_tools  YourRepo/_build_tools

# 2. config বানাও — কাছাকাছি একটা example নাও
cd YourRepo/_build_tools
cp templates/PROJECT.config.aaizaql.md  PROJECT.config.md   # library হলে
# অথবা .heyhomex.md (pipeline/full-stack) / .proactive_ai.md (multi-tenant)

# 3. PROJECT.config.md ভরো — PROJECT_MODE: brownfield দাও (নিচের checklist)

# 4. চালাও — CONTEXT হিসেবে আসল repo (../) দাও
./build.sh report ../ yourrepo 12
```

---

## ✅ brownfield এ যা আলাদা করে খেয়াল রাখবে

- [ ] **PROJECT_MODE: brownfield** — config এ এটা সেট করো (নাহলে toolkit code দেখে infer করবে, কিন্তু explicit ভালো)
- [ ] **CONTEXT সবসময় আসল repo** — `./build.sh report ../ ...` এর `../` যেন তোমার
      real code এ point করে, খালি toolkit folder এ নয়। driver পুরোটা `--add-dir` করে।
- [ ] **REPO_LAYOUT** — top-level dirs list করো, যাতে Claude কোথায় কী খুঁজবে জানে।
- [ ] **STRUCTURE_RULES + NAMING** — তোমার existing convention লেখো; নতুন code যেন
      মিলে যায়, নতুন pattern না বানায়।
- [ ] **KNOWN_ISSUES_SOURCE** — verified bug/fix কোথায় (issue tracker, audit notes,
      CHANGELOG)। report এর findings এখান থেকেই আসবে — বানানো নয়।
- [ ] **SAMPLE_DATA_PATHS** — repo এর ভেতরের real sample data, যাতে report এ dummy লাগে না।

## 🆚 greenfield থেকে যে যে জায়গায় behavior বদলায়

| জিনিস            | greenfield (নতুন)                  | brownfield (চলতি repo)              |
| ---------------- | ---------------------------------- | ----------------------------------- |
| codegen          | design থেকে scratch এ লেখে          | existing pattern মিলিয়ে যোগ করে      |
| report journey   | planned/intended (`PLANNED` badge) | real, যা code এ আছে                 |
| findings section | "design risks / open decisions"    | real verifiable bugs/findings       |
| source of truth  | architecture/abstract_design output| আসল repo এর code                    |

এই switch টা `_base.md > 0.5` rule নিজে সামলায় — তুমি শুধু `PROJECT_MODE` ঠিক দাও।

## 🔁 একই repo তে দুই mode

বড় কাজ brownfield, কিন্তু ভেতরে একটা **নতুন module** scratch এ বানাচ্ছ?
দুই ভাবে:
- পুরো config `brownfield` রাখো; নতুন module এর codegen এ prompt কে বলে দাও
  "এই module টা নতুন, scratch এ" — `_base.md` truth policy বাকিটা সামলাবে।
- অথবা ওই module এর জন্য আলাদা একটা `PROJECT.config.md` (greenfield) রেখে
  আলাদা run চালাও। ছোট, isolated module হলে এটা পরিষ্কার।

---

## ⚠️ ৩টা মনে রাখার জিনিস

1. **brownfield এ findings কখনো dummy নয়** — সব আসল repo থেকে verifiable হতে হবে।
   শুধু dataset দরকার হলে dummy চলে, তাও `SAMPLE DATA — illustrative` badge সহ।
2. **toolkit এর core file বদলাতে হবে না** — শুধু `PROJECT.config.md`। mode-handling
   already `_base.md` এ আছে।
3. **নতুন project হলে** `NEW_PROJECT.md` দেখো — এই পাতা শুধু চলতি repo এর জন্য।
