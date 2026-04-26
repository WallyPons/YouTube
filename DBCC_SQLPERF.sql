/*
DBCC (Transact-SQL)

The Transact-SQL programming language provides 
DBCC statements that act as Database Console 
Commands for SQL Server. Here you can see how to
use SQLPERF, this command provides transaction 
log space usage statistics for all databases. 
Can also be used to reset wait and latch statistics.
*/

-- 1. Display LOGSPACE information for all databases 
-- contained in the current instance of SQL Server.
DBCC SQLPERF (LOGSPACE);
GO

-- a. Results will include: Database Name, Log Size (MB),
-- Log Space Used (%) and Status

-- 2. This resets the wait statistics for the instance 
-- of SQL Server.
DBCC SQLPERF ("sys.dm_os_wait_stats", CLEAR);
GO

-- Note: Starting with SQL Server 2012 (11.x), use the 
-- sys.dm_db_log_space_usage DMV instead of 
-- DBCC SQLPERF(LOGSPACE), to return space usage information 
-- for the transaction log per database.

/*
Don't forget to download a copy of this and other 
scripts from my GitHub repo, please check the link 
and name of the file on the video description. This 
and other solutions are given "AS IS" under no warranty 
or claim.
*/