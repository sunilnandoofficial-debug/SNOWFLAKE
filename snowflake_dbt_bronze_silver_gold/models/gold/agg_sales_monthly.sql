select
    sale_month,
    currency_code,
    count(*) as transaction_count,
    count(distinct customer_id) as distinct_customers,
    sum(quantity) as units_sold,
    sum(gross_sales_amount) as gross_sales_amount,
    sum(discount_amount) as discount_amount,
    sum(net_sales_amount) as net_sales_amount,
    sum(estimated_cost_amount) as estimated_cost_amount,
    sum(estimated_margin_amount) as estimated_margin_amount
from {{ ref('fct_sales') }}
group by sale_month, currency_code
