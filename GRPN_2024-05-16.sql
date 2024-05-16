WITH
full_month AS (
    SELECT
        DATE_TRUNC(month,DATEADD(month, '-' || seq4(), CURRENT_DATE())) AS date
      FROM
        TABLE
          (GENERATOR(ROWCOUNT =>24))
)
    ,
last_two_years AS (
    SELECT 
        DATE_TRUNC(month, timestamp)    AS order_month
        ,SUM(Amount)                    AS total_revenue
      FROM
        Payment
      WHERE 
        DATE_TRUNC(month, timestamp) BETWEEN DATEADD(month, -24, CURRENT_DATE()) and CURRENT_DATE()
      GROUP BY 
        order_month
      ORDER BY 
        total_revenue
)

SELECT 
    LEFT(full.date,7)   AS month
    ,CASE 
      WHEN last.total_revenue IS null THEN 0
      ELSE last.total_revenue
    END                 AS total_revenue
  FROM 
    full_month as full
  left join
    last_two_years as last
        ON full.date = last.order_month
    ORDER BY 
      full.date asc
