-- QA 14: unique complainer users per category (remapped definition)
SELECT 'overall' AS scope,
       COUNT(DISTINCT opened_by) AS unique_complainer_users_mapped
FROM support_tickets
WHERE category IN ('bug','usage_question','billing') AND opened_by IS NOT NULL
UNION ALL SELECT 'by_category_mapped_bug',            COUNT(DISTINCT opened_by) FROM support_tickets WHERE category = 'bug'
UNION ALL SELECT 'by_category_mapped_usage_question', COUNT(DISTINCT opened_by) FROM support_tickets WHERE category = 'usage_question'
UNION ALL SELECT 'by_category_mapped_billing',        COUNT(DISTINCT opened_by) FROM support_tickets WHERE category = 'billing'
UNION ALL SELECT 'all_ticket_openers',                COUNT(DISTINCT opened_by) FROM support_tickets;
