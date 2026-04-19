---
name: validation
description: Stress-test the conclusions from Synthesis before they become a deliverable. Use after Synthesis, before Data Storytelling. Runs sensitivity checks, looks for confounders, tests alternative explanations, and red-teams the findings — so we catch issues before the audience does.
---

# Validation

The findings look clean. That's exactly when to be suspicious.

## Purpose

Stress-test the synthesis before turning it into a deliverable. Check sensitivity, consider alternative explanations, and try hard to break your own conclusions.

## When to Use

Phase 5 of every analysis. After synthesis is checkpointed, before storytelling.

Skipping this phase is the most common failure mode in AI-assisted analysis: the story is too clean because the system was never asked to challenge it.

## Method

### 1. Sensitivity Analysis

Change one assumption at a time. Re-check the conclusion.

- **Time window** — does the effect hold if you shift the window by ±2 weeks? If you extend it by a month?
- **Segment filter** — does the effect survive when you exclude the largest segment? The smallest?
- **Metric definition** — does switching a borderline definition (e.g., 30-day vs 28-day churn) flip the conclusion?
- **Outlier handling** — does the finding depend on keeping or dropping the top 1%?

A conclusion that depends on a single arbitrary choice is fragile. Say so.

### 2. Alternative Explanations

For each strong finding, list plausible alternatives and check them.

Common alternatives:
- **Composition shift** — the metric changed because the underlying population changed, not because behavior changed. Check with fixed-cohort views.
- **Seasonality confound** — the effect is real but expected for this time of year. Compare to same period last year.
- **Reporting / instrumentation change** — the data shifted because the pipeline shifted, not the world.
- **Simpson's paradox** — aggregate direction opposite to within-group direction.
- **Selection effect** — the population you measured isn't the population you think you measured.

Check at least 2-3 alternatives for the headline finding.

### 3. Segment Robustness

Does the conclusion hold across segments, or only in some?

- If only in some — narrow the claim to those segments.
- If in none but the aggregate — Simpson's paradox suspect, investigate.
- If in all — robust, state with confidence.

### 4. Replicate with a Different Angle

When possible, compute the same conclusion a different way:

- Different metric definition reaching the same phenomenon.
- Different grain (user-level vs event-level vs session-level).
- Different aggregation window.

If the angles agree, confidence goes up. If they disagree, figure out why.

### 5. Red-Team

Explicitly write: **"What would someone skeptical of this conclusion say?"**

List 2-3 specific objections. Address each with data or concede.

Good objections look like:
- "Your sample of 400 legacy users is too small to support 'Strong' evidence."
- "You're comparing Sept-Oct to Aug, but Aug always has anomalously low churn."
- "Your segment definition leaks — users can appear in both buckets."

### 6. Revise the Synthesis

If validation surfaced real issues, update `synthesis.md`:

- Lower the evidence rating where appropriate.
- Narrow claims to where they hold.
- Add caveats.
- If a conclusion flipped, rewrite it.

Do not bury the revision. Validation revealing an issue is a success, not a failure.

## Output

Create `results/validation.md`:

```markdown
# Validation

## Sensitivity Checks
- **Time window ±2 weeks:** <result>
- **Exclude largest segment:** <result>
- **Alternative metric definition:** <result>
- **Outlier handling:** <result>

## Alternative Explanations Tested
- **<Alternative 1>:** <how tested, what found>
- **<Alternative 2>:** ...

## Segment Robustness
- **Holds in:** <segments>
- **Does not hold in:** <segments>
- **Narrowed claim:** <if applicable>

## Replication
- **Alternate approach:** <description and agreement>

## Red-Team Objections & Responses
- **Objection:** <statement>
  - **Response:** <with data>

## Revisions to Synthesis
- <list of changes made>
```

## Key Principles

- **Try to break it.** Your job is not to confirm; it's to stress-test.
- **Composition shifts are the most common confounder.** Always check.
- **A narrowed claim is stronger than a broad one that's partly wrong.**
- **Document what you tested.** Stakeholders trust conclusions more when they see the skepticism behind them.

## Checkpoint

When done:
1. Summarize: which findings survived validation intact, which were narrowed, which were lowered in strength or withdrawn.
2. Link: `validation.md`, the (possibly revised) `synthesis.md`.
3. Surface: any conclusion you couldn't fully validate and why.
4. Ask: "Proceed to Data Storytelling?"
5. Wait for explicit confirmation.

See `skills/_shared/references/checkpoint-protocol.md`.
