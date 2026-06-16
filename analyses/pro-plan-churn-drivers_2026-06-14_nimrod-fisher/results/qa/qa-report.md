# Data QA Report — Pro Plan Churn Drivers (2025)

- **Analyst:** Nimrod Fisher
- **Date:** 2026-06-14
- **Scope QA'd:** `accounts` (plan='pro'), `subscriptions` (Pro), `products`, `events`, `support_tickets`, `invoices` — exactly the tables H1–H4 require.
- **Overall quality score:** **84 / 100** → proceed with documented caveats.

## Verdict

The **core churn data is pristine** — for the 15 Pro accounts / 34 Pro subscriptions there are zero nulls in key columns, no invalid dates, no orphaned keys, and no duplicate IDs. The analysis can proceed. Three non-blocking findings shape *how* we read the data (price source, engagement testability, support categories), and one structural reality (small n) caps achievable confidence.

## Findings by severity

### HIGH — `products` table is not the price-tier source
- **Check:** `00_qa-product-join`, `00_qa-product-mapping`
- **Evidence:** All 34 Pro subs match a product (0 orphans), but **all 34** have `monthly_price ≠ products.price_monthly`. Catalog prices are only 99 (Products A, C) or 49 (Product B); the actual subscription prices are 29 / 79 / 199. The *same* `product_id` appears at multiple sub prices (e.g., Product C sold at 199, 79 **and** 29).
- **Interpretation:** `products.price_monthly` and `product_id` carry no pricing signal. The authoritative price tier for H1 is **`subscriptions.monthly_price`** only.
- **Action:** Use `subscriptions.monthly_price` for all tier logic. Do **not** join to `products` for price or use product name as a tier proxy. (Persistent — added to `known_issues.md`.)

### MEDIUM — Event coverage excludes most cancellations (H3 risk)
- **Check:** `00_qa-event-coverage`
- **Evidence:** Events span **2025-03-07 → 2025-06-06** (1,960 rows, 49/50 accounts). Of 7 Pro cancels, only **4** fall inside the window; **3** predate it. A *pre-cancel* window (activity before the cancel date) is even thinner inside coverage.
- **Action:** Treat **H3 (engagement)** as largely **inconclusive**; report any engagement comparison only for the in-coverage subset and label it descriptive, not inferential.

### MEDIUM — 17% of Pro support tickets have null category
- **Check:** `00_qa-support-coverage`
- **Evidence:** 24 Pro tickets across 11/15 accounts (2024-12-18 → 2025-05-29). `category` null on 4/24 (17%); `opened_by` null on 4/24 (expected — schema allows system-generated tickets).
- **Action:** For **H4**, report ticket *volume* (robust) and treat category breakdowns as indicative only; exclude/flag null categories.

### LOW — Small population (analytical limitation, not a defect)
- **Evidence:** 7 canceled Pro subs (5 in 2025) vs 25 active. No segment reaches statistical significance.
- **Action:** Full-population descriptive reporting; confidence capped at **Medium** (price/tenure), **Low** (industry/support/engagement). Carry as the report's headline caveat.

## Clean checks (no issue)

| Check | Result |
|---|---|
| `00_qa-pro-population` | plan is lowercase; 50 accounts (19 ent / 16 free / **15 pro**) |
| `00_qa-subscriptions-completeness` | 0 nulls across org_id, product_id, status, started_at, monthly_price; 0 canceled-missing-date; 0 active-with-cancel-date |
| `00_qa-date-logic` | 0 cancel-before-start, 0 future dates; cancels 2024-07-09 → 2025-05-26 |
| `00_qa-referential-integrity` | 0 orphan subs/tickets/invoices; 0 duplicate sub/account IDs |

## Carry-forward caveats into EDA/report

1. Price tier = `subscriptions.monthly_price` (never `products`).
2. H3 engagement is coverage-limited → likely inconclusive.
3. H4 support: use volume; categories indicative only.
4. n=7 cancels → descriptive, confidence-capped.

**Recommendation:** Proceed to EDA.
