-- EDA-01: Account tenure and industry — all pro subscriptions
SELECT
  a.id,
  a.name,
  a.industry,
  s.status,
  s.started_at,
  s.canceled_at,
  CASE
    WHEN s.canceled_at IS NOT NULL
      THEN ROUND((s.canceled_at - s.started_at) / 30.0, 1)
    ELSE ROUND((CURRENT_DATE - s.started_at) / 30.0, 1)
  END AS tenure_months,
  s.monthly_price
FROM accounts a
JOIN subscriptions s ON s.org_id = a.id
WHERE a.plan = 'pro'
ORDER BY s.status, tenure_months;
