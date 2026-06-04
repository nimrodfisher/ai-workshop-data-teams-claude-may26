-- EDA-05: Invoice patterns — churned vs retained pro accounts (H2 reframed)
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
  COUNT(DISTINCT pag.org_id) AS accounts,
  COUNT(i.id) AS total_invoices,
  ROUND(AVG(i.amount), 2) AS avg_invoice_amount,
  ROUND(MIN(i.amount), 2) AS min_invoice_amount,
  ROUND(MAX(i.amount), 2) AS max_invoice_amount,
  ROUND(AVG(s.monthly_price), 2) AS avg_monthly_price
FROM pro_account_groups pag
JOIN subscriptions s ON s.org_id = pag.org_id
LEFT JOIN invoices i ON i.subscription_id = s.id
WHERE pag.churn_group IN ('churned', 'retained')
GROUP BY pag.churn_group;
