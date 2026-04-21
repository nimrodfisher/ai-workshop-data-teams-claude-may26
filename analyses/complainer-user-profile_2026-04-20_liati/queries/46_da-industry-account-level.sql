-- Deep Analysis — Industry (account-level, not user-level)
-- EDA showed user-level rates; this re-aggregates to 50 accounts to avoid
-- within-account clustering inflating the signal. "Complainer account"
-- = account with >=1 complainer user in window.
WITH complainer_accounts AS (
    SELECT DISTINCT u.org_id AS account_id
    FROM   support_tickets t
    JOIN   users u ON u.id = t.opened_by
    WHERE  t.category IN ('bug', 'billing')
      AND  t.opened_at >= '2024-06-17'
      AND  t.opened_at <= '2025-06-17'
)
SELECT  a.industry,
        COUNT(*)                     AS total_accounts,
        COUNT(ca.account_id)         AS complainer_accounts,
        ROUND(COUNT(ca.account_id)::numeric / COUNT(*), 4) AS complainer_rate
FROM    accounts a
LEFT JOIN complainer_accounts ca ON a.id = ca.account_id
GROUP BY a.industry
ORDER BY complainer_rate DESC;
