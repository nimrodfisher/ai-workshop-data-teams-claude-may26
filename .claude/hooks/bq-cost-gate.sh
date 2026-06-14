#!/usr/bin/env bash
# PreToolUse hook — bq-cost-gate
# Dry-runs the query and blocks anything that would scan more than the threshold.
# Demonstrates: a hook can RUN something (a real dry-run against the warehouse) — the
# model can only estimate. This is the "the agent tried a 2 TB scan and we caught it" moment.
set -euo pipefail

THRESHOLD_GB=${BQ_SCAN_LIMIT_GB:-50}   # override per-project: export BQ_SCAN_LIMIT_GB=10

source "$(dirname "${BASH_SOURCE[0]}")/_lib.sh"
ensure_jq || exit 0   # fail open on tooling, fail closed on cost (no jq → can't parse → allow)

input=$(cat)
sql=$(echo "$input" | jq -r '.tool_input.command // .tool_input.sql // .tool_input.query // empty')
[ -z "$sql" ] && exit 0

# Only SELECTs reach the warehouse for scanning.
echo "$sql" | grep -Eiq '\bSELECT\b' || { hlog bq-cost-gate SKIP "not a SELECT"; exit 0; }

# If the SQL is wrapped in a bq CLI call, unwrap the inner query.
clean=$(echo "$sql" | sed -E "s/^.*bq query[^']*'//; s/'[^']*$//")

# No bq on this machine → don't block, just allow. Fail open on tooling, fail closed on cost.
command -v bq >/dev/null 2>&1 || { hlog bq-cost-gate SKIP "no bq CLI on host; dry-run skipped"; exit 0; }

bytes=$(bq query --dry-run --use_legacy_sql=false --format=json "$clean" 2>/dev/null \
        | jq -r '.statistics.totalBytesProcessed // empty')

# Dry-run failed (syntax, perms) → let the warehouse return the real error to the agent.
[ -z "$bytes" ] && exit 0

gb=$(awk "BEGIN { printf \"%.2f\", $bytes/1073741824 }")
over=$(awk "BEGIN { print ($gb > $THRESHOLD_GB) ? 1 : 0 }")

if [ "$over" -eq 1 ]; then
  hlog bq-cost-gate BLOCK "scan ${gb} GB > limit ${THRESHOLD_GB} GB"
  echo "BLOCKED by cost-gate: this query would scan ${gb} GB (limit ${THRESHOLD_GB} GB)." >&2
  echo "Add a partition filter (e.g. WHERE _PARTITIONDATE >= ...) or select fewer columns, then retry." >&2
  exit 2
fi

# Within budget — informational note, still allowed (exit 0).
hlog bq-cost-gate OK "scan ~${gb} GB within ${THRESHOLD_GB} GB budget"
echo "cost-gate: ~${gb} GB scan, within the ${THRESHOLD_GB} GB budget." >&2
exit 0
