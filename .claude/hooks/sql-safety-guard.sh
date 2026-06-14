#!/usr/bin/env bash
# PreToolUse hook — sql-safety-guard
# Blocks catastrophic / unbounded SQL before it ever reaches the warehouse.
# Demonstrates: the hook does what a rule CAN'T — it makes the wrong thing impossible,
# and the stderr message goes back to the agent so it corrects itself.
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
# Safety guard fails CLOSED: if we can't parse the SQL, we don't let it through.
ensure_jq || { echo "BLOCKED by sql-safety-guard: jq not found, cannot inspect SQL. Install jq." >&2; exit 2; }

input=$(cat)

# Pull SQL whether it came via Bash (bq/psql/snowsql) or an MCP query tool.
sql=$(echo "$input" | jq -r '.tool_input.command // .tool_input.sql // .tool_input.query // empty')
[ -z "$sql" ] && { hlog sql-safety-guard SKIP "no SQL in tool input"; exit 0; }

# Normalize for matching only (uppercase, single-spaced). Original kept for the message.
norm=$(echo "$sql" | tr '[:lower:]' '[:upper:]' | tr -s '[:space:]' ' ')

block() {
  hlog sql-safety-guard BLOCK "$1"
  echo "BLOCKED by sql-safety-guard: $1" >&2   # stderr on exit 2 is fed back to the agent
  echo "Offending SQL: $sql" >&2
  exit 2
}

# 1. Verbs that are never acceptable from an ad-hoc agent query.
echo "$norm" | grep -Eq '\b(DROP|TRUNCATE)\b' \
  && block "DROP/TRUNCATE are never permitted on this connection. Schema changes go through dbt + PR."

# 2. DELETE/UPDATE with no WHERE = unbounded mutation of the whole table.
if echo "$norm" | grep -Eq '\b(DELETE|UPDATE)\b' && ! echo "$norm" | grep -Eq '\bWHERE\b'; then
  block "DELETE/UPDATE without a WHERE clause. Add a predicate or this stays blocked."
fi

# 3. Any write that names a protected schema. Conservative by design — blocks even
#    'INSERT INTO staging SELECT FROM prod...'. For a workshop, over-blocking writes near prod is the safe default.
echo "$norm" | grep -Eq '\b(INSERT|UPDATE|DELETE|MERGE|CREATE|ALTER)\b.*\b(PROD|PRODUCTION|ANALYTICS_PROD)\.' \
  && block "Writes touching prod schemas must go through dbt + PR, not an agent query."

hlog sql-safety-guard PASS "no dangerous patterns: ${sql}"
exit 0
