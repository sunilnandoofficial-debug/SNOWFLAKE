with source_data as (
    select
        nullif(trim(customer_id), '') as customer_id,
        nullif(trim(customer_name), '') as customer_name,
        upper(nullif(trim(country), '')) as country_code,
        try_to_timestamp_ntz(updated_at) as updated_at
    from {{ ref('brz_customers') }}
),
ranked as (
    select *,
        row_number() over (
            partition by customer_id
            order by updated_at desc nulls last
        ) as row_num
    from source_data
    where customer_id is not null
)
select customer_id, customer_name, country_code, updated_at
from ranked
where row_num = 1
