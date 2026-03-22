/* =========================================================
   KPI #R4 — Order Failure Rate

   Type         : Outcome
   Description  : % of terminal-state orders that ended in failure

   Numerator    : Orders with status IN ('canceled', 'unavailable')
   Denominator  : Orders with status IN ('delivered', 'canceled', 'unavailable')

   Grain        : 1 row per order_date
   Time Basis   : orders.order_purchase_timestamp

   Notes        :
  - Measures final failed outcomes only
  - Based on terminal-state orders only
  - Terminal states represent finalized order outcomes with no further status transitions
  - Does not diagnose system or process-level mismatches
  - Related operational inconsistencies are monitored separately in R5
========================================================= */

WITH params AS (
    SELECT
        TIMESTAMP('2017-01-01 00:00:00') AS start_ts,
        TIMESTAMP('2018-01-01 00:00:00') AS end_ts
)

SELECT
    DATE(o.order_purchase_timestamp) AS order_date,

    /* numerator: terminal-state orders that ended in failure */
    SUM(
        CASE
            WHEN o.order_status IN ('canceled', 'unavailable')
            THEN 1 ELSE 0
        END
    ) AS failed_orders,

    /* denominator: all terminal-state orders */
    COUNT(*) AS terminal_orders,

    /* ratio: failed terminal-state orders / all terminal-state orders */
    ROUND(
        SUM(
            CASE
                WHEN o.order_status IN ('canceled', 'unavailable')
                THEN 1 ELSE 0
            END
        ) / NULLIF(COUNT(*), 0) * 100.0,
        2
    ) AS failure_rate_pct

FROM orders AS o
JOIN params AS p
  ON o.order_purchase_timestamp >= p.start_ts
 AND o.order_purchase_timestamp <  p.end_ts

/* denominator filter: only terminal-state orders */
WHERE o.order_status IN ('delivered', 'canceled', 'unavailable')

GROUP BY
    DATE(o.order_purchase_timestamp)

ORDER BY
    order_date;
