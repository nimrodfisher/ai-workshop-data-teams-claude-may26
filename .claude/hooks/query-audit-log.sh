#!/usr/bin/env bash
# PostToolUse hook — query-audit-log
# Appends every query the agent executed to an immutable JSONL trail.
# Demonstrates: governance/lineage WITHOUT trusting the model. Every query, who, when —
# append-only. This is the line that lands with a CDO: "show me what the agent ran."
set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
ensure_jq || exit 0   # audit is best-effort; never block a tool because logging can't run

LOG_DIR="${CLAUDE_PROJECT_DIR:-.}/.claude/audit"
mkdir -p "$LOG_DIR"
LOG_FILE="$LOG_DIR/query-log.jsonl"

input=$(cat)
sql=$(echo "$input" | jq -r '.tool_input.command // .tool_input.sql // .tool_input.query // empty')
[ -z "$sql" ] && exit 0

# Only log things that actually hit data.
echo "$sql" | grep -Eiq '\b(SELECT|INSERT|UPDATE|DELETE|MERGE|CREATE)\b' || exit 0

jq -c -n \
  --arg ts      "$(date -u +%Y-%m-%dT%H:%M:%SZ)" \
  --arg user    "${USER:-unknown}" \
  --arg session "$(echo "$input" | jq -r '.session_id // "unknown"')" \
  --arg sql     "$sql" \
  '{timestamp:$ts, user:$user, session:$session, query:$sql}' >> "$LOG_FILE"

hlog query-audit-log AUDIT "logged query to query-log.jsonl: ${sql}"
exit 0
