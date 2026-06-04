-- DA-09: Tenure distribution stats for canceled vs active PRO subscriptions
SELECT
  s.status,
  COUNT(*) AS n,
  ROUND(AVG(
    CASE WHEN s.canceled_at IS NOT NULL
      THEN (s.canceled_at - s.started_at)
      ELSE (CURRENT_DATE - s.started_at)
    END
  ), 0) AS avg_days,
  ROUND(PERCENTILE_CONT(0.25) WITHIN GROUP (ORDER BY
    CASE WHEN s.canceled_at IS NOT NULL
      THEN (s.canceled_at - s.started_at)
      ELSE (CURRENT_DATE - s.started_at)
    END
  ), 0) AS p25_days,
  ROUND(PERCENTILE_CONT(0.50) WITHIN GROUP (ORDER BY
    CASE WHEN s.canceled_at IS NOT NULL
      THEN (s.canceled_at - s.started_at)
      ELSE (CURRENT_DATE - s.started_at)
    END
  ), 0) AS median_days,
  ROUND(PERCENTILE_CONT(0.75) WITHIN GROUP (ORDER BY
    CASE WHEN s.canceled_at IS NOT NULL
      THEN (s.canceled_at - s.started_at)
      ELSE (CURRENT_DATE - s.started_at)
    END
  ), 0) AS p75_days,
  MIN(
    CASE WHEN s.canceled_at IS NOT NULL
      THEN (s.canceled_at - s.started_at)
      ELSE (CURRENT_DATE - s.started_at)
    END
  ) AS min_days,
  MAX(
    CASE WHEN s.canceled_at IS NOT NULL
      THEN (s.canceled_at - s.started_at)
      ELSE (CURRENT_DATE - s.started_at)
    END
  ) AS max_days
FROM subscriptions s
JOIN accounts a ON s.org_id = a.id
WHERE a.plan = 'pro' AND s.status IN ('active', 'canceled')
GROUP BY s.status
ORDER BY s.status;
