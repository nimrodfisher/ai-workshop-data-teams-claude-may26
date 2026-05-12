# Text Data

String operations via the `.str` accessor. Use `string[pyarrow]` dtype, not `object`.

## Set the right dtype first

```python
df["name"] = df["name"].astype("string[pyarrow]")
df = df.convert_dtypes(dtype_backend="pyarrow")
```

NA-aware, vectorized, ~5x faster than `object` strings on non-trivial data.

## Common `.str` methods

```python
df["name"].str.lower()
df["name"].str.strip()
df["name"].str.replace(" ", "_", regex=False)
df["name"].str.len()
df["name"].str.startswith("Mr")
df["name"].str.contains("foo", case=False, na=False)
df["email"].str.split("@", n=1, expand=True)    # → DataFrame with 2 cols
df["name"].str.cat(df["surname"], sep=" ")
df["name"].str.slice(0, 3)                      # same as df["name"].str[:3]
df["name"].str.zfill(5)
df["name"].str.pad(10, side="right", fillchar=".")
```

Always pass `na=False` to `.contains` / `.startswith` when feeding the result to a boolean mask — otherwise NaN propagates and `.loc` raises.

## Regex extraction

```python
df["domain"] = df["email"].str.extract(r"@([\w.]+)$", expand=False)
df[["user", "domain"]] = df["email"].str.extract(r"^(?P<user>[^@]+)@(?P<domain>.+)$")

df["has_digit"] = df["code"].str.contains(r"\d", regex=True, na=False)
df["digits"] = df["code"].str.findall(r"\d+")   # list per row — consider .explode()
```

Prefer **named groups** (`(?P<name>...)`) when extracting multiple parts.

## Parsing structured strings

```python
df[["year", "month", "day"]] = (
    df["yyyymmdd"]
    .str.extract(r"(\d{4})(\d{2})(\d{2})")
    .astype("Int64")
)
```

For dates, use `pd.to_datetime(..., format=...)` instead — faster and validates.

## Categorical text

Low-cardinality columns (plans, tiers, countries) → `category`:

```python
df["plan"] = df["plan"].astype("category")
df["plan"] = df["plan"].cat.set_categories(["free", "starter", "pro", "enterprise"], ordered=True)
df["plan"].cat.codes                # integer codes
df["plan"] > "starter"              # ordered comparison
```

Memory drops 10-100x; groupby/sort get much faster.

## Indicator / dummy from text

```python
pd.get_dummies(df["plan"], prefix="plan", dtype="int8")
df["tags"].str.get_dummies(sep=",")           # multi-label columns
```

## Matching / searching patterns

```python
df["email"].str.match(r"^[\w.]+@[\w.]+$")      # anchored to start
df["email"].str.fullmatch(r"[\w.]+@[\w.]+")    # anchored both ends
```

Use `match`/`fullmatch` for validation; `contains` for search.

## Performance tips

- `regex=False` when you don't need regex — substantially faster.
- Compile once with `re.compile` and use `.apply` only if the operation isn't on `.str`.
- Avoid `.str.replace` in a loop; chain replacements in one regex with alternation.

## Anti-patterns

- `df["col"].apply(lambda s: s.lower() if isinstance(s, str) else s)` — use `.str.lower()`.
- Storing categorical text as `object`.
- Regex without `re.escape` when the pattern comes from user input.
