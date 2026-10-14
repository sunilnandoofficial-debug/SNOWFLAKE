-- Grain: one row per sale_id. Amounts are stored in the source transaction currency;
-- do not aggregate across currencies until a governed FX conversion is applied.
select
    {{ dbt_utils.generate_surrogate_key(['sale_id']) }} as sales_key,
    sale_id,
    customer_id,
    product_id,
    sale_date,
    date_trunc('month', sale_date)::date as sale_month,
    quantity,
    unit_price,
    discount_amount,
    currency_code,
    gross_sales_amount,
    net_sales_amount,
    estimated_cost_amount,
    estimated_margin_amount,
    updated_at
from {{ ref('int_sales_enriched') }}
