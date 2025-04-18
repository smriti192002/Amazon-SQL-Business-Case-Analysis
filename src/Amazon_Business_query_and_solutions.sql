-- Bussiness Problem  -- 
/*
Business Problem 1:  
To help Amazon find out which products make the most money, I analyzed the top 10 best-selling products by total sales value.  
This helps Amazon focus on marketing and stocking the right products that customers love.  
By knowing which items sell the most, Amazon can keep them in stock, make better deals with suppliers, and suggest these products to more customers through ads and recommendations.  
This way, Amazon can increase sales, avoid running out of popular products, and keep customers happy.  

Ques - 1. Top Selling Products:  
Query the top 10 products by total sales value.  
*/

SELECT 
    product_name, 
    SUM(quantity) AS total_quantity, 
    ROUND(SUM(total_sale), 2) AS total_sales
FROM 
    orders_items oi
JOIN 
    products p 
ON 
    oi.product_id = p.product_id
GROUP BY 
    p.product_id
ORDER BY 
    total_quantity DESC
LIMIT 10;

/*
Business Problem 2:  
To help Amazon understand which product categories drive the most revenue, I analyzed total sales and percentage contribution by category.  
This helps Amazon focus marketing and inventory on high-demand categories, negotiate better supplier deals, and create targeted promotions.  
It also highlights low-performing categories to review for pricing, demand, or variety issues.  
Overall, this analysis supports better product strategies to increase revenue, avoid overstocking, and improve customer satisfaction.

Ques-2 Calculate total revenue generated by each product category.
Challenge: Include the percentage contribution of each category to total revenue.
*/

SELECT 
    category_name, 
    ROUND(SUM(total_sale), 2) AS total_revenue, 
    ROUND(
        (ROUND(SUM(total_sale), 2) / (SELECT SUM(total_sale) FROM orders_items)) * 100, 
        2
    ) AS percentage_contribution
FROM 
    category c
JOIN 
    products p 
    ON c.category_id = p.category_id
JOIN 
    orders_items oi 
    ON oi.product_id = p.product_id
GROUP BY 
    c.category_id
ORDER BY 
    total_revenue DESC;

/*
Business Problem 3: 
To help Amazon understand how much customers usually spend, 
I analyzed the Average Order Value (AOV) for customers with more than 5 orders. 
This helps Amazon identify high-value customers who spend more per order, 
so marketing teams can give them special offers or loyalty rewards to retain them.

By knowing customer spending patterns, Amazon can also plan:
- Cross-selling: Suggesting related products (e.g., phone case with a phone).
- Upselling: Offering better or premium versions of products.

These strategies help increase the size of each order, boost revenue, and improve customer satisfaction.

/*
3. Average Order Value (AOV)
Compute the average order value for each customer.
Challenge: Include only customers with more than 5 orders.
*/

SELECT 
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    SUM(total_sale) / COUNT(DISTINCT o.order_id) AS AOV,
    COUNT(o.order_id) AS total_orders
FROM 
    orders AS o
JOIN 
    customers AS c
ON 
    c.customer_id = o.customer_id
JOIN 
    orders_items AS oi
ON 
    oi.order_id = o.order_id
GROUP BY 
    c.customer_id, full_name
HAVING  
    COUNT(o.order_id) > 5;

/*
Business Problem 4: Monthly Sales Trend (Last 1 Year)
To help Amazon understand how sales are changing month by month, I analyzed total sales for each month over the past year and compared them to the previous month. 
This helps Amazon spot if sales are going up or down, find seasonal trends, and take action quickly if there are sudden drops. 
With this, Amazon can better plan marketing, manage stock, and prepare for busy seasons, so they don't lose sales or disappoint customers. 

4. Monthly Sales Trend
Query monthly total sales over the past year.
Challenge: Display the sales trend, grouping by month, return current_month sale, last month sale
*/

SELECT 
    year, 
    month, 
    total_sale AS current_month, 
    LAG(total_sale) OVER (ORDER BY year, month) AS last_month_sale
FROM
    (SELECT 
        YEAR(o.order_date) AS year, 
        MONTH(o.order_date) AS month, 
        ROUND(SUM(total_sale), 2) AS total_sale
     FROM 
        orders o
     JOIN 
        orders_items oi
     ON 
        o.order_id = oi.order_id
     WHERE 
        o.order_date >= DATE_SUB(CURDATE(), INTERVAL 1 YEAR)  -- Challenge: Last 12 months
     GROUP BY 
        YEAR(order_date), MONTH(order_date)
     ORDER BY 
        year, month
    ) AS t1;

/*
Business Problem 5: Customers with No Purchases

To help Amazon improve customer engagement and boost conversions, I analyzed customers who signed up but never made a purchase. Identifying these inactive customers allows marketing and sales teams to target them 
with personalized promotions, re-engagement emails, or first-purchase discounts, turning lost opportunities into sales. This analysis directly supports customer acquisition ROI and helps reduce churn 
by understanding why some customers drop off before buying.

Ques-5. Customers with No Purchases
Find customers who have registered but never placed an order.
Challenge: List customer details and the time since their registration.
*/

SELECT * 
FROM customers 
WHERE customer_id NOT IN (
    SELECT DISTINCT customer_id 
    FROM orders 
    WHERE customer_id IS NOT NULL
);

/*
Business Problem 6: Least-Selling Product Categories by State

To help Amazon optimize regional sales strategies, I analyzed the least-selling product categories in each state. 
This insight helps the business understand where certain products are underperforming, 
so teams can adjust marketing efforts, rethink inventory distribution, or tailor product offerings based on local demand. 
By identifying weak spots in specific markets, Amazon can unlock hidden growth opportunities and improve sales performance across regions.

Ques-6. Least-Selling Categories by State
Identify the least-selling product category for each state.
Challenge: Include the total sales for that category within each state.
*/

WITH ranking_table AS (
    SELECT 
        c.state,
        cg.category_name, 
        SUM(oi.total_sale) AS sale,
        DENSE_RANK() OVER (PARTITION BY c.state ORDER BY SUM(oi.total_sale) ASC) AS ranks
    FROM 
        customers c
    JOIN 
        orders o ON o.customer_id = c.customer_id
    JOIN 
        orders_items oi ON o.order_id = oi.order_id
    JOIN 
        products p ON oi.product_id = p.product_id
    JOIN 
        category cg ON p.category_id = cg.category_id
    GROUP BY 
        c.state, 
        cg.category_name
)

SELECT 
    * 
FROM 
    ranking_table
WHERE 
    ranks = 1;
    
/*
Business Problem 7 (Customer Lifetime Value - CLTV):

To help Amazon identify and retain its most valuable customers, I calculated Customer Lifetime Value (CLTV) for each customer based on total spending over time.

This analysis helps solve multiple business problems:
1. Identify high-value customers to focus on personalized offers, loyalty programs, and premium services — encouraging repeat purchases.
2. Optimize marketing spend by targeting profitable customers and adjusting acquisition strategies — maximizing return on investment (ROI).
3. Segment customers (e.g., VIPs, regular buyers, low spenders) to offer tailored services and communication — improving customer satisfaction and loyalty.
4. Predict future revenue to support better inventory planning and supplier negotiations — ensuring high-demand products are always available.
5. Reduce churn by identifying high-value customers at risk of leaving and running proactive retention campaigns — protecting long-term revenue.

Ques- 7. Customer Lifetime Value (CLTV):
Calculate the total value of orders placed by each customer over their lifetime. 
Challenge: Rank customers based on their CLTV.
*/

SELECT 
    c.customer_id, 
    CONCAT(c.first_name, ' ', c.last_name) AS full_name,
    SUM(total_sale) AS cltv, 
    DENSE_RANK() OVER (ORDER BY SUM(total_sale) DESC) AS cx_ranking
FROM 
    orders_items oi
JOIN 
    orders o 
    ON oi.order_id = o.order_id
JOIN 
    customers c 
    ON o.customer_id = c.customer_id
GROUP BY 
    1, 2;

/*
Business Problem 8 (Preventing Stockouts & Optimizing Inventory Management):

To help Amazon avoid stockouts and improve inventory management, 
I analyzed products with stock levels below a critical threshold. 

This insight enables inventory and supply chain teams to proactively reorder popular items before they run out—preventing lost sales and ensuring continuous availability. 

At the same time, identifying low-stock products supports smarter inventory planning 
by avoiding both overstocking slow movers and understocking fast-selling products. 

This analysis helps reduce holding costs, prevent warehouse congestion, 
improve customer satisfaction, and protect revenue by ensuring high-demand products are always ready to ship.

Ques-8. Inventory Stock Alerts
Query products with stock levels below a certain threshold (e.g., less than 10 units).
Challenge: Include last restock date and warehouse information.
*/

SELECT 
    i.inventory_id, 
    p.product_name, 
    i.stock AS current_stock, 
    i.warehouse_id, 
    i.last_stock_date
FROM 
    products p
JOIN 
    inventory i 
ON 
    p.product_id = i.product_id
WHERE 
    i.stock < 10;

/*
Business Problem 9 (Shipping Delay Analysis):
To improve customer satisfaction and reduce delivery-related costs, 
I analyzed orders with shipping delays of more than 3 days. 
This analysis helps identify regions, warehouses, or product types causing frequent delays, 
so management can reallocate resources or renegotiate with logistics partners. 
Improving shipping speed and reliability enhances customer experience 
and reduces costs from expedited shipping and complaints.

Ques-9 Identify orders where the shipping date is later than 3 days after the order date.
Challenge: Include customer, order details, and delivery provider.
*/

SELECT 
    c.*, 
    o.*, 
    s.shipping_providers, 
    s.shipping_date, 
    DATEDIFF(s.shipping_date, o.order_date) AS days_to_ship
FROM 
    shipping s
JOIN 
    orders o 
ON 
    s.order_id = o.order_id
JOIN 
    customers c 
ON 
    o.customer_id = c.customer_id  
WHERE 
    DATEDIFF(s.shipping_date, o.order_date) > 3
ORDER BY 
    days_to_ship DESC;

/*
Business Problem 10 (Improving Payment Process & Reducing Revenue Loss):  

To help Amazon improve the checkout process and reduce revenue loss, I analyzed payment status distribution (successful, failed, refunded).  
This helps identify issues causing failed or refunded payments, so teams can fix technical problems, prevent fraud, and improve payment gateway performance.  
By increasing payment success rates, Amazon can boost revenue, ensure smooth order fulfillment, and enhance customer trust during checkout.  

Ques-10. What is the percentage distribution of payment statuses 
(such as successful, failed, refunded) across all orders, and how many payments fall under each status?
*/

SELECT 
    p.payment_status,  
    COUNT(*) AS total_no_of_payments,  
    (COUNT(*) / (SELECT COUNT(*) FROM payments)) * 100 AS percentage  
FROM 
    payments p  
JOIN 
    orders o  
ON 
    p.order_id = o.order_id  
GROUP BY 
    p.payment_status;

/*
Business Problem 11 (Identifying Top Performing Sellers):  
To help Amazon focus on the best-performing sellers, I identified the top 5 sellers based on total sales value.  
This helps Amazon understand which sellers bring the most revenue and deserve special support, like better visibility, promotions, or incentives.  
By building strong relationships with these top sellers, Amazon can keep popular products in stock, increase sales, and improve customer satisfaction — all of which help the business grow faster.  
Ques-11. Top Performing Sellers
Find the top 5 sellers based on total sales value.
*/

SELECT 
    s.seller_id, 
    s.seller_name, 
    ROUND(SUM(oi.total_sale), 2) AS total_seller_sale
FROM 
    orders o
JOIN 
    orders_items oi 
    ON o.order_id = oi.order_id
JOIN 
    payments p 
    ON p.order_id = oi.order_id
JOIN 
    sellers s 
    ON s.seller_id = o.seller_id
GROUP BY 
    s.seller_id, s.seller_name
ORDER BY 
    total_seller_sale DESC;


/*
Business Problem 12  (Product Profitability & Pricing Optimization):

To help Amazon improve profits and make smarter product decisions, 
I calculated and ranked profit margins for each product. 
This helps the business focus on selling and promoting high-margin products to boost profitability, 
while reviewing or adjusting low-margin items. 
It also supports better pricing strategies, smarter supplier negotiations, and helps decide which products are worth restocking. 
By knowing which items bring in more profit, Amazon can improve overall revenue, reduce unnecessary costs, and offer the right products to customers.

Ques-12  Product Profit Margin
Calculate the profit margin for each product (difference between price and cost of goods sold).
Challenge: Rank products by their profit margin, showing highest to lowest.
*/

SELECT 
    product_id,
    product_name,
    profit_margin,
    DENSE_RANK() OVER (ORDER BY profit_margin DESC) AS product_ranking
FROM 
    (
        SELECT 
            p.product_id, 
            p.product_name,
            SUM(oi.total_sale - (p.cogs * oi.quantity)) / SUM(oi.total_sale) * 100 AS profit_margin
        FROM 
            orders_items oi
        JOIN 
            products p 
        ON 
            oi.product_id = p.product_id
        GROUP BY 
            p.product_id, 
            p.product_name
    ) AS t1;

/*
Business Problem 13 (Minimizing Returns & Improving Customer Satisfaction):
To help Amazon minimize costly returns and improve customer satisfaction, 
I analyzed the top 10 most returned products and their return rates. 
Identifying products with high return rates allows Amazon to spot quality issues, re-evaluate suppliers performance 
misleading descriptions, or sizing problems that lead to dissatisfaction. 
By addressing these issues, Amazon can reduce return-related costs, 
improve customer trust, and increase repeat purchases — all critical 
for maintaining a strong brand reputation.

Ques -13. Most Returned Products
Query the top 10 products by the number of returns.
Challenge: Display the return rate as a percentage of total units sold for each product.
*/

SELECT 
    p.product_id, 
    p.product_name, 
    COUNT(oi.product_id) AS total_products_sold,
    SUM(CASE WHEN o.order_status = 'returned' THEN 1 ELSE 0 END) AS no_of_returned_products, 
    (SUM(CASE WHEN o.order_status = 'returned' THEN 1 ELSE 0 END) / COUNT(oi.product_id)) * 100 AS return_rate
FROM 
    orders o 
JOIN 
    orders_items oi 
ON 
    o.order_id = oi.order_id
JOIN 
    products p 
ON 
    oi.product_id = p.product_id 
GROUP BY 
    p.product_id, 
    p.product_name
ORDER BY 
    return_rate DESC;

/*  
Business Problem 14 (Ranking Top-Selling Products by Category):  

To help Amazon identify the best-selling products in each category, I ranked products based on their total sales amount.  
This analysis helps Amazon focus on products that generate the highest revenue within every category,  
so they can prioritize these items for inventory management, marketing, and promotions.  
By knowing which products sell the most in each category, Amazon can avoid stockouts, optimize marketing spend,  
and ensure customer satisfaction — leading to better sales performance and profitability.  

Ques-14 . Rank products within each category based on their total sales amount to identify top 5 performing products in every category
*/  
SELECT * 
FROM (
    SELECT 
        c.category_id, 
        c.category_name, 
        p.product_id, 
        p.product_name,
        SUM(total_sale) AS total_product_sale,
        DENSE_RANK() OVER (
            PARTITION BY category_id, category_name 
            ORDER BY SUM(total_sale) DESC
        ) AS top_selling_product_category
    FROM 
        orders_items oi
    JOIN 
        products p 
    ON 
        p.product_id = oi.product_id
    JOIN 
        category c 
    ON 
        p.category_id = c.category_id
    GROUP BY 
        category_id, 
        category_name, 
        product_id, 
        p.product_name
) t 
WHERE 
    top_selling_product_category <= 5;


/*
Business Problem 15 (Reactivating Inactive Sellers):  

To help Amazon keep its marketplace active and competitive, I identified sellers who haven't made any sales in the past 6 months, along with their last sale date and total sales.  

This analysis helps Amazon:  
1. Identify inactive sellers who may need support.  
2. Reach out to them with personalized incentives or marketing tools.  
3. Reactivate sellers to increase product variety and boost overall marketplace sales.

Ques 15. - Identify sellers who haven’t made any sales in the last 6 months.
Challenge: Show the last sale date and total sales from those sellers.
*/

WITH cte AS (
    SELECT * 
    FROM sellers
    WHERE seller_id NOT IN (
        SELECT seller_id
        FROM orders
        WHERE order_date >= (
            SELECT DATE_SUB(MAX(order_date), INTERVAL 6 MONTH) 
            FROM orders
        )
    )
)

SELECT 
    o.seller_id,
    MAX(o.order_date) AS last_sale_date,
    SUM(oi.total_sale) AS last_sale_amount
FROM 
    orders o
JOIN 
    cte c ON o.seller_id = c.seller_id
JOIN 
    orders_items oi ON o.order_id = oi.order_id
GROUP BY 
    o.seller_id;


/*
Business Problem 16 (Customer Return Pattern Analysis):

To help Amazon analyze customer return patterns, I identified customers with more than 5 returned orders as "returning" and others as "new." 
This analysis helps Amazon spot customers who frequently return products, so teams can investigate issues like product fit problems, misleading listings, or possible fraud. 
By addressing these causes, Amazon can reduce return rates, improve customer satisfaction, and cut down costs related to returns.

Ques-16  IDENTITY customers into returning or new
if the customer has done more than 5 return categorize them as returning otherwise new
Challenge: List customers id, name, total orders, total returns
*/

WITH cte AS (
    SELECT 
        c.customer_id, 
        CONCAT(first_name, ' ', last_name) AS name, 
        COUNT(o.order_id) AS total_orders,
        SUM(CASE WHEN o.order_status = 'returned' THEN 1 ELSE 0 END) AS no_of_returned
    FROM 
        customers c
    JOIN 
        orders o 
    ON 
        c.customer_id = o.customer_id 
    GROUP BY 
        c.customer_id
)

SELECT 
    *, 
    CASE 
        WHEN no_of_returned > 5 THEN 'returning' 
        ELSE 'new' 
    END AS returning_check
FROM 
    cte;

/*
Business Problem 17  (Identifying Top Regional Customers):

To help Amazon recognize and retain high-value customers in each region, 
I identified the top 5 customers with the highest number of orders in each state. 
This insight allows Amazon to design targeted loyalty programs, exclusive offers, 
and personalized services for top customers—boosting retention and increasing long-term revenue. 
It also helps improve customer satisfaction and gain useful feedback from key buyers in local markets.
Ques-17 op 5 Customers by Orders in Each State
Identify the top 5 customers with the highest number of orders for each state.
Challenge: Include the number of orders and total sales for each customer
*/

SELECT * 
FROM (
    SELECT 
        c.state, 
        CONCAT(first_name, ' ', last_name) AS name, 
        c.customer_id AS customer_id,
        COUNT(o.order_id) AS total_orders, 
        SUM(oi.total_sale) AS total_sale, 
        DENSE_RANK() OVER (PARTITION BY state ORDER BY COUNT(o.order_id) DESC) AS ranking_top_5
    FROM customers c 
    JOIN orders o 
        ON c.customer_id = o.customer_id 
    JOIN orders_items oi 
        ON o.order_id = oi.order_id 
    GROUP BY 
        c.state, 
        CONCAT(first_name, ' ', last_name), 
        c.customer_id
) t
WHERE ranking_top_5 <= 5;


/*
Business Problem 18 (Shipping Provider Performance & Optimization):

To help Amazon improve shipping operations and customer satisfaction, I analyzed how much revenue each shipping provider handles, 
how many orders they deliver, and their average delivery time. This helps Amazon identify which partners generate more revenue while delivering fast, 
so they can focus on the best ones and avoid slower or costly providers. With this insight, Amazon can make smarter decisions to balance cost and delivery speed — 
like using faster providers for urgent orders and cheaper ones for regular deliveries. This approach helps reduce costs, improve delivery times, 
keep customers happy, and grow profits.

Ques- 18. Revenue by Shipping Provider (need of took) 
Calculate the total revenue handled by each shipping provider.
Challenge: Include the total number of orders handled and the average delivery time for each provider.
*/

SELECT 
    s.shipping_providers,
    COUNT(distinct s.shipping_id) AS no_of_orders, 
    SUM(oi.total_sale) AS total_shipping_sale,
    AVG(DATEDIFF(s.shipping_date, o.order_date)) AS no_of_days
FROM 
    shipping s
JOIN 
    orders o 
ON 
    s.order_id = o.order_id 
JOIN 
    orders_items oi 
ON 
    o.order_id = oi.order_id
GROUP BY 
    s.shipping_providers
ORDER BY no_of_days asc;


/*
Business Problem 19 (Identifying Underperforming Products):
To help Amazon find products that are not selling well or are losing market appeal, 
I analyzed the top 10 products with the highest revenue decline from 2022 to 2023, 
along with their categories and percentage drop in sales. 
This analysis helps Amazon quickly spot underperforming products 
and decide whether to discontinue them, improve product listings, adjust pricing, 
or run special promotions to boost sales. 
By acting on this, Amazon can avoid inventory waste, save storage space, 
and focus on high-performing products to increase profits and stay competitive.

Ques-19. Top 10 product with highest decreasing revenue ratio compare to last year(2022) and current_year(2023)
Challenge: Return product_id, product_name, category_name, 2022 revenue and 2023 revenue decrease ratio at end Round the result
Note: Decrease ratio = cr-ls/ls* 100 (cs = current_year ls=last_year)
*/
SELECT *, 
       ROUND(((year_23 - year_22) / (year_22)) * 100, 2) AS decrease_ratio 
FROM 
    (SELECT p.product_id, 
            p.product_name, 
            SUM(CASE WHEN YEAR(o.order_date) = 2023 THEN total_sale ELSE 0 END) AS year_23, 
            SUM(CASE WHEN YEAR(o.order_date) = 2022 THEN total_sale ELSE 0 END) AS year_22
     FROM category c 
     JOIN products p 
     ON c.category_id = p.category_id 
     JOIN orders_items oi 
     ON p.product_id = oi.product_id 
     JOIN orders o 
     ON o.order_id = oi.order_id
     GROUP BY p.product_id, p.product_name 
     HAVING SUM(CASE WHEN YEAR(o.order_date) = 2023 THEN total_sale ELSE 0 END) > 0 
        AND SUM(CASE WHEN YEAR(o.order_date) = 2022 THEN total_sale ELSE 0 END) > 0
    ) t 
ORDER BY decrease_ratio ASC;

/*
Business Problem 20 (Tracking Monthly Sales Trends):
To help Amazon monitor sales performance and identify seasonal trends, I analyzed total sales for each month in the current year. 
This insight helps Amazon plan targeted marketing during slow months, prepare inventory for peak seasons, and make better budgeting and forecasting decisions.

Ques-20. Find the total sales amount for each month in the current year.
*/

SELECT 
    MONTH(o.order_date) AS each_month, 
    round(SUM(oi.total_sale),2) AS month_total_sales
FROM 
    orders_items oi
JOIN 
    orders o ON oi.order_id = o.order_id
WHERE 
    YEAR(o.order_date) = (
        SELECT MAX(YEAR(order_date)) FROM orders
    )
GROUP BY 
    MONTH(o.order_date)
ORDER BY 
    each_month;
    
/*
Business Problem 21 (Identifying High Refund Products):
To help Amazon understand product quality issues and customer dissatisfaction, I analyzed the top 10 products with the highest number of refunds. 
This insight helps Amazon identify problematic products, investigate causes (e.g., quality, shipping issues), improve customer satisfaction, and make informed decisions on product offerings.

Ques-21. Find the top 10 products with the highest number of refunds.
*/

SELECT 
    p.product_id,
    p.product_name,
    COUNT(*) AS total_returns
FROM 
    shipping s
JOIN 
    orders o ON s.order_id = o.order_id
JOIN 
    orders_items oi ON o.order_id = oi.order_id
JOIN 
    products p ON oi.product_id = p.product_id
WHERE 
    s.delivery_status = 'Returned' 
GROUP BY 
    p.product_id, p.product_name
ORDER BY 
    total_returns DESC
LIMIT 10;  

