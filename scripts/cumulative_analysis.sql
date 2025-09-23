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