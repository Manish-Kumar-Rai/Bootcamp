------------------------------ MODULE 3 -----------------------------

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'module3')
BEGIN
	EXEC('CREATE SCHEMA module3')
END;

SELECT * FROM module2.employees;

INSERT INTO module2.employees(id,name,age,hiring_date,salary,city)
VALUES (6,'Kapil',NULL,'2021-08-10',40000.00,'Mumbai'),
	   (7,'Nikhil',30,'2022-08-11',45000.56,'Chennai');

UPDATE module2.employees SET age = 26
WHERE age IS NULL;

EXEC sp_help 'module2.employees';

--------- where filter part is null ------------

SELECT * FROM module2.employees
WHERE age IS NULL;

--------- where filter part is not null ------------

SELECT * FROM module2.employees
WHERE salary IS NOT NULL;

--------- GROUP BY -----------

IF OBJECT_ID('module3.orders_data','U') IS NOT NULL
	DROP TABLE module3.orders_data;
GO

CREATE TABLE module3.orders_data(
	cust_id INT,
	order_id INT,
	country VARCHAR(30),
	[state] VARCHAR(30)
);

SELECT * FROM module3.orders_data;

-- calculate total order placed by countrywise---
SELECT country, COUNT(*) AS total_orders
FROM module3.orders_data
GROUP BY country
ORDER BY country;

-- Another group by example
SELECT
	age,
	SUM(salary) AS total_salary
FROM module2.employees
GROUP BY age
ORDER BY total_salary DESC;

-- Order placed from each state within the country
SELECT 
	country,
	state,
	COUNT(*) AS total_orders
FROM module3.orders_data
GROUP BY country, state;

----- HAVING CLAUSE -----------
SELECT
	country,
	COUNT(*) AS total_orders
FROM module3.orders_data
GROUP BY country
HAVING COUNT(*) = 2
ORDER BY country DESC;


--- THIS code gives error as country is same but not part of group by or agg function
--SELECT
--	country,
--	state,
--	COUNT(*) AS total_orders
--FROM module3.orders_data
--WHERE country = 'USA'
--GROUP BY state;

---- GROUP_CONCAT(MySQL) ----------

SELECT
	country,
	COUNT(1) AS total_orders,
	--STRING_AGG([state], ' | ') WITHIN GROUP (ORDER BY [state] DESC) AS state_list
	-- For Distinct state
	(
		SELECT STRING_AGG([state],' | ') WITHIN GROUP (ORDER BY [state] DESC)
		FROM (
			SELECT DISTINCT [state]
			FROM module3.orders_data AS sub
			WHERE sub.country = main.country
		) AS distinct_state
	) AS state_list
FROM module3.orders_data AS main
GROUP BY country;

IF OBJECT_ID('module3.payments','U') IS NOT NULL
	DROP TABLE module3.payments;
GO

CREATE TABLE module3.payments(
	payment_amt DECIMAL(8,2),
	payment_date DATE,
	store_id INT
);



SELECT * FROM module3.payments;

SELECT
	store_id,
	COUNT(*) AS Number_of_payment,
	SUM(payment_amt) AS total_payment,
	STRING_AGG(payment_amt,' | ') WITHIN GROUP (ORDER BY payment_amt ) AS payment_history 
FROM module3.payments
GROUP BY store_id;

SELECT
	store_id,
	payment_date,
	MONTH(payment_date) AS payment_month,
	COUNT(*) AS Number_of_payment,
	SUM(payment_amt) AS total_payment,
	STRING_AGG(payment_amt,' | ') WITHIN GROUP (ORDER BY payment_amt ) AS payment_history 
FROM module3.payments
GROUP BY store_id,payment_date,MONTH(payment_date);

------ group (WITH ROLLUP) ---------

SELECT
	YEAR(payment_date) AS payment_year,
	store_id,
	SUM(payment_amt) AS Total_payments
FROM module3.payments
GROUP BY YEAR(payment_date),store_id WITH ROLLUP
ORDER BY 
	CASE
		WHEN YEAR(payment_date) IS NULL THEN 1 ELSE 0
	END,
	CASE
		WHEN store_id IS NULL THEN 1 ELSE 0
	END,
	YEAR(payment_date),store_id;

SELECT
	temp.payment_year,
	temp.Total_payments
FROM
	(
		SELECT
			YEAR(payment_date) AS payment_year,
			store_id,
			SUM(payment_amt) AS Total_payments
		FROM module3.payments
		GROUP BY YEAR(payment_date),store_id WITH ROLLUP
	) AS temp
WHERE temp.store_id IS NULL AND temp.payment_year IS NOT NULL;

------ SUB-Query ---------

IF OBJECT_ID('module3.employees') IS NOT NULL
	DROP TABLE module3.employees
GO

CREATE TABLE module3.employees(
	id INT IDENTITY(1,1),
	[name] VARCHAR(20),
	salary MONEY
);

SELECT * FROM module3.employees;

SELECT
	COUNT(*)
FROM module3.employees
WHERE salary < (
	SELECT salary FROM module3.employees WHERE [name] = 'Jane'
);

SELECT
	(1.0 *(
		SELECT
			COUNT(*)
		FROM module3.employees
		WHERE salary < (
			SELECT salary FROM module3.employees WHERE [name] = 'Jane'
		)
	))/ COUNT(*) AS prop
FROM module3.employees

------------ CASE clause ---------------

IF OBJECT_ID('module3.students','U') IS NOT NULL
	DROP TABLE module3.students
GO

CREATE TABLE module3.students(
	id INT IDENTITY(1,1),
	[name] VARCHAR(20),
	marks INT
);

SELECT * FROM module3.students;

SELECT
	*,
	CASE
		WHEN marks <= 70 THEN 'D'
		WHEN marks < 80 THEN 'C'
		WHEN marks < 90 THEN 'B'
		ELSE 'A'
	END AS grades
FROM module3.students
ORDER BY 
	CASE
		WHEN marks < 70 THEN 'D'
		WHEN marks < 80 THEN 'C'
		WHEN marks < 90 THEN 'B'
		ELSE 'A'
	END,marks DESC;

---- UBER Interview Question ----

IF OBJECT_ID('module3.uber','U') IS NOT NULL
	DROP TABLE module3.uber
GO

CREATE TABLE module3.uber(
	[node] INT,
	parent INT
);

SELECT * FROM module3.uber;

SELECT
	u.[node],
	CASE
		WHEN u.parent IS NULL THEN 'Root'
		WHEN u.[node] IN (SELECT DISTINCT parent FROM module3.uber WHERE parent IS NOT NULL) THEN 'Inner'
		ELSE 'Leaf'
	END AS 'type'
FROM module3.uber AS u;

----------- JOIN -------------------

IF OBJECT_ID('module3.orders','U') IS NOT NULL
	DROP TABLE module3.orders
GO

CREATE TABLE module3.orders(
	order_id INT,
	cust_id INT,
	order_date DATE,
	shipper_id INT
);

IF OBJECT_ID('module3.shippers','U') IS NOT NULL
	DROP TABLE module3.shippers
GO

CREATE TABLE module3.shippers(
	ship_id INT,
	shipper_name VARCHAR(50)
);

SELECT * FROM module3.customers;

SELECT * FROM module3.shippers;

SELECT * FROM module3.orders;


--SELECT
--	O.*,
--	C.*,
--	S.*
--FROM module3.orders AS O
--FULL OUTER JOIN module3.customers AS C
--	ON O.cust_id = C.cust_id
--FULL OUTER JOIN module3.shippers AS S
--	ON O.shipper_id = S.ship_id
--WHERE S.ship_id IS NULL
--ORDER BY C.cust_id;

IF OBJECT_ID('module3.customers','U') IS NOT NULL
	DROP TABLE module3.customers
GO

CREATE TABLE module3.customers(
	customer_id INT,
	first_name VARCHAR(20),
	last_name VARCHAR(20),
	[state] VARCHAR(50),
	birthdate DATE,
	gender VARCHAR(10)
);

IF OBJECT_ID('module3.products','U') IS NOT NULL
	DROP TABLE module3.products
GO

CREATE TABLE module3.products(
	product_id INT,
	product_class_id INT,
	brand_name VARCHAR(20),
	product_name VARCHAR(20),
	[state] VARCHAR(50),
	is_low_fat_fig TINYINT,
	is_recyclable_fig TINYINT,
	gross_weight DECIMAL(10,2),
	net_weight DECIMAL(10,2)
);

IF OBJECT_ID('module3.sales','U') IS NOT NULL
	DROP TABLE module3.sales
GO

CREATE TABLE module3.sales(
	product_id INT,
	store_id INT,
	customer_id INT,
	promotion_id INT,
	store_sales DECIMAL(10,2),
	store_cost DECIMAL(10,2),
	unit_solds DECIMAL(10,2),
	transaction_date DATE
);

SELECT * FROM module3.products;

SELECT * FROM module3.customers;

SELECT * FROM module3.sales;


SELECT
	S.customer_id
FROM module3.sales AS S
LEFT JOIN module3.products AS P
	ON S.product_id = P.product_id
WHERE P.brand_name = 'Amul';

SELECT
	*
FROM module3.customers
WHERE customer_id NOT IN (
				SELECT
					S.customer_id
				FROM module3.sales AS S
				LEFT JOIN module3.products AS P
					ON S.product_id = P.product_id
				WHERE P.brand_name = 'Amul'
);

SELECT
	*
FROM module3.customers AS C
WHERE NOT EXISTS(
				SELECT
					1
				FROM module3.sales AS S
				JOIN module3.products AS P
					ON P.product_id = S.product_id
				WHERE S.customer_id = C.customer_id AND P.brand_name = 'Amul'
);


/*
SELECT 6
TOP 8
DISTINCT 7
FROM 1
JOIN 2
WHERE 3
GROUP BY 4
HAVING 5
ORDER BY 9
*/

