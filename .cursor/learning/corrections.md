# Corrections

User feedback on agent behavior. Read at the start of every analysis. Applied as durable behavioral changes, not one-off adjustments.

## How to Use This File

**At start of analysis:** read every entry. Where a correction applies to the current phase, follow it.

**When a user corrects you:**
1. Acknowledge the correction in-conversation.
2. Immediately append an entry below.
3. Apply the correction for the rest of the analysis.

**Conflict handling:** if a new correction contradicts an existing one, surface the conflict to the user and ask which to keep.

## Entry Format

```markdown
## <YYYY-MM-DD> — <Short title>
- **Context:** <what phase / what the agent did>
- **Correction:** <what the user said to do differently>
- **Applies to:** hypothesis-framer / data-qa / eda / synthesis / validation / data-storytelling / all
```

---

## Entries

<!-- New entries added below this line, most recent first -->

## 2026-04-19 — Results per phase + CSVs per query + debug notebook + SVG viewBox
- **Context:** Workflow review after the complainers-profile analysis. All phase outputs were landing in a flat `results/` folder; no CSVs were saved from query returns; no end-to-end notebook shipped; chart titles and legend text were clipped in `report.html` and `summary.pdf` because SVGs had no `viewBox`.
- **Correction (4 parts, all non-negotiable for every analysis):**
  1. **Per-phase subfolders under `results/`** — `results/qa/`, `results/eda/`, `results/deep-analysis/`, `results/synthesis/`, `results/validation/`. Never flat. Each phase's md, charts, and CSVs live in its own folder.
  2. **CSV for every query return.** Every SQL query that returns rows must save a `.csv` whose filename exactly matches the `.sql` (e.g., `04_eda-engagement.sql` → `results/eda/04_eda-engagement.csv`). The debug notebook loads these — no DB re-query.
  3. **Debug notebook.** Every analysis ships `deliverables/notebook.ipynb`, a standalone walkthrough of the full flow (plan → QA → EDA → deep analysis → synthesis → validation → conclusions) that loads the saved CSVs with pandas and rebuilds charts. Spec and generation snippet: `.cursor/skills/_shared/references/debug-notebook.md`.
  4. **SVG charts must have `viewBox` + `preserveAspectRatio="xMidYMid meet"`**. Without a viewBox, CSS `width:100%` scales the frame but not the contents and right-edge text gets clipped in the HTML report and PDF. Also require `mr ≥ 80`, titles ≤ 52 chars (split into `<tspan>` lines otherwise), and `.card svg { max-width: 100%; }` in the report CSS.
- **Applies to:** all (data-qa, eda, deep-analysis, synthesis, validation, data-storytelling)

## 2026-04-19 — summary.pdf must be a real PDF, not an HTML file
- **Context:** Data Storytelling phase — summary was saved as `summary.pdf.html` instead of a real PDF.
- **Correction:** Always generate `summary.pdf` as a real binary PDF using headless Chrome: `chrome.exe --headless --disable-gpu --print-to-pdf="summary.pdf" --print-to-pdf-no-header "file:///tmp.html"`. Write the HTML to a temp file, render to PDF, then delete the temp file. Never name an HTML file `.pdf` or `.pdf.html`.
- **Applies to:** data-storytelling

## 2026-04-19 — Do not auto-advance through analysis phases
- **Context:** Phase 1 (hypothesis-framer) and Phase 2 (data-qa) were run back-to-back without stopping for user confirmation, because the user said "Run the analysis."
- **Correction:** "Run the analysis" at the start does NOT override per-phase checkpoints. After every phase, stop, summarize findings, link artifacts, and ask "Proceed to [next phase]?" — then wait for an explicit reply before continuing.
- **Applies to:** all
