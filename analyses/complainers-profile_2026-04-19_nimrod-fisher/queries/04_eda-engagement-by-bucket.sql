-- EDA 04: Engagement (event count) by ticket-volume bucket
WITH ticket_buckets AS (
  SELECT
    a.id AS org_id,
    COUNT(st.id) AS ticket_count,
    CASE
      WHEN COUNT(st.id) = 0 THEN '0 tickets'
      WHEN COUNT(st.id) <= 2 THEN '1-2 tickets'
      ELSE '3+ tickets'
    END AS bucket
  FROM accounts a
  LEFT JOIN support_tickets st ON a.id = st.org_id
  GROUP BY a.id
),
event_counts AS (
  SELECT org_id, COUNT(*) AS event_count
  FROM events
  GROUP BY org_id
)
SELECT
  tb.bucket,
  COUNT(DISTINCT tb.org_id) AS accounts,
  ROUND(AVG(COALESCE(ec.event_count, 0)), 1) AS avg_events,
  PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY COALESCE(ec.event_count, 0)) AS median_events,
  MIN(COALESCE(ec.event_count, 0)) AS min_events,
  MAX(COALESCE(ec.event_count, 0)) AS max_events
FROM ticket_buckets tb
LEFT JOIN event_counts ec ON tb.org_id = ec.org_id
GROUP BY tb.bucket
ORDER BY avg_events DESC;
