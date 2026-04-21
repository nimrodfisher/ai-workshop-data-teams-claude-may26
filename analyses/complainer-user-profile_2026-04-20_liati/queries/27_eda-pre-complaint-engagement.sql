-- EDA 27: H2 pre-complaint 30-day events (complainers) vs matched 30-day window (non-complainers)
-- Event coverage starts 2025-03-07; full 30-day pre-complaint lookback is only available for
-- complaints opened >= 2025-04-06 (14 of 36 complainers). Non-complainer comparison uses the
-- matched window [2025-05-06, 2025-06-06) — the single 30-day bin where all 200 users have full
-- event coverage. Flagged as Suggestive (n=14) in eda-findings.md.
WITH complainer_first_ticket AS (
  SELECT opened_by AS user_id, MIN(opened_at) AS first_complaint_at
  FROM support_tickets
  WHERE category IN ('bug','billing')
    AND opened_by IS NOT NULL
    AND opened_at >= '2024-06-17' AND opened_at <= '2025-06-17'
  GROUP BY opened_by
),
complainer_events AS (
  SELECT cft.user_id, COUNT(e.id) AS pre_complaint_events
  FROM complainer_first_ticket cft
  LEFT JOIN events e ON e.user_id = cft.user_id
                    AND e.occurred_at >= cft.first_complaint_at - INTERVAL '30 days'
                    AND e.occurred_at <  cft.first_complaint_at
  WHERE cft.first_complaint_at >= '2025-04-06'
  GROUP BY cft.user_id
),
non_complainer_events AS (
  SELECT u.id AS user_id, COUNT(e.id) AS window_events
  FROM users u
  JOIN accounts a ON u.org_id = a.id
  LEFT JOIN events e ON e.user_id = u.id
                    AND e.occurred_at >= '2025-05-06'
                    AND e.occurred_at <  '2025-06-06'
  WHERE u.id NOT IN (
    SELECT opened_by FROM support_tickets
    WHERE category IN ('bug','billing')
      AND opened_by IS NOT NULL
      AND opened_at >= '2024-06-17' AND opened_at <= '2025-06-17'
  )
  GROUP BY u.id
)
SELECT 'complainer_pre_30d' AS cohort,
       COUNT(*) AS n_users,
       ROUND(AVG(pre_complaint_events), 2) AS mean_events,
       PERCENTILE_CONT(0.5)  WITHIN GROUP (ORDER BY pre_complaint_events) AS median_events,
       PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY pre_complaint_events) AS p25,
       PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY pre_complaint_events) AS p75
FROM complainer_events
UNION ALL
SELECT 'non_complainer_matched_30d',
       COUNT(*),
       ROUND(AVG(window_events), 2),
       PERCENTILE_CONT(0.5)  WITHIN GROUP (ORDER BY window_events),
       PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY window_events),
       PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY window_events)
FROM non_complainer_events;
