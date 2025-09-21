/* Change-Over-Time: Analyze how a measure evolves over time
Help track trends and identify seasonality in your data
[Aggregate Measure] By [Date Dimension]
ex: total sales by year, average cost by month */

SELECT 
YEAR(order_date) as order_year, 
MONTH(order_date) as order_month,
SUM(sales_amount) as total_sales, 
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_quantity
FROM DataAnalytics.dbo.sales
WHERE order_date IS NOT NULL
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY YEAR(order_date), MONTH(order_date)

SELECT 
DATETRUNC(month, order_date) as order_date, -- one row for each month for each year
SUM(sales_amount) as total_sales, 
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_quantity
FROM DataAnalytics.dbo.sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
ORDER BY DATETRUNC(month, order_date)


SELECT 
FORMAT(order_date, 'yyyy-MMM') as order_date, -- Output is a string, sort not correctly
SUM(sales_amount) as total_sales, 
COUNT(DISTINCT customer_key) as total_customers,
SUM(quantity) as total_quantity
FROM DataAnalytics.dbo.sales
WHERE order_date IS NOT NULL
GROUP BY FORMAT(order_date, 'yyyy-MMM')
ORDER BY FORMAT(order_date, 'yyyy-MMM')

/* Cumulative Analysis: Aggregate the data progressively over time
Helps to undersstand whether our business is growing or declining
[Cumulative Measure] By [Date Dimension]
ex: running total sales by year, moving average of sales by month
Use window functions */

-- Calculate the total sales per month
-- and the running total of sales over time
SELECT
order_date,
total_sales,
avg_price,
SUM(total_sales) OVER (ORDER BY order_date) AS running_total_sales,
AVG(avg_price) OVER (ORDER BY order_date) AS moving_avg_price
-- window function
FROM
(
SELECT DATETRUNC(month, order_date) AS order_date, 
SUM(sales_amount) as total_sales,
AVG(price) as avg_price
FROM DataAnalytics.dbo.sales
WHERE order_date IS NOT NULL
GROUP BY DATETRUNC(month, order_date)
) t

/* Performance Analysis: Comparing the current value to a terget value
Helps measure success and compare performance
[Current Measure] - [Target Measure]
ex: current yeal sales - previous year sales, current sales - lowest sales 
Use window functions */

/* Task: Analyze the yearly performance of products by comaparing
each product's sales to both its average sales performance and
the previous year's sales */
WITH yearly_product_sales AS (
SELECT 
YEAR(s.order_date) as order_year,
p.product_name,
SUM(s.sales_amount) as current_sales
FROM DataAnalytics.dbo.sales s 
LEFT JOIN DataAnalytics.dbo.products p
ON s.product_key = p.product_key
WHERE s.order_date IS NOT NULL
GROUP BY YEAR(s.order_date), p.product_name
)

SELECT
order_year,
product_name,
current_sales,
AVG(current_sales) OVER (PARTITION BY product_name) avg_sales,
current_sales - AVG(current_sales) OVER (PARTITION BY product_name) AS diif_avg,
CASE WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) > 0 THEN 'Above Avg'
	 WHEN current_sales - AVG(current_sales) OVER (PARTITION BY product_name) < 0THEN 'Below Avg'
	 ELSE 'Avg'
END avg_change,
-- Year-over-year Analysis
LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS previous_sales,
current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) AS diff_previous,
CASE WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) > 0 THEN 'Increase'
	 WHEN current_sales - LAG(current_sales) OVER (PARTITION BY product_name ORDER BY order_year) < 0THEN 'Decrease'
	 ELSE 'No Change'
END avg_change
FROM yearly_product_sales
ORDER BY product_name, order_year
