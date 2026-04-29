# Data QA Report — FinTech Pro Activity Drop

**Date:** 2026-04-28  
**Analyst:** Nimrod Fisher  
**Phase:** 2 — Data QA

---

## Summary

| Check | Result | Severity |
|-------|--------|----------|
| Event coverage window | 2025-03-07 → 2025-06-06 (92 days, 1,960 rows) — matches known issue | INFO |
| Plan casing in DB | `plan` values are **lowercase** (`pro`, not `Pro`) | ⚠️ MEDIUM — filter bug if undetected |
| FinTech Pro account count | **2 accounts** (PJohnson Corp, ZGarcia Corp) | ⚠️ MEDIUM — small n, limit statistical claims |
| Null industry / plan | 0 null industry, 0 null plan across 50 accounts | PASS |
| Null user_id events | 0 null-user events for FinTech Pro segment | PASS |
| Drop confirmed | 37 → 26 events (-29.7%) over matched windows | PASS — drop is real |
| Zero-event tail | Jun 7–17 falls outside both comparison windows (neither window is affected) | PASS — H0 partially mitigated |

**Overall data quality score: PASS with CAVEATS**

---

## Findings by Severity

### ⚠️ MEDIUM — Plan casing bug (mitigated)
- `accounts.plan` stores lowercase values: `pro`, `enterprise`, `free`
- The plan file assumed `'Pro'` (capitalized); corrected to `'pro'` in all queries
- **Action:** All downstream queries use `plan = 'pro'`

### ⚠️ MEDIUM — Tiny segment (n = 2 accounts)
- Only **2** FinTech Pro accounts exist in the full dataset
- **PJohnson Corp:** 60 total events (Mar–Jun); prior 30 = 22, last 30 = 18 (−18.2%), users stable 3 → 3
- **ZGarcia Corp:** 36 total events (Mar–May); prior 30 = 15, last 30 = 8 (−46.7%), users dropped 5 → 4
- Combined: 37 → 26 (−29.7%), confirming the reported drop
- **Impact:** No population-level statistics. All findings are descriptive (account-by-account). H1 concentration test is moot with 2 accounts. Hypotheses H1 and H4 require reframing.

### ℹ️ INFO — Events coverage window (known issue applied)
- Events: 2025-03-07 → 2025-06-06, 92 days, 1,960 rows total
- Analysis windows: prior 30 = Apr 7 – May 6; last 30 = May 7 – Jun 6
- Both windows fall **within** the coverage boundary → no zero-event gap contaminates either window
- ZGarcia's last event is May 27; they had no events in Jun 1–6 (6-day silence at end of last 30) — this is behavioral, not a coverage gap

---

## Analysis Window Confirmed

| Period | Start | End (exclusive) | Events |
|--------|-------|-----------------|--------|
| Prior 30 | 2025-04-07 | 2025-05-07 | 37 |
| Last 30 | 2025-05-07 | 2025-06-07 | 26 |

---

## Downstream Caveats

1. All SQL filters must use `plan = 'pro'` (lowercase).
2. n = 2 accounts — all effects are described per-account, not statistically tested.
3. H1 (Pareto concentration) is not testable with 2 accounts. Reframe as: "which account drives more of the drop?"
4. H4 (platform benchmark) remains testable: compare non-FinTech-pro accounts' period drop.

---

## Artifacts

- `01_qa-event-coverage.csv`
- `02_qa-account-filter.csv`
- `02b_qa-period-comparison.csv`
- `02c_qa-per-account.csv`
