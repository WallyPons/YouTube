/*
SQL Security: GRANT/REVOKE object permissions for a USER
*/
-- 1. Object level permissions
USE [AdventureWorks2025];
GO
-- a. Table: All basic permissions on a table
GRANT SELECT, INSERT, UPDATE, DELETE 
	ON [Person].[Address] 
	TO [Consultant1];
GO
-- b. Stored Procedure: execute permission
GRANT EXECUTE 
	ON OBJECT::[dbo].[uspLogError] 
	TO [Consultant1];
GO
-- c. View: select permission
GRANT SELECT 
	ON OBJECT::[Sales].[vSalesPerson] 
	TO [Consultant1];
GO

-- 2. Revoke permissions
-- a. UPDATE
REVOKE UPDATE ON OBJECT::[Person].[Address] 
	FROM [Consultant1];
GO
-- b. DELETE
REVOKE DELETE ON OBJECT::[Person].[Address] 
	FROM [Consultant1];
GO
/*
Don't forget to download a copy of this and other 
scripts from my GitHub repo, please check the link 
and name of the file on the video description. This 
and other solutions are given "AS IS" under no warranty 
or claim.
*/