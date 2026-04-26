/*
DBCC (Transact-SQL)

The Transact-SQL programming language provides 
DBCC statements that act as Database Console 
Commands for SQL Server. Here you can see an
example on how to turn off one or more trace flags:
*/

-- 1. Returns columns for trace flag and status
DBCC TRACESTATUS ( -1 );

-- 2. Turn off one specific trace flag
DBCC TRACEOFF (2371, -1);

-- 3. Turn off multiple trace flags
DBCC TRACEOFF (2371, 4199, -1);

-- Note: -1 Disables trace flag(s) globally.

/*
Don't forget to download a copy of this and other 
scripts from my GitHub repo, please check the link 
and name of the file on the video description. This 
and other solutions are given "AS IS" under no warranty 
or claim.
*/