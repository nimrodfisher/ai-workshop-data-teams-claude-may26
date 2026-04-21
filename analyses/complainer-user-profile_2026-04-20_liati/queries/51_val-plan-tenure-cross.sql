-- V2: Composition test - does Free serve as proxy for newer tenure?
WITH complainers AS (
  SELECT DISTINCT opened_by AS user_id FROM support_tickets
  WHERE category IN ('bug','billing') AND opened_by IS NOT NULL
    AND opened_at BETWEEN '2024-06-17' AND '2025-06-17'
),
cells AS (
  SELECT CASE WHEN a.plan='free' THEN 'free' ELSE 'paid' END AS plan_group,
         CASE WHEN ('2025-06-17'::date - u.created_at::date) < 180 THEN 'newer_lt180d' ELSE 'older_180d_plus' END AS tenure_group,
         u.id AS user_id,
         CASE WHEN c.user_id IS NOT NULL THEN 1 ELSE 0 END AS is_c
  FROM users u JOIN accounts a ON u.org_id = a.id
  LEFT JOIN complainers c ON c.user_id = u.id
)
SELECT plan_group, tenure_group,
       SUM(is_c) AS comp, COUNT(*) - SUM(is_c) AS non_c, COUNT(*) AS n,
       ROUND(SUM(is_c)::numeric / COUNT(*), 4) AS rate
FROM cells GROUP BY plan_group, tenure_group ORDER BY plan_group, tenure_group;
