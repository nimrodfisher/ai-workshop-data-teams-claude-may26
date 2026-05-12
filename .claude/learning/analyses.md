# Analyses Log

Running index of every completed analysis in this repo. Checked at the start of each new analysis to avoid duplicate work and to surface prior findings on related questions.

## How to Use This File

**At start of new analysis:** scan for related questions, tags, or segments. If a similar question was answered recently, surface the prior work and ask the user whether to build on it or redo it.

**At end of analysis (data-storytelling phase):** append a new entry below.

## Entry Format

```markdown
## <YYYY-MM-DD> — <Analysis Title>
- **Path:** `analyses/<folder-name>/`
- **Question:** <one sentence>
- **Key finding:** <one or two sentences>
- **Confidence:** High / Medium / Low
- **Tags:** #tag1 #tag2
```

---

## Entries

<!-- New entries added below this line, most recent first -->

## 2026-04-28 — FinTech Pro Activity Drop
- **Path:** `analyses/fintech-pro-activity-drop_2026-04-28_nimrod-fisher/`
- **Question:** Why did paying FinTech Pro accounts in financial services show a ~30% drop in product activity in the most recent 30-day period vs. the prior 30 days?
- **Key finding:** Two accounts, two root causes. ZGarcia Corp (64% of drop, −47%): pre-churn signature — API integration stopped after Apr 28, both admins went dark, zero support tickets. PJohnson Corp (36%, −18%): session frequency reduced but report_view and file_upload held; feature requests filed and resolved. Platform grew +10.8% in the same window (40.5pp divergence), confirming segment-specific signal. Immediate CS outreach to ZGarcia required.
- **Confidence:** High for account-level descriptions; n=2 prevents segment generalization.
- **Tags:** #fintech-pro #activity-drop #pre-churn #api-discontinuation #seat-churn #platform-benchmark #event-type-shift

## 2026-04-20 — Complainer-User Profile (user-level)
- **Path:** `analyses/complainer-user-profile_2026-04-20_liati/`
- **Question:** What observable, measurable characteristics distinguish users who file complaint-like support tickets (bug/billing) from users who do not, to inform a proactive-outreach watch list?
- **Key finding:** Only `plan = 'free'` reliably distinguishes complainers (28% vs 14.7% paid, χ² p = 0.034, RR 1.91 [1.06, 3.44]). Role, tenure, and industry do not. H2 engagement was not testable — the `events` table covers only ~90 days of the 365-day analysis window. Recommended watch-list rule: `plan = 'free'` (precision 28%, recall 39%, lift 1.56×). Do not deploy event-based rules until coverage improves.
- **Confidence:** Moderate (H1-plan, narrowed to the 6-month period where complaints actually occur — 34 of 36 in 2024-12-17 → 2025-06-17); Inconclusive for engagement.
- **Tags:** #complainers #support-tickets #plan-tier #watch-list #user-level #event-coverage-gap #validation-corrections
- **Related:** supersedes the 2026-04-19 account-level analysis. Two new items added to `known_issues.md` (events narrow coverage, SQL MWU rank-tie bug). An earlier "disengagement" reframe claim was withdrawn during Phase 6 validation after uncovering the rank-sum bug and coverage gap — audit trail in `results/validation/validation.md`.

## 2026-04-19 — Complainers Profile Analysis
- **Path:** `analyses/complainers-profile_2026-04-19_nimrod-fisher/`
- **Question:** What characteristics distinguish accounts that open support tickets from those that do not?
- **Key finding:** Static profile (plan, tenure, engagement) does not reliably separate complainers from non-complainers — 82% of accounts file a ticket regardless. The only confirmed signal is behavioral: platform activity spikes 1.6× in the 30 days before a first ticket in 45% of Enterprise and Free accounts. Ticket category varies meaningfully by plan (Free = billing, Pro = feature_request, Enterprise = even). May 2025 spike (2.1× monthly avg) remains unexplained.
- **Confidence:** Medium (n=50 accounts; H4 pre-signal confirmed at Moderate strength)
- **Tags:** #complainers #support-tickets #pre-signal #plan-tier #engagement #early-warning
