# EDA Findings — FinTech Pro Activity Drop

**Date:** 2026-04-28  
**Analyst:** Nimrod Fisher  
**Phase:** 3 — EDA

---

## Summary

The ~30% drop in FinTech Pro activity is **real, behavioral, and concentrated in session-lifecycle events** — not in the core work events (report viewing and file uploads, which actually grew). The drop is driven more strongly by ZGarcia Corp, and within ZGarcia, by a coordinated decline across all analyst users plus both admins going fully silent.

---

## Finding 1 — Weekly trend: late-period taper in last 30 days

| Week | Events | Active Users |
|------|--------|-------------|
| Apr 7  | 8  | 5 |
| Apr 14 | 10 | 4 |
| Apr 21 | 9  | 5 |
| Apr 28 | 8  | 5 |
| May 5  | 6  | 5 |
| May 12 | 6  | 4 |
| May 19 | **9** | **6** |
| May 26 | 4  | 3 |
| Jun 2  | 3  | 2 |

- The prior-30 period is **broadly stable** (8–10 events/week).
- The last-30 period shows a mid-period **spike** (May 19 week: 9 events, 6 users — the largest week) followed by a **sharp taper** in the final two weeks (4, 3).
- The overall last-30 average is lower (26 vs 37), but the drop is not a straight-line decline — it's a spike then fall.

**Implication:** The last 2 weeks of May/June carry most of the drag. This is consistent with ZGarcia Corp's last event on May 27 and silence in June.

---

## Finding 2 — Event-type split: SPLIT pattern (H3 pre-signal confirmed)

| Event Type | Prior 30 | Last 30 | Change |
|------------|---------|---------|--------|
| logout     | 10      | 4       | **−60%** |
| api_call   | 8       | 3       | **−63%** |
| report_view| 8       | 9       | +13%  |
| file_upload| 6       | 7       | +17%  |
| login      | 5       | 3       | −40%  |

**Key pattern:** Core *work* events (report_view, file_upload) held or grew. Session *lifecycle* events (login, logout) and API calls dropped sharply.

Two interpretations:
1. Users who *do* log in are doing *more* substantive work per session — but fewer sessions are happening.
2. Alternatively: some users stopped logging in entirely (reducing login/logout counts) while remaining active users increased their work intensity.

The user-level data (Finding 3) strongly supports interpretation 2.

**Implication for H3:** Confirms the hypothesis — the drop is concentrated in specific event types (login, logout, api_call), not broad-based across all event types.

---

## Finding 3 — User-level: analyst decline in ZGarcia; mixed in PJohnson

### PJohnson Corp (22 → 18, −18%)

| User | Role | Prior 30 | Last 30 | Change |
|------|------|---------|---------|--------|
| Olivia Garcia | analyst | 13 | 7  | −46% |
| Karen Young   | admin   | 6  | 5  | −17% |
| Eve King      | analyst | 3  | 6  | +100% |

- PJohnson's drop is **entirely attributable to Olivia Garcia** (-6 events). She accounts for 100% of PJohnson's net decline.
- Eve King (analyst) **offset** some of the loss (+3). The account's team-level activity is partially rebalancing.
- Karen Young (admin) shows stable activity — account management is unaffected.

### ZGarcia Corp (15 → 8, −47%)

| User | Role | Prior 30 | Last 30 | Change |
|------|------|---------|---------|--------|
| Ned Quinn       | analyst | 5 | 3 | −40% |
| Quinn Zimmerman | analyst | 5 | 3 | −40% |
| Walt Lopez      | analyst | 3 | 1 | −67% |
| Walt Smith      | admin   | 1 | 0 | −100% |
| Eve Edwards     | admin   | 1 | 0 | −100% |
| Walt Harris     | viewer  | 0 | 1 | +1 (new) |

- **All 3 analysts declined.** Broad-based analyst disengagement, not a single-user event.
- **Both admins went completely silent.** Admin silence in addition to analyst decline is a stronger signal than analyst-only decline.
- One viewer appeared for the first time (Walt Harris) — a new low-engagement user may have replaced a churned analyst.

**Implication for H2:** ZGarcia shows H2 pattern (seat churn) — analyst role users declining while a viewer appeared. PJohnson shows a partial H2 pattern (one analyst declined, one grew).

---

## Pre-signal on hypotheses heading into Deep Analysis

| Hypothesis | EDA signal | Strength |
|-----------|-----------|---------|
| H0 — Measurement artifact | Refuted — drop is behavioral, not coverage | Strong refute |
| H1 — Concentrated account drop | ZGarcia drives 64% of the net drop (−7 of −11) | Moderate confirm |
| H2 — Seat churn (analyst role) | ZGarcia: all analysts down + admins dark; PJohnson: 1 analyst down | Moderate confirm |
| H3 — Event-type shift | login/logout/api_call down 40–63%; report_view/file_upload up | Strong confirm |
| H4 — Seasonality/platform | Not yet tested (needs non-FinTech-Pro benchmark) | Pending |

---

## Artifacts

- `03_eda-activity-timeseries.csv` + `03_activity-timeseries.svg`
- `04_eda-event-type-breakdown.csv` + `04_event-type-breakdown.svg`
- `05_eda-account-user-distributions.csv` + `05_user-activity-heatmap.svg`
