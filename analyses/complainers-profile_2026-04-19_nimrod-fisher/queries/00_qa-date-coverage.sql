-- QA: Date coverage — accounts
SELECT MIN(created_at)::date AS earliest, MAX(created_at)::date AS latest FROM accounts;

-- QA: Date coverage — support_tickets
SELECT MIN(opened_at)::date AS earliest_ticket, MAX(opened_at)::date AS latest_ticket FROM support_tickets;

-- QA: Date coverage — events (key for H4 pre-signal)
SELECT
  MIN(occurred_at)::date AS earliest,
  MAX(occurred_at)::date AS latest,
  COUNT(DISTINCT DATE_TRUNC('month', occurred_at)) AS distinct_months,
  COUNT(DISTINCT org_id) AS orgs_with_events
FROM events;

-- QA: Tickets before events window (pre-signal gap)
SELECT COUNT(*) AS tickets_before_events_window
FROM support_tickets
WHERE opened_at < '2025-03-07';
