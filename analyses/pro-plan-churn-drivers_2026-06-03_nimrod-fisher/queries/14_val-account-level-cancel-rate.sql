-- Validation Check 3: Account-level vs subscription-level cancel rates
-- Tests whether the price-tier gradient persists when aggregated at the account (not subscription) level
-- Phase: Validation (Check 14)

WITH account_subs AS (
  SELECT
    a.id AS org_id,
    a.name AS account_name,
    MAX(s.monthly_price) AS max_price,
    COUNT(CASE WHEN s.status = 'canceled' THEN 1 END) AS canceled_count,
    COUNT(CASE WHEN s.status = 'active' THEN 1 END) AS active_count,
    CASE WHEN COUNT(CASE WHEN s.status = 'canceled' THEN 1 END) > 0 THEN 1 ELSE 0 END AS has_canceled
  FROM accounts a
  JOIN subscriptions s ON a.id = s.org_id
  WHERE a.plan = 'pro'
    AND s.status IN ('active', 'canceled')
  GROUP BY a.id, a.name
)
SELECT
  CASE WHEN max_price = 29 THEN '$29' WHEN max_price = 79 THEN '$79' ELSE '$199' END AS max_price_tier,
  COUNT(*) AS accounts,
  SUM(has_canceled) AS accounts_with_cancel,
  ROUND(SUM(has_canceled)::numeric / COUNT(*) * 100, 1) AS pct_with_cancel
FROM account_subs
GROUP BY max_price
ORDER BY max_price;
