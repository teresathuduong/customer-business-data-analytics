/* Data Segmentation: Group the data based on a specific range 
(create new categories or segments base on a measure and then aggregating another measure based of new segments)
Helps understand the correlation between two measures
[Measure] by [Measure]
ex: total products by sales range, total customers by age 8
Use CASE WHEN Statement */

-- Task: Segment products into cost ranges and count how many products fall into each segment
WITH product_segments AS (
SELECT 
product_key,
product_name,
cost,
CASE WHEN cost < 100 THEN 'Below 100'
	 WHEN cost BETWEEN 100 AND 500 THEN '100-500'
	 WHEN cost BETWEEN 500 AND 1000 THEN '500-1000'
	 ELSE 'Above 1000'
END cost_range
FROM DataAnalytics.dbo.products p
)
SELECT 
cost_range,
COUNT(product_key) AS total_products
FROM product_segments
GROUP BY cost_range
ORDER BY total_products DESC

/* Group customers into three segments based on their spending behaviour:
- VIP: Customers with at least 12 months of history and spending more than $5000
- Regular: Customers with at least 12 months of history but spending $5000 or less
- New: Customers with a lifespan less than 12 months
And find the total number of customers by each group 
*/
WITH customer_spending AS(
SELECT
c.customer_key,
SUM(s.sales_amount) AS total_spending,

-- lifespan = last_oreder - first_order
MIN(order_date) AS first_order,
MAX(order_date) AS last_order,
DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
FROM DataAnalytics.dbo.sales s
LEFT JOIN DataAnalytics.dbo.customers c
ON s.customer_key = c.customer_key
GROUP BY c.customer_key
)

SELECT 
customer_segments,
COUNT(customer_key) AS total_customers
FROM (
	SELECT
	customer_key,
	total_spending,
	lifespan,
	CASE WHEN lifespan >= 12 AND total_spending > 5000 THEN 'Vip'
		 WHEN lifespan >= 12 AND total_spending <= 5000 THEN 'Regular'
		 ELSE 'New'
	END customer_segments
	FROM customer_spending ) t
GROUP BY customer_segments
ORDER BY total_customers DESC