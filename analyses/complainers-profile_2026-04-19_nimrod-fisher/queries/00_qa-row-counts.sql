-- QA: Row counts across all analysis tables
SELECT 'accounts' AS tbl, COUNT(*) AS rows FROM accounts
UNION ALL SELECT 'users', COUNT(*) FROM users
UNION ALL SELECT 'events', COUNT(*) FROM events
UNION ALL SELECT 'subscriptions', COUNT(*) FROM subscriptions
UNION ALL SELECT 'support_tickets', COUNT(*) FROM support_tickets;
