# Synthesis — FinTech Pro Activity Drop

**Date:** 2026-04-28 | **Analyst:** Nimrod Fisher | **Phase:** 5 — Synthesis

---

## Overall Conclusion

The −29.7% drop in FinTech Pro product activity is **real, FinTech-Pro-specific, and caused by two distinct account-level stories running in parallel.** ZGarcia Corp discontinued its API integration and both admins went dark — a pre-churn signature. PJohnson Corp shows reduced session frequency but sustained (and growing) core work. The platform-wide trend is healthy (+10.8%), which makes the FinTech Pro divergence unambiguous.

---

## H0 — Measurement Artifact

- **Evidence:** Trimmed 25-day windows (removing last 5 days): −28.1% vs −29.7% full. Drop persists unchanged. Zero-event tail (Jun 7–17) falls outside both comparison windows.
- **Strength: Refuted (Strong)**
- **Answer:** The drop is not an artifact. Restricting both windows eliminates at most 1.6pp of the gap. The effect is behavioral.
- **Cited evidence:** `09_da-artifact-test.csv`

---

## H1 — Concentrated Account Drop

- **Supporting evidence:** ZGarcia Corp drives 63.6% of the absolute drop (−7 of −11 events). One account is meaningfully larger contributor than the other.
- **Contradicting evidence:** Both accounts are declining — this is not a single-outlier event. PJohnson contributes 36.4% of the drop independently.
- **Silent areas:** With n=2, "top 20% drives >60% of drop" criterion is trivially met — the criterion was designed for a population; it cannot be interpreted as a Pareto pattern here.
- **Strength: Moderate** — ZGarcia is the primary risk account, but both accounts require attention.
- **Answer:** ZGarcia Corp accounts for 64% of the decline. Both accounts are declining, so this is not a single-account anomaly — it's a segment-wide signal with unequal severity.
- **Cited evidence:** `06_da-concentration.csv`

---

## H2 — User-Level Seat Churn

- **Supporting evidence:** ZGarcia's two admins went fully dark (2→0 active users). This is complete admin seat churn. One new viewer appeared, possibly replacing a churning user.
- **Contradicting evidence:** ZGarcia's 3 analysts are still active (3→3 distinct active users). PJohnson shows no seat churn at all — all roles stable.
- **Refined finding:** The actual pattern is **admin abandonment + analyst intensity reduction** in ZGarcia. Analysts are attending but less frequently; admins have stopped entirely.
- **Strength: Moderate (ZGarcia admins only)** — H2 as written (analyst roles go quiet) is not supported. Admin silence is a stronger pre-churn signal than analyst intensity drop.
- **Answer:** H2 is partially confirmed with an important reframe — it's *admin* seat churn in ZGarcia, not analyst seat churn. ZGarcia admins (account decision-makers) have disengaged, which is more alarming than analyst frequency decline.
- **Cited evidence:** `07_da-seat-churn.csv`, `05_eda-account-user-distributions.csv`

---

## H3 — Feature/Event-Type Shift

- **Supporting evidence (aggregate):** login (−40%), logout (−60%), api_call (−63%) all declined sharply. report_view (+13%) and file_upload (+17%) grew. Aggregate drop is entirely driven by session-lifecycle + API events.
- **Per-account nuance (critical):**
  - **PJohnson:** `logout` −63%, `report_view` +150%, `file_upload` 0%. Pattern = fewer sessions, deeper work per session.
  - **ZGarcia:** `api_call` 4→**0** (−100%), full stop. `report_view` −33%. Broad decline across all session events. Pattern = API integration discontinued + general disengagement.
- **Strength: Strong** — criterion met (≥1 event type >40% drop while others flat or growing). Two distinct mechanistic sub-patterns identified.
- **Answer:** Confirmed. The drop is concentrated in session-lifecycle events (login/logout) and API calls. Crucially, the mechanisms differ by account: PJohnson is logging in less but working harder; ZGarcia discontinued its API integration entirely and is broadly disengaged.
- **Cited evidence:** `04_eda-event-type-breakdown.csv`, `10_da-event-type-per-account.csv`

---

## H4 — Seasonality/External Platform Trend

- **Evidence:** All Other accounts: +10.8% in the same window (574→636 events). FinTech Pro: −29.7%. Divergence: 40.5 percentage points. The platform is healthy.
- **Strength: Refuted (Strong)** — the platform-wide benchmark is not just flat; it grew. There is no seasonal or external explanation consistent with the FinTech Pro drop.
- **Answer:** Definitively refuted. The rest of the platform grew +10.8% in the same period. This is a FinTech Pro-specific event, not a platform or seasonal trend.
- **Cited evidence:** `08_da-platform-benchmark.csv`

---

## What We Know vs What We Believe

**Know (from data):**
- FinTech Pro event count fell from 37 to 26 (−29.7%) on matched 30-day windows.
- ZGarcia Corp's api_call events went to exactly 0 in the last 30 days.
- ZGarcia Corp's 2 admins made zero events in the last 30 days.
- PJohnson Corp's report_view events tripled (2→5) in the last 30 days.
- The rest of the platform grew +10.8% in the same window.
- The drop persists on trimmed windows (−28.1%) — not an artifact.

**Believe (interpretation / context):**
- ZGarcia's api_call=0 likely reflects a deliberate API integration discontinuation, not a technical glitch.
- ZGarcia's admin silence + API shutdown is consistent with an account in pre-churn disengagement.
- PJohnson's session thinning + deeper work per session could reflect team consolidation (e.g., one analyst taking lead, others stepping back).
- The new viewer in ZGarcia may signal a role shift — someone consuming dashboards where before analysts were building them.

---

## Open Questions

1. **Why did ZGarcia's API stop?** Was it a deliberate technical decision? A key person leaving? A billing or permissions issue? This requires a CS call.
2. **Olivia Garcia (PJohnson, top analyst, −46%)** — did she change role, team, or usage pattern? Outreach warranted.
3. **Is there a support ticket for ZGarcia's API discontinuation?** Not yet checked — validation will test this.
4. **How long has ZGarcia been a customer?** Account tenure could indicate risk level at renewal.
5. **Are these accounts on annual contracts?** If so, when do they renew? That determines urgency of outreach.

---

## Reframes

**Original question:** "Why did FinTech Pro accounts show a ~30% drop?"

**Better framing:** "Two FinTech Pro accounts are disengaging for different reasons. ZGarcia shows a pre-churn signature (API shutdown + admin silence); PJohnson shows reduced visit frequency but sustained work engagement. What is the appropriate intervention for each?"

This reframe is important for CS: a single "reach out to FinTech Pro" action misses that the two accounts need different conversations.
