#!/usr/bin/env bash
# OpenGeno Stop-hook wrapper.
#
# Reads drift_mode from .feat-tree.json and runs drift-check.sh.
# Behavior:
#   warn  — print summary, exit 0 (session ends normally)
#   block — print summary, exit non-zero so Claude Code blocks the Stop event
#
# In block mode, the user must address drift (or temporarily switch to warn)
# before the session can end.

set -u

# No tree → no-op
[ -d feat-tree ] || exit 0
[ -f .feat-tree.json ] || exit 0

# Locate drift-check.sh. Try, in order:
#   1. CLAUDE_SKILL_DIR (set by Claude Code when this skill is loaded)
#   2. This script's own directory (sibling drift-check.sh)
#   3. CLAUDE_PLUGIN_ROOT (plugin install)
#   4. ~/.claude/skills/geno-init/scripts (manual global install)
#   5. .claude/skills/geno-init/scripts (project-local install)
OWN_DIR=$(cd "$(dirname "$0")" 2>/dev/null && pwd || echo "")
SCRIPT_DIR=""
for D in \
  "${CLAUDE_SKILL_DIR:-}/scripts" \
  "$OWN_DIR" \
  "${CLAUDE_PLUGIN_ROOT:-}/skills/geno-init/scripts" \
  "${CLAUDE_PLUGIN_ROOT:-}/scripts" \
  "$HOME/.claude/skills/geno-init/scripts" \
  ".claude/skills/geno-init/scripts"
do
  if [ -n "$D" ] && [ -f "$D/drift-check.sh" ]; then
    SCRIPT_DIR="$D"
    break
  fi
done

if [ -z "$SCRIPT_DIR" ]; then
  echo "[opengeno] drift-check.sh not found, skipping" >&2
  exit 0
fi

MODE=$(grep -o '"drift_mode"[[:space:]]*:[[:space:]]*"[^"]*"' .feat-tree.json 2>/dev/null \
  | sed 's/.*"drift_mode"[[:space:]]*:[[:space:]]*"\([^"]*\)".*/\1/')
[ -z "$MODE" ] && MODE="warn"

REPORT=$(bash "$SCRIPT_DIR/drift-check.sh" 2>/dev/null)
RC=$?

if [ "$RC" -eq 0 ]; then
  exit 0
fi

# Drift detected — format a summary
echo "[opengeno] drift detected since last_synced_commit:"
echo ""
echo "$REPORT" | head -30 | while IFS= read -r LINE; do
  case "$LINE" in
    DRIFT*)
      DOC=$(echo "$LINE" | awk '{print $2}')
      CODE=$(echo "$LINE" | awk '{print $3}')
      N=$(echo "$LINE" | awk '{print $4}')
      echo "  red:    $DOC"
      echo "          $CODE ($N commits)"
      ;;
    STUB*)
      DOC=$(echo "$LINE" | awk '{print $2}')
      echo "  stub:   $DOC (never synced)"
      ;;
    BROKEN*)
      DOC=$(echo "$LINE" | awk '{print $2}')
      CODE=$(echo "$LINE" | awk '{print $3}')
      echo "  broken: $DOC -> $CODE (file missing)"
      ;;
    STALE_SHA*)
      DOC=$(echo "$LINE" | awk '{print $2}')
      echo "  stale:  $DOC (last_synced_commit not in repo history)"
      ;;
  esac
done

TOTAL=$(echo "$REPORT" | wc -l | tr -d ' ')
SHOWN=$(echo "$REPORT" | head -30 | wc -l | tr -d ' ')
if [ "$TOTAL" -gt "$SHOWN" ]; then
  echo "  ... ($((TOTAL - SHOWN)) more)"
fi

echo ""
echo "Run /geno-sync to reconcile."

if [ "$MODE" = "block" ]; then
  echo ""
  echo "[opengeno] drift_mode=block — session will not end until drift is resolved."
  echo "Set drift_mode to \"warn\" in .feat-tree.json to bypass."
  exit 1
fi

exit 0
