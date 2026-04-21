# Deep Analysis

Phase 4 — Complainer-user profile
Window: **2024-06-17 → 2025-06-17** (12 months) · Population: 200 users · 36 complainers (18.0%)

> **⚠ CORRECTION NOTICE — added after Phase 6 validation, 2026-04-20**
>
> Phase 6 validation uncovered two issues that **invalidate the MWU-based "disengagement" conclusion** in the H2 sections below:
>
> 1. The SQL rank computation used `RANK()` (min-rank), not average-rank for ties. Corrected z-scores: 30d = −1.93 (not −4.05), 21d = −0.42 (not −3.83), 14d = +0.99 (not −4.72 — direction actually reverses).
> 2. The `events` table covers only 2025-03-07 to 2025-06-06 (~90 days), not the full 365-day window. 18 of 36 complainers had their first complaint before event data even starts → structural zeros misread as disengagement.
>
> **Do not cite the 14d, 21d, or stratified MWU results from this document.** The H1-plan, H1-role, H3-tenure, category-mix, and industry findings (all chi-square-based) are **unaffected** and remain valid.
>
> The corrected analysis lives in `results/validation/validation.md` and the revised synthesis in `results/synthesis/synthesis.md`.

> EDA surfaced directional patterns. Deep Analysis quantifies magnitude, attaches uncertainty, and rules out the obvious confound (plan × engagement).

---

## H1 — Plan & role distinguish complainers

### H1-plan

- **Method:** Chi-squared on Free vs Paid (2×2). Collapsed pro + enterprise into "paid" because their rates are statistically indistinguishable (13.6% vs 15.4%, both with overlapping Wilson CIs and combined 3-way χ² driven 74% by the Free cell).
- **Why this method:** All expected cell counts ≥5; contingency test is the standard, and collapsing categories tightens the power against the one-plan split the EDA flagged.
- **Effect:**
  - Free complaint rate: **28.0%** [Wilson 95% CI: 17.5%, 41.6%], n = 50 (14 complainers)
  - Paid complaint rate: **14.7%** [Wilson 95% CI: 9.9%, 21.2%], n = 150 (22 complainers)
  - **Risk ratio = 1.91 [95% CI: 1.06, 3.44]** — Free users are ~1.9× more likely to complain than paid users
  - Odds ratio = 2.26 [95% CI: 1.05, 4.87]
  - Risk difference = +13.3 pp [Wald 95% CI: −0.4 pp, +27.0 pp] — CI barely crosses zero
- **Test statistic:** χ² = 4.52, df = 1, **p = 0.034** (uncorrected); χ²_Yates = 3.66, p = 0.056. The effect is on the 0.05 boundary. 3-way χ² (free/pro/ent) = 4.60, df = 2, p = 0.100 — non-significant *as a 3-way test*, which is expected because Pro and Enterprise are indistinguishable from each other.
- **Baseline comparison:** overall rate 18.0%. Free is +10.0pp above baseline; Paid is −3.3pp below.
- **Decomposition:** Free cell contributes 3.39 of the 4.60 total chi-contribution (74%). Enterprise and Pro contribute 0.42 and 0.79 respectively — i.e. both paid plans behave almost identically.
- **Alternatives ruled out here:** None yet for Free specifically — the Free signal is confounded with disengagement (see H2). Plan-level, however, the Free-vs-Paid collapse is clearly justified.
- **Cited evidence:** `40_plan-rate-with-ci.svg`, `40_da-plan-complainer.csv`

### H1-role

- **Method:** Chi-squared on admin/analyst/viewer × complainer (3×2).
- **Effect:**
  - admin: 20.8% [CI≈ 13.1%, 31.7%], n = 72
  - analyst: 16.4% [CI≈ 9.2%, 27.6%], n = 61
  - viewer: 16.4% [CI≈ 9.4%, 26.8%], n = 67
- **Test statistic:** χ² = 0.61, df = 2, **p = 0.737**. All Wilson CIs overlap heavily.
- **Verdict:** **H1-role refuted.** The ≤5 pp spread across roles is noise at this n. Role should not be used as a targeting attribute.
- **Cited evidence:** `41_da-role-complainer.csv`

### H1 summary

> **Plan is a real attribute-level signal (Free ~2× rate, p = 0.034). Role is not (p = 0.74).**

---

## H2 — Pre-complaint engagement differs

**Key finding: the hypothesis is refuted — but the *direction* is informative. Complainers are MORE likely to have very low pre-complaint engagement, not less.**

### H2-main (30-day lookback)

- **Method:** Mann-Whitney U test on events-per-user in the 30 days before first complaint (complainers) or before snapshot end 2025-06-17 (non-complainers).
- **Why this method:** Both distributions are heavily right-skewed with many zeros; MWU is rank-based and robust to this.
- **Effect (ranks):**
  - Complainer rank sum = 2,345 (expected under null = 3,618)
  - U₁ = 1,679, μ_U = 2,952, σ_U = 314.5
  - **z = −4.05, two-tailed p < 0.0001**
- **Descriptive stats (tells a complementary story):**
  - Complainer: n=36, **median = 0**, Q1 = 0, Q3 = 4.25, mean = 2.25
  - Non-complainer: n=164, **median = 1.5**, Q1 = 1, Q3 = 3, mean = 1.98
- **What's happening:** The *mean* is slightly higher for complainers (2.25 vs 1.98), but the *median is zero*. The complainer distribution is **bimodal** — a large cluster of near-zero users plus a smaller tail of heavy users. Non-complainers cluster tightly in the 1–3 events/30d range. Rank-based tests pick up the disengagement cluster; mean obscures it.
- **Direction relative to H2 as stated:** H2 predicted "higher engagement → higher complaint rate." The data says the opposite by rank: **complainers are disproportionately concentrated at 0 pre-complaint events.** H2 in its directional form is refuted.

### H2-robustness (14-day lookback)

- **Method:** Same MWU with a 14-day window to reduce reliance on users who may not have 30 days of event coverage (Finding 7 in EDA).
- **Effect:** Complainer rank sum = 2,133, z = −4.72, p < 0.0001. Direction and magnitude are **stronger at 14 days** — consistent with disengagement being most visible *immediately* before the complaint, not earlier.

### H2-stratified (addressing the H1 × H2 confound from EDA Finding 8)

EDA showed Free users both complain more AND are more engaged on average, raising the risk that engagement was just a proxy for plan. Stratifying cleanly separates them:

| Stratum | Group | n | median 30d | mean 30d | Rank sum | MWU z | p |
|---|---|---|---:|---:|---:|---:|---:|
| Paid | complainer | 22 | 0 | 1.55 | 988 | **−3.57** | **<0.001** |
| Paid | non-complainer | 128 | 1 | 1.90 | 8,123 |  |  |
| Free | complainer | 14 | 0.5 | 3.36 | 263 | **−2.03** | **0.042** |
| Free | non-complainer | 36 | 2 | 2.28 | 827 |  |  |

Expected U and σ: paid μ=1,408 σ=188.2; free μ=252 σ=46.3.

- **Paid stratum**: Clean, monotonic disengagement signal. Every quantile of complainer engagement is at or below non-complainer.
- **Free stratum**: Bimodal — mean up (3.36 vs 2.28), median *down* (0.5 vs 2.0). Some free complainers are power users; most are dropouts.
- **Conclusion:** the engagement signal is **not** just a plan proxy. It exists independently within both strata. The shape differs (disengagement in paid, bimodal in free), but the rank-based direction is the same.

### H2 summary

> **H2 as literally stated is refuted (p < 0.0001 in the opposite direction).** The real signal is that **disengagement (0 events in 14–30d before complaint) is the strongest individual-level predictor observed.** This flips the narrative: complainers are *not* hyper-engaged "noise" users. They are a mix of (a) people quietly going silent and (b) a smaller cluster of heavy free users — both of which should be on a watch list.

**Cited evidence:** `43_engagement-mwu.svg`, `44_engagement-stratified.svg`, `43_da-engagement-mann-whitney.csv`, `44_da-engagement-stratified.csv`.

---

## H3 — Tenure effect

- **Method:** Chi-squared on 4-bucket tenure × complainer (4×2), plus 2×2 endpoint test (<90d vs 270d+) to probe the extremes.
- **Tenure at snapshot end (2025-06-17):**
  | Bucket | n | complainers | rate |
  |---|---:|---:|---:|
  | <90d | 59 | 14 | **23.7%** |
  | 90–180d | 59 | 9 | 15.3% |
  | 180–270d | 36 | 8 | 22.2% |
  | 270d+ | 46 | 5 | **10.9%** |
- **Test statistic (4×2):** χ² = 3.63, df = 3, **p = 0.30**.
- **Endpoint test (<90d vs 270d+):** 14/59 vs 5/46. χ² = 2.88, df = 1, **p = 0.090**. Suggestive but not significant at α=0.05. RR = 2.18 [95% CI: 0.85, 5.61].
- **Pattern:** Non-monotonic (up, down, up, down). No evidence of a smooth "newer = more complaint-prone" trend, which is what H3 predicted.
- **Verdict:** **H3 as a monotonic tenure hypothesis: refuted.** The data is more consistent with *no meaningful tenure effect at this n*, with a weak hint that the very new (<90d) cohort runs hot. Not actionable on its own.
- **Cited evidence:** `42_tenure-nonmonotonic.svg`, `42_da-tenure-complainer.csv`

---

## H0 — Null check

If nothing were distinguishing complainers we'd expect:
- Uniform rate across plan, role, tenure → **partially rejected**: plan does differ (p = 0.034), role and tenure do not.
- No engagement signal between complainer and non-complainer → **strongly rejected**: MWU z = −4.05 (p < 0.0001), and the signal persists inside both plan strata.
- Null cannot be fully retained.

---

## Category-mix decomposition

**What do complainers complain about, per plan?**

| Plan | Tickets | Billing | Bug | Billing share |
|---|---:|---:|---:|---:|
| enterprise | 16 | 8 | 8 | 50.0% |
| free | 14 | 8 | 6 | 57.1% |
| pro | 9 | 1 | 8 | **11.1%** |

- Pro is a category outlier: nearly all its complaints are bug reports; it almost never complains about billing.
- Free and Enterprise both run ~50/50. For Free this makes sense (payment friction for trial-ish users); for Enterprise it probably reflects contracted billing complexity.
- **n=9 for Pro is small;** treat this as a **lead, not a conclusion**.
- **Cited evidence:** `45_da-category-mix.csv`

---

## Industry — account-level robustness check

EDA showed very high spread at the user-level; re-aggregating to accounts avoids letting a single verbose account dominate its industry:

| Industry | Accounts | Complainer accts | Rate | Wilson 95% CI |
|---|---:|---:|---:|---|
| MarTech | 8 | 7 | **87.5%** | [53%, 98%] |
| eCommerce | 10 | 7 | 70.0% | [40%, 89%] |
| CyberSecurity | 6 | 4 | 66.7% | [30%, 90%] |
| EdTech | 5 | 3 | 60.0% | [23%, 88%] |
| HealthTech | 7 | 4 | 57.1% | [25%, 84%] |
| FinTech | 6 | 2 | 33.3% | [10%, 70%] |
| SaaS | 8 | 2 | **25.0%** | [7%, 59%] |

- **All industry CIs overlap the overall rate (58%).** The apparent 3.5× spread between MarTech and SaaS is not something we can defend at n = 5–10 accounts per industry.
- Flag for followup rather than decision input.
- **Cited evidence:** `46_industry-account-level.svg`, `46_da-industry-account-level.csv`

---

## Quantified Summary

| Hypothesis | Verdict | Effect | Test | p |
|---|---|---|---|---:|
| **H1-plan** (Free vs Paid) | **Confirmed (borderline)** | RR = 1.91 [1.06, 3.44]; Free 28% vs Paid 14.7% | χ² 2×2 | 0.034 |
| H1-plan (3-way) | Inconclusive | — | χ² 3×2 | 0.100 |
| **H1-role** | **Refuted** | <5pp spread; all CIs overlap | χ² 3×2 | 0.737 |
| **H2-engagement (as stated)** | **Refuted — direction reversed** | Complainer rank-sum −35% vs expected | MWU 30d | <0.0001 |
| H2-engagement (disengagement reinterpretation) | **Confirmed, strong** | z = −4.05 (30d), −4.72 (14d); holds in both plan strata | MWU stratified | <0.001 / 0.042 |
| **H3-tenure** (monotonic) | **Refuted** | Non-monotonic pattern | χ² 4×2 | 0.304 |
| H3-tenure (new cohort elevated) | Suggestive | <90d vs 270d+: 23.7% vs 10.9% | χ² 2×2 | 0.090 |
| **H0** | Rejected | See above | — | — |

**Dominant drivers (size-ranked):**
1. Low pre-complaint engagement (0 events in 14d) — largest effect, p < 0.0001, holds within both plan strata.
2. Free plan — RR ≈ 1.9, p = 0.034, but confounded with engagement shape (free complainers are bimodal, not uniformly high-engagement).
3. Everything else (role, tenure, industry) — insufficient evidence at this n.

---

## Caveats from this phase

- **Sample size**: The core population is 200 users / 36 complainers. Many 2×2 tests are just inside conventional significance; a handful of reassignments would flip borderline calls. We've preferred rank-based and ratio-based reporting with CIs for this reason.
- **No Fisher's exact p-values computed in SQL**: For 2×2 cells with expected counts all ≥5 (which all of ours satisfy), χ² is a standard-acceptable approximation. Yates-corrected χ² reported where relevant (pushes plan p from 0.034 → 0.056).
- **MWU uses normal approximation**: With n1+n2 = 200 the approximation is reliable. Ties are handled via average ranks.
- **Reference date for non-complainers' engagement window is fixed at 2025-06-17**, while complainers' is their first complaint date. If snapshot-end happens to be seasonally atypical, the non-complainer rank distribution could shift. Verified direction is consistent across both 30d and 14d windows, which reduces this concern.
- **Industry and role are underpowered**: 5–10 accounts per industry, 60–72 users per role. Anything we say about them is directional, not decisive.
- **Free-stratum engagement is bimodal**: A single "engagement" metric won't capture it cleanly. A rule like "0 events in 14d OR ≥5 events in 14d" may be the right operationalization for the watch-list — to be finalized in Synthesis.
- **Finding 7 limitation persists**: 18 of 36 complainers have full 30-day event histories before their first complaint; the other 18 are truncated. The 14-day window result (which is available for nearly all) points the same way, so this doesn't seem to be driving the signal.
