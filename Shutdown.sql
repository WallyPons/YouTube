/*
If for some reason, you are in an urge to stop
SQL Server Services, these are the steps to follow
*/

-- 1. To immediately stop SQL Server, just run the 
-- following code:
SHUTDOWN;

-- 2. Optionally: Stop SQL Server without performing 
-- checkpoints in every database. SQL Server exits 
-- after attempting to terminate all user processes. 
-- When the server restarts, a rollback operation 
-- occurs for incomplete transactions, just run the 
-- following code:
SHUTDOWN WITH NOWAIT;

/*
3. Any of these processes requires sysadmin and 
serveradmin roles.

Don't forget to download a copy of this and other 
scripts from my Github repo, please check the link and 
name of the file on the video description. This and 
other solutions are given "AS IS" under no warranty 
or claim.
*/