# Debug Notebook — Spec & Generation

Every analysis ships a standalone debug notebook at `deliverables/notebook.ipynb`. An analyst should be able to clone the analysis folder, open the notebook in Jupyter / VS Code, and run it top-to-bottom to understand and debug the complete flow — without a DB connection.

## Purpose

- **Debuggability.** The analyst can inspect any phase's saved CSVs, tweak a chart, re-run a block, or swap in a new filter — all in one place.
- **Reproducibility from saved data.** Code cells load the CSVs written by each phase; charts are rebuilt from that data. No Supabase, no MCP, no network.
- **One artifact, full story.** The notebook mirrors the analysis flow so a reviewer doesn't have to chain together plan.md + five phase `.md` files + a report.

## Structure (cell order)

1. **Markdown — Title & Context.** Analysis title, analyst, date, one-paragraph question restatement, link to `plan.md`.
2. **Code — Setup.**
   ```python
   from pathlib import Path
   import json
   import pandas as pd
   import matplotlib.pyplot as plt

   ROOT = Path.cwd().parent if Path.cwd().name == "deliverables" else Path.cwd()
   RESULTS = ROOT / "results"
   ```
3. **Markdown — Hypotheses & Decision.** Pulled verbatim from `plan.md` (H1 / H2 / H0 + decision this supports).
4. **Markdown + Code — Data QA.**
   - Markdown: the contents of `results/qa/qa-report.md` (or its headline summary).
   - Code:
     ```python
     qa_csvs = {p.stem: pd.read_csv(p) for p in (RESULTS / "qa").glob("*.csv")}
     for name, df in qa_csvs.items():
         print(name, df.shape)
         display(df.head())
     ```
5. **Markdown + Code — EDA.**
   - Markdown: contents of `results/eda/eda-findings.md`.
   - For each EDA chart, one code cell that reads the matching CSV and rebuilds the chart with matplotlib (or plotly). Example:
     ```python
     df = pd.read_csv(RESULTS / "eda" / "04_eda-engagement-by-bucket.csv")
     df.plot.bar(x="bucket", y=["mean_events","median_events"])
     plt.title("Engagement by Ticket Bucket"); plt.tight_layout(); plt.show()
     ```
6. **Markdown + Code — Deep Analysis.** Same pattern — method-specific tables loaded from `results/deep-analysis/*.csv`, charts rebuilt.
7. **Markdown — Synthesis.** Contents of `results/synthesis/synthesis.md` (evidence rating per hypothesis, overall conclusion).
8. **Markdown + Code — Validation.**
   - Markdown: contents of `results/validation/validation.md`.
   - Code cells for sensitivity tables loaded from `results/validation/*.csv`.
9. **Markdown — Conclusions & Recommendations.** The headline answer and recommendations from the report.
10. **Markdown — How to re-run against the DB.** Short note: "To re-run any query from scratch, open the matching file in `queries/` and run it via the Supabase MCP. The notebook intentionally uses saved CSVs so it works offline."

## Rules

- Every saved CSV in `results/<phase>/` must appear in at least one code cell. No orphan data.
- No hard-coded absolute paths; use `RESULTS = ROOT / "results"`.
- Charts use matplotlib (default) — no external JS/Plotly CDN so the notebook works offline.
- Keep cell outputs cleared on save (so the file stays small); analysts run it to regenerate outputs.
- The notebook is **generated deterministically** from the saved artifacts — do not hand-write it.

## Generation

Generate the notebook with `nbformat` at the end of data-storytelling, after all phase `.md` files and CSVs are final. Run this as a standalone Python script from inside the analysis folder, or inline in the storytelling step.

```python
# scripts/build_notebook.py — run from the analysis folder
import json, nbformat as nbf
from pathlib import Path

ROOT = Path(__file__).resolve().parent
RESULTS = ROOT / "results"
DELIV   = ROOT / "deliverables"

def md(text): return nbf.v4.new_markdown_cell(text)
def code(src): return nbf.v4.new_code_cell(src)

def read(p: Path) -> str:
    return p.read_text(encoding="utf-8") if p.exists() else f"_(missing: {p.name})_"

cells = []

# 1. Title
cells.append(md(f"# {ROOT.name}\n\nStandalone debug notebook. Runs top-to-bottom from saved CSVs."))

# 2. Setup
cells.append(code(
    "from pathlib import Path\n"
    "import pandas as pd\n"
    "import matplotlib.pyplot as plt\n"
    "ROOT = Path.cwd()\n"
    "RESULTS = ROOT / 'results'\n"
    "print('Analysis root:', ROOT)"
))

# 3. Plan / Hypotheses
cells.append(md("## Plan & Hypotheses\n\n" + read(ROOT / "plan.md")))

# 4. QA
cells.append(md("## Data QA\n\n" + read(RESULTS / "qa" / "qa-report.md")))
cells.append(code(
    "qa_csvs = {p.stem: pd.read_csv(p) for p in sorted((RESULTS / 'qa').glob('*.csv'))}\n"
    "for name, df in qa_csvs.items():\n"
    "    print(f'--- {name} — {df.shape}')\n"
    "    display(df.head())"
))

# 5. EDA
cells.append(md("## EDA\n\n" + read(RESULTS / "eda" / "eda-findings.md")))
for csv in sorted((RESULTS / "eda").glob("*.csv")):
    cells.append(code(
        f"df = pd.read_csv(RESULTS / 'eda' / '{csv.name}')\n"
        f"print('{csv.stem}', df.shape)\n"
        f"display(df.head())\n"
        f"# TODO: rebuild chart — example: df.plot.bar(x=df.columns[0]); plt.title('{csv.stem}'); plt.tight_layout(); plt.show()"
    ))

# 6. Deep Analysis
da_md = RESULTS / "deep-analysis" / "deep-analysis.md"
if da_md.exists():
    cells.append(md("## Deep Analysis\n\n" + read(da_md)))
    for csv in sorted((RESULTS / "deep-analysis").glob("*.csv")):
        cells.append(code(
            f"df = pd.read_csv(RESULTS / 'deep-analysis' / '{csv.name}')\n"
            f"print('{csv.stem}', df.shape)\n"
            f"display(df.head())"
        ))

# 7. Synthesis
cells.append(md("## Synthesis\n\n" + read(RESULTS / "synthesis" / "synthesis.md")))

# 8. Validation
cells.append(md("## Validation\n\n" + read(RESULTS / "validation" / "validation.md")))
for csv in sorted((RESULTS / "validation").glob("*.csv")):
    cells.append(code(
        f"df = pd.read_csv(RESULTS / 'validation' / '{csv.name}')\n"
        f"print('{csv.stem}', df.shape)\n"
        f"display(df.head())"
    ))

# 9. Closing
cells.append(md(
    "## Re-running against the database\n\n"
    "This notebook uses the CSVs saved under `results/`. To re-run any query from scratch, open the matching file in `queries/` and execute it via the Supabase MCP, then overwrite the CSV."
))

nb = nbf.v4.new_notebook()
nb["cells"] = cells
nb["metadata"] = {"kernelspec": {"name": "python3", "display_name": "Python 3"}, "language_info": {"name": "python"}}
DELIV.mkdir(exist_ok=True)
(DELIV / "notebook.ipynb").write_text(nbf.writes(nb), encoding="utf-8")
print("Wrote", DELIV / "notebook.ipynb")
```

If `nbformat` is not installed, the notebook JSON can be emitted directly (nbformat v4 is a plain JSON schema). Prefer `nbformat` when available — it handles cell IDs and schema version for you.

## Checklist before closing the analysis

- [ ] `deliverables/notebook.ipynb` exists and is valid JSON (open it in Jupyter/VS Code once).
- [ ] Every `results/<phase>/*.csv` is referenced in at least one code cell.
- [ ] No absolute paths; `RESULTS = ROOT / 'results'` only.
- [ ] Cell outputs cleared (file size < 1 MB unless it embeds chart images).
