/*
Disable all SQL jobs. WARNING: DO NOT USE
THIS QUERY UNLESS YOU'RE 100% SURE OF THE 
CONSEQUENCES THAT IT CARRIES.
*/

-- 1. Declare a variable for the syntax
DECLARE @sql NVARCHAR(MAX);
-- 2. Generate all EXEC statements.
SELECT @sql = 
STRING_AGG(N'EXEC msdb.dbo.sp_update_job 
            @job_name = N''' 
            + name + N''', @enabled = 0;', 
            CHAR(13))
FROM msdb.dbo.sysjobs;

-- 4. Print to verify
PRINT @sql;
-- 5. Execute command
IF @sql IS NOT NULL
    EXEC sp_executesql @sql;
GO

-- 6. Bonus: View enabled and disabled jobs
SELECT name, enabled FROM msdb.dbo.sysjobs
-- a. To enable all jobs, just change the
-- "@enabled = 0" to "@enabled = 1" on line 13
-- and run the code again. You're welcome!

/*
Don't forget to download a copy of this and other 
scripts from my GitHub repo, please check the link and 
name of the file on the video description. This and 
other solutions are given "AS IS" under no warranty 
or claim.
*/