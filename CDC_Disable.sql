-- 1. To disable CDC at the database level, run:
USE [DB_DEMO] -- Use your CDC database name
GO
EXEC sys.sp_cdc_disable_db;
GO

/*
When youn this command it will remove:
a. All CDC based tables (may take a few seconds)
b. CDC_Admin role
c. All CDC jobs (Capture / Cleanup)
d. The following system tables:
	- cdc.captured_columns
	- cdc.change_tables
	- cdc.ddl_history
	- cdc.index_columns
	- cdc.lsn_time_mapping
	- dbo.systranschemas
e. There's no need to restart SQL services!
*/

-- 2. If you just want to remove CDC for 
-- a single or all tables, execute the 
-- following code selectively:
USE [DB_DEMO] -- Use your CDC database name
GO
Select 
    'EXECUTE sys.sp_cdc_disable_table 
    @source_schema = N''' + 
    schema_name(schema_id) + ''',' + 
    '@source_name = N''' + name + 
    ''', @capture_instance = N''' + 
    schema_name(schema_id) + '_' + name + ''''
    AS cdc_setup_Script
From sys.tables
    Where schema_name(schema_id) NOT IN ('cdc')
AND
    is_tracked_by_cdc = 1
AND
    name != 'systranschemas';
-- b. Copy the results to a new window and 
-- execute. For a single table, only execute 
-- the line containing the name of the table
-- you wish to disable CDC to.
-- Note: Disable = Remove | Remember: You can 
-- download this code from my GitHub repository.