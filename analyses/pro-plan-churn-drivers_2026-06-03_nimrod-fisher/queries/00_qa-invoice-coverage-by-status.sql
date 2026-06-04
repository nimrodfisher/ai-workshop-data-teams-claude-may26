-- QA-10: Invoice coverage — churned vs active pro subscriptions
SELECT
  s.status,
  COUNT(DISTINCT s.id) AS subscriptions,
  COUNT(DISTINCT i.subscription_id) AS subscriptions_with_invoices,
  COUNT(i.id) AS total_invoices,
  ROUND(100.0 * COUNT(DISTINCT i.subscription_id) / NULLIF(COUNT(DISTINCT s.id), 0), 1) AS invoice_coverage_pct
FROM subscriptions s
LEFT JOIN invoices i ON i.subscription_id = s.id
WHERE s.org_id IN (SELECT id FROM accounts WHERE plan = 'pro')
GROUP BY s.status;
