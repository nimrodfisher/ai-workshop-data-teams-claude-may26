-- 13_val-replication-account-tier: account-grain replication of H1 — do accounts holding a $199 sub cancel more?
WITH pro AS (SELECT id FROM accounts WHERE plan='pro'),
acct AS (
  SELECT pro.id AS org_id,
    BOOL_OR(s.monthly_price=199) AS holds_199,
    BOOL_OR(s.status='canceled') AS any_cancel
  FROM pro JOIN subscriptions s ON s.org_id=pro.id
  GROUP BY pro.id
)
SELECT
  CASE WHEN holds_199 THEN 'holds_a_$199_sub' ELSE 'no_$199_sub' END AS segment,
  COUNT(*) AS accounts,
  COUNT(*) FILTER (WHERE any_cancel) AS accounts_with_cancel,
  ROUND(100.0*COUNT(*) FILTER (WHERE any_cancel)/COUNT(*),1) AS pct_with_cancel
FROM acct
GROUP BY 1
ORDER BY 1;
-- grain: one row per segment (account ever held a $199 sub vs not)
