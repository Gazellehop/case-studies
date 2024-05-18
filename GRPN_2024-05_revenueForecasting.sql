--Revenue Forecasting: Provide a query that predicts the total revenue for the next quarter based on the average growth rate of the past three complete quarters
--Warning: Extremely imprecise method for calculating prognosis! In this case there are no ways how to avoid seasonality bias. Extrapolation are better to use, but much more complex.
--Sorry, honestly I am not an expert on time series, so I choose princip below. I found my inspiration in https://docs.snowflake.com/en/user-guide/functions-window-using: Calculating a 3-Day Moving Average.
--Snowflake script (beware! this script has not been validated yet, it is only a draft and you may find errors there):
WITH
revenue_quarters as ( --I want to get source with revenue by individual quarters. 
    SELECT 
        DATE_TRUNC(quarter, timestamp)  AS quarter --timestamp format for quarter, example: 2024-04-01 00:00:00
        ,SUM(Amount)                    AS revenue_actuals
      FROM  
        Payment
      GROUP BY quarter
)

SELECT
    Left(quarter,7)  AS quarter --I changed the format to quarter YYYY-QQ
    ,revenue_actuals
    AVG(revenue_actuals) OVER (ORDER BY quarter ROWS BETWEEN 3 PRECEDING AND 1 PRECEDING) as forecasting --3 PRECEDING AND 1 PRECEDING because I want to get forecast from the complete 3 quarters
  FROM 
    revenue_quarters
  ORDER BY
    quarter
    ;
