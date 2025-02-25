------------------Command to show DataBases ------------------

/* In comment equivalent MySql command */

SELECT name FROM sys.databases;    -- SHOW databases;

---- DDL

------------------Command to CREATE/DROP DataBases ------------------

CREATE DATABASE gds_de;

DROP DATABASE gds_de;

------------------Command to USE DataBases ------------------

USE gds_de;

------------------Command to CREATE/DROP a table ------------------

IF OBJECT_ID('employees','U') IS NULL
BEGIN
	CREATE TABLE employees(
		id INT IDENTITY(1,1) NOT NULL,
		emp_name VARCHAR(15) NOT NULL,
		salary MONEY,
		hiring DATE DEFAULT '2020-01-01',
		-- Adding Constraint ----
		CONSTRAINT unique_emp_id UNIQUE(id),
		CONSTRAINT salary_check CHECK (salary >= 1000)
	)
END;

DROP TABLE employees;

------------------Command to show TABLES ------------------

SELECT [name] FROM sys.tables;    -- SHOW tables;

------------------Command to show schema of the TABLE ------------------

EXEC sp_help 'employees';      -- DESCRIBE employees/ show create table employees

---- DML

------------------Command to insert data to the TABLE ------------------

INSERT INTO dbo.employees (emp_name,salary,hiring)
VALUES ('Manish',1000,'2025-03-10'), ('Vikas',45000,'2022-06-25');

INSERT INTO dbo.employees(emp_name,salary) VALUES ('Avinash',500);

------------------Command to delete data from the TABLE ------------------

DELETE FROM dbo.employees;

TRUNCATE TABLE dbo.employees;

--- DQL

------------------Command to view the content of the TABLE ------------------

SELECT * FROM dbo.employees;

------------------------------- ASSIGNMENTS------------------------------------

IF NOT EXISTS(SELECT * FROM sys.schemas WHERE name = 'module1' )
BEGIN
	EXEC('CREATE SCHEMA module1')
END

IF OBJECT_ID('module1.city','U') IS NULL
BEGIN
	CREATE TABLE module1.city(
		id INT,
		[name] VARCHAR(17),
		countrycode VARCHAR(3),
		district VARCHAR(20),
		[population] INT
	)
END;

EXEC sp_help 'module1.city'



