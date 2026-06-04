-- QA-03: Events coverage for pro accounts
SELECT
  MIN(occurred_at)::date AS events_min_date,
  MAX(occurred_at)::date AS events_max_date,
  COUNT(*) AS total_events,
  COUNT(DISTINCT org_id) AS orgs_with_events,
  COUNT(DISTINCT org_id) FILTER (
    WHERE org_id IN (SELECT id FROM accounts WHERE plan = 'pro')
  ) AS pro_orgs_with_events,
  COUNT(*) FILTER (
    WHERE org_id IN (SELECT id FROM accounts WHERE plan = 'pro')
  ) AS pro_events_total,
  (SELECT COUNT(*) FROM accounts WHERE plan = 'pro') AS total_pro_accounts
FROM events;
