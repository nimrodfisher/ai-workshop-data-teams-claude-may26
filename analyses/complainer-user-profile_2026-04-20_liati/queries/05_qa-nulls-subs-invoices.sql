-- QA 05: null rates on subscriptions and invoices key columns
SELECT 'subscriptions' AS tbl,
       COUNT(*) AS total,
       COUNT(*) FILTER (WHERE status IS NULL) AS null_status,
       COUNT(*) FILTER (WHERE org_id IS NULL) AS null_org_id,
       COUNT(*) FILTER (WHERE product_id IS NULL) AS null_product_id,
       COUNT(*) FILTER (WHERE started_at IS NULL) AS null_started_at,
       NULL::bigint AS null_paid_at,
       NULL::bigint AS null_issued_at,
       NULL::bigint AS null_subscription_id
FROM subscriptions
UNION ALL
SELECT 'invoices',
       COUNT(*),
       NULL, NULL, NULL, NULL,
       COUNT(*) FILTER (WHERE paid_at IS NULL),
       COUNT(*) FILTER (WHERE issued_at IS NULL),
       COUNT(*) FILTER (WHERE subscription_id IS NULL)
FROM invoices;
