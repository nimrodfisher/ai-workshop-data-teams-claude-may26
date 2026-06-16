# EDA Findings — Pro Plan Churn Drivers (2025)

- **Analyst:** Nimrod Fisher · **Date:** 2026-06-14
- **Population:** 15 Pro accounts, 34 Pro subscriptions (25 active, 7 canceled, 2 trialing).
- **Reminder (from QA):** price tier = `subscriptions.monthly_price`; engagement is coverage-limited; n is small — read everything as descriptive.

## Finding 1 — Cancel rate climbs steeply with price tier *(H1)*
Chart: `01_eda-cancel-rate-by-tier.svg` · data: `01_eda-cancel-rate-by-tier.csv`

Cancel rate [canceled / (active+canceled)] is **$29 → 0.0%** (0/9), **$79 → 28.6%** (2/7), **$199 → 31.3%** (5/16). The progression is monotonic and the gap from the bottom tier is categorical, not marginal: the entry tier has **never** lost a subscription, while roughly **1 in 3** of the top tier has canceled. This is the clearest signal in the dataset and directly supports H1. Caveat: tiers are small (7–16 subs), so the *exact* $79 vs $199 ordering is within noise — the robust statement is "$29 never churns; the two paid-up tiers churn at ~30%."

## Finding 2 — $199 cancels are early-life; $79 cancels are late *(H2, with a twist)*
Chart: `02_eda-tenure-by-tier.svg` · data: `02_eda-tenure.csv`

Among canceled subs, the **$199** tier has a median tenure of just **24 days** (avg 47), and **4 of 5** canceled within 90 days of starting. By contrast, **$79** cancels are *late*: median **244 days**. Active subs sit in between (median tenure $29→221d, $79→85d, $199→154d as of the 2025-06-17 snapshot). So H2's "early-life churn" holds **specifically for the $199 tier** — the expensive subscriptions that fail, fail fast — but is not a universal Pro pattern. This sharpens the at-risk profile: a newly-started $199 subscription is the danger zone.

## Finding 3 — Cancellations are a slow trickle, not a spike *(timeline)*
Data: `03_eda-cancel-timeline.csv`

The 7 cancellations spread thinly across 5 distinct months (Jul-2024, Aug-2024, Feb-2025, Apr-2025 ×2, May-2025 ×2). There is no concentration around any single date, no cliff, and no evidence of an event-driven churn wave. 2025 shows a mild uptick (5 of 7 cancels) but at this volume it is indistinguishable from random arrival.

## Finding 4 — Engagement does NOT precede churn — the paradox repeats *(H3, coverage-limited)*
Data: `05_eda-engagement.csv`

Within the event-coverage window (2025-03-07 → 06-06), accounts that canceled a sub averaged **47 events** (median 43) versus **39 events** (median 37.5) for accounts with no cancellation. Canceled accounts were *more* active, not less — echoing the prior complainer/fintech analyses. This **refutes the disengagement direction of H3**. Strong caveat: only 4 of 7 cancels fall in coverage and n is 5 vs 8 accounts, so this is descriptive, not a test.

## Finding 5 — Support burden does not separate churners *(H4)*
Data: `06_eda-support.csv`

Accounts with a cancellation averaged **2.0 tickets** vs **1.5** for those without — a small gap on tiny counts (10 vs 12 tickets total; open 4 vs 5). There is no meaningful support-burden signal distinguishing churners, consistent with prior Pulseboard findings that support tickets are not a reliable churn predictor.

## Finding 6 — "Churn" is overwhelmingly rationalization, not loss *(H0)*
Chart: `03_eda-rationalization.svg` · data: `07_eda-rationalization.csv`

Of the **5** Pro accounts that canceled a subscription, **4 still hold an active subscription** (rationalization) and only **1** fully left — and that single true logo exit was in **2024**. All **3** accounts that canceled in 2025 retained an active subscription. **Logo churn among Pro accounts in 2025 = 0 of 15.** Two accounts canceled two subscriptions each, i.e. trimming multi-sub footprints. This reframes the entire question: 2025 "Pro churn" is customers *downsizing their subscription mix*, not leaving Pulseboard.

## Segmentation note — industry is too thin to read
Data: `04_eda-industry.csv`

Cancels by industry: MarTech 2 (of 3 accounts), FinTech 2 (1 account), SaaS 2 (1 account), eCommerce 1; HealthTech/EdTech/CyberSecurity 0. With 1–3 accounts per industry, no industry signal is reliable — do not draw vertical conclusions.

## Carry into Deep Analysis
1. Quantify H1 cleanly (cancel rate + risk ratio by tier) and H2 (first-90-day hazard for $199).
2. Formalize the rationalization split (account-level true-exit vs downsize) as the headline reframe.
3. Treat H3 (engagement paradox) and H4 (support) as refuted/null, descriptively.
4. Keep every claim flagged with n; no significance tests will survive this sample.
