--1. count the number of distinct orders and distinct customers.
SELECT 
  COUNT(DISTINCT (order_id)),
  COUNT(DISTINCT(customer_id))
FROM `business-intelligence-472818.bigquery_dataset_ecommerce.orders_bq`;

--2. Give in percentage terms the proportion of orders associated with each status
SELECT 
  order_status,
  COUNT(*) *100 / SUM(COUNT(*)) OVER() AS percentage_of_total 
FROM `business-intelligence-472818.bigquery_dataset_ecommerce.orders_bq`
GROUP BY order_status;

--3. Write a query to count the number of orders per year and per month.
SELECT 
  EXTRACT(year FROM order_purchase_timestamp) AS year,
  EXTRACT(month FROM order_purchase_timestamp) AS month,
  COUNT(*) AS order_numbers
FROM `business-intelligence-472818.bigquery_dataset_ecommerce.orders_bq`
GROUP BY year, month;

--4. Write a query to count the number of orders per year and per month and this only for the status created and shipped.
SELECT 
  EXTRACT(year FROM order_purchase_timestamp) AS year,
  EXTRACT(month FROM order_purchase_timestamp) AS month,
  COUNT(*) AS order_numbers
FROM `business-intelligence-472818.bigquery_dataset_ecommerce.orders_bq`
WHERE order_status IN ("created",  "shipped")
GROUP BY year, month;

--5. Write a query to display the order ID, customer ID, and customer city in the same table.
SELECT 
  o.order_id,
  o.customer_id,
  c.customer_city
FROM `business-intelligence-472818.bigquery_dataset_ecommerce.orders_bq` o
JOIN `business-intelligence-472818.bigquery_dataset_ecommerce.ext_customers_table`  c
ON c.customer_id = o.customer_id;


--6. Write the query to display the city with most orders.
SELECT 
  c.customer_city,
  COUNT(o.order_id) as numbers_of_orders
FROM `business-intelligence-472818.bigquery_dataset_ecommerce.orders_bq` o
JOIN `business-intelligence-472818.bigquery_dataset_ecommerce.ext_customers_table` c
ON c.customer_id = o.customer_id
GROUP BY c.customer_city
ORDER BY numbers_of_orders DESC;


--7. Write the query to identify the most present customer in the customer table.
-- The most active customer in the customer table is identified with its customer_unique_id and this does not mean to find the customers who order the most.
SELECT
  customer_unique_id,
  COUNT(*) AS most_present_customer
FROM `business-intelligence-472818.bigquery_dataset_ecommerce.ext_customers`
GROUP BY 1
ORDER BY 2 DESC;

--8. Observe the history of the most faithful customer in terms of date.
--The query below is used to obtain, for each order, the customer ID, the date and the number of orders associated with a customer.
SELECT
  c.customer_unique_id,
  o.order_purchase_timestamp,
  ROW_NUMBER() OVER(PARTITION BY c.customer_unique_id ORDER BY o.order_purchase_timestamp) AS customer_order_number
FROM `business-intelligence-472818.bigquery_dataset_ecommerce.orders_bq` o
JOIN `business-intelligence-472818.bigquery_dataset_ecommerce.ext_customers` c
ON c.customer_id = o.customer_id
ORDER BY 2;


--9. Based of above query, display the customer's history 8d50f5eadf50201ccdcedfb9e2ac8455 by adding the order status, the order approval date and the delivery date (order_delivered_customer_date column).
-- Using window function, it answers:
--When did the customer place their first order?
--How long between order 1 and order 2?
--How many days between orders?
--What is the customer’s order frequency?
--What is the timeline of their loyalty?
SELECT
  c.customer_unique_id,
  o.order_purchase_timestamp,
  ROW_NUMBER() OVER(PARTITION BY c.customer_unique_id ORDER BY o.order_purchase_timestamp) AS customer_order_number,
  o.order_status,
  o.order_approved_at,
  o.order_delivered_customer_date
FROM `business-intelligence-472818.bigquery_dataset_ecommerce.orders_bq` o
JOIN `business-intelligence-472818.bigquery_dataset_ecommerce.ext_customers` c
ON c.customer_id = o.customer_id
WHERE c.customer_unique_id ='8d50f5eadf50201ccdcedfb9e2ac8455'
ORDER BY 2;

--10. Based on above query, display the top 5 most loyal customers.

WITH customer_history AS (
SELECT
  c.customer_unique_id,
  o.order_purchase_timestamp,
  ROW_NUMBER() OVER(PARTITION BY c.customer_unique_id ORDER BY o.order_purchase_timestamp) AS customer_order_number
FROM `business-intelligence-472818.bigquery_dataset_ecommerce.orders_bq` o
JOIN `business-intelligence-472818.bigquery_dataset_ecommerce.ext_customers` c
ON c.customer_id = o.customer_id
)
SELECT 
  customer_unique_id,
  MAX(customer_order_number) AS total_orders
FROM customer_history
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5;

-- Using subquery
SELECT customer_unique_id, MAX(customer_order_number) AS max_interaction FROM
(
SELECT
   customer_unique_id,
   o.order_purchase_timestamp,
   row_number() OVER(PARTITION BY customer_unique_id ORDER BY o.order_purchase_timestamp) AS customer_order_number
FROM `business-intelligence-472818.bigquery_dataset_ecommerce.orders_bq` o
JOIN `business-intelligence-472818.bigquery_dataset_ecommerce.ext_customers` c ON c.customer_id = o.customer_id
ORDER BY 1, 2
) AS customer_history
GROUP BY 1
HAVING max_interaction > 1
ORDER BY max_interaction DESC


















