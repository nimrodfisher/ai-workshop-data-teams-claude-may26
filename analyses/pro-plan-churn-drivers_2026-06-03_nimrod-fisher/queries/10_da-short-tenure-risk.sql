-- DA-10: Cancel rate by tenure bucket for PRO subscriptions
WITH tenure_buckets AS (
  SELECT
    s.id,
    s.status,
    s.monthly_price,
    CASE
      WHEN s.canceled_at IS NOT NULL THEN (s.canceled_at - s.started_at)
      ELSE (CURRENT_DATE - s.started_at)
    END AS tenure_days,
    CASE
      WHEN s.canceled_at IS NOT NULL AND (s.canceled_at - s.started_at) <= 30 THEN '0-1 month'
      WHEN s.canceled_at IS NOT NULL AND (s.canceled_at - s.started_at) <= 90 THEN '1-3 months'
      WHEN s.canceled_at IS NOT NULL AND (s.canceled_at - s.started_at) <= 180 THEN '3-6 months'
      WHEN s.canceled_at IS NOT NULL THEN '6+ months'
      ELSE 'still active'
    END AS tenure_bucket
  FROM subscriptions s
  JOIN accounts a ON s.org_id = a.id
  WHERE a.plan = 'pro' AND s.status IN ('active', 'canceled')
)
SELECT
  tenure_bucket,
  COUNT(*) AS subscription_count,
  COUNT(*) FILTER (WHERE status = 'canceled') AS canceled,
  ROUND(AVG(monthly_price), 0) AS avg_price
FROM tenure_buckets
GROUP BY tenure_bucket
ORDER BY
  CASE tenure_bucket
    WHEN '0-1 month' THEN 1
    WHEN '1-3 months' THEN 2
    WHEN '3-6 months' THEN 3
    WHEN '6+ months' THEN 4
    ELSE 5
  END;
