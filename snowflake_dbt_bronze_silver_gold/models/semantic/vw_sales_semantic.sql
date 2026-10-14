-- Governed BI-facing view. Keep metric definitions centralized here or in the
-- native Snowflake Semantic View; avoid redefining them independently in each BI report.
select
    f.sale_id,
    f.sale_date,
    f.sale_month,
    f.customer_id,
    c.customer_name,
    c.country_code,
    f.product_id,
    p.product_name,
    p.product_category,
    f.quantity,
    f.currency_code,
    f.gross_sales_amount,
    f.discount_amount,
    f.net_sales_amount,
    f.estimated_cost_amount,
    f.estimated_margin_amount
from {{ ref('fct_sales') }} f
join {{ ref('dim_customer') }} c on f.customer_id = c.customer_id
join {{ ref('dim_product') }} p on f.product_id = p.product_id
