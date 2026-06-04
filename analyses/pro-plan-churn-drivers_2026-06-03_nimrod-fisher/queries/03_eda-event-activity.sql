-- EDA-03: Event activity — churned vs retained pro accounts (H1 window)
WITH pro_accounts AS (
  SELECT
    a.id AS org_id,
    a.name,
    CASE
      WHEN MAX(s.status) FILTER (WHERE s.status = 'canceled') IS NOT NULL
        AND MAX(s.canceled_at) >= '2025-04-06'
      THEN 'churned'
      WHEN MAX(s.status) FILTER (WHERE s.status = 'active') IS NOT NULL
      THEN 'retained'
      ELSE 'other'
    END AS churn_group,
    MAX(s.canceled_at) AS canceled_at
  FROM accounts a
  JOIN subscriptions s ON s.org_id = a.id
  WHERE a.plan = 'pro'
  GROUP BY a.id, a.name
)
SELECT
  pa.churn_group,
  pa.org_id,
  pa.name,
  COUNT(e.id) AS total_events,
  COUNT(DISTINCT e.user_id) AS active_users,
  COUNT(DISTINCT DATE_TRUNC('week', e.occurred_at)) AS active_weeks,
  MIN(e.occurred_at)::date AS first_event,
  MAX(e.occurred_at)::date AS last_event
FROM pro_accounts pa
LEFT JOIN events e ON e.org_id = pa.org_id
  AND e.occurred_at BETWEEN '2025-03-07' AND '2025-06-06'
WHERE pa.churn_group IN ('churned', 'retained')
GROUP BY pa.churn_group, pa.org_id, pa.name
ORDER BY pa.churn_group, total_events DESC;
