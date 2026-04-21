-- QA 04: null rates + cardinality on events table
SELECT
  COUNT(*) AS total_events,
  COUNT(*) FILTER (WHERE user_id IS NULL) AS null_user_id,
  COUNT(*) FILTER (WHERE org_id IS NULL) AS null_org_id,
  COUNT(*) FILTER (WHERE occurred_at IS NULL) AS null_occurred_at,
  COUNT(*) FILTER (WHERE event_type IS NULL) AS null_event_type,
  ROUND(100.0 * COUNT(*) FILTER (WHERE user_id IS NULL) / NULLIF(COUNT(*), 0), 2) AS pct_null_user_id,
  COUNT(DISTINCT user_id) AS distinct_users_in_events,
  COUNT(DISTINCT event_type) AS distinct_event_types
FROM events;
