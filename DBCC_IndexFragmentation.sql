/*
DBCC (Transact-SQL)

The Transact-SQL programming language provides 
DBCC statements that act as Database Console 
Commands for SQL Server. Here you can see some
examples to check/fix index/PK fragmentation:
*/

-- 1. Displays fragmentation information for the 
-- data and indexes of the specified table or view.
DBCC SHOWCONTIG			-- Provide DB/Schema/Table
('AdventureWorksLT2025.SalesLT.Address')
WITH ALL_INDEXES;
GO

-- 2. Get all indexes/PK for a table, please provide 
-- table's schema/name on the WHERE clause
SELECT index_id AS [Index ID],
       name AS [Index/PK]
FROM sys.indexes
WHERE object_id = OBJECT_ID('SalesLT.Address');

-- 3. Defragment an index for the specified table/view.
DBCC INDEXDEFRAG		
(AdventureWorksLT2025,	-- Database name
'SalesLT.Address',		-- Schema and Table name
PK_Address_AddressID);	-- Index or PK to defragment
GO

/*
Don't forget to download a copy of this and other 
scripts from my GitHub repo, please check the link 
and name of the file on the video description. This 
and other solutions are given "AS IS" under no warranty 
or claim.
*/