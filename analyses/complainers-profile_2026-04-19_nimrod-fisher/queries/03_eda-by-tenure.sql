-- EDA 03: Complaint rate and ticket volume by account tenure bucket
SELECT
  CASE
    WHEN DATE_PART('day', NOW() - a.created_at) <= 90 THEN '0-90 days'
    WHEN DATE_PART('day', NOW() - a.created_at) <= 365 THEN '91-365 days'
    WHEN DATE_PART('day', NOW() - a.created_at) <= 730 THEN '1-2 years'
    ELSE '2+ years'
  END AS tenure_bucket,
  COUNT(DISTINCT a.id) AS total_accounts,
  COUNT(DISTINCT st.org_id) AS accounts_with_tickets,
  ROUND(100.0 * COUNT(DISTINCT st.org_id) / COUNT(DISTINCT a.id), 1) AS complaint_rate_pct,
  COUNT(st.id) AS total_tickets,
  ROUND(COUNT(st.id)::numeric / COUNT(DISTINCT a.id), 2) AS avg_tickets_per_account
FROM accounts a
LEFT JOIN support_tickets st ON a.id = st.org_id
GROUP BY tenure_bucket
ORDER BY avg_tickets_per_account DESC;
