-- V3: Mann-Whitney rank sums with CORRECT average-rank tie handling
-- avg_rank = ((#rows with x < me.x) + 1 + (#rows with x <= me.x)) / 2
-- Replaces buggy RANK()-based computation used in Phase 4 queries 43 and 44.
WITH fc AS (
  SELECT opened_by AS user_id, MIN(opened_at)::date AS first_cd
  FROM support_tickets
  WHERE category IN ('bug','billing') AND opened_by IS NOT NULL
    AND opened_at BETWEEN '2024-06-17' AND '2025-06-17'
  GROUP BY opened_by
),
ue AS (
  SELECT u.id AS user_id,
         CASE WHEN fc.user_id IS NOT NULL THEN 'complainer' ELSE 'non_complainer' END AS grp,
         COUNT(e.id) FILTER (
             WHERE e.occurred_at::date >= COALESCE(fc.first_cd, '2025-06-17'::date) - 30
               AND e.occurred_at::date <  COALESCE(fc.first_cd, '2025-06-17'::date)
         ) AS ev_30,
         COUNT(e.id) FILTER (
             WHERE e.occurred_at::date >= COALESCE(fc.first_cd, '2025-06-17'::date) - 21
               AND e.occurred_at::date <  COALESCE(fc.first_cd, '2025-06-17'::date)
         ) AS ev_21,
         COUNT(e.id) FILTER (
             WHERE e.occurred_at::date >= COALESCE(fc.first_cd, '2025-06-17'::date) - 14
               AND e.occurred_at::date <  COALESCE(fc.first_cd, '2025-06-17'::date)
         ) AS ev_14
  FROM   users u
  LEFT JOIN fc ON u.id = fc.user_id
  LEFT JOIN events e ON e.user_id = u.id
  GROUP BY u.id, fc.user_id, fc.first_cd
)
SELECT  u1.grp, COUNT(*) AS n,
        SUM( ((SELECT COUNT(*) FROM ue u2 WHERE u2.ev_30 <  u1.ev_30) + 1
            + (SELECT COUNT(*) FROM ue u2 WHERE u2.ev_30 <= u1.ev_30))::numeric / 2 ) AS rs_30,
        SUM( ((SELECT COUNT(*) FROM ue u2 WHERE u2.ev_21 <  u1.ev_21) + 1
            + (SELECT COUNT(*) FROM ue u2 WHERE u2.ev_21 <= u1.ev_21))::numeric / 2 ) AS rs_21,
        SUM( ((SELECT COUNT(*) FROM ue u2 WHERE u2.ev_14 <  u1.ev_14) + 1
            + (SELECT COUNT(*) FROM ue u2 WHERE u2.ev_14 <= u1.ev_14))::numeric / 2 ) AS rs_14
FROM    ue u1
GROUP BY u1.grp
ORDER BY u1.grp;
