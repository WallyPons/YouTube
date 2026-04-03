/*
This script creates a "KILL" command for a specific
database connection or session, just change step #6
to your specific needs, copy the results and execute 
on a different window.
*/

-- 1. Drop table if exists
DROP TABLE IF EXISTS #SP_WHO2_KILL;

-- 2. Create temp table
CREATE TABLE #SP_WHO2_KILL
(SPID INT, Status VARCHAR(255),
 [Login] VARCHAR(255), HostName VARCHAR(255),
 BlkBy VARCHAR(255), DBName VARCHAR(255),
 Command VARCHAR(255), CPUTime INT,
 DiskIO INT, LastBatch VARCHAR(255),
 ProgramName VARCHAR(255), SPID1 INT,
 REQUESTID INT);

-- 3. Insert values into #SP_WHO2_KILL
INSERT INTO #SP_WHO2_KILL EXEC SP_WHO2;

-- 4. View contents of #SP_WHO2_KILL
SELECT * FROM #SP_WHO2_KILL;

-- 5. Add a filter to #SP_WHO2_KILL table
SELECT * FROM #SP_WHO2_KILL WHERE DBName = 'msdb'

-- 6. Create KILL process for specific connections
SELECT 
	'KILL ' + CAST(SPID AS VARCHAR(4)) 
	AS [KILL Command]
FROM #SP_WHO2_KILL
WHERE DBName = 'msdb' -- DB/Login/HostName/Etc..
/*
 Don't forget to download a copy of this and other 
 scripts from my Github repo, please check the link and 
 name of the file on the video description. This and 
 other solutions are given "AS IS" under no  warranty 
 or claim.
 */
