# onemind dbt project

This repository now contains a dbt project for Snowflake with a simple three-layer model structure for the `onemind.public.customers` source table.

## Structure

- `models/staging`: raw source definitions and light renaming/standardization
- `models/intermediate`: business-ready transformations
- `models/marts`: final analytics-facing models

## dbt Cloud connection

Configure your dbt Cloud environment to use Snowflake with:

- Database: `onemind`
- Warehouse: `COMPUTE_WH`
- Schema: `public`

This project assumes your raw Snowflake objects were created as quoted lowercase names, so dbt is configured to preserve the schema casing and to quote the `customers` source table identifier.

The project name in [dbt_project.yml](./dbt_project.yml) is `onemind`. The configured `profile` remains `default`, so update that value if your dbt Cloud environment uses a different profile name.

## Key models

- `stg_customers`
- `int_customers`
- `dim_customers`

## Suggested first run

```bash
dbt build --select dim_customers
```
