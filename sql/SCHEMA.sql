DROP TABLE IF EXISTS superstore CASCADE;

/*In the nest queries i just created the whole data base from the main file (superstore.cvs), then this dataset was normalized into 4
tables to improve consistency and scalability:*/
--MAIN TABLE
CREATE TABLE IF NOT EXISTS superstore (
    row_id INTEGER,
    order_id TEXT,
    order_date DATE,
    ship_date DATE,
    ship_mode TEXT,
    customer_id TEXT,
    customer_name TEXT,
    segment TEXT,
    country TEXT,
    city TEXT,
    state TEXT,
    postal_code NUMERIC,
    region TEXT,
    product_id TEXT,
    category TEXT,
    sub_category TEXT,
    product_name TEXT,
    sales NUMERIC,
    quantity INTEGER,
    discount NUMERIC,
    profit NUMERIC
);

SET datestyle = 'MDY'; --As the main file (superstore.cvs) has diferent date type

COPY superstore
FROM 'C:/Program Files/PostgreSQL/17/data/Superstore.csv'
DELIMITER ','
CSV HEADER;

-- FIRST lets normalized the table for better understanding of the data
DROP TABLE IF EXISTS customers CASCADE;
DROP TABLE IF EXISTS orders CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS order_details CASCADE;

/*DROP TABLE was used only for the purpose of texting the CREATE TABLE statement, after I see that the tables have the perfect
structure and values type correctly is recomended to erase those lines from the script or use another file for queries but dont run this 
script again because if so, then the data from those tables will be erase everytime and we will have to re enter the data everytime.*/
CREATE TABLE IF NOT EXISTS customers (
customer_id TEXT PRIMARY KEY,
customer_name TEXT,
segment TEXT,
country TEXT,
city TEXT,
state TEXT,
postal_code NUMERIC,
region TEXT
); --ALL info about customers

CREATE TABLE IF NOT EXISTS orders (
order_id TEXT PRIMARY KEY,
order_date DATE,
ship_date DATE,
ship_mode TEXT,
customer_id TEXT REFERENCES customers(customer_id)
); --ALL info about orders

CREATE TABLE IF NOT EXISTS products (
product_id TEXT PRIMARY KEY,
category TEXT,
sub_category TEXT,
product_name TEXT
); --Product catalog

CREATE TABLE IF NOT EXISTS order_details (
order_id TEXT REFERENCES orders(order_id),
product_id TEXT REFERENCES products(product_id),
PRIMARY KEY (order_id, product_id),
sales NUMERIC,
quantity NUMERIC,
discount NUMERIC,
profit NUMERIC
); --the intermediate table between orders and products for the many to many relationship

-- NOW insert the data that we imported into those tables!
/*
The DISTINCT ON CLAUSE its because we want only the customers information so there might be more than 1 row with
the same customer id and name because they can have many orders, so we dont want repeated data on
the customer table and that is why we use DISCTINCT ON customer_id to get only 1 customer for that id and
everytime the program get the same id and name it will just skip and get a new one ... the same process its
done for all other tables except for order details table
*/
INSERT INTO customers (customer_id, customer_name, segment, country, city, state, postal_code, region)
SELECT DISTINCT ON (customer_id) customer_id, customer_name, segment, country, city, state, postal_code, region
FROM superstore
ORDER BY customer_id;

INSERT INTO products (product_id, category, sub_category, product_name)
SELECT DISTINCT ON (product_id) product_id, category, sub_category, product_name
FROM superstore
ORDER BY product_id;

INSERT INTO orders (order_id, customer_id, order_date, ship_date, ship_mode)
SELECT DISTINCT order_id, customer_id, order_date, ship_date, ship_mode
FROM superstore;

/*
IMPORTANT
WHEN inserting data into order_details table, there are some things to know, there are 2 rows of the same product_id and order_id
meaning that that person buy the same product 2 times with differents amounts of the same product (quantity), in order to actually
check if this is true we do this:

This will say how many of the same order/product id has the same "transaction", meaning the person buy 2 or more times the same thing
SELECT order_id, product_id, COUNT(*)
FROM superstore
GROUP BY order_id, product_id
HAVING COUNT(*) > 1
ORDER BY COUNT(*) DESC
LIMIT 10;

NOW we check for 1 example and see exactly that, the quantity is different from those 2 (or more) rows
SELECT *
FROM superstore
WHERE order_id = 'CA-2016-129714' AND product_id = 'OFF-PA-10001970';

So before inserting the data we need 1 product_id and order_id per row AND the total ammount (SUM) for everything else so we have
1 product in the same order but SUM(quantity, profict, discount) AS 1 value
*/

INSERT INTO order_details (order_id, product_id, sales, quantity, discount, profit)
SELECT
  order_id,
  product_id,
  SUM(sales) AS sales,
  SUM(quantity) AS quantity,
  SUM(discount) AS discount,
  SUM(profit) AS profit
FROM superstore
GROUP BY order_id, product_id;

--Finally we create INDEXES for improving speed
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_order_details_order_id ON order_details(order_id);
CREATE INDEX idx_order_details_product_id ON order_details(product_id);

