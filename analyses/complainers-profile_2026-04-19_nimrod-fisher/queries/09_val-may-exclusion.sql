-- VAL 03: Alternative explanation — May spike isolation
-- Does removing May 2025 first-tickets change the pre-signal result?
WITH first_tickets AS (
  SELECT org_id, MIN(opened_at) AS first_ticket_at
  FROM support_tickets
  WHERE opened_at >= '2025-03-07'
    AND (opened_at < '2025-05-01' OR opened_at >= '2025-06-01')  -- exclude May
  GROUP BY org_id
),
pre_window AS (
  SELECT
    ft.org_id,
    COUNT(CASE WHEN e.occurred_at BETWEEN ft.first_ticket_at - INTERVAL '30 days' AND ft.first_ticket_at THEN 1 END) AS events_before,
    COUNT(CASE WHEN e.occurred_at BETWEEN ft.first_ticket_at - INTERVAL '60 days' AND ft.first_ticket_at - INTERVAL '30 days' THEN 1 END) AS events_baseline
  FROM first_tickets ft
  LEFT JOIN events e ON e.org_id = ft.org_id
  GROUP BY ft.org_id
)
SELECT
  COUNT(*) AS accounts_excl_may,
  ROUND(AVG(events_before), 1) AS avg_pre,
  ROUND(AVG(events_baseline), 1) AS avg_baseline,
  ROUND(AVG(CASE WHEN events_baseline > 0 THEN events_before::numeric / events_baseline ELSE NULL END), 2) AS ratio,
  COUNT(CASE WHEN events_before > events_baseline * 1.5 THEN 1 END) AS spike_accounts
FROM pre_window;
