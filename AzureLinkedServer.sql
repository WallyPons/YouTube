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

