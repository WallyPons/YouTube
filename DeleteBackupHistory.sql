/*
1. sp_delete_backuphistory
Reduces the size of the backup and restore 
history tables by deleting the entries for 
backup sets older than the specified date.
Date must be specified as YYYY-MM-DD
*/
-- a. Deletes backup history older 
-- than 2026-January-01
USE msdb;
GO
EXECUTE 
	sp_delete_backuphistory 
	@oldest_date = '2026-01-01';
GO

/*
2. sp_delete_database_backuphistory
Deletes information about the specified database 
from the backup and restore history tables.
*/
-- a. Delete backup history for DB_DEMO database
USE msdb;
GO
EXECUTE 
	dbo.sp_delete_database_backuphistory 
	@database_name = 'DB_DEMO';
GO

/*
Don't forget to download a copy of this and other 
scripts from my Github repo, please check the link and 
name of the file on the video description. This and 
other solutions are given "AS IS" under no warranty 
or claim.
*/