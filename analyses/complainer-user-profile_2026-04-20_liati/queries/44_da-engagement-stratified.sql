-- Deep Analysis — H2 stratified by plan (free vs paid)
-- Addresses the H1xH2 confound surfaced in EDA:
-- Does the engagement signal persist within each plan stratum?
WITH first_complaint AS (
    SELECT opened_by AS user_id, MIN(opened_at)::date AS first_cdate
    FROM   support_tickets
    WHERE  category IN ('bug', 'billing')
      AND  opened_by IS NOT NULL
      AND  opened_at >= '2024-06-17'
      AND  opened_at <= '2025-06-17'
    GROUP BY opened_by
),
user_events AS (
    SELECT  u.id AS user_id,
            CASE WHEN a.plan = 'free' THEN 'free' ELSE 'paid' END AS plan_group,
            CASE WHEN fc.user_id IS NOT NULL THEN 'complainer' ELSE 'non_complainer' END AS grp,
            COUNT(e.id) FILTER (
                WHERE e.occurred_at::date >= COALESCE(fc.first_cdate, '2025-06-17'::date) - 30
                  AND e.occurred_at::date <  COALESCE(fc.first_cdate, '2025-06-17'::date)
            ) AS events_30d
    FROM    users u
    JOIN    accounts a ON u.org_id = a.id
    LEFT JOIN first_complaint fc ON u.id = fc.user_id
    LEFT JOIN events    e ON e.user_id = u.id
    GROUP BY u.id, a.plan, fc.user_id, fc.first_cdate
),
paid_ranked AS (
    SELECT user_id, grp, events_30d,
           RANK() OVER (ORDER BY events_30d) AS rmin
    FROM   user_events
    WHERE  plan_group = 'paid'
),
paid_avg AS (
    SELECT pr.user_id, pr.grp, pr.events_30d,
           (SELECT AVG(r.rmin) FROM paid_ranked r WHERE r.events_30d = pr.events_30d) AS avg_rank
    FROM   paid_ranked pr
),
free_ranked AS (
    SELECT user_id, grp, events_30d,
           RANK() OVER (ORDER BY events_30d) AS rmin
    FROM   user_events
    WHERE  plan_group = 'free'
),
free_avg AS (
    SELECT fr.user_id, fr.grp, fr.events_30d,
           (SELECT AVG(r.rmin) FROM free_ranked r WHERE r.events_30d = fr.events_30d) AS avg_rank
    FROM   free_ranked fr
)
SELECT  'paid' AS stratum, grp,
        COUNT(*) AS n,
        ROUND(AVG(events_30d)::numeric, 2) AS mean_30,
        ROUND((percentile_cont(0.50) WITHIN GROUP (ORDER BY events_30d))::numeric, 2) AS median_30,
        ROUND((percentile_cont(0.25) WITHIN GROUP (ORDER BY events_30d))::numeric, 2) AS q1_30,
        ROUND((percentile_cont(0.75) WITHIN GROUP (ORDER BY events_30d))::numeric, 2) AS q3_30,
        SUM(avg_rank)::numeric AS rank_sum
FROM    paid_avg
GROUP BY grp
UNION ALL
SELECT  'free', grp,
        COUNT(*),
        ROUND(AVG(events_30d)::numeric, 2),
        ROUND((percentile_cont(0.50) WITHIN GROUP (ORDER BY events_30d))::numeric, 2),
        ROUND((percentile_cont(0.25) WITHIN GROUP (ORDER BY events_30d))::numeric, 2),
        ROUND((percentile_cont(0.75) WITHIN GROUP (ORDER BY events_30d))::numeric, 2),
        SUM(avg_rank)::numeric
FROM    free_avg
GROUP BY grp
ORDER BY 1, 2;
