-- QA: Null rates per column — support_tickets
SELECT
  COUNT(*) AS total_tickets,
  COUNT(id) AS non_null_id,
  COUNT(org_id) AS non_null_org_id,
  COUNT(opened_by) AS non_null_opened_by,
  COUNT(status) AS non_null_status,
  COUNT(category) AS non_null_category,
  COUNT(opened_at) AS non_null_opened_at,
  COUNT(closed_at) AS non_null_closed_at
FROM support_tickets;

-- QA: Null rates per column — accounts
SELECT
  COUNT(*) AS total_accounts,
  COUNT(id) AS non_null_id,
  COUNT(name) AS non_null_name,
  COUNT(industry) AS non_null_industry,
  COUNT(plan) AS non_null_plan,
  COUNT(created_at) AS non_null_created_at
FROM accounts;

-- QA: Null rates per column — events
SELECT
  COUNT(*) AS total_events,
  COUNT(id) AS non_null_id,
  COUNT(org_id) AS non_null_org_id,
  COUNT(user_id) AS non_null_user_id,
  COUNT(event_type) AS non_null_event_type,
  COUNT(occurred_at) AS non_null_occurred_at
FROM events;
