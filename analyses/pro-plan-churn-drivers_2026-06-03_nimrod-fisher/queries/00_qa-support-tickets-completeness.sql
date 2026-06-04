-- QA-06: Support tickets completeness for pro accounts
SELECT
  COUNT(*) AS total_tickets,
  COUNT(DISTINCT org_id) AS pro_accounts_with_tickets,
  (SELECT COUNT(*) FROM accounts WHERE plan = 'pro') AS total_pro_accounts,
  COUNT(*) FILTER (WHERE opened_at IS NULL) AS null_opened_at,
  COUNT(*) FILTER (WHERE category IS NULL) AS null_category,
  COUNT(*) FILTER (WHERE status IS NULL) AS null_status,
  COUNT(*) FILTER (WHERE closed_at IS NULL) AS open_tickets,
  ROUND(100.0 * COUNT(*) FILTER (WHERE closed_at IS NULL) / NULLIF(COUNT(*), 0), 1) AS open_pct,
  MIN(opened_at)::date AS earliest_ticket,
  MAX(opened_at)::date AS latest_ticket
FROM support_tickets
WHERE org_id IN (SELECT id FROM accounts WHERE plan = 'pro');
