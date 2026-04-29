-- EDA: User-level activity distribution, FinTech Pro accounts, period-over-period
SELECT
  u.id AS user_id,
  u.full_name,
  u.role,
  a.name AS account_name,
  COUNT(CASE WHEN e.occurred_at >= '2025-04-07' AND e.occurred_at < '2025-05-07' THEN 1 END) AS prior_30_events,
  COUNT(CASE WHEN e.occurred_at >= '2025-05-07' AND e.occurred_at < '2025-06-07' THEN 1 END) AS last_30_events
FROM users u
JOIN accounts a ON u.org_id = a.id
LEFT JOIN events e ON e.user_id = u.id
WHERE a.industry = 'FinTech' AND a.plan = 'pro'
GROUP BY u.id, u.full_name, u.role, a.name
ORDER BY a.name, prior_30_events DESC;
