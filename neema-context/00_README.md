# Neema Context — README

> Index and orientation for the Neema context structure: how the folders are organized and how to navigate company, Account, Platform, shared departments, and data/metrics.

## Start here: the router

**Before answering any analyst question, read [`router.md`](router.md) and load ONLY the files
it directs you to.** The router maps each question to the minimum set of context files needed —
it exists so the agent never reads the whole context (especially the large semantic model) when
a few leaf files will do. Reading everything is slow, expensive, and dilutes attention.

Do **not** read the full `05_data-and-metrics/semantic_model.yml` unless explicitly asked to
audit the whole model — use the per-table splits the router points to instead.

### Wiring into CLAUDE.md

Add this to the project's `CLAUDE.md` so the agent always routes first:

```markdown
## Context
Before answering any analyst question, read `neema-context/router.md` and load ONLY the
files it directs you to. Never read the full `semantic_model.yml` unless explicitly asked —
use the per-table splits under `05_data-and-metrics/semantic-model/`.
```

## Folder map

| Path | What's inside |
|---|---|
| `router.md` | **Entry point.** Question → minimum file set (business + data routing). |
| `01_company-overview/` | Mission/history, 2026 targets, org structure. |
| `02_neema-account/` | B2C product (foreign workers in Israel): overview, features, revenue, segments, departments. |
| `03_neema-platform/` | B2B API: overview, products, dynamic routing, revenue, ICP, departments. |
| `04_shared-departments/` | Finance, compliance/legal/risk, data & AI, R&D, security, HR. |
| `05_data-and-metrics/` | `metrics.yaml`, `semantic_model.yml` (source of truth), and `semantic-model/` per-table splits + `_index.md` join map. |

## How loading works (tiers)

1. **Tier 0 (cheap, most questions):** `router.md` + `semantic-model/_index.md` (join map) +
   `metrics.yaml` when a metric is named.
2. **Tier 1 (by business area):** the matched area `overview` + the specific department/topic file.
3. **Tier 2 (by data entity):** only the per-table `.yml` files the query actually touches.

Typical 1–2 table questions load ~75–82% fewer semantic-model tokens than scanning the full
model; even a heavy 3-table join still saves ~46%.
