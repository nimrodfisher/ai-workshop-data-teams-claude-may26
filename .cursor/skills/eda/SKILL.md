---
name: eda
description: Explore the data to understand its shape and surface patterns relevant to the hypotheses. Use after Data QA passes, before synthesis. Produces distributions, relationships, segmentation, and time patterns — all saved as charts and tables in the results folder.
---

# EDA

Exploration, not fishing. EDA answers the hypotheses' neighboring questions so synthesis has context, not just a number.

## Purpose

Explore the data systematically to understand distributions, relationships, segments, and time patterns that inform the hypotheses from Phase 1.

## When to Use

Phase 3 of every analysis. After Data QA passes (or proceeds with documented caveats), before synthesis.

## Method

Run in this order. Save each output to `results/` with a matching query in `queries/`.

### 1. Univariate Analysis

For each key metric in the hypotheses:

- **Distribution** — histogram or density plot. Is it normal, skewed, bimodal, zero-inflated?
- **Central tendency** — mean, median, mode. Large mean/median gap → skew, investigate.
- **Spread** — std dev, IQR, range.
- **Zero / null concentration** — often more informative than the rest.

Don't just run `describe()`. Look at the shape and write one sentence per metric about what you see.

### 2. Bivariate & Multivariate Relationships

For hypotheses that involve two or more variables:

- **Numeric × numeric** — scatter plot, correlation (Pearson for linear, Spearman for rank). Correlation ≠ causation; note this.
- **Numeric × categorical** — box plot, group means with CIs.
- **Categorical × categorical** — contingency table, chi-square if appropriate.

Focus on the relationships the hypotheses *predict*. Don't explore every pair — that's fishing.

### 3. Segmentation

Break the key metric down by dimensions that matter to the hypothesis:

- Plan / tier / pricing
- Acquisition channel / cohort
- Geography / device / platform
- Tenure buckets (new, established, long-tenure)

Look for:
- Segments where the metric is dramatically different.
- Simpson's paradox — aggregate trend reverses inside segments. Always check.
- Small-n segments that shouldn't drive conclusions.

### 4. Time Patterns

If the analysis has a time dimension:

- **Trend** — level over time, rolling averages.
- **Seasonality** — day-of-week, week-of-month, month-of-year effects.
- **Change points** — did something shift at a specific date? Overlay with known events (launches, price changes, outages).
- **Cohort behavior** — users acquired in different periods, tracked over lifetime.

### 5. Anomaly Context

QA flagged impossible values. EDA contextualizes *unusual* ones:

- Outliers in the business sense — a $1M order in a SaaS with $50 median ACV.
- Behavioral anomalies — a user with 10,000 events in an hour.
- Segments that behave qualitatively differently from others.

Decide per outlier: drop, cap, investigate, or keep-and-note. Document the decision.

## What Not to Do

- **Don't test every hypothesis here.** That's synthesis. Here you explore; there you conclude.
- **Don't run 50 correlations looking for significance.** Multiple testing will find spurious signal. Stick to what the hypotheses predicted.
- **Don't over-plot.** Every chart saved should earn its place by informing the hypothesis.

## Output

Save to `results/eda/` (create the subfolder if it doesn't exist):
- Charts as `.svg` (or `.png`) — numbered and named: `03_churn-distribution.svg`, `04_churn-by-plan.svg`. **Every SVG must include `viewBox="0 0 <w> <h>"` and `preserveAspectRatio="xMidYMid meet"`** so it scales without clipping in the HTML report and PDF.
- **One `.csv` per EDA query that returns data** — filename matches the query exactly (e.g., `04_eda-churn-by-plan.sql` → `04_eda-churn-by-plan.csv`). This is non-negotiable: the debug notebook reloads these CSVs instead of re-querying.
- `eda-findings.md` — narrative notes: one paragraph per major finding, linked to the chart that shows it.

Save all exploratory queries to `queries/`.

## Key Principles

- **Let the hypotheses lead.** Explore what the hypotheses predict, plus obvious adjacent checks (segmentation, time).
- **One chart, one insight.** If a chart doesn't clearly make a point, it's not ready.
- **Write as you go.** A paragraph summarizing each chart prevents "I'll remember what this meant" fatigue.
- **Watch for Simpson's paradox.** Aggregate patterns lie when segments differ.

## Checkpoint

When done:
1. Summarize: 3-5 key findings, one sentence each, tied to specific charts.
2. Link: `eda-findings.md`, key charts, underlying queries.
3. Surface: anything surprising, anything that might change the hypotheses, anything you couldn't explain.
4. Ask: "Proceed to Synthesis?"
5. Wait for explicit confirmation.

See `skills/_shared/references/checkpoint-protocol.md`.
