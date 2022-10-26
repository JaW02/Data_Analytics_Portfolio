CREATE DATABASE IF NOT EXISTS olist_store;
USE olist_store;
-- CREATE TABLES

CREATE TABLE IF NOT EXISTS customers (
	customer_id VARCHAR(32) NOT NULL,
	customer_unique_id VARCHAR(32) NOT NULL,
	customer_zip_code_prefix VARCHAR(5) NOT NULL,
	customer_city  TINYTEXT,
	customer_state CHAR(2),
    PRIMARY KEY (customer_id),
    FOREIGN KEY (customer_zip_code_prefix) REFERENCES geolocation(geolocation_zip_code_prefix)
);

CREATE TABLE IF NOT EXISTS geolocation (
	geolocation_zip_code_prefix VARCHAR(5) NOT NULL,
    geolocation_lat DECIMAL(16, 14),
    geolocation_lng DECIMAL(16, 14),
    geolocation_city TINYTEXT,
    geolocation_state CHAR(2),
    PRIMARY KEY (geolocation_zip_code_prefix)
);

CREATE TABLE IF NOT EXISTS order_items(
	order_id VARCHAR(32) NOT NULL,
    order_item_id SMALLINT NOT NULL,
    product_id VARCHAR(32) NOT NULL,
    seller_id VARCHAR(32) NOT NULL,
    shipping_limit_date DATETIME,
    price FLOAT,
    freight_value FLOAT,
    PRIMARY KEY (order_id), 
    FOREIGN KEY (order_id) REFERENCES orders(order_id), 
    FOREIGN KEY (product_id) REFERENCES products(product_id) 
);

CREATE TABLE IF NOT EXISTS order_payments(
	order_id VARCHAR(32) NOT NULL,
    payment_sequential TINYINT,
    payment_type TINYTEXT,
    payment_installments TINYINT,
    payment_value FLOAT,
    PRIMARY KEY (order_id),
    FOREIGN KEY (order_id) REFERENCEs orders(order_id)
);

CREATE TABLE IF NOT EXISTS orders(
	order_id VARCHAR(32) NOT NULL,
    customer_id VARCHAR(32) NOT NULL,
    order_status TINYTEXT,
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME,
    PRIMARY KEY (order_id),
    FOREIGN KEY (customer_id) REFERENCES customers(customer_id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS products(
	product_id VARCHAR(32) NOT NULL,
    product_category_name TINYTEXT,
    product_name_length TINYINT,
    product_description_length SMALLINT,
    product_photos_qty TINYINT,
    product_weight_g MEDIUMINT,
    product_length_cm SMALLINT,
    product_height_cm SMALLINT,
    product_width_cm SMALLINT,
    PRIMARY KEY (product_id)
);
