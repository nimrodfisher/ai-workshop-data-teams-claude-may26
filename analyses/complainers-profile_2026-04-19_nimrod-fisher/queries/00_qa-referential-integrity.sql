-- QA: Referential integrity — support_tickets → accounts
SELECT
  COUNT(DISTINCT st.org_id) AS orgs_with_tickets,
  COUNT(DISTINCT CASE WHEN a.id IS NOT NULL THEN st.org_id END) AS matched_orgs,
  COUNT(DISTINCT CASE WHEN a.id IS NULL THEN st.org_id END) AS orphaned_orgs
FROM support_tickets st
LEFT JOIN accounts a ON st.org_id = a.id;

-- QA: Events coverage per account
SELECT
  COUNT(DISTINCT org_id) AS orgs_in_events,
  (SELECT COUNT(*) FROM accounts) AS total_accounts
FROM events;

-- QA: Complainer vs non-complainer split
SELECT
  COUNT(DISTINCT st.org_id) AS complainer_orgs,
  (SELECT COUNT(*) FROM accounts) - COUNT(DISTINCT st.org_id) AS non_complainer_orgs
FROM support_tickets st;
