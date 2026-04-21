# Analysis Plan

> Copy this folder to `analyses/<slug>_<YYYY-MM-DD>_<analyst-name>/` to start a new analysis.
> Fill in every section below as you progress through the skills.

---

## Results Folder Conventions (do not skip)

- **Per-phase subfolders** under `results/` — never a flat layout:
  - `results/qa/` — `qa-report.md`, `qa-summary.json`, one `.csv` per QA query
  - `results/eda/` — `eda-findings.md`, chart SVGs, one `.csv` per EDA query
  - `results/deep-analysis/` — `deep-analysis.md`, method charts, one `.csv` per DA query
  - `results/synthesis/` — `synthesis.md` (md only)
  - `results/validation/` — `validation.md`, any validation charts, one `.csv` per validation query
- **CSV for every query return.** Filename matches the `.sql` file exactly (e.g., `04_eda-engagement.sql` → `results/eda/04_eda-engagement.csv`).
- **Every SVG chart** must include `viewBox` + `preserveAspectRatio="xMidYMid meet"` so it scales without clipping in `report.html` and `summary.pdf`.
- **Final deliverables:** `deliverables/report.html`, `deliverables/summary.pdf`, `deliverables/notebook.ipynb` (standalone debug notebook — spec: `.cursor/skills/_shared/references/debug-notebook.md`).

---

## Meta

- **Analyst:** <name>
- **Date started:** <YYYY-MM-DD>
- **Slug:** <kebab-case-slug>
- **Status:** In Progress / Complete / On Hold

---

## Question

<One-sentence restatement of the business question. Confirm with the user before proceeding.>

## Decision This Supports

<What action depends on the answer. If none, flag to the user.>

---

## Hypotheses

*Filled during hypothesis-framer phase.*

- **H1 (primary):** <statement>
  - Confirms if: <specific criterion>
  - Refutes if: <specific criterion>
- **H2 (alternative):** <statement>
  - Confirms if: <criterion>
  - Refutes if: <criterion>
- **H0 (null):** <what "nothing's going on" looks like>

---

## Required Data

- **Tables:** <list from schema.yml>
- **Metrics:** <list with definitions cited from metrics.yml>
- **Time window:** <start — end>
- **Segments:** <list>

## Scope

- **In:** <list>
- **Out:** <list>

---

## Flow Diagram

*Required. Replace the placeholder below with the actual flow for this analysis.*

```mermaid
flowchart TD
    Q[Business Question] --> H[Hypotheses]
    H --> QA[Data QA]
    QA --> E[EDA]
    E --> S[Synthesis]
    S --> V[Validation]
    V --> D[Deliverables]

    H -.-> M[Metrics: from metrics.yml]
    QA -.-> T[Tables: from schema.yml]
    D --> R[report.html]
    D --> P[summary.pdf]
```

---

## Checkpoint Log

*Append an entry after each phase when the user confirms advancement.*

### Hypothesis Framed — <YYYY-MM-DD HH:MM>
- **Summary:** <what was decided>
- **Artifacts:** this plan.md
- **User decision:** Approved / Revised / Paused
- **Notes:** <any direction-changing notes>

### Data QA Complete — <YYYY-MM-DD HH:MM>
- **Summary:** quality score, findings by severity
- **Artifacts:** `results/qa/qa-report.md`, `results/qa/qa-summary.json`, `results/qa/*.csv`
- **User decision:**
- **Notes:**

### EDA Complete — <YYYY-MM-DD HH:MM>
- **Summary:** key findings
- **Artifacts:** `results/eda/eda-findings.md`, `results/eda/*.svg`, `results/eda/*.csv`
- **User decision:**
- **Notes:**

### Deep Analysis Complete — <YYYY-MM-DD HH:MM>
- **Summary:** quantified effects per hypothesis
- **Artifacts:** `results/deep-analysis/deep-analysis.md`, `results/deep-analysis/*.svg`, `results/deep-analysis/*.csv`
- **User decision:**
- **Notes:**

### Synthesis Drafted — <YYYY-MM-DD HH:MM>
- **Summary:** headline conclusion, evidence per hypothesis
- **Artifacts:** `results/synthesis/synthesis.md`
- **User decision:**
- **Notes:**

### Validation Complete — <YYYY-MM-DD HH:MM>
- **Summary:** which conclusions survived, which were narrowed
- **Artifacts:** `results/validation/validation.md`, `results/validation/*.csv`, revised `results/synthesis/synthesis.md`
- **User decision:**
- **Notes:**

### Deliverables Ready — <YYYY-MM-DD HH:MM>
- **Summary:** final answer, recommendations
- **Artifacts:** `deliverables/report.html`, `deliverables/summary.pdf`, `deliverables/notebook.ipynb`
- **User decision:** Accepted / Revised
- **Notes:**
