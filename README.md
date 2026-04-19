# AI Workshop for Data Teams

A teaching repo that turns a general-purpose AI assistant into an **AI Analyst** — one that runs end-to-end analyses on Supabase data, with a disciplined multi-phase flow, checkpoint-gated execution, and a learning loop.

Used in live workshops to demonstrate structured AI-assisted data analysis.

## What's in Here

```
├── AGENTS.md                    # How the agent behaves in this repo — read first
├── skills/                      # The seven phases of an analysis
│   ├── hypothesis-framer/       # 1. Turn questions into testable hypotheses
│   ├── data-qa/                 # 2. Validate data before analysis
│   ├── eda/                     # 3. Explore distributions, relationships, time
│   ├── deep-analysis/           # 4. Drill in: quantify effects, decompose drivers
│   ├── synthesis/               # 5. Turn findings into conclusions
│   ├── validation/              # 6. Stress-test the conclusions
│   ├── data-storytelling/       # 7. Build the HTML report + PDF summary
│   └── _shared/references/      # Protocols used by all skills
├── analyses/                    # One folder per completed analysis
│   └── _template/               # Scaffold to copy when starting a new analysis
├── .cursor/learning/            # Feedback loop: past analyses, corrections, known issues
├── scripts/                     # Shared Python helpers
└── docs/                        # Workshop-facing materials
```

## The Flow

Every analysis runs through seven phases, in order, with a user-confirmed checkpoint between each:

```
Business question
      ↓
1. Hypothesis Framer    — testable hypotheses + success criteria
      ↓ (checkpoint)
2. Data QA              — validate data health, severity-rated issues
      ↓ (checkpoint)
3. EDA                  — distributions, relationships, segments, time
      ↓ (checkpoint)
4. Deep Analysis        — quantify effects, decompose drivers, apply methods
      ↓ (checkpoint)
5. Synthesis            — conclusions mapped to hypotheses
      ↓ (checkpoint)
6. Validation           — sensitivity, alternatives, red-team
      ↓ (checkpoint)
7. Data Storytelling    — report.html + summary.pdf
      ↓
Learning files updated
```

No phase is skipped. No phase advances without explicit user confirmation.

## How to Start an Analysis

1. The agent loads the semantic model from the external GitHub repo (schema + metrics).
2. The agent reads `.cursor/learning/` for past context, corrections, and known data issues.
3. The agent copies `analyses/_template/` to a new folder: `analyses/<slug>_<YYYY-MM-DD>_<analyst>/`.
4. Work begins at Phase 1 (hypothesis-framer).

See `AGENTS.md` for the full contract.

## Analysis Folder Convention

```
analyses/<slug>_<YYYY-MM-DD>_<analyst>/
├── plan.md                  # Hypotheses, approach, Mermaid diagram, checkpoint log
├── queries/                 # All queries, one per file, numbered
├── results/                 # Query outputs + QA / EDA / synthesis / validation docs
└── deliverables/
    ├── report.html
    └── summary.pdf
```

Full spec in `skills/_shared/references/analysis-folder-convention.md`.

## Learning Loop

Three files under `.cursor/learning/` capture feedback across sessions:

- **`analyses.md`** — index of past analyses.
- **`corrections.md`** — behavioral feedback; applied at the start of each new analysis.
- **`known_issues.md`** — persistent data problems; factored into QA and report caveats.

Full spec in `skills/_shared/references/learning-system.md`.

## Data Source

All data is pulled from Supabase via the Supabase MCP. The schema and metric definitions live in a separate GitHub repo (`nimrodfisher/workshop-queries-repo`) and are loaded at the start of every analysis. See `skills/_shared/references/semantic-model-loader.md`.

## For Workshop Attendees

- Read `AGENTS.md` first.
- Read one SKILL.md in detail — `hypothesis-framer` is a good entry point.
- Look at `analyses/_template/plan.md` to see the artifact structure.
- Run through a live analysis end-to-end with the agent; watch the checkpoints fire.
