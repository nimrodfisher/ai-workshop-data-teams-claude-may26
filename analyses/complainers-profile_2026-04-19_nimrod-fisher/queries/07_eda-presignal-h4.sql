-- EDA 07: H4 pre-signal — events in 30 days before first ticket vs prior 30-day baseline
-- Only tickets opened >= 2025-03-07 (events window start)
WITH first_tickets AS (
  SELECT org_id, MIN(opened_at) AS first_ticket_at
  FROM support_tickets
  WHERE opened_at >= '2025-03-07'
  GROUP BY org_id
),
pre_window AS (
  SELECT
    ft.org_id,
    ft.first_ticket_at,
    COUNT(CASE WHEN e.occurred_at BETWEEN ft.first_ticket_at - INTERVAL '30 days' AND ft.first_ticket_at THEN 1 END) AS events_30d_before,
    COUNT(CASE WHEN e.occurred_at BETWEEN ft.first_ticket_at - INTERVAL '60 days' AND ft.first_ticket_at - INTERVAL '30 days' THEN 1 END) AS events_30d_baseline
  FROM first_tickets ft
  LEFT JOIN events e ON e.org_id = ft.org_id
  GROUP BY ft.org_id, ft.first_ticket_at
)
SELECT
  ROUND(AVG(events_30d_before), 1) AS avg_pre_ticket_events,
  ROUND(AVG(events_30d_baseline), 1) AS avg_baseline_events,
  ROUND(AVG(CASE WHEN events_30d_baseline > 0 THEN events_30d_before::numeric / events_30d_baseline ELSE NULL END), 2) AS avg_pre_vs_baseline_ratio,
  COUNT(CASE WHEN events_30d_before > events_30d_baseline * 1.5 THEN 1 END) AS spike_accounts,
  COUNT(CASE WHEN events_30d_before < events_30d_baseline * 0.5 THEN 1 END) AS drop_accounts,
  COUNT(*) AS total_accounts_in_window
FROM pre_window;
