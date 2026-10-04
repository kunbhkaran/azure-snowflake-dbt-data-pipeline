-- ============================================================
-- Data Warehouse Schema
-- Azure → Snowflake → dbt Data Engineering Pipeline
-- ============================================================

-- ============================================================
-- Dimension: Date
-- ============================================================

CREATE OR REPLACE TABLE dim_date (
    date_key        INTEGER PRIMARY KEY,
    full_date       DATE NOT NULL,
    day             INTEGER,
    month           INTEGER,
    month_name      VARCHAR(20),
    quarter         INTEGER,
    year            INTEGER,
    week_of_year    INTEGER,
    day_of_week     INTEGER
);


-- ============================================================
-- Dimension: Customer
-- ============================================================

CREATE OR REPLACE TABLE dim_customer (
    customer_key    INTEGER AUTOINCREMENT PRIMARY KEY,
    customer_id     VARCHAR(50) NOT NULL,
    customer_name   VARCHAR(200),
    email           VARCHAR(255),
    city            VARCHAR(100),
    country         VARCHAR(100),
    created_at      TIMESTAMP,
    updated_at      TIMESTAMP,
    is_current      BOOLEAN DEFAULT TRUE,
    valid_from      TIMESTAMP,
    valid_to        TIMESTAMP
);


-- ============================================================
-- Dimension: Product
-- ============================================================

CREATE OR REPLACE TABLE dim_product (
    product_key     INTEGER AUTOINCREMENT PRIMARY KEY,
    product_id      VARCHAR(50) NOT NULL,
    product_name    VARCHAR(200),
    category        VARCHAR(100),
    subcategory     VARCHAR(100),
    unit_price      NUMBER(12,2),
    created_at      TIMESTAMP,
    updated_at      TIMESTAMP,
    is_current      BOOLEAN DEFAULT TRUE
);


-- ============================================================
-- Dimension: Store
-- ============================================================

CREATE OR REPLACE TABLE dim_store (
    store_key       INTEGER AUTOINCREMENT PRIMARY KEY,
    store_id        VARCHAR(50) NOT NULL,
    store_name      VARCHAR(200),
    city            VARCHAR(100),
    region          VARCHAR(100),
    country         VARCHAR(100),
    opened_date     DATE,
    is_active       BOOLEAN DEFAULT TRUE
);


-- ============================================================
-- Fact: Sales
-- Grain:
-- One row per product line within an order.
-- ============================================================

CREATE OR REPLACE TABLE fact_sales (
    sales_key           INTEGER AUTOINCREMENT PRIMARY KEY,

    order_id            VARCHAR(50) NOT NULL,

    date_key            INTEGER,
    customer_key        INTEGER,
    product_key         INTEGER,
    store_key           INTEGER,

    quantity            INTEGER,
    unit_price          NUMBER(12,2),
    discount_amount     NUMBER(12,2),
    sales_amount        NUMBER(14,2),

    created_at           TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_sales_date
        FOREIGN KEY (date_key)
        REFERENCES dim_date(date_key),

    CONSTRAINT fk_sales_customer
        FOREIGN KEY (customer_key)
        REFERENCES dim_customer(customer_key),

    CONSTRAINT fk_sales_product
        FOREIGN KEY (product_key)
        REFERENCES dim_product(product_key),

    CONSTRAINT fk_sales_store
        FOREIGN KEY (store_key)
        REFERENCES dim_store(store_key)
);


-- ============================================================
-- Example calculation:
--
-- sales_amount =
-- (quantity × unit_price) - discount_amount
-- ============================================================
