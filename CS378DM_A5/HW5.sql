-- HW5.sql -- Homework 5
--
-- Kevin Nguyen
-- UT EID: kdn433, UTCS username: kxnguyen
-- CS f347, Spring 2017, Dr. P. Cannata
-- Department of Computer Science, The University of Texas at Austin
--
 
-- 13-01
SET SERVEROUTPUT ON;

DECLARE
	COUNT_PRODUCTS_VAR NUMBER;
BEGIN
	SELECT COUNT(p.PRODUCT_ID)
	INTO COUNT_PRODUCTS_VAR
	FROM PRODUCTS p;

  IF COUNT_PRODUCTS_VAR >= 7 THEN
    DBMS_OUTPUT.PUT_LINE('The number of products is greater than or equal to 7');
  ELSE
    DBMS_OUTPUT.PUT_LINE('The number of products is less than 7');
  END IF;

EXCEPTION
	WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('An error occurred in the script');
END;
/

-- 13-02
SET SERVEROUTPUT ON;

DECLARE
	COUNT_VAR NUMBER;
	AVG_VAR NUMBER;
BEGIN
	SELECT COUNT(p.PRODUCT_ID), AVG(p.LIST_PRICE) INTO COUNT_VAR, AVG_VAR
	FROM PRODUCTS p;
  IF COUNT_VAR < 7 THEN
    DBMS_OUTPUT.PUT_LINE('The number of products is less than 7');
  ELSE
    DBMS_OUTPUT.PUT_LINE('Count: ' || COUNT_VAR || ', ' || 'Average: ' || AVG_VAR);
  END IF;
EXCEPTION
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('An error occurred in the script');
END;
/

-- 13-03
SET SERVEROUTPUT ON;

DECLARE
  iter NUMBER;
	FACTORS_VAR VARCHAR2(2000); 
BEGIN
	iter := 2;
  FACTORS_VAR := 1;
	WHILE iter < 11 LOOP
    IF (10 MOD iter = 0) AND (20 MOD iter = 0) THEN
			FACTORS_VAR := FACTORS_VAR || ', ' || iter;
		END IF;
		iter := iter + 1;
	END LOOP;
  DBMS_OUTPUT.PUT_LINE('Common factors of 10 and 20: ' || FACTORS_VAR);
END;
/

-- 13-04
SET SERVEROUTPUT ON;

DECLARE
  str_var VARCHAR(2000);
	CURSOR products_cursor IS
    SELECT p.product_name, p.list_price FROM PRODUCTS p
    WHERE p.list_price > 700
    ORDER BY p.list_price DESC;
    products_row products%ROWTYPE;
BEGIN
  str_var := '';
  FOR products_row IN products_cursor LOOP
    IF (products_row.list_price > 700) THEN
      str_var := str_var || '"' || products_row.product_name || '"' || ', ' || '"' || products_row.list_price || '"' || ' | '; 
    END IF;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE(str_var);
END;
/

-- 13-05
SET SERVEROUTPUT ON;

BEGIN
	INSERT INTO CATEGORIES VALUES (999, '"Guitars"');
	DBMS_OUTPUT.PUT_LINE('1 row inserted.');
EXCEPTION
	WHEN DUP_VAL_ON_INDEX THEN
		DBMS_OUTPUT.PUT_LINE('Row was not inserted - duplicate entry.');
	WHEN OTHERS THEN
		DBMS_OUTPUT.PUT_LINE('Unexpected exception occurred.');
END;
/