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
.cursor/rules/AGENTS.mdc          # Agent behavioral contract — read this first
.cursor/skills/                   # One subdirectory per phase/skill
.cursor/learning/
    analyses.md                   # Index of completed analyses (prevents duplication)
    corrections.md                # Persistent behavioral feedback from user
    known_issues.md               # Persistent data quality issues
.cursor/business_knowledge/       # Pulseboard company context and product tiers
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

### Learning Loop

Before starting any analysis, read all three learning files:
- `corrections.md` — apply every behavioral rule to the current analysis
- `known_issues.md` — factor known data issues into QA phase
- `analyses.md` — check whether this question has already been answered

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

### SVG Charts

All SVG charts must include:
- `viewBox="0 0 <w> <h>"` and `preserveAspectRatio="xMidYMid meet"`
- Margins: left ≥ 70, right ≥ 80, top ≥ 72, bottom ≥ 80
- Titles ≤ 52 characters; use `<tspan>` to split if longer
- No illegal XML control characters; no XML declaration (`<?xml ...?>`) inside inline SVG

### Analysis Plan (`plan.md` + plan.html)

Every `plan.md` must include:
- A Mermaid flowchart showing question → hypotheses → phases → deliverables
- Hypotheses with testable success criteria
- A checkpoint log updated after each phase

Every `plan.html` must show the plan by sections in a clear flow, using the front end design skill. 

### Known Data Issues to Always Apply

- `events` table coverage is ~90 days (2025-03-07 to 2025-06-06), not a full year — never annualize from this table without flagging the limitation
- Mann-Whitney rank-sum has a tie-handling bug in SQL — use the documented workaround in `known_issues.md`

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
- **Completed example analysis:** `analyses/fintech-pro-activity-drop_2026-04-28_nimrod-fisher/`
