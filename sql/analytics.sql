-- ============================================================
-- Analytics Queries
-- Azure → Snowflake → dbt Data Engineering Pipeline
-- ============================================================

-- 1. Monthly Revenue
-- Business question:
-- How much revenue was generated each month?

SELECT
    d.year,
    d.month,
    SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
JOIN dim_date d
    ON f.date_key = d.date_key
GROUP BY
    d.year,
    d.month
ORDER BY
    d.year,
    d.month;


-- 2. Top 5 Products by Revenue
-- Business question:
-- Which products generate the most revenue?

SELECT
    p.product_name,
    SUM(f.quantity) AS quantity_sold,
    SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
JOIN dim_product p
    ON f.product_key = p.product_key
GROUP BY
    p.product_name
ORDER BY
    total_revenue DESC
LIMIT 5;


-- 3. Sales by City
-- Business question:
-- Which cities generate the most sales?

SELECT
    s.city,
    SUM(f.quantity) AS quantity_sold,
    SUM(f.sales_amount) AS total_revenue
FROM fact_sales f
JOIN dim_store s
    ON f.store_key = s.store_key
GROUP BY
    s.city
ORDER BY
    total_revenue DESC;


-- 4. Top 5 Products per City
-- Uses a window function to rank products within each city.

WITH city_product_sales AS (
    SELECT
        s.city,
        p.product_name,
        SUM(f.quantity) AS quantity_sold,
        SUM(f.sales_amount) AS total_revenue
    FROM fact_sales f
    JOIN dim_store s
        ON f.store_key = s.store_key
    JOIN dim_product p
        ON f.product_key = p.product_key
    GROUP BY
        s.city,
        p.product_name
),

ranked_products AS (
    SELECT
        city,
        product_name,
        quantity_sold,
        total_revenue,
        ROW_NUMBER() OVER (
            PARTITION BY city
            ORDER BY total_revenue DESC
        ) AS product_rank
    FROM city_product_sales
)

SELECT
    city,
    product_name,
    quantity_sold,
    total_revenue
FROM ranked_products
WHERE product_rank <= 5
ORDER BY
    city,
    product_rank;


-- 5. Customer Lifetime Revenue
-- Business question:
-- Which customers have generated the most revenue?

SELECT
    c.customer_id,
    c.customer_name,
    SUM(f.sales_amount) AS lifetime_revenue
FROM fact_sales f
JOIN dim_customer c
    ON f.customer_key = c.customer_key
GROUP BY
    c.customer_id,
    c.customer_name
ORDER BY
    lifetime_revenue DESC;


-- 6. Monthly Revenue Growth
-- Calculates month-over-month revenue growth.

WITH monthly_sales AS (
    SELECT
        d.year,
        d.month,
        SUM(f.sales_amount) AS revenue
    FROM fact_sales f
    JOIN dim_date d
        ON f.date_key = d.date_key
    GROUP BY
        d.year,
        d.month
),

with_previous_month AS (
    SELECT
        year,
        month,
        revenue,
        LAG(revenue) OVER (
            ORDER BY year, month
        ) AS previous_month_revenue
    FROM monthly_sales
)

SELECT
    year,
    month,
    revenue,
    previous_month_revenue,
    ROUND(
        (
            (revenue - previous_month_revenue)
            / NULLIF(previous_month_revenue, 0)
        ) * 100,
        2
    ) AS revenue_growth_percentage
FROM with_previous_month
ORDER BY
    year,
    month;
