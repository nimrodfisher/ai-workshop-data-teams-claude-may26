# Context Router

**Read this file before answering any analyst question. Then load ONLY the files it points to.**

The context in `neema-context/` is large — especially the semantic model. Reading all of it
on every question is slow, expensive, and dilutes your attention. Your job is to load the
**minimum set of files** that actually answers the question, and nothing else.

> Principle: *route, don't slurp.* If you can answer from a leaf file, don't read its parents.
> If you're unsure which file holds the answer, read the relevant `_index`/`overview` first
> (cheap), then drill in. Never read a whole folder "to be safe."

---

## How to route (do this every time)

1. **Classify the question on two axes:**
   - **Business axis** — is it about **Account** (B2C / foreign workers / app), **Platform**
     (B2B API / PSPs), a **shared function** (finance, compliance, data, R&D, security, HR),
     or **company-wide** (strategy, org, targets)?
   - **Data axis** — does answering it require querying data? If so, which **entity**
     (transaction, remittance, deposit, card, campaign, loan, user, KPI) and which **metric**?

2. **Load the business context** for the matched area (tables below). Start with the
   `overview` of that area; add a specific department/topic file only if the question is about
   that department/topic.

3. **Load the data context only if the question needs a query:**
   - Always read `05_data-and-metrics/semantic-model/_index.md` (the join map — cheap).
   - If a **named metric** is involved → read `05_data-and-metrics/metrics.yaml` and use its
     **exact** definition (don't reconstruct it).
   - For each **entity** the question touches → read that one per-table file from
     `semantic-model/` (e.g. remittance → `semantic-model/dw_fact_remittance.yml`).

4. **Stop and ask** instead of guessing when the metric, column, table, or grain isn't
   defined in the YAML. A correct "X is undefined, here's the assumption I'd make" beats a
   confident wrong number. (This mirrors `no-guessing` / `ground-truth`.)

---

## Always-load vs on-demand

| Tier | Files | When |
|---|---|---|
| **0 — cheap, almost always** | `router.md` (this), `05_data-and-metrics/semantic-model/_index.md` | Every data question |
| **0 — metrics** | `05_data-and-metrics/metrics.yaml` | Any question naming a metric/KPI |
| **1 — by business area** | the area `overview` + the specific department/topic file | Per the tables below |
| **2 — by data entity** | one per-table file under `semantic-model/` | Only the entities the query touches |

Never default to reading the full `semantic_model.yml`. The split files + `_index.md` exist
so you don't have to. Read the full file only if explicitly asked to audit the whole model.

---

## Business routing

### Which area?
| Signal in the question | Area | Start here |
|---|---|---|
| B2C, foreign workers, app users, remittance/card/SIM/loans **as a consumer product**, churn, retention, ARPU, user segments | **Account** | `02_neema-account/overview.md` |
| B2B, API, Global Payouts, Pay-ins, RTP, IBAN, stablecoins, PSPs/EMIs/MTOs, dynamic routing, pipeline | **Platform** | `03_neema-platform/overview.md` |
| Pricing/FX, KYC/AML, data stack, engineering, security, headcount/hiring | **Shared function** | the file in `04_shared-departments/` |
| Strategy, company targets, org/who-owns-what | **Company-wide** | `01_company-overview/` |

### Account → department file
| Topic | File |
|---|---|
| Product roadmap, initiatives, Q-plans | `02_neema-account/departments/product.md` |
| Growth, acquisition, B2B2C, employer channel | `02_neema-account/departments/growth.md` |
| Operations | `02_neema-account/departments/account-operations.md` |
| Customer support / CS | `02_neema-account/departments/account-cs.md` |
| B2C marketing, campaigns, retention | `02_neema-account/departments/marketing-account.md` |
| Fees / monetization | `02_neema-account/revenue-model.md` |
| Nationalities, corridors, ABCD tiers | `02_neema-account/user-segments.md` |
| Feature catalog (remittance, card, SIM, N2N, loans) | `02_neema-account/products-and-features.md` |

### Platform → department file
| Topic | File |
|---|---|
| GTM, pipeline, HubSpot | `03_neema-platform/departments/platform-gtm.md` |
| Provider network, EMI, expansion | `03_neema-platform/departments/business-operations.md` |
| Integration & ongoing support | `03_neema-platform/departments/platform-cs.md` |
| Product roadmap (platform) | `03_neema-platform/departments/platform-product.md` |
| B2B marketing, MQLs, events | `03_neema-platform/departments/marketing-platform.md` |
| Dynamic Routing (DR®, DR3) | `03_neema-platform/dynamic-routing.md` |
| Pricing / FX spread / monetization | `03_neema-platform/revenue-model.md` |
| ICP, customer scoring | `03_neema-platform/icp-and-customers.md` |
| Product/service catalog | `03_neema-platform/products-and-services.md` |

### Shared functions
| Topic | File |
|---|---|
| Pricing, FX trading, reconciliation | `04_shared-departments/finance.md` |
| KYC/AML, EMI compliance, due diligence | `04_shared-departments/compliance-legal-risk.md` |
| Data stack, sprint process, data targets | `04_shared-departments/data-and-ai.md` |
| Engineering, offshore, mobile modules | `04_shared-departments/rd-engineering.md` |
| Security, AI readiness | `04_shared-departments/security.md` |
| Headcount, hiring, org building | `04_shared-departments/hr.md` |

---

## Data routing

| Question is about… | Per-table file(s) to load |
|---|---|
| Active users, churn, ATD, BFD, customer base, "transactions" generally | `dw_fact_transaction.yml` (+ `metrics.yaml`) |
| Remittance, corridors, beneficiaries, send amounts/FX | `dw_fact_remittance.yml` |
| Deposits / top-ups | `dw_fact_deposit.yml` |
| Card spend (Max/Kasefet), MCC, merchants | `dw_fact_max_transaction.yml` |
| Campaigns, Braze, incentives, referrals, bonuses | `dw_fact_user_campaign_event.yml` |
| Loans, loan/credit score | `dw_dim_user_loan_score_scd.yml` |
| Per-user **monthly** KPI snapshot | `dw_fact_user_monthly_kpis.yml` |
| Per-user **lifetime** KPIs / totals / firsts | `dw_fact_user_kpis.yml` |
| User profile, nationality, segment, install source | `dw_dim_user.yml` |

Joining across entities → consult the **join map** in `semantic-model/_index.md` (always read
it for multi-table questions) and respect the grain/fan-out caveats listed there.

---

## Worked examples (question → exact file set)

- **"What's our churn rate for Filipino remittance users last quarter?"**
  → `metrics.yaml` (CHURN def) · `semantic-model/_index.md` · `dw_fact_transaction.yml`
  (metric base) · `dw_fact_remittance.yml` + `dw_dim_user.yml` (nationality/corridor) ·
  business: `02_neema-account/user-segments.md`. *Not loaded:* Platform, campaigns, loans.

- **"How is campaign X affecting active users?"**
  → `metrics.yaml` (Active_Users) · `_index.md` · `dw_fact_user_campaign_event.yml` ·
  `dw_fact_transaction.yml` · business: `02_neema-account/departments/marketing-account.md`.

- **"What's the B2B pipeline target for the platform GTM team?"**
  → business only: `03_neema-platform/overview.md` + `departments/platform-gtm.md`.
  *No data files* — this is a business/targets question.

- **"Which nationalities have the highest card spend?"**
  → `_index.md` · `dw_fact_max_transaction.yml` · `dw_dim_user.yml` ·
  business: `02_neema-account/user-segments.md`. Note `dw_dim_max_cards` is external.

- **"Who owns compliance and what's our KYC stance?"**
  → business only: `04_shared-departments/compliance-legal-risk.md`. *No data files.*

---

## Self-check before you answer

- Did I read only what the question needs, or did I over-read?
- For every number: is its metric defined in `metrics.yaml` and its column present in the
  loaded per-table file? If not → stop and ask.
- For every join: is the edge in the `_index.md` join map, and did I handle grain/fan-out?
