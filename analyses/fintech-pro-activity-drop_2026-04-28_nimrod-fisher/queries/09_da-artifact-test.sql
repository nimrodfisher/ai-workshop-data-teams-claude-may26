-- DA: H0 artifact test — restrict both windows to first 25 days (trimming last 5)
-- If drop persists, it is not an end-of-window artifact
SELECT
  SUM(CASE WHEN e.occurred_at >= '2025-04-07' AND e.occurred_at < '2025-05-02' THEN 1 ELSE 0 END) AS prior_25_events,
  SUM(CASE WHEN e.occurred_at >= '2025-05-07' AND e.occurred_at < '2025-06-01' THEN 1 ELSE 0 END) AS last_25_events,
  ROUND(100.0 * (
    SUM(CASE WHEN e.occurred_at >= '2025-05-07' AND e.occurred_at < '2025-06-01' THEN 1 ELSE 0 END)
    - SUM(CASE WHEN e.occurred_at >= '2025-04-07' AND e.occurred_at < '2025-05-02' THEN 1 ELSE 0 END))
    / NULLIF(SUM(CASE WHEN e.occurred_at >= '2025-04-07' AND e.occurred_at < '2025-05-02' THEN 1 ELSE 0 END), 0), 1) AS pct_change_trimmed
FROM events e
JOIN accounts a ON e.org_id = a.id
WHERE a.industry = 'FinTech' AND a.plan = 'pro';
