/*
How to move database files
---------------------------
Basic Requirements:

1. Use an existing location on your computer or network
2. The SQL Server Service account must have the necessary 
   file system permissions.
3. If the SQL Server Service account does not have the proper 
   permissions:
    a. You'll still be able to physically move
       the database files
    b. But, you get an operating system error 5 "access denied" 
       message from the SQL Server instance.
4. To execute the move database files, the SQL account
   requires at least one of the following roles/permissions:
    a. sysadmin
    b. db_creator
    c. db_owner
    d. ALTER ANY DATABASE server-level permission
*/


-- 1. List all databases, lookup for the database_id field matching your DB
USE [master];
GO
SELECT database_id AS [Database Id], 
name AS [Database Name],
state_desc AS [Status]
FROM sys.databases
ORDER BY 1 ASC;

-- 2. Use the database_id to list all devices related to the DB, in this case 
-- you get the logical name and the file name
-- a. File, location and size
USE [master];
GO
SELECT database_id AS [Database Id],
       DB_NAME(database_id) AS [Database Name],
       name AS [Logical Name],
       physical_name AS [Physical Name],
	   CAST((size * 8.0 / 1024.0) AS DECIMAL(10, 2)) AS [Size MB]
FROM sys.master_files
WHERE database_id = 5;

-- b. Volume, Total Suize, Free Size and % Free
SELECT f.database_id AS [Database Id],
       DB_NAME(f.database_id) AS [Database Name],
       f.file_id AS [File Id],
       vs.volume_mount_point AS [Volume Mount Point],
       vs.total_bytes / 1048576 / 1024 AS [Total Size GB],
       vs.available_bytes / 1048576 / 1024 AS [Free Size GB],
       CAST((CAST(vs.available_bytes AS FLOAT) 
       / 
       CAST(vs.total_bytes AS FLOAT)) * 100 AS DECIMAL(5, 2)) 
       AS [% Free]
FROM sys.master_files AS f
    CROSS APPLY sys.dm_os_volume_stats(f.database_id, f.file_id) AS vs
WHERE f.database_id = 5;

-- c. Display current drives
EXEC master.dbo.xp_fixeddrives;

-- 3. Create the MODIFY FILE NAME syntax, specify database_id to continue
USE [master];
GO

SELECT 
	'ALTER DATABASE ['+DB_NAME(database_id)+']
    MODIFY FILE (NAME = '''+name+''', 
    FILENAME = '''+physical_name+''');' AS [Move Script]
FROM sys.master_files
WHERE database_id = 5; -- Specify database_id


-- 4. Take the database you want to work with offline
USE [master];
GO

ALTER DATABASE [CorporateData_East1] SET OFFLINE; -- Add the name of the database

ALTER DATABASE [CorporateData_East1]      
    MODIFY FILE (NAME = 'CorporateData_East1',       
    FILENAME = 'F:\SQLDATA\CorporateData_East1\DATA\CorporateData_East1.mdf');

ALTER DATABASE [CorporateData_East1]      
    MODIFY FILE (NAME = 'CorporateData_East1_log',       
    FILENAME = 'G:\SQLDATA\CorporateData_East1\TRANSLOG\CorporateData_East1_log.ldf');

-- a. Now you need to move the database files

-- b. Last step: Put the database back online, and you're done!
USE [master];
GO
ALTER DATABASE [CorporateData_East1] SET ONLINE;

-- 5. Make folders from SQL
-- a. Add permissions to the newly created folders
EXEC master.dbo.xp_create_subdir 'F:\SQLDATA\CorporateData_East1\DATA'
EXEC master.dbo.xp_create_subdir 'G:\SQLDATA\CorporateData_East1\TRANSLOG'

-- 6. Open DB connections
SELECT 
    DB_NAME(dbid) AS DatabaseName, 
    COUNT(dbid) AS NumberOfConnections,
    loginame AS LoginName
FROM sys.sysprocesses
WHERE dbid > 0  
AND 
DB_NAME(dbid) = 'CorporateData_East1'
GROUP BY dbid, loginame
ORDER BY DatabaseName;
GO

-- a. Execute sp_who2 to view active user sessions and identify acordingly
sp_who2

-- b. Kill open sessions (if needed)
-- kill XX