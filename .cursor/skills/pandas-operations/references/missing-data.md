# Missing Data

Decide *why* a value is missing before deciding *how* to handle it. Silent `fillna(0)` has buried more insights than any other single pandas call.

## Detection

```python
df.isna().sum()                       # counts per column
df.isna().mean().sort_values()        # % missing per column
df[df["col"].isna()]                  # rows where col is NA
df.loc[df.isna().any(axis=1)]         # rows with any NA
```

## NA-aware dtypes

Prefer these over numpy `NaN` — they distinguish "missing" from "0" or "".

| Old (leaky) | New (NA-aware) |
|-------------|----------------|
| `int64` + NaN-as-float | `Int64` |
| `bool` | `boolean` |
| `object` (text) | `string` or `string[pyarrow]` |

```python
df = df.convert_dtypes()                          # convert whole frame
df["cnt"] = df["cnt"].astype("Int64")             # preserves NA on ints
```

## Filling

Match the strategy to the column's semantics:

```python
df["mrr"] = df["mrr"].fillna(0)                  # only if missing truly means zero
df["plan"] = df["plan"].fillna("unknown")         # explicit sentinel
df["ts"] = df["ts"].ffill()                       # forward fill — time series only
df["score"] = df["score"].fillna(df["score"].median())   # median imputation
df = df.fillna({"a": 0, "b": "x", "c": pd.Timestamp("1970-01-01")})
```

- **Never** `df.fillna(0)` across all columns unless you've confirmed every column's zero is semantically neutral.
- Document every fill decision inline:

```python
df["mrr"] = df["mrr"].fillna(0)  # free-tier users have no MRR row in billing
```

## Dropping

```python
df = df.dropna(subset=["user_id", "ts"])          # required keys only
df = df.dropna(thresh=len(df.columns) - 2)        # drop rows missing >2 cols
```

Always log before/after shape:

```python
before = len(df)
df = df.dropna(subset=["user_id"])
print(f"dropped {before - len(df):,} rows without user_id")
```

## Interpolation (time series only)

```python
df["price"] = df["price"].interpolate(method="time")        # requires DatetimeIndex
df["price"] = df["price"].interpolate(method="linear", limit=3)
```

Never interpolate across customers / groups without a `groupby` first.

## Imputation within groups

```python
df["mrr"] = df.groupby("plan")["mrr"].transform(lambda s: s.fillna(s.median()))
```

## Comparison gotcha

`NaN != NaN`. Use `.isna()`, not `== np.nan`. For equality-aware joins, use NA-aware dtypes so `pd.NA == pd.NA` is `pd.NA` (still falsy, but consistent).
