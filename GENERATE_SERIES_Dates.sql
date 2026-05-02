/*
GENERATE_SERIES (Transact-SQL)

Generates a series of numbers/dates within a given 
interval. The interval and the step between series 
values are defined by the user. Note: Compatibility 
level 160 (SQL Server 2022 and up only)
*/
-- 1. Create a calendar table to store dates
CREATE TABLE [DB_DEMO].[dbo].[CalendarDemo2026]
(AppointmentDate DATE, Completed bit DEFAULT(0));

-- 2. Declare variables and assign values to them
DECLARE @StartDate DATE;		-- DATE variable
DECLARE @EndDate DATE;			-- DATE variable
SET @StartDate = '2026-01-01';	-- Start on Jan-01
SET @EndDate =   '2026-12-31';	-- End on Dec-31

-- 3. Insert the date range into the calendar table
INSERT INTO [DB_DEMO].[dbo].[CalendarDemo2026] 
(AppointmentDate) -- Insert into a single column
SELECT 
	DATEADD(DAY, value, 
	@StartDate) AS GeneratedDate
FROM GENERATE_SERIES(0, DATEDIFF(DAY, 
	@StartDate, @EndDate), 1);  -- Range and step

-- 4. View the values inserted on the table
SELECT * FROM [DB_DEMO].[dbo].[CalendarDemo2026];

/*
Don't forget to download a copy of this and other 
scripts from my GitHub repo, please check the link 
and name of the file on the video description. This 
and other solutions are given "AS IS" under no warranty 
or claim.
*/