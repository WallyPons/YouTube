/*
Normally, SQL variables are used for: 

1. Storing intermediate results like a calculation or text
2. Enhancing the complexity of stored procedures with input parameters
3. Or simplify repetitive tasks by using a variable multiple times.

You will now see some generic examples on how to manipulate variables and its types
*/

-- Basic Usage
-- 1. Declare variables
DECLARE @Value1 VARCHAR(20)
DECLARE @Value2 INT

SET @Value1 = 'This is a test'
SET @Value2 = 1

-- 2. Print one or both values
Print @Value1 
Print @Value2

-- Create an error (on purpose)
--Print @Value1 + ' ' + @Value2

-- Fix the error
-- Print @Value1 + ': ' + CONVERT(VARCHAR(1),@Value2)

--

-- Running a Select Statement
-- 1. Declare variable
DECLARE @MyExp1 VARCHAR(MAX)

-- 2. Assign SQL text to variable
SET @MyExp1 = 'SELECT name [System Databases] FROM sys.databases WHERE database_id < 5'

-- 3. Execute dynamic SQL
EXEC(@MyExp1)

---------------------------------


-- Running a Select Statement from a Temp Table
-- 1. Drop table
DROP TABLE IF EXISTS #QueryHolder

-- 2. Create and populate the temp table
CREATE TABLE #QueryHolder
(
    Id INT IDENTITY(1,1),
    Query VARCHAR(MAX)
)

INSERT INTO #QueryHolder (Query)
VALUES ('Select name FROM sys.databases WHERE database_id = 2'), -- This Id 1
       ('Select name FROM sys.databases WHERE database_id < 5'), -- This Id 2
	   ('Select @@VERSION AS [SQL Version]'),					 -- This Id 3
	   ('Select GETDATE() AS [Current Date]')					 -- This Id 4

-- 3. Declare a variable to hold the SQL
DECLARE @sql VARCHAR(MAX)

-- 4. Get the Query from the table
SELECT @sql = Query FROM #QueryHolder WHERE Id = 4

-- 5. Execute the dynamic SQL
EXEC(@sql)
GO

-- 6. Table contents
Select * From #QueryHolder;
--



-- Running a Select Statement from a Physical Table
-- 1. Drop table
DROP TABLE IF EXISTS [DB_DEMO].[dbo].[QueryHolder]

-- 2. Create and populate the table
CREATE TABLE [DB_DEMO].[dbo].[QueryHolder] 
(
    Id INT IDENTITY(1,1),
    Query VARCHAR(MAX)
)

INSERT INTO [DB_DEMO].[dbo].[QueryHolder] (Query)
VALUES ('Select name FROM sys.databases WHERE database_id = 2'), -- This Id 1
       ('Select name FROM sys.databases WHERE database_id < 5'), -- This Id 2
	   ('Select @@VERSION AS [SQL Version]'),					 -- This Id 3
	   ('Select GETDATE() AS [Current Date]')					 -- This Id 4

-- 3. Declare a variable to hold the SQL
DECLARE @sql VARCHAR(MAX)

-- 4. Get the expression from the table
SELECT @sql = Query FROM [DB_DEMO].[dbo].[QueryHolder] WHERE Id = 4

-- 5. Execute the dynamic SQL
EXEC(@sql)

Select * From [DB_DEMO].[dbo].[QueryHolder];