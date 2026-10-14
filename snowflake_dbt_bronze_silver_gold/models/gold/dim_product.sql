select
    {{ dbt_utils.generate_surrogate_key(['product_id']) }} as product_key,
    product_id,
    product_name,
    product_category,
    standard_cost
from {{ ref('stg_products') }}
