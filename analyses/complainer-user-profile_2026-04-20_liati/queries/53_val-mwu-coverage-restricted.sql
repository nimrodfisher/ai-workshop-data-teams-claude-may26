-- V8: Restrict H2 MWU to complainers with actual 30d event-data coverage
-- (first_cd BETWEEN 2025-04-06 AND 2025-06-06 so the 30d pre-window is inside events range).
-- Non-complainer reference date moved to 2025-05-06 (midpoint of event coverage).
WITH fc_full AS (
  SELECT opened_by AS user_id, MIN(opened_at)::date AS first_cd
  FROM   support_tickets
  WHERE  category IN ('bug','billing') AND opened_by IS NOT NULL
    AND  opened_at BETWEEN '2024-06-17' AND '2025-06-17'
  GROUP  BY opened_by
  HAVING MIN(opened_at)::date BETWEEN '2025-04-06'::date AND '2025-06-06'::date
),
ue AS (
  SELECT u.id,
         CASE WHEN fc.user_id IS NOT NULL THEN 'complainer' ELSE 'non_complainer' END AS grp,
         COUNT(e.id) FILTER (
             WHERE e.occurred_at::date >= COALESCE(fc.first_cd, '2025-05-06'::date) - 30
               AND e.occurred_at::date <  COALESCE(fc.first_cd, '2025-05-06'::date)
         ) AS ev_30
  FROM   users u
  LEFT JOIN fc_full fc ON u.id = fc.user_id
  LEFT JOIN events   e ON e.user_id = u.id
  GROUP BY u.id, fc.user_id, fc.first_cd
)
SELECT u1.grp, COUNT(*) AS n,
       ROUND(AVG(ev_30)::numeric, 2) AS mean_30,
       ROUND((percentile_cont(0.5) WITHIN GROUP (ORDER BY ev_30))::numeric, 2) AS median_30,
       SUM(CASE WHEN ev_30 = 0 THEN 1 ELSE 0 END) AS zeros_30,
       SUM( ((SELECT COUNT(*) FROM ue u2 WHERE u2.ev_30 <  u1.ev_30) + 1
           + (SELECT COUNT(*) FROM ue u2 WHERE u2.ev_30 <= u1.ev_30))::numeric / 2 ) AS rank_sum_avg
FROM   ue u1
GROUP BY u1.grp
ORDER BY u1.grp;
