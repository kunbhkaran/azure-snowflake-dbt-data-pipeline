# Architecture

## Logical Flow

```text
Source Files
     |
     v
Azure Data Lake Storage Gen2
     |
     v
Snowflake RAW
     |
     v
dbt Staging
     |
     v
dbt Marts
     |
     v
Analytics / BI
```

## Layers

### 1. Landing / Raw
Source files are retained with minimal transformation.

### 2. Snowflake RAW
Source-aligned tables provide a durable warehouse landing layer.

### 3. dbt Staging
Light transformations standardize data types, names, and basic quality rules.

### 4. Analytics / Marts
Business-ready dimensional models support reporting and analytical workloads.

## Design Principles

- Explicit data grain
- Separation of ingestion and transformation
- Reusable SQL transformations
- Incremental processing where appropriate
- Data quality testing
- Secure credential handling
- Version-controlled code
