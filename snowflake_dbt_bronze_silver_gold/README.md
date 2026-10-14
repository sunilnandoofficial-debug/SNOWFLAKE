# Snowflake + dbt Bronze → Silver → Gold → Semantic View

A starter project based on the supplied architecture diagram. It includes Snowflake setup SQL, a dbt project, sample seed data, staging/cleaning models, dimensional models, tests, a snapshot example, and a semantic-view deployment script.

## Assumptions and what you must customize

- The diagram names IRIS, Finance Foundation, and application inputs but does not specify source schemas or column contracts. This project uses a small **illustrative sales/finance dataset** so the pipeline is executable end-to-end.
- Replace the sample entities and business rules with your real source tables, definitions, and security policies before production use.
- `raw` is the Bronze landing schema. It is intentionally separate from dbt transformations.
- dbt Core + `dbt-snowflake` is used. Snowflake Semantic Views require an account/region that supports the feature and the appropriate privileges. If unavailable, use a governed secure view as the fallback.
- Sample CSVs are loaded with `dbt seed` for a quick demo. For production, use your real ingestion process (Snowpipe, COPY INTO, an ELT tool, etc.) and define dbt sources against the landed tables.

## Project structure

```text
snowflake_dbt_bronze_silver_gold/
├── README.md
├── requirements.txt
├── .gitignore
├── profiles.yml.example
├── scripts/
│   ├── 00_create_environment.sql
│   ├── 01_create_raw_tables.sql
│   ├── 02_load_demo_data.sql
│   ├── 03_create_semantic_view.sql
│   └── 04_grants_example.sql
├── seeds/
│   ├── raw_customers.csv
│   ├── raw_products.csv
│   └── raw_sales.csv
├── snapshots/
│   └── snap_customers.sql
├── models/
│   ├── sources.yml
│   ├── bronze/
│   ├── silver/
│   ├── gold/
│   └── semantic/
└── tests/
    └── assert_no_negative_net_sales.sql
```

## 1. Prerequisites

- Snowflake account and a role with privileges to create/use a database, schemas, warehouse, tables, views, and (if supported) semantic views.
- Python 3.10+ recommended.
- dbt Core and the Snowflake adapter.

```bash
python -m venv .venv
# Windows:
.venv\Scripts\activate
# macOS/Linux:
source .venv/bin/activate

pip install -r requirements.txt
dbt --version
```

## 2. Configure Snowflake connection

Copy `profiles.yml.example` to `~/.dbt/profiles.yml` (Windows: `%USERPROFILE%\.dbt\profiles.yml`) and replace placeholders. Do not commit credentials. Environment variables are preferred.

Set these environment variables (example names):
- `SNOWFLAKE_ACCOUNT`
- `SNOWFLAKE_USER`
- `SNOWFLAKE_PASSWORD` (or configure key-pair authentication)
- `SNOWFLAKE_ROLE`
- `SNOWFLAKE_WAREHOUSE`

Then validate:

```bash
dbt debug
```

## 3. Create Snowflake environment

Run `scripts/00_create_environment.sql` as an admin/developer role. Then use `scripts/01_create_raw_tables.sql` if you want physical raw tables. The demo path instead uses `dbt seed` to create tables in the `SEED` schema, and the source definitions point at those seeded tables.

The included schema-name macro maps model folders to the exact `BRONZE`, `SILVER`, `GOLD`, and `SEMANTIC` schemas (rather than dbt's default `DEV_BRONZE` naming). For a production-style Bronze schema, load real raw tables into `RAW` and update `models/sources.yml` to point there. The included models currently point to `SEED` so the demo runs without a separate file-ingestion setup.

## 4. Execute the dbt demo

From this project directory:

```bash
dbt deps
dbt debug
dbt seed
dbt run
dbt test
dbt build
```

`dbt build` runs seeds/models/tests in dependency order. If the semantic view script is run separately, run it only after the Gold models exist.

To see the model graph:

```bash
dbt docs generate
dbt docs serve
```

## 5. How each layer works

### Bronze
The raw layer is immutable-by-design: retain source values and ingestion metadata; do not overwrite the only copy with business transformations. The sample seed tables stand in for raw-landed inputs for a local demo.

### Silver
`stg_customers`, `stg_products`, and `stg_sales` standardize types and names. `int_sales_enriched` deduplicates sales by `sale_id`, joins validated product/customer records, and calculates net sales. This is the harmonization layer.

### Gold
`dim_customer`, `dim_product`, and `fct_sales` are reporting-ready dimensional models. `agg_sales_monthly` is a monthly aggregate for dashboards. The fact table grain is **one row per sale_id**.

### Semantic
`gold.vw_sales_semantic` is a simple governed dbt view usable by BI. `scripts/03_create_semantic_view.sql` demonstrates native Snowflake `CREATE SEMANTIC VIEW` syntax as a separate optional deployment step. Confirm exact syntax and account support against your Snowflake release before using it in production.

## 6. Run selected models

```bash
dbt run --select stg_sales+
dbt test --select fct_sales
dbt build --select tag:gold
```

Tags are assigned in `dbt_project.yml`.

## 7. Production hardening checklist

1. Replace seed inputs with actual raw tables and declare freshness on timestamped sources.
2. Add `loaded_at`, source filename, batch/run ID, source system, and ingestion timestamp to raw data.
3. Define authoritative business keys and late-arriving-data policy.
4. Decide incremental strategy per model (merge key, delete handling, backfills, schema changes).
5. Add reconciliation tests: source vs target counts, control totals, duplicate rate, rejected rows.
6. Keep PII/PHI out of broad-access schemas; use least-privilege roles, masking/row access policies, and approved secure views.
7. Store credentials in a secret manager and use key-pair/OAuth where appropriate.
8. Add CI checks (`dbt deps`, `dbt parse`, `dbt compile`, `dbt build`) and controlled deployment.
9. Orchestrate with Airflow/Control-M/dbt jobs. Trigger Silver only after ingestion succeeds; Gold only after Silver tests pass; semantic publication only after Gold tests pass.
10. Monitor dbt artifacts, Snowflake query history, warehouse spend, failures, freshness and SLA.
11. Implement dev/test/prod environment separation and documented rollback.
12. For regulated data, add retention, audit, lineage, data classification, and access-review controls.

## 8. Troubleshooting

- `Database does not exist`: run the environment SQL and verify `database` in your profile.
- `Object does not exist`: run `dbt seed` before `dbt run`, or change source schema/table names.
- `Insufficient privileges`: verify role grants for database/schema/warehouse and object creation.
- Semantic view syntax/feature error: skip the optional native semantic view script and use `gold.vw_sales_semantic` until the account supports the feature.
- Seed table column type differs: check CSV headers and seed configuration, then `dbt seed --full-refresh`.

## 9. How to map this demo to the attached diagram

| Diagram layer | Project implementation |
|---|---|
| Bronze | `SEED` tables for demo; replace with immutable `RAW` source tables |
| Silver | `models/silver/stg_*.sql`, `models/silver/int_sales_enriched.sql` |
| Gold | `models/gold/dim_*.sql`, `fct_sales.sql`, `agg_sales_monthly.sql` |
| Semantic View | `models/semantic/vw_sales_semantic.sql` + optional native script |
| Automated tests | `models/**/*.yml`, `tests/assert_no_negative_net_sales.sql` |
| Lineage | dbt `ref()` dependencies + `dbt docs generate` |
| Orchestration | External orchestrator; example DAG design described above |
