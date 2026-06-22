# Prompt: Interactive Report (Universal, Per-Stage Build)

> Inherit `.prompts/_base.md`. Read `PROJECT.config.md` first.
> You are building ONE part of a larger interactive HTML report. A driver script
> invokes this prompt ONCE PER STAGE. Do exactly ONE stage this run, then STOP.
> Do NOT attempt the whole report in one run — it collapses into a skeleton.

GOAL (finished product, across all stages): a SINGLE self-contained, runnable
interactive HTML report for **`{{PROJECT_NAME}}`** that walks through
**`{{REPORT_INPUTS.WALKTHROUGH_SUBJECT}}`**. One `.html` file: inline CSS + inline
SVG/canvas + vanilla JS, no external libraries, no build step, opens by
double-clicking. Finished size is LARGE (~3000–4000 lines). A ~900-line file means
the build is NOT finished — more stages remain.

This is a **teaching + debugging instrument**, not a static slide deck. It must be
genuinely runnable: buttons that compute over embedded data, animations that play,
graphs you can drag, a dark/light mode toggle.

============================================================
ADAPT TO THE SYSTEM (this is what makes it universal)
============================================================
Before writing, DISCOVER the target system's real shape from the inputs and shape
the report around it — do not assume any specific project:

- **If it's a pipeline/ETL** → spine = stage sequence; each stage shows
  DATA IN → DATA OUT, the transform math, the engine, known issues.
- **If it's an API/service** → spine = request lifecycle (parse → query →
  compute → response); show each hop's transformation + algorithm.
- **If it's a library** → spine = call graph / public API surface; show
  the core algorithm running on sample input.
- **If it's an ML/scoring system** → spine = feature → model/formula → score;
  make scoring interactive with live sliders.
- **Otherwise** → pick the closest "journey", note it in the tracker.

For EVERY stage, present these four panels IN THIS ORDER:
1. **DATA IN → DATA OUT** — real record before/after, changed fields highlighted.
2. **THE MATH** — exact formula(s), computed LIVE in JS on a real hero record.
3. **THE ALGORITHM / ENGINE** — what does the work, 2–4 lines + inline diagram.
4. **KNOWN PROBLEMS / FIXES** — real verified issues, collapsible incident cards.

============================================================
HOW EACH RUN WORKS (every invocation)
============================================================
1. Read `TRACKER PATH` (passed by driver). If absent → STAGE 0: create tracker
   with the stage checklist below (all unchecked) + note the chosen spine.
2. Read current `OUTPUT REPORT PATH` (passed by driver) if it exists.
3. Find the FIRST unchecked stage `[ ]`. Do ONLY that stage.
4. EXTEND the HTML (append/insert the new <script> block) — NEVER regenerate
   or overwrite finished stages. The scaffold from Stage 0 must never be touched again.
5. Run that stage's self-check. If it passes, mark it `[x]` in the tracker.
6. Print: stage done · new total line count · self-check result. Then STOP.

============================================================
"RUNNABLE" REQUIREMENT (most important)
============================================================
- Every stage has a **▶ Run this step** button that ANIMATES the transform:
  fields fly in, numbers count up, bars fill, nodes pulse, results re-rank.
- A top **"Run entire journey"** button plays all stages in sequence with delays.
- State persists: the hero record run through stage 1 is the SAME object at stage N.
- Every computed value is computed FOR REAL in JS from embedded data — never hardcoded.
- A curious engineer should read the JS and trust it completely.

============================================================
ANIMATION SYSTEM — implement ALL of these
============================================================
Every stage MUST use at least 3 of these animation techniques:

**A. Morphing data records** — when ▶ Run fires, fields animate from old value to new
  value using a JS counter/interpolator (numbers count up over ~600ms, strings fade
  cross-dissolve). Changed fields glow green then settle.

**B. Animated process flow** — for pipeline/API stages, draw the step sequence as SVG
  nodes connected by animated dashed lines. When ▶ Run fires, highlight each node in
  sequence (pulse + color change), with a moving dot traveling the path:
  ```js
  // SVG stroke-dashoffset animation — the traveling dot pattern
  path.style.animation = 'dash 1.2s linear infinite';
  @keyframes dash { to { stroke-dashoffset: -24; } }
  ```

**C. Bar/score fill animations** — for any metric (NDCG, scores, weights, benchmarks),
  render bars at width:0 then animate to final width via CSS transition over 800ms.
  Show the numeric value counting up inside the bar.

**D. Node pulse on the system map** — when a stage runs, the corresponding node on
  the overview SVG map pulses with a ripple ring (SVG circle + CSS keyframe scale+fade).

**E. Step-by-step reveal** — multi-step processes (e.g. training lifecycle, auth chain)
  reveal each step one at a time with a 300ms stagger when ▶ Run fires. Each step
  appears with a slide-in from the left + opacity fade.

**F. Diff highlighting** — DATA IN→OUT panel: fields that changed get a 2-second
  highlight sweep (background flash from --ok-glow to transparent), like a git diff.

**G. Number counters** — any numeric output (scores, counts, ranks) animates from 0
  to final value using a JS easing function over ~700ms. Never show a static number
  where a counter could run.

============================================================
DARK / LIGHT MODE — mandatory
============================================================
STAGE 0 MUST implement a dark/light mode toggle. Requirements:

```css
/* Dark mode (default) */
:root {
  --bg:#060e1c; --bg2:#0a1730; --panel:#0d1c38; --panel2:#11254a;
  --line:#1c3357; --line2:#26426f;
  --ink:#e6eefc; --ink-dim:#9fb3d6; --ink-faint:#64789f;
  --accent:#2e75b6; --violet:#6e59a5; --ok:#86efac; --warn:#b8860b;
  --crit:#c8201a; --info:#93c5fd;
  --ok-glow: rgba(134,239,172,.28); --shadow: rgba(0,0,0,.7);
}
/* Light mode — applied via class on <html> */
html.light {
  --bg:#f0f4fa; --bg2:#e4ecf7; --panel:#ffffff; --panel2:#dde7f5;
  --line:#c2d0e8; --line2:#a8bedd;
  --ink:#0f1f3d; --ink-dim:#3a5080; --ink-faint:#7a96c0;
  --accent:#1a5fa0; --violet:#5040a0; --ok:#16a34a; --warn:#b45309;
  --crit:#b91c1c; --info:#2563eb;
  --ok-glow: rgba(22,163,74,.2); --shadow: rgba(0,0,0,.15);
}
```

The toggle button MUST:
- Live in the topbar (sticky), always visible
- Show a sun/moon icon and animate between states (CSS transition on all --vars)
- Persist the chosen mode in a JS var (NOT localStorage)
- Work correctly for all panels, code blocks, SVGs, charts, and incident cards

```js
// Toggle implementation
let lightMode = false;
function toggleMode() {
  lightMode = !lightMode;
  document.documentElement.classList.toggle('light', lightMode);
  document.getElementById('modeBtn').textContent = lightMode ? '☀ Light' : '☾ Dark';
}
```

============================================================
VISUAL SYSTEM
============================================================
Dark-first, technical "engineering" aesthetic. IBM Plex Mono for UI/labels/data;
Georgia serif for big headlines. Uppercase letter-spaced eyebrows, pill badges for
key constants, status dots (green=ok, amber=cached, red=bug), glow/shadow.
Sticky left rail (stage nav, current highlighted). Top progress bar.
Each slide: eyebrow → serif headline → "what to interact with" subtitle → visual.
Fully responsive. NO localStorage/sessionStorage.

Key CSS keyframes to define in STAGE 0:
```css
@keyframes dash     { to { stroke-dashoffset: -24; } }
@keyframes pulse-ring { 0%{r:12;opacity:.9} 100%{r:28;opacity:0} }
@keyframes count-up { from{opacity:0;transform:translateY(4px)} to{opacity:1;transform:none} }
@keyframes bar-fill { from{width:0} to{width:var(--bar-target)} }
@keyframes step-in  { from{opacity:0;transform:translateX(-12px)} to{opacity:1;transform:none} }
@keyframes glow-flash { 0%{background:var(--ok-glow)} 100%{background:transparent} }
```

============================================================
STAGE CHECKLIST (tracker — ONE per run)
============================================================
STAGE 0 — Scaffold. Full CSS design system including ALL keyframes above and
  BOTH dark+light mode CSS vars. Dark/light toggle button in topbar. Auth wall
  (cosmetic). Deck container. Sticky stage rail. Top progress bar. Prev/next nav
  + arrow-key support. Empty STAGES array. Dataset embedded as JS const with
  DATA_MODE flag. "SAMPLE DATA — illustrative" badge when dummy. All animation
  helper functions defined (animCounter, animBar, animSteps, animDash, animPulse,
  animDiff). SELF-CHECK: page loads in dark AND light mode, rail works, toggle works.

STAGE 1 — Overview + animated system map. Cover stats band. Hand-built SVG map
  of the system's REAL components/datastores as clickable nodes with animated
  dashed connectors. When ▶ Run fires: nodes pulse in sequence (pulse-ring
  animation) with a traveling dot along each connector path. Node click → sticky
  inspector panel showing real module path + rules. Legend. SELF-CHECK: map
  renders with real names, nodes clickable, pulse animation plays on Run.

STAGE 2..N-2 — One journey stage per run (4 panels + animation). For each real
  stage/hop of the system: DATA IN→OUT with diff-highlight animation; THE MATH
  with live number counters; ENGINE with animated process-flow SVG showing the
  step sequence; KNOWN PROBLEMS as collapsible incident cards. ▶ Run button
  triggers all animations in sequence (diff → counter → bar fills → step reveal).
  SELF-CHECK: Run button fires all 3+ animation types; counters compute real values.

STAGE N-1 — Interactive core widget. The system's headline operation as a live
  playground. Input sliders/controls wired to real parameters. Output shown as
  animated bars filling to computed values. Full breakdown panel. All numbers
  animate when inputs change. SELF-CHECK: changing inputs triggers re-animation.

STAGE N — Polish + close. Wire "Run entire journey". Force-directed or grid
  entity graph (draggable). Verify all hard minimums. Remove dead handlers.
  Mark DONE. SELF-CHECK: all minimums met, dark+light both clean.

============================================================
HARD MINIMUMS (finished file must satisfy all)
============================================================
8+ stages · 12+ inline SVG/canvas visuals · every map node clickable ·
6+ code/formula blocks with real identifiers · dark/light toggle working ·
3+ animation types per stage (from the 7 listed above) · all Run buttons
compute + animate with real numbers · 1 interactive core widget · 1 draggable
entity graph · no empty onclick, no dead tabs · NO localStorage/sessionStorage.

============================================================
OPTIONAL: embedded AI assistant
============================================================
If it adds value, dock a chat (POST https://api.anthropic.com/v1/messages,
model "claude-sonnet-4-6", max_tokens 1000, no api key in code),
with try/catch, suggested chips, node-click seeding. Else skip + note in tracker.

============================================================
TONE & RESPONSIBILITY
============================================================
Honest, precise, system-specific. Cite exact file/function/constant + real data.
Never fabricate findings, metrics, or data. Match `{{VOICE}}`.

============================================================
THIS RUN'S OUTPUT
============================================================
Write/extend `OUTPUT REPORT PATH` (passed by driver at runtime).
Update `TRACKER PATH` (passed by driver at runtime).
Do ONE stage. Print stage + line count + self-check. Then STOP.
