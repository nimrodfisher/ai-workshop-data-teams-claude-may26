# Selection & Indexing

Pick rows and columns. `.loc` for labels, `.iloc` for positions — never mix.

## Column selection

```python
df["col"]                 # Series
df[["a", "b"]]            # DataFrame
df.loc[:, "a":"c"]        # inclusive label slice
df.select_dtypes(include="number")
```

## Row selection

```python
df.loc[mask]              # boolean
df.loc[mask, "col"] = v   # safe assignment (no chained indexing)
df.iloc[0:10]             # positions
df.iloc[[0, 3, 7]]
```

## Boolean masks (compose, don't chain)

```python
m = (df["plan"] == "pro") & (df["mrr"] > 50) & df["active"]
df.loc[m]
```

- Parenthesize each clause; `&`, `|`, `~` — never `and`, `or`, `not`.
- `df["col"].isin([...])` is faster than repeated `==` with `|`.
- `df["col"].between(lo, hi, inclusive="both")` beats `(col >= lo) & (col <= hi)`.

## `.query()` — readable filters

```python
df.query("plan == 'pro' and mrr > 50 and active")
df.query("col in @my_list")     # @var references Python scope
```

Best for >2 clauses. Skip when column names have spaces or dots.

## MultiIndex

```python
df = df.set_index(["region", "plan"]).sort_index()
df.loc[("EU", "pro")]
df.loc[("EU", slice(None))]            # all plans in EU
df.loc[pd.IndexSlice[:, "pro"], :]     # cross-section on second level
df.xs("pro", level="plan")
```

- **Always sort a MultiIndex after setting it.** Unsorted slicing raises or silently underperforms.

## Conditional assignment

```python
df["segment"] = np.select(
    [df.mrr >= 500, df.mrr >= 50, df.mrr > 0],
    ["enterprise", "pro", "starter"],
    default="free",
)
df["flag"] = np.where(df.active, 1, 0)
```

## Sampling

```python
df.sample(n=1000, random_state=42)
df.sample(frac=0.01, random_state=42)
df.groupby("plan", group_keys=False).sample(n=100, random_state=42)   # stratified
```

## Anti-patterns

- `df[df.col == x]["other"] = 1` — **chained assignment, will fail silently under CoW**.
- `df.ix[...]` — removed in pandas 1.0.
- Integer slicing with `.loc` on a non-sorted index.
- Using `.loc[cond, :]` where `.loc[cond]` is enough (same result, fewer chars).
