# Learning System

Every analysis feeds back into the agent's behavior through `.cursor/learning/`. Three files, three purposes.

## The Three Files

**`analyses.md`** — index of every completed analysis. Prevents duplicate work, surfaces prior findings on related questions.

**`corrections.md`** — behavioral feedback from users. "Don't do X." "Always ask before Y." Applied at the start of every new analysis.

**`known_issues.md`** — persistent data problems reported by users. Factored into Data QA and into caveats in reports.

## Read at Start, Write at End

**Start of every analysis (in this order):**
1. Read `corrections.md` — adjust behavior.
2. Read `known_issues.md` — know what data to distrust.
3. Read `analyses.md` — check if this question (or adjacent ones) has been answered.

**End of every analysis:**
1. Append a new entry to `analyses.md`.
2. If the user corrected your behavior → append to `corrections.md`.
3. If the user flagged a data issue → append to `known_issues.md`.

## Entry Formats

### `analyses.md`

```markdown
## <YYYY-MM-DD> — <Analysis Title>
- **Path:** `analyses/<folder-name>/`
- **Question:** <one sentence>
- **Key finding:** <one or two sentences>
- **Confidence:** High / Medium / Low
- **Tags:** #churn #segmentation #q3
```

### `corrections.md`

```markdown
## <YYYY-MM-DD> — <Short title>
- **Context:** <what phase / what the agent did>
- **Correction:** <what the user said to do differently>
- **Applies to:** hypothesis-framer / data-qa / eda / synthesis / validation / data-storytelling / all
```

### `known_issues.md`

```markdown
## <Table or Metric Name> — <Short issue title>
- **Reported:** <YYYY-MM-DD> by <user>
- **Issue:** <description>
- **Impact:** <what analyses it affects>
- **Workaround:** <if known>
- **Status:** Open / Mitigated / Resolved
```

## Applying Corrections

When a correction exists, the agent must:
- Actually change behavior, not just acknowledge it.
- Reference the correction in `plan.md` when it affects an analysis decision.

If a new correction conflicts with an existing one — surface the conflict and ask the user which to keep.

## Pruning

These files grow. When they get unwieldy (say, >50 entries):
- `analyses.md` → archive entries older than 6 months to `analyses-archive.md`.
- `corrections.md` → consolidate duplicate or superseded entries.
- `known_issues.md` → move resolved issues to a `## Resolved` section at the bottom.
