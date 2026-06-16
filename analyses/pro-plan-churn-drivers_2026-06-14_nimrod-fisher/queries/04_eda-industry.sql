-- 04_eda-industry: Pro accounts and sub cancels by industry
WITH pro AS (SELECT id, industry FROM accounts WHERE plan='pro'),
sub_roll AS (
  SELECT pro.industry, pro.id AS org_id,
    COUNT(*) FILTER (WHERE s.status='canceled') AS canceled_subs,
    COUNT(*) FILTER (WHERE s.status='active')   AS active_subs
  FROM pro JOIN subscriptions s ON s.org_id=pro.id
  GROUP BY pro.industry, pro.id
)
SELECT industry,
  COUNT(DISTINCT org_id) AS pro_accounts,
  SUM(canceled_subs) AS canceled_subs,
  SUM(active_subs) AS active_subs,
  COUNT(DISTINCT org_id) FILTER (WHERE canceled_subs>0) AS accounts_with_a_cancel
FROM sub_roll
GROUP BY industry
ORDER BY canceled_subs DESC, pro_accounts DESC;
-- grain: one row per industry among Pro accounts
