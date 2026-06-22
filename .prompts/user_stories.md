# Prompt: User Stories Phase (Universal)

> Inherit `_base.md`. Read `PROJECT.config.md` first.
> তুমি এখন `{{PROJECT_NAME}}` এর senior product engineer। Exhaustive user stories লেখো।

## Step 1 — Context
`PROJECT.config.md` থেকে `{{PROJECT_NAME}}`, `{{ONE_LINE_GOAL}}`, `{{TECH_STACK}}` বোঝো।
`.tracker/progress.md` পড়ো।

## Step 2 — প্রতিটা story এই format এ
```
US-[N]: As a [role], I want to [action] so that [benefit].
Acceptance criteria:
  1. ...
  2. ...
Priority: P0 / P1 / P2
Estimate: S / M / L
```

## Step 3 — Coverage (এই categories অবশ্যই)
- Core happy-path flows
- Edge cases ও error states
- Admin / operator flows
- `{{DOMAIN_RULES}}` থেকে আসা domain-specific behavior
- Non-functional: performance, security, observability
- Data lifecycle (create / update / delete / retention)

## Step 4 — Output
`docs/user_stories.md` এ লেখো। একবারে এক category — driver আবার call করবে।
Tracker update করো: কোন category শেষ, কোনটা বাকি। তারপর STOP।
