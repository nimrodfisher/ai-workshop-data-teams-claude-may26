# Synthesis — Pro Plan Churn Drivers (2025)

- **Analyst:** Nimrod Fisher · **Date:** 2026-06-14
- **Question:** What drives churn (subscription cancellation) among Pro-plan accounts, viewed against the 2025 active Pro base?
- **Method note:** Each hypothesis is judged against the confirm/refute criteria written in `plan.md` *before* the data was seen.

## H1 — Price tier drives churn
- **Pre-registered criterion:** Confirm if cancel rate rises monotonically with tier and $199 ≥ 1.5× the lowest non-zero tier.
- **Evidence:** **Supporting.** Cancel rate is monotonic — $29 **0%**, $79 **28.6%**, $199 **31.3%**. Entry ($29) 0% [0–29.9] vs premium ($79+$199) 30.4% [15.6–50.9], risk difference 30.4pp. The $199-vs-lowest-non-zero ratio criterion is technically *not* met (1.09×, since $79 and $199 are nearly equal), but the stronger, cleaner cut is present: the entry tier never churns and everything above it churns at ~30%.
- **Contradicting / silent:** Fisher exact p≈0.15 — not significant at n=32 subs; $79 vs $199 separation is within noise.
- **Strength:** **Moderate.** Direction robust and economically large; significance unreachable at this n.
- **Answer:** Yes — price is the clearest driver, but the real threshold is **$29 (churn-free) vs any paid-up tier (~30%)**, not a smooth gradient. Confidence Medium.
- **Cited:** `01_eda-cancel-rate-by-tier.svg`, `08_da-tier-cancel-ci.svg`, `08_da-tier-rates.csv`.

## H2 — $199 churn concentrates early in the lifecycle
- **Pre-registered criterion:** Confirm if median canceled-$199 tenure is well below active tenure and clusters in the first ~90 days.
- **Evidence:** **Supporting.** Median canceled-$199 tenure **24 days** vs active-$199 median 154 days; **4 of 5** canceled within 90 days; first-90-day hazard **30.8%** [12.7–57.6]. Criterion met.
- **Contradicting / silent:** The $79 tier shows the *opposite* (cancels late, median 244d) — so this is a $199-specific pattern, not a Pro-wide one.
- **Strength:** **Moderate** (for the $199 tier specifically).
- **Answer:** Yes for $199 — expensive subscriptions that fail, fail fast, almost always inside the first quarter. The at-risk window is precise: a $199 sub in its first 90 days. Confidence Medium.
- **Cited:** `02_eda-tenure-by-tier.svg`, `02_eda-tenure.csv`, `09_da-199-hazard.csv`.

## H3 — Engagement decline precedes churn
- **Pre-registered criterion:** Confirm if canceled accounts show materially lower pre-cancel event intensity; refute if no gap or canceled more active.
- **Evidence:** **Contradicting.** Canceled accounts averaged **47 events** vs **39** for non-cancel accounts — *more* active. The refutation clause ("canceled accounts more active — the engagement paradox") is the observed pattern.
- **Strength:** **Refuted** in direction, but **Inconclusive** as proof — only 4 of 7 cancels fall in the ~90-day event window; descriptive, no test run.
- **Answer:** No evidence that disengagement precedes Pro churn; if anything the reverse. Do not build an engagement-decline early-warning rule on this data. Confidence Low.
- **Cited:** `05_eda-engagement.csv`.

## H4 — Support burden precedes churn
- **Pre-registered criterion:** Confirm if canceled accounts show higher ticket volume or open-rate pre-cancel.
- **Evidence:** **Contradicting/Silent.** 2.0 vs 1.5 tickets/account; open 4 vs 5 — no meaningful separation on tiny counts.
- **Strength:** **Inconclusive / Null.**
- **Answer:** Support burden does not distinguish Pro churners — consistent with prior Pulseboard complainer analyses. Confidence Low.
- **Cited:** `06_eda-support.csv`.

## H0 — No driver / rationalization
- **Pre-registered criterion:** Most "churn" is accounts dropping one subscription while staying active.
- **Evidence:** **Strongly supporting.** Of 5 accounts that canceled, **4 rationalized** (kept an active sub), **1** truly exited — in **2024**. **All 3 accounts that canceled in 2025 retained an active subscription → 0 true logo exits among 15 Pro accounts in 2025.** Every cancel-account dropped a **$199** sub.
- **Strength:** **Strong** (full-population, account-level, unambiguous).
- **Answer:** Confirmed. 2025 Pro "churn" is subscription downsizing, not customer loss.
- **Cited:** `03_eda-rationalization.svg`, `10_da-rationalization-detail.csv`.

## Validation Update (added 2026-06-16 after Phase 6)
- **Churn is definition-sensitive** — logo 7.7% (1/13) / sub-level 21.9% (7/32) / account-any-cancel 38.5% (5/13) / premium-tier-sub 30.4% (7/23). Every rate in the report must name its definition. Magnitudes change; drivers do not.
- **Cohort confound tested and rejected** — $199 (median age 156d) and $79 (162d) are the same cohort age yet churn early vs late; the $199 early-cancel is price/value-specific, not a recency artifact.
- **H1 replicated at account grain** — $199-holding accounts cancel 45.5% (5/11) vs 0% (0/2).
- **Data oddity** — 2 of 15 Pro accounts have no subscription at all (account denom = 13).
- **No strength ratings changed.** All verdicts below survived validation.

## Overall Conclusion
The drivers of Pro **subscription cancellation** are **price tier** (the $29 entry tier never churns; paid-up tiers churn ~30%) and **early-life tenure on the $199 tier** (median 24 days to cancel; ~31% first-90-day hazard). But the more important finding sits above the hypotheses: in 2025 this churn is **rationalization, not loss** — 4 of 5 cancelling accounts kept an active subscription and there were **zero true logo exits**. Engagement and support show no predictive signal. So the price/tenure "drivers" explain *which subscriptions get trimmed*, not *which customers leave*.

## What We Know vs What We Believe
- **Know (from data):**
  - $29 tier: 0/9 cancellations; premium tiers: 7/23 (30.4%).
  - Canceled-$199 median tenure 24d; 4/5 within 90d; 90-day hazard 30.8%.
  - 4/5 cancel-accounts retained an active sub; 0 true logo exits in 2025; every cancel-account dropped a $199 sub.
  - Canceled accounts were *more* active (47 vs 39 events) within event coverage.
- **Believe (interpretation):**
  - The pattern looks like **value perception at the top price point**: customers buy a $199 sub, don't realize the value in the first quarter, and trim it while keeping cheaper subs — a packaging/onboarding problem, not an engagement or support failure.
  - The $29 tier's zero-churn likely reflects low-stakes pricing (easy to keep), not superior product fit.

## Open Questions
- **Causality of the $199 early-cancel:** needs onboarding-funnel or seat-activation data not in scope here.
- **Is 0 true-exit durable or a censoring artifact?** A longer post-2025-06-17 window would confirm whether rationalized accounts later fully churn.
- **Why $79 cancels late:** different (possibly contract-cycle) mechanism — unexplored.
- **Significance:** the whole question is n-limited; a definitive test needs more Pro cancellations than exist.

## Reframes
- **Surfaced reframe (recommend noting as the report's lead, not a re-scope):** The question "what drives Pro churn?" is best answered as "**what drives Pro $199-subscription downsizing in the first 90 days?**" — because true logo churn in 2025 is zero. This doesn't require returning to hypothesis-framer; it sharpens H1/H2 with the H0 rationalization finding. Flag for user confirmation at checkpoint.
