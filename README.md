Professional Case Study: End-to-End Retail Data Architecture 🛒📊
This repository contains a comprehensive SQL-based infrastructure for a modern retail ecosystem. It spans from a high-performance OLTP (On-line Transactional Processing) MySQL database to a structured Data Warehouse Staging (BigQuery) environment, demonstrating expertise in relational modeling, data integrity, and scalable architecture.

📌 Project Overview
The objective of this project is to model a real-world retail environment where customers, products, and employees interact across multiple channels. The architecture is designed to handle complex transactional flows while ensuring data lineage and preparation for advanced ELT/ETL processes in the cloud.

📋 Technical Modules
1. Relational Database Design (OLTP)
Normalization: Implements a 3NF structure across core entities including category, product, customer, store, and employee.

Referential Integrity: Utilizes strict FOREIGN KEY constraints with CASCADE and RESTRICT policies to prevent orphaned records in sales data.

Business Logic Enforcement: Includes CHECK constraints to ensure financial accuracy for quantities, unit prices, and tax amounts.

2. Omnichannel Transactional Flow
Sales Engine: Features a dual-table approach (sales_order and sales_order_line) to support multi-item transactions.

Channel Optimization: Supports both IN_STORE and ONLINE sales, mapping store-specific data to physical locations while allowing for direct-to-consumer digital orders.

Payment Integration: Models various payment methods, including modern digital wallets like APPLE_PAY and GOOGLE_PAY alongside traditional CARD and CASH options.

3. Data Automation & Simulation
Synthetic Data Generation: A robust generate_orders stored procedure creates realistic historical data by simulating customer behavior.

Dynamic Calculations: Automatically computes VAT (23%), randomized discounts (up to 15%), and total order amounts to populate the database with high-fidelity test data.

Performance Indexing: Strategic use of B-Tree indexes on date and ID columns to optimize query performance for analytical reporting.

4. Data Warehousing & Cloud Staging
BigQuery Integration: Defines a staging layer (retail_stg_raw) designed for high-volume ingestion in Google BigQuery.

Auditability & Lineage: Every staging table includes metadata columns such as ingestion_ts, source_system, and batch_id to ensure 100% traceability during the data journey.

🛠️ Tech Stack
Language: SQL (MySQL 8.0 & Google BigQuery dialects).

Engine: InnoDB (for ACID compliance and row-level locking).

Concepts: Stored Procedures, Advanced Indexing, Relational Modeling, Data Lineage.

🚀 How to Use
Deploy the Schema: Execute the Retail_database.sql script in your MySQL environment to build the tables and relationships.

Populate the Database: Run the built-in procedure to generate a custom volume of data:

CALL generate_orders(200); -- Generates 200 orders with associated lines and payments

Run Analytics: Use the provided aggregation queries to view monthly revenue trends or product performance.
