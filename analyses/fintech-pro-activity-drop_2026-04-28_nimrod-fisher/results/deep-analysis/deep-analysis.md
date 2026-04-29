# Deep Analysis — FinTech Pro Activity Drop

**Date:** 2026-04-28  
**Analyst:** Nimrod Fisher  
**Phase:** 4 — Deep Analysis

---

## Executive Summary

The −29.7% drop in FinTech Pro activity is **real, FinTech-Pro-specific, and driven by two distinct root causes operating in parallel** across the two accounts. H0 (artifact) is definitively refuted. H4 (platform-wide) is definitively refuted. H3 (event-type shift) is confirmed with a critical per-account nuance. H1 and H2 require reinterpretation given n=2.

---

## H1 — Account Concentration

**Reframed as: which account drives more of the drop?**

| Account | Prior 30 | Last 30 | Abs Δ | % Δ | Share of Drop |
|---------|---------|---------|-------|-----|--------------|
| ZGarcia Corp | 15 | 8 | −7 | −46.7% | **63.6%** |
| PJohnson Corp | 22 | 18 | −4 | −18.2% | **36.4%** |

**Verdict:** ZGarcia drives nearly two-thirds of the aggregate drop. This is analogous to a concentrated-account pattern — the smaller, faster-declining account is the primary risk signal. Both accounts are declining, however, so this is not a single-account anomaly.

---

## H2 — User-Level Seat Churn

| Account | Role | Prior Active Users | Last Active Users | Total Users |
|---------|------|--------------------|-------------------|-------------|
| PJohnson Corp | admin | 1 | 1 | 1 |
| PJohnson Corp | analyst | 2 | 2 | 2 |
| ZGarcia Corp | admin | 2 | **0** | 2 |
| ZGarcia Corp | analyst | 3 | 3 | 3 |
| ZGarcia Corp | viewer | 0 | 1 | 1 |

**Critical nuance — H2 verdict is split:**

- **ZGarcia admins: fully churned** — both admins (Walt Smith, Eve Edwards) went completely dark in the last 30 days. This is the clearest seat-churn signal in the data.
- **ZGarcia analysts: still 3 active users** — all 3 analysts showed up at least once, but they each made *fewer* events (per EDA: 5→3, 5→3, 3→1). This is *intensity churn*, not *seat churn*.
- **PJohnson: no seat churn** — all roles stable (admin 1→1, analyst 2→2). Olivia Garcia dropped in activity but did not stop entirely.
- **New viewer in ZGarcia** — Walt Harris appeared for the first time. A low-engagement new user may be replacing (or masking) the departing admins.

**H2 verdict: Partial confirm for ZGarcia admins; refuted for analysts.** The H2 hypothesis as stated (analysts go quiet) is not supported at the seat-count level. The actual pattern is *admin abandonment* + *analyst intensity reduction*, which is a different (and arguably more serious) signal.

---

## H3 — Event-Type Shift (Confirmed — with per-account divergence)

### Aggregate (confirmed)
All of the drop is driven by logout (−60%), api_call (−63%), and login (−40%). report_view (+13%) and file_upload (+17%) grew. This is a **session-lifecycle + API-usage collapse** with sustained core-work activity.

### Per-account breakdown reveals two distinct patterns:

**PJohnson Corp — "Fewer sessions, deeper work"**

| Event Type | Prior | Last | Δ |
|-----------|-------|------|---|
| logout | 8 | 3 | −63% |
| file_upload | 5 | 5 | 0% |
| api_call | 4 | 3 | −25% |
| login | 3 | 2 | −33% |
| report_view | 2 | **5** | **+150%** |

- Sessions dropped sharply (logout −63%, login −33%)
- But `report_view` tripled and `file_upload` held
- **Interpretation:** PJohnson users are logging in *less often* but doing *more substantive work* per session. This could reflect workflow consolidation, fewer casual check-ins, or a single power user (Eve King, +100%) compensating.

**ZGarcia Corp — "API shutdown + broad decline"**

| Event Type | Prior | Last | Δ |
|-----------|-------|------|---|
| report_view | 6 | 4 | −33% |
| api_call | 4 | **0** | **−100%** |
| login | 2 | 1 | −50% |
| logout | 2 | 1 | −50% |
| file_upload | 1 | 2 | +100% |

- **api_call dropped to exactly zero** — a complete discontinuation, not gradual drift. This is a binary state change: ZGarcia stopped using Pulseboard's API entirely in the last 30-day period.
- All session events also declined
- file_upload slightly up (minor)
- **Interpretation:** ZGarcia likely discontinued an automated integration (api_call → 0) and shows broad disengagement across the account. Combined with admin silence, this looks like account-level pre-churn behavior.

---

## H4 — Platform Benchmark (STRONGLY REFUTED)

| Segment | Prior 30 | Last 30 | Change |
|---------|---------|---------|--------|
| **FinTech Pro** | 37 | 26 | **−29.7%** |
| All Others | 574 | 636 | **+10.8%** |

**The rest of the platform grew +10.8% in the same window.** FinTech Pro dropped −29.7%. The divergence is **40.5 percentage points**.

H4 is definitively refuted. This is not seasonality, not a platform-wide issue, and not a data artifact. The drop is **FinTech Pro-specific**.

---

## H0 — Measurement Artifact (DEFINITIVELY REFUTED)

| Window | Prior events | Last events | Change |
|--------|-------------|-------------|--------|
| Full 30 days | 37 | 26 | −29.7% |
| Trimmed 25 days (last 5 removed) | 32 | 23 | **−28.1%** |

Trimming the last 5 days of each window barely moves the result (−29.7% → −28.1%). The drop is not an end-of-window artifact. **H0 is refuted.**

---

## Hypothesis Verdicts

| Hypothesis | Verdict | Strength | Notes |
|-----------|---------|---------|-------|
| H0 — Measurement artifact | **Refuted** | Strong | −28.1% on trimmed windows; drop is behavioral |
| H1 — Concentrated account drop | **Partial confirm** | Moderate | ZGarcia 63.6% of drop; both accounts declining |
| H2 — Analyst seat churn | **Partial confirm** | Moderate | ZGarcia admin seat churn (2→0); analysts show intensity churn, not seat churn |
| H3 — Event-type shift | **Confirmed** | Strong | Two distinct sub-patterns: PJohnson = session thinning; ZGarcia = API shutdown + broad decline |
| H4 — Seasonality/platform | **Refuted** | Strong | Rest of platform grew +10.8%; 40.5pp divergence |

---

## Most Actionable Finding

**ZGarcia Corp is the primary risk:**
1. api_call → 0 (integration discontinued)
2. Both admins went dark (account management abandoned)
3. All 3 analysts reduced intensity
4. Accounts for 63.6% of the drop
5. Last event: May 27 — 10 days of silence before data cutoff

**Recommended action:** Immediate CS outreach to ZGarcia Corp. The admin silence + API shutdown pattern is a pre-churn signature that preceded full disengagement in prior analyses.

**PJohnson Corp is lower urgency but worth monitoring:**
- The drop is real (−18%) but core work metrics (report_view +150%) suggest the account is still engaged
- Olivia Garcia (top user) reduced activity but Eve King grew — internal team dynamics may be shifting

---

## Artifacts

- `06_da-concentration.csv`
- `07_da-seat-churn.csv`
- `08_da-platform-benchmark.csv` + `08_platform-benchmark.svg`
- `09_da-artifact-test.csv`
- `10_da-event-type-per-account.csv` + `10_event-type-per-account.svg`
