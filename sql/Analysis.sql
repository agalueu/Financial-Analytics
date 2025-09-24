--1. Profit hotspot (TOP and BOTTOM KPIs on power BI)
WITH sales AS (
	SELECT  c.region, c.segment, 
			ROUND(SUM(od.sales), 2) AS total_sales, --total sales per region/segment
			ROUND(SUM(od.profit), 2) AS total_profit --total profit per region/segment
	FROM customers c
	JOIN orders o ON c.customer_id = o.customer_id --inner JOIN just because we want only customers that has an order
	JOIN order_details od ON o.order_id = od.order_id --only orders that has an order details
	GROUP BY c.region, c.segment
)

SELECT  region AS "Region",
		segment AS "Segment",
		total_sales AS "Total Sales",
		total_profit AS "Total Profit",
		ROUND(total_profit/total_sales * 100, 2) AS "Profit Margin"
FROM sales
ORDER BY "Profit Margin" DESC, region, segment;

--2. total sales per product
SELECT  p.product_name,
		EXTRACT(YEAR FROM (o.order_date)) AS year,
		SUM(sales) AS total_sales
FROM products p
JOIN order_details oi ON p.product_id = oi.product_id
JOIN orders o ON oi.order_id = o.order_id
GROUP BY p.product_name, EXTRACT(YEAR FROM (o.order_date))
ORDER BY total_sales DESC
/*the ORDER BY clause will show in the table the result we want, for example, if we want the product that performance more sales per year, we should
do ORDER BY year, total_sales DESC, if we want the product that overall the years performance the most selling just do ORDER BY total_sales DESC*/

--3. Sales trends by Category
WITH sales AS (
	SELECT p.category, EXTRACT (YEAR FROM (o.order_date)) AS year, ROUND(SUM(od.sales), 2) AS total_sales
	FROM products p
	JOIN order_details od ON p.product_id = od.product_id
	JOIN orders o ON od.order_id = o.order_id
	GROUP BY p.category, EXTRACT (YEAR FROM (o.order_date))
),

preview AS (
	SELECT *, LAG (total_sales) OVER (PARTITION BY category ORDER BY year) AS previews_value
	FROM sales
)

SELECT  category AS "Category",
		year AS "Year",
		total_sales AS "Total Sales",
		ROUND((total_sales - previews_value)/NULLIF(previews_value, 0) * 100, 2) AS "YoY Growth"
FROM preview;

--4. Compute YoY growth for both sales and profit. AND show rank changes from the previous year for each category
--This is showing on power BI in rank changes over years and year over year Growth
WITH sales AS (
	SELECT  p.category,
		c.region,
		EXTRACT (YEAR FROM(o.order_date)) AS year,
		ROUND(SUM(od.sales), 2) AS total_sales,
		ROUND(SUM(od.profit), 2) AS total_profit
	FROM customers c
	JOIN orders o ON c.customer_id = o.customer_id
	JOIN order_details od ON o.order_id = od.order_id
	JOIN products p ON od.product_id = p.product_id
	GROUP BY p.category, c.region, EXTRACT (YEAR FROM(o.order_date))
),

ranked AS (
	SELECT  *,
		RANK () OVER (PARTITION BY region, year ORDER BY total_sales DESC) AS rank_by_sales,
		RANK () OVER (PARTITION BY region, year ORDER BY total_profit DESC) AS rank_by_profit,
		SUM(total_sales) OVER (PARTITION BY region, category ORDER BY year) AS cumulative_sales,
		COALESCE(LAG (total_sales) OVER (PARTITION BY region, category ORDER BY year), 0) AS previews_sale,
		COALESCE(LAG (total_profit) OVER (PARTITION BY region, category ORDER BY year), 0) AS previews_profit
	FROM sales
),

final_results AS (
	SELECT  *,
		COALESCE(ROUND((total_sales - previews_sale)/NULLIF(previews_sale, 0) * 100, 2), 0) AS YoY_sales,
		COALESCE(ROUND((total_profit - previews_profit)/NULLIF(previews_profit, 0) * 100, 2), 0) AS YoY_profit,
		LAG (rank_by_sales) OVER (PARTITION BY region, category ORDER BY year) AS previews_rank_sale,
		LAG (rank_by_profit) OVER (PARTITION BY region, category ORDER BY year) AS previews_rank_profit
	FROM ranked
)

SELECT  category AS "Category",
		region AS "Region",
		year AS "Year",
		total_sales AS "Total Sales",
		total_profit AS "Total Profit",
		cumulative_sales AS "Cumulative Sales",
		yoy_sales AS "Year over Year Growth by sales",
		yoy_profit AS "Year over Year Growth by profit",
		--previews_rank_sale,
		rank_by_sales AS "Rank by Sales",
		--previews_rank_profit,
		rank_by_profit AS "Rank by Profit",
		-1 * (rank_by_sales - previews_rank_sale) AS "Rank changes by Sales",
		-1 * (rank_by_profit - previews_rank_profit) AS "Rank changes by Profit"
FROM final_results
ORDER BY category, region, year;

--5. Highlight the top-selling category each year.
WITH total AS (
	SELECT /*p.product_name,*/ p.category, EXTRACT(YEAR FROM (o.order_date)) AS year, SUM(od.sales) AS total_sales, SUM(od.profit) AS total_profit
	FROM products p
	JOIN order_details od ON p.product_id = od.product_id
	JOIN orders o ON od.order_id = o.order_id
	GROUP BY /*p.product_name,*/ p.category, EXTRACT(YEAR FROM (o.order_date))
),

ranked As (
	SELECT  *,
			DENSE_RANK () OVER (PARTITION BY year ORDER BY total_sales DESC) AS rank
	FROM total
)

SELECT  category AS "Category",
		year AS "Year",
		total_sales AS "Total Sales",
		total_profit AS "Total Profit",
		rank AS "Rank"
FROM ranked
WHERE rank = 1;

--Key business question
--6. Which product categories and subcategories drive the most profit?
WITH sales AS (
	SELECT  p.category,
		c.region,
		EXTRACT (YEAR FROM(o.order_date)) AS year,
		ROUND(SUM(od.sales), 2) AS total_sales,
		ROUND(SUM(od.profit), 2) AS total_profit
	FROM customers c
	JOIN orders o ON c.customer_id = o.customer_id
	JOIN order_details od ON o.order_id = od.order_id
	JOIN products p ON od.product_id = p.product_id
	GROUP BY p.category, c.region, EXTRACT (YEAR FROM(o.order_date))
)

SELECT  category AS "Category",
		region AS "Region",
		year AS "Year",
		total_sales AS "Total Sales",
		total_profit AS "Total Profit",
		RANK () OVER (PARTITION BY region, year ORDER BY total_sales DESC) AS "Rank by Sales",
		RANK () OVER (PARTITION BY region, year ORDER BY total_profit DESC) AS "Rank by Profit"
FROM sales;

--7. What customer segments and region combined are most valuable?
WITH ranked AS (
	SELECT  c.region, c.segment,
			ROUND(SUM(od.sales), 2) AS total_sales,
			ROUND(SUM(od.profit), 2) AS total_profit, 
			ROUND(  SUM(od.profit)/SUM(od.sales) * 100, 2) AS profit_margin_pct,
			DENSE_RANK () OVER (PARTITION BY c.region ORDER BY SUM(od.sales) DESC) AS rank_by_sales,
			DENSE_RANK () OVER (PARTITION BY c.region ORDER BY SUM(od.profit) DESC) AS rank_by_profit,
			DENSE_RANK () OVER (PARTITION BY c.region ORDER BY (SUM(od.profit)/SUM(od.sales)) DESC) AS rank_by_margin
	FROM customers c
	JOIN orders o ON c.customer_id = o.customer_id
	JOIN order_details od ON o.order_id = od.order_id
	GROUP BY c.region, c.segment
)

SELECT  region AS "Region",
		segment AS "Segment",
		total_sales AS "Total Sales",
		total_profit AS "Total Profit",
		rank_by_sales AS "Rank by Sales",
		rank_by_profit AS "Rank by Profit",
		rank_by_margin AS "Margin Rank",
		(rank_by_sales + rank_by_profit + rank_by_margin) / 3 AS "Overall Performer"
FROM ranked

ORDER BY region, "Overall Performer";
