-- This is a simple demo on Logins and Users
-- 1. Create a database for the purpose
USE [master]
GO
CREATE DATABASE [LoginTestingDemo];
GO

-- 2. Create a table
-- a. Define table structure
CREATE TABLE 
[LoginTestingDemo].[dbo].[TblDepts]
(
[Id] [bigint] IDENTITY(1,1) NOT NULL,
[Company_Id] [int] NOT NULL,
[Dept_Id] [int] NOT NULL,
[Dept_Desc] [varchar](30)NOT NULL,
[Dept_Notes] [varchar](200)NULL,
[Locked] [bit] NOT NULL,
[CreatedBy] nvarchar(128),
 CONSTRAINT [PK_TblDepts] 
 PRIMARY KEY CLUSTERED 
(
[Id] ASC
)WITH 
(PAD_INDEX = OFF, 
STATISTICS_NORECOMPUTE = OFF, 
IGNORE_DUP_KEY = OFF, 
ALLOW_ROW_LOCKS = ON, 
ALLOW_PAGE_LOCKS = ON, 
OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) 
ON [PRIMARY]
) ON [PRIMARY];
GO

-- b. Table constraints (default)
-- c. Locked
ALTER TABLE [LoginTestingDemo].[dbo].[TblDepts] 
ADD CONSTRAINT [DF_TblDepts_Locked_Bit]  
DEFAULT ((0)) FOR [Locked];
-- d. CreatedBy
ALTER TABLE [LoginTestingDemo].[dbo].[TblDepts] 
ADD CONSTRAINT [DF_TblDepts_CreatedBy]  
DEFAULT (SUSER_NAME()) FOR [CreatedBy];
GO

-- 3. Create two SQL Logins
-- This works at the server level
USE [master]
GO

-- a. User1
CREATE LOGIN [User1]
WITH PASSWORD = N'S0m3$7FB49@27r571',
     -- Default Database
     DEFAULT_DATABASE = [master],   
     -- No expiration policy for the password
     CHECK_EXPIRATION = OFF,        
     -- Force complex password
     CHECK_POLICY = ON              

-- b. User2
CREATE LOGIN [User2]
WITH PASSWORD = N'S0m3$81BG9@27r97y',
     -- Default Database
     DEFAULT_DATABASE = [master],   
     -- No expiration policy for the password
     CHECK_EXPIRATION = OFF,        
     -- Force complex password
     CHECK_POLICY = ON              

-- 4. Create database users (user mapping)
-- a. Change database connection scope

USE [LoginTestingDemo];
GO

-- b. Create user User1
CREATE USER [User1]
-- c. Associate to SQL login
FOR LOGIN [User1] 
-- d. Default it to a schema (optional)
WITH DEFAULT_SCHEMA=[dbo];
GO

-- e. Create user User2
CREATE USER [User2]
-- f. Associate to SQL login
FOR LOGIN [User2] 
-- g. Default it to a schema (optional)
WITH DEFAULT_SCHEMA=[dbo];
GO

-- 5. Table permissions
-- a. Change database connection scope
-- b. User1
USE [LoginTestingDemo];
GO
GRANT SELECT, INSERT, UPDATE, DELETE 
ON [dbo].[TblDepts] TO [User1];
GO
-- c. Grant IMPERSONATE (To run EXECUTE AS)
USE master;
GO
GRANT IMPERSONATE ON LOGIN::[User2] TO [User1];
GO

-- d. User2
USE [LoginTestingDemo];
GO
GRANT SELECT, INSERT, UPDATE 
ON [dbo].[TblDepts] TO [User2];
GO
-- e. Grant IMPERSONATE (To run EXECUTE AS)
USE master;
GO
GRANT IMPERSONATE ON LOGIN::[User1] TO [User2];
GO


-- 6. Test permissions
-- a. User1
-- b. Change database connection scope
USE [LoginTestingDemo];
GO
EXECUTE AS LOGIN = 'User1';

-- c. Insert one row
INSERT INTO 
[LoginTestingDemo].[dbo].[TblDepts]
(Company_Id, Dept_Id, Dept_Desc)
VALUES
(1,1,'Sales & Marketing'),
(1,2,'Accounting');

-- d. View row data
Select 
    Id, 
    Company_Id, 
    Dept_Id, 
    Dept_Notes, 
    Locked, 
    CreatedBy
From [LoginTestingDemo].[dbo].[TblDepts];

-- e. Verify user
Select SUSER_NAME() AS CurrentUser;

-- f. User2
-- g. Change database connection scope
USE [LoginTestingDemo];
GO
EXECUTE AS LOGIN = 'User2';

-- h. Insert one row
INSERT INTO 
[LoginTestingDemo].[dbo].[TblDepts]
(Company_Id, Dept_Id, Dept_Desc)
VALUES
(1,3,'eCommerce');

-- i. View row data
Select 
    Id, 
    Company_Id, 
    Dept_Id, 
    Dept_Notes, 
    Locked, 
    CreatedBy
From [LoginTestingDemo].[dbo].[TblDepts];

-- j. Verify current user
Select SUSER_NAME() AS CurrentUser;

-- k. Test DELETE, it should be denied
DELETE FROM [LoginTestingDemo].[dbo].[TblDepts]
WHERE Dept_Id = 1;



















/*
DROP Logins and Users
-----------------------
-- 1. Delete SQL logins
USE [master]
GO

-- a. User1
REVOKE IMPERSONATE ON LOGIN::[User1] FROM [User2];
GO

DROP LOGIN [User1]
GO

-- b. User2
REVOKE IMPERSONATE ON LOGIN::[User2] FROM [User1];
GO

DROP LOGIN [User2]
GO

-- 2. Delete database users
USE [LoginTestingDemo]
GO

-- a. User 1
DROP USER [User1]
GO

-- b. User 2
DROP USER [User2]
GO

-- 3. Drop database
USE [master]
GO

DROP DATABASE [LoginTestingDemo];
GO

Note: 
1. You might need to run sp_who2
and kill some connections that 
could be open

2. Use a different connection user
with higher privileges. otherwise
you won't be able to drop the
database.
*/ 