# I/O

Read and write tabular data. Always pass explicit dtypes and date columns when the schema is known.

## CSV

```python
df = pd.read_csv(
    path,
    dtype={"user_id": "int64", "plan": "category"},
    parse_dates=["signup_at", "churn_at"],
    na_values=["", "NA", "null"],
    keep_default_na=True,
)
df.to_csv(path, index=False)
```

- `chunksize=100_000` returns an iterator for large files.
- `usecols=[...]` loads a subset — massively faster than `.drop` afterwards.
- `dtype_backend="pyarrow"` for NA-aware, memory-efficient loading.

## Parquet (preferred for intermediates)

```python
df = pd.read_parquet(path, columns=["user_id", "plan", "mrr"])
df.to_parquet(path, index=False, compression="zstd")
```

- Always prefer Parquet over pickle for intermediates.
- Column pruning (`columns=`) and predicate pushdown (`filters=`) are free speedups.

## Excel

```python
df = pd.read_excel(path, sheet_name="raw", dtype_backend="pyarrow")
with pd.ExcelWriter(out, engine="openpyxl") as w:
    df.to_excel(w, sheet_name="clean", index=False)
```

## SQL

```python
from sqlalchemy import create_engine
engine = create_engine(url)
df = pd.read_sql(
    "SELECT user_id, plan, mrr FROM subs WHERE active",
    engine,
    params={...},
    parse_dates=["signup_at"],
    chunksize=50_000,   # iterator for large results
)
```

- Use parameterized queries; never f-string user input into SQL.
- For analytical queries, prefer `read_sql_query` over `read_sql_table`.

## JSON

```python
df = pd.read_json(path, orient="records", lines=True)  # JSON Lines
df.to_json(path, orient="records", lines=True, date_format="iso")
```

## Feather / Arrow IPC

Fast language-interop, not compressed. Use for short-lived handoffs between processes:

```python
df.to_feather(path)
df = pd.read_feather(path, columns=[...])
```

## Schema validation on load

After any `read_*`, verify:

```python
expected = {"user_id": "int64", "plan": "category", "mrr": "float64"}
actual = {c: str(df[c].dtype) for c in expected}
assert actual == expected, (actual, expected)
```

## When not to use pandas

- Files > 10GB — use `polars` or `duckdb` and materialize only the aggregated result into pandas.
- Streaming — pandas is batch-only.
