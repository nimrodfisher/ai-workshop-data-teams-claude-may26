-- EDA 01: Ticket volume distribution per account
SELECT
  ticket_count,
  COUNT(*) AS accounts
FROM (
  SELECT
    a.id,
    COUNT(st.id) AS ticket_count
  FROM accounts a
  LEFT JOIN support_tickets st ON a.id = st.org_id
  GROUP BY a.id
) sub
GROUP BY ticket_count
ORDER BY ticket_count;
