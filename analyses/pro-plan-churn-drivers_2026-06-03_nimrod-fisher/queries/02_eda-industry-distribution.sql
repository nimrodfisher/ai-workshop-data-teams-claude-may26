-- EDA-02: Industry distribution — churned vs active pro accounts
WITH account_status AS (
  SELECT
    a.id,
    a.industry,
    MAX(CASE WHEN s.status = 'canceled' THEN 1 ELSE 0 END) AS has_canceled,
    MAX(CASE WHEN s.status = 'active' THEN 1 ELSE 0 END) AS has_active
  FROM accounts a
  JOIN subscriptions s ON s.org_id = a.id
  WHERE a.plan = 'pro'
  GROUP BY a.id, a.industry
)
SELECT
  industry,
  COUNT(*) FILTER (WHERE has_canceled = 1 AND has_active = 0) AS churned_only,
  COUNT(*) FILTER (WHERE has_active = 1) AS retained,
  COUNT(*) AS total
FROM account_status
GROUP BY industry
ORDER BY total DESC;
