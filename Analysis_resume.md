In this section I´m going to talk about some results in the different queries that i did in the [Query Analysis](sql/Analysis.sql) file, what was the purpose, steps to do it and business insight for this analysis

# 1. Profit hotspot (TOP and BOTTOM KPIs on power BI)
### Query Purpose:
This query analyzes sales and profitability performance across different regions and customer segments.

### Steps:
- Aggregate sales and profit from the Orders and Order_Details tables, grouped by Region and Segment.
- Use a CTE to simplify logic and make the query more modular.
- Calculate Profit Margin as a percentage:

Profit Margin = Total Profit / Total Sales × 100

- Rank the results by highest margin to identify the most profitable regions/segments.

### Business Insight:
This query helps reveal which region + segment combinations are the most profitable. For example, management might use this to decide which segments to prioritize in marketing or where to adjust pricing/discount strategies.

Sample img: [Profit Hotspot](images/query_profit_hotspot.png)

# 2. Total sales per product
### Query Purpose
This query identifies the top-selling products by year, showing how sales performance evolves over time at the product level.

### Steps / Logic
- Join tables:
      * products → to get product names
      * order_details → to get sales amounts per product
      * orders → to bring in the order dates

- Extract year: Use EXTRACT(YEAR FROM o.order_date) to group sales by year.

- Aggregate: SUM(sales) → calculate total sales per product per year.

- Group & Order:
      * Group by product and year
      * Sort results by total_sales DESC to highlight best performers.

### Business Insight
This query reveals which products drive the most revenue each year.
Helps identify:
    - Consistently strong products (long-term bestsellers)
    - Seasonal or trend-driven products (peaks in certain years)
Useful for product strategy, inventory planning, and targeted promotions.

Sample img: [Total sales per product](images/query_total_sales_per_product.png)

# 3. Sales trends by Category
### Query Purpose
This query calculates year-over-year (YoY) sales growth by product category, showing how sales performance evolves over time.

### Steps / Logic
- CTE – sales:
    * Join products, order_details, and orders
    * Aggregate sales by category and year
    * Round totals for cleaner output

- CTE – preview:
Use the LAG() window function to get the previous year’s sales for each category (previews_value).

- Final Select:
Calculate YoY Growth % as:

  YoYGrowth = (this year sales - previous year sales) / previous year sales * 100

Use NULLIF(previews_value, 0) to avoid division by zero errors.

Present results by Category, Year, Sales, and YoY Growth.

### Business Insight
This query highlights how each product category is growing (or declining) year over year. Useful for:
    - Spotting high-growth categories worth investing in
    - Detecting categories in decline that may need strategy changes
    - Comparing year-over-year performance across categories

Sample img: [Sales trends](images/query_sales_trends_by_category.png)

# 4. Compute YoY growth for both sales and profit. AND show rank changes from the previous year for each category
### Query Purpose
This query evaluates category-level sales and profit performance across regions and years, including rankings, growth rates, and cumulative trends.

### Steps / Logic
- CTE – sales:
    * Join customers, orders, order_details, and products.
    * Aggregate sales and profit by category, region, and year.

- CTE – ranked:
    * Assign rankings within each region & year:
    * RANK() OVER (PARTITION BY region, year ORDER BY total_sales DESC) → sales rank
    * RANK() OVER (PARTITION BY region, year ORDER BY total_profit DESC) → profit rank
    * Compute cumulative sales per category over time.
    * Use LAG() to capture the previous year’s sales and profit for YoY comparison.

- CTE – final_results:
    * Calculate YoY growth % for both sales and profit.
    * Use LAG() again to compare current ranking vs previous year’s rank → determine rank changes.

- Final SELECT:
    * Output category, region, year, sales, profit, cumulative sales, YoY growth, ranks, and rank changes.
    * Order results by category, region, and year for a clean timeline.

### Business Insight
This query provides a holistic performance analysis by:
    * Showing which categories dominate sales & profit in each region/year.
    * Tracking growth trends (YoY %).
    * Highlighting cumulative sales progression (long-term value creation).
    * Measuring rank shifts → which categories are climbing or losing ground year to year.

Sample img: [Yoy & rank changes](images/query_yoy_and_rank_changes_1.png) [Yoy & rank changes 2](images/query_yoy_and_rank_changes_2.png)

# 5. Highlight the top-selling category each year.
## Query Purpose
This query finds the top-selling product category each year, highlighting which category dominated annually in terms of total sales.

### Steps / Logic
- CTE – total:
     * Join products, order_details, and orders.
     * Aggregate total sales and total profit per category and year.

- CTE – ranked:
     * Use DENSE_RANK() to rank categories within each year by total sales.

- Final SELECT:
     * Filter to only rank = 1, i.e., the top-selling category for each year.
     * Show category, year, total sales, and total profit.

### Business Insight
- Reveals the leading category by sales year over year.
- Useful for tracking shifts in market dominance — e.g., if Technology was #1 in early years but Office Supplies overtakes later.
- Can inform category-level investment and long-term trend analysis.

Sample img: [Top Selling Category](images/query_top_selling_category.png)

# 6. Which product categories and subcategories drive the most profit?
### Query Purpose
This query ranks product categories by sales and profit within each region and year.

### Steps / Logic
- CTE – sales:
    * Join customers, orders, order_details, and products.
    * Aggregate total sales and total profit per category, region, and year.

- Final SELECT:
    * Output aggregated values.
    * Use RANK() OVER (PARTITION BY region, year ORDER BY total_sales DESC) → ranks categories by sales within each region/year.
    * Use RANK() OVER (PARTITION BY region, year ORDER BY total_profit DESC) → ranks categories by profit within each region/year.

### Business Insight
- Quickly identifies the top-performing categories by sales and profit for each region in each year.
- Helps reveal if a category is strong in revenue but weak in profitability (or vice versa).
- Supports decisions around regional product strategy — e.g., where to expand, cut, or adjust pricing.

Sample img: [Most profit category](images/query_most_profit.png)

# 7. What customer segments and region combined are most valuable?
### Query Purpose
This query evaluates customer segments within each region by ranking them across sales, profit, and profit margin, then combining those rankings into an overall performance score.

### Steps / Logic
- CTE – ranked:
    * Join customers, orders, and order_details.
    * Aggregate total sales, total profit, and calculate profit margin % per region × segment.
    * Apply DENSE_RANK():
        rank_by_sales → rank by total sales (descending) within each region.
        rank_by_profit → rank by total profit.
        rank_by_margin → rank by profit margin %.
- Final SELECT:
    * Output totals, ranks, and compute an “Overall Performer” score as the average of the three ranks.
    * Order results by region and performance score.

### Business Insight
- Identifies which segments perform best within each region not just in raw sales, but also in profitability and efficiency.
- The “Overall Performer” score provides a balanced benchmark across multiple KPIs.
Useful for:
    * Targeting marketing efforts toward the most profitable and efficient customer groups.
    * Spotting segments that generate high sales but weak margins (or vice versa).

Sample img: [Most valuable Customers and region](images/query_customers_and_region_most_valuable.png)
