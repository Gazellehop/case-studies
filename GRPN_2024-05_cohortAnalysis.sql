--Cohort Analysis: Group customers based on their registration timestamp, calculate the percentage of customers who have made at least one transaction in the first month after registration, exclude customers with zero transactions
--Assumption: anyone can open an account (even a registered customer may not have any transaction)
--Snowflake script (beware! this script has not been validated yet, it is only a draft and you may find errors there):
WITH
customers_group AS ( --I want to get a clear source with customer's data
    SELECT
        customer_id
        ,registration_timestamp --date of the first registration
        ,TO_DATE(registration_timestamp)                   AS date_from --I want to use it later for deffinition whether customer has a transaction in the first month after his registration
        ,DATEADD(day, 30, TO_DATE(registration_timestamp)  AS date_to --I want to use it later for deffinition whether customer has a transaction in the first month after his registration
      FROM
        Customers    
),
payment AS ( --I want to get a clear source with transaction's data
    SELECT
        sale_id
        ,to_date(timestamp) AS order_date --will be used for deffinition whether customer has a transaction in the first month after his registration
      FROM
        Payment 
    GROUP 1,2 --Removing of duplicate sale_ids because one sale_id can contain multiple product_ids => in this case we only need sale_id and timestamp
),
customers_orders AS ( --preparation for final calculation
    SELECT
        customer_id
        ,CASE
          WHEN date_from >= order_date and date_to <= order_date then 1 --if the order_date is in the range, it means that customer made transaction in the first month after his registration 
          ELSE 0 --zero transactions in the first month after registration
        END AS firstmonth
      FROM  
        (SELECT
            cust.customer_id
            ,cust.registration_timestamp --just for check, whether date_from/to are calculated correctly
            ,cust.date_from
            ,cust.date_to
            ,pay.sale_id
            ,pay.order_date
        FROM
          customers_group AS cust
        LEFT JOIN
          payment AS pay
        ON cust.customer_id = pay_customer_id
        )
      WHERE
        sale_id IS NOT null --I will remove "customers" without transactions (possible bias - see row nr. 2)
      GROUP BY 
        customer_id, firstmonth --because there can be duplications of customer_ids thanks to more transactions
)

--one of two queries below can be active in the same time:    
--final query for percentage calculation of customers with 1+ transactions in the first month after registration    
SELECT
    ROUND(100 * COUNT(DISTINCT (CASE WHEN firstmonth = 1 THEN customer_id END))/COUNT(DISTINCT customer_id),2) AS percentage
  FROM
    customers_orders
--final query for excluding customers with zero transactions
SELECT
    customer_id
    ,firstmonth --just for validation
  FROM
    customers_orders
  WHERE
    firstmonth = 1
    
