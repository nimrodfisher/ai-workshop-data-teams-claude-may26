-- EDA 22: H1 complaint rate by users.role
WITH complainers AS (
  SELECT DISTINCT opened_by AS user_id
  FROM support_tickets
  WHERE category IN ('bug','billing')
    AND opened_by IS NOT NULL
    AND opened_at >= '2024-06-17' AND opened_at <= '2025-06-17'
)
SELECT
  u.role,
  COUNT(DISTINCT u.id) AS users_in_role,
  COUNT(DISTINCT c.user_id) AS complainer_users,
  ROUND(100.0 * COUNT(DISTINCT c.user_id) / NULLIF(COUNT(DISTINCT u.id), 0), 2) AS complaint_rate_pct,
  ROUND(COUNT(DISTINCT c.user_id)::numeric / NULLIF(COUNT(DISTINCT u.id), 0) / 0.18, 2) AS lift_vs_baseline
FROM users u
JOIN accounts a ON u.org_id = a.id
LEFT JOIN complainers c ON u.id = c.user_id
GROUP BY u.role
ORDER BY complaint_rate_pct DESC;
