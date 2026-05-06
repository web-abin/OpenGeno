#!/usr/bin/env bash
# OpenGeno PostToolUse hook.
#
# Reads the file path from the tool input ($CLAUDE_TOOL_INPUT_file_path or
# similar; falls back to scanning recent stdin for a path).
#
# If the touched file is listed in any L3 doc's `code:` block, emit a
# reminder that the corresponding doc may need updating.
#
# Always exits 0 — this is a soft reminder, never blocks. Drift gating
# happens at Stop hook (stop-check.sh).

set -u

[ -d feat-tree ] || exit 0

# Try common Claude Code env vars that expose the touched path
TARGET=""
for v in CLAUDE_TOOL_INPUT_file_path CLAUDE_FILE_PATH CLAUDE_TARGET_FILE; do
  VAL=$(eval "echo \${$v:-}")
  if [ -n "$VAL" ]; then
    TARGET="$VAL"
    break
  fi
done

# If no env var, try to read from stdin (some Claude Code versions pipe JSON)
if [ -z "$TARGET" ] && [ ! -t 0 ]; then
  STDIN_BUF=$(cat 2>/dev/null)
  TARGET=$(echo "$STDIN_BUF" \
    | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' \
    | head -1 \
    | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
fi

[ -z "$TARGET" ] && exit 0

# Don't warn for edits inside the tree itself
case "$TARGET" in
  */feat-tree/*|feat-tree/*) exit 0 ;;
esac

# Find any L3 doc whose code: list contains this path
# Use grep -F for literal match; quick and good enough for soft warning
RELATIVE_TARGET="${TARGET#$(pwd)/}"
MATCHES=$(grep -rl -F "$RELATIVE_TARGET" feat-tree/ 2>/dev/null | grep '\.md$' || true)

if [ -z "$MATCHES" ]; then
  exit 0
fi

# Filter to actual og-feature docs
HITS=""
for DOC in $MATCHES; do
  if head -20 "$DOC" 2>/dev/null | grep -q "^type:[[:space:]]*og-feature"; then
    HITS="$HITS $DOC"
  fi
done

[ -z "$HITS" ] && exit 0

echo "[opengeno] you edited $RELATIVE_TARGET"
echo "[opengeno] this file is referenced by:"
for DOC in $HITS; do
  echo "  - $DOC"
done
echo "[opengeno] if your edit changed user-visible behavior, update the doc and bump last_synced_commit (see CLAUDE.md \"Update after changing\")."

exit 0
