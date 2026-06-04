-- EDA-07: Churn timeline — monthly cancellations for pro accounts
SELECT
  DATE_TRUNC('month', s.canceled_at)::date AS churn_month,
  COUNT(*) AS canceled_subscriptions,
  STRING_AGG(a.name, ', ' ORDER BY a.name) AS account_names
FROM subscriptions s
JOIN accounts a ON s.org_id = a.id
WHERE a.plan = 'pro' AND s.status = 'canceled'
GROUP BY DATE_TRUNC('month', s.canceled_at)
ORDER BY churn_month;
