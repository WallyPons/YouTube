/*
DBCC (Transact-SQL)

The Transact-SQL programming language provides 
DBCC statements that act as Database Console 
Commands for SQL Server. Here you can see some
examples to enhance SQL Server performance:
*/
-- 1. Returns columns for trace flag and status
DBCC TRACESTATUS ( -1 );
-- 2. General Query & Statistics Performance:
-- a. Dynamic Statistics Updates (SQL < 2016)
DBCC TRACEON (2371, -1);
-- b. Enables Query Optimizer fixes released on CUs/SPs
DBCC TRACEON (4199, -1);
-- c. Allows for table variable/rrigger recompilation
DBCC TRACEON (2453, -1);
-- 3. Memory & Storage Efficiency:
-- a. Enable SQL to use large page allocations
DBCC TRACEON (834, -1);
-- b. TempDB Contention (uniform data file growth)
DBCC TRACEON (117,118, -1); -- (SQL < 2016)
-- 4. Maintenance & Maintenance Performance:
-- a. Suppress backup logging for successful backups
DBCC TRACEON (3226, -1);
-- b. Fast DBCC CHECKDB: For DBCC CHECKDB performance
DBCC TRACEON (2562,2549, -1);
-- c. Enables compression during AG automatic seeding
DBCC TRACEON (9567, -1);
-- Note: -1 Sets the specified trace flags globally.
/*
Don't forget to download a copy of this and other 
scripts from my GitHub repo, please check the link 
and name of the file on the video description. This 
and other solutions are given "AS IS" under no warranty 
or claim.
*/