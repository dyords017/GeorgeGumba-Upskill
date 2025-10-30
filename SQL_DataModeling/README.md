# SQL Data Modeling for MIS Dashboards

This folder contains SQL scripts and Power BI assets focused on building scalable MIS dashboards using structured data and relational modeling. The goal is to demonstrate SQL proficiency, data modeling best practices, and integration with Power BI for real-world reporting.

## 🎯 Objectives
- Practice core SQL skills: SELECT, JOIN, GROUP BY, CTE
- Design a star schema for MIS reporting (e.g., fact table for bookings, dimension tables for teams and time)
- Build a Power BI dashboard using DirectQuery from SQL tables

## 📂 Contents
- `SQL_Practice_Queries.sql`: Sample queries for data extraction and transformation
- `PowerBI_SQL_Dashboard.pbix`: Power BI file connected to SQL backend
- `Mock_Data.xlsx`: Sample MIS data used for testing
- `README.md`: This documentation file

## 🧠 Skills Demonstrated
- SQL query optimization and logic structuring
- Fact/dimension table design for MIS use cases
- Power BI relationships, slicers, and dynamic visuals
- MIS metrics: cards booked per month, TL Code summaries, team performance

## 🛠️ Tools Used
- Microsoft SQL Server / SQLite (for local testing)
- Power BI Desktop
- Excel (for mock data generation)

## 📈 Sample Metrics
- Monthly booking volume by TL Code
- Team Lead performance summaries
- Reconciliation-ready exports for Finance

## 🚀 Next Steps
- Add stored procedures for automated refresh
- Integrate Python for hybrid dashboards
- Expand schema to include HR and Finance dimensions
