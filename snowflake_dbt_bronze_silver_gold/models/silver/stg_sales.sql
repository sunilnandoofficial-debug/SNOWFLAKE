with source_data as (
    select
        nullif(trim(sale_id), '') as sale_id,
        nullif(trim(customer_id), '') as customer_id,
        nullif(trim(product_id), '') as product_id,
        try_to_date(sale_date) as sale_date,
        try_to_number(quantity) as quantity,
        try_to_decimal(unit_price, 12, 2) as unit_price,
        coalesce(try_to_decimal(discount_amount, 12, 2), 0) as discount_amount,
        upper(nullif(trim(currency_code), '')) as currency_code,
        try_to_timestamp_ntz(updated_at) as updated_at
    from {{ ref('brz_sales') }}
),
ranked as (
    select *,
        row_number() over (
            partition by sale_id
            order by updated_at desc nulls last
        ) as row_num
    from source_data
    where sale_id is not null
)
select
    sale_id, customer_id, product_id, sale_date, quantity,
    unit_price, discount_amount, currency_code, updated_at
from ranked
where row_num = 1
