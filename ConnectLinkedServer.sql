/*
Create a linked server with Transact-SQL
========================================
Linked servers are typically configured to enable 
the database engine to execute a Transact-SQL statement 
that includes tables in another instance of SQL Server, 
or another database product such as Oracle.
*/

-- 1. Create the link server
EXEC 
master.dbo.sp_addlinkedserver  -- Stored procedure
@server = N'CORPORATESALES',   -- Server/instance name
@srvproduct = N'SQL Server';   -- Type of product
GO

-- 2. Add credentials
EXEC 
master.dbo.sp_addlinkedsrvlogin  -- Stored procedure
@rmtsrvname = N'CORPORATESALES', -- Server/instance name
@useself = N'False', -- Determines if impersonation will be used
@locallogin = NULL,  -- A login on the local server
@rmtuser = N'corporate-stg', -- Remote login used to connect
@rmtpassword = N'This!sN0t@reelPzzw33rdbtW!*'; -- Password

-- 3. Test the linked server
EXEC sp_testlinkedserver N'CORPORATESALES';

-- 4. Set recommended server options
-- a. RPC/RPC OUT Only needed if you plan to execute remote stored 
-- procedures through the linked server
EXEC sp_serveroption N'CORPORATESALES', 'rpc', 'true';
EXEC sp_serveroption N'CORPORATESALES', 'rpc out', 'true';
-- b. Collation compatible: set to true only if you've confirmed the 
-- local and remote SQL databases use the same collation; otherwise 
-- leave false to avoid silent comparison issues.
EXEC sp_serveroption N'CORPORATESALES', 'collation compatible', 'false';

/*
Don't forget to download a copy of this and other 
scripts FROM my GitHub repo, please check the link 
and name of the file on the video description. This 
and other solutions are given "AS IS" under no warranty 
or claim.
*/