---
name: data-storytelling
description: Turn validated findings into the final deliverables — an interactive HTML report and a PDF executive summary. Use as the final phase of every analysis, after validation. Structures the story for a decision-maker, not an analyst.
---

# Data Storytelling

The analysis is done. Now make someone care, understand, and decide.

## Purpose

Convert validated findings into two deliverables:
- **`report.html`** — interactive, evidence-rich, for the reader who wants to dig in.
- **`summary.pdf`** — one-to-two pages, for the reader who has 90 seconds.

Both tell the same story with different depth.

## When to Use

Phase 6 of every analysis. After validation is checkpointed. Only.

## The Story Structure

Every deliverable follows this order:

1. **Question** — what was asked, in the reader's language.
2. **Answer** — headline finding, one sentence, up front.
3. **Why it matters** — the decision this enables.
4. **Evidence** — 2-4 findings with charts, each tied to a hypothesis.
5. **Caveats** — what we don't know, what validation narrowed.
6. **Recommendations** — what to do next. Concrete, not vague.
7. **Appendix** — methodology, queries, full QA notes (HTML only).

The answer goes first. Analysts bury it; decision-makers want it at the top.

## Writing Principles

- **Write for the decision-maker.** They are busy, smart, and not an analyst.
- **One chart, one point.** If a chart needs a paragraph to explain, remake it or drop it.
- **Numbers in context.** "Churn rose to 6.4%" is less useful than "Churn rose to 6.4%, 2× the normal range."
- **Show the size.** Effect size matters more than statistical significance outside academia.
- **Own the uncertainty.** Don't hide it in small type — call it out. Trust compounds.
- **Action > observation.** Close with recommendations, not a summary.

## The HTML Report

Use a static HTML file with embedded interactivity — no backend.

Structure:

```
report.html
├── Hero — question, headline answer, date, analyst
├── Key findings (2-4 cards)
│   └── each: chart + 1-2 sentence interpretation
├── Deeper dive (collapsible sections)
├── Caveats & limitations
├── Recommendations
└── Appendix (methodology, hypotheses, queries)
```

Technical notes:
- Single file. Embed charts as interactive (Plotly or Chart.js) or as PNGs from `results/`.
- Responsive; readable on a laptop.
- No external network dependencies — the file should work offline.
- Keep under 5MB; compress images.

## The PDF Summary

One page preferred, two pages maximum.

Structure:

```
Page 1
├── Title + date + analyst
├── Headline answer (2-3 sentences, prominent)
├── 2-3 supporting findings (small chart + 1 sentence each)
└── Recommendations (bullets)

Page 2 (if needed)
├── Caveats
└── What we couldn't answer / follow-ups
```

Generate from markdown using a tool like `pandoc`, or render the HTML hero + key findings to PDF directly.

## What to Leave Out

- Internal process details (which skills you ran, which checkpoints happened).
- Every chart you made — only the ones that earn their place.
- Methodology walk-throughs — that's the appendix.
- Hedging language for its own sake. Say what you mean, label uncertainty explicitly.

## Output

Save to `deliverables/`:

- `report.html`
- `summary.pdf`

Both should be standalone — sendable via email, viewable without this repo.

## After Delivery — Update Learning

Once the user sees the deliverables:

1. Append to `.cursor/learning/analyses.md` — entry per the format in `learning-system.md`.
2. If the user gave behavioral feedback during this analysis → append to `corrections.md`.
3. If the user noted data issues → append to `known_issues.md`.

This is not optional. The repo gets smarter only if you write this down.

## Key Principles

- **Answer first.** Then evidence.
- **The decision-maker is the audience.** Everything else is appendix.
- **Charts earn their place.** No chart for its own sake.
- **Own the uncertainty.** Hedging destroys trust; honest caveats build it.
- **Recommendations close the loop.** An analysis without "now what" is incomplete.

## Checkpoint

When done:
1. Summarize: the headline finding and the key recommendations.
2. Link: `deliverables/report.html`, `deliverables/summary.pdf`.
3. Surface: any limitation the reader needs to know about.
4. Confirm: the learning files have been updated.
5. Deliver: "Analysis complete. Deliverables are in `deliverables/`. Anything to revise before close-out?"

This is the final checkpoint of the analysis. After this, the analysis folder is frozen.

See `skills/_shared/references/checkpoint-protocol.md`.
