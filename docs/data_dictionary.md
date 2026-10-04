# Data Dictionary

## Overview

This document describes the analytical data model used in the Azure → Snowflake → dbt data engineering pipeline.

The warehouse follows a **star schema** consisting of one central fact table and multiple dimension tables.

---

## Fact Table

### `fact_sales`

**Grain:** One row per product line within an order.

| Column | Type | Description |
|---|---|---|
| `sales_key` | INTEGER | Surrogate key for the sales record |
| `order_id` | VARCHAR | Business identifier of the order |
| `date_key` | INTEGER | Foreign key to `dim_date` |
| `customer_key` | INTEGER | Foreign key to `dim_customer` |
| `product_key` | INTEGER | Foreign key to `dim_product` |
| `store_key` | INTEGER | Foreign key to `dim_store` |
| `quantity` | INTEGER | Number of units sold |
| `unit_price` | NUMBER | Selling price per unit |
| `discount_amount` | NUMBER | Discount applied to the order line |
| `sales_amount` | NUMBER | Net sales amount |
| `created_at` | TIMESTAMP | Record creation timestamp |

### Business Logic

```text
sales_amount =
(quantity × unit_price) - discount_amount
```

---

# Dimension Tables

## `dim_date`

Provides calendar attributes used for time-based analysis.

| Column | Description |
|---|---|
| `date_key` | Surrogate date key |
| `full_date` | Calendar date |
| `day` | Day of month |
| `month` | Month number |
| `month_name` | Month name |
| `quarter` | Calendar quarter |
| `year` | Calendar year |
| `week_of_year` | Week number |
| `day_of_week` | Day of week |

Typical use cases:

- Daily sales
- Weekly sales
- Monthly revenue
- Quarterly reporting
- Year-over-year analysis

---

## `dim_customer`

Contains customer attributes.

| Column | Description |
|---|---|
| `customer_key` | Surrogate key |
| `customer_id` | Source-system customer identifier |
| `customer_name` | Customer name |
| `email` | Customer email |
| `city` | Customer city |
| `country` | Customer country |
| `created_at` | Customer creation timestamp |
| `updated_at` | Last update timestamp |
| `is_current` | Indicates the current dimension record |
| `valid_from` | Start of record validity |
| `valid_to` | End of record validity |

The `valid_from`, `valid_to`, and `is_current` columns support **Slowly Changing Dimension Type 2** patterns.

---

## `dim_product`

Contains product attributes.

| Column | Description |
|---|---|
| `product_key` | Surrogate key |
| `product_id` | Source-system product identifier |
| `product_name` | Product name |
| `category` | Product category |
| `subcategory` | Product subcategory |
| `unit_price` | Current product price |
| `created_at` | Product creation timestamp |
| `updated_at` | Last update timestamp |
| `is_current` | Indicates whether the record is active |

---

## `dim_store`

Contains store and geographic attributes.

| Column | Description |
|---|---|
| `store_key` | Surrogate key |
| `store_id` | Source-system store identifier |
| `store_name` | Store name |
| `city` | Store city |
| `region` | Geographic region |
| `country` | Country |
| `opened_date` | Store opening date |
| `is_active` | Indicates whether the store is active |

---

# Data Relationships

```text
                    dim_customer
                         |
                         |
dim_product ---- fact_sales ---- dim_store
                         |
                         |
                      dim_date
```

Relationships:

```text
fact_sales.date_key
        ↓
dim_date.date_key

fact_sales.customer_key
        ↓
dim_customer.customer_key

fact_sales.product_key
        ↓
dim_product.product_key

fact_sales.store_key
        ↓
dim_store.store_key
```

---

# Key Design Principles

### Surrogate Keys

Dimension tables use surrogate keys such as `customer_key` and `product_key` to separate warehouse identities from source-system identifiers.

### Business Keys

Source identifiers such as `customer_id`, `product_id`, and `order_id` are retained for traceability.

### Fact Table Grain

The grain of `fact_sales` is explicitly defined as:

> One row per product line within an order.

Maintaining a clearly defined grain helps prevent double counting during analytical queries.

### Historical Tracking

Customer attributes can use an SCD Type 2 pattern to preserve historical changes.

### Data Quality

Important data quality rules include:

- Dimension surrogate keys should be unique.
- Required business keys should not be null.
- Fact foreign keys should reference valid dimension records.
- Quantities should be greater than zero.
- Monetary values should follow defined business rules.
- Duplicate source records should be detected before loading the fact table.
