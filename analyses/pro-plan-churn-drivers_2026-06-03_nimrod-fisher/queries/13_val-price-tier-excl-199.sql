-- Validation Check 2: Price tier robustness — exclude $199 tier
-- Tests whether the $29 vs $79 price gradient holds independently of the dominant $199 segment
-- Phase: Validation (Check 13)

SELECT
  s.monthly_price,
  COUNT(CASE WHEN s.status = 'active' THEN 1 END) AS active_subs,
  COUNT(CASE WHEN s.status = 'canceled' THEN 1 END) AS canceled_subs,
  COUNT(*) AS total_subs,
  ROUND(
    COUNT(CASE WHEN s.status = 'canceled' THEN 1 END)::numeric / NULLIF(COUNT(*),0) * 100,
    1
  ) AS cancel_rate_pct
FROM subscriptions s
JOIN accounts a ON s.org_id = a.id
WHERE a.plan = 'pro'
  AND s.status IN ('active', 'canceled')
  AND s.monthly_price != 199
GROUP BY s.monthly_price
ORDER BY s.monthly_price;
