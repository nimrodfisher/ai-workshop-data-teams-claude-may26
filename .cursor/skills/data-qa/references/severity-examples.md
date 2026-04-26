# Severity Examples

The data-qa skill states that "severity is contextual." This file shows that contextuality with worked scenarios — concrete situations paired with the severity call and the reasoning. Use these as anchors when you are uncertain how to rate a finding.

## Two questions to ask first

Before assigning severity, answer:

1. **Is the affected column central to the analysis?** A column the hypotheses depend on is treated more strictly than a column shown only in the final report.
2. **Does the issue prevent computation, distort it, or just need a caveat?** Prevent → CRITICAL. Distort → HIGH. Caveat → MEDIUM/LOW.

## Worked examples

### Completeness

**Scenario:** Churn analysis. `churn_date` column has 30% nulls.
**Severity:** CRITICAL.
**Why:** The target variable is unusable. Without churn dates, no churn analysis is possible.

**Scenario:** Churn analysis. `customer_email` has 30% nulls.
**Severity:** MEDIUM.
**Why:** Email is not part of the prediction. Note in caveats so anyone segmenting by communication channel knows the gap exists.

**Scenario:** Revenue forecast. `revenue` column has 5% nulls.
**Severity:** HIGH.
**Why:** Small percentage but it is the target variable. An explicit imputation or exclusion decision is needed before proceeding.

**Scenario:** Customer profiling. `secondary_address` has 95% nulls.
**Severity:** LOW.
**Why:** Optional field, expected to be sparse. Don't treat as a quality issue — note that segment-level work on this field is impossible.

### Duplicates

**Scenario:** Transactions table. 2% exact duplicates.
**Severity:** CRITICAL.
**Why:** Financial integrity. 2% double-counting changes revenue numbers. Halt and trace upstream before proceeding.

**Scenario:** Event log. 2% exact duplicates from a known at-least-once delivery system.
**Severity:** MEDIUM.
**Why:** Expected pattern; dedup with a hash key during cleaning. Document the dedup rule.

**Scenario:** Users table. `user_id` not unique.
**Severity:** CRITICAL.
**Why:** A primary key with duplicates breaks every join downstream. Fix the table or escalate before any analysis.

### Time coverage

**Scenario:** Two-year daily sales series. 3 missing days scattered across 2024.
**Severity:** LOW.
**Why:** <0.5% of the window, no clustering. Note in caveats.

**Scenario:** Two-year daily sales series. 3 missing days fall on the Black Friday weekend.
**Severity:** CRITICAL.
**Why:** Same row count as above, but the missing days are the days the analysis cares about. Coverage is contextual to the question.

**Scenario:** Year-over-year comparison. The current year ends mid-March, the comparison year is full.
**Severity:** HIGH.
**Why:** Possible to proceed with same-window comparison, but the user must explicitly choose between (a) compare Jan–March only or (b) wait for full data.

### Consistency

**Scenario:** Orders table has 12 rows where `delivered_at < ordered_at`.
**Severity:** HIGH.
**Why:** Definitionally impossible. Investigate root cause; if a known timezone-conversion bug, exclude affected rows and document.

**Scenario:** Sensor readings include 3 future-dated rows during the analysis window.
**Severity:** MEDIUM.
**Why:** Often a timezone or NTP-drift artifact. Investigate but unlikely to block analysis if scoped tightly.

### Distribution sanity

**Scenario:** `country` column is 99% "US" in a "global expansion" analysis.
**Severity:** CRITICAL.
**Why:** The analysis premise is wrong — the data is not actually global. Stop and clarify scope with the user.

**Scenario:** `is_active` column is 99% true in a churn analysis.
**Severity:** LOW.
**Why:** Expected — most users have not churned. Flag only that class imbalance exists for any modeling step.

### Referential integrity

**Scenario:** Orders table has 15% rows with no matching customer row.
**Severity:** CRITICAL.
**Why:** Either the join is wrong or 15% of orders are unattributable. Either way, blocks customer-level analysis until resolved.

**Scenario:** Web events table has 3% rows with no matching session.
**Severity:** MEDIUM.
**Why:** Common with cross-domain tracking. Filter out the orphans, document the rate, and proceed.

## Rules of thumb

- **The same percentage maps to different severities.** 5% nulls in a target column is not the same as 5% nulls in an optional notes column.
- **Cluster beats count.** 3 missing days at random < 3 missing days during the analysis's most important week.
- **Severity follows the question, not the column.** When the analysis question changes, re-rate the findings.
- **When unsure between two levels, pick the higher one and write the caveat.** Cheap to lower later, expensive to recover from a missed problem.
