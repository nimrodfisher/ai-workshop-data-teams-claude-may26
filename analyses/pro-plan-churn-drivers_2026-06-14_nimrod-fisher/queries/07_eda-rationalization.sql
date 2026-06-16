-- 07_eda-rationalization: account-level outcome for Pro accounts that canceled >=1 sub
WITH pro AS (SELECT id FROM accounts WHERE plan='pro'),
acct AS (
  SELECT pro.id AS org_id,
    COUNT(*) FILTER (WHERE s.status='canceled') AS canceled_subs,
    COUNT(*) FILTER (WHERE s.status='active')   AS active_subs,
    MAX(s.canceled_at) AS last_cancel
  FROM pro JOIN subscriptions s ON s.org_id=pro.id
  GROUP BY pro.id
)
SELECT
  COUNT(*) FILTER (WHERE canceled_subs>0) AS accounts_with_a_cancel,
  COUNT(*) FILTER (WHERE canceled_subs>0 AND active_subs>0) AS rationalized_still_active,
  COUNT(*) FILTER (WHERE canceled_subs>0 AND active_subs=0) AS true_logo_exit,
  COUNT(*) FILTER (WHERE canceled_subs>0 AND active_subs>0 AND last_cancel >= DATE '2025-01-01') AS rationalized_2025
FROM acct;
-- grain: one summary row over Pro accounts; rationalization = canceled a sub but still holds an active one
