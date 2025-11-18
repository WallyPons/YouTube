/*
DROP EVENT SESSION [Audit_Alter_Create_Delete_Drop_Insert_Truncate_Update] ON SERVER 
GO
*/

-- Audit Alter, Create, Delete, Drop, Insert, Truncate and Update commands
CREATE EVENT SESSION [Audit_Alter_Create_Delete_Drop_Insert_Truncate_Update]
ON SERVER
ADD EVENT sqlserver.sql_statement_completed
(
    SET collect_statement = (1)
    ACTION
    (
        sqlserver.client_app_name,
        sqlserver.client_connection_id,
        sqlserver.client_hostname,
        sqlserver.database_name,
        sqlserver.session_id,
        sqlserver.sql_text,
        sqlserver.username
    )
    WHERE 
    (
        (
               [sqlserver].[like_i_sql_unicode_string]([statement], N'alter%')
            OR [sqlserver].[like_i_sql_unicode_string]([statement], N'create%')
            OR [sqlserver].[like_i_sql_unicode_string]([statement], N'delete%')
            OR [sqlserver].[like_i_sql_unicode_string]([statement], N'drop%')
            OR [sqlserver].[like_i_sql_unicode_string]([statement], N'insert%')
            OR [sqlserver].[like_i_sql_unicode_string]([statement], N'truncate%')
            OR [sqlserver].[like_i_sql_unicode_string]([statement], N'update%')
        )
        AND [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[database_name], N'distribution') -- Stores metadata and history data for all types of replication
        AND [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[database_name], N'tempdb')
        AND [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[client_app_name], N'SQLAgent - Schedule Saver')
        AND [sqlserver].[not_equal_i_sql_unicode_string]([sqlserver].[client_app_name], N'SQLServerCEIP') -- The Customer Experience Improvement Program: sends telemetry data back to Microsoft
    )
)
ADD TARGET package0.event_file
(
    SET filename = N'C:\MSSQL\SQLDUMP\Audit_Alter_Create_Delete_Drop_Insert_Truncate_Update.xel',
        max_file_size = 1024,
        max_rollover_files = 5
)
WITH
(
    MAX_MEMORY = 8192KB,
    EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS,
    MAX_DISPATCH_LATENCY = 15 SECONDS,
    MAX_EVENT_SIZE = 0KB,
    MEMORY_PARTITION_MODE = NONE,
    TRACK_CAUSALITY = OFF,
    STARTUP_STATE = OFF
);
GO

-- Start Events
ALTER EVENT SESSION [Audit_Alter_Create_Delete_Drop_Insert_Truncate_Update] ON SERVER STATE = START;
GO

-- Stop Events
/*
ALTER EVENT SESSION [Audit_Alter_Create_Delete_Drop_Insert_Truncate_Update] ON SERVER STATE = STOP;
GO
*/

-- Create sample table
DROP TABLE IF EXISTS [CorporateData_East1].[dbo].[SampleTable];
CREATE TABLE [CorporateData_East1].[dbo].[SampleTable]
(
    Id INT Identity(1, 1) PRIMARY KEY,
    GUIDVal uniqueidentifier
        DEFAULT NEWID(),
    ManualVal CHAR(1)
);
-- Insert Sample Data
INSERT INTO [CorporateData_East1].[dbo].[SampleTable]
(
    ManualVal
)
VALUES ('A'),
('B'),
('C'),
('D'),
('E'),
('F'),
('G'),
('H'),
('I'),
('J');
-- Verify Insert
Select *
From [CorporateData_East1].[dbo].[SampleTable];
-- Delete one value
Delete From [CorporateData_East1].[dbo].[SampleTable]
Where ManualVal = 'J'
-- Verify Delete
Select *
From [CorporateData_East1].[dbo].[SampleTable];
-- Truncate Table
Truncate Table [CorporateData_East1].[dbo].[SampleTable];
-- Dropp Table
DROP Table [CorporateData_East1].[dbo].[SampleTable];

-- Read extended events
SELECT [XML Data],
       @@Servername AS ServerName,
       [XML Data].value('(event/@timestamp)[1]','datetimeoffset') AS timestamp,
       [XML Data].value('(/event/action[@name=''client_app_name'']/value)[1]', 'varchar(128)') AS [Client App Name],
       [XML Data].value('(/event/action[@name=''session_id'']/value)[1]', 'int') AS [Client Session Id],
       [XML Data].value('(/event/action[@name=''client_hostname'']/value)[1]', 'varchar(128)') AS [Client host name],
       [XML Data].value('(/event/action[@name=''database_name'']/value)[1]', 'varchar(128)') AS [Database],
       [XML Data].value('(/event/action[@name=''sql_text'']/value)[1]', 'varchar(max)') AS [SQL Text],
       [XML Data].value('(/event/action[@name=''username'']/value)[1]', 'varchar(128)') AS [User name]
--INTO #Audit_Alter_Create_Delete_Drop_Insert_Truncate_Update
FROM
(
    SELECT OBJECT_NAME AS [Event],
           CONVERT(XML, event_data) AS [XML Data]
    FROM sys.fn_xe_file_target_read_file('D:\MSSQL\SQLDUMP\MyFirstExport_0.xel', NULL, NULL, NULL)
) as Audit_Alter_Create_Delete_Drop_Insert_Truncate_Update;
GO

-- Read Temp table
Select *
From #Audit_Alter_Create_Delete_Drop_Insert_Truncate_Update
Where Statement like 'INSERT%'
      OR Statement like 'Truncate%'
GO

-- Create procedure
CREATE PROCEDURE [dbo].[sp_XE_Test]
AS
BEGIN

    Select @@Servername AS [ServerName],
           NEWID() AS [GUID1],
           NEWID() AS [GUID2],
           NEWID() AS [GUID3],
           NEWID() AS [GUID4],
           NEWID() AS [GUID5]

END;
GO

-- Test procedure
Exec [dbo].[sp_XE_Test];

-- Drop procedure
DROP PROC [dbo].[sp_XE_Test];


-- Source: https://learn.microsoft.com/en-us/sql/relational-databases/system-dynamic-management-views/sys-dm-xe-object-columns-transact-sql?view=azuresqldb-current
-- To find the description of other object column under the cpu_time , use this
Select name,
       object_name,
       column_type,
       type_name,
       description
From sys.dm_xe_object_columns 
Where name = 'cpu_time'
-- where object_name = 'broker_activation'
order by object_name ASC, description ASC


-- Get a list of all objects for use in query above
Select DISTINCT(name) From sys.dm_xe_object_columns

-- List all available events
SELECT 
    o.name AS EventName,
    o.description AS EventDescription,
    c.name AS ColumnName,
    c.column_type,
    c.column_value AS DefaultValue
FROM sys.dm_xe_objects AS o
JOIN sys.dm_xe_object_columns AS c
    ON o.name = c.object_name
WHERE o.name = 'sql_statement_completed'
ORDER BY o.name, c.name;

-- Source: https://learn.microsoft.com/en-us/sql/relational-databases/extended-events/extended-events?view=sql-server-ver17&tabs=sqlserver
-- Sample DMVs

-- Returns information about server-scoped event session actions.
Select action_name, event_name From sys.dm_xe_session_event_actions

-- Returns information about server-scoped event session events.
Select event_name From sys.dm_xe_session_events

-- Shows the configuration values for objects that are bound to a server-scoped session.
Select column_name,column_value, object_type, object_name From sys.dm_xe_session_object_columns

-- Returns information about server-scoped event session targets.
Select target_name, execution_count, execution_duration_ms, target_data, bytes_written From sys.dm_xe_session_targets

-- Returns a row for each server-scoped event session running on the server.
Select * From sys.dm_xe_sessions



-- Sample catalog views

-- Returns a row for each action on each event of a server-scoped event session.
Select * From sys.server_event_session_actions

-- Returns a row for each event in a server-scoped event session.
Select * From sys.server_event_session_events

-- Returns a row for each customizable column that was explicitly set on events and targets of a server-scoped event session.
Select * From sys.server_event_session_fields

-- Returns a row for each event target for a server-scoped event session.
Select * From sys.server_event_session_targets

-- 	Returns a row for each server-scoped event session.
Select * From sys.server_event_sessions

-- How to monitor "Event Drops"
SELECT
    name,
    dropped_event_count,
    total_event_count,
    (dropped_event_count * 100.0 / NULLIF(total_event_count, 0)) AS DropRatePct
FROM sys.dm_xe_session_targets
WHERE target_name = 'event_file';


