-- QA-02: Subscriptions completeness for pro accounts
SELECT
  COUNT(*) AS total_rows,
  COUNT(*) FILTER (WHERE org_id IS NULL) AS null_org_id,
  COUNT(*) FILTER (WHERE product_id IS NULL) AS null_product_id,
  COUNT(*) FILTER (WHERE status IS NULL) AS null_status,
  COUNT(*) FILTER (WHERE started_at IS NULL) AS null_started_at,
  COUNT(*) FILTER (WHERE canceled_at IS NULL) AS null_canceled_at,
  COUNT(*) FILTER (WHERE monthly_price IS NULL) AS null_monthly_price,
  COUNT(*) FILTER (WHERE monthly_price <= 0) AS zero_or_neg_price,
  COUNT(*) FILTER (WHERE canceled_at IS NOT NULL AND canceled_at < started_at) AS cancel_before_start
FROM subscriptions
WHERE org_id IN (SELECT id FROM accounts WHERE plan = 'pro');
