# Ground truth: schema.yaml and metrics.yaml

Before writing any query, read `schema.yaml` and `metrics.yaml` from the repo.
Treat both as the single source of truth.

- **Columns and tables** come from `schema.yaml` from my connected github repo (MCP). If a column or table isn't there, it doesn't exist for our purposes.
- **Metric logic** comes from `metrics.yaml` from my connected github repo (MCP). When the user asks for "active users", "retention", "MRR" — use the exact definition in the file, not your own reconstruction.
- **Never copy a definition into this rule or into a query comment as if it were canonical.** The YAML is canonical; everything else is a pointer to it. Duplicating the logic creates drift the moment someone edits the file.
- These files are versioned and also consumed by dbt. If they look stale or contradict the warehouse, say so — don't silently reconcile.

The point of this rule is deference, not knowledge. You don't memorize the metrics — you go read them, every time.
