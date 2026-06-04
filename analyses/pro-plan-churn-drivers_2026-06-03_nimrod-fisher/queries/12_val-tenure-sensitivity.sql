-- Validation Check 1: Tenure threshold sensitivity
-- Tests whether the "57% in first 90 days" finding is robust to threshold changes
-- Phase: Validation (Check 12)

SELECT
  CASE
    WHEN EXTRACT(EPOCH FROM (s.canceled_at::timestamp - s.started_at::timestamp))/86400 <= 60  THEN '0-60 days'
    WHEN EXTRACT(EPOCH FROM (s.canceled_at::timestamp - s.started_at::timestamp))/86400 <= 90  THEN '61-90 days'
    WHEN EXTRACT(EPOCH FROM (s.canceled_at::timestamp - s.started_at::timestamp))/86400 <= 120 THEN '91-120 days'
    WHEN EXTRACT(EPOCH FROM (s.canceled_at::timestamp - s.started_at::timestamp))/86400 <= 180 THEN '121-180 days'
    WHEN EXTRACT(EPOCH FROM (s.canceled_at::timestamp - s.started_at::timestamp))/86400 <= 270 THEN '181-270 days'
    ELSE '270+ days'
  END AS tenure_bucket,
  COUNT(*) AS canceled_subs,
  ROUND(AVG(s.monthly_price)::numeric, 2) AS avg_monthly_price,
  MIN(EXTRACT(EPOCH FROM (s.canceled_at::timestamp - s.started_at::timestamp))/86400)::int AS min_days,
  MAX(EXTRACT(EPOCH FROM (s.canceled_at::timestamp - s.started_at::timestamp))/86400)::int AS max_days
FROM subscriptions s
JOIN accounts a ON s.org_id = a.id
WHERE a.plan = 'pro'
  AND s.status = 'canceled'
  AND s.canceled_at IS NOT NULL
GROUP BY 1
ORDER BY MIN(EXTRACT(EPOCH FROM (s.canceled_at::timestamp - s.started_at::timestamp))/86400);
