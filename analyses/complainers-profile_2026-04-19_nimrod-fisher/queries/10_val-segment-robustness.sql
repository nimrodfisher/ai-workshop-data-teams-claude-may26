-- VAL 04: Segment robustness — H4 pre-signal by plan tier
WITH first_tickets AS (
  SELECT st.org_id, MIN(st.opened_at) AS first_ticket_at, a.plan
  FROM support_tickets st
  JOIN accounts a ON st.org_id = a.id
  WHERE st.opened_at >= '2025-03-07'
  GROUP BY st.org_id, a.plan
),
pre_window AS (
  SELECT
    ft.org_id, ft.plan,
    COUNT(CASE WHEN e.occurred_at BETWEEN ft.first_ticket_at - INTERVAL '30 days' AND ft.first_ticket_at THEN 1 END) AS events_before,
    COUNT(CASE WHEN e.occurred_at BETWEEN ft.first_ticket_at - INTERVAL '60 days' AND ft.first_ticket_at - INTERVAL '30 days' THEN 1 END) AS events_baseline
  FROM first_tickets ft
  LEFT JOIN events e ON e.org_id = ft.org_id
  GROUP BY ft.org_id, ft.plan
)
SELECT
  plan,
  COUNT(*) AS accounts,
  ROUND(AVG(events_baseline), 1) AS avg_baseline,
  ROUND(AVG(events_before), 1) AS avg_pre,
  ROUND(AVG(CASE WHEN events_baseline > 0 THEN events_before::numeric / events_baseline ELSE NULL END), 2) AS ratio,
  COUNT(CASE WHEN events_before > events_baseline * 1.5 THEN 1 END) AS spike_accounts
FROM pre_window
GROUP BY plan
ORDER BY ratio DESC;
