# Performance

Pandas can handle 10M+ rows on a laptop if you use the right dtypes and avoid row-wise Python. If you're hitting memory limits, switch to `polars` or `duckdb` — don't fight pandas on data it wasn't built for.

## Measure first

```python
df.info(memory_usage="deep")
df.memory_usage(deep=True).sort_values(ascending=False) / 1e6    # MB per col

%timeit df.groupby("plan")["mrr"].sum()      # in a notebook
```

Profile before optimizing. The slowest step is usually obvious.

## Dtype downcasting — biggest single win

```python
df = df.astype({
    "user_id":   "int32",              # if < 2B
    "count":     "int16",
    "mrr":       "float32",
    "plan":      "category",
    "name":      "string[pyarrow]",
    "active":    "bool",
})
```

| Swap | Memory saved |
|------|--------------|
| `int64` → `int32` | 50% |
| `object` text → `category` (low cardinality) | 90-99% |
| `object` text → `string[pyarrow]` | ~30% + faster ops |
| `float64` → `float32` | 50% (check precision needs) |

Auto-downcast numerics:

```python
for c in df.select_dtypes("integer"):
    df[c] = pd.to_numeric(df[c], downcast="integer")
for c in df.select_dtypes("float"):
    df[c] = pd.to_numeric(df[c], downcast="float")
```

## PyArrow backend

Pass `dtype_backend="pyarrow"` to any `read_*`:

```python
df = pd.read_parquet(path, dtype_backend="pyarrow")
df = pd.read_csv(path, dtype_backend="pyarrow", engine="pyarrow")
```

Benefits: NA-aware dtypes everywhere, lower memory, faster string ops, zero-copy to Parquet.

## Categorical gotcha

```python
df.groupby("plan", observed=True).size()
```

Without `observed=True`, pandas expands all category combinations — often producing millions of empty rows.

## Chunked reads

For files that don't fit in memory:

```python
chunks = pd.read_csv(path, chunksize=200_000, dtype=...)
result = pd.concat([do_work(c) for c in chunks], ignore_index=True)
```

## Avoid copies

- `df.loc[mask, col] = v` modifies in place (under CoW, creates one copy).
- `df = df.assign(...)` creates a new frame — fine for chains, bad in tight loops.
- `inplace=True` is **deprecated as a performance optimization** — it often copies anyway. Prefer chain + reassign.

## Vectorize, don't loop

| Slow | Fast |
|------|------|
| `df.apply(f, axis=1)` | vectorized op on columns |
| `for _, row in df.iterrows(): ...` | `np.where`, `np.select`, `Series.map` |
| `df["out"] = [f(a, b) for a, b in zip(df.a, df.b)]` | `f(df.a, df.b)` if vectorizable |

## When to leave pandas

| Symptom | Tool |
|---------|------|
| >10GB data, simple aggregations | `duckdb` (SQL over Parquet) |
| Multi-core pipelines, lazy eval | `polars` |
| Streaming / incremental | `polars` streaming or DuckDB |
| ML feature engineering at scale | `cudf` (GPU) or `polars` |

Typical pattern: heavy ops in `duckdb`/`polars`, materialize a small result into pandas for charts/reports.

```python
import duckdb
df = duckdb.query("""
    SELECT plan, date_trunc('month', ts) m, SUM(mrr) mrr
    FROM 'events.parquet'
    GROUP BY 1, 2
""").df()
```

## Common footguns

- `pd.concat` in a loop — O(n²). Collect in list, concat once.
- `.copy()` after every slice — unneeded under CoW, adds latency.
- `df["x"] = df["x"].apply(str)` — use `df["x"] = df["x"].astype("string")`.
- Leaving `object` dtype on mixed numeric/string columns — forces Python fallback on every op.
- `df.merge(...)` without `validate=` on large data — silent cartesian blowups.

## Quick wins checklist

- [ ] Loaded with explicit `dtype=` and narrowest types possible
- [ ] All low-cardinality string columns are `category`
- [ ] All free-text columns are `string[pyarrow]`
- [ ] `observed=True` on category groupbys
- [ ] No `apply(axis=1)` in the hot path
- [ ] Intermediates saved as Parquet, not CSV/pickle
- [ ] Shape logged before/after each row-changing op
