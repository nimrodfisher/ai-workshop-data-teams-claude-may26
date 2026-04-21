-- EDA 26b: events-per-user binned for histogram
WITH per_user AS (
  SELECT user_id, COUNT(*) AS event_count
  FROM events
  WHERE user_id IS NOT NULL
  GROUP BY user_id
),
bucketed AS (
  SELECT
    CASE
      WHEN event_count <= 2  THEN '1-2'
      WHEN event_count <= 5  THEN '3-5'
      WHEN event_count <= 10 THEN '6-10'
      WHEN event_count <= 15 THEN '11-15'
      WHEN event_count <= 20 THEN '16-20'
      WHEN event_count <= 30 THEN '21-30'
      ELSE '31+'
    END AS bucket,
    CASE
      WHEN event_count <= 2  THEN 1 WHEN event_count <= 5  THEN 2
      WHEN event_count <= 10 THEN 3 WHEN event_count <= 15 THEN 4
      WHEN event_count <= 20 THEN 5 WHEN event_count <= 30 THEN 6
      ELSE 7
    END AS bucket_order
  FROM per_user
)
SELECT bucket, bucket_order, COUNT(*) AS users
FROM bucketed
GROUP BY bucket, bucket_order
ORDER BY bucket_order;
