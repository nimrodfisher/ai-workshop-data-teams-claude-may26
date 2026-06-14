---
name: data-qa
description: Validate data completeness, consistency, and coverage before analysis begins. Flags issues with severity ratings so the analyst knows what blocks analysis vs. what to note as a caveat. Use after hypothesis-framer, before EDA, at the start of every new analysis or whenever results look suspicious.
model: haiku
---

# Data QA

Wrong data beats missing data. This skill catches quality issues before they corrupt conclusions.

## Purpose

Validate data completeness, consistency, and coverage before any analysis begins. Flag issues with severity ratings so the analyst knows what blocks analysis vs. what to note as a caveat.

## When to Use

- Phase 2 of every analysis, after hypothesis framing.
- Any time a new table enters an analysis mid-flow.
- When results later look suspicious — come back here.

Always run QA on the *exact* tables and time window the hypotheses require. Don't QA more, don't QA less.

## Method

Run checks in this order. Stop and flag at any CRITICAL finding.

Use `scripts/qa_checks.sql` for the mechanical work: substitute the `{{placeholders}}`, run each block via Supabase, and save the instantiated queries to `queries/00_qa-<check>.sql` in the analysis workspace. Your job on top of the script is severity assignment, pattern interpretation, and mitigation guidance — the parts that need judgment.

### 1. Structural Integrity

- Row and column counts match expectations from the semantic model.
- Column names and types match `schema.yml`. Flag mismatches.
- No mixed types in a single column (numbers stored as strings, dates as strings, etc.).

### 2. Completeness

Count nulls per column. Apply severity:

- **CRITICAL:** >50% missing in a column needed for the analysis → column unusable.
- **HIGH:** 30-50% missing → imputation or exclusion required, document it.
- **MEDIUM:** 10-30% missing → handle during cleaning, note in caveats.
- **LOW:** <10% missing → standard handling.

Check for *patterns* in missingness — nulls correlated across columns often indicate systemic pipeline issues.

### 3. Uniqueness & Duplicates

- Exact row duplicates — percentage of total.
- Key columns (`id`, `user_id`, `order_id`, etc.) — should be unique. If not, CRITICAL.
- Entity-level duplicates (same user, different rows, same timestamp) — investigate.

### 4. Consistency

Logical checks on known-invalid patterns:

- Negative values in positive-only fields (price, quantity, age).
- Date logic: `end_date < start_date`, future dates where past-only expected.
- Status transitions that don't make sense (`cancelled` → `active`).
- Derived fields that don't match their sources (totals ≠ sum of line items).

### 5. Time Coverage

For time series data:

- Date range matches the analysis window.
- Gaps in the series (missing days, weeks). Quantify coverage %.
- Irregular intervals when regular expected.
- Timezone consistency (one of the most common silent corruptions).

### 6. Distribution Sanity

- Constant or near-constant columns (>95% same value) → flag; possibly unusable.
- Cardinality explosions (categorical column with thousands of values).
- Impossible values (age > 150, probability > 1, percentage > 100).

Full outlier hunting belongs in EDA, not here. At this stage, only flag values that are *definitionally* impossible.

### 7. Referential Integrity

When joining tables:

- Orphaned foreign keys (child rows with no parent).
- Join coverage (% of rows that match vs drop).
- Cardinality assumptions (is this really one-to-many, or did you get many-to-many?).

## Severity Summary

Each finding gets a severity:

- **CRITICAL** — analysis cannot proceed. Halt.
- **HIGH** — proceed only with explicit mitigation; document prominently.
- **MEDIUM** — proceed with a caveat in the final report.
- **LOW** — note; does not affect conclusions.

When uncertain about a severity call, see `references/severity-examples.md` for worked scenarios. The same percentage of nulls or duplicates can be CRITICAL or LOW depending on the analysis question — the examples illustrate that contextual judgment.

Compute an overall quality score:

- 90-100 → proceed normally.
- 70-89 → proceed with documented caveats.
- 50-69 → stop and clean, then re-check.
- <50 → data not analysis-ready. Escalate.

## Output

Save to `results/qa/` (create the subfolder if it doesn't exist):

- `qa-report.md` — findings with severity, affected tables/columns, counts, example rows, recommended action.
- `qa-summary.json` — structured version (score, counts by severity, blocking issues).
- `<query-prefix>.csv` — raw returned rows for **every** QA query that returns data. Filename matches the query file exactly (e.g., `00_qa-completeness.sql` → `00_qa-completeness.csv`).

Save instantiated QA queries to `queries/`, prefixed `00_qa-*` so they're clearly separate from analysis queries.

Append key findings to `.cursor/learning/known_issues.md` if they are **persistent** (not one-off glitches).

## Key Principles

- **Check first, analyze later.** Every suspicious result chased in EDA costs 10× the time a QA check would have.
- **Severity is contextual.** 15% nulls in a nullable text field is fine; 15% nulls in the date column blocks the analysis. See `references/severity-examples.md`.
- **Don't clean here.** QA flags issues. Cleaning decisions are taken with the user.
- **Log known issues.** The same data problem will show up in the next analysis. Make sure future-you knows.

## Checkpoint

When done:
1. Summarize: quality score, number of findings by severity, any blocking issues.
2. Link: paths to `qa-report.md` and `qa-summary.json`.
3. Surface: recommended mitigations (exclude a column, filter a date range, flag a caveat).
4. Ask: "Proceed to EDA?" — or if CRITICAL issues exist, "How should we handle [issue] before proceeding?"
5. Wait for explicit confirmation.

See `skills/_shared/references/checkpoint-protocol.md`.