--Monthly Revenue: write a query that will return the total revenue for each month over the last two years and include months with zero revenue in the result.
--Potential problems:in the Payment table there can be situation that in the last two years weren't any transactions during a month, so it's necessarry to solve it.
--Snowflake script (beware! this script has not been validated yet, it is only a draft and you may find errors there):
WITH
--First, I will solve the situation where there may be no transaction in one of the months, but I still want to display it among the other months with a result = 0. There is no "create_series" function in snowflake, so I will use code that I have used in similar situations in the past.
full_month AS (
    SELECT
        DATE_TRUNC(month,DATEADD(month, '-' || seq4(), CURRENT_DATE())) AS date --I will get the date in format YYYY-MM-DD, example: 2024-05-01. It is monthly granularity, so every day was changed to YYYY-MM-01
      FROM
        TABLE
          (GENERATOR(ROWCOUNT =>24)) --Why 24? Because we want to look see 24 months. There is big question, whether we want to see only closed months or 24 closed months + current month or 23 closed months + current month. This is only about discuss before starting the task. In that case it is only about changing the conditions.
),
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
