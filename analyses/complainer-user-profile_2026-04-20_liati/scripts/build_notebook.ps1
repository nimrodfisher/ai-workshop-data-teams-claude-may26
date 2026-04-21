# Build deliverables/notebook.ipynb from saved results/ artifacts.
# Runs under PowerShell; no Python needed. Emits nbformat v4 JSON.
$ErrorActionPreference = 'Stop'

$root    = Split-Path -Parent $PSScriptRoot
$results = Join-Path $root 'results'
$deliv   = Join-Path $root 'deliverables'
New-Item -ItemType Directory -Force -Path $deliv | Out-Null

function New-Md($text) {
    [pscustomobject]@{
        cell_type = 'markdown'
        metadata  = @{}
        source    = ($text -split "`r?`n") | ForEach-Object { "$_`n" } | Select-Object -First ([int]::MaxValue)
    }
}
function New-Code($src) {
    [pscustomobject]@{
        cell_type       = 'code'
        metadata        = @{}
        execution_count = $null
        outputs         = @()
        source          = ($src -split "`r?`n") | ForEach-Object { "$_`n" } | Select-Object -First ([int]::MaxValue)
    }
}

$cells = New-Object System.Collections.ArrayList

[void]$cells.Add((New-Md @"
# Complainer-User Profile — Debug Notebook

Standalone debug notebook. Loads every CSV saved under `results/` and re-renders charts using pandas + matplotlib. No database connection required.

**Analyst:** liati · **Date:** 2026-04-20 · **Analysis:** 2024-06-17 to 2025-06-17 snapshot.

**Question:** What observable, measurable characteristics distinguish users who file complaint-like support tickets (`bug` or `billing`) from users who do not?

**Headline answer:** Only one — `plan = 'free'` (28% complaint rate vs 14.7% paid, χ² p = 0.034, RR 1.91 [1.06, 3.44]). Role, tenure, and industry do not distinguish. Engagement is not testable at current event-data coverage.
"@))

[void]$cells.Add((New-Code @"
from pathlib import Path
import pandas as pd
import matplotlib.pyplot as plt

ROOT = Path.cwd().parent if Path.cwd().name == 'deliverables' else Path.cwd()
RESULTS = ROOT / 'results'
print('Analysis root:', ROOT)
print('Results dir:  ', RESULTS, '(exists:', RESULTS.exists(), ')')
"@))

[void]$cells.Add((New-Md @"
## Plan & Hypotheses

The `plan.md` file in the analysis root captures the hypotheses, decisions, checkpoints, and revisions throughout the analysis. Run the cell below to display it inline; otherwise open it directly from the analysis folder.
"@))
[void]$cells.Add((New-Code @"
from IPython.display import Markdown, display
display(Markdown((ROOT / 'plan.md').read_text(encoding='utf-8')))
"@))

# ---------- Phase sections ----------
$phases = @(
    @{ slug = 'qa';            title = 'Data QA';        md = 'qa-report.md' },
    @{ slug = 'eda';           title = 'EDA';            md = 'eda-findings.md' },
    @{ slug = 'deep-analysis'; title = 'Deep Analysis';  md = 'deep-analysis.md' },
    @{ slug = 'synthesis';     title = 'Synthesis';      md = 'synthesis.md' },
    @{ slug = 'validation';    title = 'Validation';     md = 'validation.md' }
)

foreach ($phase in $phases) {
    $phaseDir = Join-Path $results $phase.slug
    $mdPath   = Join-Path $phaseDir $phase.md
    $mdRelDisp = "results/$($phase.slug)/$($phase.md)"
    [void]$cells.Add((New-Md "## $($phase.title)`n`nPhase report below is pulled from ``$mdRelDisp``.`n"))
    if (Test-Path $mdPath) {
        [void]$cells.Add((New-Code @"
from IPython.display import Markdown, display
display(Markdown((RESULTS / '$($phase.slug)' / '$($phase.md)').read_text(encoding='utf-8')))
"@))
    }
    # One code cell per CSV in this phase
    if (Test-Path $phaseDir) {
        $csvs = Get-ChildItem -Path $phaseDir -Filter '*.csv' | Sort-Object Name
        foreach ($csv in $csvs) {
            $name = $csv.Name
            $stem = [System.IO.Path]::GetFileNameWithoutExtension($name)
            $src = "df = pd.read_csv(RESULTS / '$($phase.slug)' / '$name')`nprint('$stem', df.shape)`ndf.head(20)"
            [void]$cells.Add((New-Code $src))
        }
    }
}

# ---------- Closing ----------
[void]$cells.Add((New-Md @"
## Conclusions & recommendations

See `deliverables/report.html` (full interactive report) and `deliverables/summary.pdf` (one-page executive summary).

**Survivor summary after validation:**
- **Confirmed (narrowed):** `plan='free'` → ~1.9× complaint rate, within 2024-12-17 to 2025-06-17.
- **Refuted:** role, tenure, industry (underpowered) do not distinguish complainers.
- **Inconclusive / not testable:** H2 engagement — event data covers only ~90 of 365 window days.
- **Withdrawn:** earlier "disengagement" reframe (built on rank-sum SQL bug + event-coverage artifact).

**Recommended watch-list rule:** `plan = 'free'` — precision 28%, recall 39%, lift 1.56×. Simple, unconfounded, honest.

**Do not deploy:** any rule containing `ev_14 = 0` (below-baseline precision) or involving `ev_30 = 0` until event-data coverage extends to ≥6 months overlapping the complaint window.
"@))

[void]$cells.Add((New-Md @"
## How to re-run against the database

This notebook uses the CSVs saved under `results/`. To re-run any query from scratch, open the matching file in `queries/` and execute it via the Supabase MCP, then overwrite the corresponding CSV under `results/<phase>/`.

All queries in this analysis are deterministic against the frozen 2025-06-17 snapshot.
"@))

$nb = [ordered]@{
    cells          = $cells.ToArray()
    metadata       = @{
        kernelspec    = @{ display_name = 'Python 3'; language = 'python'; name = 'python3' }
        language_info = @{ name = 'python' }
    }
    nbformat       = 4
    nbformat_minor = 5
}

$json = $nb | ConvertTo-Json -Depth 20
[System.IO.File]::WriteAllText((Join-Path $deliv 'notebook.ipynb'), $json, [System.Text.Encoding]::UTF8)

Write-Host "Wrote $(Join-Path $deliv 'notebook.ipynb')"
Write-Host ("Cells: {0}" -f $cells.Count)
