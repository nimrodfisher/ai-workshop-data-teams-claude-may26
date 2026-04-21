-- V5: Temporal stability - split the 12-month window in half; does H1-plan hold in each?
WITH c_h1 AS (
  SELECT DISTINCT opened_by AS user_id FROM support_tickets
  WHERE  category IN ('bug','billing') AND opened_by IS NOT NULL
    AND  opened_at BETWEEN '2024-06-17' AND '2024-12-16'
),
c_h2 AS (
  SELECT DISTINCT opened_by AS user_id FROM support_tickets
  WHERE  category IN ('bug','billing') AND opened_by IS NOT NULL
    AND  opened_at BETWEEN '2024-12-17' AND '2025-06-17'
),
cells_h1 AS (
  SELECT CASE WHEN a.plan='free' THEN 'free' ELSE 'paid' END AS plan_group, u.id AS user_id,
         CASE WHEN c.user_id IS NOT NULL THEN 1 ELSE 0 END AS is_c
  FROM users u JOIN accounts a ON u.org_id = a.id LEFT JOIN c_h1 c ON c.user_id = u.id
),
cells_h2 AS (
  SELECT CASE WHEN a.plan='free' THEN 'free' ELSE 'paid' END AS plan_group, u.id AS user_id,
         CASE WHEN c.user_id IS NOT NULL THEN 1 ELSE 0 END AS is_c
  FROM users u JOIN accounts a ON u.org_id = a.id LEFT JOIN c_h2 c ON c.user_id = u.id
)
SELECT 'H1_2024-06-17_to_2024-12-16' AS period, plan_group,
       SUM(is_c) AS comp, COUNT(*) - SUM(is_c) AS non_c, COUNT(*) AS n,
       ROUND(SUM(is_c)::numeric / COUNT(*), 4) AS rate FROM cells_h1 GROUP BY plan_group
UNION ALL
SELECT 'H2_2024-12-17_to_2025-06-17', plan_group,
       SUM(is_c), COUNT(*) - SUM(is_c), COUNT(*),
       ROUND(SUM(is_c)::numeric / COUNT(*), 4) FROM cells_h2 GROUP BY plan_group
ORDER BY period, plan_group;
