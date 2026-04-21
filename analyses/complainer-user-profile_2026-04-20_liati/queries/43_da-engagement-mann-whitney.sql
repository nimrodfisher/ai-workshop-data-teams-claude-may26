-- Deep Analysis — H2 (pre-complaint engagement)
-- Mann-Whitney U inputs: rank sums for complainer vs non-complainer
-- using 30-day and 14-day lookback before first complaint (or snapshot end for non-complainers).
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
            CASE WHEN fc.user_id IS NOT NULL THEN 'complainer' ELSE 'non_complainer' END AS grp,
            COALESCE(fc.first_cdate, '2025-06-17'::date) AS ref_date,
            COUNT(e.id) FILTER (
                WHERE e.occurred_at::date >= COALESCE(fc.first_cdate, '2025-06-17'::date) - 30
                  AND e.occurred_at::date <  COALESCE(fc.first_cdate, '2025-06-17'::date)
            ) AS events_30d,
            COUNT(e.id) FILTER (
                WHERE e.occurred_at::date >= COALESCE(fc.first_cdate, '2025-06-17'::date) - 14
                  AND e.occurred_at::date <  COALESCE(fc.first_cdate, '2025-06-17'::date)
            ) AS events_14d
    FROM    users u
    LEFT JOIN first_complaint fc ON u.id = fc.user_id
    LEFT JOIN events e ON e.user_id = u.id
    GROUP BY u.id, fc.user_id, fc.first_cdate
),
ranked AS (
    SELECT  user_id,
            grp,
            events_30d,
            events_14d,
            RANK() OVER (ORDER BY events_30d) AS rank30_min,
            RANK() OVER (ORDER BY events_14d) AS rank14_min
    FROM    user_events
),
avg_ranks AS (
    SELECT  ue.user_id,
            ue.grp,
            ue.events_30d,
            ue.events_14d,
            (SELECT AVG(r.rank30_min) FROM ranked r WHERE r.events_30d = ue.events_30d) AS avg_rank_30,
            (SELECT AVG(r.rank14_min) FROM ranked r WHERE r.events_14d = ue.events_14d) AS avg_rank_14
    FROM    user_events ue
)
SELECT  grp,
        COUNT(*) AS n,
        ROUND(AVG(events_30d)::numeric, 2)                                AS mean_30,
        ROUND((percentile_cont(0.50) WITHIN GROUP (ORDER BY events_30d))::numeric, 2) AS median_30,
        ROUND((percentile_cont(0.25) WITHIN GROUP (ORDER BY events_30d))::numeric, 2) AS q1_30,
        ROUND((percentile_cont(0.75) WITHIN GROUP (ORDER BY events_30d))::numeric, 2) AS q3_30,
        ROUND(AVG(events_14d)::numeric, 2)                                AS mean_14,
        ROUND((percentile_cont(0.50) WITHIN GROUP (ORDER BY events_14d))::numeric, 2) AS median_14,
        SUM(avg_rank_30)::numeric                                         AS rank_sum_30,
        SUM(avg_rank_14)::numeric                                         AS rank_sum_14
FROM    avg_ranks
GROUP BY grp
ORDER BY grp;
