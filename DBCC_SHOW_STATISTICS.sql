/*
DBCC (Transact-SQL)

The Transact-SQL programming language provides 
DBCC statements that act as Database Console 
Commands for SQL Server. Here you can see an
example on how to display current query optimization 
statistics for a table or indexed view.
*/

-- 1. Select an exisitng database:
USE [AdventureWorksLT2025];
GO
-- 2. Get all indexes/PK for a table, please provide 
-- table's schema/name on the WHERE clause.
SELECT index_id AS [Index ID],
       name AS [Index/PK]
FROM sys.indexes
WHERE object_id = OBJECT_ID('SalesLT.Address');

-- 3. Display all statistics info for the PK_Address_AddressID
-- index of the SalesLT.Address table.
DBCC SHOW_STATISTICS ("SalesLT.Address", PK_Address_AddressID);
GO
-- 4. This limits the statistics information displayed for 
-- PK_Address_AddressID to the HISTOGRAM data.
DBCC SHOW_STATISTICS 
    ("SalesLT.Address", PK_Address_AddressID) WITH HISTOGRAM;
GO

/*
Don't forget to download a copy of this and other 
scripts from my GitHub repo, please check the link 
and name of the file on the video description. This 
and other solutions are given "AS IS" under no warranty 
or claim. For additional info, please visit:
https://learn.microsoft.com/
*/
