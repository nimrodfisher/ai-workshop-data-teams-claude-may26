# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What This Project Is

An **AI Analyst workflow system** for data teams. It turns an AI assistant into a disciplined analyst that executes business questions through a 7-phase gated pipeline, producing HTML reports, PDFs, and Jupyter notebooks. The data source is a Supabase PostgreSQL database for a fictitious company called **Pulseboard** (Series A B2B analytics platform, ~50 customers across 7 industries).

There is no traditional build system, dependency file, or test suite. The "code" is prompts, templates, SQL, and markdown that orchestrate an analytical process.

## Architecture

### Seven-Phase Analysis Pipeline

Every analysis runs these phases in order — no skipping, no reordering:

1. **hypothesis-framer** — business question → testable hypotheses with success criteria
2. **data-qa** — data quality validation before analysis begins
3. **eda** — distributions, segmentation, time series
4. **deep-analysis** — effect quantification, driver decomposition
5. **synthesis** — map findings back to hypotheses, render verdicts
6. **validation** — sensitivity checks, alternative explanations
7. **data-storytelling** — interactive HTML report + PDF executive summary

Each phase ends with a **checkpoint**: summarize findings → link artifacts → surface risks → ask for user confirmation → wait. Silence is not consent; do not proceed without explicit confirmation.

### Key Directories

```
.claude/rules/                    # Agent behavioral contract — read these first
    ground-truth.md               # What is authoritative vs. inferred
    no-guessing.md                # Never invent schema, metrics, or numbers
    sql-conventions.md            # SQL style and safety conventions
.claude/skills/                   # One subdirectory per phase/skill (+ _shared)
.claude/learning/
    analyses.md                   # Index of completed analyses (prevents duplication)
    corrections.md                # Persistent behavioral feedback from user
    known_issues.md               # Persistent data quality issues
.claude/business_knowledge/       # Pulseboard company context and product tiers
    business_desc.md              # Company overview
    products.md                   # Product tiers
analyses/
    _template/                    # Scaffold for new analyses
    <slug>_<YYYY-MM-DD>_<analyst>/
        plan.md                   # Hypotheses + Mermaid flowchart + checkpoint log
        queries/                  # Numbered SQL files (e.g., 01_cohort_activity.sql)
        results/
            qa/ eda/ deep-analysis/ synthesis/ validation/
```

### Semantic Model (External)

Schema and metrics are **never invented**. Load them at the start of every analysis using `mcp__github__get_file_contents` (owner: `nimrodfisher`, repo: `workshop-queries-repo`, paths: `schema.yml` and `metrics.yml`). Fail fast if loading fails — do not proceed with guessed schema.

## Your Skills

Skills are standards you follow automatically. Apply them whenever the trigger condition matches — you do not need to be asked.

| Skill | Trigger condition |
|---|---|
| `hypothesis-framer` | A new business question arrives — frame it before pulling any data |
| `data-qa` | After hypotheses are framed, before EDA — and any time results look suspicious |
| `eda` | After Data QA passes — explore distributions, segmentation, time series |
| `deep-analysis` | After EDA — quantify effects, decompose drivers, run statistical tests |
| `synthesis` | After Deep Analysis — map findings back to each hypothesis and render verdicts |
| `validation` | After Synthesis — sensitivity checks, confounders, alternative explanations |
| `data-storytelling` | After Validation — build the interactive HTML report + PDF summary |
| `data-visualizer` / `frontend-design` | Whenever building any HTML deliverable (`plan.html`, `report.html`) or chart |
| `pandas-operations` | Whenever writing pandas code in EDA, Deep Analysis, or QA |

## Learning Loop

The `.claude/learning/` folder is the project's institutional memory. It carries forward what was learned in **previous analyses** and the **analyst's corrections** so mistakes are not repeated.

**Before starting any analysis**, read all three learning files:
- `corrections.md` — persistent behavioral feedback the analyst has given. Apply every rule here to the current analysis; these override default behavior.
- `known_issues.md` — data quality issues discovered in past work. Factor each one into the QA phase before trusting the data.
- `analyses.md` — index of completed analyses. Check whether this question (or a close variant) has already been answered before doing duplicate work; reuse prior queries and findings where relevant.

**During the analysis**, when the analyst corrects your behavior or you discover a new data issue, propose adding it to the relevant learning file so the lesson persists.

**After completing an analysis**, update `analyses.md` with the new entry (slug, date, question, key findings, link to the folder) so future analyses can find and build on it.

## Required Conventions

### Results Structure

Every phase must produce files in the correct subfolder:

| Phase | Folder | Required files |
|---|---|---|
| QA | `results/qa/` | `qa-report.md`, `qa-summary.json`, `*.csv` |
| EDA | `results/eda/` | `eda-findings.md`, charts, `*.csv` |
| Deep Analysis | `results/deep-analysis/` | `deep-analysis.md`, charts, `*.csv` |
| Synthesis | `results/synthesis/` | `synthesis.md` |
| Validation | `results/validation/` | `validation.md`, sensitivity charts, `*.csv` |

Every SQL query output must be saved as a `.csv` with the same name as the `.sql` file.


### Analysis Plan (`plan.md` + plan.html)

Every `plan.md` must include:
- A Mermaid flowchart showing question → hypotheses → phases → deliverables
- Hypotheses with testable success criteria
- A checkpoint log updated after each phase

Every `plan.html` must show the plan by sections in a clear flow, using the front end design skill. 

### Known Data Issues to Always Apply

- Always check ./claude/learnings to prevent re-running analyses, learning from previous mistakes and adopt relevant context.

## Running an Analysis

1. User poses a business question
2. Load semantic model from GitHub
3. Read all three learning files
4. Scaffold `analyses/<slug>_<YYYY-MM-DD>_<analyst>/` from `_template/`
5. Execute phases 1–7, stopping at each checkpoint for explicit user confirmation
6. Update `analyses.md` upon completion

## Context

- **Analyst identity:** Nimrod Fisher, Senior Data Analyst
- **Company:** Pulseboard — mid-market B2B analytics platform, Series A
- **Industries served:** eCommerce, MarTech, SaaS, HealthTech, FinTech, CyberSecurity, EdTech
- **Data access:** Supabase MCP (no local database client needed)
- Conventions and refusal protocol: see `.claude/rules/`.