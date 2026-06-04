-- EDA-04: Event type breakdown — churned vs retained pro accounts
WITH pro_accounts AS (
  SELECT
    a.id AS org_id,
    CASE
      WHEN MAX(s.status) FILTER (WHERE s.status = 'canceled') IS NOT NULL
        AND MAX(s.canceled_at) >= '2025-04-06'
      THEN 'churned'
      WHEN MAX(s.status) FILTER (WHERE s.status = 'active') IS NOT NULL
      THEN 'retained'
      ELSE 'other'
    END AS churn_group
  FROM accounts a
  JOIN subscriptions s ON s.org_id = a.id
  WHERE a.plan = 'pro'
  GROUP BY a.id
)
SELECT
  pa.churn_group,
  e.event_type,
  COUNT(*) AS event_count,
  COUNT(DISTINCT e.org_id) AS accounts_with_event
FROM pro_accounts pa
JOIN events e ON e.org_id = pa.org_id
  AND e.occurred_at BETWEEN '2025-03-07' AND '2025-06-06'
WHERE pa.churn_group IN ('churned', 'retained')
GROUP BY pa.churn_group, e.event_type
ORDER BY pa.churn_group, event_count DESC;
