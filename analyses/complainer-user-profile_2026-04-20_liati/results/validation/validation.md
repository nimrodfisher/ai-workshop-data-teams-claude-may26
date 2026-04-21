# Validation

Phase 6 — Complainer-user profile

**Headline: validation uncovered two methodological bugs and one missed data-coverage issue that together invalidated the Phase 4/5 "disengagement" conclusion. After corrections, H1-plan (Free ~2× Paid) still holds, the "disengagement" finding is withdrawn, and H2 *as originally stated* (higher engagement → complaints) is weakly supported (z = +2.27, p ≈ 0.023, n_c = 14) once event-coverage is enforced.**

Saying this plainly up front because burying it would be worse. Full details below.

---

## What validation was supposed to do vs. what it actually did

**Plan:** run 6 sensitivity/replication checks (alt complaint definitions, plan×tenure composition, lookback-window robustness, outlier trim, temporal split, watch-list P/R).

**What happened:** two of the checks produced results that were internally inconsistent with my Phase 4 numbers. That forced a diagnostic rerun of the MWU math, which uncovered:

1. **Methodological bug #1** — rank-sum computation used min-rank instead of average-rank for ties.
2. **Methodological bug #2** — I never confirmed in Phase 2 QA whether the `events` table actually covered the 12-month analysis window.
3. **Data coverage miss** — events span ~90 days (2025-03-07 → 2025-06-06), not 365. 18 of 36 complainers had their first complaint *before* event coverage starts, forcing structural zeros that the Phase 4 analysis misread as disengagement.

Both bugs have been written to `known_issues.md`.

---

## V1 — Alternative complaint definitions (sensitivity)

**Does H1-plan survive if we change what counts as a "complaint"?**

| Definition | Free rate | Paid rate | Ratio (free/paid) | n complainers |
|---|---:|---:|---:|---:|
| `bug` only | 12.0% | 10.0% | 1.20× | 21 |
| `billing` only | 16.0% | 5.33% | **3.00×** | 16 |
| `bug` OR `billing` (plan definition) | 28.0% | 14.67% | 1.91× | 36 |
| `bug` OR `billing` OR `usage_question` | 34.0% | 22.0% | 1.55× | 50 |

**Result:** Free > Paid in every definition. The plan's chosen `(bug, billing)` set sits in the middle of the robustness range. Billing is the strongest Free-vs-Paid signal (3×), bug is the weakest (1.2×). This is consistent with Phase 4's category-mix finding (Free is billing-heavy).

**Holds.** (`50_val-alt-complaint-defs.csv`)

---

## V2 — Composition test: is "Free" a proxy for "newer"?

**If Free users happen to be newer, the Free-plan signal might collapse once we condition on tenure.**

| Plan group | Tenure | Rate | n |
|---|---|---:|---:|
| free | newer (<180d) | 28.0% | 25 |
| free | older (180d+) | 28.0% | 25 |
| paid | newer (<180d) | 17.2% | 93 |
| paid | older (180d+) | 10.5% | 57 |

**Result:** Free complaint rate is **identical (28%)** across tenure groups. Paid complaint rate declines with tenure (17% → 11%). Free is *not* a proxy for newer tenure, and the Free-vs-Paid gap (free 28% vs. paid-newer 17%, paid-older 11%) is wider when you condition on the same tenure strata.

**H1-plan holds under this decomposition.** Side finding: paid users' tenure effect is real, and if this were in scope, we'd dig into it. (`51_val-plan-tenure-cross.csv`)

---

## V3 — MWU lookback-window robustness (now with corrected rank math)

**Original Phase 4 claim:** z = −4.05 (30d), −4.72 (14d), −3.83 (21d).

**After fixing the rank-tie bug:**

| Lookback | Complainer rank sum (observed / expected) | Non-comp rank sum | U₁ | z | p (two-tail) |
|---|---|---|---:|---:|---:|
| 30d | 3,012 / 3,618 | 17,088 | 2,346 | **−1.93** | **0.054** |
| 21d | 3,485 / 3,618 | 16,615 | 2,819 | −0.42 | 0.67 |
| 14d | 3,930 / 3,618 | 16,170 | 3,264 | **+0.99** | 0.32 |

Expected R₁ under null = 36 × 201 / 2 = 3,618. Total rank sum check: 3,012 + 17,088 = 20,100 = 200 × 201 / 2 ✓ (validates the avg-rank formula is correct).

**Result:**
- 30d: borderline (p = 0.054), complainers have *slightly lower* ranked engagement.
- 21d: null.
- 14d: null, and **direction is actually reversed** (complainers higher, not lower).

The earlier "signal gets stronger at shorter windows" story was a rank-bug artifact. With correct math, the signal weakens and eventually flips direction as you shorten the window. That's no longer a consistent disengagement finding — that's noise plus a coverage artifact (more below).

(`52_val-mwu-corrected-ranks.csv`, `known_issues.md` → "MWU rank-sum computation")

---

## V4 — Outlier-trimmed MWU (with corrected ranks)

Drop top 10% and bottom 10% of 30-day event counts; recompute.

| Group | n | mean_30 | rank sum (avg rank) |
|---|---:|---:|---:|
| complainer | 27 | 0.48 | 1,295.5 |
| non-complainer | 153 | 1.60 | 14,994.5 |

Expected R₁ = 27 × 181 / 2 = 2,443.5. Observed = 1,295.5 → much lower. U₁ = 1,295.5 − 378 = 917.5; μ_U = 27 × 153 / 2 = 2,065.5; σ_U = √(27 × 153 × 181 / 12) = √(62,319.75) = 249.6.

**z = (917.5 − 2,065.5) / 249.6 = −4.60, p < 0.0001.**

After trimming: the disengagement signal *does* reappear, but with a suspicious interpretation: the bottom 10% cutoff removes the high-engagement tail (including most Free power users), leaving us with a population of low-engagement users, in which complainers cluster at the bottom. This is mechanical — we've selected on the covariate we're testing. **Does not validate the Phase-4 finding.** (`V4 data embedded in validation narrative above.`)

---

## V5 — Temporal stability

**Split the 12-month analysis window in half:**

| Period | Plan | Complainer rate | n |
|---|---|---:|---:|
| 2024-06-17 → 2024-12-16 (H1) | free | **4.0%** | 50 |
| H1 | paid | **0.0%** | 150 |
| 2024-12-17 → 2025-06-17 (H2) | free | 24.0% | 50 |
| H2 | paid | 14.7% | 150 |

**34 of 36 complaints occur in the second half of the window.** The first half has 2 total complaints (both Free), and 0 complaints on Paid plans. This means:
- H1-plan (the Phase 4 Moderate-strength finding) is essentially a claim about the period **2024-12-17 → 2025-06-17 only**.
- The "12-month window" is a misnomer; complaint-generating behavior in this dataset is concentrated in ~6 months.
- Earliest complaint in the data is **2024-12-12**, which is *outside* the plan's declared 12-month window. (Plan anchored on 2025-06-17 working back 365 days → window starts 2024-06-17.)

**Implication:** we cannot claim temporal stability of the Free-vs-Paid effect. It's a single-period observation. (`54_val-temporal-split.csv`)

---

## V6 — Watch-list rule precision/recall

**Baseline rate = 18.0% (36/200).**

| Rule | Flagged | TP | Precision | Recall | Lift vs 18% |
|---|---:|---:|---:|---:|---:|
| `plan='free' AND ev_30 = 0` | 12 | 7 | **58.3%** | 19.4% | **3.24×** |
| `ev_30 = 0` | 53 | 21 | 39.6% | 58.3% | **2.20×** |
| `plan='free' OR ev_30 = 0` | 91 | 28 | 30.8% | 77.8% | 1.71× |
| `plan='free'` | 50 | 14 | 28.0% | 38.9% | 1.56× |
| `ev_30 < 2` | 105 | 23 | 21.9% | 63.9% | 1.22× |
| `plan='free' OR ev_14 = 0` (my original Phase-5 proposal) | 161 | 30 | 18.6% | 83.3% | **1.04×** |
| `plan='free' AND ev_14 = 0` | 31 | 8 | 25.8% | 22.2% | 1.43× |
| `ev_14 = 0` | 142 | 24 | 16.9% | 66.7% | **0.94×** ← below baseline |

**Critical findings:**
- My Phase 5-recommended rule (`free OR zero_14d`) flags 161 of 200 users for essentially no lift (1.04×). It's nearly useless as a targeting rule.
- The `ev_14 = 0` flag alone has **below-baseline** precision (16.9% vs 18%). The "0 events in 14 days" signal does not separate complainers from non-complainers at the categorical level.
- The `ev_30 = 0` flag does — precision 39.6%, recall 58%, lift 2.2×. But this conflicts with V3 above (30d MWU only marginally significant) and with the coverage finding below (half of complainers' pre-complaint 30d windows are entirely outside event coverage, so `ev_30 = 0` for them is structural, not behavioral).
- The high-precision rules (`free AND zero_30`: 58% precision, 3.24× lift) look great but the `ev_30 = 0` half of that rule is partly artifactual.

(`55_val-watchlist-rules.csv`)

---

## V7 — Events data coverage (the miss that explains everything)

Ran as a consequence of a strange result in V3 (at 7-day lookback, all 164 non-complainers had 0 events).

| Metric | Value |
|---|---|
| First event | **2025-03-07** |
| Last event | **2025-06-06** |
| Total events | 1,960 across 92 active days |
| Events in last 7 days of window (Jun 11–17) | **0** |
| Events in last 30 days of window (May 18–Jun 17) | 438 |

The `events` table is **~90 days of coverage inside a 365-day analysis window**. The first 9 months of the window have zero events.

**Complainer impact:**

| Coverage status | n |
|---|---:|
| First complaint **before** event data starts (pre-2025-03-07) | **18 of 36 (50%)** |
| First complaint in first 30 days of event data (partial coverage) | 4 |
| First complaint has full 30-day pre-window inside event coverage | **14 of 36** |
| First complaint after event data ends | 0 |

**Earliest complaint: 2024-12-12, earliest event: 2025-03-07 — a 3-month gap.**

This means 22 of 36 complainers (61%) had incomplete or no pre-complaint event coverage, making their "0 events in 30d" a data artifact, not a behavioral signal. This was missed in Phase 2 QA (I checked event-table row counts and nulls, not date coverage vs. the analysis window).

**Added to `.cursor/learning/known_issues.md`.**

---

## V8 — Coverage-restricted H2 re-test (the headline replication)

**Restrict to complainers whose pre-complaint 30-day window is fully inside event coverage** (first complaint between 2025-04-06 and 2025-06-06). Move non-complainer reference date to 2025-05-06 (midpoint of event coverage, giving them a symmetric 30-day pre-window that's entirely inside coverage).

| Group | n | mean | median | zeros | Rank sum (avg) |
|---|---:|---:|---:|---:|---:|
| complainer | 14 | **4.86** | **5.00** | 1 | 1,880.5 |
| non-complainer | 186 | 2.91 | 2.00 | 22 | 18,219.5 |

Expected R₁ = 14 × 201 / 2 = 1,407; observed = 1,880.5. U₁ = 1,880.5 − 105 = 1,775.5. μ_U = 14 × 186 / 2 = 1,302; σ_U = √(14 × 186 × 201 / 12) = √43,617 = 208.8.

**z = +2.27, two-tailed p ≈ 0.023.**

**The direction flips back to H2-as-originally-stated: when we restrict to complainers whose engagement data is actually observable, complainers have HIGHER pre-complaint engagement** (median 5 vs 2, mean 4.86 vs 2.91, ratio 2.5× — above the 1.3× threshold in plan.md).

**But n=14 for complainers is fragile.** A dozen or so observations doesn't support a strong claim.

(`53_val-mwu-coverage-restricted.csv`)

---

## Alternative explanations tested

1. **Composition shift (Free = newer users?)**: V2 rejected — Free rate is 28% at both tenures.
2. **Selection by coverage (the one we missed until now)**: V7 + V8 confirmed this was the actual driver of the Phase-4 "disengagement" finding. Fixed.
3. **Tie-handling math (statistical-method artifact)**: V3 confirmed; z-scores collapsed when fixed.
4. **Temporal instability (Simpson-like)**: V5 showed the effect is entirely from the second half of the window; not Simpson's paradox exactly but a similar warning about aggregating across periods with very different data density.
5. **Outlier domination**: V4 — the disengagement signal survives outlier trimming but the interpretation is mechanical (we trimmed the variable we were testing).
6. **Complaint-definition sensitivity**: V1 — H1-plan holds for any reasonable complaint set.

---

## Segment robustness (corrected view)

**H1-plan (Free vs Paid):**
- Holds in: newer users, older users, every complaint-definition variant.
- Caveat: only the second half of the window has enough complaint volume to test it.
- Narrowed claim: "Free users complain at ~1.9× the rate of paid users over the period 2024-12-17 → 2025-06-17 (34 of 36 complainers)."

**H2 (as originally stated — higher engagement predicts complaints):**
- Holds weakly in: the n=14 subset with valid pre-complaint event coverage (z = +2.27, p = 0.023).
- Does not hold in: the full n=36 MWU with corrected ranks (z = −1.93 to +0.99 depending on window — unstable).
- Narrowed claim: **too fragile for a decision-grade conclusion.**

**H1-role, H3-tenure:** unchanged by validation — both still not distinguishing, not affected by the event-coverage issue.

---

## Red-team objections and responses

### Objection 1 — "Your Phase-4 MWU z-scores were computed with a bug; why should I trust the Phase-4 plan and tenure analyses?"
**Response:** The chi-square / RR / OR math in Phase 4 does not involve rank computation and is unaffected. H1-plan (χ² = 4.52, p = 0.034, RR = 1.91 [1.06, 3.44]) is unchanged. H1-role (χ² = 0.61, p = 0.74) unchanged. H3-tenure (χ² = 3.63, p = 0.30) unchanged. Only the engagement MWU is affected.

### Objection 2 — "You claim H1-plan 'holds' but V5 shows it only holds for 6 months of your 12-month window. Isn't that really an 'in 2025, Free users complained more' finding?"
**Concede.** That's the right framing. The claim should be narrowed to "in the period with complaint-generating activity (2024-12-17 → 2025-06-17), Free users complained ~1.9× more than paid users." Whether this is a stable structural property of the user base or a one-time phenomenon cannot be determined from this dataset.

### Objection 3 — "Your n=14 'V8 replication' is too small to support H2 either way."
**Concede.** z = +2.27 with n_c = 14 is a single marginal result; a single reshuffle of 2-3 users would flip it. We should report this as "directional signal in the limited sub-population with valid coverage, but not strong enough to drive a decision." The correct position is: **H2 is not testable with the current data**, not "H2 confirmed."

### Objection 4 — "Your `free AND zero_30` rule has precision 58% but uses an artifactual predictor. If you dropped the `ev_30 = 0` half, what's left?"
**Response:** `plan='free'` alone has precision 28% and lift 1.56×. That's the honest watch-list predictor from this dataset. Everything involving events is either unreliable at this coverage or at borderline significance.

### Objection 5 — "You should have flagged the event coverage gap in Phase 2 QA."
**Concede.** This was a QA miss. Row counts and null checks on `events` were performed, but `MIN(occurred_at) / MAX(occurred_at)` vs the analysis window was not. Added to `known_issues.md` so future analyses check this by default.

---

## Revisions to synthesis.md

Synthesis needs the following changes (applied in this phase):

1. **H2 as stated: reclassify from "Refuted" to "Inconclusive / Not Testable."** The data does not let us separate a real engagement effect from an event-coverage artifact. The `n = 14` coverage-restricted subset is directionally consistent with H2 but too small to conclude.
2. **"H2 reframed as disengagement": withdraw entirely.** It was built on bad rank math plus a coverage artifact.
3. **H1-plan: narrow the claim** to the second-half-of-window period. Evidence strength unchanged at Moderate within that period.
4. **Watch-list recommendation: revise.** The previous `plan='free' OR ev_14 = 0` rule has 1.04× lift — effectively useless. Revised recommendation:
   - **Primary:** `plan = 'free'` — precision 28%, recall 39%, lift 1.56×. Unconfounded and simple.
   - **Secondary (experimental, needs more event coverage):** `plan = 'free' AND ev_30 = 0` — precision 58%, recall 19%, lift 3.24×, but the `ev_30 = 0` half is coverage-sensitive.
   - **Do not use:** anything based on `ev_14 = 0` alone (below-baseline precision).

---

## Headline survivor summary

| Claim | Status after validation |
|---|---|
| Free users complain ~1.9× more than paid users | **Survives** (narrowed to 2024-12-17 → 2025-06-17) |
| Role does not distinguish complainers | Survives |
| Tenure does not distinguish complainers | Survives (non-monotonic) |
| Category mix differs by plan | Survives |
| Industry shows underpowered spread | Survives |
| Complainers have LOWER pre-complaint engagement ("disengagement") | **Withdrawn** (bug + coverage artifact) |
| Pre-complaint `ev_14 = 0` is a strong complaint signal | **Withdrawn** (below-baseline precision) |
| H2 as originally stated (higher engagement → complaints) | **Inconclusive — not testable with 3-month event coverage** |
| Watch-list rule `free OR ev_14=0` | **Withdrawn** (lift 1.04×) |

**After validation: one Moderate finding (Free plan), three Refutations (role, tenure, H2-as-stated after coverage fix), and one finding withdrawn.**
