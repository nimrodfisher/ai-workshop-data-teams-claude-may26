-- QA 09: referential integrity — orphan rows & unresolvable joins
SELECT
  (SELECT COUNT(*) FROM users u LEFT JOIN accounts a ON u.org_id = a.id WHERE a.id IS NULL) AS orphan_users_no_account,
  (SELECT COUNT(*) FROM support_tickets st LEFT JOIN users u ON st.opened_by = u.id WHERE u.id IS NULL) AS tickets_with_unresolvable_user,
  (SELECT COUNT(*) FROM support_tickets st LEFT JOIN accounts a ON st.org_id = a.id WHERE a.id IS NULL) AS tickets_with_unresolvable_account,
  (SELECT COUNT(DISTINCT user_id) FROM events WHERE user_id IS NOT NULL AND user_id NOT IN (SELECT id FROM users)) AS events_users_not_in_users_table,
  (SELECT COUNT(*) FROM invoices i LEFT JOIN subscriptions s ON i.subscription_id = s.id WHERE s.id IS NULL) AS invoices_with_unresolvable_subscription;
