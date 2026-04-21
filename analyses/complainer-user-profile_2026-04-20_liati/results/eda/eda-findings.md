# EDA Findings — Complainer-User Profile

- **Date:** 2026-04-20
- **Analyst:** liati
- **Inputs:** see `queries/20_eda-*.sql` … `queries/29_eda-*.sql` and matching CSVs/SVGs in this folder.
- **Population:** 200 users, 36 complainers (18.0% baseline), window `[2024-06-17, 2025-06-17]`, complaint set `('bug', 'billing')`.

Findings are mapped back to the hypotheses in `plan.md`. A finding is **Directional** here if it points the right way relative to the confirm/refute criteria; final verdicts come in Deep Analysis and Synthesis.

---

## Finding 1 — H1 plan skew: free users complain ~2× Pro/Enterprise

- **Data:** `21_eda-complaint-rate-by-plan.csv` — free 28.0% (lift **1.56×**), enterprise 15.4% (0.85×), pro 13.6% (0.75×).
- **Chart:** `21_complaint-rate-by-plan.svg`.
- **Read:** The one plan with a complaint rate above the 1.3× confirm threshold is **free**. Enterprise and Pro are both below baseline. Pooled Paid (Enterprise + Pro = 22 complainers / 150 users = 14.7%) vs Free (28.0%) gives a **Free-vs-Paid lift of ~1.9×**, which is the real headline.
- **n check:** all three cells n≥30 (50 / 91 / 59) → H1-plan can be fully tested in Deep Analysis.
- **Status:** **Directional — supports H1 for `plan`, specifically driven by Free.**

## Finding 2 — H1 role skew: no signal

- **Data:** `22_eda-complaint-rate-by-role.csv` — admin 20.8% (1.16×), viewer 16.4% (0.91×), analyst 16.4% (0.91×).
- **Chart:** `22_complaint-rate-by-role.svg`.
- **Read:** Max lift is 1.16× (admin) — below the 1.3× confirm threshold, and the gap between admins and non-admins is ~4pp. All cells n≥30 so this isn't a power issue.
- **Status:** **Directional — points to refuting the `role` arm of H1.** Will re-check with Fisher's exact in Deep Analysis before finalizing.

## Finding 3 — H3 tenure: newest users complain most, oldest least (non-monotonic)

- **Data:** `23_eda-complaint-rate-by-tenure.csv` — tenure buckets at 2025-06-17: `<90d` 23.7% (1.32×), `90–180d` 15.3% (0.85×), `180–270d` 22.2% (1.23×), `270d+` 10.9% (0.60×).
- **Chart:** `23_complaint-rate-by-tenure.svg`.
- **Read:** `<90d` exceeds the 1.3× confirm threshold with n=59; `270d+` is clearly below baseline (0.60×). The 90–180d dip breaks a clean monotonic story but the endpoints still tell a consistent picture: recency → more complaints. Caveat on buckets `180–270d` (n=36) and `270d+` (n=46) — both over n≥30 but not large.
- **Design note:** tenure is measured at snapshot end, not window start, because 199 of 200 users were created **after** 2024-06-17 (window-start tenure has no variance) — documented in `23_eda-complaint-rate-by-tenure.sql`.
- **Status:** **Directional — supports H3.** Pattern is endpoint-driven, not monotonic.

## Finding 4 — Complaint category mix differs sharply by plan

- **Data:** `24_eda-category-mix-by-plan.csv`.
- **Chart:** `24_category-mix-by-plan.svg`.
- **Read:**
  - **Free (14 tickets):** 8 billing / 6 bug → **57% billing-heavy**.
  - **Enterprise (16 tickets):** 8 billing / 8 bug → even split.
  - **Pro (9 tickets):** 1 billing / 8 bug → **89% bug-dominant**.
- **Implication:** If H1 is confirmed, the *kind* of complaint also varies by plan — outreach content should differ (billing FAQs for Free, QA/build-quality messaging for Pro). Matches the prior account-level analysis's directional finding: Free = billing, Pro ≈ bug/feature. Small n means these mix percentages have wide CIs; treat as qualitative, not precise.
- **Status:** **Supporting context for H1.** Not a hypothesis by itself.

## Finding 5 — Monthly volume: May 2025 ticket spike reproduced

- **Data:** `25_eda-monthly-complaint-volume.csv`.
- **Chart:** `25_monthly-complaint-volume.svg`.
- **Read:** Total-ticket volume peaks at 21 in May 2025 (vs. mean of ~12 for the other full months). Complaint tickets peak at 9 in May — also the month's high, but the spike is larger in *all* tickets (the May bump is not driven only by complaints). Feature-request tickets jump from 2 in April to 8 in May and drive most of the spike. Prior analysis (`analyses/complainers-profile_2026-04-19_nimrod-fisher/`) flagged this spike as unexplained; we honor that scope boundary — not re-investigating the spike here.
- **Status:** **Out-of-scope context. Noted, not chased.**

## Finding 6 — Events-per-user distribution: right-skewed, median 8

- **Data:** `26_eda-events-per-user-distribution.csv`, `26b_eda-events-per-user-histogram.csv`.
- **Chart:** `26_events-per-user-histogram.svg`.
- **Read:** Median 8, mean 9.8, IQR [5, 11], range [1, 49], stdev 7.7. Right tail of 7 users with 31+ events, 5 with 21–30. Every user has ≥1 event. Bulk of users (84 of 200 = 42%) sit in the 6–10 bucket. Right-skew is expected for engagement distributions; no action needed.
- **Status:** **Descriptive.** Feeds the pre-complaint comparison in Finding 7.

## Finding 7 — H2 pre-complaint engagement: complainers ~1.67× non-complainers (but n=14)

- **Data:** `27_eda-pre-complaint-engagement.csv`.
- **Chart:** `27_pre-complaint-engagement.svg`.
- **Read:** Complainer users (n=14 with full 30-day coverage) — median 5 events, mean 4.86, IQR [2.25, 5.75]. Non-complainers (n=164, matched window 2025-05-06 → 2025-06-06) — median 3, mean 3.11, IQR [1, 4]. Median ratio **1.67×**, above the 1.3× threshold, and mean ratio 1.56×.
- **Critical caveat:** only 14 of 36 complainers have full 30-day pre-complaint event coverage (event data starts 2025-03-07; first-complaint dates < 2025-04-06 don't have 30 days of events before them). This is **below the n≥30 mitigation** agreed at Phase 2 QA close, so the result is **Suggestive, not Confirmed**.
- **Status:** **Directional — supports H2, insufficient power to confirm.** Deep Analysis should (a) consider a shorter lookback (e.g., 14 days) to increase n, (b) run Mann-Whitney U for distributional significance, (c) control for plan (Finding 8).

## Finding 8 — H2 × H1 confound: free users are both more engaged and more complaint-prone

- **Data:** `28_eda-events-per-user-by-plan.csv`.
- **Chart:** `28_events-by-plan.svg`.
- **Read:** Median events/user — free 10, pro 9, enterprise 7. Mean — free 11.9, pro 10.9, enterprise 8.0. Because free has both the highest complaint rate (Finding 1) *and* the highest engagement, any raw comparison of engagement between complainers and non-complainers without conditioning on plan will mix the two effects.
- **Implication:** In Deep Analysis, the pre-complaint-engagement test **must stratify by plan or include plan in a logistic regression**. Otherwise we can't distinguish "complainers are more engaged" from "free users are more engaged AND more complaint-prone".
- **Status:** **Confounder alert. Must be addressed in Phase 4.**

## Finding 9 — Industry spread is large (eCommerce/MarTech vs SaaS/FinTech)

- **Data:** `29_eda-complaint-rate-by-industry.csv`.
- **Chart:** `29_complaint-rate-by-industry.svg`.
- **Read:** Complaint rate ranges from **31.0%** (eCommerce, n=29, lift 1.72×) down to **6.5%** (SaaS, n=46, lift 0.36×). Four of seven industries are below n=30 (eCommerce 29, MarTech 29, EdTech 23, CyberSec 17, FinTech 28) — marked with striped bars in the chart.
- **Interpretation caveat:** Industry is an **account property**, not a user property. Users within the same account all share the same industry, so nominal user-level n is inflated by cluster correlation — the effective n is the number of distinct *accounts* per industry, which is much smaller. Plus, industry is likely correlated with plan and event-volume (selection effects).
- **Status:** **Exploratory — flag for Deep Analysis as a candidate control variable and as a secondary segmentation that needs account-level re-checking.**

---

## Summary Table — EDA → Hypotheses

| Hypothesis | Arm | EDA signal | Status going into Deep Analysis |
|---|---|---|---|
| H1 | plan (free vs paid) | lift 1.9× (free vs pro+ent) | **Directional-confirm** — test with chi-square/Fisher's |
| H1 | role | max lift 1.16× | **Directional-refute** — confirm with Fisher's |
| H2 | pre-complaint engagement | 1.67× median ratio, n=14 | **Directional-confirm, Suggestive** — need Mann-Whitney + plan-controlled logistic |
| H3 | tenure (at snapshot) | `<90d` 1.32×, `270d+` 0.60× | **Directional-confirm (endpoints)** — test with Fisher's trend |

## Surprises / Watch-items for Deep Analysis

1. **Confound between H1 (plan) and H2 (engagement)** — must control for plan when testing H2. Otherwise we risk double-counting the same effect.
2. **H3 is not monotonic** — endpoints differ but the middle dips. Check whether this is noise (small n in 180–270d) or a real stepped pattern.
3. **Industry spread is huge but probably account-driven** — re-check at account level in Phase 4 to decide whether "industry" should stand or be absorbed by plan/event-volume.
4. **H2 sample size is tight (n=14).** Deep Analysis should consider whether a 14-day pre-complaint window gives more complainers with coverage without sacrificing the "pre" semantics.

## Artifacts

- Queries: `queries/20_eda-*.sql` through `queries/29_eda-*.sql` (+ `26b`)
- CSVs: `results/eda/{20..29,26b}_eda-*.csv`
- Charts: `results/eda/{21..29}_*.svg` (9 charts, all with `viewBox` + `preserveAspectRatio="xMidYMid meet"`, titles ≤52 chars, mr≥80)
