-- TESTS/data_quality_checks.sql
-- 1 row counts
SELECT 'dim_customer_scd2' AS table_name, COUNT(*) FROM analytics.dim_customer_scd2;
SELECT 'dim_product' AS table_name, COUNT(*) FROM analytics.dim_product;
SELECT 'fact_order' AS table_name, COUNT(*) FROM analytics.fact_order;
SELECT 'fact_order_item' AS table_name, COUNT(*) FROM analytics.fact_order_item;

-- 2 uniqueness checks
SELECT 'duplicate_emails' AS check, COUNT(*) FROM (
  SELECT email FROM analytics.dim_customer_scd2 WHERE is_current = true GROUP BY email HAVING COUNT(*) > 1
) t;

-- 3 FK integrity
SELECT COUNT(*) AS orphan_orders FROM analytics.fact_order o LEFT JOIN analytics.dim_customer_scd2 c ON o.customer_sk = c.customer_sk WHERE c.customer_sk IS NULL;
SELECT COUNT(*) AS orphan_order_items FROM analytics.fact_order_item oi LEFT JOIN analytics.fact_order o ON oi.order_id = o.order_id WHERE o.order_id IS NULL;
