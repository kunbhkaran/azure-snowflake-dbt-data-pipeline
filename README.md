# Azure → Snowflake → dbt Data Engineering Pipeline

An end-to-end data engineering project demonstrating a modern cloud data platform using **Azure Data Lake Storage, Snowflake, dbt, SQL, and Python**.

The project simulates an e-commerce business receiving daily transactional files and transforms them into an analytics-ready dimensional warehouse.

---

## 🏗️ Architecture

```text
                    ┌─────────────────────┐
                    │   Source Systems    │
                    │  E-commerce / CSV   │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │   Azure ADLS Gen2   │
                    │   Raw / Landing     │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │      Snowflake      │
                    │                     │
                    │   RAW → STAGING     │
                    └──────────┬──────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │        dbt          │
                    │ Transformations &   │
                    │ Data Quality Tests  │
                    └──────────┬──────────┘
                               │
                               ▼
              ┌────────────────────────────────┐
              │       Analytics Layer          │
              │                                │
              │  Dimensions + Fact Tables      │
              └────────────────┬───────────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │ BI / Analytics      │
                    │ Power BI / SQL      │
                    └─────────────────────┘
```

---

## 🎯 Project Objective

The objective is to design a scalable data pipeline that:

- Ingests daily transactional data from cloud storage
- Separates raw, staging, and analytics layers
- Loads data into Snowflake
- Performs transformations using dbt
- Implements dimensional data modeling
- Supports incremental data processing
- Applies automated data quality tests
- Produces analytics-ready datasets for reporting

---

## 🛠️ Technology Stack

| Technology | Purpose |
|---|---|
| **Azure Data Lake Storage Gen2** | Cloud data lake / landing zone |
| **Snowflake** | Cloud data warehouse |
| **dbt** | SQL transformations and data modeling |
| **Python** | Data processing and utilities |
| **SQL** | Data transformation and analytics |
| **Git / GitHub** | Version control and documentation |
| **Power BI** | Analytics / visualization |

---

## 📂 Project Structure

```text
azure-snowflake-dbt-data-pipeline/
│
├── README.md
│
├── architecture/
│   └── architecture.md
│
├── sql/
│   ├── schema.sql
│   ├── staging.sql
│   └── analytics.sql
│
├── dbt/
│   ├── models/
│   │   ├── staging/
│   │   └── marts/
│   │
│   └── tests/
│
├── sample_data/
│   └── README.md
│
└── docs/
    └── data_dictionary.md
```

---

## 📊 Data Sources

The project simulates an e-commerce platform with the following entities:

### Customers

```text
customer_id
customer_name
email
city
country
created_at
```

### Products

```text
product_id
product_name
category
subcategory
unit_price
```

### Orders

```text
order_id
customer_id
order_date
order_status
store_id
```

### Order Items

```text
order_id
product_id
quantity
unit_price
discount_amount
```

Daily files are conceptually delivered to the Azure landing zone.

Example:

```text
orders_2026-10-01.csv
orders_2026-10-02.csv
orders_2026-10-03.csv
```

---

## 🗄️ Data Lake Design

The Azure Data Lake follows a simple layered structure:

```text
ADLS Gen2
│
├── raw/
│   ├── customers/
│   ├── products/
│   ├── orders/
│   └── order_items/
│
└── archive/
```

### Raw Layer

Contains source files in their original form.

The raw layer is treated as immutable wherever practical so that source data can be reprocessed if downstream transformations change.

### Archive Layer

Successfully processed files can be moved or retained here according to the ingestion strategy.

---

## ❄️ Snowflake Architecture

Snowflake is organized into logical layers:

```text
RAW
 ↓
STAGING
 ↓
MARTS
```

### RAW

Contains data loaded from the landing zone with minimal transformation.

### STAGING

Responsible for:

- Standardizing column names
- Casting data types
- Handling null values
- Basic cleansing
- Removing obvious duplicates
- Preparing data for business transformations

### MARTS

Contains analytics-ready dimensional models.

---

## ⭐ Dimensional Model

The analytics layer follows a star-schema approach.

### Fact Table

**fact_sales**

```text
sale_key
order_id
date_key
customer_key
product_key
quantity
unit_price
discount_amount
sales_amount
```

### Dimension Tables

```text
dim_date
dim_customer
dim_product
dim_store
```

Conceptually:

```text
              dim_customer
                   │
                   │
dim_product ─── fact_sales ─── dim_store
                   │
                   │
               dim_date
```

The grain of `fact_sales` is:

> **One row per product line within an order.**

Clearly defining the grain prevents double counting and makes downstream analytics more reliable.

---

## 🔄 dbt Transformation Layer

dbt is used to implement SQL-based transformations and analytics models.

Example structure:

```text
dbt/
└── models/
    ├── staging/
    │   ├── stg_customers.sql
    │   ├── stg_products.sql
    │   ├── stg_orders.sql
    │   └── stg_order_items.sql
    │
    └── marts/
        ├── dim_customer.sql
        ├── dim_product.sql
        ├── dim_date.sql
        └── fact_sales.sql
```

The transformation process follows:

```text
Source
  ↓
Raw
  ↓
Staging models
  ↓
Business transformations
  ↓
Dimensions / Facts
```

---

## 🔁 Incremental Processing

The pipeline is designed to support incremental processing rather than rebuilding the complete warehouse every day.

For example:

```text
Day 1
100,000 records
       ↓
Initial load

Day 2
5,000 new records
       ↓
Incremental load
       ↓
Only new/changed records processed
```

This reduces unnecessary computation as the dataset grows.

Incremental models can use business keys and timestamps such as:

```text
order_id
updated_at
created_at
```

to identify newly arrived or changed records.

---

## 🧩 Slowly Changing Dimensions

The project also demonstrates **Slowly Changing Dimension Type 2 (SCD2)** concepts for dimensions where historical changes need to be preserved.

Example:

```text
customer_id | city      | valid_from | valid_to   | is_current
------------|-----------|------------|------------|-----------
101         | Karachi   | 2026-01-01 | 2026-06-15 | false
101         | Lahore    | 2026-06-15 | NULL       | true
```

This allows historical reporting based on the attributes that were valid at the time of the transaction.

---

## ✅ Data Quality

Data quality checks are applied to important models.

Examples include:

- Primary/business key uniqueness
- Not-null validation
- Referential integrity
- Accepted values
- Duplicate detection
- Unexpected record-count changes

Example dbt tests:

```yaml
tests:
  - unique
  - not_null
```

For example:

```text
fact_sales.order_id
fact_sales.product_key
dim_product.product_key
dim_customer.customer_key
```

---

## 📈 Example Analytics

The final warehouse supports questions such as:

### Sales by Product

```sql
SELECT
    p.product_name,
    SUM(f.quantity) AS quantity_sold,
    SUM(f.sales_amount) AS total_sales
FROM fact_sales f
JOIN dim_product p
    ON f.product_key = p.product_key
GROUP BY p.product_name
ORDER BY total_sales DESC;
```

### Monthly Revenue

```sql
SELECT
    d.year,
    d.month,
    SUM(f.sales_amount) AS revenue
FROM fact_sales f
JOIN dim_date d
    ON f.date_key = d.date_key
GROUP BY d.year, d.month
ORDER BY d.year, d.month;
```

### Top Products by City

```sql
SELECT
    s.city,
    p.product_name,
    SUM(f.quantity) AS quantity_sold
FROM fact_sales f
JOIN dim_store s
    ON f.store_key = s.store_key
JOIN dim_product p
    ON f.product_key = p.product_key
GROUP BY s.city, p.product_name
ORDER BY s.city, quantity_sold DESC;
```

---

## 🔐 Engineering Practices

The project follows several production-oriented practices:

- Layered data architecture
- Separation of ingestion and transformation
- Dimensional modeling
- Incremental processing
- Idempotent transformation principles
- Data quality validation
- Version-controlled SQL
- Environment-specific configuration
- Secure credential management
- Documentation of data models and assumptions

Credentials and secrets are **not stored in the repository**.

---

## 🚀 Future Improvements

Potential extensions include:

- Airflow orchestration
- Azure Data Factory orchestration
- Snowpipe-based ingestion
- Azure Key Vault integration
- CI/CD using GitHub Actions
- Automated dbt testing
- Data observability
- Great Expectations integration
- Power BI dashboard
- Spark-based processing for larger datasets
- Infrastructure as Code using Terraform

---

## 👨‍💻 About

Built as a practical **Senior Data Engineering portfolio project** to demonstrate modern data warehouse architecture, cloud data engineering, ELT, dimensional modeling, SQL transformation, and data quality practices.

**Author:** Kunbh Karan

**Focus:** Data Engineering | Data Warehousing | ETL/ELT | Cloud Data Platforms | SQL | Python | Spark | dbt | Airflow

---

## 📌 Disclaimer

This repository is a learning and portfolio project. Architecture and implementation choices are designed to demonstrate production-oriented data engineering practices and may be simplified compared with a large-scale enterprise production environment.
