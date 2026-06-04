# EDA Findings — PRO Plan Churn Drivers
**Analysis:** pro-plan-churn-drivers_2026-06-03_nimrod-fisher  
**Date:** 2026-06-03  
**Analyst:** Nimrod Fisher

---

## Critical Structural Finding: Subscription Churn ≠ Account Churn

Before the findings: the data reveals that most "churned" subscriptions belong to accounts that still have active subscriptions. Only **NKing Corp** (eCommerce) has no active subscriptions — a true account churner. The other 4 accounts with canceled subscriptions (KRoberts, PJohnson, OLopez, EFisher) also retain active subscriptions. This means PRO plan "churn" is largely **subscription rationalization** — accounts reducing their subscription portfolio while staying on the platform — not full account loss.

This distinction matters for every finding below and shapes what interventions are appropriate.

---

## Finding 1 — H1 NOT SUPPORTED: Engagement is higher, not lower, before cancellation

**Chart:** `01_eda-event-activity-comparison.svg`

Accounts with recent canceled subscriptions (n=3 in events window: PJohnson=59, KRoberts=51, OLopez=43) averaged **51.0 total events** in the Mar–Jun 2025 window. Retained-only accounts (n=9) averaged **39.3 events**. The "churned" group is 30% more active than the retained group across all five event types (file_upload, report_view, logout, login, api_call) — see chart `05_eda-event-types-per-account.svg`.

This directly challenges H1. Engagement decline is not a precursor to subscription cancellation in this segment. If anything, the accounts rationalizing subscriptions are the platform's more engaged users — they are active enough to be managing multiple subscriptions and are pruning ones they don't need.

**Caveat:** n=3 is too small to generalize. The single true churner (NKing Corp) fell outside the events window and cannot be evaluated for engagement.

---

## Finding 2 — H2 REFRAMED SUPPORTED: Price tier, not billing failure, is the signal

**Chart:** `03_eda-price-tier-distribution.svg`

Every one of the 7 canceled PRO subscriptions was priced at $79 or $199/mo. **Zero cancellations occurred at the $29/mo tier.** The $199/mo tier has a 31% cancel rate (5 canceled out of 16 total: 11 active + 5 canceled); the $79/mo tier has a 29% cancel rate (2/7). By contrast, the $29/mo tier has a 0% cancel rate (9 active, 0 canceled).

The canceled subscription pool is price-skewed: average monthly price of canceled subs = **$164.71** vs **$113.80** for active subs. This is consistent with price sensitivity at the premium tiers rather than any billing execution problem (invoices are 100% paid).

**Implication:** The $199/mo PRO tier carries materially higher churn risk. Accounts at that price point are evaluating whether the product justifies the cost and are dropping individual subscriptions when they don't.

---

## Finding 3 — H4 SUPPORTED: Most cancellations happen within 5 months of subscription start

**Chart:** `02_eda-canceled-subscription-tenure.svg`

5 of 7 canceled subscriptions were canceled within **5 months** of starting (tenures: 0.5, 0.6, 0.8, 2.5, 3.4 months). The first 3 months are the highest-risk window: 3 subscriptions canceled within 1 month. Only 2 cancellations happened after month 5 (4.9 and 11.3 months), both at the $79 tier.

This is the clearest pattern in the data: **the first 3 months are the critical retention window for PRO subscriptions**, particularly at the $199 tier. Accounts that survive past month 6 show almost no cancellation risk.

---

## Finding 4 — H3 NOT SUPPORTED: Low support activity among churned subscriptions

**Chart data:** `06_eda-support-tickets.csv`

NKing Corp (the only true account churner) had 0 support tickets — no escalation, no engagement with support before disappearing. The 4 accounts with mixed canceled+active subscriptions are not distinguishable from retained accounts on support ticket volume (they appear in the 22-ticket retained pool). The pattern from QA (24 total tickets, 11 of 15 pro accounts with tickets) suggests support engagement is normal for the segment, not elevated for churners.

Support escalation does not appear to predict subscription cancellation in this segment. Churned subscriptions went quiet, not loud.

---

## Finding 5 — TEMPORAL: Cancellations accelerated in Apr–May 2025

**Chart:** `04_eda-churn-timeline.svg`

4 of 7 canceled subscriptions occurred in the last 2 months of available data (Apr–May 2025), after a 6-month gap (Sep 2024–Feb 2025 was quiet). The Apr–May cluster involves 3 distinct accounts (OLopez, PJohnson, KRoberts). This could indicate a real acceleration, but with n=7 total over 11 months, a 2-month cluster of 4 is within expected noise for a 15-account cohort.

No platform event or pricing change is known from CLAUDE.md context to explain the Apr–May cluster. Worth flagging for CS investigation.

---

## Open Questions for Deep Analysis

1. **True churner profile (NKing Corp):** This is the only account with no active subscriptions. What was different about its usage pattern vs accounts that kept active subs? Cannot test with current events window (canceled Jul 2024, before events coverage).
2. **Why are higher-price tiers more likely to be canceled?** Is it the price itself (ROI assessment), or is it that higher-price tiers attract a different account type that tests multiple subscriptions and prunes?
3. **Is the Apr–May 2025 cluster meaningful?** Three separate accounts canceling in 2 months after a 6-month gap — random noise or early signal?
4. **Multi-subscription rationalization vs true churn:** Accounts like KRoberts (canceled 2 subs, kept 3 active) look healthy by account. The "churn" signal may be more about subscription-level ROI assessment than platform dissatisfaction.

---

## Charts Index

| # | File | Hypothesis | Finding |
|---|---|---|---|
| 01 | `01_eda-event-activity-comparison.svg` | H1 | Churned accounts MORE active — H1 not supported |
| 02 | `02_eda-canceled-subscription-tenure.svg` | H4 | 5/7 cancels in first 5 months — short tenure is key risk |
| 03 | `03_eda-price-tier-distribution.svg` | H2 | $29 tier: 0 cancels; $199 tier: 31% cancel rate |
| 04 | `04_eda-churn-timeline.svg` | Temporal | 4 of 7 cancels in Apr–May 2025 — recent acceleration |
| 05 | `05_eda-event-types-per-account.svg` | H1 | All event types higher per account for churned group |
