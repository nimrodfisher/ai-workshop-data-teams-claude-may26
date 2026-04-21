-- Deep Analysis — H3 (tenure at snapshot end)
-- 4-way contingency (<90d / 90-180d / 180-270d / 270d+) and 2-way endpoint comparison
WITH complainers AS (
    SELECT DISTINCT opened_by AS user_id
    FROM   support_tickets
    WHERE  category IN ('bug', 'billing')
      AND  opened_by IS NOT NULL
      AND  opened_at >= '2024-06-17'
      AND  opened_at <= '2025-06-17'
),
cells AS (
    SELECT  u.id AS user_id,
            CASE
                WHEN ('2025-06-17'::date - u.created_at::date) <  90 THEN '1_lt90d'
                WHEN ('2025-06-17'::date - u.created_at::date) < 180 THEN '2_90to180d'
                WHEN ('2025-06-17'::date - u.created_at::date) < 270 THEN '3_180to270d'
                ELSE                                                        '4_270d_plus'
            END AS tenure_bucket,
            CASE WHEN c.user_id IS NOT NULL THEN 1 ELSE 0 END AS is_complainer
    FROM    users u
    LEFT JOIN complainers c ON u.id = c.user_id
),
by_bucket AS (
    SELECT  tenure_bucket,
            SUM(is_complainer) AS comp,
            COUNT(*) - SUM(is_complainer) AS non_comp,
            COUNT(*) AS n,
            ROUND(SUM(is_complainer)::numeric / COUNT(*), 4) AS p
    FROM    cells
    GROUP BY tenure_bucket
),
marg AS (
    SELECT SUM(comp) AS total_comp, SUM(non_comp) AS total_non, SUM(n) AS grand
    FROM   by_bucket
)
SELECT  bb.tenure_bucket,
        bb.comp,
        bb.non_comp,
        bb.n,
        bb.p,
        ROUND((bb.n::numeric * m.total_comp / m.grand)::numeric, 4) AS exp_comp,
        ROUND((bb.n::numeric * m.total_non  / m.grand)::numeric, 4) AS exp_non,
        ROUND((POWER(bb.comp     - bb.n::numeric * m.total_comp / m.grand, 2)
                  / NULLIF(bb.n::numeric * m.total_comp / m.grand, 0)
             + POWER(bb.non_comp - bb.n::numeric * m.total_non  / m.grand, 2)
                  / NULLIF(bb.n::numeric * m.total_non  / m.grand, 0))::numeric, 4) AS chi_contribution
FROM    by_bucket bb
CROSS JOIN marg m
ORDER BY bb.tenure_bucket;
