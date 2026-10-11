-- Note: Neither the server or passwords are real.

-- 1. Add linked server
EXEC sp_addlinkedserver 
    @server = N'AZ_SALES_QA',
    @srvproduct = N'',
    @provider = N'MSOLEDBSQL',
    @provstr = N'Server=tcp:sales-qa.database.windows.net,1433;Database=sales-qa;Encrypt=yes;TrustServerCertificate=no;';

-- 2. Add credentials
EXEC sp_addlinkedsrvlogin 
    @rmtsrvname = N'AZ_SALES_QA',
    @useself = N'False',
    @locallogin = NULL,
    @rmtuser = N'salesportal-qa',
    @rmtpassword = N'This!sN0t@reelPzzw33rdbtW!*';

-- 3. Set recommended server options
EXEC sp_serveroption N'AZ_SALES_QA', 'rpc', 'true';
EXEC sp_serveroption N'AZ_SALES_QA', 'rpc out', 'true';
EXEC sp_serveroption N'AZ_SALES_QA', 'collation compatible', 'false';

-- 4. Test it
EXEC sp_testlinkedserver N'AZ_SALES_QA';

-- 5. Additional recommendations
/*
Enable "Allow inprocess" for MSOLEDBSQL. This provider is disabled for in-process use by default, which causes distributed queries 
to fail or behave inconsistently. Set it via SSMS (Server Objects → Linked Servers → Providers → MSOLEDBSQL → Provider Options → 
check "Allow InProcess") or via T-SQL:
*/

EXEC sp_MSset_oledb_prop N'MSOLEDBSQL', N'AllowInProcess', 1;

-- 6. RPC/RPC OUT: Only needed if you plan to execute remote stored procedures through the linked server

-- 7. Collation compatible — set to true only if you've confirmed the local and Azure SQL databases use the same collation; 
--    otherwise leave false to avoid silent comparison issues.

-- 8. Idempotency — if you'll be re-running this script (e.g., in CI/CD or repeated deployments), guard against "linked server already exists" errors:

IF EXISTS (SELECT 1 FROM sys.servers WHERE name = N'AZ_SALES_QA')
    EXEC sp_dropserver N'AZ_SALES_QA', 'droplogins';


-- V2 below: Added on 10/11/2026


/*==============================================================================
 Linked server: on-prem SQL Server 2019  ->  Azure SQL Database (sales-qa)
 Target       : sales-qa.database.windows.net
 Run on       : on-prem SQL Server 2019 (needs sysadmin / setupadmin + securityadmin)
 
 PREREQUISITES
  1. Install Microsoft OLE DB Driver for SQL Server (MSOLEDBSQL) on the on-prem
     host. Version 19.x registers as MSOLEDBSQL19; 18.x registers as MSOLEDBSQL.
     Check with:  SELECT * FROM sys.dm_os_loaded_modules WHERE name LIKE '%msoledbsql%';
  2. An Azure SQL login/user with the minimum rights you need (db_datareader,
     db_datawriter, EXECUTE on the procs). Do NOT map to the server admin.
  3. Azure SQL Database has NO cross-database context: the linked server is
     bound to ONE database (@catalog). Create one linked server per database.
==============================================================================*/
 
USE [master];
GO
 
/*------------------------------------------------------------------------------
 0. CONFIGURATION  (edit these)
------------------------------------------------------------------------------*/
DECLARE @LinkedServerName sysname        = N'SALES_QA';
DECLARE @AzureServer      nvarchar(256)  = N'sales-qa.database.windows.net';
DECLARE @AzureDatabase    sysname        = N'<YourAzureDatabaseName>';   -- REQUIRED
DECLARE @RemoteUser       sysname        = N'<azure_sql_login>';
DECLARE @RemotePassword   nvarchar(128)  = N'<StrongPasswordHere>';
DECLARE @Provider         sysname        = N'MSOLEDBSQL';                -- or MSOLEDBSQL19
 
/*------------------------------------------------------------------------------
 1. DROP IF EXISTS (idempotent re-run)
------------------------------------------------------------------------------*/
IF EXISTS (SELECT 1 FROM sys.servers WHERE name = @LinkedServerName)
    EXEC master.dbo.sp_dropserver @server = @LinkedServerName, @droplogins = 'droplogins';
 
/*------------------------------------------------------------------------------
 2. CREATE THE LINKED SERVER
    @provstr: Azure SQL requires encrypted connections.
      Encrypt=Yes / TrustServerCertificate=No  -> validates Azure's public cert
      ApplicationIntent=ReadWrite              -> primary replica (writes)
      (use a second linked server with ApplicationIntent=ReadOnly if you have a
       readable secondary / read scale-out and want to offload heavy reads)
------------------------------------------------------------------------------*/
EXEC master.dbo.sp_addlinkedserver
      @server     = @LinkedServerName
    , @srvproduct = N''                       -- must be blank when using MSOLEDBSQL
    , @provider   = @Provider
    , @datasrc    = @AzureServer
    , @catalog    = @AzureDatabase
    , @provstr    = N'Encrypt=Yes;TrustServerCertificate=No;ApplicationIntent=ReadWrite;';
 
/*------------------------------------------------------------------------------
 3. LOGIN MAPPING (SQL authentication)
    @locallogin = NULL -> applies to ALL local logins. For least privilege,
    run once per local login/group instead and avoid the NULL mapping.
------------------------------------------------------------------------------*/
EXEC master.dbo.sp_addlinkedsrvlogin
      @rmtsrvname  = @LinkedServerName
    , @useself     = N'False'                 -- do not pass local credentials
    , @locallogin  = NULL
    , @rmtuser     = @RemoteUser
    , @rmtpassword = @RemotePassword;
 
/*------------------------------------------------------------------------------
 4. SERVER OPTIONS  (read / write / stored-proc tuning)
------------------------------------------------------------------------------*/
 
-- ===== Core enablement =====
-- READ + WRITE via four-part names / OPENQUERY
EXEC master.dbo.sp_serveroption @server = @LinkedServerName, @optname = N'data access', @optvalue = N'true';
 
-- STORED PROCS: EXEC [SALES_QA].[db].[schema].[proc] and EXEC (...) AT [SALES_QA]
EXEC master.dbo.sp_serveroption @server = @LinkedServerName, @optname = N'rpc',     @optvalue = N'true';  -- inbound
EXEC master.dbo.sp_serveroption @server = @LinkedServerName, @optname = N'rpc out', @optvalue = N'true';  -- outbound (required for calling remote procs)
 
-- ===== Read performance =====
-- 'collation compatible' = true  -> optimizer PUSHES filters/joins/sorts on character
--                                  columns to Azure (big win), but ONLY safe if both
--                                  sides share the same collation.
-- 'collation compatible' = false -> character predicates are evaluated locally after
--                                  pulling rows (safe, slower).
-- Azure SQL default collation is SQL_Latin1_General_CP1_CI_AS. If your on-prem DB and
-- the Azure DB use the same collation, flip this to 'true'.
EXEC master.dbo.sp_serveroption @server = @LinkedServerName, @optname = N'collation compatible',   @optvalue = N'false';
EXEC master.dbo.sp_serveroption @server = @LinkedServerName, @optname = N'use remote collation',   @optvalue = N'true';
-- EXEC master.dbo.sp_serveroption @server = @LinkedServerName, @optname = N'collation name', @optvalue = N'SQL_Latin1_General_CP1_CI_AS';
 
-- Defers remote schema validation until execution -> fewer metadata round trips and
-- avoids compile-time failures if the remote schema changes.
EXEC master.dbo.sp_serveroption @server = @LinkedServerName, @optname = N'lazy schema validation', @optvalue = N'true';
 
-- ===== Write / transaction behaviour =====
-- Azure SQL Database cannot enlist in on-prem MSDTC. Stop RPC calls from promoting the
-- local transaction to a distributed one (avoids MSDTC errors 7391 / 8501).
EXEC master.dbo.sp_serveroption @server = @LinkedServerName, @optname = N'remote proc transaction promotion', @optvalue = N'false';
 
-- ===== Timeouts (seconds) =====
EXEC master.dbo.sp_serveroption @server = @LinkedServerName, @optname = N'connect timeout', @optvalue = N'30';   -- WAN latency tolerance
EXEC master.dbo.sp_serveroption @server = @LinkedServerName, @optname = N'query timeout',   @optvalue = N'600';  -- 0 = unlimited (not recommended)
 
-- ===== Not used =====
EXEC master.dbo.sp_serveroption @server = @LinkedServerName, @optname = N'dist',      @optvalue = N'false'; -- not a distributor
EXEC master.dbo.sp_serveroption @server = @LinkedServerName, @optname = N'pub',       @optvalue = N'false';
EXEC master.dbo.sp_serveroption @server = @LinkedServerName, @optname = N'sub',       @optvalue = N'false';
EXEC master.dbo.sp_serveroption @server = @LinkedServerName, @optname = N'system',    @optvalue = N'false';
GO
 
/*------------------------------------------------------------------------------
 5. PROVIDER OPTIONS (instance-level, apply to every linked server using MSOLEDBSQL)
    Needed for parameterised remote queries and 4-part-name DML.
------------------------------------------------------------------------------*/
EXEC master.dbo.sp_MSset_oledb_prop N'MSOLEDBSQL', N'AllowInProcess',   1;
EXEC master.dbo.sp_MSset_oledb_prop N'MSOLEDBSQL', N'DynamicParameters', 1;
-- For MSOLEDBSQL19 repeat the two lines above with N'MSOLEDBSQL19'.
GO
 
/*------------------------------------------------------------------------------
 6. TEST
------------------------------------------------------------------------------*/
-- 6a. Connectivity (throws if the link is broken)
EXEC sp_testlinkedserver N'SALES_QA';
 
-- 6b. Read  - pass-through (BEST for performance: whole query runs in Azure)
SELECT * FROM OPENQUERY([SALES_QA], N'SELECT TOP (10) name, create_date FROM sys.tables;');
 
-- 6c. Read  - four-part name (database part left empty because @catalog is set)
-- SELECT TOP (10) * FROM [SALES_QA].[<YourAzureDatabaseName>].[dbo].[YourTable];
 
-- 6d. Stored proc - remote execution (needs 'rpc out')
-- EXEC [SALES_QA].[<YourAzureDatabaseName>].[dbo].[usp_YourProc] @Param1 = 1;
-- EXEC (N'EXEC dbo.usp_YourProc @Param1 = ?;', 1) AT [SALES_QA];   -- AT syntax, parameterised
 
-- 6e. Write - pass-through (set-based, executes entirely on Azure)
-- EXEC (N'UPDATE dbo.YourTable SET Col = 1 WHERE Id = ?;', 42) AT [SALES_QA];
 
/*==============================================================================
 USAGE GUIDANCE (ordered by performance)
 
 READS
   - Prefer OPENQUERY / EXEC ... AT for anything with filters, joins or
     aggregates: the query is shipped and executed on Azure, only results return.
   - Avoid joining large local tables to large remote tables via 4-part names;
     stage the smaller side (temp table) or pass keys into OPENQUERY.
   - Four-part names with 'collation compatible' = false pull rows before
     filtering on character columns.
 
 WRITES
   - Use EXEC ... AT or a remote stored procedure for set-based changes.
   - INSERT/UPDATE/DELETE via 4-part name work but are row-by-row-ish and, inside
     a local BEGIN TRAN, try to start a distributed transaction. Azure SQL DB does
     not support MSDTC from on-prem: run linked-server writes OUTSIDE explicit
     local transactions, or make each remote call its own atomic unit
     (SET XACT_ABORT ON; handle retry/compensation in your code).
 
 STORED PROCS
   - Require 'rpc out'; keep logic in the proc on Azure and return minimal result
     sets. INSERT ... EXEC against a remote proc also needs a distributed
     transaction, so land results with OPENQUERY or a table-valued approach instead.
 
 SECURITY
   - Use a dedicated least-privilege Azure SQL user; store creds only via
     sp_addlinkedsrvlogin; restrict @locallogin mappings; rotate the password.
==============================================================================*/

