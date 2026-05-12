-- =============================================================
-- Data QA — SQL check templates (Supabase / Postgres)
-- =============================================================
-- Substitute {{placeholders}} before running each block.
-- Common placeholders:
--   {{schema}}, {{table}}, {{col}}, {{key}}
--   {{date_col}}, {{ts_col}}, {{start_date}}, {{end_date}}
--   {{entity_col}}, {{status_col}}
--   {{child_table}}, {{parent_table}}, {{fk_col}}, {{pk_col}}
--
-- Each block returns a small structured result. Aggregate the
-- results into qa-summary.json; save the raw rows to results/qa/.
-- Save the instantiated query to queries/00_qa-<check>.sql.
-- =============================================================


-- -------------------------------------------------------------
-- 1. STRUCTURAL INTEGRITY
-- -------------------------------------------------------------

-- 1a. Row count.
SELECT COUNT(*) AS row_count
FROM {{schema}}.{{table}};

-- 1b. Column inventory — compare against the semantic model / schema.yml.
SELECT
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = '{{schema}}'
  AND table_name   = '{{table}}'
ORDER BY ordinal_position;


-- -------------------------------------------------------------
-- 2. COMPLETENESS
-- -------------------------------------------------------------

-- 2a. Null counts and percentages for one column.
-- Run once per column you care about, or build a UNION ALL across columns.
SELECT
    '{{col}}'                                                                AS column_name,
    COUNT(*)                                                                 AS total_rows,
    COUNT(*) - COUNT({{col}})                                                AS null_count,
    ROUND(100.0 * (COUNT(*) - COUNT({{col}})) / NULLIF(COUNT(*), 0), 2)      AS null_pct
FROM {{schema}}.{{table}}
WHERE {{date_col}} BETWEEN '{{start_date}}' AND '{{end_date}}';

-- 2b. Patterns in missingness — rows where two key columns are null together.
-- High counts in the (true, true) bucket signal a systemic upstream issue.
SELECT
    {{col_a}} IS NULL AS a_null,
    {{col_b}} IS NULL AS b_null,
    COUNT(*)          AS rows
FROM {{schema}}.{{table}}
GROUP BY 1, 2
ORDER BY rows DESC;


-- -------------------------------------------------------------
-- 3. UNIQUENESS & DUPLICATES
-- -------------------------------------------------------------

-- 3a. Key column uniqueness — should return 0. Anything > 0 is CRITICAL.
SELECT COUNT(*) - COUNT(DISTINCT {{key}}) AS duplicate_keys
FROM {{schema}}.{{table}};

-- 3b. Exact-row duplicate count — hashes the whole row, no need to list every column.
SELECT
    md5(t::text) AS row_hash,
    COUNT(*)     AS dup_count
FROM {{schema}}.{{table}} t
GROUP BY md5(t::text)
HAVING COUNT(*) > 1
ORDER BY dup_count DESC
LIMIT 50;

-- 3c. Sample of the duplicated rows (uses the hashes from 3b).
WITH dups AS (
    SELECT md5(t::text) AS h
    FROM {{schema}}.{{table}} t
    GROUP BY md5(t::text)
    HAVING COUNT(*) > 1
)
SELECT t.*
FROM {{schema}}.{{table}} t
JOIN dups d ON md5(t::text) = d.h
LIMIT 50;

-- 3d. Entity-level duplicates (same entity + same timestamp, different rows).
SELECT
    {{entity_col}},
    {{ts_col}},
    COUNT(*) AS rows
FROM {{schema}}.{{table}}
GROUP BY 1, 2
HAVING COUNT(*) > 1
ORDER BY rows DESC
LIMIT 50;


-- -------------------------------------------------------------
-- 4. CONSISTENCY
-- -------------------------------------------------------------

-- 4a. Negative values in positive-only fields.
SELECT COUNT(*) AS negative_rows
FROM {{schema}}.{{table}}
WHERE {{positive_col}} < 0;

-- 4b. Date-logic violations (end before start).
SELECT COUNT(*) AS bad_date_pairs
FROM {{schema}}.{{table}}
WHERE {{end_date_col}} < {{start_date_col}};

-- 4c. Future dates where past-only is expected.
SELECT COUNT(*) AS future_rows
FROM {{schema}}.{{table}}
WHERE {{date_col}} > NOW();

-- 4d. Status-transition sanity — pair each row with its previous status per entity.
WITH ordered AS (
    SELECT
        {{entity_col}},
        {{ts_col}},
        {{status_col}},
        LAG({{status_col}}) OVER (
            PARTITION BY {{entity_col}}
            ORDER BY {{ts_col}}
        ) AS prev_status
    FROM {{schema}}.{{table}}
)
SELECT
    prev_status,
    {{status_col}} AS new_status,
    COUNT(*)       AS transitions
FROM ordered
WHERE prev_status IS NOT NULL
GROUP BY 1, 2
ORDER BY transitions DESC;


-- -------------------------------------------------------------
-- 5. TIME COVERAGE
-- -------------------------------------------------------------

-- 5a. Range and density of the time series.
SELECT
    MIN({{date_col}})                                                        AS min_date,
    MAX({{date_col}})                                                        AS max_date,
    COUNT(DISTINCT {{date_col}}::date)                                       AS distinct_days,
    (MAX({{date_col}})::date - MIN({{date_col}})::date) + 1                  AS span_days
FROM {{schema}}.{{table}};

-- 5b. Missing-day detection — days inside the analysis window with zero rows.
WITH expected AS (
    SELECT generate_series(
        '{{start_date}}'::date,
        '{{end_date}}'::date,
        '1 day'
    )::date AS d
),
actual AS (
    SELECT DISTINCT {{date_col}}::date AS d
    FROM {{schema}}.{{table}}
    WHERE {{date_col}} BETWEEN '{{start_date}}' AND '{{end_date}}'
)
SELECT e.d AS missing_day
FROM expected e
LEFT JOIN actual a USING (d)
WHERE a.d IS NULL
ORDER BY e.d;

-- 5c. Timezone awareness — flags whether the timestamp column is timezone-aware.
-- 'timestamp with time zone' (timestamptz) stores UTC normalized.
-- 'timestamp without time zone' is ambiguous — investigate before trusting.
SELECT
    column_name,
    data_type
FROM information_schema.columns
WHERE table_schema = '{{schema}}'
  AND table_name   = '{{table}}'
  AND data_type LIKE 'timestamp%';


-- -------------------------------------------------------------
-- 6. DISTRIBUTION SANITY
-- -------------------------------------------------------------

-- 6a. Near-constant column detector — top values and their share of the column.
-- If the top value is >95%, the column may be unusable for analysis.
SELECT
    {{col}}                                                  AS value,
    COUNT(*)                                                 AS rows,
    ROUND(100.0 * COUNT(*) / SUM(COUNT(*)) OVER (), 2)       AS pct
FROM {{schema}}.{{table}}
GROUP BY {{col}}
ORDER BY rows DESC
LIMIT 5;

-- 6b. Cardinality of a categorical column — flag explosions (thousands of values).
SELECT COUNT(DISTINCT {{col}}) AS distinct_values
FROM {{schema}}.{{table}};

-- 6c. Definitionally-impossible values.
-- Replace the WHERE clause with the actual domain bounds for {{col}}.
-- Examples: age between 0 and 150, probability between 0 and 1, percentage 0-100.
SELECT COUNT(*) AS impossible_rows
FROM {{schema}}.{{table}}
WHERE {{col}} > {{max_valid}}
   OR {{col}} < {{min_valid}};


-- -------------------------------------------------------------
-- 7. REFERENTIAL INTEGRITY
-- -------------------------------------------------------------

-- 7a. Orphan foreign keys — child rows whose parent does not exist.
SELECT COUNT(*) AS orphan_rows
FROM {{schema}}.{{child_table}} c
LEFT JOIN {{schema}}.{{parent_table}} p
       ON c.{{fk_col}} = p.{{pk_col}}
WHERE p.{{pk_col}} IS NULL;

-- 7b. Join coverage — what fraction of child rows match a parent.
SELECT
    COUNT(*)                                                                 AS child_rows,
    COUNT(p.{{pk_col}})                                                      AS matched_rows,
    ROUND(100.0 * COUNT(p.{{pk_col}}) / NULLIF(COUNT(*), 0), 2)              AS match_pct
FROM {{schema}}.{{child_table}} c
LEFT JOIN {{schema}}.{{parent_table}} p
       ON c.{{fk_col}} = p.{{pk_col}};

-- 7c. Cardinality assumption — max children per parent.
-- If you expected one-to-many, scan the top of the result for surprises.
SELECT
    {{fk_col}},
    COUNT(*) AS child_count
FROM {{schema}}.{{child_table}}
GROUP BY {{fk_col}}
ORDER BY child_count DESC
LIMIT 10;
