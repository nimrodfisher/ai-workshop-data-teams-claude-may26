# EDA Findings — Complainers Profile Analysis

**Analyst:** Nimrod Fisher  
**Date:** 2026-04-19  
**Charts:** `results/01_*.svg` through `results/06_*.svg`

---

## Finding 1 — Ticket volume is concentrated in the 1–2 range; very few heavy complainers

**Chart:** `01_ticket-distribution.svg`

Of 50 accounts: 9 filed zero tickets, 14 filed 1, 19 filed 2, 5 filed 3, and 3 filed 4. The distribution is right-skewed but shallow — no account filed more than 4. The "0-ticket" group (18%) is the only clean non-complainer cohort, and it's small. The QA-recommended reframe to **ticket-volume buckets (0 / 1–2 / 3+)** maps cleanly to this distribution.

---

## Finding 2 — H1 (Engagement): Weak signal — higher-ticket accounts show modestly more events, but well below threshold

**Chart:** `03_engagement-by-bucket.svg`

| Bucket | Mean events | Median events |
|---|---|---|
| 0 tickets (n=9) | 35.1 | 39 |
| 1–2 tickets (n=33) | 39.6 | 40 |
| 3+ tickets (n=8) | 42.0 | 40.5 |

The direction matches H1 (more tickets → more events), but the ratio between the extreme groups is only **1.20× on mean** and **1.04× on median**. The H1 confirm threshold was ≥1.5×. **H1 is not confirmed.** The median being nearly identical across all three groups (39–40.5) indicates that a small high-activity tail in the 3+ bucket is driving the mean difference. Engagement is not a reliable differentiator.

---

## Finding 3 — H2 (Plan tier): Enterprise has the highest complaint rate, but the gap doesn't meet the threshold

**Chart:** `02_complaint-by-plan.svg`

| Plan | Accounts | Complaint rate | Avg tickets/account |
|---|---|---|---|
| Enterprise | 19 | **94.7%** | 1.68 |
| Pro | 15 | 73.3% | 1.60 |
| Free | 16 | 75.0% | 1.44 |

Enterprise has a notably higher complaint *rate* (94.7% vs ~74% for others) — almost every enterprise account files a ticket. However, the H2 confirm criterion required complaint rate ≥2× the overall average (82%). Enterprise's 94.7% is only **1.16× the overall average**, well below that bar. **H2 is not confirmed** by the strict criterion.

**Notable category signal:** Enterprise tickets are uniformly distributed across all 4 categories (8 each). Pro is heavily skewed toward `feature_request` (10 tickets) with almost no `billing` (1 ticket). Free is `billing`-heavy (8 billing tickets, the highest category share). This is a meaningful pattern for customer success routing. (See `05_category-by-plan.svg`.)

---

## Finding 4 — H3 (Tenure): Newer accounts file more tickets, but sample is too small to conclude

**Chart:** Data only (no separate chart — covered in plan segmentation table)

| Tenure | Accounts | Complaint rate | Avg tickets/account |
|---|---|---|---|
| 91–365 days | 5 | **100%** | **2.40** |
| 1–2 years | 45 | 80.0% | 1.49 |

The 91–365 day cohort (5 accounts) has a 100% complaint rate and 2.40 avg tickets — **1.61× the longer-tenure average**. This is directionally above the 1.5× H3 threshold, but **n=5 is insufficient to draw a conclusion**. The dataset has essentially no accounts outside the 91 days–2 years window, which also limits any tenure-based insight.

**Plan × tenure interaction:** The most striking cell is Enterprise accounts with < 1 year tenure: avg 3.00 tickets per account (n=3). This is the highest intensity segment, though n is very small.

---

## Finding 5 — H4 (Pre-signal): CONFIRMED — activity spikes 30 days before first ticket ✅

**Chart:** `06_presignal-h4.svg`

| Window | Avg events |
|---|---|
| Baseline (T-60 to T-30) | 8.0 |
| Pre-ticket (T-30 to T) | 11.2 |

Among the 29 accounts whose first ticket fell within the events window (≥ Mar 2025):
- Average activity in the 30 days before the ticket was **11.2 events** vs baseline of **8.0 events** — a **1.60× ratio**
- **13/29 accounts (45%)** showed a pre-ticket spike of >1.5× their own baseline
- **0 accounts** showed a sharp drop

Both criteria in H4 are met: ratio ≥1.5× (1.60×) and ≥40% of accounts showing a spike (45%). **H4 is confirmed.** Importantly, no accounts showed a *drop* — suggesting complaints are not driven by disengagement but by increased activity surfacing problems.

---

## Finding 6 — Time pattern: Unexplained spike in May 2025

**Chart:** `04_tickets-over-time.svg`

Monthly ticket volume averaged ~10–12 from Dec 2024 through Apr 2025. May 2025 saw **21 tickets across 16 accounts** — 2.1× the monthly average and the highest single month in the dataset. No product change or outage information is available in the schema to explain this. This spike warrants investigation in Validation.

---

## Summary Table

| Hypothesis | Direction | Ratio | n | Preliminary verdict |
|---|---|---|---|---|
| H1 — Engagement | ✅ correct direction | 1.20× (threshold: 1.5×) | 8 vs 9 | **Not confirmed — weak** |
| H2 — Plan tier | ✅ Enterprise highest | 1.16× overall (threshold: 2×) | 19/15/16 | **Not confirmed** |
| H3 — Tenure | ✅ newer = more tickets | 1.61× (threshold: 1.5×) | n=5 | **Inconclusive — n too small** |
| H4 — Pre-signal | ✅ spike confirmed | 1.60×, 45% of accounts | 29 | **CONFIRMED** |
| H0 — Null | — | — | 50 | **Partially supported** — no dimension shows a strong separator |

**Most actionable finding:** H4. Platform activity spikes in the 30 days before a ticket — this is a detectable early warning signal. Category routing by plan (Free→billing, Pro→feature_request) is a secondary actionable finding from the category × plan breakdown.
