# Data QA Report — Complainer-User Profile

- **Date:** 2026-04-20
- **Analyst:** liati
- **Scope:** `users`, `support_tickets`, `accounts`, `events`, `subscriptions`, `invoices`, `products` — the tables required by the plan.
- **Overall quality score:** **72 / 100** — data itself is structurally clean (no nulls, no duplicates, no orphans), but **three CRITICAL plan-fit issues** prevent running the analysis as currently specified. Resolve them before advancing.

---

## Summary Counts by Severity

| Severity | Count |
|----------|-------|
| CRITICAL | 3     |
| HIGH     | 1     |
| MEDIUM   | 0     |
| LOW      | 3     |

---

## CRITICAL Findings (block analysis; require user decision)

### C1. `support_tickets.category` — enum mismatch with plan definition

- **Documented values (schema.yml):** `billing`, `technical`, `feature_request`, `bug_report`, `general_inquiry`, `onboarding`.
- **Plan's complaint set:** `('bug_report', 'technical', 'billing')`.
- **Actual values in data** (see `06_qa-category-enum.csv`):

| category | ticket_count | pct | bucket |
|---|---|---|---|
| feature_request | 22 | 27.85% | non_complaint |
| bug | 22 | 27.85% | **UNDOCUMENTED (not in schema)** |
| usage_question | 18 | 22.78% | **UNDOCUMENTED (not in schema)** |
| billing | 17 | 21.52% | complaint |

- **Impact:** Under the plan's strict definition, only 17 of 79 tickets (16 users) qualify as complaints — 78% of the intended complaint pool is lost. `bug_report` and `technical` do not appear; the closest substitutes are `bug` (likely = `bug_report`) and `usage_question` (loose match for `technical`).
- **Proposed fix:** remap the complaint set to `('bug', 'usage_question', 'billing')` → 57 tickets, 50 unique complainer users (see `14_qa-complainers-by-category.csv` and `11_qa-population-sizes.csv`). Explicit user confirmation required because `usage_question` is a stretch — a user may prefer to drop it and run with `('bug', 'billing')` only (39 tickets, ~37 users).
- **Action:** user decision before Phase 3.

### C2. Time window outside actual data coverage

- **Plan window:** rolling 12 months → `[2025-04-20, 2026-04-20)`.
- **Actual max dates** (see `10_qa-time-coverage.csv`): `support_tickets.opened_at` = 2025-06-06, `events.occurred_at` = 2025-06-06, `users.created_at` = 2025-06-17. The dataset is a **static historical snapshot** ending mid-June 2025; today's date (2026-04-20) is disconnected from the data.
- **Impact:** only 31 of 79 tickets (39%) fall in the planned window; 48 tickets would be excluded. Engagement analysis has 1,009 of 1,960 events (51%) in-window.
- **Proposed fix:** shift window to the last 12 months of available data → **`[2024-06-17, 2025-06-17]`** (tickets: full 79; events: 1,960; users tenure computed relative to 2025-06-17). Alternative: tighter 6-month window `[2024-12-12, 2025-06-17]` matching the actual ticket date range — loses no tickets but halves the pre-complaint lookback runway.
- **Action:** user decision before Phase 3.

### C3. `invoices.paid_at` — all invoices paid (no variance for H4 billing arm)

- **Finding:** 0 of 300 invoices have `paid_at IS NULL` (see `05_qa-nulls-subs-invoices.csv`). Schema documents `paid_at` as nullable ("null if unpaid"); in this snapshot every invoice is marked paid.
- **Impact:** H4's "billing complaints concentrate in accounts with unpaid/late invoices (≥2× lift)" is **untestable** — there is no unpaid-invoice population to contrast. The same applies to any derived "account billing health" flag.
- **Proposed fix:** drop the H4 billing-arm; keep the H4 technical/bug arm (top-quartile event-volume → technical-complaint lift). Optionally substitute a proxy like "high invoice amount" (top-quartile `invoices.amount`) as a coarse billing-stress signal, but this weakens the hypothesis meaningfully — flag in `validation/` if used.
- **Action:** user decision before Phase 3. Candidate for `.cursor/learning/known_issues.md` if it recurs across datasets (pending user confirmation that this is persistent).

---

## HIGH Findings (proceed with explicit mitigation)

### H1. Sample size too small for the plan's `n≥100 per group` thresholds

- **Totals:** 200 users in population, **50 complainers** (remapped) vs **135 non-complainers** (see `11_qa-population-sizes.csv`).
- **Cell sizes:** 3 plans × 2 classes = 6 cells; 3 roles × 2 classes = 6 cells. Expected mean cell size ≈ 8–30, several cells likely below the chi-square expected-count threshold of 5.
- **Mitigation:**
  1. Replace chi-square with **Fisher's exact test** where any expected cell count <5.
  2. Relax "n≥100 per group" to **n≥30 per group** for go/no-go; otherwise mark as **Inconclusive**.
  3. Lower confirm thresholds from 1.5× to **1.3× lift + statistical significance** for H1/H3; keep H4 at 1.5×.
  4. Report all effect sizes with 95% confidence intervals; small n will produce wide CIs — a finding that passes a CI-based test is trustworthy, a point estimate alone is not.
- **Action:** fold these into the revised `plan.md` at the next checkpoint.

---

## LOW Findings (document, no action)

### L1. `accounts.plan` values are lowercase, not Title-case as in schema examples
- Actual: `enterprise`, `free`, `pro`. Schema shows `Free`, `Pro`, `Enterprise` as examples. Non-blocking — treated as free text per schema. Use case-insensitive comparisons downstream if ever needed.

### L2. `users.role` values do not match schema example exactly
- Actual: `admin` (72), `viewer` (67), `analyst` (61). Schema example said `admin, member, viewer` ("e.g."). Distribution is clean and well-balanced — use as-is.

### L3. `support_tickets.status` has two values only: `open`, `closed`
- Schema documents a wider enum (`open, in_progress, waiting_on_customer, resolved, closed, reopened`). Only `open`/`closed` appear here. Not needed by the plan — noted for completeness.

---

## Passed Checks

- **Row counts** (`00_qa-rowcounts.csv`): accounts=50, users=200, tickets=79, events=1960, subs=120, invoices=300, products=3. All consistent with a small teaching-dataset snapshot.
- **Nulls on key columns:** 0% across `support_tickets` (opened_by, category, opened_at, org_id, status), `users` (all columns), `accounts` (all columns), `events` (user_id, org_id, occurred_at, event_type), `subscriptions` (all key columns), `invoices` (issued_at, subscription_id). `opened_by` is schema-nullable but 0% null here — good for this analysis.
- **Primary-key uniqueness** (`12_qa-duplicates.csv`): 0 duplicates across all six tables.
- **Referential integrity** (`09_qa-join-coverage.csv`): 0 orphan users, 0 unresolvable tickets, 0 unresolvable events, 0 unresolvable invoices. Join coverage is perfect.
- **Events coverage:** 200/200 users have at least one event (distinct `user_id` in `events` = 200) — pre-complaint engagement analysis is feasible.

---

## Recommended Next Steps Before Phase 3 (EDA)

1. **User confirms C1 category remapping.** Strong recommendation: `('bug', 'usage_question', 'billing')`. Safer alternative: `('bug', 'billing')`.
2. **User confirms C2 time window.** Strong recommendation: `[2024-06-17, 2025-06-17]` (full 12-month coverage relative to snapshot max).
3. **User confirms C3 H4 scope reduction.** Drop the unpaid-invoice arm; keep the top-quartile-events arm.
4. Update `plan.md` hypothesis criteria to the HIGH-finding mitigations (Fisher's exact, n≥30, 1.3× lift thresholds, CI reporting).
5. Then proceed to EDA with revised scope.
