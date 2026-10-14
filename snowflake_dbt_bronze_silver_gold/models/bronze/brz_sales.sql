select
    sale_id,
    customer_id,
    product_id,
    sale_date,
    quantity,
    unit_price,
    discount_amount,
    currency_code,
    updated_at,
    current_timestamp()::timestamp_ntz as dbt_observed_at
from {{ source('demo_seed', 'raw_sales') }}
