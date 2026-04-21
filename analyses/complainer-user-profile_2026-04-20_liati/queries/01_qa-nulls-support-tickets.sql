-- QA 01: null rates on key support_tickets columns
SELECT
  COUNT(*) AS total_tickets,
  COUNT(*) FILTER (WHERE opened_by IS NULL) AS null_opened_by,
  COUNT(*) FILTER (WHERE category IS NULL) AS null_category,
  COUNT(*) FILTER (WHERE opened_at IS NULL) AS null_opened_at,
  COUNT(*) FILTER (WHERE org_id IS NULL) AS null_org_id,
  COUNT(*) FILTER (WHERE status IS NULL) AS null_status,
  ROUND(100.0 * COUNT(*) FILTER (WHERE opened_by IS NULL) / NULLIF(COUNT(*), 0), 2) AS pct_null_opened_by,
  ROUND(100.0 * COUNT(*) FILTER (WHERE category IS NULL) / NULLIF(COUNT(*), 0), 2) AS pct_null_category
FROM support_tickets;
