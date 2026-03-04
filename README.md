# 🛒 Retail-to-Cloud: SQL Data Engineering Case Study

---

## 📌 PROJECT OVERVIEW
This repository features a complete SQL-based data infrastructure for a modern retail ecosystem. It covers the entire journey from a high-performance **MySQL OLTP** transactional database to a structured **BigQuery Staging** environment for cloud analytics. The architecture manages complex omnichannel retail operations while ensuring data integrity and preparing for advanced **ELT/ETL** workflows.

---

## 📋 TECHNICAL MODULES

### 🔹 1. Relational Database Design (OLTP)
* **Normalization**: Implements a 3NF structure across core entities including `category`, `product`, `customer`, `store`, and `employee`.
* **Integrity**: Uses strict `FOREIGN KEY` constraints with `CASCADE` and `RESTRICT` policies to prevent orphaned records.
* **Business Logic**: Enforces `CHECK` constraints on quantities, unit prices, and tax amounts to ensure financial accuracy.

### 🔹 2. Omnichannel Transactional Flow
* **Sales Engine**: Features a dual-table approach (`sales_order` and `sales_order_line`) to support multi-item transactions.
* **Channel Optimization**: Supports both `IN_STORE` and `ONLINE` sales channels.
* **Payment Integration**: Models various payment methods, including `APPLE_PAY`, `GOOGLE_PAY`, `CARD`, `CASH`, and `GIFT_CARD`.

### 🔹 3. Data Automation (Stored Procedures)
* **Synthetic Generation**: Includes a `generate_orders` procedure to create realistic historical data by simulating customer behavior.
* **Dynamic Calculations**: Automatically computes 23% VAT, randomized discounts (up to 15%), and order totals during simulation.
* **Performance**: Strategic use of B-Tree indexes on date and ID columns to optimize query execution.

### 🔹 4. Cloud Data Warehousing (BigQuery)
* **Staging Layer**: Defines a staging schema (`retail_stg_raw`) designed for high-volume ingestion in Google BigQuery.
* **Traceability**: Includes audit metadata columns such as `ingestion_ts`, `source_system`, and `batch_id` to ensure full data lineage.

---

## 🛠️ TECH STACK
* **Databases**: MySQL 8.0 (InnoDB Engine) and Google BigQuery.
* **Automation**: SQL Stored Procedures.
* **Key Concepts**: ACID Compliance, Advanced Indexing, Relational Modeling, Data Lineage.

---

## 🚀 HOW TO USE

1. **Deploy Schema**: Execute the `Retail_database.sql` script in your MySQL environment.
2. **Generate Data**: Populate the database with 200 simulated transactions by running:
   ```sql
   CALL generate_orders(200);
3. **Analyze**: Run the provided aggregation queries to track monthly revenue trends or product performance.
