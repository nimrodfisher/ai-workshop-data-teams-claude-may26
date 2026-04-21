-- QA 08: accounts.plan value distribution
SELECT
  plan,
  COUNT(*) AS account_count,
  ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM accounts), 2) AS pct
FROM accounts
GROUP BY plan
ORDER BY account_count DESC;
