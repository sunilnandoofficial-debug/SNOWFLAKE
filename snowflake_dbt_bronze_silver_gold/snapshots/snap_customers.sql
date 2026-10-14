{% snapshot snap_customers %}
{{
    config(
      target_schema='SNAPSHOTS',
      unique_key='customer_id',
      strategy='check',
      check_cols=['customer_name', 'country_code']
    )
}}
select customer_id, customer_name, country_code
from {{ ref('stg_customers') }}
{% endsnapshot %}
