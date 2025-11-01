
-- DDL/seeds.sql
INSERT INTO analytics.dim_date (date_key, year, month, day, quarter, is_weekend)
VALUES
  ('2025-01-01', 2025, 1, 1, 1, true)
ON CONFLICT (date_key) DO NOTHING;

INSERT INTO analytics.dim_product (sku, name, category, list_price, launch_date)
VALUES
  ('SKU-001', 'Alpha Widget', 'Widgets', 49.99, '2024-01-15')
ON CONFLICT (sku) DO NOTHING;

INSERT INTO staging.customers_raw (source_customer_id, full_name, email, signup_date, country, current_tier)
VALUES
  ('CUST-001', 'Aisha Khan', 'aisha.k@example.com', '2024-02-10', 'AE', 'gold')
ON CONFLICT DO NOTHING;

INSERT INTO staging.orders_raw (order_id, order_date, customer_source_id, channel, order_total)
VALUES
  (1001, '2024-03-01', 'CUST-001', 'web', 129.97)
ON CONFLICT DO NOTHING;

INSERT INTO staging.order_items_raw (order_item_id, order_id, sku, quantity, unit_price, discount)
VALUES
  (5001, 1001, 'SKU-001', 1, 49.99, 0),
  (5002, 1001, 'SKU-002', 2, 39.99, 0)
ON CONFLICT DO NOTHING;
