-- 1. Alter your database authorization 
-- a. Change the owner of a securable entity
-- b. Change the database name to your database
USE [master]
GO
ALTER AUTHORIZATION ON DATABASE::[DB_DEMO] TO sa;

-- 2. Enable CDC
USE [DB_DEMO] -- Use your database name
GO
EXEC sys.sp_cdc_enable_db;
GO

-- 3. Verify
Select 
    name, 
    is_cdc_enabled 
From sys.databases 
    Where is_cdc_enabled = 1
    AND
    name = 'DB_DEMO'; -- Your database name

-- 4. Pull script to enable all tables
-- a. Copy the results to a new window and execute
USE [DB_DEMO] -- Use your database name
GO
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

-- 5. Verify your CDC tables
USE [DB_DEMO] -- Use your database name
GO
EXEC sys.sp_cdc_help_change_data_capture;