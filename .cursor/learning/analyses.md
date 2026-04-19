# Analyses Log

Running index of every completed analysis in this repo. Checked at the start of each new analysis to avoid duplicate work and to surface prior findings on related questions.

## How to Use This File

**At start of new analysis:** scan for related questions, tags, or segments. If a similar question was answered recently, surface the prior work and ask the user whether to build on it or redo it.

**At end of analysis (data-storytelling phase):** append a new entry below.

## Entry Format

```markdown
## <YYYY-MM-DD> — <Analysis Title>
- **Path:** `analyses/<folder-name>/`
- **Question:** <one sentence>
- **Key finding:** <one or two sentences>
- **Confidence:** High / Medium / Low
- **Tags:** #tag1 #tag2
```

---

## Entries

<!-- New entries added below this line, most recent first -->

## 2026-04-19 — Complainers Profile Analysis
- **Path:** `analyses/complainers-profile_2026-04-19_nimrod-fisher/`
- **Question:** What characteristics distinguish accounts that open support tickets from those that do not?
- **Key finding:** Static profile (plan, tenure, engagement) does not reliably separate complainers from non-complainers — 82% of accounts file a ticket regardless. The only confirmed signal is behavioral: platform activity spikes 1.6× in the 30 days before a first ticket in 45% of Enterprise and Free accounts. Ticket category varies meaningfully by plan (Free = billing, Pro = feature_request, Enterprise = even). May 2025 spike (2.1× monthly avg) remains unexplained.
- **Confidence:** Medium (n=50 accounts; H4 pre-signal confirmed at Moderate strength)
- **Tags:** #complainers #support-tickets #pre-signal #plan-tier #engagement #early-warning
