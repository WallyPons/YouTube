/*
DBCC (Transact-SQL)

The Transact-SQL programming language provides 
DBCC statements that act as Database Console 
Commands for SQL Server. Here you can see how to
generate a schema-only, read-only copy of a user 
database by using DBCC CLONEDATABASE in order to 
investigate performance issues related to the query 
optimizer.
*/

-- 1. Create a clone of the AdventureWorks2025 
DBCC CLONEDATABASE 
	(AdventureWorks2025,		-- Source database
	AdventureWorks2025_Clone)	-- New database
	-- Some basic options:
	WITH VERIFY_CLONEDB,		-- Verify consistency
		 NO_STATISTICS,			-- Exclude statistics
		 NO_QUERYSTORE;			-- Exclude Query Store
GO

-- 2. Verify cloned database
SELECT DATABASEPROPERTYEX
	('AdventureWorks2025_Clone',	-- New database
	'IsVerifiedClone') [Verified];	-- bit value (1/0)


/*
Don't forget to download a copy of this and other 
scripts from my GitHub repo, please check the link 
and name of the file on the video description. This 
and other solutions are given "AS IS" under no warranty 
or claim.
*/