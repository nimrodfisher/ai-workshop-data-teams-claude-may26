# Synthesis (revised after Phase 6 validation, 2026-04-20)

> **This document was substantially revised after validation.** See `results/validation/validation.md` for the full stress-test. The prior version overstated the H2 "disengagement" finding; that claim has been withdrawn. The H1-plan finding survives with a narrowed temporal claim.

Phase 5 — Complainer-user profile.
Population: 200 users / 36 complainers (18.0% baseline) / 39 complaint tickets in `[2024-06-17, 2025-06-17]`.

---

## Original question

> What observable, measurable characteristics distinguish **users** who file complaint-like support tickets (`bug` or `billing`) from users who do not, so we can decide whether to build an early-warning / proactive-outreach list?

---

## H1 — Plan & role skew

> *Original criterion:* "At least one segment shows ≥1.3× baseline with n≥30 per group and Fisher's exact p<0.05."

### H1-plan

- **Supporting:** Free plan rate 28.0% vs baseline 18.0% (lift 1.56×). Free-vs-Paid RR = 1.91 [95% CI: 1.06, 3.44]. χ² = 4.52, df=1, p = 0.034. Holds under every alternative complaint definition (bug 1.20×, billing 3.00×, bug+billing+usage 1.55× — V1 validation). Holds when stratified by tenure (Free 28%/28% across newer/older — V2 validation). Passes n≥30 in both arms.
- **Contradicting / caveats:**
  - 3-way (Free/Pro/Enterprise) χ² p = 0.100 — collapsing is the right move; Pro and Enterprise are statistically indistinguishable.
  - Yates-corrected χ² p = 0.056 — the signal is on the significance boundary.
  - **V5 temporal split reveals complaint activity is concentrated in second half of window** (2/50 free, 0/150 paid in months 1–6; 12/50 free, 22/150 paid in months 7–12). The "12-month" claim is effectively a 6-month claim.

**Strength: Moderate (narrowed).**
Criterion is met for the analysis period where complaint data exists. Generalisation beyond that period is unsupported.

**Answer:** **Yes — in the period 2024-12-17 → 2025-06-17, Free users complained at ~1.9× the rate of paid users.** Pro and Enterprise behave identically. Whether this is a stable structural property of the user base or reflects something about that specific period cannot be answered with this data.

### H1-role

- **Supporting:** None meeting the 1.3× + p<0.05 bar.
- **Contradicting:** χ² = 0.61, df=2, **p = 0.737**; max spread 5pp; all Wilson CIs overlap.

**Strength: Refuted.**
**Answer:** Role does not distinguish complainers. Do not use as a targeting attribute.

---

## H2 — Engagement

> *Original criterion:* "Median events/user in 30 days before first complaint is **≥1.3×** the median for matched non-complainers; Mann-Whitney U p<0.05."

### What Phase 4 claimed and why it was wrong

Phase 4 concluded that H2 was refuted in the stated direction but "strongly supported" as a *disengagement* reframe (MWU z = −4.05 at 30d, −4.72 at 14d). **Phase 6 validation withdrew that conclusion.** Three overlapping issues:

1. **Rank-computation bug.** The SQL used `RANK()` (min-rank) instead of average-rank for tied values. Correctly computed rank sums (V3): z = −1.93 at 30d (borderline), z = −0.42 at 21d (null), z = +0.99 at 14d (*direction reversed*). The "signal gets stronger at shorter windows" story was the artifact.
2. **Event coverage gap.** Events span 2025-03-07 → 2025-06-06 (~90 days) inside a 365-day analysis window. 18 of 36 complainers had first complaint before event data even starts. Their pre-complaint event windows were structurally zero — not behavioral.
3. **Reference-date mismatch.** Non-complainers' 30d window ended at 2025-06-17 (11 days after last event), partly in a post-coverage dead zone.

Each alone was a problem; combined they produced a convincing-looking "disengagement" signal that isn't actually in the data.

### What the data actually supports (V8)

Restricted to complainers whose pre-complaint 30-day window is fully inside event coverage (n = 14), and comparing against non-complainers at a reference date inside coverage (2025-05-06):

| Group | n | mean | median | zeros |
|---|---:|---:|---:|---:|
| complainer | 14 | 4.86 | **5.0** | 1 |
| non-complainer | 186 | 2.91 | 2.0 | 22 |

MWU z = **+2.27, p ≈ 0.023** — direction consistent with the *original* H2 (higher engagement → complaints). Median ratio 2.5×, above the 1.3× plan threshold.

- **Supporting:** Directional signal consistent with H2 in the only subset where the test is actually computable.
- **Contradicting:** n = 14 complainers is very small; single-observation reshuffles could flip it.
- **Silent:** The other 22 complainers. Whether they behaved similarly cannot be determined from this data.

**Strength: Inconclusive.** Too small an n in the only valid subset to draw a decision-grade conclusion. H2 *as originally stated* is directionally consistent in the valid subset but not testable at the scale the plan envisioned.

**Answer:** **We cannot testably answer whether engagement predicts complaints with this dataset**, because the events table does not cover most of the analysis window. The 14-complainer subset with valid coverage shows directional support for the *original* H2 (higher engagement → complaints), but n is too small for a decision-grade claim. The "disengagement" framing introduced in earlier synthesis drafts has been withdrawn.

---

## H3 — Tenure

> *Original criterion:* "One bucket shows ≥1.3× baseline with n≥30 per bucket and Fisher's exact p<0.05."

- **Supporting:** `<90d` bucket: 23.7% (lift 1.32×, just above threshold).
- **Contradicting:** 4-way χ² p = 0.30, endpoint 2×2 p = 0.09. Pattern non-monotonic (23.7% → 15.3% → 22.2% → 10.9%).

**Strength: Weak, effectively Refuted.**
**Answer:** No reliable tenure signal at this n. Suggestive only that newest cohort runs hot and oldest runs quiet. Not actionable on its own.

*Note:* V2 validation shows the paid stratum has a real tenure effect (17% newer → 11% older). The free stratum does not (28%/28%). This is a sub-finding not in the hypothesis set — flag for follow-up.

---

## H0 — Null

- Plan delta p = 0.034 → rejected for plan.
- Role p = 0.74 → not rejected for role.
- Tenure p = 0.30 → not rejected for tenure.
- Engagement: not testable at current coverage.

**H0 is rejected on plan. Everything else is consistent with H0 or not testable.**

---

## Overall Conclusion (revised)

**Based on this 12-month data snapshot, the only observable, measurable characteristic that reliably distinguishes complainer users is `plan = 'free'`.**

Free users complain at ~1.9× the rate of paid users in the period that actually contains complaint activity (2024-12-17 → 2025-06-17). Pro and Enterprise are indistinguishable. Role, tenure, and industry show no reliable signal. Pre-complaint engagement cannot be tested because the events table covers only ~90 of the 365 days in the analysis window.

**Recommended watch-list rule:** `plan = 'free'` — precision 28%, recall 39%, lift 1.56× over baseline. Simple, single-factor, unconfounded, and honest about what the data supports. Flags 50 users, catches 14 of the 36 complainers.

**Stretch rule (needs verification with better event coverage):** `plan = 'free' AND ev_30 = 0` reaches precision 58%, lift 3.24×, but flags only 12 users (recall 19%) and relies on an event signal that is partially artifactual at current coverage. Mark as experimental; don't deploy until event data covers ≥6 months overlapping with the complaint window.

---

## What We Know vs What We Believe

### Know — directly supported by validated data
- Free users complain ~1.9× more than paid users in the 2024-12-17 → 2025-06-17 period (χ² p = 0.034, RR [1.06, 3.44]).
- Pro and Enterprise are statistically indistinguishable from each other.
- Role does not distinguish complainers (p = 0.74).
- Tenure does not monotonically distinguish complainers (p = 0.30).
- Paid users' complaint rate declines with tenure (17% newer → 11% older); free users' does not (28% both).
- Complaint activity is concentrated in the second half of the analysis window (34 of 36 complaints).
- Events table coverage is far narrower than the complaint window (~90 days vs ~365).

### Believe — interpretation, not data
- The Free-vs-Paid gap is plausibly driven by (a) billing friction on a free tier and (b) lower tolerance from users who haven't invested financially. Both are consistent with Free being billing-heavy (57% billing share), but we have not causally tested this.
- The temporal concentration of complaints probably reflects either a product or user-base change in late 2024, or a lag in support-ticket logging. Either interpretation has design implications (stable vs. transient signal); the data cannot distinguish them.
- If we had full event coverage, H2-as-stated would probably show a real engagement effect, based on the n=14 subset. But we cannot commit to this.

---

## Open Questions (for follow-up)

- **Extend event data coverage.** The single highest-leverage data improvement. A 6-month overlap between events and complaints would let us properly test H2.
- **Is the Free-plan signal a period effect or a structural one?** Needs either a longer time series or a second snapshot.
- **Paid-plan tenure effect.** 17% → 11% warrants its own analysis.
- **Watch-list false-positive cost.** What does it cost to outreach to a non-complainer who's flagged? That determines the precision/recall trade-off for rule choice.
- **Industry is underpowered at n = 5–10 accounts per industry.** A larger snapshot or macro-rollup could unlock it.

---

## Reframes / revisions from the plan

1. **H2 "disengagement" reframe: withdrawn.** Built on bad math + a coverage artifact. Reported here for process transparency, not as a finding.
2. **H1-plan claim narrowed** to a 6-month sub-period.
3. **Watch-list rule revised** from `plan='free' OR ev_14=0` (lift 1.04×, near-useless) to `plan='free'` alone (lift 1.56×), with `plan='free' AND ev_30=0` as an experimental stretch.
4. **Tenure-at-snapshot reference date** retained (no change from Phase 4).
5. **New known issues logged:** (a) events table ~90-day coverage vs 365-day window; (b) SQL MWU rank-tie pattern. Both in `.cursor/learning/known_issues.md`.

---

## Evidence-strength scorecard (post-validation)

| Hypothesis | Criterion | Verdict | Strength |
|---|---|---|---|
| H1-plan | ≥1.3× lift, n≥30, p<0.05 | Met (narrowed to 6-month window) | **Moderate** |
| H1-role | same | Not met (1.16×, p=0.74) | **Refuted** |
| H2 as stated | Median ratio ≥1.3×, MWU p<0.05 same direction | Directionally supported in n=14 subset; not testable at planned scale | **Inconclusive** |
| H2 reframed (disengagement) | — | Prior claim withdrawn | **Withdrawn** |
| H3-tenure | ≥1.3× lift in ≥1 bucket, n≥30, p<0.05 | Lift yes (<90d 1.32×), p no (0.30) | **Weak / Refuted** |
| H0 | No segment distinguishes | Rejected on plan | **Rejected** |

> One Moderate finding. Two clear Refutations. One Inconclusive (the data simply can't test it). One Withdrawn claim from the prior synthesis.
>
> A narrower, better-validated story. Less to say — but what remains is supported.
