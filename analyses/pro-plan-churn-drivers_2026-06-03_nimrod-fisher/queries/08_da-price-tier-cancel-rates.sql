-- DA-08: Cancel rates by price tier for PRO subscriptions
WITH sub_groups AS (
  SELECT
    s.monthly_price,
    s.status,
    COUNT(*) AS count
  FROM subscriptions s
  JOIN accounts a ON s.org_id = a.id
  WHERE a.plan = 'pro'
  GROUP BY s.monthly_price, s.status
)
SELECT
  monthly_price,
  SUM(count) FILTER (WHERE status = 'active') AS active_count,
  SUM(count) FILTER (WHERE status = 'canceled') AS canceled_count,
  SUM(count) FILTER (WHERE status = 'trialing') AS trialing_count,
  SUM(count) AS total_count,
  ROUND(100.0 * SUM(count) FILTER (WHERE status = 'canceled') /
    NULLIF(SUM(count) FILTER (WHERE status IN ('active','canceled')), 0), 1) AS cancel_rate_pct
FROM sub_groups
GROUP BY monthly_price
ORDER BY monthly_price;
