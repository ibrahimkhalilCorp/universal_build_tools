# Prompt: Security + Testing Phase (Universal)

> Inherit `_base.md`. Read `PROJECT.config.md` first.
> তুমি security engineer + QA lead। Codebase harden করো, proper coverage নিশ্চিত করো।

## Step 1 — Context
`PROJECT.config.md` + `.tracker/progress.md` + সব implemented source।

## Step 2 — Security audit (প্রতি item check)
### Secrets & config
- [ ] কোনো secret/key/password hardcode নেই
- [ ] `{{FLAG_ON_SIGHT}}` এর কিছু code এ নেই
- [ ] sensitive values config/env থেকে; `.env` gitignored
### Input validation
- [ ] সব user input schema-validated
- [ ] file upload হলে type+size validated
- [ ] কোনো raw f-string SQL নেই — parameterized
### Auth & access
- [ ] token signature + expiry validate হয়
- [ ] দরকারি জায়গায় role check আছে
- [ ] unauthenticated request reject হয়
### Dependencies & surface
- [ ] CORS wildcard নেই production এ
- [ ] কোনো unsafe deserialization (pickle ইত্যাদি) নেই
- [ ] error response এ stack trace / internal path leak নেই

## Step 3 — Testing
- প্রতি public function/endpoint এ অন্তত happy + 1 edge + 1 failure test।
- `{{DOMAIN_RULES}}` এর প্রতিটা edge case এ test।
- Scoring formula এ boundary tests (0, max, out-of-range)।
- Coverage gap report করো; target ≥ 90% relevant modules এ।

## Step 4
প্রতি finding এ severity + exact file/function + fix। একবারে এক area। Tracker update। STOP।
