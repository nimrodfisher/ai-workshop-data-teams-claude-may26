-- EDA 24: complaint-category mix (bug vs billing) by accounts.plan
SELECT
  a.plan,
  st.category,
  COUNT(*) AS tickets,
  COUNT(DISTINCT st.opened_by) AS distinct_users
FROM support_tickets st
JOIN users u ON st.opened_by = u.id
JOIN accounts a ON u.org_id = a.id
WHERE st.category IN ('bug','billing')
  AND st.opened_by IS NOT NULL
  AND st.opened_at >= '2024-06-17' AND st.opened_at <= '2025-06-17'
GROUP BY a.plan, st.category
ORDER BY a.plan, st.category;
