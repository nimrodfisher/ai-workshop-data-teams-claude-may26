# Validation — Pro Plan Churn Drivers (2025)

- **Analyst:** Nimrod Fisher · **Date:** 2026-06-16
- **Goal:** Try to break the synthesis before it becomes a deliverable. Net result: **no conclusion flipped; one important framing caveat added (churn is definition-sensitive); the cohort confound was tested and largely ruled out; H1 replicated at a second grain.**

## Sensitivity Checks

- **Churn definition (the big one):** The headline rate depends entirely on the chosen definition (`11_val-churn-definition.csv`):
  - **Logo churn (account fully left):** **7.7%** (1/13 accounts with subs) — or 6.7% of all 15 Pro accounts.
  - **Sub-level churn (canceled / active+canceled):** **21.9%** (7/32).
  - **Account-any-cancel:** **38.5%** (5/13).
  - The "~30%" cited for premium tiers is the *premium-tier subscription* rate, a conditional slice — not the Pro plan's overall churn. **Action:** the report must state the definition next to every rate. This does not change drivers, only the magnitude framing.
- **Including trialing:** trialing subs (n=2) were excluded from all rates by design; including them would only dilute denominators, not change direction.
- **Outlier handling:** no outliers dropped — the population is 34 subs; every row is kept and visible.
- **Active-tenure reference date:** rates/tenure use the frozen 2025-06-17 snapshot, not `CURRENT_DATE`; using today's date would inflate active tenure but not affect cancel rates.

## Alternative Explanations Tested

- **Newer-cohort confound (is $199 churn just a recency effect?):** Tested via `12_val-tier-cohort-confound.csv`. $199 subs have median age **156d** vs $79 **162d** and $29 **221d** — only modestly younger than $79, yet $199 churns *early* (median 24d) while $79 churns *late* (median 244d) at nearly identical cohort age. If recency were the driver, $79 and $199 would behave alike. They don't. **Confound largely ruled out** — the early-$199 pattern is price/value-specific, not an artifact of a young cohort.
- **Product effect, not price:** Already ruled out in QA — `product_id` carries no price signal (same product sold at $29/$79/$199), so the tier effect is a price effect.
- **Composition shift:** the population is a fixed, frozen snapshot of 15 accounts; there is no time-varying intake to shift. N/A.

## Segment Robustness

- **Holds in:** the $199 tier (early-life cancellation) and the entry-vs-paid split (price). Replicated at account grain (`13_val-replication-account-tier.csv`): accounts holding a $199 sub cancel **45.5%** (5/11) vs **0%** (0/2) without.
- **Does not hold / not testable in:** industry (1–3 accounts per vertical), engagement (only 4/7 cancels in event coverage), support (no separation).
- **Narrowed claim:** "Price drives churn" is narrowed to **"the $29 entry tier is churn-free; any paid-up subscription — especially a new $199 — is at risk."**

## Replication

- **H1 at a different grain:** account-level replication agrees with sub-level — only $199-holding accounts cancel. Direction consistent across grains → confidence holds at Moderate (still n-limited).

## Red-Team Objections & Responses

- **"Your '30% churn' is cherry-picked."** *Concede the framing:* 30.4% is the premium-tier subscription rate. Logo churn is 7.7% and zero in 2025. The report leads with the definition table so no single number stands alone.
- **"7 cancellations can't support any driver claim."** *Concede on significance:* Fisher p≈0.15; we label H1/H2 **Moderate** and never claim statistical significance. The claims are directional/descriptive over the full population, not inferential.
- **"$199 churns early just because those subs are newer."** *Rebutted with data:* $79 subs are the same age and churn late; recency doesn't explain the split (`12_val-tier-cohort-confound.csv`).
- **"Maybe rationalized accounts churn fully later — your 0 exits is premature."** *Partial concede:* true, the snapshot can't see beyond 2025-06-17; durability of the 0-exit finding is an open question, flagged in synthesis.

## Data Oddity Noted

- **2 of 15 Pro accounts have no subscription rows at all.** Not a churn signal (they never had a sub to cancel) but worth flagging as a data-completeness curiosity; it makes the account-level denominator 13, not 15. Carried as a report caveat.

## Revisions to Synthesis

1. Added explicit **churn-definition table** requirement — every rate must name its definition (logo 7.7% / sub 21.9% / account 38.5% / premium-sub 30.4%).
2. Recorded the **cohort confound as tested and rejected** (strengthens H1/H2 from "direction only" toward "direction, confound-checked").
3. Added the **2 subless accounts** caveat.
4. No strength ratings changed: H1 Moderate, H2 Moderate, H3 Refuted/Inconclusive, H4 Null, H0 Strong — all survived.
