-- DA-11: Ticket rate for accounts with vs without canceled subscriptions
WITH account_groups AS (
  SELECT
    a.id,
    a.name,
    CASE
      WHEN COUNT(s.id) FILTER (WHERE s.status = 'canceled') > 0 THEN 'has_canceled_sub'
      ELSE 'no_canceled_sub'
    END AS group_label,
    COUNT(DISTINCT st.id) AS ticket_count
  FROM accounts a
  JOIN subscriptions s ON s.org_id = a.id AND a.plan = 'pro'
  LEFT JOIN support_tickets st ON st.org_id = a.id
  GROUP BY a.id, a.name
)
SELECT
  group_label,
  COUNT(*) AS accounts,
  SUM(ticket_count) AS total_tickets,
  ROUND(AVG(ticket_count), 1) AS avg_tickets_per_account,
  COUNT(*) FILTER (WHERE ticket_count = 0) AS accounts_with_zero_tickets,
  MAX(ticket_count) AS max_tickets
FROM account_groups
GROUP BY group_label
ORDER BY group_label;
