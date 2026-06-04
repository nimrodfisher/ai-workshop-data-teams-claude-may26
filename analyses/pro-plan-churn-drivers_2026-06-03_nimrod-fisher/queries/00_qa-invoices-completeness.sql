-- QA-05: Invoices completeness for pro accounts
SELECT
  COUNT(*) AS total_invoices,
  COUNT(*) FILTER (WHERE amount IS NULL) AS null_amount,
  COUNT(*) FILTER (WHERE amount <= 0) AS zero_or_neg_amount,
  COUNT(*) FILTER (WHERE issued_at IS NULL) AS null_issued_at,
  COUNT(*) FILTER (WHERE paid_at IS NULL) AS unpaid_invoices,
  ROUND(100.0 * COUNT(*) FILTER (WHERE paid_at IS NULL) / NULLIF(COUNT(*), 0), 1) AS unpaid_pct,
  COUNT(DISTINCT subscription_id) AS subscriptions_with_invoices,
  MIN(issued_at) AS earliest_invoice,
  MAX(issued_at) AS latest_invoice
FROM invoices
WHERE subscription_id IN (
  SELECT s.id FROM subscriptions s
  JOIN accounts a ON s.org_id = a.id
  WHERE a.plan = 'pro'
);
