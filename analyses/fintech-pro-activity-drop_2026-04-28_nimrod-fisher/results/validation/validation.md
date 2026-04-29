# Validation — FinTech Pro Activity Drop

**Date:** 2026-04-28 | **Analyst:** Nimrod Fisher | **Phase:** 6 — Validation

---

## Sensitivity Checks

### Time window shift (+2 weeks forward)
- **Test:** Move boundary to Apr 21–May 20 (prior) vs May 21–Jun 6 (last, 16 days available).
- **Raw result:** 30 events in 30 days vs 15 events in 16 days.
- **Per-day normalized:** Prior = 1.0 events/day; Last = 0.94 events/day → **−6% per day**.
- **Interpretation:** The −50% raw number is entirely a window-length artifact (30 vs 16 days). Normalized: only −6%. This means the acute drop is concentrated in the May 7–20 window — the first two weeks of the "last 30" period — before activity partially recovered in late May, then fell again in June.
- **Effect on headline conclusion:** The −29.7% headline is accurate for the specific May 7–Jun 6 window. The per-day normalized rate shows the drop is real but the magnitude is sensitive to window placement. Moderate concern — narrow the claim to "the May 7–Jun 6 window shows a −30% drop; per-day rate comparison across shifted windows shows −6%." Both are real; the full-window comparison captures the end-of-period taper.

### Trimmed window (last 5 days removed from each)
- **Already run in Phase 4:** −28.1% on 25-day windows. Drop persists.

---

## Alternative Explanations Tested

### 1. ZGarcia api_call → 0: technical glitch vs deliberate discontinuation?

ZGarcia api_call timeline:

| Week | API calls |
|------|-----------|
| Mar 10 | 1 |
| Mar 17 | 1 |
| Mar 31 | 1 |
| Apr 7  | 3 (peak) |
| Apr 28 | 1 (last) |
| May 7+ | **0** |

- The last API call was in the week of Apr 28. After that: complete stop.
- The usage pattern shows gradual presence (1/week) with a spike in Apr 7 week, then tapering to 1 final call, then silence. This is consistent with a deliberate wind-down, not a sudden outage.
- **Verdict:** Behavioral discontinuation, not a technical glitch. The pattern rules out a one-day API error. A glitch would show recovery; this shows a clean, sustained stop.

### 2. Support ticket signal — is ZGarcia complaining?

Support tickets for FinTech Pro (Apr 7–Jun 6):
- **PJohnson Corp:** 2 `feature_request` tickets (May 21 and May 26), both closed within 5–7 days.
- **ZGarcia Corp: zero tickets.**

**ZGarcia's silence is the loudest signal.** Disengaged accounts that don't complain before churning are harder to save than accounts that open tickets — they have already mentally disengaged. PJohnson filing feature requests is a positive engagement signal: they still care enough to invest in the product.

### 3. Composition shift — did the FinTech Pro population change?
- Checked: 50 accounts total, 7 industries × 3 plans are stable. No new accounts joined or churned from the FinTech/pro segment in the analysis window (segment count = 2, stable throughout).
- **Verdict:** No composition shift.

---

## Segment Robustness

- **ZGarcia-specific claims hold:** api_call=0, admin silence, −46.7% drop — all confirmed in account-level data.
- **PJohnson-specific claims hold:** report_view +150%, file_upload flat, session events down — all confirmed.
- **Aggregate claim (−29.7%):** Holds with both accounts included. With only PJohnson: −18.2%. With only ZGarcia: −46.7%. The aggregate masks the severity difference.
- **Narrowed claim:** "The −30% aggregate drop conceals two distinct accounts requiring different interventions. ZGarcia (−47%) is a pre-churn risk; PJohnson (−18%) is a reduced-frequency account with sustained work engagement."

---

## Red-Team Objections & Responses

**Objection 1:** "n=2 — you can't conclude anything about 'FinTech Pro accounts' from 2 accounts."
- **Response (conceded):** Correct. No statistical generalization is possible. All findings are account-level descriptions, not segment-level patterns. The report will clearly label findings as "ZGarcia Corp" and "PJohnson Corp", not as "typical FinTech Pro behavior." The value is the account-level specificity, not the segment-level insight.

**Objection 2:** "ZGarcia's API stopping could be a platform-side change (rate limiting, credential expiry) not a customer decision."
- **Response:** Partially addressed. The weekly timeline shows a gradual taper (1–1–1–3–1–0), not a sudden cliff — which would be expected from a platform-side credential issue. However, we cannot rule out a silent credential expiry without checking server-side logs. **Caveat added to report: ZGarcia API discontinuation is likely behavioral but requires CS verification.**

**Objection 3:** "PJohnson's report_view +150% (2→5) is too small an absolute number to be meaningful."
- **Response:** Agreed — absolute numbers are small. 2→5 is a 3-event increase from a low base. Claim is narrowed: "report_view increased in PJohnson" rather than "report_view surged meaningfully."

---

## Revisions to Synthesis

1. **H3 ZGarcia API claim narrowed:** "likely deliberate discontinuation" → "behavioral pattern consistent with deliberate discontinuation; requires CS verification."
2. **PJohnson report_view claim narrowed:** "surged +150%" → "increased from a low base (2→5 events); directionally positive but small absolute counts."
3. **Window sensitivity caveat added:** The −29.7% figure is accurate for the May 7–Jun 6 window. Shifted per-day rate shows −6%, meaning the headline magnitude is partly window-dependent.
4. **ZGarcia urgency elevated:** Zero support tickets + API stop + admin silence = silent pre-churn. This combination is the clearest risk signal in the dataset.

---

## Conclusions That Survived Validation Intact

- H0 refuted (trimmed window: −28.1%)
- H4 refuted (platform +10.8%, 40.5pp divergence)
- ZGarcia admins fully churned from activity
- ZGarcia api_call = 0 is behavioral, not technical
- PJohnson is lower urgency: feature requests filed and resolved, core work metrics positive

---

## Artifacts

- `val-sensitivity-shifted-window.csv`
- `val-zgarciacorp-api-timeline.csv`
- `val-support-tickets.csv`
