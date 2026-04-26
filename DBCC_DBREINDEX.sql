/*
DBCC (Transact-SQL)

The Transact-SQL programming language provides 
DBCC statements that act as Database Console 
Commands for SQL Server. Here you can see how to
rebuild one or more indexes for a table in the
specified database:
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
-- 3. Rebuild PK_Address_AddressID with a fill 
-- factor of 80 on the SalesLT.Address table.
USE [AdventureWorksLT2025];
GO
DBCC DBREINDEX 
    ('SalesLT.Address',     -- Table name
    PK_Address_AddressID,   -- Index or PK to defragment
    80);                    -- Fill factor of 80
GO
-- 4. Rebuild all indexes/PK on the specified table
DBCC DBREINDEX 
    ('SalesLT.Address',     -- Table name
    ' ',                    -- Leave empty for all
    80);                    -- Fill factor of 80
GO
/*
Don't forget to download a copy of this and other 
scripts from my GitHub repo, please check the link 
and name of the file on the video description. This 
and other solutions are given "AS IS" under no warranty 
or claim.
*/