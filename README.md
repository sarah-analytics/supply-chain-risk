# Supply Chain Risk Analysis (SQL)

This project analyzes logistics performance and operational risks using SQL on the Olist e-commerce dataset.

The goal is to monitor service health, detect delivery issues, measure failure outcomes, and identify root causes through system-level mismatches.

---

## KPI Framework

### R1 — On-Time Delivery Rate
- Measures baseline logistics performance
- % of orders delivered on or before estimated date

### R2 — Delay Rate
- Detects delivery issues early
- % of orders delivered after estimated date

### R3 — Average Delay Days
- Measures severity of delays
- Average number of delayed days for late deliveries

### R4 — Order Failure Rate
- Measures final failed outcomes
- Based only on terminal-state orders (delivered, canceled, unavailable)

### R5 — System Mismatch Rate
- Flags ERP/WMS/TMS inconsistencies in delivered orders
- % of orders with missing or misaligned payment, fulfillment, or delivery records
---

## Project Structure
```
sql/
└── kpi/
├── kpi_r1_on_time_delivery_rate.sql
├── kpi_r2_delay_rate.sql
├── kpi_r3_average_delay_days.sql
├── kpi_r4_order_failure_rate.sql
└── kpi_r5_system_mismatch_rate.sql
```
---

## Key Concept

- Separate outcome metrics from root cause analysis
- Keep KPI definitions simple and stable
- Use mismatch analysis to explain operational failures

---

## Dataset

- Olist E-commerce Dataset (Brazilian marketplace data)
- Includes orders, payments, items, and delivery information
