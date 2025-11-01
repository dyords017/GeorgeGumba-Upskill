-- DDL/create_tables.sql
-- Schema: staging and analytics
CREATE SCHEMA IF NOT EXISTS staging;
CREATE SCHEMA IF NOT EXISTS analytics;

-- Dim Date
CREATE TABLE IF NOT EXISTS analytics.dim_date (
  date_key DATE PRIMARY KEY,
  year INTEGER NOT NULL,
  month INTEGER NOT NULL,
  day INTEGER NOT NULL,
  quarter INTEGER NOT NULL,
  is_weekend BOOLEAN NOT NULL
);

-- Dim Product
CREATE TABLE IF NOT EXISTS analytics.dim_product (
  product_id SERIAL PRIMARY KEY,
  sku VARCHAR(100) UNIQUE,
  name TEXT,
  category VARCHAR(100),
  list_price NUMERIC(12,2),
  launch_date DATE
);

-- Dim Customer SCD Type 2
CREATE TABLE IF NOT EXISTS analytics.dim_customer_scd2 (
  customer_sk BIGSERIAL PRIMARY KEY,
  source_customer_id VARCHAR(100) NOT NULL,
  full_name TEXT,
  email TEXT,
  signup_date DATE,
  country VARCHAR(100),
  current_tier VARCHAR(50),
  valid_from DATE NOT NULL,
  valid_to DATE NOT NULL,
  is_current BOOLEAN NOT NULL DEFAULT true,
  UNIQUE (source_customer_id, valid_from)
);

-- Fact Order
CREATE TABLE IF NOT EXISTS analytics.fact_order (
  order_id BIGINT PRIMARY KEY,
  order_date DATE NOT NULL,
  order_date_key DATE NOT NULL,
  customer_sk BIGINT NOT NULL,
  channel VARCHAR(50),
  order_total NUMERIC(14,2),
  FOREIGN KEY (customer_sk) REFERENCES analytics.dim_customer_scd2(customer_sk)
);

-- Fact Order Item
CREATE TABLE IF NOT EXISTS analytics.fact_order_item (
  order_item_id BIGINT PRIMARY KEY,
  order_id BIGINT NOT NULL,
  product_id INTEGER,
  sku VARCHAR(100),
  quantity INTEGER,
  unit_price NUMERIC(12,2),
  discount NUMERIC(12,2),
  line_total NUMERIC(14,2),
  FOREIGN KEY (order_id) REFERENCES analytics.fact_order(order_id)
);

-- Staging tables (raw imports)
CREATE TABLE IF NOT EXISTS staging.customers_raw (
  source_customer_id VARCHAR(100),
  full_name TEXT,
  email TEXT,
  signup_date DATE,
  country VARCHAR(100),
  current_tier VARCHAR(50)
);

CREATE TABLE IF NOT EXISTS staging.products_raw (
  sku VARCHAR(100),
  name TEXT,
  category VARCHAR(100),
  list_price NUMERIC(12,2),
  launch_date DATE
);

CREATE TABLE IF NOT EXISTS staging.orders_raw (
  order_id BIGINT,
  order_date DATE,
  customer_source_id VARCHAR(100),
  channel VARCHAR(50),
  order_total NUMERIC(14,2)
);

CREATE TABLE IF NOT EXISTS staging.order_items_raw (
  order_item_id BIGINT,
  order_id BIGINT,
  sku VARCHAR(100),
  quantity INTEGER,
  unit_price NUMERIC(12,2),
  discount NUMERIC(12,2)
);

CREATE TABLE IF NOT EXISTS staging.payments_raw (
  payment_id BIGINT,
  order_id BIGINT,
  payment_method VARCHAR(50),
  paid_amount NUMERIC(14,2),
  paid_date DATE
);

CREATE TABLE IF NOT EXISTS staging.catalog_changes_raw (
  sku VARCHAR(100),
  effective_from DATE,
  effective_to DATE,
  price NUMERIC(12,2),
  reason TEXT
);
