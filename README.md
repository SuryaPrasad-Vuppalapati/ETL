# ETL Project - dbt + Airflow Data Pipeline

A production-ready ETL (Extract, Transform, Load) pipeline that combines **dbt** for data transformations and **Apache Airflow** for orchestration, using TPC-H benchmark data in Snowflake.

## Project Structure

```
ETL/
├── data_pipeline/          # dbt project for data transformations
│   ├── models/
│   │   ├── staging/        # Raw data models (views)
│   │   └── marts/          # Business logic models (tables)
│   ├── tests/              # Data quality tests
│   ├── macros/             # Custom dbt macros
│   ├── seeds/              # Static reference data
│   └── dbt_project.yml     # dbt configuration
└── dbt-dag/                # Airflow orchestration layer
    ├── dags/
    │   └── dbt_dag.py      # Main DAG definition
    ├── Dockerfile          # Containerized Airflow setup
    ├── requirements.txt    # Python dependencies
    └── airflow_settings.yaml
```

## Overview

### Data Pipeline Components

**Staging Layer** (`models/staging/`)
- `stg_tpch_orders.sql` - Cleaned and standardized orders data
- `stg_tpch_line_items.sql` - Cleaned and standardized line items data
- Materialized as **views** for lightweight transformations

**Marts Layer** (`models/marts/`)
- `fct_orders.sql` - Core fact table for order analytics
- `int_order_summary.sql` - Order aggregations and summaries
- `int_orders_items.sql` - Denormalized order-item relationships
- Materialized as **tables** for optimized query performance

### Orchestration

The Airflow DAG (`dbt-dag/dags/dbt_dag.py`) runs:
- **Schedule**: Daily (`@daily`)
- **Start Date**: September 10, 2025
- **Target**: Snowflake data warehouse
- **Execution**: Cosmos operator for seamless dbt integration

## Getting Started

### Prerequisites

- **Snowflake** account and credentials
- **Python 3.8+**
- **Docker** (for Airflow containerization)
- **dbt-core** and **dbt-snowflake** adapter

### Installation

#### 1. Set Up dbt Project

```bash
cd data_pipeline

# Install dbt dependencies
dbt deps

# Configure dbt profile (create ~/.dbt/profiles.yml)
# Add your Snowflake credentials
```

#### 2. Configure Snowflake Credentials

Create `~/.dbt/profiles.yml`:

```yaml
data_pipeline:
  outputs:
    dev:
      type: snowflake
      account: [your_account]
      user: [your_username]
      password: [your_password]
      role: [your_role]
      database: dbt_db
      schema: dbt_schema
      warehouse: dbt_wh
      threads: 4
  target: dev
```

#### 3. Set Up Airflow

```bash
cd dbt-dag

# Install dependencies
pip install -r requirements.txt

# Build Docker image
docker build -t etl-airflow .

# Start Airflow (using docker-compose)
docker-compose up
```

#### 4. Configure Airflow Connections

Add Snowflake connection in Airflow UI:
- **Conn ID**: `snowflake_conn`
- **Host**: Your Snowflake account
- **Login**: Your username
- **Password**: Your password
- **Schema**: `dbt_schema`
- **Database**: `dbt_db`

## Running the Pipeline

### dbt Commands

```bash
cd data_pipeline

# Run all models
dbt run

# Run with selection
dbt run --select staging  # Run only staging models
dbt run --select marts    # Run only marts models

# Run tests
dbt test

# Generate documentation
dbt docs generate
dbt docs serve
```

### Airflow Commands

```bash
# Trigger DAG
airflow dags trigger dbt_dag

# Check DAG status
airflow dags list
airflow tasks list dbt_dag

# View logs
airflow logs dbt_dag
```

## Data Quality Tests

Tests are defined in `models/marts/genric_tests.yml`:

```bash
# Run all tests
dbt test

# Run specific test
dbt test -s fact_orders_date_valid
```

### Test Coverage

- `fact_orders_date_valid` - Validates order dates
- `fct_order_discounts` - Validates discount calculations
- Generic uniqueness and not-null constraints

## Data Source: TPC-H

This pipeline uses the **TPC-H (Transaction Processing Performance Council)** benchmark dataset:

- **Orders**: Customer orders with timestamps and totals
- **Line Items**: Individual order items with pricing and discounts

TPC-H is a standard analytical workload used for benchmarking data warehouse performance.

## Architecture

```
Airflow (Orchestrator)
    ↓
    └→ Cosmos DbtDag
        ↓
        └→ dbt Core
            ↓
            ├→ Staging Layer (Views)
            │   ├ stg_tpch_orders
            │   └ stg_tpch_line_items
            │
            └→ Marts Layer (Tables)
                ├ fct_orders
                ├ int_order_summary
                └ int_orders_items
                ↓
            Snowflake
```

## Configuration

### dbt Configuration

Edit `data_pipeline/dbt_project.yml`:

```yaml
models:
  data_pipeline:
    staging:
      +materialized: view         # Staging as views
      +snowflake_warehouse: dbt_wh
    marts:
      +materialized: table        # Marts as tables
      +snowflake_warehouse: dbt_wh
```

### Airflow Configuration

Edit `dbt-dag/airflow_settings.yaml` to adjust:
- Execution parameters
- Warehouse settings
- Database schema
- Runtime dependencies

## Key Files

| File | Purpose |
|------|---------|
| `data_pipeline/dbt_project.yml` | dbt project metadata and config |
| `dbt-dag/dags/dbt_dag.py` | Airflow DAG definition |
| `data_pipeline/models/staging/` | Raw data layer |
| `data_pipeline/models/marts/` | Business logic layer |
| `data_pipeline/tests/` | Data quality tests |

## Troubleshooting

### dbt Connection Issues
```bash
# Test Snowflake connection
dbt debug

# If connection fails, verify profiles.yml credentials
```

### Airflow DAG Not Showing
```bash
# Restart Airflow services
docker-compose restart

# Check logs
docker-compose logs airflow-webserver
```

### Test Failures
```bash
# Run tests with detailed output
dbt test --debug

# Check test definitions in genric_tests.yml
```

## Resources

- [dbt Documentation](https://docs.getdbt.com/)
- [Apache Airflow Documentation](https://airflow.apache.org/docs/)
- [Astronomer Cosmos](https://github.com/astronomer/cosmos)
- [Snowflake dbt Adapter](https://docs.getdbt.com/reference/warehouse-setups/snowflake-setup)
- [TPC-H Benchmark](http://www.tpc.org/tpch/)

## Development Workflow

1. **Create Feature Branch**: `git checkout -b feature/new-model`
2. **Add dbt Model**: Create `.sql` file in `models/staging/` or `models/marts/`
3. **Write Tests**: Add test definitions to `.yml` files
4. **Test Locally**: `dbt run && dbt test`
5. **Commit Changes**: `git commit -m "Add new model"`
6. **Push & Deploy**: `git push origin feature/new-model`

## Dependencies

- **dbt-core** ^1.5.0
- **dbt-snowflake** ^1.5.0
- **apache-airflow** ^2.0
- **astronomer-cosmos**
- **apache-airflow-providers-snowflake**

### Resources:
- Learn more about dbt [in the docs](https://docs.getdbt.com/docs/introduction)
- Check out [Discourse](https://discourse.getdbt.com/) for commonly asked questions and answers
- Join the [chat](https://community.getdbt.com/) on Slack for live discussions and support
- Find [dbt events](https://events.getdbt.com) near you
- Check out [the blog](https://blog.getdbt.com/) for the latest news on dbt's development and best practices
