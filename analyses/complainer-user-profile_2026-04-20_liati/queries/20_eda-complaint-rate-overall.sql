-- EDA 20: baseline complaint rate (user-level)
-- Complaint = user with >=1 ticket where category IN ('bug','billing') in [2024-06-17, 2025-06-17]
WITH pop AS (
  SELECT u.id AS user_id FROM users u JOIN accounts a ON u.org_id = a.id
),
complainers AS (
  SELECT DISTINCT opened_by AS user_id
  FROM support_tickets
  WHERE category IN ('bug','billing')
    AND opened_by IS NOT NULL
    AND opened_at >= '2024-06-17'
    AND opened_at <= '2025-06-17'
)
SELECT
  (SELECT COUNT(*) FROM pop) AS total_users,
  (SELECT COUNT(*) FROM complainers) AS complainer_users,
  ROUND(100.0 * (SELECT COUNT(*) FROM complainers) / (SELECT COUNT(*) FROM pop), 2) AS complaint_rate_pct;
