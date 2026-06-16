-- 00_qa-product-join: product_id join coverage and price consistency for Pro subs
WITH pro_subs AS (
  SELECT s.id, s.product_id, s.monthly_price
  FROM subscriptions s
  JOIN accounts a ON s.org_id = a.id
  WHERE a.plan = 'pro'
)
SELECT
  COUNT(*) AS pro_subs,
  COUNT(p.id) AS matched_product,
  COUNT(*) - COUNT(p.id) AS orphaned_product_fk,
  COUNT(*) FILTER (WHERE p.id IS NOT NULL AND ps.monthly_price <> p.price_monthly) AS price_mismatch_vs_catalog
FROM pro_subs ps
LEFT JOIN products p ON ps.product_id = p.id;
-- grain: one summary row; checks subscriptions.product_id -> products.id (no explicit FK in schema)
