/*
-------------------------------------------------------------
Function to calculate age by years, months and days 
using MS SQL Server
-------------------------------------------------------------
For a quick contact:
Web: https://datagrupo.com
Email: wpons@datagrupo.com
-------------------------------------------------------------
*/

-- SQL SCALAR FUNCTION
CREATE OR ALTER FUNCTION dbo.fn_GetHumanAge 
(@DOB DATETIME) RETURNS NVARCHAR(100)
	
	AS
	BEGIN

    DECLARE @TotalDays INT,
            @Year INT,
            @RemainingDays INT,
            @Month INT,
            @Day INT,
            @Result NVARCHAR(100)
    -- Set values
    SET @TotalDays = DATEDIFF(DAY, @DOB, GETDATE())
    SET @Year = FLOOR(@TotalDays / 365.25)
    SET @RemainingDays = @TotalDays % 365.25
    SET @Month = FLOOR(@RemainingDays / 30.4375)
    SET @Day = FLOOR(@RemainingDays % 30.4375)
    -- Convert results
    SET @Result
        = CAST(@Year AS NVARCHAR(3)) + ' Years, ' + CAST(@Month AS NVARCHAR(2)) + ' Month(s), and '
          + CAST(@Day AS NVARCHAR(2)) + ' Days old'
    -- Return result
    RETURN @Result
END;
GO

-- To use the function on a one-liner
SELECT dbo.fn_GetHumanAge('1990-04-21') AS Age;

-- To use the function on an existing table
DROP TABLE IF EXISTS #Person  
CREATE TABLE #Person (PersonName VARCHAR(20), DateOfBirth DATETIME)
INSERT INTO #Person (PersonName, DateOfBirth) Values ('Steven', '1990-04-21')


-- Example from a temp table (Make sure to use the DB containing the function ;))
SELECT	PersonName, 
		dbo.fn_GetHumanAge(DateOfBirth) AS HumanAge, 
		DateOfBirth AS DOB
FROM #Person;

-- Example from a real table
SELECT	PersonName, 
		dbo.fn_GetHumanAge(DateOfBirth) AS HumanAge, 
		DateOfBirth AS DOB
FROM DB_DEMO.dbo.Person;

-- List current functions
SELECT 
    DB_NAME() AS [Database Name],
	name AS FunctionName,
    SCHEMA_NAME(schema_id) AS SchemaName,
    type_desc AS FunctionType,
    create_date,
    modify_date
FROM 
    sys.objects
WHERE 
    type IN ('FN', 'IF', 'TF') -- FN = scalar, IF = inline table-valued, TF = multi-statement table-valued
ORDER BY 
    SchemaName, FunctionName;