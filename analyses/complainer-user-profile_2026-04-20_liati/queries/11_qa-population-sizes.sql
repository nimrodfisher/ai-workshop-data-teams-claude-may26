-- QA 11: population sizing under strict vs remapped complaint definition
-- Strict: (bug_report, technical, billing) — from the original plan
-- Remapped: (bug, usage_question, billing) — best-fit to actual values found in QA 06
WITH pop AS (
  SELECT u.id AS user_id, u.org_id, u.role, u.created_at, a.plan, a.industry
  FROM users u JOIN accounts a ON u.org_id = a.id
),
complainers_strict AS (
  SELECT DISTINCT opened_by AS user_id FROM support_tickets
  WHERE category IN ('bug_report','technical','billing') AND opened_by IS NOT NULL
),
complainers_mapped AS (
  SELECT DISTINCT opened_by AS user_id FROM support_tickets
  WHERE category IN ('bug','usage_question','billing') AND opened_by IS NOT NULL
),
any_ticket_user AS (
  SELECT DISTINCT opened_by AS user_id FROM support_tickets WHERE opened_by IS NOT NULL
)
SELECT
  (SELECT COUNT(*) FROM pop) AS total_users_in_population,
  (SELECT COUNT(*) FROM any_ticket_user) AS users_with_any_ticket,
  (SELECT COUNT(*) FROM complainers_strict) AS complainers_under_plan_definition_strict,
  (SELECT COUNT(*) FROM complainers_mapped) AS complainers_under_remapped_definition,
  (SELECT COUNT(*) FROM pop) - (SELECT COUNT(*) FROM any_ticket_user) AS users_without_any_ticket;
