# Semantic Model Loader

The semantic model is the single source of truth for table schemas, metric definitions, and query patterns. It lives in GitHub, not in this repo, so it can be maintained independently.

## Why Load it Every Time

- Table schemas evolve; stale assumptions cause wrong queries.
- Metric definitions (MRR, Churn, ARPU, etc.) must be consistent across analyses.
- Pre-built query patterns save time and enforce standards.

## What to Load

**1. Schema** — table definitions, column meanings, relationships.

```
Tool: user-github-get_file_contents
Parameters:
  owner: "nimrodfisher"
  repo: "workshop-queries-repo"
  path: "schema.yml"
```

**2. Metrics** — business metric formulas and definitions.

```
Tool: user-github-get_file_contents
Parameters:
  owner: "nimrodfisher"
  repo: "workshop-queries-repo"
  path: "metrics.yml"
```

## When to Load

- At the start of every analysis, before hypothesis framing.
- Again if the analysis extends to a new domain not covered by the initial load.

## Handling Failures

If either file fails to load:
1. STOP. Do not proceed.
2. Tell the user exactly which file failed and why.
3. Ask: "Proceed without the semantic model (risk: incorrect queries), retry, or abort?"
4. Wait for a decision.

Do not invent schema. Do not guess metric definitions. A wrong metric in a deliverable is worse than no deliverable.

## Using the Model

- When a user asks about "MRR", "churn", "active users", etc. — pull the definition from `metrics.yml` and cite it in `plan.md`.
- When writing a query — use column names and joins exactly as defined in `schema.yml`.
- When a user's question uses a term not in the semantic model — ask them to define it, then optionally propose adding it to the model.
