-- 11_val-churn-definition: sensitivity of churn rate to definition (sub / account / true logo exit)
WITH pro AS (SELECT id FROM accounts WHERE plan='pro'),
sub AS (
  SELECT COUNT(*) FILTER (WHERE s.status='canceled') AS canceled_subs,
         COUNT(*) FILTER (WHERE s.status IN ('active','canceled')) AS denom_subs
  FROM pro JOIN subscriptions s ON s.org_id=pro.id
),
acct AS (
  SELECT pro.id AS org_id,
         BOOL_OR(s.status='canceled') AS any_cancel,
         BOOL_OR(s.status='active') AS any_active
  FROM pro JOIN subscriptions s ON s.org_id=pro.id
  GROUP BY pro.id
)
SELECT
  (SELECT canceled_subs FROM sub) AS canceled_subs,
  (SELECT denom_subs FROM sub) AS denom_subs,
  ROUND(100.0*(SELECT canceled_subs FROM sub)/(SELECT denom_subs FROM sub),1) AS sub_level_churn_pct,
  COUNT(*) AS pro_accounts_with_subs,
  COUNT(*) FILTER (WHERE any_cancel) AS accounts_with_any_cancel,
  ROUND(100.0*COUNT(*) FILTER (WHERE any_cancel)/COUNT(*),1) AS account_level_churn_pct,
  COUNT(*) FILTER (WHERE any_cancel AND NOT any_active) AS true_logo_exits,
  ROUND(100.0*COUNT(*) FILTER (WHERE any_cancel AND NOT any_active)/COUNT(*),1) AS logo_churn_pct
FROM acct;
-- grain: one summary row; three churn definitions side by side.
-- NOTE: denom is 13 (accounts WITH >=1 subscription); 2 of 15 Pro accounts have no subscription at all.
