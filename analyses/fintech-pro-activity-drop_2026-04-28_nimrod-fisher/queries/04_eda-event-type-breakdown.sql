-- EDA: Event-type breakdown, prior-30 vs last-30, FinTech Pro
SELECT
  e.event_type,
  SUM(CASE WHEN e.occurred_at >= '2025-04-07' AND e.occurred_at < '2025-05-07' THEN 1 ELSE 0 END) AS prior_30,
  SUM(CASE WHEN e.occurred_at >= '2025-05-07' AND e.occurred_at < '2025-06-07' THEN 1 ELSE 0 END) AS last_30,
  ROUND(100.0 * (
    SUM(CASE WHEN e.occurred_at >= '2025-05-07' AND e.occurred_at < '2025-06-07' THEN 1 ELSE 0 END)
    - SUM(CASE WHEN e.occurred_at >= '2025-04-07' AND e.occurred_at < '2025-05-07' THEN 1 ELSE 0 END))
    / NULLIF(SUM(CASE WHEN e.occurred_at >= '2025-04-07' AND e.occurred_at < '2025-05-07' THEN 1 ELSE 0 END), 0), 1) AS pct_change
FROM events e
JOIN accounts a ON e.org_id = a.id
WHERE a.industry = 'FinTech' AND a.plan = 'pro'
GROUP BY e.event_type
ORDER BY prior_30 DESC;
