#!/usr/bin/env bash
# auto.sh — এক command, পুরো toolkit নিজে চালায়।
#
# ⚠️ কোথায় চালাবে: Git Bash (Windows) বা সাধারণ bash terminal-এ, সরাসরি।
#    Claude Code session-এর ভেতরে NA — এই script নিজেই claude CLI call করে;
#    Claude-এর ভেতরে চালালে সে executor হয়ে নিজে সিদ্ধান্ত নিতে শুরু করে।
#    PowerShell/CMD-ও না (.sh চলে না)।
#
# তুমি শুধু এটা চালাও:
#     ./auto.sh ../              # CONTEXT = তোমার আসল repo
#     ./auto.sh ../ myproj 12    # নাম + max_stages দিতে চাইলে
#
# এটা নিজে যা করে:
#   1. greenfield না brownfield — repo দেখে detect করে (config খালি থাকলে)
#   2. graph + spec configured কিনা দেখে (soft — না থাকলে skip, থামে না)
#   3. ঠিক phase sequence নিজে চালায়: spec → (design phases) → codegen
#      → research_report → security_test → report
#   4. প্রতি phase build.sh দিয়ে চলে, tracker দেখে এক phase শেষ হলে পরেরটা।
#
# কিছু config করতে হয় না — তবে PROJECT.config.md এ PROJECT_NAME / ONE_LINE_GOAL
# / TECH_STACK ভরা থাকলে output অনেক ভালো হয়।

set -euo pipefail

TOOLKIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTEXT="${1:?Usage: ./auto.sh <repo_path> [system_name] [max_stages]}"
SYSTEM="${2:-project}"
MAX="${3:-10}"

CONTEXT="$(cd "$CONTEXT" && pwd)"
cd "$TOOLKIT_DIR"

[ -f PROJECT.config.md ] || { echo "❌ PROJECT.config.md নেই — আগে ভরো।"; exit 1; }

cfg() { grep -E "^\s*-\s*$1:" PROJECT.config.md | head -1 | sed -E "s/.*$1:\s*//; s/<!--.*-->//" | tr -d ' '; }

echo "════════════════════════════════════════════"
echo " AUTO BUILD — toolkit নিজে চালাচ্ছে"
echo " context: $CONTEXT"
echo "════════════════════════════════════════════"

# ── 1. greenfield vs brownfield detect ───────────────────────────
MODE="$(cfg PROJECT_MODE)"
if [ -z "$MODE" ]; then
  # config খালি → repo দেখে infer। code-ish file গুলো গুনি (toolkit/spec/output বাদ)।
  CODE_COUNT="$(find "$CONTEXT" -type f \
      \( -name '*.py' -o -name '*.js' -o -name '*.ts' -o -name '*.go' \
         -o -name '*.rs' -o -name '*.java' -o -name '*.rb' \) \
      -not -path '*/node_modules/*' -not -path '*/_build_tools/*' \
      -not -path '*/build_output/*' -not -path '*/openspec/*' 2>/dev/null | head -5 | wc -l)"
  if [ "$CODE_COUNT" -ge 1 ]; then MODE="brownfield"; else MODE="greenfield"; fi
  echo "ℹ PROJECT_MODE খালি → detect করলাম: $MODE  ($CODE_COUNT code file)"
else
  echo "✓ PROJECT_MODE = $MODE  (config থেকে)"
fi

# ── 2. graph + spec status (soft) ────────────────────────────────
GTOOL="$(cfg TOOL)"
if [ -z "$GTOOL" ] || [ "$GTOOL" = "none" ]; then
  echo "ℹ graphify: off — grounding skip হবে (soft)"
else
  echo "✓ graphify: $GTOOL — সব phase grounding টানবে"
fi
SPEC_DIR="$(cfg DIR)"; SPEC_DIR="${SPEC_DIR:-openspec}"
if [ -d "${CONTEXT}/${SPEC_DIR}" ]; then
  echo "✓ spec: ${SPEC_DIR}/ আছে"
else
  echo "ℹ spec: নেই — auto প্রথমে spec phase চালিয়ে বানাবে"
fi

# ── 3. phase sequence ঠিক করি ────────────────────────────────────
# greenfield = scratch থেকে, তাই design phase গুলো লাগে।
# brownfield = code আছে, তাই সরাসরি spec→codegen→audit→report।
if [ "$MODE" = "greenfield" ]; then
  PHASES=(spec user_stories architecture abstract_design codegen research_report security_test report)
else
  PHASES=(spec codegen research_report security_test report)
fi

echo ""
echo "চালানোর ক্রম: ${PHASES[*]}"
echo "────────────────────────────────────────────"

# ── 4. প্রতিটা phase চালাই ────────────────────────────────────────
for ph in "${PHASES[@]}"; do
  echo ""
  echo "▶▶▶ PHASE: $ph"
  # report/security এ system নাম + max লাগে; বাকিতে শুধু context।
  case "$ph" in
    report|security_test) ./build.sh "$ph" "$CONTEXT" "$SYSTEM" "$MAX" ;;
    spec)                 ./build.sh "$ph" "$CONTEXT" "$SYSTEM" 6 ;;
    *)                    ./build.sh "$ph" "$CONTEXT" "$SYSTEM" "$MAX" ;;
  esac
  echo "◀◀◀ PHASE done: $ph"
done

echo ""
echo "════════════════════════════════════════════"
echo " ✅ AUTO BUILD শেষ"
REPORT="${CONTEXT}/build_output/${SYSTEM}_report.html"
[ -f "$REPORT" ] && echo " report: $REPORT ($(wc -l < "$REPORT") lines)"
echo "════════════════════════════════════════════"