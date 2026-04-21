-- QA 02: null rates on key users columns
SELECT
  COUNT(*) AS total_users,
  COUNT(*) FILTER (WHERE org_id IS NULL) AS null_org_id,
  COUNT(*) FILTER (WHERE role IS NULL) AS null_role,
  COUNT(*) FILTER (WHERE created_at IS NULL) AS null_created_at,
  COUNT(*) FILTER (WHERE full_name IS NULL) AS null_full_name,
  COUNT(*) FILTER (WHERE email IS NULL) AS null_email
FROM users;
