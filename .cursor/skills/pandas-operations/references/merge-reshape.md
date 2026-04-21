# Merge & Reshape

Combine tables and change their shape.

## Merge / Join

Always specify `on=` and `how=` explicitly.

```python
out = pd.merge(
    orders, customers,
    on="customer_id",
    how="left",
    validate="many_to_one",      # asserts cardinality
    indicator=True,              # adds _merge column: left_only / right_only / both
)
```

### `validate` options (use them)

| Value | Asserts |
|-------|---------|
| `one_to_one` | both key sets unique |
| `one_to_many` | left key unique |
| `many_to_one` | right key unique |
| `many_to_many` | no assertion (default if omitted) |

### `how` cheat sheet

| `how` | Result |
|-------|--------|
| `inner` | keys present in both |
| `left` | all left, matched right |
| `right` | all right, matched left |
| `outer` | union of keys |
| `cross` | cartesian product |

### Post-merge audit

```python
print(out["_merge"].value_counts())
out = out.drop(columns="_merge")
```

## `merge_asof` — nearest-key join (time series)

```python
out = pd.merge_asof(
    trades.sort_values("ts"),
    quotes.sort_values("ts"),
    on="ts",
    by="symbol",
    direction="backward",
    tolerance=pd.Timedelta("5s"),
)
```

## Concat

```python
pd.concat([df1, df2], axis=0, ignore_index=True)    # stack rows
pd.concat([df1, df2], axis=1)                       # stack columns (align on index)
pd.concat({"a": df1, "b": df2}, names=["src"])       # keys → outer index level
```

- Never `df.append()` in a loop — collect in a list, `concat` once.
- Mismatched columns become NaN in missing frames.

## `compare` (diff two frames)

```python
a.compare(b, align_axis=1, keep_shape=False, keep_equal=False)
```

## Reshaping

### Long → wide (`pivot` / `pivot_table`)

```python
wide = df.pivot(index="user_id", columns="metric", values="value")
wide = df.pivot_table(
    index="user_id",
    columns="metric",
    values="value",
    aggfunc="sum",
    fill_value=0,
)
```

Use `pivot_table` when duplicate index/column pairs exist or aggregation is required. Plain `pivot` will raise on duplicates — which is often the *right* behavior.

### Wide → long (`melt`)

```python
long = df.melt(
    id_vars=["user_id", "ts"],
    value_vars=["mrr", "arr", "ltv"],
    var_name="metric",
    value_name="value",
)
```

### `stack` / `unstack` (MultiIndex moves)

```python
df.unstack(level="plan")     # pivot plan → columns
df.stack(level="metric")     # pivot metric → rows
```

### `crosstab` (quick contingency)

```python
pd.crosstab(df.plan, df.churned, normalize="index", margins=True)
```

### `get_dummies` (one-hot)

```python
pd.get_dummies(df, columns=["plan", "region"], drop_first=True, dtype="int8")
```

### `explode` (list → rows)

```python
df.explode("tags", ignore_index=True)
```

## Sanity checks to run after any merge/reshape

```python
assert len(out) == expected_rows, len(out)
assert out["customer_id"].notna().all()
shape_log(out, "post-merge")
```
