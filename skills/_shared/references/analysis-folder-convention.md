# Analysis Folder Convention

Every analysis lives in its own folder under `analyses/`. Consistent structure makes past work discoverable and reviewable.

## Folder Name

Format: `<slug>_<YYYY-MM-DD>_<analyst-name>`

- **slug** — kebab-case, short, descriptive: `churn-spike-q3`, `activation-drop-ios`, `pricing-test-readout`
- **date** — ISO format, the date analysis started: `2026-04-19`
- **analyst-name** — lowercase, no spaces: `nimrod`, `sarah-chen`

Example: `churn-spike-q3_2026-04-19_nimrod`

## Folder Contents

```
<analysis-folder>/
├── plan.md                  # Hypotheses, approach, diagram, checkpoint log
├── queries/                 # All queries used, one per file
│   ├── 01_baseline-churn-rate.sql
│   ├── 02_churn-by-segment.sql
│   └── ...
├── results/                 # Outputs from queries
│   ├── 01_baseline-churn-rate.csv
│   ├── 02_churn-by-segment.csv
│   └── ...
└── deliverables/
    ├── report.html          # Interactive report
    └── summary.pdf          # Executive summary
```

## Naming Rules

**Queries** — numbered prefix + kebab-case description, matches order of execution:
`01_baseline-churn-rate.sql`, `02_churn-by-segment.sql`, `03_cohort-retention.sql`

**Results** — same prefix and name as the query that produced them, with the appropriate extension:
`01_baseline-churn-rate.csv`

This 1:1 pairing makes it trivial to trace any number in the report back to the query that produced it.

## Creating a New Analysis

1. Copy `analyses/_template/` to the new folder name.
2. Fill in `plan.md` header (question, hypotheses, analyst, date).
3. Add the Mermaid diagram to the plan.
4. Begin phase 1 (hypothesis-framer).

## What Never Goes in the Folder

- Scratch work, tmp files, `.ipynb_checkpoints`
- API keys, connection strings, credentials
- Raw data dumps unrelated to the queries run (results only)
- Drafts of deliverables — only the final ones
