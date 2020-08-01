"""
Troubleshooting CREATE TABLE statements
"""

-- Query 1: Too much of a good thing

#standardSQL

# copy one day of ecommerce data to explore
CREATE OR REPLACE TABLE ecommerce.all_sessions_raw_20170801
 OPTIONS(
   description="Raw data from analyst team into our dataset for 08/01/2017"
 ) AS
 SELECT * FROM `data-to-insights.ecommerce.all_sessions_raw`
 WHERE date = '20170801' #56,989 records
;

# copy another day of ecommerce data to explore
CREATE OR REPLACE TABLE ecommerce.all_sessions_raw_20170731
OPTIONS(
 description="Raw data from analyst team into our dataset for 07/31/2017"
) AS
SELECT * FROM `data-to-insights.ecommerce.all_sessions_raw`
WHERE date = '20170731' # 59,681 records
;


--Query 2: Columns, Columns, Columns

#standardSQL

# copy one day of ecommerce data to explore
CREATE OR REPLACE TABLE ecommerce.all_sessions_raw_20170801
 OPTIONS(
   description="Raw data from analyst team into our dataset for 08/01/2017"
 ) AS
 SELECT fullVisitorId, * FROM `data-to-insights.ecommerce.all_sessions_raw`
 WHERE date = '20170801'  #56,989 records
;


--Query 3: Columns revisited

#standardSQL

# copy one day of ecommerce data to explore
CREATE OR REPLACE TABLE ecommerce.all_sessions_raw_20170801
#schema
(
  fullVisitorId STRING OPTIONS(description="Unique visitor ID"),
  channelGrouping STRING OPTIONS(description="Channel e.g. Direct, Organic, Referral...")
)
 OPTIONS(
   description="Raw data from analyst team into our dataset for 08/01/2017"
 ) AS
 SELECT * FROM `data-to-insights.ecommerce.all_sessions_raw`
 WHERE date = '20170801'  #56,989 records
;


--Query 4: It's Valid! Or is it?

#standardSQL

# copy one day of ecommerce data to explore
CREATE OR REPLACE TABLE ecommerce.all_sessions_raw_20170801
#schema
(
  fullVisitorId STRING OPTIONS(description="Unique visitor ID"),
  channelGrouping STRING OPTIONS(description="Channel e.g. Direct, Organic, Referral...")
)
 OPTIONS(
   description="Raw data from analyst team into our dataset for 08/01/2017"
 ) AS
 SELECT fullVisitorId, city FROM `data-to-insights.ecommerce.all_sessions_raw`
 WHERE date = '20170801'  #56,989 records
;


--Query 5: The gatekeeper

#standardSQL

# copy one day of ecommerce data to explore
CREATE OR REPLACE TABLE ecommerce.all_sessions_raw_20170801
#schema
(
  fullVisitorId STRING NOT NULL OPTIONS(description="Unique visitor ID"),
  channelGrouping STRING NOT NULL OPTIONS(description="Channel e.g. Direct, Organic, Referral..."),
  totalTransactionRevenue INT64 NOT NULL OPTIONS(description="Revenue * 10^6 for the transaction")
)
 OPTIONS(
   description="Raw data from analyst team into our dataset for 08/01/2017"
 ) AS
 SELECT fullVisitorId, channelGrouping, totalTransactionRevenue FROM `data-to-insights.ecommerce.all_sessions_raw`
 WHERE date = '20170801'  #56,989 records
;


--Query 6: Working as intended

#standardSQL

# copy one day of ecommerce data to explore
CREATE OR REPLACE TABLE ecommerce.all_sessions_raw_20170801
#schema
(
  fullVisitorId STRING NOT NULL OPTIONS(description="Unique visitor ID"),
  channelGrouping STRING NOT NULL OPTIONS(description="Channel e.g. Direct, Organic, Referral..."),
  totalTransactionRevenue INT64 OPTIONS(description="Revenue * 10^6 for the transaction")
)
 OPTIONS(
   description="Raw data from analyst team into our dataset for 08/01/2017"
 ) AS
 SELECT fullVisitorId, channelGrouping, totalTransactionRevenue FROM `data-to-insights.ecommerce.all_sessions_raw`
 WHERE date = '20170801'  #56,989 records
;


"""
Query 7: Your turn to practice
Goal: In the Query Editor, create a new permanent table that stores all the transactions with
 revenue for August 1st, 2017.

Use the below rules as a guide:

Create a new table in your ecommerce dataset titled revenue_transactions_20170801.
 Replace the table if it already exists.

Source your raw data from the data-to-insights.ecommerce.all_sessions_raw table.

Divide the revenue field by 1,000,000 and store it as a FLOAT64 instead of an INTEGER.

Only include transactions with revenue in your final table (hint: use a WHERE clause).

Only include transactions on 20170801.

Include these fields:

fullVisitorId as a REQUIRED string field.

visitId as a REQUIRED string field (hint: you will need to type convert).

channelGrouping as a REQUIRED string field.

totalTransactionRevenue as a FLOAT64 field.

Add short descriptions for the above four fields by referring to the schema.

Be sure to deduplicate records that have the same fullVisitorId and visitId (Hint: use DISTINCT).

"""


#standardSQL

# copy one day of ecommerce data to explore
CREATE OR REPLACE TABLE ecommerce.revenue_transactions_20170801
#schema
(
  fullVisitorId STRING NOT NULL OPTIONS(description="Unique visitor ID"),
  visitId STRING NOT NULL OPTIONS(description="ID of the session, not unique across all users"),
  channelGrouping STRING NOT NULL OPTIONS(description="Channel e.g. Direct, Organic, Referral..."),
  totalTransactionRevenue FLOAT64 NOT NULL OPTIONS(description="Revenue for the transaction")
)
 OPTIONS(
   description="Revenue transactions for 08/01/2017"
 ) AS
 SELECT DISTINCT
  fullVisitorId,
  CAST(visitId AS STRING) AS visitId,
  channelGrouping,
  totalTransactionRevenue / 1000000 AS totalTransactionRevenue
 FROM `data-to-insights.ecommerce.all_sessions_raw`
 WHERE date = '20170801'
      AND totalTransactionRevenue IS NOT NULL #XX transactions
;



"""
Creating views
"""

--Query the latest 100 transactions


#standardSQL
CREATE OR REPLACE VIEW ecommerce.vw_latest_transactions
AS
SELECT DISTINCT
  date,
  fullVisitorId,
  CAST(visitId AS STRING) AS visitId,
  channelGrouping,
  totalTransactionRevenue / 1000000 AS totalTransactionRevenue
 FROM `data-to-insights.ecommerce.all_sessions_raw`
 WHERE totalTransactionRevenue IS NOT NULL
 ORDER BY date DESC # latest transactions
 LIMIT 100
;


#standardSQL
# top 50 latest transactions
CREATE VIEW ecommerce.vw_latest_transactions # CREATE
OPTIONS(
  description="latest 50 ecommerce transactions",
  labels=[('report_type','operational')]
)
AS
SELECT DISTINCT
  date,
  fullVisitorId,
  CAST(visitId AS STRING) AS visitId,
  channelGrouping,
  totalTransactionRevenue / 1000000 AS totalTransactionRevenue
 FROM `data-to-insights.ecommerce.all_sessions_raw`
 WHERE totalTransactionRevenue IS NOT NULL
 ORDER BY date DESC # latest transactions
 LIMIT 50
;


"""
View Creation: Your turn to practice
Scenario: Your anti-fraud team has asked you to create a report that lists the 10 most 
recent transactions that have an order amount of 1,000 or more for them to review manually.

Task: Create a new view that returns all the most recent 10 transactions with revenue greater 
than 1,000 on or after January 1st, 2017.

Use these rules as a guide:

Create a new view in your ecommerce dataset titled "vw_large_transactions". Replace the view if 
    it already exists.

Give the view a description "large transactions for review".

Give the view a label [("org_unit", "loss_prevention")].

Source your raw data from the data-to-insights.ecommerce.all_sessions_raw table.

Divide the revenue field by 1,000,000.

Only include transactions with revenue greater than or equal to 1,000

Only include transactions on or after 20170101 ordered by most recent first.

Only include currencyCode = 'USD'.

Return these fields:

date
fullVisitorId
visitId
channelGrouping
totalTransactionRevenue AS revenue
currencyCode
v2ProductName
Be sure to deduplicate records (hint: use DISTINCT).
"""


#standardSQL
CREATE OR REPLACE VIEW ecommerce.vw_large_transactions
OPTIONS(
  description="large transactions for review",
  labels=[('org_unit','loss_prevention')]
)
AS
SELECT DISTINCT
  date,
  fullVisitorId,
  visitId,
  channelGrouping,
  totalTransactionRevenue / 1000000 AS revenue,
  currencyCode
  #v2ProductName
 FROM `data-to-insights.ecommerce.all_sessions_raw`
 WHERE
  (totalTransactionRevenue / 1000000) > 1000
  AND currencyCode = 'USD'
 ORDER BY date DESC # latest transactions
 LIMIT 10
;


"""
Scenario: Your anti-fraud department is grateful for the query and they are monitoring it daily for
     suspicious orders. They have now asked you to include a sample of the products that are part of
         each order along with the results you returned previously.

Using the BigQuery string aggregation function STRING_AGG and the v2ProductName field, modify 
    your previous query to return 10 of the product names in each order, listed alphabetically.
"""


#standardSQL
CREATE OR REPLACE VIEW ecommerce.vw_large_transactions
OPTIONS(
  description="large transactions for review",
  labels=[('org_unit','loss_prevention')]
)
AS
SELECT DISTINCT
  date,
  fullVisitorId,
  visitId,
  channelGrouping,
  totalTransactionRevenue / 1000000 AS totalTransactionRevenue,
  currencyCode,
  STRING_AGG(DISTINCT v2ProductName ORDER BY v2ProductName LIMIT 10) AS products_ordered
 FROM `data-to-insights.ecommerce.all_sessions_raw`
 WHERE
  (totalTransactionRevenue / 1000000) > 1000
  AND currencyCode = 'USD'

 GROUP BY 1,2,3,4,5,6
  ORDER BY date DESC # latest transactions

  LIMIT 10


  --

  #standardSQL
CREATE OR REPLACE VIEW ecommerce.vw_large_transactions
OPTIONS(
  description="large transactions for review",
  labels=[('org_unit','loss_prevention')],
  expiration_timestamp=TIMESTAMP_ADD(CURRENT_TIMESTAMP(), INTERVAL 90 DAY)
)
AS
#standardSQL
SELECT DISTINCT
  SESSION_USER() AS viewer_ldap,
  REGEXP_EXTRACT(SESSION_USER(), r'@(.+)') AS domain,
  date,
  fullVisitorId,
  visitId,
  channelGrouping,
  totalTransactionRevenue / 1000000 AS totalTransactionRevenue,
  currencyCode,
  STRING_AGG(DISTINCT v2ProductName ORDER BY v2ProductName LIMIT 10) AS products_ordered
 FROM `data-to-insights.ecommerce.all_sessions_raw`
 WHERE
  (totalTransactionRevenue / 1000000) > 1000
  AND currencyCode = 'USD'
  AND REGEXP_EXTRACT(SESSION_USER(), r'@(.+)') IN ('qwiklabs.net')

 GROUP BY 1,2,3,4,5,6,7,8
  ORDER BY date DESC # latest transactions

  LIMIT 10;