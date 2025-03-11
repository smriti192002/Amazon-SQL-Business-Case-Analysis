create database amazon_db;
USE amazon_db;
-- Amazon Project Advance SQl -- 
-- category table -- 
CREATE TABLE category
(
category_id	INT PRIMARY KEY,
category_name VARCHAR(20)
);

-- customer table 
CREATE TABLE customers
(
customer_id INT PRIMARY KEY , 
first_name	VARCHAR(20),
last_name VARCHAR(20),
state VARCHAR(20),
address VARCHAR(20) DEFAULT('xxxx')
);

-- seller table 
CREATE TABLE sellers 
(
seller_id INT PRIMARY KEY, 
seller_name VARCHAR(25), 
origin VARCHAR(10)
);

-- product table 
CREATE TABLE products 
(
product_id INT PRIMARY KEY, 
product_name VARCHAR(50), 
price FLOAT, 
cogs FLOAT, 
category_id INT, -- FK
CONSTRAINT product_fk_category FOREIGN KEY (category_id) REFERENCES category(category_id)
);

-- orders table 
CREATE TABLE orders
(
order_id INT PRIMARY KEY, 
order_date DATE,
customer_id	 INT , -- FK 
seller_id INT, -- FK
order_status VARCHAR(15) ,
CONSTRAINT orders_fk_customers FOREIGN KEY(customer_id) REFERENCES customers(customer_id),
CONSTRAINT orders_fk_sellers FOREIGN KEY(seller_id) REFERENCES sellers(seller_id)
);

-- orders item table 
CREATE TABLE orders_items
(
order_item_id INT PRIMARY KEY,
order_id INT, -- FK
product_id	INT,  -- FK
quantity INT ,
price_per_unit FLOAT,
CONSTRAINT orders_items_fk_orders FOREIGN KEY(order_id) REFERENCES orders(order_id),
CONSTRAINT orders_items_fk_products FOREIGN KEY(product_id) REFERENCES products(product_id) 
);

-- payments table 
CREATE TABLE payments
(
payment_id	INT PRIMARY KEY,
order_id INT , -- FK
payment_date DATE,
payment_status VARCHAR(20),
CONSTRAINT payments_fk_orders FOREIGN KEY(order_iD) REFERENCES orders(order_id) 
);

-- shipping table 
CREATE TABLE shipping
(
shipping_id	INT PRIMARY KEY, 
order_id INT, -- FK
shipping_date DATE,
return_date	DATE,
shipping_providers	VARCHAR(15),
delivery_status VARCHAR(15), 
CONSTRAINT shipping_fk_orders FOREIGN KEY(order_iD) REFERENCES orders(order_id) 
);

-- inventory table 
CREATE TABLE inventory
(
inventory_id INT PRIMARY KEY,
product_id INT, -- FK
stock INT , 
warehouse_id INT ,
last_stock_date DATE, 
CONSTRAINT inventory_fk_products FOREIGN KEY(product_id) REFERENCES products(product_id) 
);


