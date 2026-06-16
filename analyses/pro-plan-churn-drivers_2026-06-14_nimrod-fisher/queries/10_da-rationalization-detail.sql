-- 10_da-rationalization-detail: per account that canceled, what it dropped vs what it kept (H0)
WITH pro AS (SELECT id, name, industry FROM accounts WHERE plan='pro'),
agg AS (
  SELECT pro.id AS org_id, pro.industry,
    STRING_AGG(CASE WHEN s.status='canceled' THEN s.monthly_price::text END, ' + ' ORDER BY s.monthly_price) AS canceled_prices,
    STRING_AGG(CASE WHEN s.status='active' THEN s.monthly_price::text END, ' + ' ORDER BY s.monthly_price) AS active_prices,
    COUNT(*) FILTER (WHERE s.status='canceled') AS n_canceled,
    COUNT(*) FILTER (WHERE s.status='active') AS n_active,
    MAX(s.canceled_at) AS last_cancel
  FROM pro JOIN subscriptions s ON s.org_id=pro.id
  GROUP BY pro.id, pro.industry
)
SELECT industry, n_canceled, canceled_prices, n_active, active_prices, last_cancel,
  CASE WHEN n_active=0 THEN 'true_logo_exit' ELSE 'rationalized' END AS outcome
FROM agg
WHERE n_canceled > 0
ORDER BY last_cancel;
-- grain: one row per Pro account that canceled >=1 subscription
