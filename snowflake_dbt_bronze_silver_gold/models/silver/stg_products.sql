with source_data as (
    select
        nullif(trim(product_id), '') as product_id,
        nullif(trim(product_name), '') as product_name,
        initcap(nullif(trim(product_category), '')) as product_category,
        try_to_decimal(standard_cost, 12, 2) as standard_cost
    from {{ ref('brz_products') }}
)
select *
from source_data
where product_id is not null
qualify row_number() over (partition by product_id order by product_name) = 1
