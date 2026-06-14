# SQL conventions

How to write queries here. These are judgment calls — a hook can't tell whether a JOIN is at
the right grain, so the steering happens in your reasoning, here.

**Structure**
- CTEs over nested subqueries. Name each step for what it produces.
- Never `SELECT *` in anything that ships. Name the columns you need.
- Read from staging / marts models, not raw source tables, unless explicitly asked.

**Cost awareness**
- Always add a partition filter on partitioned tables (date/`_PARTITIONDATE`). Assume tables are large.
- When exploring, add a `LIMIT` and sample first. Confirm shape before you scan the full table.

**Correctness**
- Be explicit about JOIN grain. If a join can fan out, deduplicate or aggregate to the intended grain on purpose, and say so.
- Never write `DELETE` or `UPDATE` without a `WHERE` clause. (This is also enforced by a hook — the rule is so you never attempt it; the hook is so it can't happen.)
- Cast and handle nulls deliberately; don't let an implicit type coercion decide the answer.

**Output**
- End a non-trivial query with one line stating the grain of the result set and any assumption you made.
