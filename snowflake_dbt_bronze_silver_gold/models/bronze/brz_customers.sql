-- Bronze pass-through: keep source representation; no business rules.
select
    customer_id,
    customer_name,
    country,
    updated_at,
    current_timestamp()::timestamp_ntz as dbt_observed_at
from {{ source('demo_seed', 'raw_customers') }}
