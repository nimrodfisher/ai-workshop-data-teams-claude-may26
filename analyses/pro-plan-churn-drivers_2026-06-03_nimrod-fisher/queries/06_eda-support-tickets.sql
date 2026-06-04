-- EDA-06: Support ticket patterns — churned vs retained pro accounts
WITH pro_account_groups AS (
  SELECT
    a.id AS org_id,
    CASE
      WHEN EXISTS (
        SELECT 1 FROM subscriptions s2
        WHERE s2.org_id = a.id AND s2.status = 'canceled'
      ) AND NOT EXISTS (
        SELECT 1 FROM subscriptions s2
        WHERE s2.org_id = a.id AND s2.status = 'active'
      ) THEN 'churned'
      WHEN EXISTS (
        SELECT 1 FROM subscriptions s2
        WHERE s2.org_id = a.id AND s2.status = 'active'
      ) THEN 'retained'
      ELSE 'other'
    END AS churn_group
  FROM accounts a
  WHERE a.plan = 'pro'
)
SELECT
  pag.churn_group,
  st.category,
  COUNT(*) AS ticket_count,
  COUNT(DISTINCT pag.org_id) AS accounts_with_ticket_type
FROM pro_account_groups pag
LEFT JOIN support_tickets st ON st.org_id = pag.org_id
WHERE pag.churn_group IN ('churned', 'retained')
GROUP BY pag.churn_group, st.category
ORDER BY pag.churn_group, ticket_count DESC;
