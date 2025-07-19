/*
=========================================================================
-- Customer Report
=========================================================================
Purpose: 
	- This report consolidates key customer metrics and behaviors.

Highlights: 
	1. Gathers essential fields such as names, ages and transation details.
	2. Segments customer into categories (VIP, Regular, New) and age groups.
	3. Aggregates customer-level metrics.
		- total orders
		- total sales
		- total quantity purchased
		- total products
		- lifespan (in month)
	4. Calculates valuable KPIs:
		- recency (months since last order)
		- average order value
		- average monthly spend
==========================================================================
*/
CREATE VIEW gold.report_customers AS
	WITH base_query AS(
	/*------------------------------------------------------------------------
	1.) Base Query: Retrieves core columns from tables.
	------------------------------------------------------------------------*/
		SELECT
			sal.order_number,
			sal.product_key,
			sal.order_date,
			sal.sales_amount,
			sal.quantity,
			cus.customer_key,
			cus.customer_number,
			CONCAT(cus.first_name, ' ', cus.last_name) AS customer_name,
			cus.birthdate,
			DATEDIFF(year, cus.birthdate, GETDATE()) AS age
		FROM gold.fact_sales sal
		LEFT JOIN gold.dim_customers cus
		ON sal.customer_key = cus.customer_key
		WHERE sal.order_date IS NOT NULL )

	, customer_aggregation AS(
	/*------------------------------------------------------------------------
	2.) Customer Aggregations: Summarizes key metrics at the customer level.
	------------------------------------------------------------------------*/
		SELECT
			customer_key,
			customer_number,
			customer_name,
			birthdate,
			age,
			COUNT(DISTINCT order_number) AS total_orders,
			SUM(sales_amount) AS total_sales,
			COUNT(quantity) AS total_quantity,
			COUNT(DISTINCT product_key) AS total_product,
			MAX(order_date) AS last_order_date,
			DATEDIFF(month, MIN(order_date), MAX(order_date)) AS lifespan
		FROM base_query
		GROUP BY
			customer_key,
			customer_number,
			customer_name,
			birthdate,
			age )

	SELECT
		customer_key,
		customer_number,
		customer_name,
		age,
		CASE
			WHEN age < 20 THEN 'Under 20'
			WHEN age between 20 and 29 THEN '20-29'
			WHEN age between 30 and 39 THEN '30-39'
			WHEN age between 40 and 49 THEN '40-49'
			ELSE '50 and above'
		END age_group,
		CASE
			WHEN lifespan >= 12 and total_sales > 5000 THEN 'VIP'
			WHEN lifespan >= 12 and total_sales <= 5000 THEN 'Regular'
			ELSE 'New'
		END customer_segment,
		last_order_date,
		DATEDIFF(month, last_order_date, GETDATE()) AS recency,
		total_orders,
		total_sales,
		total_quantity,
		total_product,
		lifespan,
		-- Compute average order value (AVO)
		CASE
			WHEN total_orders  = 0 THEN '0'
			ELSE total_sales / total_orders
		END AS avg_order_value,

		-- Compute average monthly spend
		CASE
			WHEN total_sales = 0  THEN '0'
			WHEN lifespan = 0  THEN '0'
			ELSE total_sales / lifespan
		END AS avg_monthly_spend
	FROM customer_aggregation
