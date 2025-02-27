----------------------------- MODULE 4 -----------------------------

USE gds_de;

------ Self Join ----------------

IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'module4')
BEGIN 
	EXEC('CREATE SCHEMA module4')
END
GO

IF OBJECT_ID('module4.managers','U') IS NOT NULL
	DROP TABLE module4.managers
GO

CREATE TABLE module4.managers(
	emp_id INT,
	[name] VARCHAR(15),
	manager_id INT
);

SELECT * FROM module4.managers;

SELECT
	E.*,
	ISNULL(M.[name],'N/A') AS manager,
	CASE
		WHEN E.manager_id IS NULL THEN 'CEO/Founder'
		WHEN E.emp_id NOT IN (SELECT DISTINCT manager_id FROM module4.managers WHERE manager_id IS NOT NULL) THEN 'Employee'
		ELSE 'Manager'
	END AS 'position'
FROM module4.managers AS E
LEFT JOIN module4.managers AS M
	ON E.manager_id = M.emp_id;

-------- ANY -------------

IF OBJECT_ID('module4.students','U') IS NOT NULL
	DROP TABLE module4.students
GO

CREATE TABLE module4.students(
	studentID INT,
	studentName VARCHAR(15)
);

IF OBJECT_ID('module4.courses','U') IS NOT NULL
	DROP TABLE module4.courses
GO

CREATE TABLE module4.courses(
	courseID INT,
	courseName VARCHAR(20)
);

IF OBJECT_ID('module4.enrollments','U') IS NOT NULL
	DROP TABLE module4.enrollments
GO

CREATE TABLE module4.enrollments(
	studentID INT,
	courseID INT
);

SELECT * FROM module4.enrollments;

SELECT * FROM module4.students;

SELECT * FROM module4.courses;

SELECT
	DISTINCT S.studentName
FROM module4.students AS S
JOIN module4.enrollments AS E
	ON S.studentID = E.StudentID
WHERE S.studentName <> 'Amit' AND E.courseID = ANY (
					SELECT
						E.courseID
					FROM module4.students AS S
					JOIN module4.enrollments AS E
						ON S.studentID = E.StudentID
					WHERE S.studentName = 'Amit'
);


IF OBJECT_ID('module4.products','U') IS NOT NULL
	DROP TABLE module4.products
GO

CREATE TABLE module4.products(
	productID INT,
	productName VARCHAR(20),
	price DECIMAL(5,2)
);


IF OBJECT_ID('module4.orders','U') IS NOT NULL
	DROP TABLE module4.orders
GO

CREATE TABLE module4.orders(
	orderID INT,
	customerID INT,
	orderDate DATE
);

IF OBJECT_ID('module4.customers','U') IS NOT NULL
	DROP TABLE module4.customers
GO

CREATE TABLE module4.customers(
	customerID INT,
	customerName VARCHAR(20)
);

SELECT * FROM module4.orders;

SELECT * FROM module4.products;


SELECT
	DISTINCT productID
FROM module4.products
WHERE price < ALL (
					SELECT
						P.price
					FROM module4.orders AS O
					JOIN module4.products AS P
						ON P.productID = O.productID
					WHERE O.orderID = 103
);

----- EXISTS/ NOT EXISTS -----------------

SELECT * FROM module4.customers;

SELECT * FROM module4.orders;



SELECT
	customerID,customerName
FROM module4.customers AS C
WHERE NOT EXISTS(
						SELECT
							1
						FROM module4.orders AS O
						WHERE O.customerID = C.customerID
)

--------------- WINDOW FUNCTION ------------------------

IF OBJECT_ID('module4.shop_sales_data','U') IS NOT NULL
	DROP TABLE module4.shop_sales_data
GO

CREATE TABLE module4.shop_sales_data(
	sales_date DATE,
	shop_id VARCHAR(5),
	sales_amt INT
);

SELECT
	*,
	SUM(sales_amt) OVER(PARTITION BY shop_id) AS total_sales
FROM module4.shop_sales_data;

SELECT
	*,
	SUM(sales_amt) OVER(ORDER BY sales_amt DESC) AS total_sales
FROM module4.shop_sales_data;

SELECT
	*,
	SUM(sales_amt) OVER(PARTITION BY shop_id ORDER BY sales_amt DESC) AS running_sum_of_sales,
	AVG(sales_amt) OVER(PARTITION BY shop_id ORDER BY sales_amt DESC) AS running_avg_of_sales,
	MAX(sales_amt) OVER(PARTITION BY shop_id ORDER BY sales_amt DESC) AS running_max_of_sales,
	MIN(sales_amt) OVER(PARTITION BY shop_id ORDER BY sales_amt DESC) AS running_min_of_sales
FROM module4.shop_sales_data;

IF OBJECT_ID('module4.amazon_sales_data','U') IS NOT NULL
	DROP TABLE module4.amazon_sales_data
GO

CREATE TABLE module4.amazon_sales_data(
	sales_date DATE,
	sales_amt INT
);


--- LAST 7 DAYS ----
SELECT 
	TOP 7
	*,
	AVG(sales_amt) OVER(ORDER BY sales_date DESC) AS rolling_avg,
	ROW_NUMBER() OVER(ORDER BY sales_date DESC) AS [row_number]
FROM module4.amazon_sales_data;

------- RANK, ROW, DENSE-RANK ------------------
SELECT 
	*,
	ROW_NUMBER() OVER(ORDER BY sales_amt DESC) AS [row_number],
	RANK() OVER(ORDER BY sales_amt DESC) AS [rank],
	DENSE_RANK() OVER(ORDER BY sales_amt DESC) AS [dense_rank]
FROM module4.amazon_sales_data;

IF OBJECT_ID('module4.employees','U') IS NOT NULL
	DROP TABLE module4.employees
GO

CREATE TABLE module4.employees(
	emp_id INT,
	salary INT,
	dept_name VARCHAR(30)
);

SELECT 
	*
FROM module4.employees
ORDER BY salary DESC;

-- Get employee that have maximum salary only one
WITH RankedSalary
AS (
	SELECT 
		*,
		ROW_NUMBER() OVER(PARTITION BY dept_name ORDER BY salary DESC) AS row_salary
	FROM module4.employees
)
SELECT
	*
FROM RankedSalary
WHERE row_salary = 1;

-- Get employee that have maximum salary (all)
WITH RankedSalary
AS (
	SELECT 
		*,
		RANK() OVER(PARTITION BY dept_name ORDER BY salary DESC) AS rank_salary
	FROM module4.employees
)
SELECT
	*
FROM RankedSalary
WHERE rank_salary = 1;

-- Get TOP 2 employee that have maximum salary 

WITH RankedSalary
AS (
	SELECT 
		*,
		DENSE_RANK() OVER(PARTITION BY dept_name ORDER BY salary DESC) AS dense_rank_salary
	FROM module4.employees
)
SELECT
	*
FROM RankedSalary
WHERE dense_rank_salary <= 2;

--------------------- LEAD / LAG --------------------

IF OBJECT_ID('module4.daily_sales','U') IS NOT NULL
	DROP TABLE module4.daily_sales
GO

CREATE TABLE module4.daily_sales(
	sales_date DATE,
	sales_amt INT
);


SELECT
	YEAR(sales_date) AS sales_year,
	MONTH(sales_date) AS sales_month,
	sales_amt,
	LAG(sales_amt,1,0) OVER(PARTITION BY YEAR(sales_date) ORDER BY YEAR(sales_date),DATEPART(QUARTER,sales_date)) AS prev_sales,
	sales_amt - LAG(sales_amt,1,0) OVER(PARTITION BY YEAR(sales_date) ORDER BY YEAR(sales_date),DATEPART(QUARTER,sales_date)) AS sales_difference
FROM module4.daily_sales;

SELECT
	YEAR(sales_date) AS sales_year,
	MONTH(sales_date) AS sales_month,
	sales_amt,
	LEAD(sales_amt,1,0) OVER(PARTITION BY YEAR(sales_date) ORDER BY YEAR(sales_date),DATEPART(QUARTER,sales_date)) AS next_sales,
	sales_amt - LEAD(sales_amt,1,0) OVER(PARTITION BY YEAR(sales_date) ORDER BY YEAR(sales_date),DATEPART(QUARTER,sales_date)) AS sales_difference
FROM module4.daily_sales
WHERE YEAR(sales_date) = 2023;


---------  FRAME CLAUSE ----------------

SELECT
	YEAR(sales_date) AS sales_year,
	MONTH(sales_date) AS sales_month,
	sales_amt,
	SUM(sales_amt) OVER(ORDER BY YEAR(sales_date) ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS rolling_sums
FROM module4.daily_sales
WHERE YEAR(sales_date) = 2023;


/*
* RANGE in SQL Server only works with:
	UNBOUNDED PRECEDING
	CURRENT ROW
* ROWS BETWEEN is required for row-based calculations.
*/

----------------- Common Table Expression ----------------------

IF OBJECT_ID('module4.amazon_emp','U') IS NOT NULL
	DROP TABLE module4.amazon_emp
GO

CREATE TABLE module4.amazon_emp(
	emp_id INT,
	emp_name VARCHAR(20),
	dept_id INT,
	salary  INT
);

IF OBJECT_ID('module4.department','U') IS NOT NULL
	DROP TABLE module4.department
GO

CREATE TABLE module4.department(
	dept_id INT,
	dept_name VARCHAR(20)
);


SELECT * FROM module4.amazon_emp;


WITH groupedrecords
AS (
	SELECT
		dept_id,
		AVG(salary) AS avg_salaries,
		COUNT(*) AS No_of_emp,
		STRING_AGG(emp_name,' | ') AS list_of_emp
	FROM module4.amazon_emp
	GROUP BY dept_id
)
SELECT
	*,
	CASE
		WHEN avg_salaries < 70000 THEN 'Emp'
		WHEN avg_salaries < 90000 THEN 'Manager'
		ELSE 'Head'
	END AS designation
FROM groupedrecords
ORDER BY avg_salaries DESC;
	
WITH joinedTable
AS(
	SELECT
		D.*,
		E.salary
	FROM module4.department AS D
	LEFT JOIN module4.amazon_emp AS E
		ON D.dept_id = E.dept_id
	WHERE E.emp_id IS NOT NULL
)
SELECT
	dept_id,
	dept_name,
	SUM(salary) AS total_salaries
FROM joinedTable
GROUP BY dept_id,dept_name;


WITH dept_wise_salary
AS
(
	SELECT
		dept_id,
		SUM(salary) AS total_salary,
		STRING_AGG(salary,' | ') AS salary_list
	FROM module4.amazon_emp
	GROUP BY dept_id
),
max_dept_salary
AS
(
	SELECT
		dept_id,
		MAX(salary) AS max_salary,
		COUNT(*) AS total_number
	FROM module4.amazon_emp	
	GROUP BY dept_id
)
SELECT
	D.dept_name,
	DS.total_salary,
	MS.max_salary,
	MS.total_number,
	DS.salary_list
FROM module4.department AS D
JOIN dept_wise_salary AS DS
	ON DS.dept_id = D.dept_id
JOIN max_dept_salary AS MS
	ON MS.dept_id = D.dept_id

-------- RECURSIVE CTE -----------------

/*
Recursive CTEs are useful for working with heirarical or tree-structure data.
*/

WITH cte_n
AS
(
	SELECT 1 AS number
	UNION ALL
	SELECT number + 1
	FROM cte_n
	WHERE number < 10
)

SELECT
	number
FROM cte_n
OPTION (MAXRECURSION 100);

/*
SQL Server does not support WITH RECURSIVE. Instead, SQL Server only supports the WITH keyword for CTEs.
*/

/*
WITH RECURSIVE cte_n AS (
    SELECT 1 AS number  -- 🔹 Base Case: Start with number = 1
    UNION ALL
    SELECT number + 1   -- 🔹 Recursive Case: Increment number by 1
    FROM cte_n
    WHERE number < 10   -- 🔹 Termination Condition: Stop when number reaches 10
)
SELECT number FROM cte_n;  -- 🔹 Final Output
*/

IF OBJECT_ID('module4.emp_mgr','U') IS NOT NULL
	DROP TABLE module4.emp_mgr
GO

CREATE TABLE module4.emp_mgr(
	id INT,
	name VARCHAR(20),
	manager_id INT,
	designation VARCHAR(20),
	PRIMARY KEY(id)
);

SELECT * FROM module4.emp_mgr;

--SELECT
--	E.id,
--	E.[name],
--	E.designation,
--	M.[name] AS manager
--FROM module4.emp_mgr AS E
--LEFT JOIN module4.emp_mgr AS M
--	ON E.manager_id = M.id;

IF OBJECT_ID('module4.sp_recursive_cte','P') IS NOT NULL
	DROP PROCEDURE module4.sp_recursive_cte
GO

CREATE PROCEDURE module4.sp_recursive_cte (@name VARCHAR(15))
AS
BEGIN
	WITH emp_hir
	AS
	(
		SELECT id,[name],manager_id,designation,1 AS [level]
		FROM module4.emp_mgr
		WHERE [name] = @name
		UNION ALL
		SELECT 
			EM.id,EM.[name],EM.manager_id,EM.designation,EH.[level] + 1
		FROM emp_hir AS EH
		JOIN module4.emp_mgr AS EM
			ON EH.id = EM.manager_id
	)
	SELECT
		*
	FROM emp_hir
END;

EXEC module4.sp_recursive_cte 'Bob';

--------------  VIEWs -----------------

SELECT * FROM module4.employees;

IF OBJECT_ID('module4.vw_avg_wise_salary','V') IS NOT NULL
	DROP VIEW module4.vw_avg_wise_salary
GO

CREATE VIEW module4.vw_avg_wise_salary
AS
SELECT
	dept_name,
	AVG(salary) AS avg_salary_per_dept
FROM module4.employees
GROUP BY dept_name;

SELECT * FROM module4.vw_avg_wise_salary;

------- INDEXING -----------------

