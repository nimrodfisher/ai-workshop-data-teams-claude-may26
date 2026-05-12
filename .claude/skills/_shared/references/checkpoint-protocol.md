# Checkpoint Protocol

Every skill ends with a checkpoint. The agent stops, summarizes, and waits for the user to confirm before advancing to the next phase.

## Why

- Prevents cascading errors (a wrong hypothesis corrupts every downstream phase).
- Gives the user control over cost, direction, and pace.
- Creates an audit trail in `plan.md` of what was decided and when.

## The Protocol

When a skill's phase completes:

1. **Summarize** — 3-5 bullets: what was done, what was found, what was saved and where.
2. **Link artifacts** — explicit paths to queries, results, charts, or docs produced.
3. **Surface risks** — anything ambiguous, missing, or suspicious.
4. **Ask to proceed** — single sentence: "Proceed to [next phase]?"
5. **Wait** — do not run the next skill until the user explicitly confirms.

## Confirmation Rules

- **"Yes" / "Proceed" / "Go"** → advance to the next phase.
- **"No" / "Wait" / questions** → stay in the current phase, address what was raised.
- **Silence** → stay. Do not infer consent.

## Logging the Checkpoint

Append to the `## Checkpoint Log` section of `plan.md`:

```markdown
### [Phase Name] — YYYY-MM-DD HH:MM
- **Summary:** <one paragraph>
- **Artifacts:** <paths>
- **User decision:** Approved / Revised / Paused
- **Notes:** <anything the user said that changes the plan>
```

## Phase Sequence

1. Hypothesis framed → confirm
2. Data QA complete → confirm
3. EDA complete → confirm
4. Synthesis drafted → confirm
5. Validation complete → confirm
6. Storytelling deliverables ready → done
