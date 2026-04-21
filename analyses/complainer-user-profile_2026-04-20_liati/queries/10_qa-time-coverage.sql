-- QA 10: time coverage — min/max dates and rows in/out of planned window
-- Planned window: [2025-04-20, 2026-04-20)
SELECT 'support_tickets' AS table_name,
       MIN(opened_at)::date AS min_date,
       MAX(opened_at)::date AS max_date,
       COUNT(*) AS total_rows,
       COUNT(*) FILTER (WHERE opened_at >= '2025-04-20' AND opened_at < '2026-04-20') AS in_window,
       COUNT(*) FILTER (WHERE opened_at <  '2025-04-20') AS before_window,
       COUNT(*) FILTER (WHERE opened_at >= '2026-04-20') AS after_window
FROM support_tickets
UNION ALL
SELECT 'events',
       MIN(occurred_at)::date, MAX(occurred_at)::date, COUNT(*),
       COUNT(*) FILTER (WHERE occurred_at >= '2025-04-20' AND occurred_at < '2026-04-20'),
       COUNT(*) FILTER (WHERE occurred_at <  '2025-04-20'),
       COUNT(*) FILTER (WHERE occurred_at >= '2026-04-20')
FROM events
UNION ALL
SELECT 'users (created_at)',
       MIN(created_at)::date, MAX(created_at)::date, COUNT(*),
       COUNT(*) FILTER (WHERE created_at >= '2025-04-20' AND created_at < '2026-04-20'),
       COUNT(*) FILTER (WHERE created_at <  '2025-04-20'),
       COUNT(*) FILTER (WHERE created_at >= '2026-04-20')
FROM users;
