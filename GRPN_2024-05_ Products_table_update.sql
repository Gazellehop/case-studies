--Broken column is_deleted in the table Products
--The target is to recreate the column in query to get the right results
--assumptions:
-- - product_id is primal key
-- - in order to have historical changes in this table this column exists to see log of updates
-- - the product_id is same for all updated rows
-- - to select only viable product you would have to select only is_deleted = FALSE
--Note: in this table one column is missing (Active_product True/False). 
--Snowflake script (beware! this script has not been validated yet, it is only a draft and you may find errors there):
SELECT
    product_id
    ,name
    ,Category
    ,price_per_unit
    ,Updated_at
    ,CASE 
      WHEN rn = 1 then "FALSE" --the latest records mean active product
      ELSE "TRUE" --the older records mean an inactive product
    END AS is_deleted
  FROM
    (SELECT 
        product_id
        ,name
        ,Category
        ,price_per_unit
        ,Updated_at
        ,ROW_NUMBER() OVER (PARTITION BY product_id ORDER BY updated_at desc) as rn --thanks to this I will get information about the last records for each product. Row number 1 means in this case the last change.
      FROM
        Products)
