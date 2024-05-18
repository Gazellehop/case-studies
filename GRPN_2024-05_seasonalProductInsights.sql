--Seasonal Product Insights: Identify the top 5 products with the highest percentage increase in sales during the holiday season (November and December) compared to the rest of the year
--Assumption: product table has broken column is_deleted, 
--Risks: The task is focused on relative data, which can be misleading because there is a risk of bias => from my experience: very often it can happen that an increase of 50% against normal months can be a higher absolute number than an increase of 1000%, it always depends on the basis from which we start. If we want to see the absolute difference, then I need this query in a different way.
--Snowflake script (ONLY DRAFT, WITHOUT VALIDATION):
WITH
--There is one broken column "is_deleted" in the table Products
--The target is to recreate the column in query to get the right results
--assumptions:
-- - product_id is primal key
-- - in order to have historical changes in this table this column exists to see log of updates
-- - the product_id is same for all updated rows
-- - to select only viable product you would have to select only is_deleted = FALSE
--Note: in this table one column is missing (Active_product with results True/False). 
products_update AS (
SELECT
    product_id
    ,name
    ,Category
    ,price_per_unit
    ,Updated_at
    ,CASE 
      WHEN rn = 1 THEN 'FALSE' --the latest records mean active product
      ELSE 'TRUE' --the older records mean an inactive product
    END AS is_deleted
  FROM
    (SELECT 
        product_id
        ,name
        ,Category
        ,price_per_unit
        ,Updated_at
        ,ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY updated_at DESC) AS rn --thanks to this I will get information about the last records for each product. Row number 1 means in this case the last change.
      FROM
        Products)
),
payment_products AS ( --join of infromation from payment and products table
    SELECT
        DATE_TRUNC(month, pay.timestamp)    AS month --I will get the date in format YYYY-MM-DD, example: 2024-05-01. It is monthly granularity, so every day was changed to YYYY-MM-01
        ,prod.product_id                    AS product_id
        ,SUM(pay.quantity)                  AS quantity
      FROM
        Payment AS pay
      LEFT JOIN
        products_update AS prod
      ON 
        pay.product_id = prod.product_id
      WHERE
        DATE_TRUNC(month, pay.timestamp) BETWEEN '2023-01-01' AND '2023-12-31' --I am interested in the data from 2023
      AND
        prod.is_deleted = 'FALSE'
),
products_2023_part1 AS (
    SELECT
        product_id
        ,AVG(quantity)   AS quantity
      FROM
        payment_products
      WHERE    
        month BETWEEN '2023-01-01' AND '2023-10-31' --I will get avg number of product_ids which were ordered in months before the main season (January - October 2023)
      GROUP BY
        product_id
),
products_2023_part2 AS (
    SELECT
        product_id
        ,AVG(quantity)   AS quantity
      FROM
        payment_products
      WHERE    
        month BETWEEN '2023-11-01' AND '2023-12-31' --I will get avg number of product_ids which were ordered in the main season (November - December 2023)
      GROUP BY
        product_id
)

SELECT
    product_id
    ,ROUND(100*(sea.quantity/ord.quantity)-1),2)  AS percent_difference --I will get the percentage difference
  FROM
    products_2023_part1 AS ord
  LEFT JOIN  
    products_2023_part2 AS sea
  ON
    ord.product_id = sea.product_id
  GROUP BY 
    product_id
  ORDER BY
    percent_difference DESC -- I want to see the highest results as first.
  LIMIT 5 -- I want to see only the fist 5 results (poroduct_ids)
