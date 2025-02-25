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
