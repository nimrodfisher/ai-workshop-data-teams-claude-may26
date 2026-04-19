-- VAL 01: Sensitivity — H4 pre-signal with 14-day window (vs original 30-day)
WITH first_tickets AS (
  SELECT org_id, MIN(opened_at) AS first_ticket_at
  FROM support_tickets
  WHERE opened_at >= '2025-03-07'
  GROUP BY org_id
),
pre_window AS (
  SELECT
    ft.org_id,
    COUNT(CASE WHEN e.occurred_at BETWEEN ft.first_ticket_at - INTERVAL '14 days' AND ft.first_ticket_at THEN 1 END) AS events_14d_before,
    COUNT(CASE WHEN e.occurred_at BETWEEN ft.first_ticket_at - INTERVAL '28 days' AND ft.first_ticket_at - INTERVAL '14 days' THEN 1 END) AS events_14d_baseline
  FROM first_tickets ft
  LEFT JOIN events e ON e.org_id = ft.org_id
  GROUP BY ft.org_id
)
SELECT
  ROUND(AVG(events_14d_before), 1) AS avg_pre_14d,
  ROUND(AVG(events_14d_baseline), 1) AS avg_baseline_14d,
  ROUND(AVG(CASE WHEN events_14d_baseline > 0 THEN events_14d_before::numeric / events_14d_baseline ELSE NULL END), 2) AS ratio_14d,
  COUNT(CASE WHEN events_14d_before > events_14d_baseline * 1.5 THEN 1 END) AS spike_accounts_14d,
  COUNT(*) AS total
FROM pre_window;
