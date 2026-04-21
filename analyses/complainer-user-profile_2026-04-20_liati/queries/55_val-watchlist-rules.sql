-- V6: Evaluate candidate watch-list rules: precision, recall, lift vs baseline 18.0%
WITH fc AS (
  SELECT opened_by AS user_id, MIN(opened_at)::date AS first_cd FROM support_tickets
  WHERE  category IN ('bug','billing') AND opened_by IS NOT NULL
    AND  opened_at BETWEEN '2024-06-17' AND '2025-06-17'
  GROUP BY opened_by
),
ue AS (
  SELECT u.id, a.plan,
         CASE WHEN fc.user_id IS NOT NULL THEN 1 ELSE 0 END AS actual,
         COUNT(e.id) FILTER (
             WHERE e.occurred_at::date >= COALESCE(fc.first_cd, '2025-06-17'::date) - 14
               AND e.occurred_at::date <  COALESCE(fc.first_cd, '2025-06-17'::date)
         ) AS ev_14,
         COUNT(e.id) FILTER (
             WHERE e.occurred_at::date >= COALESCE(fc.first_cd, '2025-06-17'::date) - 30
               AND e.occurred_at::date <  COALESCE(fc.first_cd, '2025-06-17'::date)
         ) AS ev_30
  FROM   users u
  JOIN   accounts a ON u.org_id = a.id
  LEFT JOIN fc ON fc.user_id = u.id
  LEFT JOIN events e ON e.user_id = u.id
  GROUP BY u.id, a.plan, fc.user_id, fc.first_cd
),
rules AS (
  SELECT 'free_only'        AS rule, CASE WHEN plan='free'                  THEN 1 ELSE 0 END AS pred, actual FROM ue UNION ALL
  SELECT 'zero14_only',               CASE WHEN ev_14 = 0                   THEN 1 ELSE 0 END,         actual FROM ue UNION ALL
  SELECT 'zero30_only',               CASE WHEN ev_30 = 0                   THEN 1 ELSE 0 END,         actual FROM ue UNION ALL
  SELECT 'zero30_lt2',                CASE WHEN ev_30 < 2                   THEN 1 ELSE 0 END,         actual FROM ue UNION ALL
  SELECT 'free_or_zero14',            CASE WHEN plan='free' OR ev_14 = 0    THEN 1 ELSE 0 END,         actual FROM ue UNION ALL
  SELECT 'free_or_zero30',            CASE WHEN plan='free' OR ev_30 = 0    THEN 1 ELSE 0 END,         actual FROM ue UNION ALL
  SELECT 'free_and_zero14',           CASE WHEN plan='free' AND ev_14 = 0   THEN 1 ELSE 0 END,         actual FROM ue UNION ALL
  SELECT 'free_and_zero30',           CASE WHEN plan='free' AND ev_30 = 0   THEN 1 ELSE 0 END,         actual FROM ue
)
SELECT rule,
       SUM(CASE WHEN pred=1 AND actual=1 THEN 1 ELSE 0 END) AS tp,
       SUM(CASE WHEN pred=1 AND actual=0 THEN 1 ELSE 0 END) AS fp,
       SUM(CASE WHEN pred=0 AND actual=1 THEN 1 ELSE 0 END) AS fn,
       SUM(CASE WHEN pred=0 AND actual=0 THEN 1 ELSE 0 END) AS tn,
       SUM(pred)   AS flagged,
       SUM(actual) AS total_pos,
       COUNT(*)    AS total,
       ROUND(SUM(CASE WHEN pred=1 AND actual=1 THEN 1 ELSE 0 END)::numeric / NULLIF(SUM(pred),0),   4) AS precision_pct,
       ROUND(SUM(CASE WHEN pred=1 AND actual=1 THEN 1 ELSE 0 END)::numeric / NULLIF(SUM(actual),0), 4) AS recall_pct,
       ROUND((SUM(CASE WHEN pred=1 AND actual=1 THEN 1 ELSE 0 END)::numeric / NULLIF(SUM(pred),0)) / 0.18, 4) AS lift
FROM   rules GROUP BY rule ORDER BY lift DESC NULLS LAST;
