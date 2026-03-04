-- 1) Create database
CREATE DATABASE IF NOT EXISTS retail_oltp
  DEFAULT CHARACTER SET utf8mb4
  DEFAULT COLLATE utf8mb4_0900_ai_ci;

USE retail_oltp;

-- 2) Master tables

CREATE TABLE category (
  category_id INT AUTO_INCREMENT PRIMARY KEY,
  category_name VARCHAR(100) NOT NULL,
  CONSTRAINT uq_category_name UNIQUE (category_name)
) ENGINE=InnoDB;

CREATE TABLE product (
  product_id INT AUTO_INCREMENT PRIMARY KEY,
  category_id INT NOT NULL,
  sku VARCHAR(50) NOT NULL,
  product_name VARCHAR(150) NOT NULL,
  brand VARCHAR(100) NULL,
  current_list_price DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  CONSTRAINT uq_product_sku UNIQUE (sku),
  CONSTRAINT fk_product_category
    FOREIGN KEY (category_id) REFERENCES category(category_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE customer (
  customer_id INT AUTO_INCREMENT PRIMARY KEY,
  email VARCHAR(150) NOT NULL,
  first_name VARCHAR(80) NOT NULL,
  last_name VARCHAR(80) NOT NULL,
  phone VARCHAR(30) NULL,
  created_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT uq_customer_email UNIQUE (email)
) ENGINE=InnoDB;

CREATE TABLE store (
  store_id INT AUTO_INCREMENT PRIMARY KEY,
  store_code VARCHAR(20) NOT NULL,
  store_name VARCHAR(150) NOT NULL,
  city VARCHAR(80) NOT NULL,
  country VARCHAR(80) NOT NULL,
  CONSTRAINT uq_store_code UNIQUE (store_code)
) ENGINE=InnoDB;

CREATE TABLE employee (
  employee_id INT AUTO_INCREMENT PRIMARY KEY,
  store_id INT NOT NULL,
  employee_code VARCHAR(20) NOT NULL,
  first_name VARCHAR(80) NOT NULL,
  last_name VARCHAR(80) NOT NULL,
  role VARCHAR(50) NOT NULL,
  CONSTRAINT uq_employee_code UNIQUE (employee_code),
  CONSTRAINT fk_employee_store
    FOREIGN KEY (store_id) REFERENCES store(store_id)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

-- 3) Transaction tables

CREATE TABLE sales_order (
  order_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_number VARCHAR(30) NOT NULL,
  customer_id INT NULL,
  store_id INT NULL,
  employee_id INT NULL,
  order_datetime DATETIME NOT NULL,
  channel ENUM('IN_STORE','ONLINE') NOT NULL,
  order_status ENUM('PAID','REFUNDED','CANCELLED') NOT NULL DEFAULT 'PAID',
  currency CHAR(3) NOT NULL DEFAULT 'EUR',
  CONSTRAINT uq_sales_order_number UNIQUE (order_number),

  CONSTRAINT fk_order_customer
    FOREIGN KEY (customer_id) REFERENCES customer(customer_id)
    ON UPDATE CASCADE ON DELETE SET NULL,

  CONSTRAINT fk_order_store
    FOREIGN KEY (store_id) REFERENCES store(store_id)
    ON UPDATE CASCADE ON DELETE SET NULL,

  CONSTRAINT fk_order_employee
    FOREIGN KEY (employee_id) REFERENCES employee(employee_id)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE sales_order_line (
  order_line_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT NOT NULL,
  product_id INT NOT NULL,
  quantity INT NOT NULL,
  unit_price DECIMAL(10,2) NOT NULL,
  discount_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,
  tax_amount DECIMAL(10,2) NOT NULL DEFAULT 0.00,

  CONSTRAINT fk_line_order
    FOREIGN KEY (order_id) REFERENCES sales_order(order_id)
    ON UPDATE CASCADE ON DELETE CASCADE,

  CONSTRAINT fk_line_product
    FOREIGN KEY (product_id) REFERENCES product(product_id)
    ON UPDATE CASCADE ON DELETE RESTRICT,

  CONSTRAINT chk_quantity_positive CHECK (quantity > 0),
  CONSTRAINT chk_unit_price_nonnegative CHECK (unit_price >= 0),
  CONSTRAINT chk_discount_nonnegative CHECK (discount_amount >= 0),
  CONSTRAINT chk_tax_nonnegative CHECK (tax_amount >= 0)
) ENGINE=InnoDB;

CREATE TABLE payment (
  payment_id BIGINT AUTO_INCREMENT PRIMARY KEY,
  order_id BIGINT NOT NULL,
  payment_datetime DATETIME NOT NULL,
  payment_method ENUM('CARD','CASH','GIFT_CARD','APPLE_PAY','GOOGLE_PAY') NOT NULL,
  amount DECIMAL(10,2) NOT NULL,

  CONSTRAINT fk_payment_order
    FOREIGN KEY (order_id) REFERENCES sales_order(order_id)
    ON UPDATE CASCADE ON DELETE CASCADE,

  CONSTRAINT chk_payment_amount_positive CHECK (amount > 0)
) ENGINE=InnoDB;

-- 4) Essential indexes for OLTP access patterns
CREATE INDEX idx_product_category ON product(category_id);
CREATE INDEX idx_employee_store ON employee(store_id);

CREATE INDEX idx_order_datetime ON sales_order(order_datetime);
CREATE INDEX idx_order_customer ON sales_order(customer_id);
CREATE INDEX idx_order_store ON sales_order(store_id);

CREATE INDEX idx_line_order ON sales_order_line(order_id);
CREATE INDEX idx_line_product ON sales_order_line(product_id);

CREATE INDEX idx_payment_order ON payment(order_id);
CREATE INDEX idx_payment_datetime ON payment(payment_datetime); 

INSERT INTO category (category_name) VALUES
('Electronics'),
('Home Appliances'),
('Clothing'),
('Sports & Outdoors'),
('Health & Beauty');

INSERT INTO product (category_id, sku, product_name, brand, current_list_price) VALUES
(1, 'ELEC-001', 'Smartphone X12', 'NovaTech', 699.00),
(1, 'ELEC-002', 'Wireless Headphones Pro', 'SoundMax', 149.00),
(1, 'ELEC-003', '4K Smart TV 55"', 'VisionPlus', 899.00),

(2, 'HOME-001', 'Air Fryer 5L', 'CookEase', 129.00),
(2, 'HOME-002', 'Robot Vacuum Cleaner', 'CleanBot', 349.00),

(3, 'CLOT-001', 'Men\'s Running Jacket', 'ActiveWear', 89.00),
(3, 'CLOT-002', 'Women\'s Yoga Leggings', 'FlexFit', 59.00),

(4, 'SPORT-001', 'Mountain Bike Helmet', 'TrailGuard', 79.00),
(4, 'SPORT-002', 'Adjustable Dumbbell Set', 'PowerLift', 199.00),

(5, 'HEAL-001', 'Electric Toothbrush', 'BrightSmile', 79.00),
(5, 'HEAL-002', 'Hair Dryer Pro 2000', 'StylePro', 59.00);

INSERT INTO store (store_code, store_name, city, country) VALUES
('DUB01', 'Dublin City Centre', 'Dublin', 'Ireland'),
('COR01', 'Cork Retail Park', 'Cork', 'Ireland'),
('GAL01', 'Galway Shopping Plaza', 'Galway', 'Ireland');

INSERT INTO employee (store_id, employee_code, first_name, last_name, role) VALUES
(1, 'EMP-DUB-001', 'Aoife', 'Murphy', 'Sales Associate'),
(1, 'EMP-DUB-002', 'Conor', 'Walsh', 'Store Manager'),

(2, 'EMP-COR-001', 'Siobhan', 'O\'Brien', 'Sales Associate'),
(2, 'EMP-COR-002', 'Liam', 'Fitzgerald', 'Store Manager'),

(3, 'EMP-GAL-001', 'Niamh', 'Kelly', 'Sales Associate'),
(3, 'EMP-GAL-002', 'Patrick', 'Doyle', 'Store Manager');

INSERT INTO customer (email, first_name, last_name, phone) VALUES
('john.smith@email.com', 'John', 'Smith', '0851234567'),
('sarah.connor@email.com', 'Sarah', 'Connor', '0862345678'),
('michael.brown@email.com', 'Michael', 'Brown', '0873456789'),
('emma.wilson@email.com', 'Emma', 'Wilson', '0859876543'),
('liam.oconnor@email.com', 'Liam', 'O\'Connor', '0868765432');

INSERT INTO sales_order
(order_number, customer_id, store_id, employee_id, order_datetime, channel, order_status, currency)
VALUES
('ORD-1001', 1, 1, 1, '2025-01-10 14:32:00', 'IN_STORE', 'PAID', 'EUR'),
('ORD-1002', 2, NULL, NULL, '2025-01-11 10:15:00', 'ONLINE', 'PAID', 'EUR'),
('ORD-1003', 3, 2, 3, '2025-01-12 16:45:00', 'IN_STORE', 'PAID', 'EUR'),
('ORD-1004', 4, NULL, NULL, '2025-01-13 09:20:00', 'ONLINE', 'PAID', 'EUR'),
('ORD-1005', 5, 3, 5, '2025-01-14 18:10:00', 'IN_STORE', 'REFUNDED', 'EUR');

INSERT INTO sales_order_line
(order_id, product_id, quantity, unit_price, discount_amount, tax_amount)
VALUES

-- Order 1 (In-store, Dublin)
(1, 1, 1, 699.00, 50.00, 120.00),
(1, 2, 1, 149.00, 0.00, 25.00),

-- Order 2 (Online)
(2, 4, 1, 129.00, 10.00, 22.00),
(2, 7, 2, 59.00, 0.00, 20.00),

-- Order 3 (Cork)
(3, 3, 1, 899.00, 100.00, 150.00),

-- Order 4 (Online)
(4, 10, 1, 79.00, 0.00, 14.00),
(4, 11, 1, 59.00, 5.00, 10.00),

-- Order 5 (Refunded)
(5, 8, 1, 79.00, 0.00, 14.00);

NSERT INTO payment
(order_id, payment_datetime, payment_method, amount)
VALUES
(1, '2025-01-10 14:35:00', 'CARD', 943.00),
(2, '2025-01-11 10:17:00', 'CARD', 278.00),
(3, '2025-01-12 16:50:00', 'CARD', 949.00),
(4, '2025-01-13 09:25:00', 'APPLE_PAY', 157.00),
(5, '2025-01-14 18:15:00', 'CARD', 93.00);

SET GLOBAL log_bin_trust_function_creators = 1;

DELIMITER $$

CREATE PROCEDURE generate_orders(IN order_count INT)
BEGIN
  DECLARE i INT DEFAULT 0;
  DECLARE rand_customer INT;
  DECLARE rand_store INT;
  DECLARE rand_employee INT;
  DECLARE rand_channel VARCHAR(20);
  DECLARE rand_order_id BIGINT;
  DECLARE rand_lines INT;
  DECLARE rand_product INT;
  DECLARE rand_qty INT;
  DECLARE rand_price DECIMAL(10,2);
  DECLARE rand_discount DECIMAL(10,2);
  DECLARE rand_tax DECIMAL(10,2);
  DECLARE rand_total DECIMAL(10,2);

  WHILE i < order_count DO

    -- Random selections
    SET rand_customer = FLOOR(1 + RAND() * (SELECT COUNT(*) FROM customer));
    SET rand_store = FLOOR(1 + RAND() * (SELECT COUNT(*) FROM store));
    SET rand_employee = FLOOR(1 + RAND() * (SELECT COUNT(*) FROM employee));

    IF RAND() > 0.4 THEN
      SET rand_channel = 'IN_STORE';
    ELSE
      SET rand_channel = 'ONLINE';
      SET rand_store = NULL;
      SET rand_employee = NULL;
    END IF;

    INSERT INTO sales_order
    (order_number, customer_id, store_id, employee_id, order_datetime, channel, order_status, currency)
    VALUES
    (
      CONCAT('ORD-AUTO-', LPAD(i+1000, 5, '0')),
      rand_customer,
      rand_store,
      rand_employee,
      DATE_ADD('2025-01-01', INTERVAL FLOOR(RAND()*90) DAY),
      rand_channel,
      'PAID',
      'EUR'
    );

    SET rand_order_id = LAST_INSERT_ID();

    -- Random 1–4 lines
    SET rand_lines = FLOOR(1 + RAND()*4);
    SET rand_total = 0;

    WHILE rand_lines > 0 DO
      SET rand_product = FLOOR(1 + RAND() * (SELECT COUNT(*) FROM product));
      SET rand_qty = FLOOR(1 + RAND()*3);

      SELECT current_list_price INTO rand_price
      FROM product WHERE product_id = rand_product;

      SET rand_discount = ROUND(rand_price * rand_qty * RAND() * 0.15, 2);
      SET rand_tax = ROUND((rand_price * rand_qty - rand_discount) * 0.23, 2);

      INSERT INTO sales_order_line
      (order_id, product_id, quantity, unit_price, discount_amount, tax_amount)
      VALUES
      (rand_order_id, rand_product, rand_qty, rand_price, rand_discount, rand_tax);

      SET rand_total = rand_total + (rand_price * rand_qty - rand_discount + rand_tax);

      SET rand_lines = rand_lines - 1;
    END WHILE;

    INSERT INTO payment
    (order_id, payment_datetime, payment_method, amount)
    VALUES
    (
      rand_order_id,
      NOW(),
      ELT(FLOOR(1 + RAND()*5),'CARD','CASH','GIFT_CARD','APPLE_PAY','GOOGLE_PAY'),
      rand_total
    );

    SET i = i + 1;

  END WHILE;

END$$

DELIMITER ;

CALL generate_orders(200);

SELECT COUNT(*) FROM sales_order;
SELECT COUNT(*) FROM sales_order_line;
SELECT COUNT(*) FROM payment;

SELECT 
  DATE_FORMAT(order_datetime, '%Y-%m') AS month,
  SUM(sol.quantity * sol.unit_price - sol.discount_amount + sol.tax_amount) AS revenue
FROM sales_order so
JOIN sales_order_line sol ON so.order_id = sol.order_id
GROUP BY month
ORDER BY month;

REATE SCHEMA IF NOT EXISTS `project-dbfd521c-244a-49ce-8c8.retail_stg_raw`
OPTIONS(location="EU");

CREATE SCHEMA IF NOT EXISTS `project-dbfd521c-244a-49ce-8c8.retail_stg`
OPTIONS(location="EU");

-- CATEGORY
CREATE TABLE IF NOT EXISTS `project-dbfd521c-244a-49ce-8c8.retail_stg_raw.stg_category` (
  category_id INT64,
  category_name STRING,
  ingestion_ts TIMESTAMP,
  source_system STRING,
  batch_id STRING
);

-- PRODUCT
CREATE TABLE IF NOT EXISTS `project-dbfd521c-244a-49ce-8c8.retail_stg_raw.stg_product` (
  product_id INT64,
  category_id INT64,
  sku STRING,
  product_name STRING,
  brand STRING,
  current_list_price NUMERIC,
  ingestion_ts TIMESTAMP,
  source_system STRING,
  batch_id STRING
);

-- CUSTOMER
CREATE TABLE IF NOT EXISTS `project-dbfd521c-244a-49ce-8c8.retail_stg_raw.stg_customer` (
  customer_id INT64,
  email STRING,
  first_name STRING,
  last_name STRING,
  phone STRING,
  created_at TIMESTAMP,
  ingestion_ts TIMESTAMP,
  source_system STRING,
  batch_id STRING
);

-- STORE
CREATE TABLE IF NOT EXISTS `project-dbfd521c-244a-49ce-8c8.retail_stg_raw.stg_store` (
  store_id INT64,
  store_code STRING,
  store_name STRING,
  city STRING,
  country STRING,
  ingestion_ts TIMESTAMP,
  source_system STRING,
  batch_id STRING
);

-- EMPLOYEE
CREATE TABLE IF NOT EXISTS `project-dbfd521c-244a-49ce-8c8.retail_stg_raw.stg_employee` (
  employee_id INT64,
  store_id INT64,
  employee_code STRING,
  first_name STRING,
  last_name STRING,
  role STRING,
  ingestion_ts TIMESTAMP,
  source_system STRING,
  batch_id STRING
);

-- SALES ORDER
CREATE TABLE IF NOT EXISTS `project-dbfd521c-244a-49ce-8c8.retail_stg_raw.stg_sales_order` (
  order_id INT64,
  order_number STRING,
  customer_id INT64,
  store_id INT64,
  employee_id INT64,
  order_datetime TIMESTAMP,
  channel STRING,
  order_status STRING,
  currency STRING,
  ingestion_ts TIMESTAMP,
  source_system STRING,
  batch_id STRING
);

-- SALES ORDER LINE
CREATE TABLE IF NOT EXISTS `project-dbfd521c-244a-49ce-8c8.retail_stg_raw.stg_sales_order_line` (
  order_line_id INT64,
  order_id INT64,
  product_id INT64,
  quantity INT64,
  unit_price NUMERIC,
  discount_amount NUMERIC,
  tax_amount NUMERIC,
  ingestion_ts TIMESTAMP,
  source_system STRING,
  batch_id STRING
);

-- PAYMENT
CREATE TABLE IF NOT EXISTS `project-dbfd521c-244a-49ce-8c8.retail_stg_raw.stg_payment` (
  payment_id INT64,
  order_id INT64,
  payment_datetime TIMESTAMP,
  payment_method STRING,
  amount NUMERIC,
  ingestion_ts TIMESTAMP,
  source_system STRING,
  batch_id STRING
);

