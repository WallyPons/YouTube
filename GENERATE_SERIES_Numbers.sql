/*
GENERATE_SERIES (Transact-SQL)

Generates a series of numbers/dates within a given 
interval. The interval and the step between series 
values are defined by the user. Note: Compatibility 
level 160 (SQL Server 2022 and up only)
*/
-- 1. Create a calendar table to store dates
CREATE TABLE [DB_DEMO].[dbo].[Numbers2026]
(Number INT, Completed bit DEFAULT(0));

-- 2. Declare variables and assign values to them
DECLARE @StartNum INT;		-- INT variable
DECLARE @EndNum   INT;		-- INT variable
SET @StartNum = 1;			-- Start number
SET @EndNum   = 5000;	    -- End number

-- 3. Insert the date range into the calendar table
INSERT INTO [DB_DEMO].[dbo].[Numbers2026] 
(Number) -- Insert into a single column
SELECT value FROM GENERATE_SERIES
(@StartNum, @EndNum, 1);	-- Range and step

-- 4. View the values inserted on the table
SELECT * FROM [DB_DEMO].[dbo].[Numbers2026];

/*
Don't forget to download a copy of this and other 
scripts from my GitHub repo, please check the link 
and name of the file on the video description. This 
and other solutions are given "AS IS" under no warranty 
or claim.
*/