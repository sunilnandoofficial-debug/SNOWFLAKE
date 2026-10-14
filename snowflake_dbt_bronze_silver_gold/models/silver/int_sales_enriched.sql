-- One row per valid sale_id after deduplication. Orphan rows are excluded here;
-- in production, send them to a quarantine model/table and alert rather than silently dropping.
select
    s.sale_id,
    s.customer_id,
    c.customer_name,
    c.country_code,
    s.product_id,
    p.product_name,
    p.product_category,
    s.sale_date,
    s.quantity,
    s.unit_price,
    s.discount_amount,
    s.currency_code,
    (s.quantity * s.unit_price) as gross_sales_amount,
    (s.quantity * s.unit_price - s.discount_amount) as net_sales_amount,
    p.standard_cost * s.quantity as estimated_cost_amount,
    (s.quantity * s.unit_price - s.discount_amount - p.standard_cost * s.quantity) as estimated_margin_amount,
    s.updated_at
from {{ ref('stg_sales') }} s
inner join {{ ref('stg_customers') }} c
    on s.customer_id = c.customer_id
inner join {{ ref('stg_products') }} p
    on s.product_id = p.product_id
where s.sale_date is not null
  and s.quantity > 0
  and s.unit_price >= 0
  and s.discount_amount >= 0
  and (s.quantity * s.unit_price - s.discount_amount) >= 0
