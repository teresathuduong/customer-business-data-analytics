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

