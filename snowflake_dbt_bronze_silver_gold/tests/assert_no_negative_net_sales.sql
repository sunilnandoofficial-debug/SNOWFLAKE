select sale_id, net_sales_amount
from {{ ref('fct_sales') }}
where net_sales_amount < 0
