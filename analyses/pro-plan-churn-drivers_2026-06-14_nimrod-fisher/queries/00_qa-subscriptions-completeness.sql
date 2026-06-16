-- 00_qa-subscriptions-completeness: null counts in key columns for Pro-account subs
WITH pro_subs AS (
  SELECT s.id, s.org_id, s.product_id, s.status, s.started_at, s.canceled_at, s.monthly_price
  FROM subscriptions s
  JOIN accounts a ON s.org_id = a.id
  WHERE a.plan = 'pro'
)
SELECT
  COUNT(*) AS pro_subs,
  COUNT(*) FILTER (WHERE org_id IS NULL) AS null_org_id,
  COUNT(*) FILTER (WHERE product_id IS NULL) AS null_product_id,
  COUNT(*) FILTER (WHERE status IS NULL) AS null_status,
  COUNT(*) FILTER (WHERE started_at IS NULL) AS null_started_at,
  COUNT(*) FILTER (WHERE monthly_price IS NULL) AS null_monthly_price,
  COUNT(*) FILTER (WHERE status='canceled' AND canceled_at IS NULL) AS canceled_missing_date,
  COUNT(*) FILTER (WHERE status='active' AND canceled_at IS NOT NULL) AS active_with_cancel_date
FROM pro_subs;
-- grain: one summary row over Pro-account subscriptions
