#!/usr/bin/env bash
# SessionStart hook — load-analysis-rules
# Injects the always-on analysis principles into context at session start.
# Demonstrates: rules become real because a hook PUTS them in front of the model every
# session — not because we hope a markdown file gets read. Judgment rules (ground-truth,
# no-guessing) steer reasoning; the cost/safety hooks enforce the non-negotiables.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"

DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/rules"

# Phase-specific rules (sql-conventions) are injected on demand by a PreToolUse hook,
# so they don't sit in context for non-SQL work. Here we load only the always-on ones.
ALWAYS_ON=("ground-truth.md" "no-guessing.md")

body=""
for f in "${ALWAYS_ON[@]}"; do
  if [ -f "$DIR/$f" ]; then
    body+="<<< rule: $f >>>"$'\n'
    body+="$(cat "$DIR/$f")"$'\n'
    body+="<<< end rule: $f >>>"$'\n\n'
  fi
done

# Nothing found → inject nothing.
[ -n "$body" ] || exit 0

printf '## Analysis rules in force (auto-loaded)\n\n'
printf 'These are not optional. Apply them to every step of this analysis.\n\n'
printf '%s' "$body"
hlog load-analysis-rules INJECT "loaded always-on rules: ${ALWAYS_ON[*]}"
exit 0
