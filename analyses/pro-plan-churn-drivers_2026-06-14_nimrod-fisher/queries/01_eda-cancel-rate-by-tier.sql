-- 01_eda-cancel-rate-by-tier: cancel rate by monthly_price tier (H1), Pro subs
WITH pro_subs AS (
  SELECT s.monthly_price, s.status
  FROM subscriptions s JOIN accounts a ON s.org_id=a.id
  WHERE a.plan='pro'
)
SELECT
  monthly_price,
  COUNT(*) FILTER (WHERE status='active')   AS active,
  COUNT(*) FILTER (WHERE status='canceled') AS canceled,
  COUNT(*) FILTER (WHERE status='trialing') AS trialing,
  ROUND(100.0 * COUNT(*) FILTER (WHERE status='canceled')
        / NULLIF(COUNT(*) FILTER (WHERE status IN ('active','canceled')),0), 1) AS cancel_rate_pct
FROM pro_subs
GROUP BY monthly_price
ORDER BY monthly_price;
-- grain: one row per price tier; cancel_rate = canceled / (active+canceled)
