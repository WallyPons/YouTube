/*
Run sp_who2 and store it on a temp table for
evaluation purposes. You can filter the data
and create a summary of the connections too.
*/

-- 1. Declare variable with database name
DECLARE @DBName VARCHAR(255) = 'msdb'

-- 2. Drop table if exists
DROP TABLE IF EXISTS #SP_WHO2;

-- 3. Create temp table
CREATE TABLE #SP_WHO2
(SPID INT, Status VARCHAR(255),
 [Login] VARCHAR(255), HostName VARCHAR(255),
 BlkBy VARCHAR(255), DBName VARCHAR(255),
 Command VARCHAR(255), CPUTime INT,
 DiskIO INT, LastBatch VARCHAR(255),
 ProgramName VARCHAR(255), SPID1 INT,
 REQUESTID INT);

-- 4. Insert values into #SP_WHO2
INSERT INTO #SP_WHO2 EXEC SP_WHO2;

-- 5. View all contents of #SP_WHO2
SELECT * FROM #SP_WHO2;

-- 6. Add a filter to #SP_WHO2 table
SELECT *
FROM #SP_WHO2
WHERE DBName = @DBName

/*
 Don't forget to download a copy of this and other 
 scripts from my Github repo, please check the link and 
 name of the file on the video description. 
 This and other solutions are given "AS IS" under no
 warranty or claim.
 */