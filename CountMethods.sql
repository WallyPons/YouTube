/*
Different methods to run a COUNT/COUNT_BIG
Note: I'm using [AdventureWorksLT2025] database
*/

-- 1. Counts every row in the table, including 
-- duplicates and rows with NULL values.
SELECT COUNT(*) FROM [SalesLT].[Product];

-- 2. Functions identically to COUNT(*) in modern SQL
-- Server versions and is often used interchangeably.
SELECT COUNT(1) FROM [SalesLT].[Product];;

-- 3. Counts only the rows where the specified column 
-- contains a non-null value.
SELECT COUNT(Color) FROM [SalesLT].[Product]; 

-- 4. Returns the number of unique, non-null values
-- in a specific column.
SELECT COUNT(DISTINCT Color) FROM [SalesLT].[Product]; 

-- 5. If the total count might exceed 2,147,483,647 
-- it returns a bigint data type.
SELECT COUNT_BIG(*) FROM [SalesLT].[Product]; 

/*
In Microsoft SQL Server, the '?' symbol is used as a
placeholder within the undocumented stored procedure 
sp_MSforeachtable. This code will return a COUNT for 
each and all tables in the current database:
*/
EXEC sp_MSforeachtable 'SELECT ''?'', COUNT(*) FROM ?';

/*
Don't forget to download a copy of this and other 
scripts from my GitHub repo, please check the link and 
name of the file on the video description. This and 
other solutions are given "AS IS" under no warranty 
or claim.
*/