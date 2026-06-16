-- 08_da-tier-rates: cancel rate, premium($79/$199) vs entry($29) 2x2 components (H1)
WITH pro_subs AS (
  SELECT s.monthly_price, s.status
  FROM subscriptions s JOIN accounts a ON s.org_id=a.id
  WHERE a.plan='pro' AND s.status IN ('active','canceled')
)
SELECT
  CASE WHEN monthly_price=29 THEN 'entry_$29' ELSE 'premium_$79+$199' END AS tier_group,
  COUNT(*) FILTER (WHERE status='canceled') AS canceled,
  COUNT(*) AS denom_active_plus_canceled,
  ROUND(100.0*COUNT(*) FILTER (WHERE status='canceled')/COUNT(*),1) AS cancel_rate_pct
FROM pro_subs
GROUP BY 1
ORDER BY 1;
-- grain: one row per tier group; denom excludes trialing
