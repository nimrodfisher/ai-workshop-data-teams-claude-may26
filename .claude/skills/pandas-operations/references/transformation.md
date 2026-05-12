# Transformation

Derived columns, sorting, dtype management. Vectorize.

## Derived columns

```python
df["ratio"] = df["a"] / df["b"]
df["log_mrr"] = np.log1p(df["mrr"])
df = df.assign(
    ratio=lambda d: d.a / d.b,
    tier=lambda d: np.where(d.mrr > 100, "hi", "lo"),
)
```

`.assign()` is chain-friendly and never mutates in place.

## `apply` vs vectorized

Order of preference:

1. **Vectorized op** (`df.a + df.b`, `np.where`, `np.select`, `.clip`, `.round`).
2. **`Series.map()`** for element-wise dict/function on one column.
3. **`df.apply(func, axis=0)`** on columns — acceptable.
4. **`df.apply(func, axis=1)`** on rows — last resort. Document why.

```python
df["status"] = df["code"].map({1: "ok", 2: "warn", 3: "err"})
df["norm"] = df[num_cols].apply(lambda s: (s - s.mean()) / s.std())
```

## Sorting

```python
df.sort_values(["region", "mrr"], ascending=[True, False], kind="stable")
df.sort_index(level=["region", "plan"])
df.nlargest(10, "mrr")       # faster than sort+head
df.nsmallest(10, "latency")
```

Use `kind="stable"` when sort order matters downstream (group-first-row patterns).

## dtype management

```python
df = df.astype({"user_id": "int64", "plan": "category", "mrr": "float32"})
df["ts"] = pd.to_datetime(df["ts"], utc=True, errors="raise")
df["n"] = pd.to_numeric(df["n"], errors="coerce")   # invalid → NaN
```

- `category` for low-cardinality strings cuts memory 10-100x.
- `string[pyarrow]` for free-text columns.
- `errors="coerce"` is fine during cleaning; log the count of coerced NaN.

## Renaming & reshaping columns

```python
df = df.rename(columns={"old": "new"})
df.columns = df.columns.str.lower().str.replace(" ", "_")
df = df[["id", "name", "mrr"]]   # explicit reorder
```

## Binning

```python
df["mrr_bucket"] = pd.cut(
    df["mrr"],
    bins=[-np.inf, 0, 50, 500, np.inf],
    labels=["free", "starter", "pro", "enterprise"],
)
df["decile"] = pd.qcut(df["mrr"], q=10, labels=False, duplicates="drop")
```

## Deduplication

```python
df = df.drop_duplicates(subset=["user_id"], keep="last")
df = df.sort_values("updated_at").drop_duplicates("user_id", keep="last")
assert df["user_id"].is_unique
```

## Chain-friendly transforms

```python
out = (
    df
    .query("active")
    .assign(log_mrr=lambda d: np.log1p(d.mrr))
    .sort_values("log_mrr", ascending=False)
    .loc[:, ["user_id", "plan", "log_mrr"]]
    .reset_index(drop=True)
)
```

Chaining reads top-to-bottom like a pipeline; prefer over reassigning `df` repeatedly.
