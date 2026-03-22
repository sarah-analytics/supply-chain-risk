/* =========================================================
   KPI #R5 — System Mismatch Rate

   Type         : Root Cause
   Description  : Percentage of orders showing inconsistencies
                  between delivered status and related payment,
                  fulfillment, or delivery records.

   Numerator    : Orders with at least one mismatch condition
   Denominator  : All orders

   Grain        : 1 row per order_date
   Time Basis   : orders.order_purchase_timestamp
   Date Filter  : [start_ts, end_ts)
   Output       : order_date, mismatch_orders, total_orders, mismatch_rate_pct

   Notes        :
     - Root-cause proxy KPI based on Olist tables
     - ERP proxy = order status in orders
     - Payment proxy = order_payments
     - WMS proxy = order_items
     - TMS proxy = delivery timestamps
     - Focuses on delivered-side record inconsistencies only
     - To preserve order grain, 1:N child tables are reduced
       to 1 row per order before joining
     - Measures order-level mismatch presence,
       not mismatch event counts
========================================================= */

WITH params AS (
    SELECT
        TIMESTAMP('2017-01-01 00:00:00') AS start_ts,
        TIMESTAMP('2018-01-01 00:00:00') AS end_ts
),

/* payment existence flag: 1 row per order */
payment_flag AS (
    SELECT
        op.order_id,
        1 AS has_payment
    FROM order_payments AS op
    GROUP BY
        op.order_id
),

/* item existence flag: 1 row per order */
item_flag AS (
    SELECT
        oi.order_id,
        1 AS has_item
    FROM order_items AS oi
    GROUP BY
        oi.order_id
)

SELECT
    DATE(o.order_purchase_timestamp) AS order_date,

    /* numerator: delivered orders with missing related records */
    SUM(
        CASE
            WHEN
                /* ERP vs Payment: delivered order but no payment record */
                (o.order_status = 'delivered' AND pf.has_payment IS NULL)

                OR

                /* ERP vs WMS: delivered order but no item (fulfillment) record */
                (o.order_status = 'delivered' AND ifl.has_item IS NULL)

                OR

                /* ERP vs TMS: delivered status but missing actual delivery timestamp */
                (o.order_status = 'delivered'
                 AND o.order_delivered_customer_date IS NULL)
            THEN 1
            ELSE 0
        END
    ) AS mismatch_orders,

    /* denominator: all orders */
    COUNT(*) AS total_orders,

    /* ratio: mismatch orders / all orders */
    ROUND(
        SUM(
            CASE
                WHEN
                    (o.order_status = 'delivered' AND pf.has_payment IS NULL)
                    OR (o.order_status = 'delivered' AND ifl.has_item IS NULL)
                    OR (o.order_status = 'delivered'
                        AND o.order_delivered_customer_date IS NULL)
                THEN 1
                ELSE 0
            END
        ) / NULLIF(COUNT(*), 0) * 100.0,
        2
    ) AS mismatch_rate_pct

FROM orders AS o
JOIN params AS p
  ON o.order_purchase_timestamp >= p.start_ts
 AND o.order_purchase_timestamp <  p.end_ts

LEFT JOIN payment_flag AS pf
  ON o.order_id = pf.order_id

LEFT JOIN item_flag AS ifl
  ON o.order_id = ifl.order_id

GROUP BY
    DATE(o.order_purchase_timestamp)

ORDER BY
    order_date;
