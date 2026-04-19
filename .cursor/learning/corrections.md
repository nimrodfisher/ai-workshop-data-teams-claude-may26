# Corrections

User feedback on agent behavior. Read at the start of every analysis. Applied as durable behavioral changes, not one-off adjustments.

## How to Use This File

**At start of analysis:** read every entry. Where a correction applies to the current phase, follow it.

**When a user corrects you:**
1. Acknowledge the correction in-conversation.
2. Immediately append an entry below.
3. Apply the correction for the rest of the analysis.

**Conflict handling:** if a new correction contradicts an existing one, surface the conflict to the user and ask which to keep.

## Entry Format

```markdown
## <YYYY-MM-DD> — <Short title>
- **Context:** <what phase / what the agent did>
- **Correction:** <what the user said to do differently>
- **Applies to:** hypothesis-framer / data-qa / eda / synthesis / validation / data-storytelling / all
```

---

## Entries

<!-- New entries added below this line, most recent first -->

## 2026-04-19 — summary.pdf must be a real PDF, not an HTML file
- **Context:** Data Storytelling phase — summary was saved as `summary.pdf.html` instead of a real PDF.
- **Correction:** Always generate `summary.pdf` as a real binary PDF using headless Chrome: `chrome.exe --headless --disable-gpu --print-to-pdf="summary.pdf" --print-to-pdf-no-header "file:///tmp.html"`. Write the HTML to a temp file, render to PDF, then delete the temp file. Never name an HTML file `.pdf` or `.pdf.html`.
- **Applies to:** data-storytelling

## 2026-04-19 — Do not auto-advance through analysis phases
- **Context:** Phase 1 (hypothesis-framer) and Phase 2 (data-qa) were run back-to-back without stopping for user confirmation, because the user said "Run the analysis."
- **Correction:** "Run the analysis" at the start does NOT override per-phase checkpoints. After every phase, stop, summarize findings, link artifacts, and ask "Proceed to [next phase]?" — then wait for an explicit reply before continuing.
- **Applies to:** all
