#!/usr/bin/env bash
# check_citations.sh — verifies "US-N" story references across generated docs
# against the actual definitions in docs/user_stories.md.
#
# Born from a real incident: architecture.md cited US-33/US-38 interchangeably
# for narration reject-on-malformed (only US-33 was correct), and several
# admin-endpoint numbers were off by one — all found by slow manual grep,
# one line at a time, across a single ~800-line file.
#
# What this DOES catch (hard errors — cheap, 100% mechanical):
#   - "US-N" citations in generated docs where N doesn't exist in user_stories.md
#     at all (typos, off-by-one into a number that was never defined).
#
# What this CANNOT catch (needs a human):
#   - "US-30" cited where "US-29" was meant, when BOTH numbers are real,
#     defined stories — the number is valid, just the wrong one for that
#     sentence's meaning. For this, the script prints every citation next to
#     the actual one-line text of the story it points to, side-by-side, so a
#     human reviewer can eyeball a mismatch in seconds instead of minutes.
#
# Usage (from _build_tools/):
#   ./check_citations.sh ../                # scan CONTEXT/docs/*.md
#   ./check_citations.sh ../ docs/architecture.md   # scan one specific file

set -euo pipefail

TOOLKIT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
chmod +x "$TOOLKIT_DIR"/*.sh 2>/dev/null || true

CONTEXT="${1:?Usage: ./check_citations.sh <repo_path> [specific_file]}"
CONTEXT="$(cd "$CONTEXT" && pwd)"
TARGET="${2:-}"

STORIES_FILE="${CONTEXT}/docs/user_stories.md"
if [ ! -f "$STORIES_FILE" ]; then
  echo "❌ No docs/user_stories.md found under ${CONTEXT} — nothing to check against."
  exit 1
fi

# Build the ground-truth map: US-N -> one-line story text.
TMPMAP="$(mktemp)"
trap 'rm -f "$TMPMAP"' EXIT
grep -E '^US-[0-9]+:' "$STORIES_FILE" | sed -E 's/^(US-[0-9]+):\s*/\1\t/' > "$TMPMAP"
DEFINED_COUNT="$(wc -l < "$TMPMAP")"
echo "════════════════════════════════════════════"
echo " CITATION CHECK — ${DEFINED_COUNT} defined stories in docs/user_stories.md"
echo "════════════════════════════════════════════"

# Which files to scan.
if [ -n "$TARGET" ]; then
  FILES="${CONTEXT}/${TARGET}"
else
  FILES="$(find "${CONTEXT}/docs" -name '*.md' ! -name 'user_stories.md' 2>/dev/null)"
fi

if [ -z "$FILES" ]; then
  echo "ℹ no docs to scan (besides user_stories.md itself)."
  exit 0
fi

ERRORS=0
for f in $FILES; do
  [ -f "$f" ] || continue
  REL="${f#$CONTEXT/}"
  echo ""
  echo "── ${REL} ──"

  # Every US-N citation in this file, deduplicated, in order of first appearance.
  CITED="$(grep -oE 'US-[0-9]+' "$f" | sort -u -t- -k2 -n)"
  [ -z "$CITED" ] && { echo "  (no US-N citations)"; continue; }

  for c in $CITED; do
    NUM="${c#US-}"
    TEXT="$(grep -P "^US-${NUM}\t" "$TMPMAP" | cut -f2- || true)"
    if [ -z "$TEXT" ]; then
      echo "  ❌ $c — NOT DEFINED in user_stories.md (typo or out-of-range citation)"
      ERRORS=$((ERRORS + 1))
    else
      # Truncate long story text for readability.
      SHORT="$(echo "$TEXT" | cut -c1-90)"
      echo "  ✓  $c → ${SHORT}..."
    fi
  done
done

echo ""
echo "════════════════════════════════════════════"
if [ "$ERRORS" -gt 0 ]; then
  echo " ❌ ${ERRORS} citation(s) reference undefined US-N numbers — fix before relying on these docs."
  exit 1
else
  echo " ✓ No undefined citations found."
  echo " ⚠ This does NOT confirm every number means what the sentence claims —"
  echo "   review the ✓ lines above: does each story's one-line text actually"
  echo "   match what the citing sentence says it does?"
fi
echo "════════════════════════════════════════════"