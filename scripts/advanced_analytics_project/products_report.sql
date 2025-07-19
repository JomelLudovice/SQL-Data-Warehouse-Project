/*
=========================================================================
-- Product Report
=========================================================================
Purpose: 
	- This report consolidates key product metrics and behaviors.

Highlights: 
	1. Gathers essential fields such as product names, category, subcategory, and cost.
	2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
	3. Aggregates product-level metrics.
		- total orders
		- total sales
		- total quantity sold
		- total customers (unique)
		- lifespan (in month)
	4. Calculates valuable KPIs:
		- recency (months since last sale)
		- average order revenue (AOR)
		- average monthly revenue
==========================================================================
*/
CREATE VIEW gold.report_products AS
	WITH base_query AS (
		SELECT
			f.order_number,
			f.customer_key,
			f.order_date,
			f.sales_amount,
			f.quantity,
			p.product_key,
			p.product_name,
			p.category,
			p.subcategory,
			p.cost
		FROM gold.fact_sales f
		LEFT JOIN gold.dim_products p
		ON p.product_key = f.product_key
		WHERE f.order_date IS NOT NULL -- ony consider valid sales date)
		)

	, product_aggregation AS (
		SELECT 
			product_key,
			product_name,
			category,
			subcategory,
			cost,
			COUNT(DISTINCT order_number) AS total_orders,
			SUM(sales_amount) AS total_sales,
			SUM(quantity) AS total_quantity_sold,
			COUNT( DISTINCT customer_key) AS total_customers,
			MAX(order_date) AS last_sales_date,
			DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan,
			ROUND(AVG(CAST(sales_amount AS FLOAT) / NULLIF(quantity, 0)), 1) AS avg_selling_price
		FROM base_query
		GROUP BY 
			product_key,
			product_name,
			category,
			subcategory,
			cost)

	SELECT
		product_key,
		product_name,
		category,
		subcategory,
		cost,
		avg_selling_price,
		CASE 
			WHEN total_sales > 50000 THEN 'High-Performers'
			WHEN total_sales >= 10000 THEN  'Mid-Range'
			ELSE 'Low-Performers'
		END product_segment,
		last_sales_date,
		DATEDIFF(month, last_sales_date, GETDATE()) AS recency_in_months,
		total_orders,
		total_sales,
		total_quantity_sold,
		total_customers,
		lifespan,
		-- average order revenue (AOV)
		CASE
			WHEN total_orders  = 0 THEN '0'
			ELSE total_sales / total_orders
		END AS avg_order_revenue,
		-- average monthly revenue
		CASE
			WHEN total_sales = 0  THEN '0'
			WHEN lifespan = 0  THEN '0'
			ELSE total_sales / lifespan
		END AS avg_monthly_revenue
	FROM product_aggregation
