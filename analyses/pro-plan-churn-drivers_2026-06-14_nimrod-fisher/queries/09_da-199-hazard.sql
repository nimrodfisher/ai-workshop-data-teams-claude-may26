-- 09_da-199-hazard: first-90-day cancellation hazard for $199 subs (H2)
-- eligible = started >=90d before snapshot 2025-06-17 (so a 90d window is observable)
WITH s199 AS (
  SELECT s.id, s.status, s.started_at, s.canceled_at
  FROM subscriptions s JOIN accounts a ON s.org_id=a.id
  WHERE a.plan='pro' AND s.monthly_price=199 AND s.status IN ('active','canceled')
)
SELECT
  COUNT(*) AS all_199_subs,
  COUNT(*) FILTER (WHERE started_at <= DATE '2025-06-17' - 90) AS eligible_observed_90d,
  COUNT(*) FILTER (WHERE status='canceled' AND (canceled_at - started_at) <= 90) AS canceled_within_90d,
  ROUND(100.0 * COUNT(*) FILTER (WHERE status='canceled' AND (canceled_at - started_at) <= 90)
        / NULLIF(COUNT(*) FILTER (WHERE started_at <= DATE '2025-06-17' - 90),0),1) AS hazard_90d_pct
FROM s199;
-- grain: one summary row over $199 Pro subs
