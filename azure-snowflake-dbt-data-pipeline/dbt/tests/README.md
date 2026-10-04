# dbt Tests

This directory is reserved for custom dbt data-quality tests.

The project currently demonstrates schema-level tests in `models/staging/schema.yml`, including:

- not-null validation
- uniqueness validation

Future extensions can add custom SQL tests for:

- duplicate business keys
- invalid sales amounts
- orphaned foreign keys
- unexpected row-count changes
