-- EDA 05: Ticket volume over time (monthly)
SELECT
  DATE_TRUNC('month', opened_at)::date AS month,
  COUNT(*) AS tickets_opened,
  COUNT(DISTINCT org_id) AS accounts_filing
FROM support_tickets
GROUP BY DATE_TRUNC('month', opened_at)
ORDER BY month;
