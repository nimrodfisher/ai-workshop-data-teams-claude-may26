-- DA: H3 event-type split per account — confirm pattern holds at account level
SELECT
  a.name AS account_name,
  e.event_type,
  SUM(CASE WHEN e.occurred_at >= '2025-04-07' AND e.occurred_at < '2025-05-07' THEN 1 ELSE 0 END) AS prior_30,
  SUM(CASE WHEN e.occurred_at >= '2025-05-07' AND e.occurred_at < '2025-06-07' THEN 1 ELSE 0 END) AS last_30
FROM events e
JOIN accounts a ON e.org_id = a.id
WHERE a.industry = 'FinTech' AND a.plan = 'pro'
GROUP BY a.name, e.event_type
ORDER BY a.name, prior_30 DESC;
