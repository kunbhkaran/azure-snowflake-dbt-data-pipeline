-- dbt staging model for orders

WITH source_data AS (

    SELECT
        order_id,
        customer_id,
        store_id,
        order_date,
        order_status,
        created_at,
        updated_at
    FROM {{ source('raw', 'orders') }}

),

cleaned AS (

    SELECT
        TRIM(order_id) AS order_id,
        TRIM(customer_id) AS customer_id,
        TRIM(store_id) AS store_id,
        CAST(order_date AS DATE) AS order_date,
        LOWER(TRIM(order_status)) AS order_status,
        CAST(created_at AS TIMESTAMP) AS created_at,
        CAST(updated_at AS TIMESTAMP) AS updated_at
    FROM source_data

)

SELECT *
FROM cleaned;
