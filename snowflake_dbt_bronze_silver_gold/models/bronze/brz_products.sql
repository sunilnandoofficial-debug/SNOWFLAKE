select
    product_id,
    product_name,
    product_category,
    standard_cost,
    current_timestamp()::timestamp_ntz as dbt_observed_at
from {{ source('demo_seed', 'raw_products') }}
