-- 00_qa-referential-integrity: orphan checks + duplicate primary keys
SELECT
  (SELECT COUNT(*) FROM subscriptions s LEFT JOIN accounts a ON s.org_id=a.id WHERE a.id IS NULL) AS subs_orphan_account,
  (SELECT COUNT(*) FROM support_tickets t LEFT JOIN accounts a ON t.org_id=a.id WHERE a.id IS NULL) AS tickets_orphan_account,
  (SELECT COUNT(*) FROM invoices i LEFT JOIN subscriptions s ON i.subscription_id=s.id WHERE s.id IS NULL) AS invoices_orphan_sub,
  (SELECT COUNT(*) FROM (SELECT id FROM subscriptions GROUP BY id HAVING COUNT(*)>1) d) AS duplicate_sub_ids,
  (SELECT COUNT(*) FROM (SELECT id FROM accounts GROUP BY id HAVING COUNT(*)>1) d) AS duplicate_account_ids;
-- grain: one summary row of referential-integrity counts
