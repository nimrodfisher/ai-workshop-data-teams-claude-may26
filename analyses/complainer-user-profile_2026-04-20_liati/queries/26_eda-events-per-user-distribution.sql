-- EDA 26: overall events-per-user distribution (univariate)
WITH per_user AS (
  SELECT user_id, COUNT(*) AS event_count
  FROM events
  WHERE user_id IS NOT NULL
  GROUP BY user_id
)
SELECT
  COUNT(*) AS users_with_events,
  ROUND(AVG(event_count), 2) AS mean_events,
  PERCENTILE_CONT(0.5)  WITHIN GROUP (ORDER BY event_count) AS median_events,
  PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY event_count) AS p25,
  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY event_count) AS p75,
  MIN(event_count) AS min_events,
  MAX(event_count) AS max_events,
  STDDEV(event_count)::numeric(10,2) AS stdev_events
FROM per_user;
