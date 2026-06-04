# Known Issues

Persistent data issues users have reported. Checked before every analysis so Data QA can factor them in and the final report can include appropriate caveats.

## How to Use This File

**At start of analysis:** read all **Open** and **Mitigated** entries. Factor them into the QA plan and into hypothesis scoping.

**When a user flags a data issue during an analysis:**
1. Confirm it's *persistent* (not a one-off glitch in a single run).
2. Append an entry below with status `Open`.
3. Note the issue in the current analysis's `plan.md` caveats.

**When an issue is fixed:** move the entry to the `## Resolved` section at the bottom and update status.

## Entry Format

```markdown
## <Table or Metric Name> — <Short issue title>
- **Reported:** <YYYY-MM-DD> by <user>
- **Issue:** <description>
- **Impact:** <what analyses it affects>
- **Workaround:** <if known>
- **Status:** Open / Mitigated / Resolved
```

---

## Open

<!-- Open issues — the agent must factor these into every relevant analysis -->

## events — Narrow coverage window (~90 days, not 365)
- **Reported:** 2026-04-20 by liati (surfaced in Phase 6 validation of complainer-user-profile analysis)
- **Issue:** The `events` table contains only data from **2025-03-07 to 2025-06-06** (92 days with events, 1,960 rows total). Despite analyses typically using 12-month windows aligned to the frozen snapshot ending ~2025-06-17, the event data is effectively a ~3-month slice. The last 11 days of the snapshot window (Jun 7–17) also have zero events.
- **Impact:** Any "pre-event window for user X" calculation breaks if the reference date is outside 2025-04-06 to 2025-06-06 (30-day pre-window) or 2025-03-21 to 2025-06-06 (14-day pre-window). Users whose reference date falls outside this coverage are assigned `0 events` by the data, not by behavior. In the complainer analysis, 22 of 36 complainers had their first complaint before 2025-04-06, making their pre-complaint event windows structurally zero. Any MWU, distribution, or zero-event-flag analysis that compares complainer pre-complaint events to non-complainer reference-date events is biased unless coverage is enforced at the user-filter level.
- **Workaround:**
  1. In QA, compute `MIN(occurred_at)` and `MAX(occurred_at)` on `events` and compare to the analysis window. Flag any user whose reference date is outside `[events_min + lookback_days, events_max]`.
  2. Restrict H2-style comparisons to the sub-population with valid coverage, or report the same summary stat (e.g., zero-event rate) for both groups using matched reference dates within the coverage window.
  3. For non-complainer reference date, pick a date inside the coverage window (e.g., 2025-05-06 midpoint), not the snapshot end.
- **Status:** Open

## Mann-Whitney rank-sum computation — tie handling bug
- **Reported:** 2026-04-20 by liati (self-surfaced during Phase 6 validation)
- **Issue:** SQL pattern `RANK() OVER (ORDER BY x)` followed by `AVG(rank_min) FILTER (WHERE x = val)` returns **min-rank** for tied values (because all tied rows share the same `RANK()` output, so `AVG(min_rank) = min_rank`). The correct Mann-Whitney rank for ties is the **average rank**: `(min_rank + max_rank) / 2`, where `max_rank = COUNT(*) WHERE x <= val` and `min_rank = COUNT(*) WHERE x < val + 1`. Using min-rank understates the rank sum of whichever group has more zeros and artificially inflates the MWU z-statistic.
- **Impact:** In the complainer-user-profile analysis, Phase 4 reported z = -4.05 (30d), -4.72 (14d), -3.83 (21d) based on min-rank; corrected avg-rank gives z = -1.93 (30d, borderline), +0.99 (14d, null in opposite direction), -0.42 (21d, null). The direction and strength of the H2 "disengagement" finding was driven by this bug, not by real signal.
- **Workaround:** Use `avg_rank = ((SELECT COUNT(*) FROM t WHERE t.x < me.x) + 1 + (SELECT COUNT(*) FROM t WHERE t.x <= me.x)) / 2.0` in a correlated subquery per row. Verified correct when total rank sum equals `n*(n+1)/2`.
- **Status:** Open — applies to any future MWU / Wilcoxon / rank-sum test done in SQL without a stats library.

## accounts.plan — Lowercase values, not title-case
- **Reported:** 2026-06-03 by nimrod-fisher (surfaced in QA phase of pro-plan-churn-drivers analysis)
- **Issue:** The `accounts.plan` column stores values as lowercase: `pro`, `free`, `enterprise`. Schema documentation and business context uses title-case (`Pro`, `Free`, `Enterprise`). Queries using `plan = 'Pro'` return zero rows.
- **Impact:** Any analysis filtering on `accounts.plan` must use lowercase values or `LOWER(plan) = 'pro'`.
- **Workaround:** Use `WHERE plan = 'pro'` (lowercase). Affects all analyses that segment by plan tier.
- **Status:** Open

## Mitigated

<!-- Issues with documented workarounds — still relevant to caveat in reports -->

## Resolved

<!-- Issues that have been fixed at the source — kept for historical context -->
