-- dbt analytical fact model
-- Grain: one row per product line within an order.

WITH order_items AS (

    SELECT
        order_id,
        product_id,
        quantity,
        unit_price,
        discount_amount
    FROM {{ source('raw', 'order_items') }}

)

SELECT
    order_id,
    product_id,
    quantity,
    unit_price,
    discount_amount,
    (quantity * unit_price) - COALESCE(discount_amount, 0)
        AS sales_amount
FROM order_items;
