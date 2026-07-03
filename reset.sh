#!/usr/bin/env bash
# reset.sh — one-command project-state reset for universal_build_tools.
#
# Born from a real incident: after retargeting/deleting a project, stale state
# had to be hunted down file-by-file (.tracker/, openspec/changes/*, and the
# easy-to-miss openspec/project.md which the spec phase only CREATES, never
# overwrites). This script clears all of it in one visible, confirmable step.
#
# Run from the toolkit folder, same as build.sh (Git Bash on Windows):
#   ./reset.sh ../              # standard reset (tracker + spec changes)
#   ./reset.sh ../ --full       # also removes openspec/project.md and
#                               # graphify-out/ so they regenerate fresh
#
# It NEVER touches: your code, PROJECT.config.md, docs/, or anything outside
# CONTEXT and the toolkit's own .tracker/.

set -euo pipefail

TOOLKIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONTEXT="${1:?Usage: ./reset.sh <repo_path> [--full]}"
FULL="${2:-}"

CONTEXT="$(cd "$CONTEXT" && pwd)"
cd "$TOOLKIT_DIR"

SPEC_DIR="$(grep -E '^\s*-\s*DIR:' PROJECT.config.md 2>/dev/null | head -1 | sed -E 's/.*DIR:\s*//' | tr -d ' ')"
SPEC_DIR="${SPEC_DIR:-openspec}"

echo "════════════════════════════════════════════"
echo " RESET — $CONTEXT"
echo "════════════════════════════════════════════"
echo "Will remove:"
echo "  • ${TOOLKIT_DIR}/.tracker/            (phase progress state)"
echo "  • ${CONTEXT}/${SPEC_DIR}/changes/*    (all active spec changes)"
if [ "$FULL" = "--full" ]; then
  echo "  • ${CONTEXT}/${SPEC_DIR}/project.md   (spec constitution — will regenerate on next spec phase)"
  echo "  • ${CONTEXT}/graphify-out/            (knowledge graph — will rebuild on next codegen pass)"
fi
echo ""
read -r -p "Proceed? [y/N] " CONFIRM
[ "$CONFIRM" = "y" ] || [ "$CONFIRM" = "Y" ] || { echo "Aborted — nothing touched."; exit 0; }

rm -rf "${TOOLKIT_DIR}/.tracker"
echo "✓ cleared .tracker/"

if [ -d "${CONTEXT}/${SPEC_DIR}/changes" ]; then
  rm -rf "${CONTEXT}/${SPEC_DIR}/changes"/*
  echo "✓ cleared ${SPEC_DIR}/changes/*"
else
  echo "ℹ no ${SPEC_DIR}/changes/ — skipped"
fi

if [ "$FULL" = "--full" ]; then
  rm -f "${CONTEXT}/${SPEC_DIR}/project.md"
  echo "✓ removed ${SPEC_DIR}/project.md (spec phase will regenerate it)"
  rm -rf "${CONTEXT}/graphify-out"
  echo "✓ removed graphify-out/ (codegen pass will rebuild it)"
else
  # Even in standard mode, warn if project.md contradicts the config —
  # this is the exact staleness that caused a real blocker once.
  SPEC_PROJECT_MD="${CONTEXT}/${SPEC_DIR}/project.md"
  if [ -f "$SPEC_PROJECT_MD" ]; then
    CFG_MODE="$(grep -E '^\s*-\s*PROJECT_MODE:' PROJECT.config.md 2>/dev/null | head -1 | sed -E 's/.*PROJECT_MODE:\s*//; s/<!--.*-->//' | tr -d ' \r')"
    SPEC_MODE="$(grep -iE 'MODE:.*\b(greenfield|brownfield)\b' "$SPEC_PROJECT_MD" | head -1 | grep -oiE 'greenfield|brownfield' | tr '[:upper:]' '[:lower:]')"
    if [ -n "$CFG_MODE" ] && [ -n "$SPEC_MODE" ] && [ "$CFG_MODE" != "$SPEC_MODE" ]; then
      echo ""
      echo "⚠⚠ ${SPEC_DIR}/project.md says MODE=$SPEC_MODE but PROJECT.config.md says $CFG_MODE."
      echo "   It is STALE. Re-run with --full to remove it, or fix it manually before the next build."
    fi
  fi
fi

echo ""
echo "Reset done. Reminders:"
echo "  1. Review PROJECT.config.md — set PROJECT_MODE / CURRENT_PHASE for the fresh start."
echo "  2. If the project was retargeted, grep code+docs for old paths before building."
echo "════════════════════════════════════════════"