/* =========================================================
   KPI #R1 — On-Time Delivery Rate

   Type         : Health Check
   Description  : % of delivered orders completed on or before estimated delivery date

   Numerator    : Delivered orders where actual_delivery_date <= estimated_delivery_date
   Denominator  : Delivered orders

   Grain        : 1 row per order_date
   Time Basis   : orders.order_purchase_timestamp

   Notes        :
     - Baseline logistics performance KPI
     - Evaluated only on delivered orders
========================================================= */

WITH params AS (
    SELECT
        TIMESTAMP('2017-01-01 00:00:00') AS start_ts,
        TIMESTAMP('2018-01-01 00:00:00') AS end_ts
)

SELECT
    DATE(o.order_purchase_timestamp) AS order_date,

    /* numerator: delivered orders that arrived on time */
    SUM(
        CASE
            WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date
            THEN 1 ELSE 0
        END
    ) AS on_time_orders,

    /* denominator: all delivered orders */
    COUNT(*) AS delivered_orders,

    /* ratio: on-time delivered orders / all delivered orders */
   ROUND(
    SUM(
        CASE
            WHEN o.order_delivered_customer_date <= o.order_estimated_delivery_date
            THEN 1 ELSE 0
        END
    ) / NULLIF(COUNT(*), 0) * 100.0,
    2
   ) AS on_time_rate_pct

FROM orders AS o
JOIN params AS p
  ON o.order_purchase_timestamp >= p.start_ts
 AND o.order_purchase_timestamp <  p.end_ts

/* denominator filter: only delivered orders */
WHERE o.order_status = 'delivered'

GROUP BY
    DATE(o.order_purchase_timestamp)

ORDER BY
    order_date;
