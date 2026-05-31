/*
Computed columns: Are virtual (or physically stored) 
columns whose values are calculated from an expression 
based on other columns in the same table, constants, 
operators, functions, or deterministic expressions.
*/
-- 1. Create a table with two computed columns
-- a. Drop temp table (if exists)
DROP TABLE IF EXISTS #Products 
-- b. Create temp table (can be a physical table too)
CREATE TABLE #Products(Id INT IDENTITY(1,1) 
PRIMARY KEY, CurrentQty INT, CurrentPrice DECIMAL(10,2),
-- c. Non-Persisted (Calculation only)
InvValue_NP AS CurrentQty * CurrentPrice,
-- d. Persisted (Physically stored)
InvValue_P AS (CurrentQty * CurrentPrice) PERSISTED);

-- 2. Insert sample data (4 rows)
INSERT INTO #Products(CurrentQty, CurrentPrice)
VALUES (3, 2), (6, 7), (5, 4), (9, 23);

-- 3. View all the data
SELECT * FROM #Products;

/*
Don't forget to download a copy of this and other 
scripts FROM my GitHub repo, please check the link 
and name of the file on the video description. This 
and other solutions are given "AS IS" under no warranty 
or claim.
*/
