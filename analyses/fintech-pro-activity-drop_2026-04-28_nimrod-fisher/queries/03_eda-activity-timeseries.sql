-- EDA: Weekly activity time series for FinTech Pro, last 9 weeks of coverage
SELECT
  DATE_TRUNC('week', e.occurred_at)::date AS week_start,
  COUNT(*) AS event_count,
  COUNT(DISTINCT e.user_id) AS active_users
FROM events e
JOIN accounts a ON e.org_id = a.id
WHERE a.industry = 'FinTech' AND a.plan = 'pro'
  AND e.occurred_at >= '2025-04-07'
GROUP BY DATE_TRUNC('week', e.occurred_at)
ORDER BY week_start;
