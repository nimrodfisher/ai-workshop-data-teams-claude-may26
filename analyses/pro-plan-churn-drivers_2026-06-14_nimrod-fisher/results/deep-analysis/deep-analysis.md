# Deep Analysis — Pro Plan Churn Drivers (2025)

- **Analyst:** Nimrod Fisher · **Date:** 2026-06-14
- **Population:** 15 Pro accounts, 34 subs (25 active, 7 canceled, 2 trialing). Price tier = `subscriptions.monthly_price` (per QA).
- **Stance on n:** With 7 cancellations, point estimates carry wide intervals. Every headline number below is reported with a 95% interval, and we lead with magnitude/direction, not p-values.

## H1 — Price tier drives churn
- **Method:** Proportion comparison, entry ($29) vs premium ($79+$199), Wilson 95% CIs + Fisher's exact test. Chosen because the outcome is a binary cancel/not at the subscription grain with very small cells (Fisher, not χ²).
- **Effect:** Entry $29 = **0.0%** (0/9), Wilson 95% CI **[0%, 29.9%]**. Premium = **30.4%** (7/23), Wilson 95% CI **[15.6%, 50.9%]**. **Risk difference = 30.4pp.** A relative-risk point estimate is undefined (entry numerator = 0); the floor effect is that the entry tier has zero observed cancellations.
- **Significance:** Fisher's exact two-tailed **p ≈ 0.15** (one-sided ≈ 0.07). The direction is strong and consistent (monotonic across $29→$79→$199 in EDA), but the sample is too small to clear α=0.05.
- **Decomposition:** Within premium, $79 = 28.6% (2/7) and $199 = 31.3% (5/16) — effectively indistinguishable; the real cliff is **$29 (free of churn) vs everything above it.**
- **Temporal pattern:** Cancellations trickle across 5 months (Jul-2024 → May-2025); no spike or event-driven wave.
- **Alternatives ruled out here:** Not a product effect — QA showed `product_id` carries no price signal (same product sold at all three prices), so the tier effect is a *price* effect, not a *product* effect.
- **Evidence:** `08_da-tier-rates.csv`, `08_da-tier-cancel-ci.svg`, `01_eda-cancel-rate-by-tier.svg`.
- **Verdict (for synthesis):** Supported in direction and magnitude; confidence **Medium** (capped by n, not significant).

## H2 — $199 churn concentrates in the first 90 days
- **Method:** First-90-day cancellation hazard for $199 subs — denominator restricted to subs with ≥90 days of observable history before the 2025-06-17 snapshot (avoids survivorship bias from very recent starts). Cohort/hazard framing fits the "since-start" question.
- **Effect:** **30.8%** of eligible $199 subs canceled within 90 days (4/13), Wilson 95% CI **[12.7%, 57.6%]**. Median tenure of canceled $199 subs = **24 days**; 4 of 5 canceled ≤90d.
- **Contrast:** The $79 tier shows the **opposite** pattern — both its cancels are *late* (median 244d, min 148d). So early-life churn is specific to the **$199** tier, not a blanket Pro phenomenon.
- **Temporal pattern:** Early-life failure — the expensive subscriptions that fail, fail fast.
- **Alternatives ruled out here:** Not driven by recent-start censoring (eligibility window enforces 90d observability); not engagement-driven (see H3).
- **Evidence:** `09_da-199-hazard.csv`, `02_eda-tenure.csv`, `02_eda-tenure-by-tier.svg`.
- **Verdict (for synthesis):** Supported for the $199 tier; confidence **Medium**. Defines the at-risk window precisely: a $199 sub in its first quarter.

## H3 — Engagement decline precedes churn
- **Method:** Descriptive comparison of in-coverage event counts (no formal test — n and coverage forbid it; the SQL rank-sum tie bug in `known_issues.md` also makes ad-hoc MWU unsafe).
- **Effect:** Accounts with a cancellation averaged **47 events** (median 43) vs **39** (median 37.5) for non-cancel accounts — canceled accounts were *more* active. Only 4 of 7 cancels fall in the event-coverage window.
- **Verdict (for synthesis):** **Refuted in direction** (no disengagement; if anything, the engagement paradox). Confidence **Low** (coverage-limited, descriptive).

## H4 — Support burden precedes churn
- **Method:** Ticket-volume comparison per account (volume robust; categories excluded per QA's 17% null finding).
- **Effect:** 2.0 vs 1.5 tickets/account (cancel vs non-cancel); open tickets 4 vs 5. No meaningful separation.
- **Verdict (for synthesis):** **Null** — support burden does not distinguish churners. Confidence **Low** (n).

## H0 — No driver / rationalization
- **Method:** Account-level outcome classification — for each account that canceled ≥1 sub, did it retain an active subscription (rationalization) or fully leave (true logo exit)?
- **Result:** Of **5** accounts that canceled, **4 rationalized** (kept an active sub) and **1** truly exited — and that exit was in **2024** (eCommerce). **All 3 accounts that canceled in 2025 retained an active subscription → 0 true logo exits in 2025 (0 of 15 Pro accounts).** Two accounts trimmed two subs each. Notably, **every one of the 5 cancel-accounts dropped a $199 subscription** (and the lone true-exit was also a $199-only account).
- **Verdict (for synthesis):** H0's rationalization clause is **strongly supported** — 2025 Pro "churn" is subscription downsizing, not customer loss. This reframes H1/H2: the price/tenure drivers describe which *subscriptions* get trimmed, not which *customers* leave.
- **Evidence:** `10_da-rationalization-detail.csv`, `03_eda-rationalization.svg`.

## Quantified Summary
- **H1:** Premium cancel rate 30.4% [15.6, 50.9] vs entry 0% [0, 29.9]; RD 30.4pp; Fisher p≈0.15. Direction strong, not significant.
- **H2:** $199 first-90-day hazard 30.8% [12.7, 57.6]; median canceled tenure 24d; $79 cancels late (244d).
- **H3:** Refuted — canceled accounts more active (47 vs 39 events), descriptive only.
- **H4:** Null — 2.0 vs 1.5 tickets/account.
- **H0:** Rationalization confirmed — 4/5 cancel-accounts retained an active sub; 0 true logo exits in 2025; every cancel-account dropped a $199 sub.

## Caveats from This Phase
- n=7 cancellations: no result reaches statistical significance; intervals are wide by construction.
- $79 vs $199 ordering is within noise — the robust H1 statement is "$29 vs everything above."
- H3 rests on 4 of 7 cancels inside the ~90-day event window — treat as indicative only.
- Active-sub tenure measured to the frozen 2025-06-17 snapshot, not `CURRENT_DATE`.
