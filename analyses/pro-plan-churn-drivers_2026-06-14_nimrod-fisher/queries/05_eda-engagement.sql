-- 05_eda-engagement: account-level event activity within coverage window (2025-03-07..2025-06-06),
-- split by whether the Pro account has any canceled sub. Coverage-limited -> descriptive only.
WITH pro AS (SELECT id FROM accounts WHERE plan='pro'),
flags AS (
  SELECT pro.id AS org_id,
    BOOL_OR(s.status='canceled') AS has_cancel
  FROM pro JOIN subscriptions s ON s.org_id=pro.id
  GROUP BY pro.id
),
ev AS (
  SELECT org_id, COUNT(*) AS events_in_window
  FROM events
  WHERE occurred_at::date BETWEEN DATE '2025-03-07' AND DATE '2025-06-06'
  GROUP BY org_id
)
SELECT
  CASE WHEN f.has_cancel THEN 'has_canceled_sub' ELSE 'no_cancel' END AS segment,
  COUNT(*) AS accounts,
  ROUND(AVG(COALESCE(ev.events_in_window,0))) AS avg_events_in_window,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY COALESCE(ev.events_in_window,0)) AS median_events,
  MIN(COALESCE(ev.events_in_window,0)) AS min_events,
  MAX(COALESCE(ev.events_in_window,0)) AS max_events
FROM flags f
LEFT JOIN ev ON ev.org_id=f.org_id
GROUP BY 1
ORDER BY 1;
-- grain: one row per segment (has canceled sub vs not) across the 15 Pro accounts
