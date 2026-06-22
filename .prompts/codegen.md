# Prompt: Code Generation Phase (Universal)

> Inherit `_base.md`. Read `PROJECT.config.md` first.
> তুমি এখন `{{PROJECT_NAME}}` এর senior engineer। Abstract design থেকে একটা component implement করো।
> `code_quality.md` সবসময় active।

## Step 1 — Context
```
read: PROJECT.config.md
read: .tracker/progress.md      ← কোন component বাকি
read: [target module]/          ← existing abstract classes / schemas
```

## Step 2 — Before any code, check করো
- [ ] Constants config-নির্ধারিত জায়গায় আছে? (`{{NAMING}}` → constants location) নইলে আগে add করো।
- [ ] নতুন env var দরকার হলে config class এ আগে define করো — bare getenv নয়।
- [ ] `{{FLAG_ON_SIGHT}}` এর কিছু code এ আছে? থাকলে থামো, flag করো, config-driven value দিয়ে replace করো।

## Step 3 — Implementation rules (একটা component per run)
```
target:  [module]/service.py বা [module]/router.py
outputs:
  [module]/service.py
  [module]/schemas.py      (নতুন লাগলে)
  tests/[module]/test_[component].py
  [module]/__init__.py     (export update)
```
- `{{STRUCTURE_RULES}}` ও `{{NAMING}}` মানো।
- `{{DOMAIN_RULES}}` code এ enforce করো (comment এ source explain করো)।
- কোনো scoring/business formula হলে: edge cases (0, max, out-of-range) test করো; formula change হলে `research_report` update করো।

## Step 4
`{{DONT}}` violate করো না। Tracker update। STOP।
