WITH
customers_group AS (
    SELECT
        customer_id
        ,registration_timestamp
        ,TO_DATE(registration_timestamp)                   AS date_from
        ,DATEADD(day, 30, TO_DATE(registration_timestamp)  AS date_to
      FROM
        Customers    
),
payment AS (
    SELECT
        sale_id
        ,to_date(timestamp) AS order_date
      FROM
        Payment 
    GROUP 1,2 --Removing of duplicate sale_ids because one sale_id can contain multiple product_ids => in this case we only need sale_id and timestamp
),
customers_orders AS (
    SELECT
        customer_id
        ,CASE
          WHEN date_from >= order_date and date_to <= order_date then 1
          ELSE 0
        END AS firstmonth
      FROM  
        (SELECT
            cust.customer_id
            ,cust.registration_timestamp
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
        sale_id IS NOT null --We need to remove customer_ids that have no purchase history
      GROUP BY 
        customer_id, firstmonth
),
    
SELECT
    ROUND(100 * COUNT(DISTINCT (CASE WHEN firstmonth = 1 THEN customer_id END))/COUNT(DISTINCT customer_id),2) AS percentage
  FROM
    customers_orders
