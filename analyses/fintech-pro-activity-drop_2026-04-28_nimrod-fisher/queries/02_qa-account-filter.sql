-- QA: FinTech Pro account filter validation (plans are lowercase in DB)
-- Checks: count of FinTech+pro accounts, plan casing, null checks

SELECT
  COUNT(*) FILTER (WHERE industry = 'FinTech' AND plan = 'pro') AS fintech_pro_count,
  COUNT(*) AS total_accounts,
  COUNT(DISTINCT industry) AS distinct_industries,
  COUNT(DISTINCT plan) AS distinct_plans,
  COUNT(*) FILTER (WHERE industry IS NULL) AS null_industry,
  COUNT(*) FILTER (WHERE plan IS NULL) AS null_plan
FROM accounts;
