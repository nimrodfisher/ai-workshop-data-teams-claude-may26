# Deep Analysis — PRO Plan Churn Drivers
**Analysis:** pro-plan-churn-drivers_2026-06-03_nimrod-fisher  
**Date:** 2026-06-03  
**Analyst:** Nimrod Fisher

---

## Framing Note

With n=7 canceled subscriptions across n=5 accounts, no formal significance tests are reported — the population is complete (all PRO cancelations, not a sample), so p-values would be meaningless. Effect sizes are reported as absolute differences on the full population, with sensitivity commentary where relevant. All findings are directional and descriptive, ready for synthesis judgment.

---

## H1 — Engagement Decline Predicts Cancellation

**Method:** Mean/median comparison of events per account between accounts with recent canceled subscriptions (n=3, canceled_at ≥ 2025-04-06, within events window) vs retained-only accounts (n=9).

**Why this method:** Simple group comparison. No formal test given n=3 — report effect direction and magnitude only.

**Effect (from EDA-03, corrected for join inflation):**
- Has-canceled group (n=3): mean = **51.0 events**, range [43–59]
- Retained-only group (n=9): mean = **39.3 events**, range [32–48]
- Direction: churned group +30% MORE active — opposite to H1 prediction
- Effect size: +11.7 events/account difference favoring churned group

**Baseline comparison:** H1 predicts churned < retained. Observed: churned > retained.

**Decomposition:** All 5 event types (file_upload, report_view, logout, login, api_call) are higher per account in the has-canceled group. No single event type drives the difference — the pattern is uniform across all interaction types.

**Temporal pattern:** Cannot assess within-window trend (events window is only 92 days); the 3 testable churned accounts show consistent activity through their cancellation date.

**Alternatives ruled out:** The 3 excluded churned accounts (NKing, EFisher's canceled sub, PJohnson's Feb cancel) fell outside the events window — their exclusion cannot be tested for bias. The NKing Corp (true full churner) is the account most likely to have shown a real engagement drop, but its Jul 2024 cancellation is 8 months before events coverage begins.

**Verdict: H1 REFUTED** for subscription-level cancellation within the events window. Engagement does not decline before PRO subscription cancelation — active accounts cancel subscriptions they no longer see value in, not accounts that have disengaged.

**Cited evidence:** `03_eda-event-activity.csv`, `05_eda-event-types-per-account.svg`

---

## H2 (Reframed) — Price Tier as Cancellation Risk Signal

**Method:** Population-level cancel rate by price tier. Full population (no sampling), so exact proportions are reported without CIs.

**Why this method:** Complete population data by tier — no statistical test needed; the rates ARE the truth for this cohort.

**Effect:**
| Price Tier | Active | Canceled | Cancel Rate |
|---|---|---|---|
| $29/mo | 9 | 0 | **0.0%** |
| $79/mo | 5 | 2 | **28.6%** |
| $199/mo | 11 | 5 | **31.3%** |

- The $29/mo tier has **never generated a cancellation** (9 active, 0 canceled)
- The $79 and $199 tiers cancel at nearly identical rates (~29–31%)
- Avg monthly price: canceled subscriptions = **$164.71** vs active = **$113.80** — a $51/mo premium (45% higher)
- The $199/mo tier accounts for **71% of all cancellations** (5/7) while representing 55% of the at-risk pool (11/20 active+canceled at $79-$199)

**Decomposition:** The price tier effect is not mediated by industry or tenure alone — it is a structural feature of the PRO plan. The $29/mo tier appears to be a "safe" entry price where accounts see clear ROI; $79+ tiers require a higher bar of perceived value.

**Temporal pattern:** All 5 cancellations of $199 subscriptions occurred across the full 11-month window, concentrated in early tenure (see H4). The 2 $79 cancellations occurred later in tenure (4.9 and 11.3 months).

**Alternatives ruled out:** The price concentration is not explainable by industry — cancellations span 4 different industries (MarTech, FinTech, SaaS, eCommerce). It is not explainable by account age — accounts with only $29/mo subscriptions include both new and long-tenured accounts.

**Verdict: H2 SUPPORTED (reframed)** — Price tier is the strongest population-level predictor. No billing failures exist, but the $199 tier generates ~31% subscription cancellation, vs 0% at $29. This is a price-value signal, not a billing execution problem.

**Cited evidence:** `08_da-price-tier-cancel-rates.csv`, `08_da-price-tier-risk.svg`

---

## H3 — Support Ticket Escalation Predicts Cancellation

**Method:** Mean ticket count per account — accounts with at least one canceled subscription (n=5) vs accounts with no canceled subscriptions (n=8). Note: all accounts are in scope (not restricted to events window) since ticket data covers the full history.

**Why this method:** Simple mean comparison on the full account population.

**Effect:**
- Has-canceled-sub (n=5): avg **2.0 tickets**/account, max=4, 1 account with 0 (NKing Corp)
- No-canceled-sub (n=8): avg **1.5 tickets**/account, max=2, 2 accounts with 0

- Difference: +0.5 tickets/account in churn group — small and practically negligible
- Direction: churned accounts have slightly MORE tickets, but effect is tiny (33% more)
- NKing Corp (true full churner): **0 tickets** — went silent before churning, no escalation

**Decomposition:** The higher ticket count in the churn group (2.0 vs 1.5) is driven by the multi-subscription accounts (KRoberts, PJohnson) that have many interactions generally — consistent with their higher event counts. It is not an elevated-distress signal.

**Verdict: H3 REFUTED** — Support ticket volume does not meaningfully separate churned from retained PRO accounts. The only true churner (NKing Corp) had zero tickets. Subscription cancellation in this segment happens without a support escalation precursor — accounts make silent ROI decisions, not noisy complaint-driven ones.

**Cited evidence:** `11_da-support-tickets-by-cancel-status.csv`

---

## H4 — Short Tenure Concentration

**Method:** Median tenure comparison (active vs canceled subscriptions) and tenure bucket breakdown. Full population.

**Why this method:** Median is robust to the one outlier (KRoberts2 at 339 days). Bucket breakdown quantifies the early-warning window.

**Effect:**
| Metric | Active (n=25) | Canceled (n=7) | Gap |
|---|---|---|---|
| Mean tenure | 518 days | 103 days | −415 days |
| Median tenure | 505 days | 75 days | **−430 days (6.7×)** |
| IQR | 432–595 days | 21–125 days | — |
| Min / Max | 374 / 710 days | 15 / 339 days | — |

- **57% of cancellations (4/7) occurred within the first 90 days** of the subscription
- **43% (3/7) occurred within the first 30 days** — all at $199/mo
- The one long-tenure cancellation (339 days, KRoberts2) was at $79/mo — a subscription retained ~11 months before pruning

**Tenure bucket breakdown:**
| Bucket | Canceled | Avg Price |
|---|---|---|
| 0–1 month | 3 | $199 |
| 1–3 months | 1 | $199 |
| 3–6 months | 2 | $139 (one $199, one $79) |
| 6+ months | 1 | $79 |

- The highest-risk window is **months 0–3 at $199/mo** (4 of 7 cancellations, 100% at $199 for the 0-1 month bucket)
- After month 6, only 1 cancellation occurred — and it was at $79

**Alternatives ruled out:** Short tenure is not a proxy for industry — the early-cancel accounts span MarTech, FinTech, SaaS, and eCommerce. It is not driven by a single account — 4 different accounts are represented in the 0-3 month bucket.

**Verdict: H4 STRONGLY SUPPORTED** — Short tenure (especially 0–3 months) at the $199/mo tier is the most precise risk signal. The product appears to fail to demonstrate ROI within the first 90 days for premium-priced PRO subscriptions, leading to cancellation.

**Cited evidence:** `09_da-tenure-distribution.csv`, `10_da-short-tenure-risk.csv`, `09_da-tenure-distribution.svg`

---

## H0 — Null: Churn is Random or Unexplainable

**What H0 looks like:** Cancellations distributed uniformly across price tiers, tenures, industries, and engagement levels. No discernible pattern.

**Assessment:** H0 is rejected for two dimensions:
1. **Price tier** — $29/mo has 0% cancel rate vs 29-31% at higher tiers. Random distribution would predict ~22% cancel rate across all tiers (7/32 non-trialing).
2. **Tenure** — Median canceled tenure = 75 days vs median active tenure = 505 days. A 6.7× gap cannot be attributed to random variation in this complete population.

H0 is not decisively rejected for:
- Industry (only 1 eCommerce true-churner; others span multiple industries)
- Support escalation (2.0 vs 1.5 tickets — too small a difference)
- Engagement (counter-directional: churned accounts are more active)

---

## Quantified Summary

| Hypothesis | Direction | Effect Size | Verdict |
|---|---|---|---|
| H1 — engagement decline | Opposite to prediction | Churned accts +30% more active | **REFUTED** |
| H2 — price tier signal | Supported (reframed) | $29: 0% churn; $199: 31.3% churn; $51/mo avg price gap | **SUPPORTED** |
| H3 — support escalation | Not supported | +0.5 tickets/account difference (negligible) | **REFUTED** |
| H4 — short tenure risk | Strongly supported | Median 75d cancel vs 505d active; 57% cancel in first 90d | **STRONGLY SUPPORTED** |
| H0 — null | Partially rejected | Price and tenure show clear patterns; industry/support do not | **PARTIALLY REJECTED** |

---

## Structural Finding (Not a Hypothesis — Emerged from Data)

**"Churn" is mostly subscription rationalization by active accounts.** Only 1 of 5 accounts with canceled subscriptions has no active subscriptions (NKing Corp). The other 4 continue as active Pulseboard customers. This means the "churn" problem at the subscription level is primarily about accounts discovering that specific premium subscriptions don't deliver ROI — not about platform abandonment. The intervention required is different: not win-back or emergency outreach, but better onboarding and value demonstration within the first 90 days at the $199 tier.

---

## Caveats from This Phase

1. **n=7 canceled subscriptions** — All effect sizes are population-level, not sample-based. No p-values are meaningful or reported.
2. **Events coverage** — H1 assessment covers only 3 of 5 churned accounts (those with canceled_at ≥ 2025-04-06). NKing Corp (the true full churner) cannot be assessed for engagement.
3. **Join inflation in Query 3** — The deep analysis event count query had a multi-subscription join inflation issue. EDA-03 (correct query design) was used instead for H1 numbers.
4. **Price tier and tenure are correlated** — All 0-3 month cancellations are at $199. The two effects (short tenure + high price) are intertwined. Separating them would require a larger sample.
5. **No external context** — The Apr-May 2025 cancellation cluster (4 of 7 cancels) may reflect a platform change, pricing event, or competitor action not in the data. This cannot be ruled in or out.
