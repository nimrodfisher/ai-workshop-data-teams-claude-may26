-- QA 06: distribution of support_tickets.category values vs documented enum
-- Documented values (schema.yml): billing, technical, feature_request, bug_report, general_inquiry, onboarding
-- Plan's complaint set: bug_report, technical, billing
SELECT
  category,
  COUNT(*) AS ticket_count,
  ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM support_tickets), 2) AS pct_of_total,
  CASE
    WHEN category IN ('bug_report','technical','billing') THEN 'complaint'
    WHEN category IN ('feature_request','general_inquiry','onboarding') THEN 'non_complaint'
    ELSE 'UNDOCUMENTED_VALUE'
  END AS category_bucket
FROM support_tickets
GROUP BY category
ORDER BY ticket_count DESC;
