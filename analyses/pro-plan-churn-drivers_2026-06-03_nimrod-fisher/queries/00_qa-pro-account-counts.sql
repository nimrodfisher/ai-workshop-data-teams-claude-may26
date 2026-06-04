-- QA-01: PRO account subscription counts by status
SELECT
  s.status,
  COUNT(DISTINCT a.id) AS account_count,
  COUNT(s.id) AS subscription_count,
  MIN(s.started_at) AS earliest_start,
  MAX(s.started_at) AS latest_start,
  MIN(s.canceled_at) AS earliest_cancel,
  MAX(s.canceled_at) AS latest_cancel,
  ROUND(AVG(s.monthly_price), 2) AS avg_monthly_price
FROM accounts a
JOIN subscriptions s ON s.org_id = a.id
WHERE a.plan = 'pro'
GROUP BY s.status
ORDER BY s.status;
