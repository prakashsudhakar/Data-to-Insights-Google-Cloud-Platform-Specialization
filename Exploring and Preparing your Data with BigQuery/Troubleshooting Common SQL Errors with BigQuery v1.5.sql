"""
Troubleshoot queries that contain query validator, alias, and comma errors
"""

#standardSQL
SELECT  FROM `data-to-inghts.ecommerce.rev_transactions` LIMIT 1000

"""
What about this updated query?

"""

#standardSQL
SELECT * FROM [data-to-insights:ecommerce.rev_transactions] LIMIT 1000

"""
What about this query that uses Standard SQL?

"""

#standardSQL
SELECT FROM `data-to-insights.ecommerce.rev_transactions`


"""
What about now? This query has a column.
"""


#standardSQL
SELECT
fullVisitorId
FROM `data-to-insights.ecommerce.rev_transactions`


"""
What about this? An aggregation function, COUNT(), was added.

"""

#standardSQL
SELECT
COUNT(fullVisitorId) AS visitor_count
, hits_page_pageTitle
FROM `data-to-insights.ecommerce.rev_transactions`


"""
In this next query, GROUP BY and DISTINCT statements were added.
"""


#standardSQL
SELECT
COUNT(DISTINCT fullVisitorId) AS visitor_count
, hits_page_pageTitle
FROM `data-to-insights.ecommerce.rev_transactions`
GROUP BY hits_page_pageTitle


"""

List the cities with the most transactions with your ecommerce site
"""


#standardSQL
SELECT
geoNetwork_city,
SUM(totals_transactions) AS totals_transactions,
COUNT( DISTINCT fullVisitorId) AS distinct_visitors
FROM
`data-to-insights.ecommerce.rev_transactions`
GROUP BY geoNetwork_city


"""
Update your previous query to order the top cities first.

"""
#standardSQL
SELECT
geoNetwork_city,
SUM(totals_transactions) AS totals_transactions,
COUNT( DISTINCT fullVisitorId) AS distinct_visitors
FROM
`data-to-insights.ecommerce.rev_transactions`
GROUP BY geoNetwork_city
ORDER BY distinct_visitors DESC

"""
Update your query and create a new calculated field to return 
    the average number of products per order by city.

"""

#standardSQL
SELECT
geoNetwork_city,
SUM(totals_transactions) AS total_products_ordered,
COUNT( DISTINCT fullVisitorId) AS distinct_visitors,
SUM(totals_transactions) / COUNT( DISTINCT fullVisitorId) AS avg_products_ordered
FROM
`data-to-insights.ecommerce.rev_transactions`
GROUP BY geoNetwork_city
ORDER BY avg_products_ordered DESC


"""
Filter your aggregated results to only return cities with more than 20 avg_products_ordered.

"""

#standardSQL
SELECT
geoNetwork_city,
SUM(totals_transactions) AS total_products_ordered,
COUNT( DISTINCT fullVisitorId) AS distinct_visitors,
SUM(totals_transactions) / COUNT( DISTINCT fullVisitorId) AS avg_products_ordered
FROM
`data-to-insights.ecommerce.rev_transactions`
GROUP BY geoNetwork_city
HAVING avg_products_ordered > 20
ORDER BY avg_products_ordered DESC


"""
Find the top selling products by filtering with NULL values
Update the query to only count distinct products in each product category.


"""

#standardSQL
SELECT
COUNT(DISTINCT hits_product_v2ProductName) as number_of_products,
hits_product_v2ProductCategory
FROM `data-to-insights.ecommerce.rev_transactions`
WHERE hits_product_v2ProductName IS NOT NULL
GROUP BY hits_product_v2ProductCategory
ORDER BY number_of_products DESC
LIMIT 5