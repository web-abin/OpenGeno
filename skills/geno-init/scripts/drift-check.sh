#!/usr/bin/env bash
# OpenGeno drift-check
#
# Walks every L3 feature doc under feat-tree/, compares last_synced_commit
# to git HEAD for each code: path, and prints a structured report.
#
# Exit codes:
#   0 — no drift / no tree
#   1 — drift found (used by Stop hook in block mode)
#
# Output format (one line per drift entry):
#   DRIFT <doc-path> <code-path> <commit-count>
#   STUB <doc-path>
#   BROKEN <doc-path> <missing-code-path>

set -u

# Resolve tree path from .feat-tree.json or default
TREE_PATH="feat-tree"
if [ -f .feat-tree.json ]; then
  # Use grep instead of jq to avoid dependency
  CONFIGURED=$(grep -o '"tree_path"[[:space:]]*:[[:space:]]*"[^"]*"' .feat-tree.json 2>/dev/null \
    | sed 's/.*"tree_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
  [ -n "$CONFIGURED" ] && TREE_PATH="$CONFIGURED"
fi

# No tree → silent success (project may not be initialized yet)
if [ ! -d "$TREE_PATH" ]; then
  exit 0
fi

# Must be in a git repo for diffing to work
if ! git rev-parse --git-dir >/dev/null 2>&1; then
  echo "opengeno-drift: not a git repo, skipping" >&2
  exit 0
fi

DRIFT_FOUND=0

# Find all L3 feature docs (frontmatter has type: og-feature)
while IFS= read -r DOC; do
  # Extract frontmatter (lines between first two --- markers)
  FM=$(awk '/^---$/{c++; next} c==1' "$DOC" 2>/dev/null)

  # Confirm this is a feature doc
  echo "$FM" | grep -q "^type:[[:space:]]*og-feature" || continue

  # Extract last_synced_commit
  LSC=$(echo "$FM" | grep "^last_synced_commit:" | head -1 \
    | sed 's/^last_synced_commit:[[:space:]]*//' \
    | sed 's/^"//;s/"$//' \
    | tr -d "'" \
    | tr -d ' ')

  # Extract code: list (lines under "code:" until next top-level key)
  CODE_PATHS=$(echo "$FM" | awk '
    /^code:[[:space:]]*$/ { in_code=1; next }
    in_code && /^[[:space:]]*-[[:space:]]+/ {
      sub(/^[[:space:]]*-[[:space:]]+/, "")
      sub(/[[:space:]]+$/, "")
      print
      next
    }
    in_code && /^[^[:space:]]/ { in_code=0 }
  ')

  # Stub: no SHA
  if [ -z "$LSC" ]; then
    echo "STUB $DOC"
    DRIFT_FOUND=1
    continue
  fi

  # Verify SHA exists in repo (could be from before history was rewritten)
  if ! git cat-file -e "$LSC^{commit}" 2>/dev/null; then
    echo "STALE_SHA $DOC $LSC"
    DRIFT_FOUND=1
    continue
  fi

  # Per code path, count commits since LSC
  while IFS= read -r CODE_PATH; do
    [ -z "$CODE_PATH" ] && continue

    if [ ! -e "$CODE_PATH" ]; then
      echo "BROKEN $DOC $CODE_PATH"
      DRIFT_FOUND=1
      continue
    fi

    COMMIT_COUNT=$(git log --oneline "$LSC..HEAD" -- "$CODE_PATH" 2>/dev/null | wc -l | tr -d ' ')
    if [ "$COMMIT_COUNT" -gt 0 ]; then
      echo "DRIFT $DOC $CODE_PATH $COMMIT_COUNT"
      DRIFT_FOUND=1
    fi
  done <<EOF
$CODE_PATHS
EOF
done < <(find "$TREE_PATH" -type f -name "*.md" 2>/dev/null)

if [ "$DRIFT_FOUND" -eq 1 ]; then
  exit 1
fi
exit 0
