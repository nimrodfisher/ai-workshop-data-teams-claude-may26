-- EDA 28: events per user by plan — confound check between H1 (plan) and H2 (engagement)
WITH per_user AS (
  SELECT u.id AS user_id, a.plan, COUNT(e.id) AS event_count
  FROM users u
  JOIN accounts a ON u.org_id = a.id
  LEFT JOIN events e ON e.user_id = u.id
  GROUP BY u.id, a.plan
)
SELECT
  plan,
  COUNT(*) AS users,
  ROUND(AVG(event_count), 2) AS mean_events,
  PERCENTILE_CONT(0.5)  WITHIN GROUP (ORDER BY event_count) AS median_events,
  PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY event_count) AS p25,
  PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY event_count) AS p75
FROM per_user
GROUP BY plan
ORDER BY median_events DESC;
