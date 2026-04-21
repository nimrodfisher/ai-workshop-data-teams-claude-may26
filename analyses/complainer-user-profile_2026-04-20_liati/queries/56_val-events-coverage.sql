-- V7: Events-data actual coverage (surfaces Phase-2-QA miss: events are ~90 days, not 365)
SELECT MIN(occurred_at)::date AS first_event,
       MAX(occurred_at)::date AS last_event,
       COUNT(*) AS total_events,
       COUNT(DISTINCT DATE(occurred_at)) AS active_days,
       SUM(CASE WHEN occurred_at::date >= '2025-06-11' THEN 1 ELSE 0 END) AS events_last_7d_of_window,
       SUM(CASE WHEN occurred_at::date >= '2025-05-18' THEN 1 ELSE 0 END) AS events_last_30d_of_window
FROM   events;

-- And: how many complainers have their first-complaint date inside event coverage?
WITH fc AS (
  SELECT opened_by AS user_id, MIN(opened_at)::date AS first_cd FROM support_tickets
  WHERE  category IN ('bug','billing') AND opened_by IS NOT NULL
    AND  opened_at BETWEEN '2024-06-17' AND '2025-06-17'
  GROUP BY opened_by
)
SELECT COUNT(*) AS total_complainers,
       SUM(CASE WHEN first_cd < '2025-03-07'::date THEN 1 ELSE 0 END)                                AS first_cd_before_events,
       SUM(CASE WHEN first_cd BETWEEN '2025-03-07'::date AND '2025-03-07'::date + 29 THEN 1 ELSE 0 END) AS first_cd_partial_coverage,
       SUM(CASE WHEN first_cd >= '2025-03-07'::date + 30 AND first_cd <= '2025-06-06'::date THEN 1 ELSE 0 END) AS first_cd_full_30d_coverage,
       SUM(CASE WHEN first_cd > '2025-06-06'::date THEN 1 ELSE 0 END)                               AS first_cd_after_events,
       MIN(first_cd) AS earliest_complaint, MAX(first_cd) AS latest_complaint
FROM   fc;
