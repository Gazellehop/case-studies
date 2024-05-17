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
    GROUP 1,2 --Removing of duplicate sale_ids because one sale_id can contain multiple product_ids => in this case we only need sale_id and timestamp
),
