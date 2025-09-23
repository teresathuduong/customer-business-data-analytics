/* Part-to-whole: Analyze how an individual part is performing compared to the overall
Allow us to understand which category has the greatest impact on the business
([Measure]/Total[Measure]) * 100 by [Dimension]
ex: (sales/total sale) * 100 by category */

-- Task: Which categories contribute the most to the overall sales?
WITH category_sales AS (
SELECT 
category,
SUM(sales_amount) as total_sales
FROM DataAnalytics.dbo.sales s
LEFT JOIN DataAnalytics.dbo.products p
On p.product_key = s.product_key
GROUP BY category
)
SELECT 
category,
total_sales,
SUM(total_sales) OVER () as overall_sales,
CONCAT(ROUND((CAST(total_sales AS FLOAT) / SUM(total_sales) OVER ()) * 100, 2), '%') AS percentage_of_total
FROM category_sales
ORDER BY total_sales DESC

-- category bikes is dominating, it is the overwhelming top performing category, making 96% of the sales of the business
-- other 2 categories are minor contributors to our business sales, which is dangerous sinn we are
-- overrelying on 1 category in your business, if this fails, the whole business is gonna fail