-- Deep Analysis — H1 (role)
-- Contingency test: admin / analyst / viewer vs complainer
WITH complainers AS (
    SELECT DISTINCT opened_by AS user_id
    FROM   support_tickets
    WHERE  category IN ('bug', 'billing')
      AND  opened_by IS NOT NULL
      AND  opened_at >= '2024-06-17'
      AND  opened_at <= '2025-06-17'
),
cells AS (
    SELECT  u.role,
            u.id AS user_id,
            CASE WHEN c.user_id IS NOT NULL THEN 1 ELSE 0 END AS is_complainer
    FROM    users u
    LEFT JOIN complainers c ON u.id = c.user_id
),
by_role AS (
    SELECT  role,
            SUM(is_complainer) AS comp,
            COUNT(*) - SUM(is_complainer) AS non_comp,
            COUNT(*) AS n,
            ROUND(SUM(is_complainer)::numeric / COUNT(*), 4) AS p
    FROM    cells
    GROUP BY role
),
marg AS (
    SELECT SUM(comp) AS total_comp, SUM(non_comp) AS total_non, SUM(n) AS grand
    FROM   by_role
)
SELECT  br.role,
        br.comp,
        br.non_comp,
        br.n,
        br.p,
        ROUND((br.n::numeric * m.total_comp / m.grand)::numeric, 4) AS exp_comp,
        ROUND((br.n::numeric * m.total_non  / m.grand)::numeric, 4) AS exp_non,
        ROUND((POWER(br.comp     - br.n::numeric * m.total_comp / m.grand, 2)
                  / NULLIF(br.n::numeric * m.total_comp / m.grand, 0)
             + POWER(br.non_comp - br.n::numeric * m.total_non  / m.grand, 2)
                  / NULLIF(br.n::numeric * m.total_non  / m.grand, 0))::numeric, 4) AS chi_contribution
FROM    by_role br
CROSS JOIN marg m
ORDER BY br.role;
