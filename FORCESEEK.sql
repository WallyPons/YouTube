/*
FORCESEEK: This table hint in SQL Server instructs the
query optimizer to use only an index seek operation to 
access the data in a specific table or view. This 
overrides the optimizer's default behavior when it 
incorrectly chooses a full table or index scan instead 
of a faster, more targeted look-up.
*/
-- 1. Force the optimizer to find and use an index seek 
-- on any applicable index for that table
SELECT AddressID, AddressLine1, AddressLine2, City
FROM [AdventureWorks2025].[Person].[Address]
WHERE City = 'Seattle'; -- Scans all the rows

-- 2. Force an index seek specifically through a 
-- designated index with the columns on the WHERE clause
SELECT AddressID, AddressLine1, AddressLine2, City
FROM [AdventureWorks2025].[Person].[Address]
WITH (FORCESEEK, INDEX(IX_Address_City))
WHERE City = 'Seattle';

-- 3. Explicitly specifies both the index and the exact 
-- column(s) to use for the seek operation.
SELECT AddressID, AddressLine1, AddressLine2, City
FROM [AdventureWorks2025].[Person].[Address]
WITH (FORCESEEK(IX_Address_City (City)))
WHERE City = 'Seattle';

/*
Scenario			  Works?		 Recommendations
==========================================================
FORCESEEK alone		  Best			 Use most of the time
FORCESEEK(index_name) single column  Not for composite Idx
==========================================================

Don't forget to download a copy of this and other 
scripts FROM my GitHub repo, please check the link 
and name of the file on the video description. This 
and other solutions are given "AS IS" under no warranty 
or claim.
*/