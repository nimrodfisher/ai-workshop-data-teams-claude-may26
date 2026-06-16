-- 02_eda-tenure: canceled-sub tenure (at cancel) vs active-sub tenure (as of 2025-06-17 snapshot), by tier
WITH pro_subs AS (
  SELECT s.status, s.monthly_price, s.started_at, s.canceled_at,
         CASE WHEN s.status='canceled' THEN (s.canceled_at - s.started_at)
              WHEN s.status='active'   THEN (DATE '2025-06-17' - s.started_at) END AS tenure_days
  FROM subscriptions s JOIN accounts a ON s.org_id=a.id
  WHERE a.plan='pro' AND s.status IN ('active','canceled')
)
SELECT status, monthly_price,
  COUNT(*) AS subs,
  ROUND(AVG(tenure_days)) AS avg_tenure_days,
  MIN(tenure_days) AS min_tenure,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY tenure_days) AS median_tenure,
  MAX(tenure_days) AS max_tenure,
  COUNT(*) FILTER (WHERE status='canceled' AND tenure_days <= 90) AS canceled_le_90d
FROM pro_subs
GROUP BY status, monthly_price
ORDER BY status, monthly_price;
-- grain: one row per (status, tier); active tenure measured to frozen snapshot 2025-06-17
