-- EDA 02: Complaint rate and ticket volume by plan
SELECT
  a.plan,
  COUNT(DISTINCT a.id) AS total_accounts,
  COUNT(DISTINCT st.org_id) AS accounts_with_tickets,
  ROUND(100.0 * COUNT(DISTINCT st.org_id) / COUNT(DISTINCT a.id), 1) AS complaint_rate_pct,
  COUNT(st.id) AS total_tickets,
  ROUND(COUNT(st.id)::numeric / COUNT(DISTINCT a.id), 2) AS avg_tickets_per_account
FROM accounts a
LEFT JOIN support_tickets st ON a.id = st.org_id
GROUP BY a.plan
ORDER BY avg_tickets_per_account DESC;
