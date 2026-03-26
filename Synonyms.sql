/*
A SQL Server synonym is a database object 
that serves as an alias or alternative name 
for another database object such as a Table,
View, Stored Procedure or Function
*/
-- 1. This is how you use a synonym on a table
-- a. Change the database scope
USE [DB_DEMO];
GO
-- 2. Create or use a table with a long name
-- a. Here's an example to create a long table name
CREATE TABLE -- Max table name length is 128 chars
[DB_DEMO].[dbo].[EmployeeDataRecords_ISO_30400_series_HR]
(Employee_Id int PRIMARY KEY IDENTITY(1,1) NOT NULL,
Alias UNIQUEIDENTIFIER NOT NULL);
GO
-- 3. Add one row to the table
INSERT INTO
[DB_DEMO].[dbo].[EmployeeDataRecords_ISO_30400_series_HR]
(Alias)
VALUES (NEWID()); -- Alias = GUID
GO
-- 4. Create a synonym for the table
CREATE SYNONYM 
[dbo].[EmployeeV1] -- Synonym name
FOR 
[DB_DEMO].[dbo].[EmployeeDataRecords_ISO_30400_series_HR];
GO
-- 5. Query the source table and synonym, the results
-- will be the same in both cases
-- a. Results for the table:
SELECT TOP 1 * 
FROM 
[DB_DEMO].[dbo].[EmployeeDataRecords_ISO_30400_series_HR];
-- b. Results for the synonym:
SELECT * 
FROM [DB_DEMO].[dbo].[EmployeeV1];














/*
-- 1. If you need drop a synomyn:
USE [DB_DEMO];
GO

DROP SYNONYM [dbo].[EmployeeV1];
GO

-- 2. If you need to drop the table
USE [DB_DEMO];
GO

DROP TABLE 
[DB_DEMO].[dbo].[EmployeeDataRecords_ISO_30400_series_HR];
*/

