-- 00_qa-product-mapping: how Pro sub monthly_price maps to catalog product/price
WITH pro_subs AS (
  SELECT s.product_id, s.monthly_price
  FROM subscriptions s
  JOIN accounts a ON s.org_id = a.id
  WHERE a.plan = 'pro'
)
SELECT
  p.name AS product_name,
  p.price_monthly AS catalog_price,
  ps.monthly_price AS sub_price,
  COUNT(*) AS subs
FROM pro_subs ps
LEFT JOIN products p ON ps.product_id = p.id
GROUP BY p.name, p.price_monthly, ps.monthly_price
ORDER BY subs DESC;
-- grain: one row per (product, catalog_price, sub_price) among Pro subs.
-- Finding: catalog price (99/49) never equals the agreed sub price (29/79/199);
-- same product_id appears at multiple sub prices => products table is NOT the price-tier source.
