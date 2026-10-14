-- OPTIONAL native Snowflake Semantic View example.
-- Run only after GOLD.FCT_SALES, GOLD.DIM_CUSTOMER and GOLD.DIM_PRODUCT exist.
-- Semantic View syntax/features can vary by Snowflake release/account; validate in your account.
-- The dbt view `DBT_DEMO.GOLD.VW_SALES_SEMANTIC` is the portable fallback.
--
-- Adjust object names and metric semantics to match your governed business glossary.
CREATE OR REPLACE SEMANTIC VIEW DBT_DEMO.SEMANTIC.SALES_SEMANTIC
  TABLES (
    sales AS DBT_DEMO.GOLD.FCT_SALES
      PRIMARY KEY (SALE_ID)
      WITH SYNONYMS = ('transactions', 'orders')
      COMMENT = 'One row per sale transaction',
    customers AS DBT_DEMO.GOLD.DIM_CUSTOMER
      PRIMARY KEY (CUSTOMER_ID)
      WITH SYNONYMS = ('clients', 'accounts'),
    products AS DBT_DEMO.GOLD.DIM_PRODUCT
      PRIMARY KEY (PRODUCT_ID)
      WITH SYNONYMS = ('items', 'services')
  )
  RELATIONSHIPS (
    sales_to_customers AS sales (CUSTOMER_ID) REFERENCES customers,
    sales_to_products AS sales (PRODUCT_ID) REFERENCES products
  )
  FACTS (
    sales.quantity AS quantity,
    sales.gross_sales_amount AS gross_sales_amount,
    sales.discount_amount AS discount_amount,
    sales.net_sales_amount AS net_sales_amount,
    sales.estimated_cost_amount AS estimated_cost_amount,
    sales.estimated_margin_amount AS estimated_margin_amount
  )
  DIMENSIONS (
    sales.sale_date AS sale_date,
    sales.sale_month AS sale_month,
    sales.currency_code AS currency_code,
    customers.customer_name AS customer_name,
    customers.country_code AS country_code,
    products.product_name AS product_name,
    products.product_category AS product_category
  )
  METRICS (
    sales.transaction_count AS COUNT(sales.SALE_ID),
    sales.total_net_sales AS SUM(sales.NET_SALES_AMOUNT),
    sales.total_gross_sales AS SUM(sales.GROSS_SALES_AMOUNT),
    sales.total_discount AS SUM(sales.DISCOUNT_AMOUNT),
    sales.total_units AS SUM(sales.QUANTITY)
  )
  COMMENT = 'Governed semantic model for sales analytics';
