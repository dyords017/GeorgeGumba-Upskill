-- ETL/staging_loads.sql
-- Load products into dim_product if not present
INSERT INTO analytics.dim_product (sku, name, category, list_price, launch_date)
SELECT sku, name, category, list_price, launch_date
FROM staging.products_raw s
WHERE NOT EXISTS (SELECT 1 FROM analytics.dim_product d WHERE d.sku = s.sku);

-- Insert new customer SCD rows and handle current flag
-- Step 1: insert new current rows where no current exists
INSERT INTO analytics.dim_customer_scd2
  (source_customer_id, full_name, email, signup_date, country, current_tier, valid_from, valid_to, is_current)
SELECT s.source_customer_id, s.full_name, s.email, s.signup_date, s.country, s.current_tier,
       CURRENT_DATE, '9999-12-31'::date, true
FROM staging.customers_raw s
LEFT JOIN analytics.dim_customer_scd2 d ON d.source_customer_id = s.source_customer_id AND d.is_current = true
WHERE d.customer_sk IS NULL;

-- Step 2: expire changed rows where current differs
UPDATE analytics.dim_customer_scd2 d
SET valid_to = CURRENT_DATE - 1, is_current = false
FROM staging.customers_raw s
WHERE d.source_customer_id = s.source_customer_id
  AND d.is_current = true
  AND (COALESCE(d.full_name, '') <> COALESCE(s.full_name, '')
       OR COALESCE(d.email, '') <> COALESCE(s.email, '')
       OR COALESCE(d.current_tier, '') <> COALESCE(s.current_tier, ''));

-- Step 3: insert new current row for changed customers
INSERT INTO analytics.dim_customer_scd2
  (source_customer_id, full_name, email, signup_date, country, current_tier, valid_from, valid_to, is_current)
SELECT s.source_customer_id, s.full_name, s.email, s.signup_date, s.country, s.current_tier,
       CURRENT_DATE, '9999-12-31'::date, true
FROM staging.customers_raw s
WHERE EXISTS (
  SELECT 1 FROM analytics.dim_customer_scd2 d
  WHERE d.source_customer_id = s.source_customer_id AND d.is_current = false
    AND d.valid_to = CURRENT_DATE - 1
);

-- Load orders into fact_order with resolved customer_sk
INSERT INTO analytics.fact_order (order_id, order_date, order_date_key, customer_sk, channel, order_total)
SELECT o.order_id, o.order_date, o.order_date, d.customer_sk, o.channel, o.order_total
FROM staging.orders_raw o
LEFT JOIN analytics.dim_customer_scd2 d
  ON d.source_customer_id = o.customer_source_id AND d.is_current = true
WHERE NOT EXISTS (SELECT 1 FROM analytics.fact_order f WHERE f.order_id = o.order_id);

-- Load order items into fact_order_item and compute line_total
INSERT INTO analytics.fact_order_item (order_item_id, order_id, product_id, sku, quantity, unit_price, discount, line_total)
SELECT oi.order_item_id, oi.order_id, p.product_id, oi.sku, oi.quantity, oi.unit_price, COALESCE(oi.discount,0),
       (oi.quantity * oi.unit_price) - COALESCE(oi.discount,0)
FROM staging.order_items_raw oi
LEFT JOIN analytics.dim_product p ON p.sku = oi.sku
WHERE NOT EXISTS (SELECT 1 FROM analytics.fact_order_item fi WHERE fi.order_item_id = oi.order_item_id);
