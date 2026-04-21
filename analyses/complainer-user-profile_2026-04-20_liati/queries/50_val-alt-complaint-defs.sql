-- V1: Alternative complaint definitions x Free/Paid
WITH base AS (
  SELECT DISTINCT t.category, t.opened_by AS user_id FROM support_tickets t
  WHERE t.opened_by IS NOT NULL AND t.opened_at BETWEEN '2024-06-17' AND '2025-06-17'
),
d_bug  AS (SELECT DISTINCT user_id FROM base WHERE category = 'bug'),
d_bill AS (SELECT DISTINCT user_id FROM base WHERE category = 'billing'),
d_bb   AS (SELECT DISTINCT user_id FROM base WHERE category IN ('bug','billing')),
d_bbu  AS (SELECT DISTINCT user_id FROM base WHERE category IN ('bug','billing','usage_question')),
cells AS (
  SELECT u.id AS user_id, CASE WHEN a.plan='free' THEN 'free' ELSE 'paid' END AS plan_group,
         (CASE WHEN d_bug.user_id IS NOT NULL THEN 1 ELSE 0 END)  AS is_bug,
         (CASE WHEN d_bill.user_id IS NOT NULL THEN 1 ELSE 0 END) AS is_bill,
         (CASE WHEN d_bb.user_id IS NOT NULL THEN 1 ELSE 0 END)   AS is_bb,
         (CASE WHEN d_bbu.user_id IS NOT NULL THEN 1 ELSE 0 END)  AS is_bbu
  FROM users u JOIN accounts a ON u.org_id = a.id
  LEFT JOIN d_bug  ON d_bug.user_id  = u.id
  LEFT JOIN d_bill ON d_bill.user_id = u.id
  LEFT JOIN d_bb   ON d_bb.user_id   = u.id
  LEFT JOIN d_bbu  ON d_bbu.user_id  = u.id
)
SELECT plan_group,
       SUM(is_bug) AS c_bug, SUM(is_bill) AS c_bill, SUM(is_bb) AS c_bb, SUM(is_bbu) AS c_bbu,
       COUNT(*) AS n,
       ROUND(SUM(is_bug)::numeric  / COUNT(*), 4) AS r_bug,
       ROUND(SUM(is_bill)::numeric / COUNT(*), 4) AS r_bill,
       ROUND(SUM(is_bb)::numeric   / COUNT(*), 4) AS r_bb,
       ROUND(SUM(is_bbu)::numeric  / COUNT(*), 4) AS r_bbu
FROM cells GROUP BY plan_group ORDER BY plan_group;
