-- 12_val-tier-cohort-confound: is $199 churn really a newer-cohort (tenure) effect in disguise?
WITH pro_subs AS (
  SELECT s.monthly_price, s.started_at,
         (DATE '2025-06-17' - s.started_at) AS age_days
  FROM subscriptions s JOIN accounts a ON s.org_id=a.id
  WHERE a.plan='pro' AND s.status IN ('active','canceled')
)
SELECT monthly_price,
  COUNT(*) AS subs,
  MIN(started_at) AS earliest_start,
  MAX(started_at) AS latest_start,
  ROUND(AVG(age_days)) AS avg_age_days,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY age_days) AS median_age_days
FROM pro_subs
GROUP BY monthly_price
ORDER BY monthly_price;
-- grain: one row per tier; age measured from start to 2025-06-17 snapshot
