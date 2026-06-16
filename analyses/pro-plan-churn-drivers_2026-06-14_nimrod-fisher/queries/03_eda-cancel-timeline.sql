-- 03_eda-cancel-timeline: Pro cancellations by month
WITH pro_cancels AS (
  SELECT DATE_TRUNC('month', s.canceled_at)::date AS month, s.monthly_price
  FROM subscriptions s JOIN accounts a ON s.org_id=a.id
  WHERE a.plan='pro' AND s.status='canceled'
)
SELECT month,
  COUNT(*) AS cancels,
  COUNT(*) FILTER (WHERE monthly_price=199) AS cancels_199,
  COUNT(*) FILTER (WHERE monthly_price=79)  AS cancels_79
FROM pro_cancels
GROUP BY month
ORDER BY month;
-- grain: one row per cancellation month
