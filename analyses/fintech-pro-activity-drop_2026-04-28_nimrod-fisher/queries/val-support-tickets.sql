-- Val: Support tickets for FinTech Pro accounts in last 60 days
SELECT
  a.name AS account_name,
  st.category,
  st.status,
  st.opened_at::date AS opened_date,
  st.closed_at::date AS closed_date
FROM support_tickets st
JOIN accounts a ON st.org_id = a.id
WHERE a.industry = 'FinTech' AND a.plan = 'pro'
  AND st.opened_at >= '2025-04-07'
ORDER BY st.opened_at DESC;
