-- Validation Check 4: Industry distribution robustness
-- Tests whether "even industry distribution" of cancels is a real finding or a small-n artifact
-- Phase: Validation (Check 15)

SELECT
  a.industry,
  COUNT(DISTINCT a.id) AS total_pro_accounts,
  COUNT(DISTINCT CASE WHEN EXISTS(
    SELECT 1 FROM subscriptions s2
    WHERE s2.org_id = a.id AND s2.status = 'canceled'
  ) THEN a.id END) AS accounts_with_cancel,
  ROUND(
    COUNT(DISTINCT CASE WHEN EXISTS(
      SELECT 1 FROM subscriptions s2
      WHERE s2.org_id = a.id AND s2.status = 'canceled'
    ) THEN a.id END)::numeric /
    NULLIF(COUNT(DISTINCT a.id), 0) * 100,
    1
  ) AS cancel_rate_pct
FROM accounts a
WHERE a.plan = 'pro'
GROUP BY a.industry
ORDER BY cancel_rate_pct DESC NULLS LAST;
