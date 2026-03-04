## Professional Case Study: End-to-End Retail Data Architecture 🛒📊

This repository features a complete SQL-based data infrastructure for a modern retail ecosystem. It covers the entire journey from a high-performance MySQL OLTP transactional database to a structured BigQuery Staging environment for cloud analytics.

###📌 Project Overview
The goal is to model a robust retail environment where customers, products, and employees interact across multiple channels. The architecture ensures transactional integrity while preparing data for advanced ELT/ETL processes in the cloud.

###📋 Technical Modules

####1. Relational Database Design (OLTP)

Normalization: Implements a 3NF structure across core entities like category, product, customer, and employee.

Referential Integrity: Uses strict FOREIGN KEY constraints with CASCADE and RESTRICT policies.

Business Rules: Includes CHECK constraints to prevent negative values in prices, quantities, and taxes.

####2. Omnichannel Transactional Flow

Sales Engine: A dual-table approach (sales_order and sales_order_line) to support complex multi-item transactions.

Channel Mapping: Native support for both IN_STORE and ONLINE sales channels.

Payment Integration: Models multiple methods including APPLE_PAY, GOOGLE_PAY, CARD, and CASH.

####3. Data Automation & Simulation

Synthetic Data Generation: A robust generate_orders stored procedure that simulates realistic historical data.

Dynamic Logic: Automatically calculates VAT (23%), random discounts, and totals during the simulation.

Performance: Strategic indexing on date and ID columns to optimize analytical query speed.

####4. Cloud Data Warehousing (BigQuery)
Staging Layer: Dedicated schema (retail_stg_raw) designed for high-volume ingestion in Google BigQuery.

Data Lineage: Includes metadata columns like ingestion_ts, source_system, and batch_id for full traceability.

###🛠️ Tech Stack
Databases: MySQL 8.0 & Google BigQuery.

Engine: InnoDB for ACID compliance.

Features: Stored Procedures, Advanced Indexing, Relational Modeling.

###🚀 How to Use
1. Deploy Schema: Run the Retail_database.sql script to build the tables and relationships.

2. Generate Data: Populate the database with 200+ simulated transactions:

CALL generate_orders(200);

3. Analyze: Use the included aggregation queries to track monthly revenue trends.
