#!/usr/bin/env bash
# Universal build driver.
# Loops ONE stage per Claude CLI call until the phase tracker reports DONE.
# This sidesteps the single-response token ceiling that produces skeletons.
#
# Usage:
#   ./build.sh <phase> <context_path> [system_name] [max_stages]
#
# Examples:
#   # from inside the toolkit subfolder, pointing at the parent repo:
#   ./build.sh report  ../ aaizaql 10           # build interactive HTML report
#   ./build.sh codegen ../                       # implement next component
#   ./build.sh security_test ../ myproj 6
#
# Layout (Option B — toolkit lives in a subfolder, repo stays clean):
#   AaizaQL/
#   ├── _build_tools/   ← this toolkit (run from here)
#   │   ├── build.sh  PROJECT.config.md  CLAUDE.md  .prompts/  .tracker/
#   └── aaizaql/  tests/  ...   ← your real code (the CONTEXT)
#
# Phases map to .prompts/<phase>.md  (report -> interactive_report.md).
# The script finds its OWN folder, so toolkit files resolve no matter where
# you run it from. CONTEXT (your repo) is resolved relative to your shell.

set -euo pipefail

# --- resolve the toolkit's own directory (so cwd doesn't matter) ---
TOOLKIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

PHASE="${1:?Usage: build.sh <phase> <context_path> [system_name] [max_stages]}"
CONTEXT="${2:?Provide the repo/context path}"
SYSTEM="${3:-project}"
MAX="${4:-10}"

# Make CONTEXT absolute from the caller's cwd BEFORE we cd into the toolkit.
CONTEXT="$(cd "$CONTEXT" && pwd)"
# All toolkit-relative reads (config, prompts, tracker) happen from here.
cd "$TOOLKIT_DIR"

# Resolve phase -> prompt file (allow a few friendly aliases).
case "$PHASE" in
  report|interactive_report) PROMPT_FILE=".prompts/interactive_report.md"; TRACKER=".tracker/report_progress.md" ;;
  spec|openspec)             PROMPT_FILE=".prompts/spec.md";                TRACKER=".tracker/spec_progress.md" ;;
  *)                         PROMPT_FILE=".prompts/${PHASE}.md";            TRACKER=".tracker/progress.md" ;;
esac

[ -f "$PROMPT_FILE" ] || { echo "❌ No prompt at $PROMPT_FILE"; exit 1; }
[ -f "PROJECT.config.md" ] || { echo "❌ PROJECT.config.md missing — fill it in first."; exit 1; }

# Where the report HTML lands. Override with OUT_DIR env var if you like.
# Default: a `build_output/` folder beside your repo (Option B keeps repo clean).
OUT_DIR="${OUT_DIR:-${CONTEXT}/build_output}"
mkdir -p "$OUT_DIR"
OUT="${OUT_DIR}/${SYSTEM}_report.html"   # only used by report phase
mkdir -p .tracker

echo "phase=$PHASE  system=$SYSTEM  max=$MAX  prompt=$PROMPT_FILE"

# --- soft preflight: warn (never block) if grounding/spec missing ---
# Graphify grounding
if grep -qiE '^\s*-\s*TOOL:\s*(none)?\s*$' PROJECT.config.md; then
  echo "ℹ graphify: not configured (KNOWLEDGE_GRAPH.TOOL=none) — proceeding without graph grounding"
else
  echo "✓ graphify: configured — phases will pull graph grounding (soft)"
fi
# Spec layer
SPEC_DIR="$(grep -E '^\s*-\s*DIR:' PROJECT.config.md | head -1 | sed -E 's/.*DIR:\s*//' | tr -d ' ')"
SPEC_DIR="${SPEC_DIR:-openspec}"
if [ -d "${CONTEXT}/${SPEC_DIR}" ] || [ -d "${SPEC_DIR}" ]; then
  echo "✓ spec layer: ${SPEC_DIR}/ found"
else
  echo "ℹ spec layer: no ${SPEC_DIR}/ yet — run './build.sh spec ${CONTEXT}' to create one (soft, build continues)"
fi

for i in $(seq 1 "$MAX"); do
  echo "──────────── pass $i / $MAX ────────────"

  # One stage per invocation. -p = single prompt run, then exit.
  # Always feed the config + base + the phase prompt together.
  claude -p "$(cat PROJECT.config.md)

$(cat .prompts/_base.md)

$(cat "$PROMPT_FILE")

SYSTEM NAME: ${SYSTEM}
CONTEXT / INPUTS: ${CONTEXT}
OUTPUT REPORT PATH: ${OUT}
TRACKER PATH: ${TOOLKIT_DIR}/${TRACKER}
(Write/extend the report at OUTPUT REPORT PATH and update the tracker at TRACKER PATH. Ignore any /mnt/... example paths shown inside the prompt text.)
Do exactly ONE stage per the prompt's rules, then stop." \
    --add-dir "$CONTEXT" \
    --add-dir "$TOOLKIT_DIR" \
    --allowedTools "Read,Write,Edit,Bash"

  # Stop once the tracker has no unchecked boxes left.
  if [ -f "$TRACKER" ] && ! grep -q '\[ \]' "$TRACKER"; then
    echo "✅ All stages complete for phase: $PHASE"
    break
  fi

  if [ "$PHASE" = "report" ] || [ "$PHASE" = "interactive_report" ]; then
    LINES=$( [ -f "$OUT" ] && wc -l < "$OUT" || echo 0 )
    echo "current report size: ${LINES} lines"
  fi
done

echo "Done with phase: $PHASE"
[ -f "$OUT" ] && echo "Report: $OUT ($(wc -l < "$OUT") lines)" || true
