# Data QA Report — Complainers Profile Analysis

**Analyst:** Nimrod Fisher  
**Date:** 2026-04-19  
**Tables checked:** `support_tickets`, `accounts`, `events`, `subscriptions`  
**Analysis window:** All available data (accounts: 2024-06-06 → 2025-06-06; tickets: 2024-12-12 → 2025-06-06; events: 2025-03-07 → 2025-06-06)

---

## Overall Quality Score: **82 / 100** — Proceed with documented caveats

---

## 1. Structural Integrity ✅

| Table | Schema Match | Column Types | Notes |
|---|---|---|---|
| `support_tickets` | ✅ | ✅ | 7 columns, matches schema.yml |
| `accounts` | ✅ | ✅ | 5 columns, all correct types |
| `events` | ✅ | ✅ | 6 columns, bigint PK as expected |
| `subscriptions` | ✅ | ✅ | 7 columns, correct |

---

## 2. Completeness

### `support_tickets` (79 rows)

| Column | Non-null | Null % | Severity |
|---|---|---|---|
| id | 79 | 0% | — |
| org_id | 79 | 0% | — |
| opened_by | 79 | 0% | — |
| status | 79 | 0% | — |
| category | 79 | 0% | — |
| opened_at | 79 | 0% | — |
| closed_at | 40 | **49%** | LOW — expected; nulls = open tickets (39 open, 40 closed) |

### `accounts` (50 rows)

| Column | Non-null | Null % | Severity |
|---|---|---|---|
| id | 50 | 0% | — |
| name | 50 | 0% | — |
| industry | 50 | 0% | — |
| plan | 50 | 0% | — |
| created_at | 50 | 0% | — |

### `events` (1,960 rows)

| Column | Non-null | Null % | Severity |
|---|---|---|---|
| id | 1,960 | 0% | — |
| org_id | 1,960 | 0% | — |
| user_id | 1,960 | 0% | — |
| event_type | 1,960 | 0% | — |
| occurred_at | 1,960 | 0% | — |

**Finding:** All critical columns are 100% complete. `closed_at` nulls are structurally correct (open tickets).

---

## 3. Uniqueness & Duplicates

| Table | Total rows | Unique PK | Duplicate rows |
|---|---|---|---|
| `support_tickets` | 79 | 79 | 0 |
| `accounts` | 50 | 50 | 0 |

**Finding:** No duplicates. Primary keys are clean.

---

## 4. Consistency

- Ticket statuses: `open` (39), `closed` (40) — clean, only 2 values, no invalid states.
- Ticket categories: `feature_request` (22), `bug` (22), `usage_question` (18), `billing` (17) — clean, 4 categories, balanced.
- Account plans: `enterprise` (19), `free` (16), `pro` (15) — clean, 3 tiers, balanced.
- Logical check: open tickets have `closed_at IS NULL` — consistent with status values.

**Finding:** No consistency issues.

---

## 5. Time Coverage

| Table | Earliest | Latest | Coverage |
|---|---|---|---|
| `accounts.created_at` | 2024-06-06 | 2025-06-06 | 12 months |
| `support_tickets.opened_at` | 2024-12-12 | 2025-06-06 | ~6 months |
| `events.occurred_at` | 2025-03-07 | 2025-06-06 | ~4 months |

### ⚠️ MEDIUM — Events window starts later than ticket history

The `events` table only contains data from **2025-03-07 onward**, but support tickets start from **2024-12-12**. This creates a data gap:

- **35 of 79 tickets (44%)** were opened before the events window begins.
- **Impact:** H4 (pre-complaint behavioral signal) can only be tested on the 44 tickets opened from March 2025 onward. Pre-signal analysis should caveat that early-period tickets lack event baselines.
- **Mitigation:** Filter H4 analysis to tickets opened ≥ 2025-03-07; flag in report caveats.

---

## 6. Distribution Sanity

- `accounts.plan`: enterprise/free/pro (19/16/15) — balanced, no dominant value.
- `support_tickets.category`: 4 categories, 17–22 per category — healthy spread.
- `events` across 49/50 accounts (98% coverage) — one account with no events (may have been inactive).

---

## 7. Referential Integrity

| Check | Result |
|---|---|
| `support_tickets.org_id` → `accounts.id` | 0 orphaned rows — 100% match |
| `events.org_id` → `accounts` coverage | 49/50 accounts (98%) have events |
| Complaining accounts | 41/50 accounts (82%) have ≥1 ticket |
| Non-complaining accounts | **9/50 accounts (18%)** have zero tickets |

### ⚠️ MEDIUM — Very few non-complainers for comparison

With only **9 non-complaining accounts**, direct statistical comparison between complainers and non-complainers is severely limited. Specifically:

- H1 (engagement comparison), H2 (plan tier comparison), H3 (tenure comparison), and H0 (null) all rely on meaningful non-complainer samples.
- **Implication:** Binary complainer/non-complainer comparisons should be interpreted with extreme caution. Sub-analysis by *ticket volume* (heavy vs light complainers) provides more analytical power than the binary split.
- **Mitigation for EDA:** Reframe primary analysis as "ticket volume per account" (high vs zero/low) rather than binary complainer/non-complainer. Preserve binary comparison but caveat the n=9 constraint prominently.

---

## Summary of Findings

| # | Table | Finding | Severity | Action |
|---|---|---|---|---|
| 1 | `support_tickets` | `closed_at` 49% null | LOW | Expected (open tickets); note in caveats |
| 2 | `events` | Starts 2025-03-07; 35 tickets predate window | **MEDIUM** | Restrict H4 to tickets ≥ 2025-03-07; caveat |
| 3 | `accounts` / `support_tickets` | Only 9 non-complaining accounts (18%) | **MEDIUM** | Reframe as ticket-volume analysis; caveat binary comparisons |

**No CRITICAL issues found. Analysis may proceed with the above documented mitigations.**

---

## Recommended Mitigations Before EDA

1. **Reframe the primary grouping:** Use ticket count buckets (`0 tickets`, `1–2 tickets`, `3+ tickets`) rather than a binary complainer/non-complainer split. This gives 3 comparable groups and better uses the full dataset.
2. **Restrict H4 to the events window:** Only analyze pre-signal for tickets opened ≥ 2025-03-07 (44 tickets, 56% of the dataset).
3. **Caveat all binary comparisons:** Any complainer vs. non-complainer comparison must note n=9 non-complainers.
