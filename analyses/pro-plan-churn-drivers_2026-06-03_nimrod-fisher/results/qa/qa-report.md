# Data QA Report — PRO Plan Churn Drivers
**Analysis:** pro-plan-churn-drivers_2026-06-03_nimrod-fisher  
**Date:** 2026-06-03  
**Analyst:** Nimrod Fisher  
**Overall Quality Score: 72 / 100 — Proceed with documented caveats**

---

## Summary

| Severity | Count |
|---|---|
| CRITICAL | 0 |
| HIGH | 3 |
| MEDIUM | 1 |
| LOW | 1 |

No blocking issues. Proceed to EDA with the mitigations and scope adjustments below applied.

---

## Population Overview

| Dimension | Value |
|---|---|
| Total PRO accounts | 15 |
| Active subscriptions | 25 (12 unique accounts) |
| Canceled subscriptions | 7 (5 unique accounts) |
| Trialing subscriptions | 2 (2 unique accounts) |
| Avg monthly price — active | $113.80 |
| Avg monthly price — churned | $164.71 |
| Avg monthly price — trialing | $139.00 |

---

## Findings

### HIGH-1 — Churned PRO sample is extremely small (n=5 accounts)

- **Table:** `accounts`, `subscriptions`
- **Finding:** Only 5 unique PRO accounts have at least one canceled subscription (7 canceled subscription records). This is too small for any statistically robust inference.
- **Impact:** All hypotheses (H1–H4) will yield descriptive, directional findings only. No p-values or effect sizes can be trusted at n=5. Do not report statistical significance.
- **Mitigation:** Frame all findings as "pattern observed in X of 5 churned accounts" rather than rates or significance tests. Caveat prominently in all deliverables. For H1, MWU will not be run due to low power.

---

### HIGH-2 — H2 (billing friction) is untestable as framed — 0 unpaid invoices

- **Table:** `invoices`
- **Finding:** 83 invoices for PRO accounts, 0 unpaid. Invoice payment rate = 100%. The hypothesis framed H2 as "higher unpaid invoice rate in churned accounts" — there is no variation to test.
- **Impact:** H2 as written cannot be confirmed or refuted. The billing signal must be reframed.
- **Mitigation:** Reframe H2 in EDA/Deep Analysis to test whether churned PRO accounts had:
  1. Higher invoice amounts (price sensitivity proxy)
  2. Fewer invoices before cancellation (shorter tenure before churn)
  3. Longer gaps between invoice issuance and payment (time-to-pay proxy, if timestamps allow)
  Note: 1 of 7 canceled subscriptions has no invoice at all (14.3% gap — see LOW-1).

---

### HIGH-3 — H1 events testability: only 4 of 7 churned subscription records are within window

- **Table:** `events`, `subscriptions`
- **Finding:** Events coverage is 2025-03-07 to 2025-06-06. To have a valid 30-day pre-cancellation window, canceled_at must be ≥ 2025-04-06. Of 7 churned subscription records (5 unique accounts), 4 records are testable; 3 were canceled before 2025-04-06 (earliest: 2024-07-09).
- **Impact:** H1 pre-churn engagement analysis is restricted to at most 4 subscription records. Combined with HIGH-1 (n=5 accounts), this further limits the comparison.
- **Mitigation:** For H1, only include accounts where canceled_at is in [2025-04-06, 2025-06-06]. Report results as descriptive patterns. Explicitly flag the 3 excluded records and note they cannot be evaluated for engagement.

---

### MEDIUM-1 — Plan values are lowercase in DB, not title-case as schema docs suggest

- **Table:** `accounts`
- **Finding:** Actual values in `accounts.plan`: `pro`, `free`, `enterprise` (all lowercase). Schema documentation uses title-case examples (`Pro`, `Free`, `Enterprise`). All initial queries with `plan = 'Pro'` returned 0 rows.
- **Impact:** Low — corrected in all queries before any data was analyzed. No data was lost.
- **Mitigation:** All queries in this analysis use `plan = 'pro'`. Document in `known_issues.md` as a schema doc inconsistency.

---

### LOW-1 — 1 canceled PRO subscription has no invoice history (14.3% gap)

- **Table:** `invoices`, `subscriptions`
- **Finding:** 6 of 7 canceled PRO subscriptions have at least one invoice. 1 has no invoice records.
- **Impact:** Minor. Billing analysis on churned accounts has one data point missing.
- **Mitigation:** Note the gap. Include the 6/7 with invoice history; flag 1 missing when computing averages.

---

## Table-Level Quality Summary

| Table | Rows (PRO scope) | Key Nulls | Date Coverage | Status |
|---|---|---|---|---|
| `accounts` | 15 | None | 2024-06-06 to 2025-05-05 | CLEAN |
| `subscriptions` | 34 | 27 null `canceled_at` (expected for active/trialing) | 2024-06-15 to 2025-05-25 | CLEAN |
| `events` | 640 | None checked | 2025-03-07 to 2025-06-06 | CLEAN — window constrained (known issue) |
| `invoices` | 83 | None | 2024-06-06 to 2025-05-30 | CLEAN — 0 unpaid (reframe H2) |
| `support_tickets` | 24 | None | 2024-12-18 to 2025-05-29 | CLEAN |

**Referential integrity:** Perfect — 0 orphaned foreign keys across all tables.

---

## Hypothesis Readiness

| Hypothesis | Testable? | Adjustment Required |
|---|---|---|
| H1 — engagement decline | Partially (n=4 records in window) | Restrict to canceled_at ≥ 2025-04-06; descriptive only |
| H2 — billing friction | No — as originally framed | **Reframe:** test invoice amount and tenure instead of unpaid rate |
| H3 — support escalation | Yes (24 tickets, 11 accounts) | Descriptive pattern only due to small n |
| H4 — industry/tenure concentration | Yes | Full account profile available |
| H0 — null | Yes | Default if no patterns emerge |

---

## Recommended Actions Before EDA

1. **H2 reframe (required):** Rewrite H2 success criteria to test invoice amount and subscription tenure before cancellation, not unpaid rate.
2. **H1 restriction (required):** In all engagement queries, add `s.canceled_at >= '2025-04-06'` filter for churned accounts.
3. **Report framing (required):** All findings stated as "X of 5 churned accounts showed Y" — never as percentages or statistical significance given n=5.
4. **Plan casing:** Use `plan = 'pro'` (lowercase) in all subsequent queries.
