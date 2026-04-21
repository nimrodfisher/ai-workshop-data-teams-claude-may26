-- QA 12: primary-key uniqueness per table
SELECT 'support_tickets' AS tbl, COUNT(*) AS total, COUNT(DISTINCT id) AS distinct_ids, COUNT(*) - COUNT(DISTINCT id) AS duplicate_ids FROM support_tickets
UNION ALL SELECT 'users', COUNT(*), COUNT(DISTINCT id), COUNT(*) - COUNT(DISTINCT id) FROM users
UNION ALL SELECT 'accounts', COUNT(*), COUNT(DISTINCT id), COUNT(*) - COUNT(DISTINCT id) FROM accounts
UNION ALL SELECT 'events', COUNT(*), COUNT(DISTINCT id), COUNT(*) - COUNT(DISTINCT id) FROM events
UNION ALL SELECT 'subscriptions', COUNT(*), COUNT(DISTINCT id), COUNT(*) - COUNT(DISTINCT id) FROM subscriptions
UNION ALL SELECT 'invoices', COUNT(*), COUNT(DISTINCT id), COUNT(*) - COUNT(DISTINCT id) FROM invoices;
