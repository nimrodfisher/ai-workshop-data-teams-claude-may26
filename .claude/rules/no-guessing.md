# No silent guessing

When something needed to answer the question isn't defined, stop and ask. Do not improvise.

This is the failure mode that matters most: an agent that quietly fills a gap with a plausible
guess and returns a confident, wrong number. Surface the gap instead of papering over it.

Stop and ask when:

- **A column or table isn't in `schema.yaml` from my connected github repo (MCP).** Don't invent a column name that "should" exist. Ask, or report it as missing.
- **A metric isn't defined in `metrics.yaml` from my connected github repo (MCP).** Don't reconstruct the logic from the name. Flag that it's undefined and ask how it's computed.
- **The grain is ambiguous.** If "revenue per customer" could mean per-account or per-user, or the time window is unstated, ask before choosing.
- **A join would change the grain in a way the question doesn't specify.** Name the fan-out risk; don't just pick one.

State the assumption you would otherwise have made, then ask. One question, the blocking one.

A correct "I can't answer this yet because X is undefined" beats a wrong answer every time.
