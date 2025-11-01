# SQL Data Modeling — Portfolio Project

**Owner:** George  
**Goal:** Build a repeatable, well-documented SQL data modeling workflow (star-schema sales example) with DDL, ETL examples, data quality tests, performance notes, and a portfolio-ready README and diagrams.

Project Structure
- DDL/: table creation and seed data
- ETL/: staging and transformation scripts
- TESTS/: automated SQL checks
- DIAGRAMS/: ER diagrams and notes
- Mock_Data.xlsx: sample datasets (customers, products, orders, order_items, payments, catalog_changes)
- SQL_Practice_Queries.sql: progressive queries and templates

Quick Start
1. Create a disposable Postgres database locally or in a sandbox.
2. Run `DDL/create_tables.sql`.
3. Load seed data from `DDL/seeds.sql` or import `Mock_Data.xlsx` into staging tables.
4. Run `ETL/staging_loads.sql` then `ETL/transforms.sql`.
5. Run tests in `TESTS/data_quality_checks.sql`.

Design Principles
- Start with a star schema for analytics: fact_order and fact_order_item with conformed dimensions (dim_customer, dim_product, dim_date).
- Use staging schema for raw imports and deterministic transformations.
- Implement SCD Type 2 for slowly changing customer attributes.
- Favor explicit keys and clear data lineage; keep transformations idempotent.
- Provide tests that assert row counts, uniqueness, and referential integrity.

Milestones
- Week 1 Initialize repository: README, Mock_Data.xlsx v0, DDL stub
- Week 2 Model design and ER diagram
- Week 3 Implement DDL and seeds
- Week 4 Build staging loads and basic transforms
- Week 5 Create summary marts and aggregate views
- Week 8 Implement SCD Type 2 for customer dimension
- Week 12 Final polish and portfolio release

Acceptance Criteria for This Repo
- SQL runs on Postgres without syntax errors
- Seed data loads and transformation queries produce expected row counts
- TESTS pass: uniqueness, FK integrity, nonempty critical tables
- README and DIAGRAMS provide clear onboarding for reviewers

Contact
- Owner: George — MIS and analytics architect
