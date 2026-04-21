/*
sp_renamedb: Renames a database.

WARNING: Although it still works on SQL 2025, 
this feature will be removed in a future version 
of SQL Server.
*/

USE [master];
GO
EXECUTE sp_renamedb 
N'DB_DEMO',   -- Current Database name
N'DB_DEMO2';  -- New database name
GO

/*
ALTER DATABASE [current_database_name] 
MODIFY NAME [new_database_name]: 

More current method to rename a database.
*/

USE [master];
GO
ALTER DATABASE [DB_DEMO]   -- Current Database name
MODIFY NAME =  [DB_DEMO2]; -- New database name
GO

/*
Don't forget to download a copy of this and other 
scripts from my GitHub repo, please check the link and 
name of the file on the video description. This and 
other solutions are given "AS IS" under no warranty 
or claim.
*/