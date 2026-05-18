/*
SQL Security: Creating a SQL LOGIN and USER
*/
-- 1. Create SQL LOGIN (server level only)
USE [master]
GO
CREATE LOGIN [Consultant1]		   -- SQL LOGIN name
WITH PASSWORD = N'G0svn@kgsax!k3', -- Complex PASSWORD
DEFAULT_DATABASE = [master], -- Default Database
CHECK_EXPIRATION = ON,       -- Expires in 42 days
CHECK_POLICY = ON            -- Force complex PASSWORD
GO
-- 2. Create database USER (USER mapping from a LOGIN)
USE [AdventureWorks2025]; -- Or any other database
GO
CREATE USER [Consultant1] -- A USER relies on a LOGIN
FOR LOGIN [Consultant1]   -- Specify the LOGIN
WITH DEFAULT_SCHEMA=[dbo];-- This is optional
GO

-- 3. Optional Roles (you may specify object permissions)
USE [AdventureWorks2025]; 
GO
-- a. Can read from all tables
ALTER ROLE [db_datareader] ADD MEMBER [Consultant1] 
-- b. Can write to all tables
ALTER ROLE [db_datawriter] ADD MEMBER [Consultant1] 
-- c. Can run DDL (CREATE, ALTER, DROP of DB objects)
ALTER ROLE [db_ddladmin] ADD MEMBER [Consultant1]   
GO
/*
Don't forget to download a copy of this and other 
scripts from my GitHub repo, please check the link 
and name of the file on the video description. This 
and other solutions are given "AS IS" under no warranty 
or claim.
*/