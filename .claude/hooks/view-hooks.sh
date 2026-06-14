#!/usr/bin/env bash
# view-hooks — pretty-print the unified hook activity log (.claude/audit/hooks.log).
# Usage:
#   bash .claude/hooks/view-hooks.sh          # show recent activity
#   bash .claude/hooks/view-hooks.sh -n 50    # show last 50 lines
#   bash .claude/hooks/view-hooks.sh -f       # follow live (tail -f)
set -euo pipefail

LOG="${CLAUDE_PROJECT_DIR:-.}/.claude/audit/hooks.log"
lines=20
follow=0

while [ $# -gt 0 ]; do
  case "$1" in
    -n) lines="$2"; shift 2 ;;
    -f) follow=1; shift ;;
    -h|--help) sed -n '2,8p' "$0"; exit 0 ;;
    *) echo "unknown arg: $1" >&2; exit 1 ;;
  esac
done

[ -f "$LOG" ] || { echo "No hook activity yet ($LOG not found)."; exit 0; }

# Colorize the DECISION column (field 3, '|'-delimited). Falls back to plain if no tty.
colorize() {
  if [ -t 1 ]; then
    sed -E \
      -e $'s/\\| (BLOCK) /| \033[31m\\1\033[0m  /' \
      -e $'s/\\| (PASS|OK) /| \033[32m\\1\033[0m   /' \
      -e $'s/\\| (INJECT|AUDIT) /| \033[36m\\1\033[0m /' \
      -e $'s/\\| (SKIP) /| \033[90m\\1\033[0m  /'
  else
    cat
  fi
}

if [ "$follow" -eq 1 ]; then
  tail -n "$lines" -f "$LOG" | colorize
else
  tail -n "$lines" "$LOG" | colorize
fi
