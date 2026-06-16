-- 00_qa-support-coverage: support ticket presence and completeness for Pro accounts
WITH pro AS (SELECT id FROM accounts WHERE plan='pro')
SELECT
  (SELECT COUNT(*) FROM pro) AS pro_accounts,
  COUNT(t.id) AS pro_tickets,
  COUNT(DISTINCT t.org_id) AS pro_accounts_with_tickets,
  MIN(t.opened_at)::date AS earliest_ticket,
  MAX(t.opened_at)::date AS latest_ticket,
  COUNT(*) FILTER (WHERE t.category IS NULL) AS null_category,
  COUNT(*) FILTER (WHERE t.opened_by IS NULL) AS null_opened_by
FROM pro
LEFT JOIN support_tickets t ON t.org_id = pro.id;
-- grain: one summary row over Pro-account support tickets
