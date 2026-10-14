-- Optional alternative to `dbt seed`. Run only if loading rows manually into RAW.
-- The sample pipeline points to dbt seed tables, not these RAW tables.
INSERT INTO DBT_DEMO.RAW.CUSTOMERS
  (CUSTOMER_ID, CUSTOMER_NAME, COUNTRY, UPDATED_AT, SOURCE_FILE, BATCH_ID)
VALUES
  ('C001','Acme Health','US','2026-09-01 10:00:00','customers_demo.csv','BATCH001'),
  ('C002','Northwind Care','US','2026-09-02 11:00:00','customers_demo.csv','BATCH001'),
  ('C003','Bluebird Services','GB','2026-09-03 12:00:00','customers_demo.csv','BATCH001');

INSERT INTO DBT_DEMO.RAW.PRODUCTS
  (PRODUCT_ID, PRODUCT_NAME, PRODUCT_CATEGORY, STANDARD_COST, SOURCE_FILE, BATCH_ID)
VALUES
  ('P001','Claims Platform','Software',120.00,'products_demo.csv','BATCH001'),
  ('P002','Analytics Service','Service',45.00,'products_demo.csv','BATCH001'),
  ('P003','Data Integration','Service',70.00,'products_demo.csv','BATCH001');

INSERT INTO DBT_DEMO.RAW.SALES
  (SALE_ID, CUSTOMER_ID, PRODUCT_ID, SALE_DATE, QUANTITY, UNIT_PRICE,
   DISCOUNT_AMOUNT, CURRENCY_CODE, UPDATED_AT, SOURCE_FILE, BATCH_ID)
VALUES
  ('S1001','C001','P001','2026-09-01','2','200.00','20.00','USD','2026-09-01 12:00:00','sales_demo.csv','BATCH001'),
  ('S1002','C002','P002','2026-09-02','5','80.00','0.00','USD','2026-09-02 12:00:00','sales_demo.csv','BATCH001'),
  ('S1003','C001','P003','2026-09-05','3','100.00','15.00','USD','2026-09-05 12:00:00','sales_demo.csv','BATCH001'),
  ('S1004','C003','P001','2026-09-10','1','250.00','10.00','GBP','2026-09-10 12:00:00','sales_demo.csv','BATCH001'),
  ('S1005','C002','P003','2026-09-15','4','90.00','20.00','USD','2026-09-15 12:00:00','sales_demo.csv','BATCH001');
