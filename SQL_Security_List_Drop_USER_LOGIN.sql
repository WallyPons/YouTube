/*
SQL Security: List/Drop SQL LOGIN and SQL USER
*/
-- 1. List LOGINS
USE [master];
GO

SELECT sid, name, type, type_desc
FROM master.sys.server_principals
WHERE type IN ('S', 'U')
-- S: SQL LOGIN | U: Windows LOGIN
AND name not like '%#%';

-- 2. List database USERS
USE [AdventureWorks2025];
GO

SELECT sid, name, type, type_desc 
FROM sys.database_principals;

-- 3. Drop database USER Consultant1 (First step)
IF EXISTS (SELECT 1 FROM sys.database_principals 
WHERE name = 'Consultant1') DROP USER [Consultant1];
GO

-- 4. Drop SQL LOGIN Consultant1 (Final step)
USE [master];
GO

IF EXISTS (SELECT 1 FROM sys.server_principals 
WHERE name = 'Consultant1') DROP LOGIN [Consultant1];
GO
/*
Don't forget to download a copy of this and other 
scripts from my GitHub repo, please check the link 
and name of the file on the video description. This 
and other solutions are given "AS IS" under no warranty 
or claim.
*/