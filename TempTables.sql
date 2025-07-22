/*
Create a temp table logic:

	1. There are two types of temp tables:
		a. Local: Available only to the current session.
		b. Global: Available to all sessions within the instance (Regardless of DB context).

	2. You can create temp tables anywhere, regardless of which DB is being used at the moment.
	3. Temp tables are stored on the TempDB database.
	4. Lifespan:
		a. Local and global temp tables are dropped with the session.
		b. Global temp tables can exist on any new session as long as the
		   originating session is still open.

	5. Local temp tables always start with #
	6. Global temp tables always start with ##
	7. In some cases and under tempdb.sys.objects, the tables may include several underscores "___" 
	   and a random small HEX address type of code in the end to guarantee uniqueness.
*/

-- 1. Local temp table
	-- Drop table (if exists)
DROP TABLE IF EXISTS #LocalTemp
	-- Create table
CREATE TABLE #LocalTemp (Val1Local int)
	-- Insert values
INSERT INTO #LocalTemp
VALUES (1),(2),(3),(4),(5),(6)
	-- Run a select statement
Select *
From #LocalTemp

-- 2. Global temp table
	-- Drop table (if exists)
DROP TABLE IF EXISTS ##GlobalTemp
	-- Create table
CREATE TABLE ##GlobalTemp (Val1Global int)
	-- Insert values
INSERT INTO ##GlobalTemp
VALUES (7),(8),(9),(10),(11),(12)
	-- Run a select statement
Select *
From ##GlobalTemp

-- 3. Verify both tables
Select *
From #LocalTemp

Select *
From ##GlobalTemp

-- 4. List all temp tables
SELECT name AS TempTableName,
       create_date,
       modify_date,
       OBJECT_ID
FROM tempdb.sys.objects
WHERE name LIKE '#%' -- Matches local (#) and global (##) temp tables
      AND type IN ( 'U' ) 
Order by create_date DESC;