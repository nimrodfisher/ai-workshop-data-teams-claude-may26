-- DA: H1 concentration — which account drives more of the absolute drop
WITH periods AS (
  SELECT
    a.id, a.name,
    SUM(CASE WHEN e.occurred_at >= '2025-04-07' AND e.occurred_at < '2025-05-07' THEN 1 ELSE 0 END) AS prior_30,
    SUM(CASE WHEN e.occurred_at >= '2025-05-07' AND e.occurred_at < '2025-06-07' THEN 1 ELSE 0 END) AS last_30
  FROM accounts a
  JOIN events e ON e.org_id = a.id
  WHERE a.industry = 'FinTech' AND a.plan = 'pro'
  GROUP BY a.id, a.name
)
SELECT
  name,
  prior_30,
  last_30,
  (last_30 - prior_30) AS abs_change,
  ROUND(100.0 * (last_30 - prior_30) / NULLIF(prior_30, 0), 1) AS pct_change,
  ROUND(100.0 * (prior_30 - last_30) / NULLIF(SUM(prior_30 - last_30) OVER (), 0), 1) AS share_of_total_drop
FROM periods
ORDER BY abs_change ASC;
