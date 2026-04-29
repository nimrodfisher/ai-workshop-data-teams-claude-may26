-- DA: H2 seat churn — active user count and role breakdown per account per period
SELECT
  a.name AS account_name,
  u.role,
  COUNT(DISTINCT CASE WHEN e.occurred_at >= '2025-04-07' AND e.occurred_at < '2025-05-07' THEN u.id END) AS prior_active_users,
  COUNT(DISTINCT CASE WHEN e.occurred_at >= '2025-05-07' AND e.occurred_at < '2025-06-07' THEN u.id END) AS last_active_users,
  COUNT(DISTINCT u.id) AS total_users_in_role
FROM accounts a
JOIN users u ON u.org_id = a.id
LEFT JOIN events e ON e.user_id = u.id
WHERE a.industry = 'FinTech' AND a.plan = 'pro'
GROUP BY a.name, u.role
ORDER BY a.name, u.role;
