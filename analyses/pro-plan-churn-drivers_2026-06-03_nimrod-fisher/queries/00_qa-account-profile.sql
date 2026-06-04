-- QA-07: Account profile completeness for pro accounts
SELECT
  COUNT(*) AS total_pro_accounts,
  COUNT(*) FILTER (WHERE industry IS NULL) AS null_industry,
  COUNT(*) FILTER (WHERE created_at IS NULL) AS null_created_at,
  COUNT(*) FILTER (WHERE name IS NULL) AS null_name,
  MIN(created_at)::date AS earliest_account,
  MAX(created_at)::date AS latest_account
FROM accounts
WHERE plan = 'pro';
