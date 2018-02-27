-- HW4.sql -- Homework 4
--
-- KEVIN NGUYEN
-- UT EID: kdn433, UTCS username: kxnguyen
-- CS f347, Spring 2017, Dr. P. Cannata
-- Department of Computer Science, The University of Texas at Austin
--
 
-- 7-01
INSERT INTO PRODUCTS 
  (product_id, category_id, product_code, product_name, description, list_price, discount_percent, date_added)
  VALUES (11, 4, 'dgx_640', 'Yamaha DGX 640 88-Key Digital Piano', 'Long description to come', 799.99, 0, NULL);

-- 7-02
UPDATE PRODUCTS SET discount_percent = 35
WHERE discount_percent = 0;

-- 7-03
DELETE FROM PRODUCTS WHERE CATEGORY_ID = 4;

-- 8-04
SELECT ORDER_DATE, TO_CHAR(ORDER_DATE, 'YYYY') AS order_year, TO_CHAR(ORDER_DATE, 'MM-DD-YYYY') AS formatted_order_date,
TO_CHAR(ORDER_DATE, 'HH:MI:SS AM') as time_order_date, TO_CHAR(ORDER_DATE, 'MM/DD/YY HH:SS') as formatted_order_date_new FROM ORDERS;

-- 8-05
SELECT card_number, LENGTH(card_number) as length_card_number, SUBSTR(card_number,13,16) as last_four_digits, CONCAT(SUBSTR(card_number,1,4),CONCAT('-',CONCAT(SUBSTR(card_number,5,4),CONCAT('-',CONCAT(SUBSTR(card_number,9,4),CONCAT('-',CONCAT(SUBSTR(card_number,13,4),CONCAT('-','1234')))))))) as formatted_card_number from ORDERS;

-- 11-01
CREATE or REPLACE VIEW customer_addresses AS 
  Select o.ship_address_id, o.billing_address_id, c.customer_id, c.email_address, c.last_name, c.first_name, adrs.line1 as bill_line1, adrs.line2 as bill_line2, adrs.city as bill_city, adrs.state as bill_state, adrs.zip_code as bill_zip, adrs.line1 as ship_line1, adrs.line2 as ship_line2, adrs.city as ship_city, adrs.state as ship_state, adrs.zip_code as ship_zip from ORDERS o 
  JOIN CUSTOMERS c ON o.customer_id = c.customer_id
  JOIN ADDRESSES adrs ON c.customer_id = adrs.customer_id
  ORDER BY c.last_name, c.first_name;
Select * FROM customer_addresses;

-- 11-02
SELECT customer_id, last_name, first_name, bill_line1 FROM customer_addresses;

-- 11-03
CREATE OR REPLACE VIEW Orders_orderItems_Products AS 
  SELECT o.order_id, o.order_date, o.tax_amount, oi.item_price, oi.discount_amount, (oi.item_price - oi.discount_amount) as final_price, oi.quantity, ((oi.item_price - oi.discount_amount)*oi.quantity) as item_total, p.product_name
  FROM ORDERS o JOIN ORDER_ITEMS oi ON o.order_id = oi.order_id JOIN PRODUCTS p ON oi.product_id = p.product_id;
SELECT * FROM Orders_orderItems_Products;

-- 11-04
CREATE OR REPLACE VIEW product_summary AS 
  Select oop.product_name, oop.item_total as order_total, COUNT(oop.order_id) as order_count FROM Orders_orderItems_Products oop
  GROUP BY oop.product_name, oop.item_total;
Select * FROM product_summary;

-- 11-05
SELECT product_name, order_total FROM
  (SELECT product_name, order_total FROM product_summary
  ORDER BY order_total DESC)
WHERE ROWNUM < 6;