-- 00_qa-date-logic: invalid date ordering and out-of-range dates for Pro subs
WITH pro_subs AS (
  SELECT s.id, s.status, s.started_at, s.canceled_at
  FROM subscriptions s
  JOIN accounts a ON s.org_id = a.id
  WHERE a.plan = 'pro'
)
SELECT
  COUNT(*) FILTER (WHERE canceled_at IS NOT NULL AND canceled_at < started_at) AS cancel_before_start,
  COUNT(*) FILTER (WHERE started_at > CURRENT_DATE) AS start_in_future,
  COUNT(*) FILTER (WHERE canceled_at > CURRENT_DATE) AS cancel_in_future,
  MIN(started_at) AS earliest_start,
  MAX(started_at) AS latest_start,
  MIN(canceled_at) AS earliest_cancel,
  MAX(canceled_at) AS latest_cancel
FROM pro_subs;
-- grain: one summary row over Pro-account subscriptions
