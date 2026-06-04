-- QA-09: Referential integrity checks
SELECT
  (SELECT COUNT(*) FROM subscriptions WHERE org_id NOT IN (SELECT id FROM accounts)) AS orphan_subscriptions,
  (SELECT COUNT(*) FROM invoices WHERE subscription_id NOT IN (SELECT id FROM subscriptions)) AS orphan_invoices,
  (SELECT COUNT(*) FROM support_tickets WHERE org_id NOT IN (SELECT id FROM accounts)) AS orphan_tickets,
  (SELECT COUNT(*) FROM events WHERE org_id NOT IN (SELECT id FROM accounts)) AS orphan_events,
  (SELECT COUNT(*) FROM (SELECT id, COUNT(*) FROM subscriptions GROUP BY id HAVING COUNT(*) > 1) x) AS dup_subscription_ids;
