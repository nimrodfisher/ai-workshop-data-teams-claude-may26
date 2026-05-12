# GroupBy & Aggregation

Split-apply-combine. `groupby` is pandas' workhorse — use it well.

## Basic aggregation

```python
df.groupby("plan")["mrr"].sum()
df.groupby(["region", "plan"])["mrr"].agg(["sum", "mean", "count"])
```

## Named aggregations (preferred — no multi-level columns)

```python
out = df.groupby("plan").agg(
    total_mrr=("mrr", "sum"),
    mean_mrr=("mrr", "mean"),
    n_users=("user_id", "nunique"),
    churned=("churned_at", lambda s: s.notna().sum()),
).reset_index()
```

## `transform` (broadcast back to original shape)

```python
df["plan_avg"] = df.groupby("plan")["mrr"].transform("mean")
df["z"] = df.groupby("plan")["mrr"].transform(lambda s: (s - s.mean()) / s.std())
df["rank"] = df.groupby("plan")["mrr"].rank(method="dense", ascending=False)
```

Use `transform` when the output must align with original rows (adding a group statistic as a column).

## `filter` (drop whole groups)

```python
big = df.groupby("user_id").filter(lambda g: len(g) >= 10)
```

## `apply` (custom per-group logic)

```python
def top_n(g, n=3):
    return g.nlargest(n, "mrr")

df.groupby("plan", group_keys=False).apply(top_n, n=3, include_groups=False)
```

- `group_keys=False` avoids adding the group key to the index.
- `include_groups=False` (pandas 2.2+) stops the grouping col being passed into the func — removes a FutureWarning.

## Common recipes

### Row with max value per group

```python
idx = df.groupby("user_id")["ts"].idxmax()
latest = df.loc[idx]
```

Faster on large data: sort + drop_duplicates:

```python
latest = df.sort_values("ts").drop_duplicates("user_id", keep="last")
```

### Percentile / quantile per group

```python
df.groupby("plan")["mrr"].quantile([0.5, 0.9, 0.99]).unstack()
```

### Running / cumulative within group

```python
df["cum_mrr"] = df.sort_values("ts").groupby("user_id")["mrr"].cumsum()
df["runs_avg"] = df.groupby("user_id")["mrr"].expanding().mean().reset_index(0, drop=True)
```

### Rolling window per group

```python
df["mrr_7d"] = (
    df.sort_values("ts")
      .groupby("user_id")["mrr"]
      .rolling("7D", on_index=False)
      .mean()
      .reset_index(0, drop=True)
)
```

See `references/time-series.md` for date-aware rolling.

## Multi-column aggregation with different funcs

```python
df.groupby("plan").agg({
    "mrr":     ["sum", "mean"],
    "user_id": "nunique",
    "ts":      ["min", "max"],
})
```

Prefer **named aggregations** when columns will be used downstream — flat column index is easier to join.

## Performance notes

- Pass `observed=True` when grouping on a `category` dtype — otherwise pandas creates rows for every unused category combination.
- `sort=False` inside `groupby()` skips the group-key sort and is faster when order doesn't matter.
- For 10M+ rows with simple aggs, `duckdb` or `polars` is often 10x faster — materialize the aggregate back into pandas.

```python
df.groupby(["region", "plan"], observed=True, sort=False).agg(...)
```

## Anti-patterns

- `df.groupby("x").apply(lambda g: g.sum())` — use `.sum()` directly, it's C-optimized.
- Iterating over groups (`for name, g in df.groupby(...)`) when a vectorized agg/transform exists.
- Forgetting `.reset_index()` before joining the grouped result back.
