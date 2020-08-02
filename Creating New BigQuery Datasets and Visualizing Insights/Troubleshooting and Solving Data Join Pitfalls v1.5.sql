"""
Identify a key field in your ecommerce dataset
"""

#standardSQL
# how many products are on the website?
SELECT DISTINCT
productSKU,
v2ProductName
FROM `data-to-insights.ecommerce.all_sessions_raw`


"""
 determine if some product names have more than one SKU
"""


#standardSQL
# how can we find the products with more than 1 sku?
SELECT
DISTINCT
COUNT(DISTINCT productSKU) AS SKU_count,
STRING_AGG(DISTINCT productSKU LIMIT 5) AS SKU,
v2ProductName
FROM `data-to-insights.ecommerce.all_sessions_raw`
WHERE productSKU IS NOT NULL
GROUP BY v2ProductName
HAVING SKU_count > 1
ORDER BY SKU_count DESC
# product name is not unique (expected for variants)


"""
Do some product names have more than one SKU? Look at the query results to confirm.
"""


#standardSQL

SELECT
DISTINCT
COUNT(DISTINCT v2ProductName) AS product_count,
STRING_AGG(DISTINCT v2ProductName LIMIT 5) AS product_name,
productSKU
FROM `data-to-insights.ecommerce.all_sessions_raw`
WHERE v2ProductName IS NOT NULL
GROUP BY productSKU
HAVING product_count > 1
ORDER BY product_count DESC
# SKU is not unique (indicates data quality issues)



"""
Write a query to identify all the product names for the SKU 'GGOEGPJC019099'.
"""


#standardSQL
# multiple records for this SKU
SELECT DISTINCT
v2ProductName,
productSKU
FROM `data-to-insights.ecommerce.all_sessions_raw`

WHERE productSKU = 'GGOEGPJC019099'


"""
Joining website data against your product inventory list

"""

#standardSQL
# join in another table
# products (has inventory)
SELECT * FROM `data-to-insights.ecommerce.products`
WHERE SKU = 'GGOEGPJC019099'

"""
Join pitfall: Unintentional many-to-one SKU relationship
"""


#standardSQL
SELECT
  productSKU,
  SUM(stockLevel) AS total_inventory

FROM (

  SELECT DISTINCT
  website.v2ProductName,
  website.productSKU,
  inventory.stockLevel
  FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
  JOIN `data-to-insights.ecommerce.products` AS inventory
  ON website.productSKU = inventory.SKU
  WHERE productSKU = 'GGOEGPJC019099'
)

GROUP BY productSKU


"""
Write a query to return the count of distinct productSKU from 
    data-to-insights.ecommerce.all_sessions_raw.
"""

#standardSQL
SELECT
COUNT(DISTINCT website.productSKU) AS distinct_sku_count
FROM `data-to-insights.ecommerce.all_sessions_raw` AS website


"""
Join pitfall: Losing data records after a join

"""
#standardSQL
# pull ID fields from both tables
SELECT DISTINCT
website.productSKU AS website_SKU,
inventory.SKU AS inventory_SKU
FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
JOIN `data-to-insights.ecommerce.products` AS inventory
ON website.productSKU = inventory.SKU
# IDs are present in both tables, how can we dig deeper?



#standardSQL
# the secret is in the JOIN type
# pull ID fields from both tables
SELECT DISTINCT
website.productSKU AS website_SKU,
inventory.SKU AS inventory_SKU
FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
LEFT JOIN `data-to-insights.ecommerce.products` AS inventory
ON website.productSKU = inventory.SKU


"""
How many SKUs are missing from your product inventory set?

Write a query to filter on NULL values from the inventory table.
"""


#standardSQL
# find product SKUs in website table but not in product inventory table
SELECT DISTINCT
website.productSKU AS website_SKU,
inventory.SKU AS inventory_SKU
FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
LEFT JOIN `data-to-insights.ecommerce.products` AS inventory
ON website.productSKU = inventory.SKU
WHERE inventory.SKU IS NULL


"""
Why might the product inventory dataset be missing SKUs?

Answer: Unfortunately, there is no easy answer. It is most likely a business-related question:

Some SKUs could be digital products that you don't store in inventory
Old products you sold in past website orders are no longer offered in current inventory
Legitimate missing data from inventory and should be tracked
Are there any products are in the product inventory dataset but missing from the website?
"""

#standardSQL
# what are these products?
# add more fields in the SELECT STATEMENT
SELECT DISTINCT
website.productSKU AS website_SKU,
inventory.*
FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
RIGHT JOIN `data-to-insights.ecommerce.products` AS inventory
ON website.productSKU = inventory.SKU
WHERE website.productSKU IS NULL


"""
What if you wanted one query that listed all products missing from either the website or inventory?
"""


#standardSQL
SELECT DISTINCT
website.productSKU AS website_SKU,
inventory.SKU AS inventory_SKU
FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
FULL JOIN `data-to-insights.ecommerce.products` AS inventory
ON website.productSKU = inventory.SKU
WHERE website.productSKU IS NULL OR inventory.SKU IS NULL


"""
Join pitfall: Unintentional Cross Join
"""


SELECT DISTINCT
productSKU,
v2ProductCategory,
discount
FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
CROSS JOIN ecommerce.site_wide_promotion
WHERE v2ProductCategory LIKE '%Clearance%'


"""
What happens when you apply the discount again across all 82 clearance products?

"""

#standardSQL
# now what happens:
SELECT DISTINCT
productSKU,
v2ProductCategory,
discount
FROM `data-to-insights.ecommerce.all_sessions_raw` AS website
CROSS JOIN ecommerce.site_wide_promotion
WHERE v2ProductCategory LIKE '%Clearance%'



"""
Deduplicating Rows

"""

#standardSQL
# recall the earlier query that showed multiple product_names for each SKU
SELECT
DISTINCT
COUNT(DISTINCT v2ProductName) AS product_count,
STRING_AGG(DISTINCT v2ProductName LIMIT 5) AS product_name,
productSKU
FROM `data-to-insights.ecommerce.all_sessions_raw`
WHERE v2ProductName IS NOT NULL
GROUP BY productSKU
HAVING product_count > 1
ORDER BY product_count DESC



"""
Since most of the product names are extremely similar 
    (and you want to map a single SKU to a single product),
         write a query to only choose one of the product_names.
"""
#standardSQL
# take the one name associated with a SKU
WITH product_query AS (
  SELECT
  DISTINCT
  v2ProductName,
  productSKU
  FROM `data-to-insights.ecommerce.all_sessions_raw`
  WHERE v2ProductName IS NOT NULL
)

SELECT k.* FROM (

  # aggregate the products into an array and
  # only take 1 result
  SELECT ARRAY_AGG(x LIMIT 1)[OFFSET(0)] k
  FROM product_query x
  GROUP BY productSKU # this is the field you want deduplicated
);