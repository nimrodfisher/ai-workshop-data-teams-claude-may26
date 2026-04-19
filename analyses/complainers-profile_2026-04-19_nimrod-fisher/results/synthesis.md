# Synthesis — Complainers Profile Analysis

**Analyst:** Nimrod Fisher  
**Date:** 2026-04-19  
**Based on:** `eda-findings.md`, charts `01–06`, hypotheses from `plan.md`

---

## Re-reading the Hypotheses

Criteria below are as written in Phase 1 — before data was seen.

---

## H1 — Complainers have higher platform engagement than non-complainers

- **Supporting evidence:** Mean events increase monotonically with ticket count: 35.1 (0 tickets) → 39.6 (1–2) → 42.0 (3+). Direction is correct.
- **Contradicting evidence:** The mean ratio between extreme groups is only **1.20×** (threshold: ≥1.5×). Median events are nearly identical: 39 vs 40 vs 40.5. The effect is driven by a small high-activity tail in the 3+ bucket, not a consistent pattern.
- **Silent areas:** Event *types* were not broken down — it's possible that a specific event type (e.g. errors, failed actions) is elevated in high-ticket accounts even if total volume is similar. Not available in this dataset without querying `events.event_type`.
- **Strength:** **Weak**
- **Answer:** Complaining accounts generate marginally more events than non-complaining accounts, but the difference (1.20× on mean, ~1× on median) is too small to be practically meaningful. Engagement volume alone does not distinguish who will complain.
- **Cited evidence:** `03_engagement-by-bucket.svg`

---

## H2 — Complaints concentrate in specific plan tiers

- **Supporting evidence:** Enterprise has the highest complaint rate at 94.7% and highest ticket intensity at 1.68 avg tickets/account — both above the overall averages of 82% and 1.58. Pro and Free are nearly identical (~74% rate, ~1.50 intensity).
- **Contradicting evidence:** Enterprise's rate is only **1.16× the overall average** (threshold: ≥2×). The gap between Enterprise and the other tiers is real but modest. Enterprise's ticket distribution is uniform across all 4 categories — it does not cluster into any single problem type.
- **Silent areas:** The dataset has no pricing or contract data at the subscription level that would allow distinguishing Enterprise contract sizes. Larger contracts may correlate with more deliberate support engagement.
- **Strength:** **Weak** (direction correct, magnitude below threshold)
- **Answer:** Enterprise accounts are more likely to file a ticket than Free or Pro accounts, but the difference is not large enough to be a reliable predictor. The more actionable finding is *what* they complain about: Enterprise spreads tickets evenly; Pro concentrates on feature requests; Free concentrates on billing.
- **Cited evidence:** `02_complaint-by-plan.svg`, `05_category-by-plan.svg`

---

## H3 — Complaints cluster in specific tenure buckets

- **Supporting evidence:** The 91–365 day cohort has a 100% complaint rate and 2.40 avg tickets per account — **1.61× the 1–2 year average of 1.49**, which clears the 1.5× threshold directionally.
- **Contradicting evidence:** **n=5** for the 91–365 day bucket. With 5 accounts at 100%, a single non-complainer would drop the rate to 80% — identical to the longer-tenure cohort. The result is entirely fragile to small sample effects.
- **Silent areas:** No accounts with tenure < 90 days or > 2 years exist in the dataset, so the "new user onboarding friction" and "long-tenure accumulated debt" sub-hypotheses cannot be tested.
- **Strength:** **Inconclusive** — correct direction, meets threshold numerically, but n=5 makes no conclusion valid.
- **Answer:** We cannot conclude that tenure drives complaint behavior with the available data. A larger dataset with a fuller tenure distribution would be needed to test this hypothesis properly.
- **Cited evidence:** Tenure table in `eda-findings.md` (no separate chart — n too small to visualise meaningfully)

---

## H4 — Complainers show a behavioral spike in the 30 days before their first ticket

- **Supporting evidence:**
  - Pre-ticket window avg: **11.2 events** vs baseline avg: **8.0 events** → ratio **1.60×** (threshold: ≥1.5×) ✅
  - **13/29 accounts (45%)** show a >1.5× spike in pre-ticket activity (threshold: ≥40%) ✅
  - Both confirm criteria are met simultaneously.
  - Zero accounts show a *drop* in pre-ticket activity — this rules out the "disengagement causes complaints" narrative.
- **Contradicting evidence:** None. The pattern is consistent across the sample.
- **Silent areas:** The pre-signal analysis is restricted to 29 accounts (tickets ≥ Mar 2025, events window). The remaining 12 complaining accounts outside this window cannot be assessed. The 30-day pre-signal window is somewhat arbitrary — it was set in Phase 1, not tuned post-hoc.
- **Strength:** **Moderate** — both criteria met, direction unambiguous, zero contradictory cases. Rated Moderate (not Strong) because: (a) n=29, (b) the events window only covers 4 months, (c) we cannot distinguish *type* of activity spike.
- **Answer:** Yes, in Enterprise and Free accounts. Platform activity builds up over the 30 days before a first ticket in 45% of measured accounts overall (42% Enterprise, 56% Free, 38% Pro — Pro is below threshold). The pre-signal is a **sustained 30-day elevation**, not a last-week spike (7-day daily rate ratio is flat at 1.02×). Signal is window-dependent: present at 30 days, weakens at 14 days. May 2025 spike was tested and cleared as a confounder — excluding May strengthens the effect (2.26×). A 30-day rolling activity monitor is the right detection horizon.
- **Cited evidence:** `06_presignal-h4.svg`, `queries/07_eda-presignal-h4.sql`, `results/validation.md`

---

## H0 — Complainers are statistically indistinguishable from non-complainers

- **Supporting evidence:** No single dimension (plan, tenure, engagement) produces a complaint rate difference of ≥1.5× with n ≥ 50 in both groups. The three main dimensions tested (H1, H2, H3) all failed to meet their confirm criteria.
- **Contradicting evidence:** H4 refutes the pure null — there *is* a detectable pre-ticket signal in event activity. The null holds for static profile dimensions, not for behavioral dynamics.
- **Strength:** **Partially supported**
- **Answer:** In terms of static profile (plan, tenure, engagement level), complaining and non-complaining accounts are largely indistinguishable. However, the null does not hold for behavioral dynamics — activity trajectory in the weeks before a ticket is a real differentiator.

---

## Overall Conclusion

**The static profile of a complaining account does not reliably differ from a non-complaining one.** Plan tier, account tenure, and overall engagement volume are weak predictors with modest effect sizes. Enterprise accounts file slightly more tickets, and Free accounts skew toward billing issues, but these are marginal signals.

**The strongest finding is behavioral and temporal:** platform activity spikes in the 30 days before a ticket is filed, in 45% of cases and at 1.6× baseline intensity. The implication is that *who* will complain cannot be determined from their profile alone — but *when* they are about to complain can be inferred from a detectable uptick in activity.

---

## What We Know vs What We Believe

**Know (from data):**
- 82% of accounts have filed at least one support ticket
- Enterprise accounts have a 94.7% complaint rate vs ~74% for Pro/Free
- Free accounts file predominantly billing tickets; Pro accounts file predominantly feature requests; Enterprise is evenly spread
- Activity spikes 1.6× in the 30 days before a first ticket in 45% of measured accounts
- May 2025 had an unexplained 2.1× spike in ticket volume

**Believe (interpretation):**
- The category × plan pattern likely reflects true product friction differences: Free users hit paywalls (billing); Pro users are power users wanting more (features); Enterprise has broad, varied teams
- The pre-ticket activity spike probably reflects users encountering a problem and trying repeatedly to solve it before escalating to support
- The May 2025 spike may indicate a product change, infrastructure issue, or billing cycle event — but this cannot be confirmed from available data

---

## Open Questions

1. **What event types spike before a ticket?** The pre-signal is confirmed on volume; knowing whether it's login spikes, error events, or specific feature interactions would sharpen the early warning model.
2. **What caused the May 2025 spike?** Without a product changelog or incident log in the schema, this is unresolvable with available data.
3. **Does tenure matter at scale?** The 91–365 day cohort finding is suggestive but requires n > 50 to test meaningfully.
4. **Do accounts with billing tickets churn at higher rates?** The analysis scoped out churn/revenue modeling — this is the logical follow-up for the Free plan insight.
5. **Is the pre-signal stronger for specific ticket categories?** A category-split pre-signal analysis could identify whether the spike precedes bugs differently than feature requests.

---

## Reframes

None required. The original question ("what characterizes complaining users?") is answered — it just turns out that *static characteristics* are weak predictors and *behavioral dynamics* are the real signal. No re-scoping needed; this is a clean finding to take into Validation.
