---
name: hypothesis-framer
description: Turn a vague business question into testable hypotheses with clear success criteria. Use at the start of every analysis, before any data is pulled. Produces the hypotheses, required metrics, scope, and decision this analysis supports — written into plan.md.
---

# Hypothesis Framer

Analyses fail more often from a bad question than from bad SQL. This skill forces clarity before a single query runs.

## Purpose

Turn a business question into a structured analysis plan: what we believe, what would confirm or refute it, what data we need, and what decision this enables.

## When to Use

Phase 1 of every analysis. Run this *before* loading data, *after* loading the semantic model.

## Method

### 1. Clarify the Question

Restate the user's question in one sentence. Confirm it back.

Ask (only if genuinely unclear):
- Who needs the answer and what decision does it drive?
- What timeframe matters?
- What population? (All users? A segment? A cohort?)

Do not ask more than 3 clarifying questions. If the question is reasonably clear, proceed and state your assumptions.

### 2. Identify the Decision

Every analysis should support a decision. Write it down:
- "Should we invest in feature X?"
- "Is our recent churn spike a real problem or noise?"
- "Which segment should we target for the next campaign?"

If there is no decision, the analysis is entertainment. Flag this to the user.

### 3. Decompose into Sub-Questions

Break the main question into 2-5 answerable sub-questions.

Example. Main question: "Why did churn spike in Q3?"
Sub-questions:
- Did the spike affect all segments equally, or is it concentrated?
- Did it start at a specific date? What else happened then?
- Did it affect new users, existing users, or both?
- Is the "spike" statistically distinguishable from normal variance?

### 4. Frame Hypotheses

For each sub-question, state a **testable hypothesis** — something that could be shown false by data.

Good: "Churn increased disproportionately in users on the legacy plan after the Sept 15 price change."
Bad: "Users are unhappy." (Not testable.)

Rate each hypothesis:
- **Primary** — the main bet
- **Alternative** — other plausible explanations you'll also check
- **Null** — the "nothing's really going on" case

Checking the null is not optional. It prevents confirming what isn't there.

### 5. Define Success Criteria

For each hypothesis, write what would **confirm** and what would **refute** it. Be specific about magnitude.

Example:
- Confirms: legacy-plan churn rate >1.5× non-legacy in Sept-Oct, with n>500 per group.
- Refutes: legacy-plan churn within ±10% of non-legacy churn.

This prevents post-hoc goalpost moving.

### 6. Identify Required Data

From the semantic model, list:
- Tables needed
- Metrics needed (cite their definitions from `metrics.yml`)
- Time window
- Segments / dimensions

If any required data isn't in the semantic model, flag it now. Don't wait until EDA.

### 7. Scope

State what's **out of scope** explicitly. Examples:
- "Not covering revenue impact — that's a follow-up."
- "Not covering acquisition channels — user requested churn-only focus."

Scope prevents drift.

## Output

Populate these sections of `plan.md`:

```markdown
## Question
<one-sentence restatement>

## Decision This Supports
<what action depends on the answer>

## Hypotheses
- **H1 (primary):** <statement> | Confirm if: <criterion> | Refute if: <criterion>
- **H2 (alternative):** ...
- **H0 (null):** <what "nothing to see here" looks like>

## Required Data
- Tables: <list>
- Metrics: <list, with definitions cited from metrics.yml>
- Window: <dates>
- Segments: <list>

## Scope
- In: <list>
- Out: <list>

## Flow Diagram
<Mermaid diagram — see template>
```

## Severity Ratings for Hypothesis Quality

Before checkpointing, rate the plan:

- **READY** — hypotheses testable, criteria specific, data available. Proceed.
- **NEEDS WORK** — hypotheses vague, criteria missing, data gaps. Revise before QA.
- **BLOCKED** — required data not in semantic model, or question isn't answerable with available data. Escalate to user.

## Key Principles

- **Testable, not aspirational.** If data can't falsify it, it's not a hypothesis.
- **Check the null.** Most spikes are noise. Prove it's signal first.
- **Write criteria before seeing data.** Prevents confirmation bias.
- **Scope hard.** An analysis that answers one question well beats one that gestures at five.

## Checkpoint

When done:
1. Summarize: question, decision, hypotheses, data needed, scope.
2. Link: path to the updated `plan.md` with diagram.
3. Surface: any data gaps, ambiguity, or items you scoped out.
4. Ask: "Proceed to Data QA?"
5. Wait for explicit confirmation.

See `skills/_shared/references/checkpoint-protocol.md`.
