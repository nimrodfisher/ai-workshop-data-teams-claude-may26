-- Val: ZGarcia api_call weekly timeline — when did the API integration stop?
SELECT
  DATE_TRUNC('week', e.occurred_at)::date AS week_start,
  COUNT(*) AS api_calls
FROM events e
JOIN accounts a ON e.org_id = a.id
WHERE a.name = 'ZGarcia Corp' AND e.event_type = 'api_call'
GROUP BY DATE_TRUNC('week', e.occurred_at)
ORDER BY week_start;
