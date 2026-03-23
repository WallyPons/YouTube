-- Read the error log from SQl Server

-- 1. You can use SERVERPROPERTY() command to 
-- know the current error log file location
SELECT SERVERPROPERTY('ErrorLogFileName') 
AS 'Error log file location';

-- 2. Error Logs and their sizes (bytes)
EXEC sys.sp_enumerrorlogs;

-- 3. Read current error log
EXEC xp_readerrorlog 
    0, -- Log number
    1, -- 1 for SQL Server / 2 SQL Agent
    N'Failed', -- Ex: Failed, Login
    N'Password', -- Ex: Backup, Restore
    N'2026-01-01 00:00:01.000', -- From
    N'2026-12-31 23:59:59.000', -- To
	N'DESC' -- Sort order (ASC or DESC)

-- 4. With variables
DECLARE @logno INT;
DECLARE @logFileType SMALLINT;
DECLARE @searchString1 NVARCHAR(256);
DECLARE @searchString2 NVARCHAR(256);
DECLARE @start DATETIME;
DECLARE @end DATETIME;
DECLARE @sort VARCHAR(4);

-- 0 for current log
SET @logno = 0; 
-- 1 for SQL Server 2 for SQL agent job
SET @logFileType = 1; 
-- String contained to search #1 (BACKUP Database)
SET @searchString1 = 'Failed'; 
-- String contained to search #2 (Failed)
SET @searchString2 = ''; 
-- Start date
SET @start  = '2026-01-01 00:00:01.000'; 
-- End date
SET @end = '2026-12-31 23:59:59.000'; 
-- Sort order (ASC or DESC)
SET @sort = 'ASC'; 

-- Execution
EXEC master.dbo.xp_readerrorlog @logno, 
                                @logFileType,
                                @searchString1,
                                @searchString2,
                                @start,
                                @end,
								@sort;