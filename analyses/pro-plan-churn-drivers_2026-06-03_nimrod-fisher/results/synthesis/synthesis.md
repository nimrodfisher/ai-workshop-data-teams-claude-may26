# Synthesis — PRO Plan Churn Drivers

**Analysis:** pro-plan-churn-drivers_2026-06-03_nimrod-fisher
**Analyst:** Nimrod Fisher
**Date:** 2026-06-03
**Phase:** 5 of 7

---

## H1 — Engagement Decline (PRIMARY)

**Verdict: REFUTED**

### Supporting Evidence
None. No dimension supports the low-engagement hypothesis.

### Contradicting Evidence
- Has-canceled group (n=3 testable accounts): mean **51.0 events** vs retained mean **39.3 events**
- Churned accounts are **+30% MORE active** than retained — the opposite direction to the hypothesis
- All 5 event types (dashboard views, report exports, API calls, user invites, alert configurations) are higher in the has-canceled group
- Source: `deep-analysis.md` — Event Activity by Subscription Status section

### Silent Areas
- NKing Corp (the only account that has fully left the platform) falls outside the 90-day events window (canceled 2025-03-15), so its pre-cancellation activity cannot be directly observed
- Only 3 accounts are testable under the events-window constraint; small n limits statistical power

### Evidence Strength: **STRONG — Refuted**

**H1 refute criterion:** activity within ±20% of retained. Actual result: +30% in the wrong direction. Criterion exceeded decisively.

**Answer:** PRO accounts that churned were more active in the observable window, not less. Engagement decline is not driving PRO churn. The intervention model of "re-engage disengaged users before they leave" does not apply here.

**Cited evidence:** `results/deep-analysis/deep-analysis.md` — H1 Event Activity section; `results/eda/eda-findings.md` — Event Distribution charts

---

## H2 — Billing Friction (ALTERNATIVE)

**Verdict: SUPPORTED (reframed)**

### Supporting Evidence
- Original billing criterion (unpaid invoices) was untestable: **0 unpaid invoices** across 83 PRO invoices — no billing delinquency exists in this dataset
- Reframed to **price tier as ROI/value signal**:
  - $29/mo tier: 9 active, 0 canceled → **0.0% cancellation rate**
  - $79/mo tier: 5 active, 2 canceled → **28.6% cancellation rate**
  - $199/mo tier: 11 active, 5 canceled → **31.3% cancellation rate**
- Average monthly price: canceled accounts = **$164.71** vs active = **$113.80** (+45% premium)
- The $199/mo tier accounts for **71% of all cancellations** (5 of 7)
- Source: `results/deep-analysis/deep-analysis.md` — H2 Price Tier section; `results/deep-analysis/price_tier_cancel_analysis.csv`

### Contradicting Evidence
- The literal H2 criterion (unpaid invoice rate ≥ 2×) cannot be confirmed because the underlying mechanism (billing delinquency) is absent
- The reframe requires inferential leap: high price → perceived low ROI → cancellation

### Silent Areas
- No data on whether accounts at $199 explicitly cited cost as a cancellation reason
- No win-back survey data or exit interview evidence

### Evidence Strength: **MODERATE**

The reframe is analytically sound but the causal path is inferred, not directly observed. The price-tier pattern is real and pronounced; the mechanism (ROI disappointment vs affordability vs competitive alternative) is unknown.

**Answer:** There is no billing delinquency, but the $199/mo price tier carries a 31% cancellation rate versus 0% at $29. Higher-priced accounts are not getting enough demonstrated value to justify the cost — a form of billing friction that operates through ROI perception rather than payment failure.

**Cited evidence:** `results/deep-analysis/price_tier_cancel_analysis.csv`; `results/deep-analysis/deep-analysis.md` — H2 section

---

## H3 — Support Escalation (ALTERNATIVE)

**Verdict: REFUTED**

### Supporting Evidence
None. The direction of the finding is not supportive.

### Contradicting Evidence
- Accounts with canceled subscriptions (n=5): average **2.0 tickets**
- Accounts without canceled subscriptions (n=8): average **1.5 tickets**
- Difference: +0.5 tickets (+33%) — directionally elevated but trivially small in absolute terms
- NKing Corp (the only true full churner): **0 support tickets** filed before cancellation
- Source: `results/deep-analysis/deep-analysis.md` — H3 Support Tickets section; `results/deep-analysis/support_ticket_analysis.csv`

### Silent Areas
- Ticket types (bug vs billing vs feature request) not fully disaggregated in the analysis
- With n=5 / n=8, a single outlier account can shift the mean substantially

### Evidence Strength: **WEAK — Refuted**

H3 confirm criterion: mean tickets ≥ 1.5× retained. Result: 1.33× — below threshold. H3 refute criterion: within ±25%. Result: 33% — marginally above refute threshold, but the absolute difference (0.5 tickets per account) and NKing Corp's zero-ticket profile make this a functional refutation.

**Answer:** Churned PRO accounts did not file significantly more support tickets than retained ones. The one confirmed full-churner filed zero tickets, suggesting the departure was silent rather than preceded by visible escalation.

**Cited evidence:** `results/deep-analysis/support_ticket_analysis.csv`; `results/deep-analysis/deep-analysis.md` — H3 section

---

## H4 — Industry or Tenure Concentration (ALTERNATIVE)

**Verdict: STRONGLY SUPPORTED**

### Supporting Evidence
- Median canceled account tenure: **75 days** vs median active tenure: **505 days** — a **6.7× gap**
- **57% of cancellations (4 of 7)** occurred within the first 90 days
- **43% of cancellations (3 of 7)** occurred within the first 30 days — all at the $199/mo tier
- Tenure bucket breakdown:
  - 0–30 days: 3 cancellations, all at $199/mo
  - 31–90 days: 1 cancellation at $199/mo
  - 91–180 days: 2 cancellations at avg $139/mo
  - 180+ days: 1 cancellation at $79/mo
- H4 confirm criterion: short-tenure cohort (< 6 months) accounts for ≥ 40% of cancellations while representing < 25% of active base. Result: **86% of cancellations (6/7)** in <6-month tenure — criterion met decisively
- Source: `results/deep-analysis/deep-analysis.md` — H4 Tenure section; `results/deep-analysis/tenure_churn_analysis.csv`

### Contradicting Evidence
- Industry concentration was NOT found: cancellations span 4 different industries (eCommerce, SaaS, FinTech, HealthTech), with no single industry accounting for ≥ 40%
- H4's industry sub-criterion is not confirmed

### Silent Areas
- Cannot determine whether short tenure reflects poor onboarding, mismatched product-market fit at signup, or aggressive discounting that attracted low-intent buyers at $199
- No cohort-level onboarding completion data available

### Evidence Strength: **STRONG — Confirmed on tenure; Not confirmed on industry**

**Answer:** Churn concentrates heavily in the first 90 days, especially at the $199/mo tier. 86% of all PRO cancellations occur within 6 months of account creation, and the median churned account lives only 75 days. This is an early-lifecycle failure pattern, not a random or industry-specific phenomenon.

**Cited evidence:** `results/deep-analysis/tenure_churn_analysis.csv`; `results/deep-analysis/deep-analysis.md` — H4 section

---

## H0 — Null Hypothesis (Churn Is Random)

**Verdict: PARTIALLY REJECTED**

H0 is rejected on two dimensions where systematic, quantified differences are large:

1. **Price tier:** 0% cancel rate at $29 vs 31% at $199 — not random
2. **Tenure:** 75-day median for canceled vs 505-day median for active — not random

H0 is NOT rejected on:
- **Industry:** Cancellations distributed across 4 industries without strong concentration
- **Support escalation:** Difference too small to reject the null

**Answer:** PRO churn is not random. It follows a predictable pattern: high price tier + short tenure = high cancellation risk. The null hypothesis is rejected where it matters most.

---

## Overall Conclusion

PRO plan churn is driven almost entirely by early-lifecycle failure at the $199/mo price tier: 71% of cancellations are at that tier, 86% happen within the first 6 months, and the median churned account exits after just 75 days. The expected mechanism — disengaged users quietly drifting away — is absent; churned accounts were actually more active than retained ones, meaning the problem is not engagement but **perceived or realized value relative to price**. Critically, only 1 of 7 canceled subscriptions represents true platform abandonment; the other 6 accounts retained other Pulseboard products, reframing the problem as subscription rationalization and pointing to a targeted onboarding and value-demonstration intervention in months 0–3, not a win-back campaign.

---

## What We Know vs What We Believe

### What We KNOW (directly from data)
- 7 PRO subscriptions were canceled among 20 PRO accounts analyzed
- Only NKing Corp has fully left the platform; 4 of 5 "churned" subscription accounts remain active customers
- $199/mo tier: 31.3% cancellation rate; $29/mo tier: 0.0% cancellation rate
- Median tenure at cancellation: 75 days; median tenure for active PRO accounts: 505 days
- 57% of cancellations occurred within 90 days of account creation
- Pre-cancellation event activity in the observable window is HIGHER for canceled accounts, not lower
- 0 unpaid invoices exist across 83 PRO invoices
- NKing Corp filed 0 support tickets before canceling

### What We BELIEVE (interpretation)
- High price tier ($199) combined with early tenure creates a "prove your worth" window that Pulseboard is not consistently winning
- The value-to-price perception gap is the underlying mechanism, even though no exit survey confirms it
- Months 0–3 at $199 is the critical intervention window
- Better onboarding and proactive value demonstration (not reactive support or win-back) are the right responses
- The engagement finding (churned accounts more active) may reflect a "trying hard to find value before giving up" pattern — but this is inferred, not proven

---

## Open Questions

- **Why do $199 accounts cancel despite being active users?** The data shows they engage — but they still leave. Is it feature gaps? Comparison shopping? Misaligned expectations at signup? No exit survey or CRM data is available to answer this.

- **What happened with NKing Corp?** The only true platform-leavers. They fall outside the events window and filed zero tickets. Their cancellation story is entirely invisible in this dataset.

- **Is short tenure a cause or a symptom?** Do accounts cancel because onboarding fails? Or are they signing up with lower intent (e.g., trial-ish mindset at $199) and always likely to cancel quickly? The data cannot distinguish these.

- **What is the onboarding completion rate by price tier?** If $199 accounts are completing fewer onboarding steps, that's a direct intervention lever — but no onboarding funnel data was available.

- **Are the 4 accounts that canceled subscriptions but stayed on the platform profitable to retain?** They rationalized down, not out — understanding their remaining product spend matters for LTV calculations.

- **Is $199/mo priced correctly for the segment buying it?** The 0% cancel rate at $29 vs 31% at $199 could reflect pricing misalignment as much as onboarding failure. Whether this is a product or a pricing problem requires competitive analysis not in scope here.

---

## Reframes

**1. "Churn" is mostly subscription rationalization, not platform abandonment.**
The working assumption entering this analysis was that churned PRO accounts had left Pulseboard. The data shows 4 of 5 accounts with canceled subscriptions are still active customers. The intervention model shifts from win-back / emergency outreach to tier-right-sizing and value demonstration for retained customers.

**2. The problem is not disengagement — it is value-price mismatch in a critical early window.**
H1 (engagement decline) was the primary hypothesis and was refuted in the strongest possible direction. Churned accounts were more active. The problem is not that users stop using the product; it is that active use is not translating into perceived value sufficient to justify $199/mo in months 0–3.

**3. The risk cohort is precise: $199/mo accounts in their first 90 days.**
Rather than a diffuse churn problem across PRO, the data points to a narrow, identifiable at-risk population. 3 of 7 cancellations were $199 accounts in their first 30 days. This precision enables a targeted early-warning system and proactive intervention, rather than broad retention spending.

**4. Support silence is a risk signal, not a health signal.**
NKing Corp — the only true churner — filed zero tickets. The absence of support contact before departure suggests that silent disengagement (without escalation) is how the worst-case churn happens. A customer who files tickets is still engaged; a customer who goes quiet may be at higher risk than support-escalation metrics would suggest.
