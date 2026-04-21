-- Deep Analysis — H1 (plan)
-- Contingency test: Free vs Paid (2x2) and 3-way Free/Pro/Enterprise (3x2)
-- Outputs observed cells, expected cells under independence, chi-square,
-- risk ratio and odds ratio. CIs computed downstream in deep-analysis.md.
WITH complainers AS (
    SELECT DISTINCT opened_by AS user_id
    FROM   support_tickets
    WHERE  category IN ('bug', 'billing')
      AND  opened_by IS NOT NULL
      AND  opened_at >= '2024-06-17'
      AND  opened_at <= '2025-06-17'
),
cells AS (
    SELECT  CASE WHEN a.plan = 'free' THEN 'free' ELSE 'paid' END AS plan_group,
            a.plan AS plan_detail,
            u.id    AS user_id,
            CASE WHEN c.user_id IS NOT NULL THEN 1 ELSE 0 END AS is_complainer
    FROM    users u
    JOIN    accounts a ON u.org_id = a.id
    LEFT JOIN complainers c ON u.id = c.user_id
),
by_group AS (
    SELECT  plan_group,
            SUM(is_complainer)                         AS complainers,
            COUNT(*) - SUM(is_complainer)              AS non_complainers,
            COUNT(*)                                   AS total,
            ROUND(100.0 * SUM(is_complainer) / COUNT(*), 2) AS rate_pct
    FROM    cells
    GROUP BY plan_group
),
by_plan AS (
    SELECT  plan_detail,
            SUM(is_complainer)                         AS comp,
            COUNT(*) - SUM(is_complainer)              AS non_comp,
            COUNT(*)                                   AS n,
            ROUND(SUM(is_complainer)::numeric / COUNT(*), 4) AS p
    FROM    cells
    GROUP BY plan_detail
)
SELECT 'free_vs_paid' AS view, plan_group AS label, complainers AS comp, non_complainers AS non_comp, total AS n, rate_pct
FROM   by_group
UNION ALL
SELECT '3way', plan_detail, comp, non_comp, n, ROUND((p * 100)::numeric, 2)
FROM   by_plan
ORDER BY view, label;
