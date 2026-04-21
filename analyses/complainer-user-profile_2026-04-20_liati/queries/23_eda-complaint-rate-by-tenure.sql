-- EDA 23: H3 complaint rate by tenure bucket (tenure = 2025-06-17 minus users.created_at)
-- Tenure at *window start* has no variance (199/200 users signed up AFTER window start), so we
-- measure tenure at snapshot end instead — "how long has this user been in the system".
WITH complainers AS (
  SELECT DISTINCT opened_by AS user_id
  FROM support_tickets
  WHERE category IN ('bug','billing')
    AND opened_by IS NOT NULL
    AND opened_at >= '2024-06-17' AND opened_at <= '2025-06-17'
),
tenure AS (
  SELECT
    u.id AS user_id,
    ('2025-06-17'::date - u.created_at::date) AS tenure_days,
    CASE
      WHEN ('2025-06-17'::date - u.created_at::date) < 90  THEN 'lt_90d'
      WHEN ('2025-06-17'::date - u.created_at::date) < 180 THEN '90_180d'
      WHEN ('2025-06-17'::date - u.created_at::date) < 270 THEN '180_270d'
      ELSE '270d_plus'
    END AS tenure_bucket
  FROM users u
)
SELECT
  t.tenure_bucket,
  COUNT(DISTINCT t.user_id) AS users_in_bucket,
  COUNT(DISTINCT c.user_id) AS complainer_users,
  ROUND(100.0 * COUNT(DISTINCT c.user_id) / NULLIF(COUNT(DISTINCT t.user_id), 0), 2) AS complaint_rate_pct,
  ROUND(COUNT(DISTINCT c.user_id)::numeric / NULLIF(COUNT(DISTINCT t.user_id), 0) / 0.18, 2) AS lift_vs_baseline
FROM tenure t
LEFT JOIN complainers c ON t.user_id = c.user_id
GROUP BY t.tenure_bucket
ORDER BY CASE t.tenure_bucket
           WHEN 'lt_90d'   THEN 1
           WHEN '90_180d'  THEN 2
           WHEN '180_270d' THEN 3
           WHEN '270d_plus' THEN 4
         END;
