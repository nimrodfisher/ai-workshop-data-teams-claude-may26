# Semantic Model — Index & Join Map

This is the **cheap-to-read map** of the warehouse. Read this file first, then load
**only** the per-table file(s) the question touches. Each per-table `.yml` is a
self-contained fragment of `../semantic_model.yml` (the full source of truth) and
carries its own `relationships:` block.

> Ground truth is `../semantic_model.yml` and `../metrics.yaml`. These split files and
> the join map below are **derived** from it. If they disagree, the source `.yml` wins —
> regenerate the splits (see `../../../GOVERNANCE.md`).

## Tables → file → when to load

| Table | File | Load when the question is about… |
|---|---|---|
| `dw_fact_transaction` | `dw_fact_transaction.yml` | Any wallet transaction; the base for all metrics (active users, churn, ATD, BFD, customer base) |
| `dw_fact_remittance` | `dw_fact_remittance.yml` | Money transfers / remittance corridors, beneficiaries, FX fees |
| `dw_fact_deposit` | `dw_fact_deposit.yml` | Deposits / top-ups into the wallet |
| `dw_fact_max_transaction` | `dw_fact_max_transaction.yml` | Max / Kasefet card spend (Mastercard/Visa), MCC, merchants |
| `dw_fact_user_campaign_event` | `dw_fact_user_campaign_event.yml` | Marketing campaigns, Braze, incentives/bonuses, referrals |
| `dw_dim_user_loan_score_scd` | `dw_dim_user_loan_score_scd.yml` | Loans, credit/loan scoring history (slowly-changing) |
| `dw_fact_user_monthly_kpis` | `dw_fact_user_monthly_kpis.yml` | Pre-aggregated per-user **monthly** KPI snapshots |
| `dw_fact_user_kpis` | `dw_fact_user_kpis.yml` | Per-user **lifetime** KPIs (totals, firsts, LTV-style fields) |
| `dw_dim_user` | `dw_dim_user.yml` | User profile, segments, nationality/corridor, install attribution. **Central hub** for almost every join |

## Join map (every edge — derived from the `relationships:` blocks)

`dw_dim_user` is the hub. Join user-level facts to it on `USER_ID` (UUID) or `NEEMA_ID` (numeric).

```
dw_dim_user  (HUB: USER_ID / NEEMA_ID)
├── dw_fact_transaction          USER_ID / NEEMA_ID
├── dw_fact_remittance           USER_ID / NEEMA_ID
├── dw_fact_deposit              DEPOSIT_CUTOMER_ID→USER_ID  /  NEEMA_ID
├── dw_fact_max_transaction      USER_ID / NEEMA_ID
├── dw_fact_user_campaign_event  USER_ID / NEEMA_ID
├── dw_fact_user_monthly_kpis    USER_ID / NEEMA_ID
├── dw_fact_user_kpis            USER_ID / NEEMA_ID
└── dw_dim_user_loan_score_scd   USER_ID / NEEMA_ID

Transaction-level links (fact ↔ fact):
dw_fact_transaction ─ dw_fact_remittance   TRANSACTION_UNIQUE_ID ; remittance.TRANSACTION_ID→transaction.TRANSACTION_ID
dw_fact_transaction ─ dw_fact_deposit      transaction.TRANSACTION_UNIQUE_ID↔deposit.DEPOSIT_UNIQUE_ID ; deposit.DEPOSIT_UNIQUE_ID→transaction.TRANSACTION_ID
dw_fact_user_campaign_event ─ dw_fact_transaction   BONUS_TRANSACTION_ID → TRANSACTION_ID  (only campaign bonus rows)
dw_dim_user_loan_score_scd  ─ dw_fact_user_kpis      USER_ID
dw_fact_max_transaction ─ dw_dim_max_cards           CARD_ID   ⚠ external: dw_dim_max_cards is NOT in this semantic model
```

## Caveats to carry into any query (governance flags)

- **Grain & fan-out:** `dw_dim_user` is one row per user; the `_fact_` tables are one row
  per event/transaction. Joining a fact to another fact through the user hub fans out —
  aggregate to the intended grain on purpose and say so.
- **Asymmetric deposit↔transaction keys:** the model links
  `transaction.TRANSACTION_UNIQUE_ID ↔ deposit.DEPOSIT_UNIQUE_ID` on one side and
  `deposit.DEPOSIT_UNIQUE_ID → transaction.TRANSACTION_ID` on the other. Confirm which key
  pair is correct before joining; flag it, don't guess.
- **`DEPOSIT_CUTOMER_ID`** is spelled as-is in the source (likely a typo for "CUSTOMER").
  Use the literal column name; note it.
- **External dim:** `dw_dim_max_cards` is referenced by card joins but not modeled here.
  Flag as missing if a question needs card-master attributes.
- **SCD table:** `dw_dim_user_loan_score_scd` is slowly-changing — filter to the correct
  validity window / current flag before counting users.
