--Revenue Forecasting: Provide a query that predicts the total revenue for the next quarter based on the average growth rate of the past three complete quarters
--Warning: Extremely imprecise method for calculating prognosis! In this case there are no ways how to avoid seasonality bias. Extrapolation are better to use, but much more complex.
--Sorry, honestly I am not an expert on time series, so I selected princip below. I found my inspiration in https://docs.snowflake.com/en/user-guide/functions-window-using: Calculating a 3-Day Moving Average.
--Snowflake script:
WITH
revenue_quarters AS ( --I want to get source with revenue by individual quarters. 
    SELECT 
        DATE_TRUNC(quarter, timestamp)  AS quarter --timestamp format for quarter, example: 2024-04-01 00:00:00
        ,SUM(Amount)                    AS revenue_actuals
      FROM  
        Payment
      GROUP BY quarter
)

SELECT
    LEFT(quarter,7)  AS quarter --I changed the format to YYYY-QQ
    ,revenue_actuals
    AVG(revenue_actuals) OVER (ORDER BY quarter ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING) AS forecasting --3 PRECEDING AND 1 PRECEDING because I want to get forecast from the 3 previous complete quarters
  FROM 
    revenue_quarters
  ORDER BY
    quarter
    ;
