-- QA-08: Support ticket categories and status for pro accounts
SELECT
  category,
  status,
  COUNT(*) AS ticket_count
FROM support_tickets
WHERE org_id IN (SELECT id FROM accounts WHERE plan = 'pro')
GROUP BY category, status
ORDER BY ticket_count DESC;
