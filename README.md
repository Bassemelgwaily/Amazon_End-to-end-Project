# Amazon Egypt Data Warehouse

A hands-on, end-to-end Data Warehouse project built on **SQL Server**, simulating a real Egyptian e-commerce marketplace (first-party + third-party sellers), following the **Medallion Architecture** (Bronze → Silver → Gold) and modeled as a **Galaxy Schema** (6 independent Fact tables sharing 13 Conformed Dimensions).

> Status: Bronze, Silver and Gold layers are fully built and loaded. Next steps: ad-hoc analytical views/CTEs (RFM, cohort, etc.) and a Power BI connection on top of the Gold layer.

---

## 1. Project Scope

This project simulates the core operations of an Amazon-Egypt-style marketplace:

- **First-party + third-party selling** — one retail seller ("Amazon Retail") plus 79 marketplace sellers, with commission charged only on marketplace orders.
- **Full order lifecycle** — sales, returns, product reviews, delivery performance, and inventory stock levels.
- **Marketing attribution** — which platform / campaign / adset a customer's order is attributed to.
- **Real Egyptian seasonality** — Ramadan, Eid al-Fitr, Eid al-Adha, Mother's Day, White Friday, etc., modeled with a measurable lift on order volume.
- **Customer segmentation left un-baked** — no pre-computed RFM fields in `dim_customer`; segmentation is meant to be computed live with SQL on top of `fact_sales`.

**Data range:** January 2025 – September 2026
**Scale:** ~28K orders / ~41K order lines, 300 products, 80 sellers, 3,000 customers.

---

## 2. Architecture — Medallion (Bronze / Silver / Gold)

All three layers live in **one SQL Server database**, separated as three **schemas** (`bronze`, `silver`, `gold`) rather than three physical databases — this keeps cross-layer joins, permissions (read-only grants per schema), and backups simple.

| Layer | Purpose | Data types | Constraints |
|---|---|---|---|
| **Bronze** | Raw, 1:1 copy of every source CSV, loaded via `BULK INSERT` | All columns `NVARCHAR` | None |
| **Silver** | Cleaned & correctly typed (`TRY_CAST`, `NULLIF`, text→`BIT` via `CASE WHEN`) | Real SQL types | Primary Keys only — **no Foreign Keys yet**, to keep loads fast and flexible |
| **Gold** | Business-ready, with calculated/derived columns | Real SQL types | **Primary Keys + Foreign Keys** — guarantees referential integrity before the data reaches BI |

### Bronze layer notes
- 19 source CSVs loaded as-is via `BULK INSERT`.
- Source files are UTF-8, LF-terminated (generated on Linux), which required explicit `ROWTERMINATOR = '0x0a'` and `CODEPAGE = '65001'` in every `BULK INSERT` statement (the SQL Server default assumes Windows CRLF).

### Silver layer notes
- `TRY_CAST` used everywhere instead of `CAST`, so a bad value becomes `NULL` instead of failing the whole batch.
- `NULLIF('', ...)` converts blank strings to true `NULL` before casting.
- `CASE WHEN ... THEN 1 ELSE 0 END` converts text `'True'/'False'` values into real `BIT` columns.
- Every table script ends with a row-count + NULL-check `SELECT` before moving to the next table.

### Gold layer notes — calculated columns added
| Fact table | Calculated columns |
|---|---|
| `fact_sales` | `total_cost`, `profit`, `profit_margin_pct`, `net_revenue_seller` |
| `fact_marketing` | `ctr`, `cvr`, `cpc`, `roas` (with divide-by-zero guards) |
| `fact_inventory` | `days_of_supply`, `stock_health` |
| `fact_delivery` | `delivery_duration_days`, `on_time_flag` |
| `dim_customer` | `customer_age` (via `DATEDIFF`, birthday-not-yet-occurred corrected) |
| `dim_product` | `top_category_name` (via a self-join on `dim_category`, climbing from leaf category to top-level category) |

---

## 3. Data Model — Galaxy Schema

**6 Fact tables** (each independent, not hard-linked to one another) + **13 Dimension tables** (Conformed, shared across facts).

### Fact tables
| Table | Grain | Notes |
|---|---|---|
| `fact_sales` | One row per order line | Core sales fact |
| `fact_returns` | One row per returned item | **Degenerate dimension**: `original_order_id` / `original_order_line_id` kept as plain reference numbers, no FK back to `fact_sales` — it stands on its own |
| `fact_reviews` | One row per product review | Degenerate dimension on `order_line_id`, same reasoning as above |
| `fact_delivery` | One row per order | **Role-playing dimension**: `order_date_id`, `shipped_date_id`, `delivered_date_id` all reference the *same* `dim_date` table via three separate FKs |
| `fact_marketing` | One row per ad-set/day attribution event | Tracks platform → campaign → adset attribution |
| `fact_inventory` | Weekly snapshot per product × warehouse | Periodic snapshot fact, used for stock vs. demand analysis |

### Dimension tables
`dim_date`, `dim_customer`, `dim_product`, `dim_category` (self-referencing `parent_category_id` → `category_id` hierarchy), `dim_seller`, `dim_warehouse`, `dim_shipping`, `dim_payment_method`, `dim_promotion`, `dim_return_reason`, `dim_platform`, `dim_campaign`, `dim_adset`.

**Design decisions worth calling out:**
- `fact_returns` is a **fully independent fact table** (not FK-linked to `fact_sales`), by deliberate design — it has its own complete dimensional context (customer, product, seller, date, reason).
- `dim_customer` is kept purely descriptive — **no pre-computed RFM/segmentation fields**. Recency/Frequency/Monetary is computed live via SQL against `fact_sales`.
- `dim_promotion` holds real Egyptian seasonal campaigns (Ramadan, Eid al-Fitr, Eid al-Adha, Mother's Day, White Friday, etc.) with a visible, measurable lift on order volume during those windows.
- PK/FK placement follows Kimball best practice: constraints are enforced in **Gold**, not Silver, so ingestion stays fast/flexible upstream and integrity is guaranteed right before BI consumption.

---

## 4. Tech Stack

- **SQL Server** — all 3 layers, `BULK INSERT`, `TRY_CAST`, constraints
- **Python** (pandas, numpy) — synthetic data generation (Poisson-distributed daily order volume with holiday/weekend multipliers, lognormal customer/product popularity skew)
- **Power BI** (planned) — Gold layer only is meant to be exposed as the BI data source; Bronze/Silver stay internal

---

## 5. Repository Structure (suggested)

```
/data/                      raw CSV source files (19 files)
/sql/
  01_create_database_and_bronze.sql
  02_bulk_insert_remaining_tables.sql
  03_silver_layer_tables.sql
  04_silver_layer_remaining_tables.sql
  05_gold_layer_copy_as_is_tables.sql
  06_gold_layer_enriched_tables.sql
  07_gold_layer_final_tables.sql
/docs/
  README.md                 (this file)
  ERD.png                    data model diagram
```

---

## 6. What's Next

- [ ] Analytical CTEs/Views on the Gold layer (RFM segmentation, cohort analysis, seasonal lift analysis)
- [ ] Power BI connection (Gold schema only)
- [ ] Data quality checks / automated validation pass

---

**Author:** Bassem Mohamed Elgwaily
