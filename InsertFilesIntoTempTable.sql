/*
Insert files list into a temp table
*/
-- 1. Enable xp_cmdshell
EXEC sp_configure 'show advanced options', 1;
RECONFIGURE;
EXEC sp_configure 'xp_cmdshell', 1;
RECONFIGURE;
GO

-- a. Drop/Create/insert to temp table
DROP TABLE IF EXISTS #CMDFiles;
CREATE TABLE #CMDFiles (Files varchar(max));
INSERT INTO #CMDFiles

-- b. Execute CMD against a directory (C:\WINDOWS)
-- You can provide a different directory or path
EXECUTE xp_cmdshell 'DIR C:\WINDOWS\ /b /a-d /on';
GO

-- c. Disable xp_cmdshell
EXEC sp_configure 'xp_cmdshell', 0;
RECONFIGURE;
EXEC sp_configure 'show advanced options', 0;
RECONFIGURE;
GO

-- 2. View files
SELECT Files FROM #CMDFiles WHERE Files != 'NULL';

/*
Don't forget to download a copy of this and other 
scripts from my GitHub repo, please check the link 
and name of the file on the video description. This 
and other solutions are given "AS IS" under no warranty 
or claim.
*/