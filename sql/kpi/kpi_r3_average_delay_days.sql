/* =========================================================
   KPI #R3 — Average Delay Days

   Type         : Severity
   Description  : Average number of days delayed for late deliveries only

   Numerator    : Sum of delay days
   Denominator  : Delayed orders only

   Grain        : 1 row per order_date
   Time Basis   : orders.order_purchase_timestamp

   Notes        :
     - Measures how severe delays are (not just occurrence)
     - Excludes on-time deliveries
========================================================= */

WITH params AS (
    SELECT
        TIMESTAMP('2017-01-01 00:00:00') AS start_ts,
        TIMESTAMP('2018-01-01 00:00:00') AS end_ts
)

SELECT
    DATE(o.order_purchase_timestamp) AS order_date,

    /* average delay days (only for delayed orders) */
    ROUND(
        AVG(
            CASE
                WHEN o.order_delivered_customer_date > o.order_estimated_delivery_date
                THEN DATEDIFF(
                        o.order_delivered_customer_date,
                        o.order_estimated_delivery_date
                     )
                ELSE NULL
            END
        ),
        2
    ) AS avg_delay_days

FROM orders AS o
JOIN params AS p
  ON o.order_purchase_timestamp >= p.start_ts
 AND o.order_purchase_timestamp <  p.end_ts

/* only delivered orders */
WHERE o.order_status = 'delivered'

GROUP BY
    DATE(o.order_purchase_timestamp)

ORDER BY
    order_date;
