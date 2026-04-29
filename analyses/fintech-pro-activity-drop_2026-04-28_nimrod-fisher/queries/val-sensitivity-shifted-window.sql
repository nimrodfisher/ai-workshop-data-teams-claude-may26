-- Val: Sensitivity — shift window boundary +2 weeks
SELECT
  SUM(CASE WHEN e.occurred_at >= '2025-04-21' AND e.occurred_at < '2025-05-21' THEN 1 ELSE 0 END) AS prior_shifted_30d,
  SUM(CASE WHEN e.occurred_at >= '2025-05-21' AND e.occurred_at < '2025-06-07' THEN 1 ELSE 0 END) AS last_shifted_16d,
  ROUND(100.0 * (SUM(CASE WHEN e.occurred_at >= '2025-05-21' AND e.occurred_at < '2025-06-07' THEN 1 ELSE 0 END) / 16.0
    - SUM(CASE WHEN e.occurred_at >= '2025-04-21' AND e.occurred_at < '2025-05-21' THEN 1 ELSE 0 END) / 30.0)
    / NULLIF(SUM(CASE WHEN e.occurred_at >= '2025-04-21' AND e.occurred_at < '2025-05-21' THEN 1 ELSE 0 END) / 30.0, 0), 1) AS pct_change_per_day
FROM events e
JOIN accounts a ON e.org_id = a.id
WHERE a.industry = 'FinTech' AND a.plan = 'pro';
