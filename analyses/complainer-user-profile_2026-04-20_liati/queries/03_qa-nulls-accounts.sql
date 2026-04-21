-- QA 03: null rates on key accounts columns
SELECT
  COUNT(*) AS total_accounts,
  COUNT(*) FILTER (WHERE plan IS NULL) AS null_plan,
  COUNT(*) FILTER (WHERE industry IS NULL) AS null_industry,
  COUNT(*) FILTER (WHERE created_at IS NULL) AS null_created_at
FROM accounts;
