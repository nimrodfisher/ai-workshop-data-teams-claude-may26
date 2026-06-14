#!/usr/bin/env bash
# PreToolUse hook — sql-conventions-context
# Injects the SQL conventions rule the FIRST time SQL is run in a session, then stays quiet.
# Demonstrates: phase-specific steering, delivered by a hook exactly when it's relevant
# (you're about to write SQL) instead of sitting in context the whole session.
# This hook NEVER blocks — enforcement is the safety/cost gates' job. It only adds context.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
ensure_jq || exit 0   # context injection is best-effort; never block on missing jq

RULE="${CLAUDE_PROJECT_DIR:-.}/.claude/rules/sql-conventions.md"
[ -f "$RULE" ] || exit 0

input=$(cat)
sql=$(echo "$input" | jq -r '.tool_input.command // .tool_input.sql // .tool_input.query // empty')
[ -z "$sql" ] && exit 0

# Only inject for things that are actually SQL.
echo "$sql" | grep -Eiq '\b(SELECT|INSERT|UPDATE|DELETE|MERGE|CREATE|WITH)\b' || exit 0

# Inject once per session. Sentinel keyed by session_id so a fresh session re-injects.
session=$(echo "$input" | jq -r '.session_id // "unknown"')
STATE_DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/audit"
mkdir -p "$STATE_DIR"
sentinel="$STATE_DIR/.sql-conventions-injected-$session"
[ -f "$sentinel" ] && { hlog sql-conventions SKIP "already injected this session"; exit 0; }
touch "$sentinel"
hlog sql-conventions INJECT "added sql-conventions.md to context (first SQL of session)"

# Emit the rule as additionalContext (JSON form jq-escapes the markdown safely).
note="The SQL conventions for this project are below. Apply them to every query this session."$'\n\n'"$(cat "$RULE")"
jq -cn --arg ctx "$note" \
  '{hookSpecificOutput:{hookEventName:"PreToolUse", additionalContext:$ctx}}'
exit 0
