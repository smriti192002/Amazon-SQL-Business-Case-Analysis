# Amazon-SQL-Business-Case-Analysis

## 🚀 Project Overview

In this project, I conducted a comprehensive analysis of a dataset containing over **20,000 sales records** from an **Amazon-like e-commerce platform**, focusing on deriving actionable business insights through advanced **SQL (MYSQL)** queries.

The analysis covers **customer behavior, product performance, sales trends**, and **inventory management**, addressing real-world business challenges faced by e-commerce companies. Throughout the project, I tackled key analytical areas, including:  
- **Revenue analysis** to identify top-performing products and categories.  
- **Customer segmentation** to highlight high-value customers and purchasing patterns.  
- **Inventory optimization** to detect stock level issues and support supply chain decisions.

Additionally, the project emphasizes **data cleaning, handling missing/null values**, and structuring queries to deliver precise, meaningful insights.

## **Database Setup & Design**

### **Schema Structure**

```sql
CREATE TABLE category
(
  category_id	INT PRIMARY KEY,
  category_name VARCHAR(20)
);

-- customers TABLE
CREATE TABLE customers
(
  customer_id INT PRIMARY KEY,	
  first_name	VARCHAR(20),
  last_name	VARCHAR(20),
  state VARCHAR(20),
  address VARCHAR(5) DEFAULT ('xxxx')
);

-- sellers TABLE
CREATE TABLE sellers
(
  seller_id INT PRIMARY KEY,
  seller_name	VARCHAR(25),
  origin VARCHAR(15)
);

-- products table
  CREATE TABLE products
  (
  product_id INT PRIMARY KEY,	
  product_name VARCHAR(50),	
  price	FLOAT,
  cogs	FLOAT,
  category_id INT, -- FK 
  CONSTRAINT product_fk_category FOREIGN KEY(category_id) REFERENCES category(category_id)
);

-- orders
CREATE TABLE orders
(
  order_id INT PRIMARY KEY, 	
  order_date	DATE,
  customer_id	INT, -- FK
  seller_id INT, -- FK 
  order_status VARCHAR(15),
  CONSTRAINT orders_fk_customers FOREIGN KEY (customer_id) REFERENCES customers(customer_id),
  CONSTRAINT orders_fk_sellers FOREIGN KEY (seller_id) REFERENCES sellers(seller_id)
);

CREATE TABLE order_items
(
  order_item_id INT PRIMARY KEY,
  order_id INT,	-- FK 
  product_id INT, -- FK
  quantity INT,	
  price_per_unit FLOAT,
  CONSTRAINT order_items_fk_orders FOREIGN KEY (order_id) REFERENCES orders(order_id),
  CONSTRAINT order_items_fk_products FOREIGN KEY (product_id) REFERENCES products(product_id)
);

-- payment TABLE
CREATE TABLE payments
(
  payment_id	
  INT PRIMARY KEY,
  order_id INT, -- FK 	
  payment_date DATE,
  payment_status VARCHAR(20),
  CONSTRAINT payments_fk_orders FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE shippings
(
  shipping_id	INT PRIMARY KEY,
  order_id	INT, -- FK
  shipping_date DATE,	
  return_date	 DATE,
  shipping_providers	VARCHAR(15),
  delivery_status VARCHAR(15),
  CONSTRAINT shippings_fk_orders FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE inventory
(
  inventory_id INT PRIMARY KEY,
  product_id INT, -- FK
  stock INT,
  warehouse_id INT,
  last_stock_date DATE,
  CONSTRAINT inventory_fk_products FOREIGN KEY (product_id) REFERENCES products(product_id)
  );
```

---

## **Task: Data Cleaning**

I cleaned the dataset by:
- **Removing duplicates**: Duplicates in the customer and order tables were identified and removed.
- **Handling missing values**: Null values in critical fields (e.g., customer address, payment status) were either filled with default values or handled using appropriate methods.

---

## **Handling Null Values**

Null values were handled based on their context:
- **Customer addresses**: Missing addresses were assigned default placeholder values.
- **Payment statuses**: Orders with null payment statuses were categorized as “Pending.”
- **Shipping information**: Null return dates were left as is, as not all shipments are returned.

---

## **Objective**

The primary objective of this project is to showcase SQL proficiency through complex queries that address real-world e-commerce business challenges. The analysis covers various aspects of e-commerce operations, including:
- Customer behavior
- Sales trends
- Inventory management
- Payment and shipping analysis
- Forecasting and product performance
  

## **Identifying Business Problems**

Key business problems identified:
1. Low product availability due to inconsistent restocking.
2. High return rates for specific product categories.
3. Significant delays in shipments and inconsistencies in delivery times.
4. High customer acquisition costs with a low customer retention rate.

## 🎯 **Learning Outcomes**

Through this project, I gained hands-on experience and developed key skills essential for solving real-world business problems with data. Specifically, I learned how to:

- **Design and implement a fully normalized relational database schema** aligned with business needs and data integrity.
- **Clean and preprocess real-world, messy datasets** to ensure data quality and readiness for analysis.
- Apply **advanced SQL techniques**, including **window functions, subqueries, CTEs, and complex joins**, to extract actionable insights.
- Conduct **comprehensive business analysis using SQL**, addressing critical areas such as customer behavior, sales performance, and inventory management.
- **Optimize query performance** to handle large datasets efficiently and ensure scalable analytical solutions.

---

## ✅ **Conclusion**

This project demonstrates my ability to leverage **advanced SQL techniques to solve real-world e-commerce business challenges** through structured, insight-driven analysis.  

From **improving customer retention** and **enhancing product profitability** to **optimizing inventory and logistics operations**, the analysis provides **practical and data-backed solutions** to common operational challenges faced by online retailers.  

By completing this project, I have deepened my understanding of how **SQL can be used as a powerful tool for business intelligence**, enabling organizations to make **data-informed strategic decisions** and improve operational efficiency.

---
