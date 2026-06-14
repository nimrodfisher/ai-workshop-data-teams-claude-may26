# Workshop Setup Guide — Design

**Date:** 2026-06-14
**Author:** Nimrod Fisher
**Status:** Approved design, pending spec review

## Purpose

Give the data analysts joining the workshop a single, simple guide that gets them
from zero to running the **same 7-phase AI-analyst workflow** on **their own data**.
They connect their database, write their own `schema.yml` / `metrics.yml` and business
context in the **same structure** as the Pulseboard setup, point the workflow at their
local files, and run an analysis — so they can practice independently before and
between live sessions.

## Deliverable

A single self-contained file: **`workshop_setup_prep/workshop-setup.html`**

- No external dependencies — inline CSS/JS so it opens in any browser by double-click.
- Built with the data-visualizer / frontend-design patterns (KPI-card styling,
  responsive layout, copy-friendly code blocks), per the standing rule that all HTML
  deliverables use the design skill.
- Ends with an **interactive setup checklist** (checkboxes the analyst ticks as they go;
  state held in-page).

## Scope

**In scope:** the HTML guide only.

**Out of scope:** I do **not** modify the repo's loader, `CLAUDE.md`, or skills. The guide
*instructs* analysts what to change so the workflow reads their **local** files instead of
Nimrod's GitHub repo. The workshop repo stays as-is.

## Key decisions (locked)

| Decision | Choice |
|---|---|
| Where analysts' context lives | Local files in the repo: `.claude/semantic-model/schema.yml` + `metrics.yml`; business context in `.claude/business_knowledge/` |
| File extension | `.yml` (matches the canonical Pulseboard files exactly) |
| Data connection | Connection-agnostic — guide points to the right MCP for the analyst's warehouse (Postgres / Supabase / BigQuery), with a verify-with-one-query step |
| How analysts create the files | AI-assisted from templates: blank template + one worked example + a "have Claude draft it" prompt they review/edit |
| Loader change | Guide instructs only (edit `semantic-model-loader.md` + `CLAUDE.md` to read local files); repo not modified by me |
| Progress tracking | One-time interactive setup checklist (no heavyweight run-tracker) |

## Reference: the exact structures the guide must teach

These are pulled from `nimrodfisher/workshop-queries-repo` and are the canonical shapes
the analysts must mirror.

**`schema.yml`** (top-level keys, in order):
- `version: 2`
- `models[]` — each table: `name`, `description`, `synonyms[]`, `columns[]`
  (each column: `name`, `description`, `data_type`, `synonyms[]`, optional `constraints[]`, optional `default`)
- `relationships[]` — `from_model`, `from_column`, `to_model`, `to_column`, `description`
- `notes` — freeform schema overview + data-quality notes
- `common_business_questions[]` — `question`, `synonyms[]`, `query_pattern`
- `common_metrics[]` — `name`, `synonyms[]`, `calculation`
- `sql_style_guide` — freeform formatting rules

**`metrics.yml`** (top-level keys, in order):
- `version: 2`
- `metrics[]` — each metric: `name`, `label`, `description`, `type` (`simple` | `ratio`),
  `type_params` (`measure` for simple; `numerator` + `denominator` for ratio),
  `synonyms[]`, `meta` (`agent_guidance` + source pointers: `source_table`, `source_column`,
  `filter`, `calculation`, etc.)

## HTML guide — section outline

1. **What you're building** — 3-sentence framing + a simple flow diagram:
   *your data → your context files → the 7-phase workflow → HTML report*.
2. **Step 1 · Pull the repo** — `git clone https://github.com/nimrodfisher/ai-workshop-data-teams-claude-may26`, open in Claude Code.
3. **Step 2 · Connect your data** — add the MCP for your warehouse; run one test query to confirm the connection.
4. **Step 3 · Build `schema.yml`** — annotated structure, copy-paste template, one real worked example (a single table from the Pulseboard schema), plus the AI-assist prompt: point Claude at your connected DB to draft it, then review.
5. **Step 4 · Build `metrics.yml`** — same treatment: template + two worked examples (a `simple` metric like MRR and a `ratio` metric like ARPA) + AI-assist prompt from plain-language metric descriptions.
6. **Step 5 · Write your business context** — plain language → `business_desc.md` + `products.md` via AI-assist; what "good" framing looks like.
7. **Step 6 · Point the workflow at your local files** — the one change so the loader reads `.claude/semantic-model/` instead of the GitHub repo (edit `semantic-model-loader.md` + the `CLAUDE.md` ground-truth pointer).
8. **Step 7 · Run an analysis** — pose a business question; the same 7 gated phases run, stopping at each checkpoint.
9. **✅ Setup checklist** — interactive: repo pulled · data connected + test query · `schema.yml` done · `metrics.yml` done · business context done · loader pointed local · first analysis run.

## Success criteria

- An analyst with their own database can follow the guide end-to-end without help and
  reach a running analysis.
- The `schema.yml` / `metrics.yml` they produce match the canonical structure (validated
  by the workflow loading them without errors).
- The guide is one file, opens offline, and the checklist makes "am I ready?" obvious at a glance.
