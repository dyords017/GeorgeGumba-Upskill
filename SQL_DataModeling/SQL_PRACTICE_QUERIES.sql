
-- SQL_Practice_Queries.sql
-- 1 Simple checks
SELECT 'dim_customer_scd2' AS table_name, COUNT(*) FROM analytics.dim_customer_scd2;
SELECT 'fact_order' AS table_name, COUNT(*) FROM analytics.fact_order;
SELECT 'fact_order_item' AS table_name, COUNT(*) FROM analytics.fact_order_item;

-- 2 Referential integrity check
SELECT COUNT(*) AS orphan_orders
FROM analytics.fact_order o
LEFT JOIN analytics.dim_customer_scd2 c ON o.customer_sk = c.customer_sk
WHERE c.customer_sk IS NULL;

-- 3 Basic KPI daily revenue
SELECT order_date, SUM(order_total) AS revenue
FROM analytics.fact_order
GROUP BY order_date
ORDER BY order_date DESC
LIMIT 30;

-- 4 Top 10 customers by revenue
SELECT d.source_customer_id, d.full_name, SUM(f.order_total) AS total_revenue
FROM analytics.fact_order f
JOIN analytics.dim_customer_scd2 d ON f.customer_sk = d.customer_sk
GROUP BY d.source_customer_id, d.full_name
ORDER BY total_revenue DESC
LIMIT 10;

-- 5 30 day rolling revenue per customer using window
SELECT customer_sk, order_date,
  SUM(order_total) OVER (
    PARTITION BY customer_sk
    ORDER BY order_date
    RANGE BETWEEN INTERVAL '29 days' PRECEDING AND CURRENT ROW
  ) AS revenue_30d
FROM analytics.fact_order
ORDER BY customer_sk, order_date;

-- 6 Cohort analysis template by signup month and first purchase month
WITH first_order AS (
  SELECT customer_sk, MIN(order_date) AS first_order_date
  FROM analytics.fact_order
  GROUP BY customer_sk
),
cust_signup AS (
  SELECT customer_sk, signup_date
  FROM analytics.dim_customer_scd2
  WHERE is_current = true
)
SELECT date_trunc('month', c.signup_date) AS signup_month,
       date_trunc('month', f.first_order_date) AS first_purchase_month,
       COUNT(*) AS customers
FROM cust_signup c
LEFT JOIN first_order f USING (customer_sk)
GROUP BY 1,2
ORDER BY 1,2;

-- 7 SCD Type 2 change history for a customer
SELECT customer_sk, source_customer_id, full_name, current_tier, valid_from, valid_to, is_current
FROM analytics.dim_customer_scd2
WHERE source_customer_id = 'CUST-001'
ORDER BY valid_from DESC;

-- 8 Materialized view example for daily revenue (create as needed)
-- CREATE MATERIALIZED VIEW analytics.mv_daily_revenue AS
-- SELECT order_date, SUM(order_total) AS revenue
-- FROM analytics.fact_order
-- GROUP BY order_date;

-- 9 Partitioning suggestion query (Postgres example for range partitioning)
-- This block is a template; test in a safe environment before applying to production
-- CREATE TABLE analytics.fact_order_partitioned (
--   order_id BIGINT,
--   order_date DATE,
--   order_date_key DATE,
--   customer_sk BIGINT,
--   channel VARCHAR(50),
--   order_total NUMERIC(14,2)
-- ) PARTITION BY RANGE (order_date);
--
-- CREATE TABLE analytics.fact_order_2024 PARTITION OF analytics.fact_order_partitioned
-- FOR VALUES FROM ('2024-01-01') TO ('2025-01-01');

-- 10 Data quality assertions examples
-- Uniqueness of email among current customers
SELECT email, COUNT(*) FROM analytics.dim_customer_scd2 WHERE is_current = true GROUP BY email HAVING COUNT(*) > 1;

-- Orders with negative totals
SELECT order_id, order_total FROM analytics.fact_order WHERE order_total < 0;

-- 11 Advanced window example Rank customers by lifetime revenue per country
SELECT country, source_customer_id, total_revenue,
  RANK() OVER (PARTITION BY country ORDER BY total_revenue DESC) AS country_rank
FROM (
  SELECT d.country, d.source_customer_id, SUM(f.order_total) AS total_revenue
  FROM analytics.fact_order f
  JOIN analytics.dim_customer_scd2 d ON f.customer_sk = d.customer_sk
  GROUP BY d.country, d.source_customer_id
) t
ORDER BY country, country_rank;

-- 12 SCD Type 2 merge template for upsert into dim_customer_scd2
-- This template demonstrates logic; adapt to your ETL orchestration system
-- WITH incoming AS (
--   SELECT source_customer_id, full_name, email, signup_date, country, current_tier FROM staging.customers_raw
-- ),
-- changes AS (
--   SELECT i.*, d.customer_sk, d.full_name AS existing_name, d.email AS existing_email, d.current_tier AS existing_tier
--   FROM incoming i
--   LEFT JOIN analytics.dim_customer_scd2 d ON d.source_customer_id = i.source_customer_id AND d.is_current = true
-- )
-- -- expire existing
-- UPDATE analytics.dim_customer_scd2 d
-- SET valid_to = CURRENT_DATE - 1, is_current = false
-- FROM changes c
-- WHERE d.customer_sk = c.customer_sk
--   AND (COALESCE(d.full_name,'') <> COALESCE(c.full_name,'') OR COALESCE(d.email,'') <> COALESCE(c.email,'') OR COALESCE(d.current_tier,'') <> COALESCE(c.current_tier));
--
-- -- insert new current rows
-- INSERT INTO analytics.dim_customer_scd2 (source_customer_id, full_name, email, signup_date, country, current_tier, valid_from, valid_to, is_current)
-- SELECT source_customer_id, full_name, email, signup_date, country, current_tier, CURRENT_DATE, '9999-12-31'::date, true
-- FROM incoming i
-- WHERE NOT EXISTS (
--   SELECT 1 FROM analytics.dim_customer_scd2 d WHERE d.source_customer_id = i.source_customer_id AND d.is_current = true AND
--   d.full_name = i.full_name AND d.email = i.email AND d.current_tier = i.current_tier
-- );
