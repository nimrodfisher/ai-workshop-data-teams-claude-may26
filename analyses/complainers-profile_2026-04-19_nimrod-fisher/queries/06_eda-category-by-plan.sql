-- EDA 06: Ticket category by plan
SELECT
  a.plan,
  st.category,
  COUNT(*) AS tickets
FROM support_tickets st
JOIN accounts a ON st.org_id = a.id
GROUP BY a.plan, st.category
ORDER BY a.plan, tickets DESC;
