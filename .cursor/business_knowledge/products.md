# Pulseboard — Product Catalog

Pulseboard ships three SKUs, tracked in the `products` table. They map to different customer shapes and generate different patterns of activity, so the agent should reason about them separately rather than lumping them together.

## Pulseboard Analytics ($99/mo) — flagship

Full self-serve BI: dashboards, reports, ad-hoc queries, scheduled deliveries. This is where most Enterprise accounts live and where the richest event activity happens — logins, report views, file uploads, the full mix.

A healthy Analytics account has regular analyst-role activity (not just admin logins), a steady stream of `report_view` events, and file uploads on roughly a weekly cadence. Sparse or admin-only activity on this SKU is unusual and worth flagging.

Metrics that matter most here: weekly active users, reports created per account, dashboard views, and renewal-stage signals like net revenue retention.

## Pulseboard Starter ($49/mo) — entry tier

Lightweight tier: read-only dashboards and scheduled email reports. This is the most common upgrade path from free, and its commercial job is to convert into Pulseboard Analytics within a few months. Low engagement on Starter isn't necessarily bad — the product is narrow by design — but low engagement *without* an upgrade by month 3 usually means the account won't expand.

Metrics that matter most here: activation rate, upgrade rate into Analytics, and dashboard views. Don't judge Starter accounts by the same activity bar as Analytics accounts.

## Pulseboard Embed ($99/mo) — API / white-label

Embedded analytics for customers who surface Pulseboard dashboards inside their own applications via API. Activity here looks very different from the other two SKUs: much higher `api_call` volume, much lower human-in-the-UI activity (few logins, few report views). A quiet Embed account with healthy API traffic is *fine*; a quiet Embed account with falling API traffic is not.

Metrics that matter most here: API call volume, API error rate, and embedded view counts. If an agent is grading Embed accounts on login frequency, it's grading the wrong thing.

## Reading this catalog when analyzing data

When you see a product SKU in query results, use the commercial context above to interpret it — not just the raw numbers. "Low activity" means different things across the three products, and a good analyst answer reflects that.