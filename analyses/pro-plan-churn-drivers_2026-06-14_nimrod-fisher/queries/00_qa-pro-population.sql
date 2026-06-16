-- 00_qa-pro-population: account counts and plan-value casing
WITH plan_values AS (
  SELECT plan, COUNT(*) AS accounts
  FROM accounts
  GROUP BY plan
)
SELECT plan, accounts,
       (SELECT COUNT(*) FROM accounts) AS total_accounts
FROM plan_values
ORDER BY accounts DESC;
-- grain: one row per distinct plan value. Confirms plan is lowercase ('pro').
