---
name: deep-analysis
description: Drill into the hypotheses with targeted, rigorous methods — statistical tests, cohort/funnel analysis, driver decomposition, counterfactual reasoning — to quantify effects and isolate causes before drawing conclusions. Use after EDA, before Synthesis. EDA asks "what does the data look like?"; Deep Analysis asks "what is actually driving H1, and by how much?".
---

# Deep Analysis

EDA surfaces what's interesting. Deep Analysis tells you what's **real**, what's **big**, and what's **driven by what**.

## Purpose

Take the patterns EDA surfaced and subject them to rigorous, targeted analysis. Quantify effects, decompose drivers, apply formal tests where appropriate, and produce findings that are ready for synthesis — with magnitude and uncertainty, not just direction.

## When to Use

Phase 4 of every analysis. After EDA is complete and checkpointed, before synthesis.

Skip this phase only if EDA trivially answered the question (rare). Most of the time, EDA produces "there's a pattern here" and Deep Analysis is what turns that into "here's the effect, its size, and what's driving it."

## How Deep Analysis Differs From EDA

| EDA | Deep Analysis |
|---|---|
| Broad, exploratory | Targeted at specific hypotheses |
| Descriptive (distributions, relationships) | Inferential (tests, effect sizes, attribution) |
| "What patterns exist?" | "How big is the effect? What's driving it?" |
| Many charts, many dimensions | Fewer charts, deeper on each |
| Outputs: findings to explore | Outputs: quantified answers ready for synthesis |

If EDA is a wide-angle lens, Deep Analysis is a zoom.

## Method

Run the steps that apply to your hypotheses. Not every analysis needs every step.

### 1. Re-target on the Hypotheses

Open `plan.md`. Read H1, H2, H0 and their confirm/refute criteria.

For each hypothesis, decide:
- What quantity would confirm or refute it?
- What's the right method to measure that quantity?
- What level of precision does the decision require?

If EDA revealed the hypotheses were asking the wrong thing, go back to hypothesis-framer. Don't force a method onto a broken question.

### 2. Quantify the Effect

Translate findings from "direction" into "magnitude."

Not: "Churn went up in Q3."
But: "Churn rose from 2.1% to 6.4% in Sep-Oct — a 4.3pp absolute increase, 3.0× baseline."

Always report:
- **Point estimate** — the effect size in the native unit (pp, %, $, ratio)
- **Uncertainty** — confidence interval, standard error, or sensitivity range
- **Baseline comparison** — vs. prior period, vs. other segment, vs. expected

Effect size that is statistically significant but practically tiny is a footnote, not a finding. Size matters more than p-values outside academia.

### 3. Apply the Right Method

Pick based on the hypothesis, not on what's fancy:

- **Two-group comparison** (did A differ from B?) → t-test for means, proportion test for rates, chi-square for contingencies. Report effect size, not just p-value.
- **Cohort analysis** — when the question has a "since onboarding / since event" dimension. Fix the cohort; track behavior over lifetime.
- **Funnel analysis** — when the question is about conversion across stages. Per-step conversion, overall funnel rate, segment comparison.
- **Retention curves** — when the question is about engagement over time. Day-N retention, survival curves.
- **Regression** — when attributing effect to multiple covariates. Linear for continuous outcomes, logistic for binary. Check residuals.
- **Time-series decomposition** — when separating trend from seasonality from anomaly.
- **Counterfactual / synthetic baseline** — "what would the metric have been without X?" Compare observed to modeled expectation.

Document method choice in `deep-analysis.md` — why this method fits this hypothesis.

### 4. Decompose the Change

When a metric moves, it never moves uniformly. Break it down:

- **By segment** — which groups contributed most to the aggregate change?
- **By time** — did the shift happen gradually or at a specific point?
- **By driver** — if the metric is a composite (e.g., revenue = users × ARPU), which component changed?

Decomposition often reveals that the "aggregate change" is really one segment doing something different while others held steady. That's usually the actual finding.

### 5. Check Temporal Dynamics

- **When did it start?** Pinpoint the inflection to the day/week when possible.
- **How fast?** Sudden jumps vs. gradual drift point to different causes.
- **Is it still happening?** A one-time step change and an ongoing trend require different responses.
- **What else happened then?** Overlay with known events (launches, pricing changes, outages, seasonality).

### 6. Test Alternative Drivers

Before concluding "X drove the change":

- **Composition shift** — did the population itself change? Fix the cohort and re-check.
- **Seasonality** — is the pattern normal for this time of year? Compare year-over-year.
- **Confounded variable** — is another factor correlated with X that might be the real cause? Condition on it.

Full alternative-explanation testing is Phase 6 (Validation). Here, eliminate the obvious ones so the findings you hand to Synthesis are robust.

### 7. Quantify Uncertainty

Every headline number gets a range, not just a point estimate.

- Small sample → wider CI; say so prominently.
- Many subgroups → multiple comparisons; adjust or flag.
- Borderline effect → run the analysis two reasonable ways; report both.

A finding with honest uncertainty survives scrutiny. A point estimate with no CI falls apart on the first skeptical question.

## Output

Create `results/deep-analysis.md`:

```markdown
# Deep Analysis

## H1 — <statement>
- **Method:** <t-test / cohort / funnel / regression / ...>
- **Why this method:** <one sentence>
- **Effect:** <point estimate> [<95% CI or equivalent>]
- **Baseline comparison:** <vs prior period / vs other segment>
- **Decomposition:** <which segment / time / driver contributed most>
- **Temporal pattern:** <when it started, speed, ongoing?>
- **Alternatives ruled out here:** <composition / seasonality / ...>
- **Cited evidence:** <charts, tables>

## H2 — ...

## H0 — <null>
- <what would we expect if nothing were going on; does the data match?>

## Quantified Summary
- <one-line quantified answer per hypothesis>

## Caveats from This Phase
- <sample size limits, method assumptions, borderline decisions>
```

Save:
- Method-specific charts to `results/` (e.g., `07_cohort-retention.png`, `08_effect-decomposition.png`).
- All queries to `queries/`.

## What NOT to Do

- **Don't pick a method because it's sophisticated.** Simple comparisons beat fancy models when the question is simple.
- **Don't run every test you know.** Multiple testing inflates false positives. Test what the hypotheses require.
- **Don't bury uncertainty.** A wide CI is information, not a failure.
- **Don't conclude here.** That's Synthesis. Deep Analysis produces quantified findings; Synthesis judges what they mean for the hypotheses.

## Key Principles

- **Method follows hypothesis.** Pick the tool that answers the question, not the question that fits the tool.
- **Quantify, don't just observe.** Magnitude is the finding; direction alone is half the work.
- **Confidence intervals or nothing.** Point estimates without uncertainty are claims without evidence.
- **Decomposition is usually the real finding.** "The average went up" almost always means "one segment changed, others held steady."
- **Significance ≠ importance.** An effect can be statistically significant and practically trivial.

## Checkpoint

When done:
1. Summarize: quantified answer per hypothesis (effect, CI, direction), which drivers dominate, any alternatives already ruled out.
2. Link: `deep-analysis.md`, new charts, queries.
3. Surface: sample size concerns, method assumptions, borderline calls, anything that should limit the synthesis.
4. Ask: "Proceed to Synthesis?"
5. Wait for explicit confirmation.

See `skills/_shared/references/checkpoint-protocol.md`.
