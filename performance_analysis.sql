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