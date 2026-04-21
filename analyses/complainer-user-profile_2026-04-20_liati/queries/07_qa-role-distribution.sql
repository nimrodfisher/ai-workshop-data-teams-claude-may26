-- QA 07: users.role value distribution (role is free text)
SELECT
  role,
  COUNT(*) AS user_count,
  ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM users), 2) AS pct
FROM users
GROUP BY role
ORDER BY user_count DESC;
