/*
MS SQL Collation: A practical example using two
different collations on the same table. One is
accent sensitive (AS) and the other is accent
insensitive (AI), both are case insensitive (CI)

This example uses a fictional person: Joe Márquez.
Please note the accent on the last name (á).
*/
-- 1. Drop/Create a local temp table
-- a. Drop the local temp table (if already exists)
DROP TABLE IF EXISTS #CollationExample;
-- b. Create the local temp table (if not exists)
CREATE TABLE #CollationExample
(Name1 NVARCHAR(20) -- Accent Sensitive
	COLLATE SQL_Latin1_General_CP1_CI_AS,
Name2 NVARCHAR(20)  -- Accent Insensitive
	COLLATE SQL_Latin1_General_CP1_CI_AI);
-- c. Insert the same name on both columns
INSERT INTO #CollationExample (Name1, Name2)
VALUES ('Joe Márquez', 'Joe Márquez');
-- d. View inserted values
SELECT TOP 1 * FROM #CollationExample;

-- 2. Select Name1 for joe marquez using WHERE
SELECT Name1 FROM #CollationExample
WHERE Name1 = 'joe marquez' -- No records found

-- 3. Select Name2 for joe marquez using WHERE
SELECT Name2 FROM #CollationExample
WHERE Name2 = 'joe marquez' -- 1 record found
/*
Don't forget to download a copy of this and other 
scripts from my GitHub repo, please check the link 
and name of the file on the video description. This 
and other solutions are given "AS IS" under no warranty 
or claim.
*/