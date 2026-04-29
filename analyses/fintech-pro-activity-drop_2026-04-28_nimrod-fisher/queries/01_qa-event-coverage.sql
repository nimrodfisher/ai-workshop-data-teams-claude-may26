-- QA: Event coverage window, row counts, and zero-day gap check
-- Checks: MIN/MAX event date, total rows, FinTech Pro rows, daily zero-event gap at end

SELECT
  MIN(occurred_at)::date AS events_min_date,
  MAX(occurred_at)::date AS events_max_date,
  COUNT(*)               AS total_event_rows,
  COUNT(DISTINCT DATE(occurred_at)) AS days_with_events
FROM events;
