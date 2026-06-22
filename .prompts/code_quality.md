# Prompt: Code Quality Standard (Universal, always-on)

> Inherit `_base.md`. এই file phase নয় — baseline। তুমি যখনই code লিখবে বা review করবে, প্রতিটা rule মানবে।
> Goal: একজন fresher পড়ে বুঝবে; একজন Google/Meta senior দেখে approve করবে। দুইটা একই — good code is obvious code.

## 1. Naming — নাম দেখেই বোঝা যাবে
```python
# BAD
def calc(x, y, z): return x*0.4 + y*0.3 + z*0.3
# GOOD
def calculate_score(commute: float, school: float, safety: float) -> float:
    COMMUTE_W, SCHOOL_W, SAFETY_W = 0.4, 0.3, 0.3
    return commute*COMMUTE_W + school*SCHOOL_W + safety*SAFETY_W
```
`{{NAMING}}` (config) সবসময় মানো।

## 2. Functions — ছোট, single responsibility
- এক function এক কাজ। 30-40 লাইনের বেশি হলে ভাঙো।
- 3+ param হলে dataclass/schema নাও।
- Side effect আর pure logic আলাদা রাখো।

## 3. Constants — magic number নিষেধ
- যেকোনো number/string এর meaning থাকলে named constant এ তোলো (config-নির্ধারিত location এ)।
- Weight/threshold এর পাশে comment এ source লেখো।

## 4. Errors — silent failure নিষেধ
- Bare `except:` নিষেধ। Specific exception ধরো।
- Catch করলে log করো বা re-raise করো — গিলে ফেলো না।
- Fallback থাকলে কেন safe তা comment এ।

## 5. Comments — "why", "what" নয়
- Code কী করছে তা code ই বলবে। কেন করছে (non-obvious choice) সেটা comment।
- `{{DOMAIN_RULES}}` enforce করা প্রতি জায়গায় rule এর source লিখে দাও।

## 6. Types & docstrings
- Public function এ full type hints + এক-লাইন docstring (purpose + non-obvious returns)।

## 7. Tests আগে চিন্তা করো
- Test করা যায় না এমন design রিফ্যাক্টর করো। External call mock-able রাখো।
- Formula/business rule test ছাড়া merge নয়।

## Hard NOs (config থেকেও)
- `{{DONT}}` এর সব।
- Hardcoded secret/IP/credential।
- `{{FLAG_ON_SIGHT}}` এর কোনো string।
