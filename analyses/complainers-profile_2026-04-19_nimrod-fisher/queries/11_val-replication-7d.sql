-- VAL 05: Replication — daily event rate in final 7 days vs prior 30-day rate
WITH first_tickets AS (
  SELECT org_id, MIN(opened_at) AS first_ticket_at
  FROM support_tickets
  WHERE opened_at >= '2025-03-07'
  GROUP BY org_id
)
SELECT
  ROUND(AVG(events_7d)::numeric, 2) AS avg_events_last_7d,
  ROUND(AVG(events_30d)::numeric, 2) AS avg_events_prior_30d,
  ROUND(AVG(CASE WHEN events_30d > 0 THEN events_7d::numeric / events_30d * (30.0/7) ELSE NULL END)::numeric, 2) AS daily_rate_ratio
FROM (
  SELECT
    ft.org_id,
    COUNT(CASE WHEN e.occurred_at BETWEEN ft.first_ticket_at - INTERVAL '7 days' AND ft.first_ticket_at THEN 1 END) AS events_7d,
    COUNT(CASE WHEN e.occurred_at BETWEEN ft.first_ticket_at - INTERVAL '37 days' AND ft.first_ticket_at - INTERVAL '7 days' THEN 1 END) AS events_30d
  FROM first_tickets ft
  LEFT JOIN events e ON e.org_id = ft.org_id
  GROUP BY ft.org_id
) sub;
