# Known Issues

Persistent data issues users have reported. Checked before every analysis so Data QA can factor them in and the final report can include appropriate caveats.

## How to Use This File

**At start of analysis:** read all **Open** and **Mitigated** entries. Factor them into the QA plan and into hypothesis scoping.

**When a user flags a data issue during an analysis:**
1. Confirm it's *persistent* (not a one-off glitch in a single run).
2. Append an entry below with status `Open`.
3. Note the issue in the current analysis's `plan.md` caveats.

**When an issue is fixed:** move the entry to the `## Resolved` section at the bottom and update status.

## Entry Format

```markdown
## <Table or Metric Name> — <Short issue title>
- **Reported:** <YYYY-MM-DD> by <user>
- **Issue:** <description>
- **Impact:** <what analyses it affects>
- **Workaround:** <if known>
- **Status:** Open / Mitigated / Resolved
```

---

## Open

<!-- Open issues — the agent must factor these into every relevant analysis -->

## Mitigated

<!-- Issues with documented workarounds — still relevant to caveat in reports -->

## Resolved

<!-- Issues that have been fixed at the source — kept for historical context -->
