-- QA-04: H1 testability window for churned pro accounts
WITH pro_churned AS (
  SELECT DISTINCT a.id AS account_id, s.canceled_at
  FROM accounts a
  JOIN subscriptions s ON s.org_id = a.id
  WHERE a.plan = 'pro' AND s.status = 'canceled'
),
ev_range AS (
  SELECT MIN(occurred_at)::date AS ev_min, MAX(occurred_at)::date AS ev_max FROM events
)
SELECT
  COUNT(*) AS total_churned_pro,
  COUNT(*) FILTER (
    WHERE canceled_at >= (SELECT ev_min + INTERVAL '30 days' FROM ev_range)
      AND canceled_at <= (SELECT ev_max FROM ev_range)
  ) AS h1_testable,
  COUNT(*) FILTER (
    WHERE canceled_at < (SELECT ev_min + INTERVAL '30 days' FROM ev_range)
       OR canceled_at > (SELECT ev_max FROM ev_range)
       OR canceled_at IS NULL
  ) AS h1_excluded,
  MIN(canceled_at) AS earliest_cancel,
  MAX(canceled_at) AS latest_cancel
FROM pro_churned;
