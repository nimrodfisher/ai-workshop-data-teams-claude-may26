-- EDA 25: monthly ticket volume — complaint vs all tickets (sanity time-pattern check)
SELECT
  DATE_TRUNC('month', opened_at)::date AS month,
  COUNT(*) FILTER (WHERE category IN ('bug','billing')) AS complaint_tickets,
  COUNT(*) AS all_tickets
FROM support_tickets
WHERE opened_by IS NOT NULL
  AND opened_at >= '2024-06-17' AND opened_at <= '2025-06-17'
GROUP BY DATE_TRUNC('month', opened_at)
ORDER BY month;
