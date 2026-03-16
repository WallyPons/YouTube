-- 1. Alter database authorization (change the owner of a securable entity)
USE [master]
GO
ALTER AUTHORIZATION ON DATABASE::[CorporateData_East1] TO sa;

-- a. Verify change
Select 
    name, 
    suser_sname(owner_sid) AS Owner 
From sys.databases 
    WHERE [name] = 'CorporateData_East1';

-- 2. Enables Change Data Capture (CDC) for the current database
USE [CorporateData_East1] 
GO
EXEC sys.sp_cdc_enable_db;
GO

-- a. Confirm changes
Select 
    name, 
    is_cdc_enabled 
From sys.databases 
    Where is_cdc_enabled = 1;


-- c. Core CDC System Tables (cdc schema)
/*
- cdc.captured_columns: Lists the columns from the source table that are being tracked.

- cdc.change_tables: Contains metadata for each table enabled for CDC, 
   including the capture instance, change table ID, and start/end LSN (Log Sequence Number).

- cdc.ddl_history: Records Data Definition Language (DDL) changes to tracked source tables (e.g., adding/dropping columns).

- cdc.index_columns: Tracks which columns act as a unique identifier (primary key or unique index) for rows in the source table.

- cdc.lsn_time_mapping: Maps LSN values to transaction commit times, essential for querying data by time range.
  cdc.<capture_instance>_CT: The actual table holding the INSERT, UPDATE, and DELETE changes (CDC Change Table).

Replication Related (dbo schema):
- dbo.systranschemas: is used to track schema changes in articles published in transactional and snapshot publications and for 
  Change Data Capture. This table is stored in both publication and subscription databases.
*/

-- 3. Select the schema and table you want to enable CDC on
USE [CorporateData_East1] 
GO
Select 
    schema_name(schema_id) AS [Schema], 
    name,
    is_tracked_by_cdc
From sys.tables
    Where schema_name(schema_id) NOT IN ('cdc')
AND
    is_tracked_by_cdc = 0
AND
    name != 'systranschemas';

-- 4. To apply CDC on a single table, run the following command, below you have only required parameters
-- a. This process will create two SQL jobs for capture and cleanup
EXECUTE sys.sp_cdc_enable_table
    @source_schema = N'dbo',
    @source_name = N'SamplePeople',
    @role_name = N'cdc_Admin';
GO

-- b. With all options
EXECUTE sys.sp_cdc_enable_table
    @source_schema = N'dbo',                                    -- Mandatory: The name of the schema in which the source table belongs.
    @source_name = N'SamplePeople',                             -- Mandatory: The name of the source table on which to enable change data capture.
    @role_name = N'cdc_admin',                                  -- Mandatory: The name of the database role used to gate access to change data.
    @capture_instance = N'dbo_SamplePeople',                    -- Optional: The name of the capture instance used to name instance-specific change data capture objects
    @supports_net_changes = 0,                                  -- Optional (default = 0): Indicates whether support for querying for net changes is to be enabled for this capture instance.
                                                                    -- If 0, only the support functions to query for all changes are generated.
                                                                    /*
                                                                    This function returns every single change that occurred for a specified interval. If a row was updated multiple times, 
                                                                    each update is represented by separate rows in the result set (an old values row and a new values row for an update).
                                                                    */
                                                                    -- If 1, the functions that are needed to query for net changes are also generated.
                                                                    /*
                                                                    This function returns only one row for each distinct row changed within a specified Log Sequence Number (LSN) range, 
                                                                    reflecting the final state (the "net" change) of the row at the end of the interval, regardless of how many inserts, 
                                                                    updates, or deletes occurred in between.
                                                                    */
    @index_name = N'PK__SamplePe__3214EC076891DFAF',            -- Optional: The name of a unique index to use to uniquely identify rows in the source table.
    @captured_column_list = N'DepartmentID, Name, GroupName',   -- Optional: Identifies the source table columns that are to be included in the change table.
    @filegroup_name = N'FG_CDC_CorporateData_East1',            -- Optional: The filegroup to be used for the change table created for the capture instance.
    @allow_partition_switch = 1;                                -- Optional: Indicates whether the SWITCH PARTITION command of ALTER TABLE can be executed against a table that is enabled for change data capture.
GO

-- c. Sample Filegroup and file creation
-- Filegroup
ALTER DATABASE [CorporateData_East1] ADD FILEGROUP [FG_CDC_CorporateData_East1]	
-- Associated file
ALTER DATABASE [CorporateData_East1] ADD FILE ( NAME = N'[TBL]_[dbo_SamplePeople]_[1]', 
    FILENAME = N'D:\SQLDATADB\CorporateData_East1\CDC\[TBL]_[dbo_CDC_CorporateData_East1]_[1].ndf', 
    SIZE = 1024MB, 
    MAXSIZE = 20480MB,
    FILEGROWTH = 64MB ) 
    TO FILEGROUP [FG_CDC_CorporateData_East1]


-- 5. To apply CDC on more than one table, you can run this query which will form the script for each table as a one-liner
Select 
    'EXECUTE sys.sp_cdc_enable_table @source_schema = N''' + 
    schema_name(schema_id) + ''',' + 
    '@source_name = N''' + name + 
    ''', @role_name = N''cdc_admin''' 
    AS cdc_setup_Script
From sys.tables
    Where schema_name(schema_id) NOT IN ('cdc')
AND
    is_tracked_by_cdc = 0
AND
    name != 'systranschemas';

-- a. To view tables with CDC configured
EXEC sys.sp_cdc_help_change_data_capture;

-- b. View CDC jobs
Select 
    job_id, 
    name, 
    enabled, 
    description, 
    date_created, 
    date_modified 
From msdb.dbo.sysjobs 
    Where name like 'cdc%';

-- c. View retention period for cleanup
EXECUTE sys.sp_cdc_help_jobs;

/*
The retention period determines how long the change data is kept 
in the CDC change tables before it is cleaned up. 
The default is 4,320 minutes (72 hours, or 3 days).

To modify the retention period: Use the sys.sp_cdc_change_job 
stored procedure, specifying @job_type = N'cleanup' and the 
new @retention value in minutes.

Column:           Variable          Value:
--------------------------------------------------------------------------------------------------------------------------
job_id:            N/A              The uniqueidentifier of the job.
job_type:          @job_type        'capture' or 'cleanup'.
job_name:          N/A              The name of the SQL Server Agent job (e.g., cdc.dbname_capture).
maxtrans:          @maxtrans        (Capture only) Maximum transactions processed per scan cycle.
maxscans:          @maxscans        (Capture only) Maximum scan cycles before exiting (if not continuous).
continuous:        @continuous      (Capture only) 1 = runs continuously, 0 = runs once.
pollinginterval:   @pollinginterval (Capture only) Seconds between log scans.
retention:         @retention       (Cleanup only) Minutes to retain data in change tables (default is 72 hours/4320 mins).
threshold:         @threshold       (Cleanup only) Maximum delete entries in a single statement.
*/

-- d. Example: Set retention to 5 days (5 * 24 * 60 = 7,200 minutes)
EXECUTE sys.sp_cdc_change_job @job_type = N'cleanup', @retention = 7200;

-- 6. CDC Operations
-- a. INSERT
INSERT INTO [CorporateData_East1].[dbo].[SamplePeople] 
(first_name, last_name, [address], job_title, [remote])
values
('A', 'B', 'C', 'D', 0);
-- b. Confirm insert
Select Top 5 * From [CorporateData_East1].[dbo].[SamplePeople]
Where First_Name = 'A'

-- c. UPDATE
UPDATE [CorporateData_East1].[dbo].[SamplePeople]
SET First_Name = 'AA'
Where First_Name = 'A';
-- d. Confirm update
Select Top 5 * From [CorporateData_East1].[dbo].[SamplePeople]
Where First_Name = 'AA'

-- e. DELETE A
DELETE FROM [CorporateData_East1].[dbo].[SamplePeople]
Where First_Name = 'AA'
-- f. Confirm delete
Select Top 5 * From [CorporateData_East1].[dbo].[SamplePeople]
Where First_Name = 'AA'

-- g. View CDC table
Select * From [CorporateData_East1].[cdc].[dbo_SamplePeople_CT];

/*
Column Meaning
__$start_lsn   : Represents the commit Log Sequence Number (LSN) of a transaction.
__$end_lsn     : Records the commit Log Sequence Number (LSN) marking the end of the transaction that modified the source data.
__$seqval      : Can be used to order more changes that occur in the same transaction.
__$operation   : type of change (1 = delete, 2 = insert, 3 = update (before image), and 4 = update (after image).
__$update_mask : is a variable bit mask with one defined bit for each captured column.
__$command_id  : It enables accurate sequencing of changes, particularly distinguishing between DELETE/INSERT operations that may have identical Log Sequence Numbers

Operation Codes
Code Operation
1 : DELETE
2 : INSERT
3 : UPDATE (before)
4 : UPDATE (after)
*/

-- h. View CDC table with CASE condition
Select __$start_lsn,
       __$end_lsn,
       __$seqval,
       __$operation,
       CASE
           WHEN __$operation = 1 THEN
               'DELETE'
           WHEN __$operation = 2 THEN
               'INSERT'
           WHEN __$operation = 3 THEN
               'UPDATE (before)'
           WHEN __$operation = 4 THEN
               'UPDATE (after)'
       END AS __$operation_Description,
       __$update_mask,
-- Add table columns here
       id,
       First_Name,
       Last_Name,
       email,
       [Address],
       Job_Title,
       Date_Hired,
       [remote]
-- End of table columns
       ,__$command_id
From [CorporateData_East1].[cdc].[dbo_SamplePeople_CT];

-- i. Extract columns from a table
;With CTE_Cols
AS (Select @@servername AS ServerName,
           db_name() AS Dbname,
           schema_name(t.schema_id) as schema_name,
           name as TABLE_NAME,
           STUFF(COLUMN_NAME, 1, 1, '') AS COLUMN_NAME
    From sys.tables t
        CROSS APPLY
    (
        SELECT ',' + name AS [text()]
        FROM sys.columns c
        WHERE c.object_id = t.object_id
        FOR XML PATH('')
    ) o(COLUMN_NAME)
   --Order by TABLE_NAME ASC
   )
Select *
From CTE_Cols
Where TABLE_NAME like 'SamplePeople' -- Specify your table by name
order by TABLE_NAME ASC;


-- 7. Delete cdc_Admin Role (if needed)
USE [CorporateData_East1]
GO

DECLARE @RoleName sysname
set @RoleName = N'cdc_Admin'

IF @RoleName <> N'public' and (select is_fixed_role from sys.database_principals where name = @RoleName) = 0
BEGIN
    DECLARE @RoleMemberName sysname
    DECLARE Member_Cursor CURSOR FOR
    select [name]
    from sys.database_principals 
    where principal_id in ( 
        select member_principal_id
        from sys.database_role_members
        where role_principal_id in (
            select principal_id
            FROM sys.database_principals where [name] = @RoleName AND type = 'R'))

    OPEN Member_Cursor;

    FETCH NEXT FROM Member_Cursor
    into @RoleMemberName
    
    DECLARE @SQL NVARCHAR(4000)

    WHILE @@FETCH_STATUS = 0
    BEGIN
        
        SET @SQL = 'ALTER ROLE '+ QUOTENAME(@RoleName,'[') +' DROP MEMBER '+ QUOTENAME(@RoleMemberName,'[')
        EXEC(@SQL)
        
        FETCH NEXT FROM Member_Cursor
        into @RoleMemberName
    END;

    CLOSE Member_Cursor;
    DEALLOCATE Member_Cursor;
END
DROP ROLE [cdc_Admin]
GO


-- 8. To disable CDC on a specific table
USE [CorporateData_East1];
GO
EXEC sys.sp_cdc_disable_table
    @source_schema = N'dbo',
    @source_name   = N'SamplePeople',
    @capture_instance = N'dbo_SamplePeople';
GO

/*
-- 9. Remove jobs (not recommended)
USE [CorporateData_East1];
GO
-- Cleanup / capture
EXEC sys.sp_cdc_drop_job @job_type = N'cleanup';
EXEC sys.sp_cdc_drop_job @job_type = N'capture';
GO
*/

-- 10. Optionally, to disable CDC at the database level, run
USE [CorporateData_East1] 
GO
EXEC sys.sp_cdc_disable_db;
GO

/*
Notes:
1. Always check your database latency
2. Make sure your Tempdb is properly configured/sized
3. SQL Memory settings must be optimal
4. The "Cost threshold for parallelism" must be > 5
5. When possible, use filegroups/files to store CDC table data
*/
