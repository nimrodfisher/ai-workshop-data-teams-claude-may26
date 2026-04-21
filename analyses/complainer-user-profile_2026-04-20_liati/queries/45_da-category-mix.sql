-- Deep Analysis — Category mix (bug vs billing) per plan
-- Surfaces WHAT each plan's complainers complain about.
WITH cats AS (
    SELECT  a.plan, t.category, COUNT(*) AS tickets
    FROM    support_tickets t
    JOIN    users    u ON u.id = t.opened_by
    JOIN    accounts a ON u.org_id = a.id
    WHERE   t.category IN ('bug', 'billing')
      AND   t.opened_at >= '2024-06-17'
      AND   t.opened_at <= '2025-06-17'
    GROUP BY a.plan, t.category
),
tot AS (
    SELECT plan, SUM(tickets) AS total FROM cats GROUP BY plan
)
SELECT  c.plan,
        c.category,
        c.tickets,
        t.total,
        ROUND(c.tickets::numeric / t.total, 4) AS share
FROM    cats c
JOIN    tot  t USING (plan)
ORDER BY c.plan, c.category;
