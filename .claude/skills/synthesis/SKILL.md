---
name: synthesis
description: Turn EDA findings into conclusions that answer the original hypotheses. Use after EDA, before validation. Maps evidence to each hypothesis, rates evidence strength, identifies what's conclusive vs suggestive, and surfaces open questions.
---

# Synthesis

EDA produces findings. Synthesis produces **answers** — and admits what can't be answered yet.

## Purpose

Connect the EDA findings back to the hypotheses from Phase 1. For each hypothesis, say what the data supports, refutes, or leaves open, and how strong the evidence is.

## When to Use

Phase 4 of every analysis. After EDA is complete and checkpointed, before validation.

## Method

### 1. Re-read the Hypotheses

Open `plan.md`. Read the hypotheses and their confirm/refute criteria as written in Phase 1 — *before* you knew what the data would say.

This prevents post-hoc rationalization. The criteria are what they were, not what would make the story cleaner now.

### 2. Map Evidence to Each Hypothesis

For each hypothesis, list:

- **Supporting evidence** — findings from EDA that confirm it. Cite the chart or table.
- **Contradicting evidence** — findings that refute it.
- **Silent areas** — aspects the data didn't address.

Be honest. A hypothesis with both supporting and contradicting evidence is the norm, not an exception.

### 3. Rate Evidence Strength

For each hypothesis, rate the overall evidence:

- **Strong** — criterion clearly met, pattern is robust across segments and time, effect size meaningful.
- **Moderate** — criterion met in the aggregate but with caveats (small n in places, mixed segment behavior, borderline effect size).
- **Weak** — direction of effect matches but magnitude or consistency is lacking.
- **Inconclusive** — data doesn't allow a clean call either way.
- **Refuted** — criterion for refutation met.

### 4. Write the Answer

For each sub-question from Phase 1, write a direct answer in one or two sentences. If the answer is "we don't know," say that.

Example format:

> **Q:** Did the churn spike affect all segments equally?
> **A:** No. Churn tripled among legacy-plan users (from 2.1% to 6.4%) while non-legacy churn was flat (2.8% → 3.0%). **Evidence: strong.** (See chart `04_churn-by-plan.png`.)

### 5. Identify What Changed

Sometimes EDA surfaces a better framing of the original question. If so:

- State the new framing.
- Explain why it's a better question.
- Ask the user whether to re-scope (which sends you back to hypothesis-framer) or note it as a follow-up.

This is a checkpoint-worthy event. Don't just quietly change direction.

### 6. Open Questions

List what this analysis cannot answer with the current data:

- Questions needing data not in the semantic model.
- Questions needing a longer time window.
- Questions needing a different experimental design (A/B test, causal methods).

These become recommendations in the final deliverable.

## Output

Create `results/synthesis/synthesis.md` (create the `results/synthesis/` subfolder if it doesn't exist; synthesis produces no new queries, so no CSVs here):

```markdown
# Synthesis

## H1 — <statement>
- **Evidence:** Supporting / Contradicting / Silent
- **Strength:** Strong / Moderate / Weak / Inconclusive / Refuted
- **Answer:** <1-2 sentences>
- **Cited evidence:** <charts, tables>

## H2 — ...

## Overall Conclusion
<2-3 sentences answering the original question>

## What We Know vs What We Believe
- **Know (from data):** <list>
- **Believe (interpretation / context):** <list>

## Open Questions
- <list>

## Reframes (if any)
- <new framing and why>
```

## Key Principles

- **Answer the hypothesis you wrote, not the one you wish you'd written.**
- **"Strong" is rare.** Most real-world findings are Moderate. Don't inflate.
- **Separate what you know from what you believe.** Data shows patterns; interpretation is yours — label it.
- **A good "I don't know" beats a confident wrong answer.**

## Checkpoint

When done:
1. Summarize: headline conclusion, evidence rating per hypothesis, any reframes.
2. Link: path to `synthesis.md`, key supporting charts.
3. Surface: any tension in the evidence, any conclusions you're uncertain about, any reframes needing user input.
4. Ask: "Proceed to Validation?"
5. Wait for explicit confirmation.

See `skills/_shared/references/checkpoint-protocol.md`.
