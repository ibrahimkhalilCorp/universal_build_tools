#!/usr/bin/env bash
# Universal build driver.
# Loops ONE stage per Claude CLI call until the phase tracker reports DONE.
# This sidesteps the single-response token ceiling that produces skeletons.
#
# ═══ WHERE TO RUN THIS (important!) ═══════════════════════════════════════
#   ✅ Git Bash (MINGW64) on Windows, or any normal bash shell on Linux/macOS.
#   ❌ NOT PowerShell/CMD (these can't run .sh scripts natively).
#   ❌ NOT inside an interactive Claude Code session. build.sh CALLS the
#      claude CLI itself — running it from inside Claude adds an extra
#      agent layer that executes it with its own judgment (backgrounding
#      it, answering its own questions, etc). Open a plain Git Bash
#      terminal and run it directly.
# ══════════════════════════════════════════════════════════════════════════
#
# ⚠ PATCHED (2026-07-01): removed "Bash" from --allowedTools.
#   --add-dir only scopes Read/Write/Edit — Bash is an unrestricted shell and
#   can cd/write ANYWHERE on disk regardless of --add-dir. A prior run used
#   Bash to wander outside CONTEXT and edit an unrelated repo, then rewrote
#   PROJECT.config.md to retarget the project at that directory. Never grant
#   bare "Bash" again.
#
# ⚠ PATCHED (2026-07-03):
#   1. codegen now gets a NARROW Bash allowlist — Bash(python -m pytest:*),
#      ruff, mypy, pip install — so its own tests actually run instead of
#      being "verified by read-through". Still no bare Bash, no cd-anywhere.
#   2. graphify bootstrap is update-first: `graphify update` is AST-only
#      (no LLM key) and builds the graph from scratch fine. `extract`
#      (semantic, needs an API key) is opt-in via GRAPHIFY_EXTRACT=1.
#   3. CURRENT_PHASE now auto-advances DETERMINISTICALLY (script-level sed
#      on a fixed phase sequence) when a phase's tracker completes — nested
#      sessions no longer decide this themselves.
#   4. Preflight now detects a stale openspec/project.md whose MODE
#      contradicts PROJECT.config.md (the post-reset blocker) and warns.
#   Companion: see reset.sh for safe full-state resets.
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
GRAPHIFY_TOOL="$(grep -E '^\s*-\s*TOOL:' PROJECT.config.md | head -1 | sed -E 's/.*TOOL:\s*//' | tr -d ' \r')"
GRAPH_JSON="${CONTEXT}/graphify-out/graph.json"

if [ -z "$GRAPHIFY_TOOL" ] || [ "$GRAPHIFY_TOOL" = "none" ]; then
  echo "ℹ graphify: not configured (KNOWLEDGE_GRAPH.TOOL=none) — proceeding without graph grounding"
elif ! command -v graphify >/dev/null 2>&1; then
  echo "⚠ graphify: TOOL=graphify in config but 'graphify' CLI not found on PATH — proceeding without grounding"
elif [ "$PHASE" = "codegen" ]; then
  # `graphify update` is AST-only (no LLM key needed) and can build the graph
  # from scratch on first run — so it is ALWAYS the default. `graphify extract`
  # (semantic pass, needs an LLM backend/API key) is opt-in via GRAPHIFY_EXTRACT=1.
  if [ "${GRAPHIFY_EXTRACT:-0}" = "1" ] && [ ! -f "$GRAPH_JSON" ]; then
    echo "▶ graphify: GRAPHIFY_EXTRACT=1 — running full semantic extract (needs an LLM backend)"
    graphify extract "$CONTEXT" || echo "⚠ graphify extract failed — falling back to AST-only update (soft)"
  fi
  echo "↻ graphify: building/refreshing graph (AST-only, no LLM needed)"
  graphify update "$CONTEXT" || echo "⚠ graphify update failed — continuing without fresh grounding (soft)"
else
  echo "✓ graphify: configured — phases will pull graph grounding (soft)"
fi
# Spec layer
SPEC_DIR="$(grep -E '^\s*-\s*DIR:' PROJECT.config.md | head -1 | sed -E 's/.*DIR:\s*//' | tr -d ' ')"
SPEC_DIR="${SPEC_DIR:-openspec}"
if [ -d "${CONTEXT}/${SPEC_DIR}" ] || [ -d "${SPEC_DIR}" ]; then
  echo "✓ spec layer: ${SPEC_DIR}/ found"
  # Staleness guard: openspec/project.md is only CREATED by the spec phase,
  # never overwritten — after a project reset it can silently contradict
  # PROJECT.config.md (this caused a real blocker: a stale brownfield
  # project.md citing a deleted directory). Detect the mismatch up front.
  SPEC_PROJECT_MD="${CONTEXT}/${SPEC_DIR}/project.md"
  if [ -f "$SPEC_PROJECT_MD" ]; then
    CFG_MODE="$(grep -E '^\s*-\s*PROJECT_MODE:' PROJECT.config.md | head -1 | sed -E 's/.*PROJECT_MODE:\s*//; s/<!--.*-->//' | tr -d ' \r')"
    SPEC_MODE="$(grep -iE 'MODE:.*\b(greenfield|brownfield)\b' "$SPEC_PROJECT_MD" | head -1 | grep -oiE 'greenfield|brownfield' | tr '[:upper:]' '[:lower:]')"
    if [ -n "$CFG_MODE" ] && [ -n "$SPEC_MODE" ] && [ "$CFG_MODE" != "$SPEC_MODE" ]; then
      echo "⚠⚠ STALE SPEC DETECTED: ${SPEC_DIR}/project.md says MODE=$SPEC_MODE but PROJECT.config.md says PROJECT_MODE=$CFG_MODE."
      echo "   This usually means project.md survived a reset. Fix it (or run ./reset.sh) before phases ground against it."
    fi
  fi
else
  echo "ℹ spec layer: no ${SPEC_DIR}/ yet — run './build.sh spec ${CONTEXT}' to create one (soft, build continues)"
fi

for i in $(seq 1 "$MAX"); do
  echo "──────────── pass $i / $MAX ────────────"

  # Tool permissions per phase. NEVER grant bare "Bash" (see header warning).
  # codegen alone gets a narrow command allowlist so its own tests can actually
  # run instead of being "verified by read-through". The Bash(prefix:*) pattern
  # allows only commands starting with that prefix — no cd-anywhere shell.
  if [ "$PHASE" = "codegen" ]; then
    ALLOWED_TOOLS="Read,Write,Edit,Bash(python -m pytest:*),Bash(python -m ruff:*),Bash(python -m mypy:*),Bash(pip install:*)"
  else
    ALLOWED_TOOLS="Read,Write,Edit"
  fi

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

SCOPE GUARDRAIL (hard rule, not a suggestion):
- All file writes/edits MUST stay strictly inside CONTEXT (${CONTEXT}) or TOOLKIT_DIR (${TOOLKIT_DIR}).
- Do NOT cd, read-for-grounding-then-write, or otherwise modify ANY path outside those two directories, even if you find what looks like a related/older/'more real' project elsewhere on disk.
- If you discover a related project outside CONTEXT, STOP, do not touch it, and report its path in the tracker/output instead of editing it.
- Do NOT rewrite PROJECT.config.md's PROJECT_MODE, CURRENT_PHASE, or REPO_LAYOUT to point at a different directory than CONTEXT. If you believe CONTEXT is wrong, report that in the tracker and stop — do not silently retarget the project yourself.

Do exactly ONE stage per the prompt's rules, then stop." \
    --add-dir "$CONTEXT" \
    --add-dir "$TOOLKIT_DIR" \
    --allowedTools "$ALLOWED_TOOLS"

  # Keep the graph fresh between passes during codegen (deterministic, no LLM
  # judgment involved — same fixed command every time, script-controlled).
  if [ "$PHASE" = "codegen" ] && [ "$GRAPHIFY_TOOL" = "graphify" ] && command -v graphify >/dev/null 2>&1; then
    echo "↻ graphify: updating graph after pass $i"
    graphify update "$CONTEXT" || echo "⚠ graphify update failed — continuing (soft)"
  fi

  # Stop once the tracker has no unchecked boxes left.
  if [ -f "$TRACKER" ] && ! grep -q '\[ \]' "$TRACKER"; then
    echo "✅ All stages complete for phase: $PHASE"

    # ── Deterministic CURRENT_PHASE advance (script-level, no agent judgment) ──
    # Previously each nested session decided for itself whether to advance the
    # phase — some did, some left a handoff note, causing blockers. Now the
    # SCRIPT advances it: fixed sequence, visible log line, nothing else edited.
    CFG_MODE="$(grep -E '^\s*-\s*PROJECT_MODE:' PROJECT.config.md | head -1 | sed -E 's/.*PROJECT_MODE:\s*//; s/<!--.*-->//' | tr -d ' \r')"
    if [ "$CFG_MODE" = "brownfield" ]; then
      SEQ="spec codegen research_report security_test report"
    else
      SEQ="spec user_stories architecture abstract_design codegen research_report security_test report"
    fi
    NEXT=""
    PREV=""
    for p in $SEQ; do
      if [ "$PREV" = "$PHASE" ]; then NEXT="$p"; break; fi
      PREV="$p"
    done
    if [ -n "$NEXT" ]; then
      sed -i -E "s|^(\s*-\s*CURRENT_PHASE:).*|\1 ${NEXT} <!-- auto-advanced by build.sh after '${PHASE}' completed, $(date +%F) -->|" PROJECT.config.md
      echo "➡ CURRENT_PHASE auto-advanced: ${PHASE} → ${NEXT} (PROJECT.config.md updated by build.sh)"
    else
      echo "ℹ '${PHASE}' has no successor in the ${CFG_MODE:-greenfield} sequence — CURRENT_PHASE left unchanged"
    fi
    break
  fi

  if [ "$PHASE" = "report" ] || [ "$PHASE" = "interactive_report" ]; then
    LINES=$( [ -f "$OUT" ] && wc -l < "$OUT" || echo 0 )
    echo "current report size: ${LINES} lines"
  fi
done

echo "Done with phase: $PHASE"
[ -f "$OUT" ] && echo "Report: $OUT ($(wc -l < "$OUT") lines)" || true