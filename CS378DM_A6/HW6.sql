-- HW6.sql -- Homework 6
--
-- Kevin Nguyen
-- UT EID: kdn433, UTCS username: kxnguyen
-- CS f347, Spring 2017, Dr. P. Cannata
-- Department of Computer Science, The University of Texas at Austin
--
 
-- 14-01
SET SERVEROUTPUT ON;

BEGIN
	DELETE ADDRESSES WHERE CUSTOMER_ID = 8;
	DELETE CUSTOMERS WHERE CUSTOMER_ID = 8;
	COMMIT;
	DBMS_OUTPUT.PUT_LINE('The transaction was committed.');
EXCEPTION
	WHEN OTHERS THEN
		ROLLBACK;
		DBMS_OUTPUT.PUT_LINE('The transaction was rolled back.');
END;
/

-- 14-02
SET SERVEROUTPUT ON;

BEGIN
  INSERT INTO orders VALUES (999, 3, SYSDATE(), '10.00', '0.00', NULL, 4, 'American Express', '378282246310005', '04/2013', 4);
  INSERT INTO order_items VALUES (988, 999, 6, '415.00', '161.85', 1);
  INSERT INTO order_items VALUES (989, 999, 1, '699.00', '209.70', 1);
	COMMIT;
	DBMS_OUTPUT.PUT_LINE('The transaction was committed.');
EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('The transaction was rolled back.');
END;
/

-- 15-01
CREATE OR REPLACE PROCEDURE insert_category 
(
	category_name_param VARCHAR2
)
AS
BEGIN
	INSERT INTO CATEGORIES VALUES (999, category_name_param);
	COMMIT;
  DBMS_OUTPUT.PUT_LINE('The transaction was successful.');
EXCEPTION
	WHEN OTHERS THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('The transaction was rolled back.');
END;
/
CALL insert_category('Test1');
CALL insert_category('Test2');
/

-- 15-02
CREATE OR REPLACE FUNCTION discount_price
(
	item_id_param NUMBER
)
RETURN NUMBER
AS
	item_discount_var NUMBER;
BEGIN
	SELECT (o.ITEM_PRICE - o.DISCOUNT_AMOUNT) AS new_price INTO item_discount_var FROM ORDER_ITEMS o
	WHERE item_id = item_id_param;
	RETURN item_discount_var; 
END;
/
SELECT item_id, discount_price(item_id) FROM ORDER_ITEMS;
/

-- 15-03
CREATE OR REPLACE FUNCTION item_total
(
	item_id_param NUMBER
)
RETURN NUMBER
AS
	total_amount_var NUMBER;
BEGIN
	SELECT (discount_price(item_id) * quantity) AS new_price INTO total_amount_var FROM ORDER_ITEMS
	WHERE item_id = item_id_param;
	RETURN total_amount_var;
END;
/
SELECT item_id, item_total(item_id) FROM ORDER_ITEMS;
/

-- 15-04
CREATE OR REPLACE PROCEDURE insert_products
(
	category_id_param NUMBER,
	product_code_param NUMBER,
  product_name_param VARCHAR2,
  list_price_param NUMBER,
  discount_percent_param NUMBER
)
AS
  discount_list_price EXCEPTION;
  list_price_bad EXCEPTION;
BEGIN
	INSERT INTO PRODUCTS VALUES (9999, category_id_param, product_code_param, product_name_param, ' ', list_price_param, discount_percent_param, SYSDATE());
	UPDATE PRODUCTS
	SET description = ' ', date_added = SYSDATE()
	WHERE  category_id = category_id_param;
  
  IF discount_percent_param < 0 OR list_price_param < 0 THEN
    RAISE discount_list_price;
  END IF;
  
	COMMIT;
EXCEPTION
  WHEN discount_list_price THEN
    ROLLBACK;
    DBMS_OUTPUT.PUT_LINE('Discount percent or List price can not be negative!');
  WHEN OTHERS THEN
    ROLLBACK;
		DBMS_OUTPUT.PUT_LINE('Error has occurred!');
END;
/
CALL insert_products(999, 888, 'Test1', 99, 9);
CALL insert_products(998, 889, 'Test2', 88, 8);
/

-- 15-05
CREATE OR REPLACE PROCEDURE update_product_discount
(
	product_id_param NUMBER,
	discount_percent_param NUMBER
)
AS
  discount_bad EXCEPTION;
BEGIN
	UPDATE PRODUCTS
	SET discount_percent = discount_percent_param
	WHERE product_id = product_id_param;
  IF (discount_percent_param < 0) THEN
    RAISE discount_bad;
  END IF;
	COMMIT;
  DBMS_OUTPUT.PUT_LINE('success!');
EXCEPTION
	WHEN discount_bad THEN
		ROLLBACK;
		DBMS_OUTPUT.PUT_LINE('Discount percent must be positive!');
	WHEN OTHERS THEN
		ROLLBACK;
		DBMS_OUTPUT.PUT_LINE('An error has occurred!');
END;
/
CALL update_product_discount(999, -33);
CALL update_product_discount(998, 56);
/

-- 16-01
CREATE OR REPLACE TRIGGER products_before_update
BEFORE INSERT OR UPDATE OF discount_percent
ON PRODUCTS
FOR EACH ROW
BEGIN
	IF :NEW.discount_percent > 0 AND :NEW.discount_percent < 1 THEN
		:NEW.discount_percent := :NEW.discount_percent * 100;
	END IF;
	IF :NEW.discount_percent < 0 OR :NEW.discount_percent > 100 THEN
    RAISE_APPLICATION_ERROR(-20032, 'Discount_percent may not be higher than 100 or lower than 0!');
  END IF;
END;
/
UPDATE PRODUCTS
SET discount_percent = 101
WHERE product_id = 5;
/
UPDATE PRODUCTS
SET discount_percent = .2
WHERE product_id = 6;
/

-- 16-02
CREATE OR REPLACE TRIGGER products_before_insert
BEFORE INSERT OR UPDATE OF discount_percent
ON PRODUCTS
FOR EACH ROW
BEGIN
	IF :NEW.date_added IS NULL THEN
		:NEW.date_added := SYSDATE();
	END IF;
END;
/
INSERT INTO PRODUCTS (product_id, category_id, product_code, product_name, description, list_price, discount_percent, date_added)
VALUES (7898, 1, 'asdf', 'qwerty', 'something', 22, 33, NULL);
/

-- 16-03
CREATE TABLE Products_audit
(
  audit_id           NUMBER         PRIMARY KEY,
  product_id         NUMBER         REFERENCES products (product_id),
  category_id        NUMBER         REFERENCES categories (category_id),
  product_code       VARCHAR2(10)   NOT NULL      UNIQUE,
  product_name       VARCHAR2(255)  NOT NULL,
  list_price         NUMBER(10,2)   NOT NULL,
  discount_percent   NUMBER(10,2)                 DEFAULT 0.00,
  date_updated       DATE                         DEFAULT NULL  
);

CREATE OR REPLACE TRIGGER products_after_update
BEFORE INSERT OR UPDATE
ON Products_audit
FOR EACH ROW
WHEN (NEW.audit_id IS NULL)
BEGIN
	SELECT audit_id_seq.NEXTVAL
	INTO :new.audit_id
	FROM DUAL;
	IF INSERTING THEN
		INSERT INTO Products_audit VALUES (:old.product_id, :old.category_id, :old.product_code, :old.product_name, :old.list_price, :old.discount_percent, :old.date_added);
  END IF;
END;
/
UPDATE PRODUCTS
SET discount_percent = 33
WHERE product_id = 1;
/
