# Validation — PRO Plan Churn Drivers
**Analysis:** pro-plan-churn-drivers_2026-06-03_nimrod-fisher
**Date:** 2026-06-03
**Analyst:** Nimrod Fisher
**Phase:** 6 of 7

---

## Overview

This phase stress-tests the two confirmed churn drivers from Synthesis:

1. **Price tier** — cancel rates rise sharply with price ($29: 0%, $79: 28.6%, $199: 31.3%)
2. **Short tenure** — 57% of cancels occur in the first 90 days; median canceled tenure 75 days vs 505 days active

Four sensitivity checks were executed via SQL (Checks 12–15). Four red-team objections were addressed using existing data.

---

## Sensitivity Checks

### Check 1 — Tenure threshold sensitivity (Query 12)

**Question:** Does the "57% in first 90 days" claim hold if we shift the threshold?

**Result:**

| Tenure bucket | Canceled subs | Avg price | Days range |
|---|---|---|---|
| 0–60 days | 3 | $199 | 15–24 |
| 61–90 days | 1 | $199 | 75–75 |
| 91–120 days | 1 | $199 | 101–101 |
| 121–180 days | 1 | $79 | 148–148 |
| 270+ days | 1 | $79 | 339–339 |

**Cumulative thresholds:**
- First 60 days: 3/7 = **43%**
- First 90 days: 4/7 = **57%** (the headline claim)
- First 120 days: 5/7 = **71%**
- First 6 months: 6/7 = **86%**

**Finding is robust:** The 90-day threshold was not cherry-picked. Tightening to 60 days gives 43%, loosening to 120 days gives 71% — the same story holds at every threshold. The early-tenure concentration is real and structurally significant, not an artifact of where we drew the line.

**Unexpected pattern:** All cancels in the 0–120 day window are exclusively from the $199 tier. The two $79 cancels appear only at 148 days and 339 days. This means the early-tenure risk is entirely concentrated in the highest-price segment — a finding that strengthens the interaction between H2 (price tier) and the tenure driver.

**Chart:** `val-tenure-sensitivity-chart.svg`

---

### Check 2 — Price tier robustness: excluding $199 tier (Query 13)

**Question:** The $199 tier has 5 of 7 cancels. Does the price-tier gradient hold at the $29 vs $79 boundary when $199 is excluded entirely?

**Result:**

| Monthly price | Active subs | Canceled subs | Total | Cancel rate |
|---|---|---|---|---|
| $29 | 9 | 0 | 9 | 0.0% |
| $79 | 5 | 2 | 7 | 28.6% |

**Finding survives the exclusion.** The $29 vs $79 gradient (0% vs 28.6%) is not an artifact of $199 dominating the cancel count. Even isolating only the lower two tiers, the zero-cancel $29 tier vs the 28.6% cancel $79 tier is a consistent directional signal. The gradient is not a $199 distortion.

---

### Check 3 — Account-level vs subscription-level (Query 14)

**Question:** Headline cancel rates were computed at subscription level. Does the price-tier pattern persist when aggregated at the account level?

**Result:**

| Price tier (max) | Accounts | Accounts with cancel | % with cancel |
|---|---|---|---|
| $29 | 1 | 0 | 0.0% |
| $79 | 1 | 0 | 0.0% |
| $199 | 11 | 5 | 45.5% |

**Important structural discovery:** At the account level, the PRO segment is almost entirely composed of $199 accounts (11 of 13 accounts). There is only 1 account each at $29 and $79. This means the subscription-level cancel rates for $29 (n=9 subs, all from 1 account) and $79 (n=7 subs, from 1 account) each reflect a single organization's behavior — not a cross-account pattern.

**Implication:** The subscription-level gradient ($29: 0%, $79: 28.6%, $199: 31.3%) is directionally correct but must be caveated: the $29 and $79 data points each represent one account's subscription portfolio, not a distribution of accounts. The $199 finding — 45.5% of accounts have at least one cancel — is the most statistically grounded claim because it rests on 11 accounts.

**This narrows, but does not invalidate, the price-tier finding.** The directional claim stands; the precision of the lower-tier percentages should not be over-stated.

---

### Check 4 — Industry distribution: is "even distribution" meaningful at n=5? (Query 15)

**Question:** EDA/Deep Analysis found no industry concentration. Is this a genuine finding or a small-n artifact?

**Result:**

| Industry | PRO accounts | Accounts with cancel | Cancel rate |
|---|---|---|---|
| SaaS | 1 | 1 | 100.0% |
| FinTech | 2 | 1 | 50.0% |
| MarTech | 4 | 2 | 50.0% |
| eCommerce | 3 | 1 | 33.3% |
| CyberSecurity | 2 | 0 | 0.0% |
| HealthTech | 2 | 0 | 0.0% |
| EdTech | 1 | 0 | 0.0% |

**The "even distribution" finding from Synthesis was too generous.** The data actually shows apparent variation (100% in SaaS, 0% in CyberSecurity/HealthTech/EdTech), but every single percentage is computed on 1–4 accounts. A single account flipping state would dramatically change any of these rates.

**Correct interpretation:** Industry cannot be ruled in OR ruled out as a driver. The data is too sparse to detect an industry signal even if one exists. The original finding should be restated as: "Industry distribution is untestable at this sample size — not as 'industry is not a driver.'"

---

## Red-Team Objections and Responses

### Objection 1 — "n=7 is too small; any pattern could be coincidence"

**Response:** n=7 is not a sample — it is the complete population of PRO plan subscription cancellations in the Pulseboard database. There is no sampling error because there is no sampling. Every canceled PRO subscription is accounted for.

What this means for interpretation: we are not making inferences about a larger population; we are describing what actually happened. The patterns we observe — all $29 subs active, majority of cancels in the first 90 days — are facts about this business, not estimates. The appropriate caution is not "this might be coincidence" but rather "this is the entire history so far; it may not predict future behavior if the customer mix changes."

The risk of over-generalizing from a small history is real. The risk of dismissing factual patterns as coincidence is equally real. Both caveats belong in the executive summary.

---

### Objection 2 — "High-price accounts cancel more simply because they have more subscriptions — more subs = more opportunities to cancel one"

**Response:** This is a legitimate confound worth checking. From DA-08, subscription counts by tier:
- $199 tier: 16 total subscriptions across accounts (11 active + 5 canceled)
- $79 tier: 7 total subscriptions (5 active + 2 canceled)
- $29 tier: 9 total subscriptions (9 active + 0 canceled)

Per-account subscription density (from Check 3): $199 accounts average roughly 16/11 ≈ 1.45 subs per account; $29 has 9 subs from 1 account = 9.0; $79 has 7 subs from 1 account = 7.0.

Critically, **the $29 tier has the highest per-account subscription count (9 subs, 1 account) yet zero cancellations.** If more subscriptions mechanically produced more cancels, the $29 account — with 9 subscriptions — would be the most likely to show a cancel. It shows none. This directly refutes the "more subs = more cancel opportunities" alternative explanation. The zero-cancel result at $29, despite high subscription volume, strengthens the price-as-signal interpretation.

---

### Objection 3 — "The 4 accounts with canceled subs but still active might just be slow churners who will leave eventually"

**Response:** This objection is valid and the data cannot resolve it. We can observe the present state (these 4 accounts retain active subscriptions), but we cannot observe future behavior. Two scenarios are genuinely compatible with the current data:

- **Rationalization scenario:** The canceled subscription was a trial or exploratory product that didn't fit; the remaining active subscriptions reflect genuine ongoing use. These accounts are not churning — they are rightsizing.
- **Slow churn scenario:** These accounts are disengaging incrementally, canceling one subscription at a time, and will eventually fully churn.

The only data point that would distinguish these scenarios is future subscription status, which we do not yet have. The engagement analysis (H1) found no difference in feature usage between these account types, which weakly favors the rationalization scenario — but it is not conclusive.

**Required caveat in deliverables:** The "subscription rationalization vs true churn" distinction is an interpretation, not a measured fact. It should be presented as the most parsimonious explanation of current data, with an explicit note that these accounts require 90-day follow-up monitoring to validate.

---

### Objection 4 — "You reframed H2 mid-analysis — was the new hypothesis chosen because it fit the data?"

**Response:** The reframe sequence is documented and the causality is clear. H2 was originally framed as "payment failures drive churn." In Phase 2 (Data QA), a complete scan of the invoices table returned zero unpaid invoices across all PRO accounts. This empirical null — no payment failures exist — made H2 untestable in its original form before any price-tier analysis was run.

The reframe to "price tier drives cancellation propensity" was triggered by the data quality finding, not by the price-tier result. The price-tier pattern (DA-08) was measured in Phase 4, two phases after the H2 reframe was documented in the QA report. There is no plausible reverse causality: we cannot have observed the price-tier pattern (Phase 4) and then designed a hypothesis (Phase 2) to match it, given the chronological gate structure of the pipeline.

---

## Revisions to Synthesis

The following changes to the Synthesis conclusions are warranted by validation:

| Claim | Synthesis status | Validation verdict |
|---|---|---|
| Price tier drives cancellation ($29: 0%, $79: 28.6%, $199: 31.3%) | Confirmed | **Narrowed:** $199 finding most robust (n=11 accounts). $29 and $79 rates each reflect a single account — treat as directional signals, not estimated rates. |
| 57% of cancels in first 90 days | Confirmed | **Survives intact.** Robust to threshold variation; 43% at 60d, 71% at 120d — same story at every cut. |
| Industry is not a driver | Confirmed (weak) | **Downgraded:** Restate as "industry is untestable at n=1–4 per segment" — not a confirmed null. |
| Subscription rationalization, not churn, for 4 of 5 accounts | Confirmed | **Caveat added:** Slow-churn alternative cannot be ruled out. Requires 90-day monitoring to validate. |
| H1 (engagement decline) refuted | Confirmed | **Survives intact.** Events-table coverage limitation is a standing caveat; no new concerns. |
| H3 (support escalation) refuted | Confirmed | **Survives intact.** Zero escalations found — clean null. |

---

## Validation Summary

**Findings that survived intact:**
- Tenure concentration (57% of cancels in first 90 days) is robust and not threshold-sensitive
- Price tier gradient holds even when $199 tier is excluded ($29: 0% vs $79: 28.6%)
- H1 (engagement) and H3 (support) refutations are clean
- H2 reframe is methodologically sound — no post-hoc selection bias

**Findings narrowed or downgraded:**
- Price-tier cancel rates at $29 and $79 should be treated as directional signals from single accounts, not cross-account estimates; the $199 finding (45.5% of 11 accounts) is the most statistically grounded claim
- Industry "not a driver" should be restated as "untestable at this sample size"

**New caveats added:**
- The rationalization vs slow-churn distinction is an interpretation, not a verified fact; 90-day follow-up monitoring is required
- All 0–120 day cancels are exclusively $199 tier — the tenure and price-tier drivers interact, a finding not surfaced in Synthesis
- The PRO segment is structurally concentrated at $199 (11/13 accounts); $29 and $79 tiers are represented by 1 account each

**Surprising SQL result:**
- Check 3 (account-level) revealed the PRO segment is far less diverse by price tier than the subscription-level view suggested. 11 of 13 PRO accounts are at $199, meaning the entire price-tier story is essentially "$199 accounts cancel; $29/$79 accounts do not" — and there is only 1 account each at those lower tiers. This is a structural insight about the customer mix that strengthens the $199 concern but weakens any inference about $29 and $79 as generalizable findings.
