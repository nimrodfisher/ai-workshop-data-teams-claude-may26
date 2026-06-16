-- 06_eda-support: support ticket volume per Pro account, split by has_cancel (H4)
WITH pro AS (SELECT id FROM accounts WHERE plan='pro'),
flags AS (
  SELECT pro.id AS org_id, BOOL_OR(s.status='canceled') AS has_cancel
  FROM pro JOIN subscriptions s ON s.org_id=pro.id
  GROUP BY pro.id
),
tix AS (
  SELECT org_id, COUNT(*) AS tickets,
         COUNT(*) FILTER (WHERE status NOT IN ('resolved','closed')) AS open_tickets
  FROM support_tickets GROUP BY org_id
)
SELECT
  CASE WHEN f.has_cancel THEN 'has_canceled_sub' ELSE 'no_cancel' END AS segment,
  COUNT(*) AS accounts,
  SUM(COALESCE(t.tickets,0)) AS total_tickets,
  ROUND(AVG(COALESCE(t.tickets,0)),2) AS avg_tickets_per_account,
  SUM(COALESCE(t.open_tickets,0)) AS total_open_tickets
FROM flags f
LEFT JOIN tix t ON t.org_id=f.org_id
GROUP BY 1
ORDER BY 1;
-- grain: one row per segment across the 15 Pro accounts
