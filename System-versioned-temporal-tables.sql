/*
Database that I use, you can create another database if you wish to do so, 
just remember to reference it on the script
*/

USE [HISTORY_DEMO];
GO

-- 1. Create Table with history table
CREATE TABLE [HISTORY_DEMO].[dbo].[TblCustomers]
(
Cust_Id BIGINT IDENTITY(1,1) CONSTRAINT PK_Customers PRIMARY KEY,
Cust_Creation_Date DATETIME DEFAULT GETDATE(),
Cust_Salutation VARCHAR(10),
Cust_Name VARCHAR(30),
Cust_MI VARCHAR(2),
Cust_Last VARCHAR(30),
Cust_Category INT DEFAULT (0),
Cust_Region INT DEFAULT (0),
--
StartTime DATETIME2(7) GENERATED ALWAYS AS ROW START HIDDEN NOT NULL,
EndTime DATETIME2(7) GENERATED ALWAYS AS ROW END HIDDEN NOT NULL,
PERIOD FOR SYSTEM_TIME (StartTime, EndTime)
--
)
WITH (SYSTEM_VERSIONING = ON 
      (HISTORY_TABLE = [dbo].[TblCustomersHistory],
       DATA_CONSISTENCY_CHECK = ON,
       HISTORY_RETENTION_PERIOD = 1 YEAR)  -- optional, only in SQL Server 2022+ may include (INFINITE, DAY, DAYS, WEEK, WEEKS, MONTH, MONTHS, YEAR, YEARS)
     );
GO

Select 	object_id ,
	name, 
	history_retention_period, 
	history_retention_period_unit_desc, 
	history_table_id 
From sys.tables

--  As a test, alter an exisitng table
CREATE TABLE [HISTORY_DEMO].[dbo].[TblProducts]
(
Prod_Id BIGINT IDENTITY(1,1) PRIMARY KEY,
Prod_Code VARCHAR(50) NOT NULL,
Prod_Alternate_Code VARCHAR(50) NOT NULL,
Prod_Desc VARCHAR(50) NOT NULL,
Prod_Std_Cost DECIMAL(18,2) NOT NULL,
Prod_Std_Price DECIMAL(18,2) NOT NULL,
Prod_Locked BIT DEFAULT (0) NOT NULL
);

-- Alter commands:

ALTER TABLE [dbo].[TblProducts] ADD
    StartTime DATETIME2 GENERATED ALWAYS AS ROW START HIDDEN NOT NULL DEFAULT '1900-01-01 00:00:00.0000000',
    EndTime   DATETIME2 GENERATED ALWAYS AS ROW END HIDDEN NOT NULL DEFAULT '9999-12-31 23:59:59.9999999',
    PERIOD FOR SYSTEM_TIME (StartTime, EndTime);

/*
Note: The DEFAULT values are crucial when adding NOT NULL columns to an existing table with data, as they provide values for existing rows. Choose default values that are appropriate for your data's historical context.
*/

ALTER TABLE [dbo].[TblProducts]
SET (SYSTEM_VERSIONING = ON
    (HISTORY_TABLE = [dbo].[TblProductsHistory], 
     DATA_CONSISTENCY_CHECK = ON,
     HISTORY_RETENTION_PERIOD = 1 YEAR)
);


Select Name From sys.tables Where name like 'TblProducts%'



-- 2. Insert some sample data
INSERT INTO [HISTORY_DEMO].[dbo].[TblCustomers]
(
    Cust_Salutation,
    Cust_Name,
    Cust_MI,
    Cust_Last
)
VALUES
('Mr.', 'Alan', 'J', 'Kniptiq'),
('Miss', 'Lisa', 'A', 'Thompson'),
('Mrs', 'Laura', 'B', 'Thompson'),
('Lord', 'Phenek', 'M', 'Galdorf'),
('Sir', 'Ivan', 'O', 'Morthensen')


-- 3. View sample data, we'll use these queries often

-- a. Normal select statement
Select * From [HISTORY_DEMO].[dbo].[TblCustomers];
Select * From [HISTORY_DEMO].[dbo].[TblCustomersHistory];

-- b. Select using a FOR SYSTEM_TIME ALL query option
SELECT * FROM [HISTORY_DEMO].[dbo].[TblCustomers] FOR SYSTEM_TIME ALL
SELECT * FROM [HISTORY_DEMO].[dbo].[TblCustomers] FOR SYSTEM_TIME ALL WHERE Cust_Id = 1;

-- 4. Other actions
-- a. Update a record and view step #3
UPDATE [HISTORY_DEMO].[dbo].[TblCustomers] SET Cust_Category = 1 WHERE Cust_Id = 1;

-- b. Delete one row and view step #3
DELETE FROM [HISTORY_DEMO].[dbo].[TblCustomers] WHERE Cust_Id = 1;

-- c. Truncate table it is not a supported operation on system-versioned tables, try it anyways
-- Optionally you can use DELETE
TRUNCATE TABLE [HISTORY_DEMO].[dbo].[TblCustomers];

-- d. Delete all records and view step #3
DELETE FROM [HISTORY_DEMO].[dbo].[TblCustomers];

-- Testing security
-- 1. Create SQL Login
USE [master]
GO
CREATE LOGIN [NoHistory]
WITH PASSWORD = N'N0H1st0rY4u!',
     DEFAULT_DATABASE = [master],   -- Default Database
     CHECK_EXPIRATION = OFF,        -- Expiration policy for the password?
     CHECK_POLICY = ON              -- Force complex password
GO

-- 2. Create database user (user mapping)
USE [HISTORY_DEMO];
GO
CREATE USER [NoHistory] FOR LOGIN [NoHistory] WITH DEFAULT_SCHEMA=[dbo];
GO

-- 3. Grant roles
USE [HISTORY_DEMO];
GO
GRANT SELECT, INSERT, UPDATE, DELETE ON [dbo].[TblCustomers] TO [NoHistory];
GO

-- 4. Deny any access to the history table, including those they might have granted
USE [HISTORY_DEMO];
GO
DENY DELETE, INSERT, SELECT, UPDATE ON OBJECT::[dbo].[TblCustomersHistory] TO [NoHistory] CASCADE;
GO

-- Run the test: You need to login as NoHistory
USE [HISTORY_DEMO]
GO

-- 1. Show me who you are
Declare @DBName as VARCHAR(128) = db_name()
Declare @UserName as NVARCHAR(128) = SUSER_NAME()
Print 'Current Database  : ' + @DBName
Print 'Current User name : ' + @UserName

-- 2. Do an insert, update, select and delete :)
-- a. Insert
INSERT INTO [HISTORY_DEMO].[dbo].[TblCustomers]
(
    Cust_Salutation,
    Cust_Name,
    Cust_MI,
    Cust_Last
)
VALUES
('Mr.', 'Don', 'A', 'Paul');

-- b. Update
UPDATE [HISTORY_DEMO].[dbo].[TblCustomers] SET Cust_Name = 'Dennster' WHERE Cust_Last = 'Paul';

-- c. Select
SELECT * FROM [HISTORY_DEMO].[dbo].[TblCustomers];

-- d. Delete
DELETE FROM [HISTORY_DEMO].[dbo].[TblCustomers];

-- 3. Read from the history table
SELECT * FROM [HISTORY_DEMO].[dbo].[TblCustomersHistory];

-- Drop tables

-- 1. Drop temporal table 
-- a. Disable system versioning
ALTER TABLE [HISTORY_DEMO].[dbo].[TblCustomers] SET (SYSTEM_VERSIONING = OFF);
-- b. Drop both tables
DROP TABLE [HISTORY_DEMO].[dbo].[TblCustomers];
DROP TABLE [HISTORY_DEMO].[dbo].[TblCustomersHistory];
-- c. List all tables
Select name FROM sys.tables;

