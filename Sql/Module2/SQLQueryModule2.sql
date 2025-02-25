------------------------- MODULE 2 -----------------------------

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE [name] = 'module2')
BEGIN
	EXECUTE('CREATE SCHEMA module2')
END


IF OBJECT_ID('module2.employees','U') IS NULL
BEGIN
	CREATE TABLE module2.employees(
		id INT,
		[name] VARCHAR(50),
		age INT,
		hiring_date DATE,
		salary MONEY,
		city VARCHAR(50)
	)
END;

DROP TABLE module2.employees;

------ ALTER Command------------
ALTER TABLE module2.employees
ADD dob DATE; 

ALTER TABLE module2.employees
ALTER COLUMN [name] VARCHAR(100);  ---- MODIFY COLUMN name varchar(100)

ALTER TABLE module2.employees
DROP COLUMN city;

ALTER TABLE module2.employees
ADD CONSTRAINT id_unique UNIQUE(id);

ALTER TABLE module2.employees
ADD CONSTRAINT salary_check CHECK (salary >= 1000);

ALTER TABLE module2.employees
DROP CONSTRAINT id_unique;

EXEC sp_rename 'module2.employees.[name]','fullname','COLUMN';
/*
ALTER TABLE module2.employees
RENAME COLUMN [name] TO fullname;
*/

EXEC sp_help 'module2.employees';

INSERT INTO module2.employees (id, [name], age, hiring_date, salary, city)
VALUES 
    (1, 'John Doe', 30, '2020-06-15', 55000.00, 'New York'),
    (2, 'Jane Smith', 28, '2021-09-20', 62000.50, 'Los Angeles'),
    (3, 'Robert Brown', 35, '2019-03-10', 75000.75, 'Chicago'),
    (4, 'Emily White', 25, '2022-11-05', 48000.25, 'Houston'),
    (5, 'Michael Green', 40, '2015-07-30', 90000.00, 'Miami');

--DELETE FROM module2.employees WHERE id = 1;

SELECT * FROM module2.employees;

-------- PRIMARY KEY CONSTRAINT ----------------

IF OBJECT_ID('module2.guest','U') IS NULL
BEGIN
	CREATE TABLE module2.guest(
		id INT,
		[name] VARCHAR(25),
		age INT,
		CONSTRAINT pk PRIMARY KEY(id)
	)
END;

INSERT INTO module2.guest (id, [name], age)
VALUES 
    (null, 'John Doe', 30);

SELECT * FROM module2.guest;

------ FORIGN KEY CONSTRAINT -----------

IF OBJECT_ID('module2.customer','U') IS NULL
BEGIN
	CREATE TABLE module2.customer(
		cust_id INT,
		[name] VARCHAR(25),
		age INT,
		CONSTRAINT pk_cust PRIMARY KEY(cust_id)
	)
END;

IF OBJECT_ID('module2.orders','U') IS NULL
BEGIN
	CREATE TABLE module2.orders(
		order_id INT,
		amount INT,
		customer_id INT,
		CONSTRAINT pk_order PRIMARY KEY(order_id),
		CONSTRAINT fk_cust FOREIGN KEY(customer_id) REFERENCES module2.customer(cust_id)
	)
END;

-- It will not allow to insert because referencial integrity will violate

INSERT INTO module2.orders (order_id, amount, customer_id)
VALUES 
    (110, 500, 11),

SELECT * FROM module2.customer;

SELECT * FROM module2.orders

--------------------------- Functions ------------------------------------

/*
Functions in MySQL are reusable blocks of code that perform a specific task and return a single value.
*/

-- predefined function

-- count(*)/count(1)   -- */1/ect is just a marker to each row

SELECT COUNT(*) AS total_row_count FROM module2.customer;

-- specific column

SELECT 
	[name] AS emp_name,
	age AS emp_age 
FROM module2.customer;

---- DISTINCT ----

SELECT 
	DISTINCT hiring_date AS distinct_hiring_date
FROM module2.employees;

---- COUNT of DISTINCT ----

SELECT 
	COUNT(DISTINCT hiring_date) AS count_of_distinct_hiring_date
FROM module2.employees;

SELECT 
	id,
	[name],
	age,
	hiring_date,
	salary AS old_salary,
	CAST((1.2 * salary) AS DECIMAL(8,2)) AS new_salary
FROM module2.employees;

-------- UPDATE statement ----

UPDATE module2.employees
SET salary = 1.2 * salary;

SELECT * FROM module2.employees;

-------------- WHERE clause --------

SELECT * FROM module2.employees
WHERE hiring_date = (SELECT MIN(hiring_date) FROM module2.employees);

SELECT TOP 1 * FROM module2.employees ORDER BY salary DESC;