# Time Series

Datetime handling, resampling, rolling windows, timezones. Timestamps enter the pipeline as **tz-aware UTC** and stay that way until presentation.

## Parsing

```python
df["ts"] = pd.to_datetime(df["ts"], utc=True, errors="raise")
df["ts"] = pd.to_datetime(df["ts"], format="%Y-%m-%d %H:%M:%S", utc=True)
df["date"] = pd.to_datetime(df["date"]).dt.date          # date-only
```

- `utc=True` is non-negotiable — strings without tz are assumed UTC.
- `format=` is 10-50x faster than inferred parsing on large columns.

## Timezones

```python
df["ts"].dt.tz_localize("UTC")                  # naive → UTC
df["ts"].dt.tz_convert("Europe/Athens")         # UTC → local, only for display
df["ts"].dt.tz_localize(None)                   # strip tz (rarely correct)
```

Convert to local tz only for charts / reports. Analysis stays in UTC.

## Datetime accessor

```python
df["ts"].dt.year
df["ts"].dt.month
df["ts"].dt.day_of_week          # 0=Mon
df["ts"].dt.hour
df["ts"].dt.to_period("M")        # month period
df["ts"].dt.normalize()           # strip time-of-day
df["ts"].dt.floor("H")            # floor to hour
df["ts"].dt.strftime("%Y-%m")
```

## Date arithmetic

```python
df["age_days"] = (pd.Timestamp.utcnow() - df["signup_at"]).dt.days
df["next_due"] = df["signup_at"] + pd.DateOffset(months=1)
df["bucket"] = df["signup_at"] + pd.to_timedelta(df["tenure_days"], unit="D")
```

Use `DateOffset` for calendar-aware shifts (handles month-ends, leap years).

## Resampling (DatetimeIndex required)

```python
s = df.set_index("ts")["mrr"]
s.resample("D").sum()                     # daily sum
s.resample("W-MON").mean()                # weeks starting Monday
s.resample("M").agg(["sum", "mean"])
s.resample("D").sum().fillna(0)           # gap days → 0
```

Common frequency strings: `H`, `D`, `W`, `M`, `Q`, `Y`, `B` (business day), `15min`.

### Resample with grouping

```python
df.set_index("ts").groupby("user_id").resample("D")["mrr"].sum()
```

## Rolling windows

```python
s.rolling("7D").mean()                    # requires DatetimeIndex
s.rolling(window=7, min_periods=3).mean() # positional window
s.rolling("30D").agg(["mean", "std"])
```

- Time-based (`"7D"`) handles gaps correctly.
- Integer window assumes evenly-spaced data.
- `min_periods` prevents leading NaN from hiding real values.

## Expanding windows (cumulative)

```python
s.expanding(min_periods=1).mean()
s.expanding().max()
```

## Period vs Timestamp

- **Timestamp** — a point in time. Most data.
- **Period** — a span (e.g., "2026-04"). Use when aggregating by calendar unit:

```python
df["month"] = df["ts"].dt.to_period("M")
df.groupby("month")["mrr"].sum()
```

## Business dates / holidays

```python
from pandas.tseries.offsets import BDay, BMonthEnd
df["next_biz_day"] = df["ts"] + BDay(1)

from pandas.tseries.holiday import USFederalHolidayCalendar
cal = USFederalHolidayCalendar()
holidays = cal.holidays(start="2026-01-01", end="2026-12-31")
df["is_holiday"] = df["ts"].dt.normalize().isin(holidays)
```

## Cohort pattern

```python
df["cohort"] = df.groupby("user_id")["ts"].transform("min").dt.to_period("M")
df["tenure_m"] = ((df["ts"] - df.groupby("user_id")["ts"].transform("min"))
                  / np.timedelta64(30, "D")).astype(int)
cohort = df.pivot_table(
    index="cohort", columns="tenure_m",
    values="user_id", aggfunc="nunique",
)
```

## Gotchas

- `pd.date_range("2026-01-01", periods=10, freq="D", tz="UTC")` — always pass `tz=` if mixing with tz-aware data.
- DST: `tz_localize` raises on ambiguous/nonexistent times. Pass `ambiguous="NaT"` or `nonexistent="shift_forward"` to be explicit.
- `.resample()` on a non-sorted DatetimeIndex silently produces nonsense — `df.sort_index()` first.
