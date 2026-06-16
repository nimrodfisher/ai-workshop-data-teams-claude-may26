-- 00_qa-event-coverage: event window overall + per Pro canceled sub whether cancel date is in coverage
WITH ev AS (
  SELECT MIN(occurred_at)::date AS ev_min, MAX(occurred_at)::date AS ev_max FROM events
),
pro_cancels AS (
  SELECT s.org_id, s.canceled_at
  FROM subscriptions s
  JOIN accounts a ON s.org_id = a.id
  WHERE a.plan = 'pro' AND s.status='canceled'
)
SELECT
  (SELECT ev_min FROM ev) AS events_min,
  (SELECT ev_max FROM ev) AS events_max,
  (SELECT COUNT(*) FROM events) AS total_events,
  (SELECT COUNT(DISTINCT org_id) FROM events) AS accounts_with_events,
  COUNT(*) AS pro_cancels,
  COUNT(*) FILTER (WHERE pc.canceled_at BETWEEN (SELECT ev_min FROM ev) AND (SELECT ev_max FROM ev)) AS cancels_in_event_window,
  COUNT(*) FILTER (WHERE pc.canceled_at < (SELECT ev_min FROM ev)) AS cancels_before_window
FROM pro_cancels pc;
-- grain: one summary row over Pro canceled subs vs event coverage
