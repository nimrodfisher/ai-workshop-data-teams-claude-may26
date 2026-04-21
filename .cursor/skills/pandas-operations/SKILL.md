---
name: pandas-operations
description: Canonical pandas recipes for every stage of a data analysis — I/O, selection, transformation, missing data, merge/reshape, groupby, time series, text, and performance. Use whenever writing pandas code in the analysis workflow (EDA, Deep Analysis, Data QA). Loads only the reference file matching the operation to keep context lean.
---

# Pandas Operations

Single source of truth for pandas code in this project. SKILL.md is a routing map — read the reference file for the exact operation you need. Do **not** load every reference; load one.

## When to Use

Writing or reviewing pandas code in any analysis phase (`data-qa`, `eda`, `deep-analysis`, `synthesis`). If the operation matches one of the categories below, read that reference before writing code.

## Routing Map

| Goal | Reference to read |
|------|-------------------|
| Load / save CSV, Parquet, Excel, SQL, JSON | `references/io.md` |
| Filter rows, pick columns, `.loc` / `.iloc` / `.query` / MultiIndex | `references/selection.md` |
| Derived columns, `apply` vs vectorized, dtype handling, sorting | `references/transformation.md` |
| Detect / fill / drop NaN, NA-aware dtypes | `references/missing-data.md` |
| `merge` / `join` / `concat` / `merge_asof` / `compare` | `references/merge-reshape.md` |
| `pivot` / `melt` / `stack` / `unstack` / `crosstab` / `get_dummies` | `references/merge-reshape.md` |
| `groupby` + agg / transform / filter / window | `references/groupby-agg.md` |
| Datetime parsing, `resample`, `rolling`, timezone, period | `references/time-series.md` |
| `.str` accessor, regex extraction, categorical text | `references/text-data.md` |
| Big data, dtypes, Arrow backend, chunking, `categorical` | `references/performance.md` |

If the goal spans two categories (e.g., "groupby on a time index"), read both files.

## Global Conventions

These apply to **all** pandas code in this project. They are non-negotiable and override anything a reference file might suggest.

1. **Import canonical.** `import pandas as pd` and `import numpy as np`. No `from pandas import *`.
2. **No chained assignment.** Use `df.loc[mask, col] = value`, never `df[mask][col] = value`. Project runs pandas with Copy-on-Write semantics.
3. **Explicit dtypes on read.** Always pass `dtype=` or `parse_dates=` to `read_csv` / `read_parquet` when the schema is known. Never let pandas infer silently for analysis inputs.
4. **No silent row drops.** Every `dropna`, `merge` (non-outer), and `query` must be preceded by a shape log and followed by an assert or comment on expected rows lost.
5. **Prefer vectorized over `apply`.** `apply(axis=1)` is a last resort. If you reach for it, leave a comment explaining why vectorization failed.
6. **Deterministic column order.** After any reshape/merge, re-select columns explicitly so downstream joins don't break on column-order assumptions.
7. **Timestamps are tz-aware UTC** at the boundary. Convert at load, not mid-pipeline. See `references/time-series.md`.
8. **Save intermediates to the analysis `results/` folder as Parquet**, not pickle. CSV only for hand-off to non-pandas consumers.

## Workflow Pattern

For any analysis step using pandas:

1. **State the operation** in one sentence (e.g., "join orders to customers, keep orders without a match").
2. **Route** to the right reference using the table above.
3. **Read only that reference**, then write code.
4. **Log shape before and after** any operation that can change row count (`print(df.shape)` or structured log).
5. **Assert invariants** that the operation must preserve (e.g., `assert df['order_id'].is_unique`).

## Shape-Logging Snippet

Drop this helper into any notebook or script that mutates DataFrames:

```python
def shape_log(df, label):
    print(f"[{label}] rows={len(df):,} cols={df.shape[1]} "
          f"mem={df.memory_usage(deep=True).sum() / 1e6:.1f}MB")
```

Call it after every non-trivial step. The cost is one line; the debugging value is hours.

## Anti-Patterns (caught in review)

- `df.iterrows()` / `df.itertuples()` inside a hot loop — vectorize or use `numba`/`polars`.
- `.append()` in a loop — collect to a list, `pd.concat` once at the end.
- `df[df.col == x]` followed by assignment — use `df.loc[df.col == x, 'target'] = ...`.
- `pd.merge(a, b)` without explicit `on=` and `how=` — always specify both.
- `df.fillna(0)` without asking whether zero is semantically correct for that column.
- Using `object` dtype for text that should be `string[pyarrow]` or `category`.
- `df.to_csv(index=False)` dropping a meaningful index — reset it explicitly first.

## Escalation

If the operation is not covered by any reference file:

1. Check the pandas user guide: https://pandas.pydata.org/docs/user_guide/index.html
2. Prefer built-in pandas over custom logic. If you end up writing 20+ lines of pandas for one operation, there is almost certainly a one-liner in the docs.
3. If the operation is both common and missing, add a recipe to the matching reference file as part of the PR.

## References

- `references/io.md` — read/write recipes
- `references/selection.md` — indexing, filtering, querying
- `references/transformation.md` — derived columns, sorting, dtypes
- `references/missing-data.md` — NA handling
- `references/merge-reshape.md` — combine and reshape tables
- `references/groupby-agg.md` — split-apply-combine
- `references/time-series.md` — datetime, resample, rolling
- `references/text-data.md` — `.str` and regex
- `references/performance.md` — memory, speed, Arrow
