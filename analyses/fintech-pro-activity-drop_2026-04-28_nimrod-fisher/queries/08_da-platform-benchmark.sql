-- DA: H4 platform benchmark — period drop for FinTech Pro vs all other accounts
SELECT
  CASE WHEN a.industry = 'FinTech' AND a.plan = 'pro' THEN 'FinTech Pro' ELSE 'All Others' END AS segment,
  SUM(CASE WHEN e.occurred_at >= '2025-04-07' AND e.occurred_at < '2025-05-07' THEN 1 ELSE 0 END) AS prior_30,
  SUM(CASE WHEN e.occurred_at >= '2025-05-07' AND e.occurred_at < '2025-06-07' THEN 1 ELSE 0 END) AS last_30,
  ROUND(100.0 * (
    SUM(CASE WHEN e.occurred_at >= '2025-05-07' AND e.occurred_at < '2025-06-07' THEN 1 ELSE 0 END)
    - SUM(CASE WHEN e.occurred_at >= '2025-04-07' AND e.occurred_at < '2025-05-07' THEN 1 ELSE 0 END))
    / NULLIF(SUM(CASE WHEN e.occurred_at >= '2025-04-07' AND e.occurred_at < '2025-05-07' THEN 1 ELSE 0 END), 0), 1) AS pct_change
FROM events e
JOIN accounts a ON e.org_id = a.id
GROUP BY CASE WHEN a.industry = 'FinTech' AND a.plan = 'pro' THEN 'FinTech Pro' ELSE 'All Others' END;
