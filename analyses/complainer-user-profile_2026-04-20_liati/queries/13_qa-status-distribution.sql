-- QA 13: support_tickets.status value distribution
SELECT status, COUNT(*) AS ticket_count
FROM support_tickets
GROUP BY status
ORDER BY ticket_count DESC;
