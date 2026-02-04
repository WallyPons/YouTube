/*
Line #  Descrition
======================================================
14      Sample Scripts
44      Full Backup Script with comments explained
74      Automated Backup Script with SQL cursor
117     Backup script with cursor
249     Query to return successful backup information
307     MSDB table informations
346     Other links
*/


-- 1. Sample Scripts
-- Full Backup Script
BACKUP DATABASE	[CorporateData_East1] TO DISK = N'Z:\MSSQL\BACKUP\CorporateData_East1_FULL.bak' With
COMPRESSION, DESCRIPTION = N'Description', NAME = N'Name', MEDIADESCRIPTION = N'Media Description', 
MEDIANAME = N'Media name', NOINIT, NOFORMAT, NOSKIP, NOREWIND, NOUNLOAD, 
Stats = 1


-- Differential Backup Script
BACKUP DATABASE	[CorporateData_East1] TO DISK = N'Z:\MSSQL\BACKUP\CorporateData_East1_DIFF.bak' With
DIFFERENTIAL, COMPRESSION, DESCRIPTION = N'Description', NAME = N'Name', MEDIADESCRIPTION = N'Media Description', 
MEDIANAME = N'Media name', NOINIT, NOFORMAT, NOSKIP, NOREWIND, NOUNLOAD, 
Stats = 1


-- Select name, recovery_model_desc From sys.databases Where name = 'CorporateData_East1'
-- LOG Backup Script
BACKUP LOG [CorporateData_East1] TO DISK = N'Z:\MSSQL\BACKUP\CorporateData_East1_LOG.bak' With
COMPRESSION, DESCRIPTION = N'Description', NAME = N'Name', MEDIADESCRIPTION = N'Media Description', 
MEDIANAME = N'Media name', NOINIT, NOFORMAT, NOSKIP, NOREWIND, NOUNLOAD, 
Stats = 1


-- COPY-ONLY Backup Script
BACKUP DATABASE	[CorporateData_East1] TO DISK = N'Z:\MSSQL\BACKUP\CorporateData_East1_CO.bak' With
COPY_ONLY, COMPRESSION, DESCRIPTION = N'Description', NAME = N'Name', MEDIADESCRIPTION = N'Media Description', 
MEDIANAME = N'Media name', NOINIT, NOFORMAT, NOSKIP, NOREWIND, NOUNLOAD, 
Stats = 1


-- 2. Full Backup Script with comments explained
BACKUP													-- Transact-SQL Command
DATABASE												-- Most commonly used options: DATABASE or LOG
[CorporateData_East1]									-- Database name
TO														-- Specifies the backup device type (DISK | TAPE | URL)
DISK = N'Z:\MSSQL\BACKUP\CorporateData_East1_FULL.bak'	-- Path and name to a disk (The capital N helps treating the string as unicode (NVARCHAR))
With													-- Start of options
COMPRESSION,											-- Explicitly enables backup compression, overriding the server-level default
														-- (NO_COMPRESSION Explicitly disables backup compression.)
-- Metadata information inside the backup file
DESCRIPTION = N'Description',							-- 255 characters description (description, free form)
NAME = N'Name',											-- 128 characters description (name, free form)
MEDIADESCRIPTION = N'Media Description',				-- 255 characters description (media description, free form)
MEDIANAME = N'Media name',								-- 128 characters description (medianame, free form)
-- Media set options
NOINIT,					-- Indicates that the backup set is appended to the specified media set (one file, many backups) 
						-- (INIT Specifies that all backup sets should be overwritten (one file, one backup))
NOFORMAT,				-- Specifies that the backup operation preserves the existing media header (Metadata) 
						-- (FORMAT Specifies that a new media set be created)
NOSKIP,					-- Instructs the BACKUP statement to check the expiration date of all backup sets on the media before allowing them to be overwritten
						-- (SKIP Disables the checking of backup set expiration and name that is usually performed by the BACKUP statement to prevent overwrites of backup sets)
-- Tape Options
NOREWIND,				-- Specifies that SQL Server keeps the tape open after the backup operation
						-- (REWIND Specifies that SQL Server releases and rewinds the tape)
NOUNLOAD,				-- Specifies that after the BACKUP operation the tape remains loaded on the tape drive.
						-- (UNLOAD Specifies that the tape is automatically rewinded and unloaded when the backup is finished)
-- Statistics
Stats = 1				-- Completion by percentage (Type=INT)


-- 3. Automated Backup Script with SQL cursor

-- Options
/*
For the SQL job output file:
============================
Full:               Z:\MSSQL\BACKUP\Reports\FullBackup_$(ESCAPE_DQUOTE(DATE))_$(ESCAPE_DQUOTE(TIME)).txt
Diff:               Z:\MSSQL\BACKUP\Reports\DiffBackup_$(ESCAPE_DQUOTE(DATE))_$(ESCAPE_DQUOTE(TIME)).txt
Log:                Z:\MSSQL\BACKUP\Reports\LogBackup_$(ESCAPE_DQUOTE(DATE))_$(ESCAPE_DQUOTE(TIME)).txt
Copy_Only:          Z:\MSSQL\BACKUP\Reports\COBackup_$(ESCAPE_DQUOTE(DATE))_$(ESCAPE_DQUOTE(TIME)).txt
DisableLogDiff:     Z:\MSSQL\BACKUP\Reports\DisableDiffLogJob_$(ESCAPE_DQUOTE(DATE))_$(ESCAPE_DQUOTE(TIME)).txt

For the SQL job name:
=====================
Full:		    _Full_Backup_Job
Diff:	    	_Diff_Backup_Job
Log:		    _Log_Backup_Job
Copy_Only:	    _CO_Backup_Job
DisableLogDiff: _DisableDiffLog_Job


-- DISABLE: Create a SQL Job to run before the next transaction log backup
-- Disable Differential Job
EXECUTE msdb.dbo.sp_update_job @job_name = N'_Diff_Backup_Job',
                               @enabled = 0;
GO
-- Disable Log job
EXECUTE msdb.dbo.sp_update_job @job_name = N'_Log_Backup_Job',
                               @enabled = 0;
GO

-- ENABLE: Add to the end of the Full backup script
-- Enable Differential Job
EXECUTE msdb.dbo.sp_update_job @job_name = N'_Diff_Backup_Job',
                               @enabled = 1;
GO
-- Enable Log job
EXECUTE msdb.dbo.sp_update_job @job_name = N'_Log_Backup_Job',
                               @enabled = 1;
GO

*/

-- 4. Backup script with cursor
-- a. Get SQL Server Service Account
DECLARE @SQLServiceAccount nvarchar(512)
SELECT
    @SQLServiceAccount = service_account
FROM
    sys.dm_server_services
WHERE
    servicename LIKE 'SQL Server (%';

-- b. Print informational headers
Print'+'
Print''
Print''
Print''
Print'-----------------------------------------------------------------'
Print'             User and Server Informations                        '
Print'-----------------------------------------------------------------'
Print 'Current Date : ' +Convert(varchar, getdate(), 9)
Print 'On Server    : ' +@@SERVERNAME
Print 'Service Name : ' +@@servicename
Print 'Current Login: ' +system_user
Print 'SQL Ser. Acc.: ' +@SQLServiceAccount
Print'-----------------------------------------------------------------'
Print''
Print'Backup process begins...'
Print''
Print'-----------------------------------------------------------------'
Print''
Print''
Print''
Print'+'
Print''
Print''
Print''

-- c. Variable declaration
DECLARE @DatabaseName NVarchar(255)       
DECLARE @BackupFolder NVarchar(255) 
DECLARE @Date Varchar(8) 
DECLARE @DateTime Varchar('15') 
DECLARE @SQLServer NVarchar(255)
DECLARE @FileName NVarchar(255)
-- Set values for variables
SET @Date = (Select CONVERT(Varchar, GETDATE(), 112))
SET @DateTime = (Select CONVERT(Varchar, GETDATE(), 112) + '_' + Replace(convert(Varchar(8), GETDATE(),114),':',''))
SET @SQLServer = (Select Replace(@@SERVERNAME, '\', '_') as ServerName)
-- Note: Please remember to update the @BackupFolder value accordingly to the backup type and location.
SET @BackupFolder = 'Z:\MSSQL\BACKUP\FULL\' + @SQLServer + '_' + @Date 

-- d. Create Backup folder
EXEC master.dbo.xp_create_subdir @BackupFolder --  SQL Server extended stored procedure used to create new directories (folders)

-- e Start backup cursor
DECLARE db_cursor CURSOR FOR
    SELECT
        name
    FROM
        sys.databases
    WHERE
    /*
    Quick reminder:
        "master" database does not support DIFFERENTIAL or LOG backups.
        "msdb" database does not support LOG backups.
        "model" database is a template database and supports all backup types, only backup when the database gets any changes.
        "tempdb" does not supports ANY type of backups.
    */
        name NOT IN (
                        'tempdb', 'model'   
                    )
        AND state_desc NOT IN ('OFFLINE', 'RESTORING') -- To not backup offline or restoring databases
        AND is_in_standby != 1
        -- AND recovery_model != 3 -- For log backups, uncomment this line, also change BACKUP DATABASE to BACKUP LOG

OPEN db_cursor
FETCH NEXT FROM db_cursor
INTO
    @DatabaseName

WHILE @@FETCH_STATUS = 0
    BEGIN
        /*
        Handling backup file extensions:
            Full: "_Full.bak"
            DIFFERENTIAL: "_Diff.bak" 
            TRANSACTION LOG: "_LOG.bak"
            COPY_ONLY: "_CO.bak"
        */
        SET @FileName = @BackupFolder + '\' + @DatabaseName + '_' + @SQLServer + '_' + @DateTime + '_Full.BAK' 
        BACKUP DATABASE @DatabaseName
            TO
                DISK = @FileName
            With
                -- COPY_ONLY, --Uncomment for COPY_ONLY backup, comment DIFFERENTIAL as well
                -- DIFFERENTIAL, -- Uncomment for DIFFERENTIAL backup, comment COPY_ONLY as well
                COMPRESSION,
                NOINIT,
                NOFORMAT,
                CONTINUE_AFTER_ERROR, -- Controls whether a backup operation stops or continues after encountering a page checksum error.
                Stats = 10

        FETCH NEXT FROM db_cursor
        INTO
            @DatabaseName
    END

CLOSE db_cursor
DEALLOCATE db_cursor

-- f. Print closing footer
Print'+'
Print''
Print''
Print''
Print'-----------------------------------------------------------------'
Print'             User and Server Informations                        '
Print'-----------------------------------------------------------------'
Print 'Current Date : ' +Convert(varchar, getdate(), 9)
Print 'On Server    : ' +@@SERVERNAME
Print 'Service Name : ' +@@servicename
Print 'Current Login: ' +system_user
Print 'SQL Ser. Acc.: ' +@SQLServiceAccount
Print'-----------------------------------------------------------------'
Print''
Print'Backup process completed...'
Print''
Print'-----------------------------------------------------------------'
Print''
Print''
Print''
Print'+'

-- 5. The following query returns successful backup information from the past n months.
SELECT bs.database_name,
       backuptype = CASE
                        WHEN bs.type = 'D'
                             AND bs.is_copy_only = 0 THEN
                            'Full Database'
                        WHEN bs.type = 'D'
                             AND bs.is_copy_only = 1 THEN
                            'Full Copy-Only Database'
                        WHEN bs.type = 'I' THEN
                            'Differential database backup'
                        WHEN bs.type = 'L' THEN
                            'Transaction Log'
                        WHEN bs.type = 'F' THEN
                            'File or filegroup'
                        WHEN bs.type = 'G' THEN
                            'Differential file'
                        WHEN bs.type = 'P' THEN
                            'Partial'
                        WHEN bs.type = 'Q' THEN
                            'Differential partial'
                    END + ' Backup',
       CASE bf.device_type
           WHEN 2 THEN
               'Disk'
           WHEN 5 THEN
               'Tape'
           WHEN 7 THEN
               'Virtual device'
           WHEN 9 THEN
               'Azure Storage'
           WHEN 105 THEN
               'A permanent backup device'
           ELSE
               'Other Device'
       END AS DeviceType,
       bms.software_name AS backup_software,
       bs.recovery_model,
       bs.compatibility_level,
       BackupStartDate = bs.Backup_Start_Date,
       BackupFinishDate = bs.Backup_Finish_Date,
       LatestBackupLocation = bf.physical_device_name,
       backup_size_mb = CONVERT(decimal(10, 2), bs.backup_size / 1024. / 1024.),
       compressed_backup_size_mb = CONVERT(decimal(10, 2), bs.compressed_backup_size / 1024. / 1024.),
       database_backup_lsn, -- For transaction log and differential backups, this is the checkpoint_lsn of the FULL backup it is based on.
       checkpoint_lsn,
       begins_log_chain,
       bms.is_password_protected
FROM msdb.dbo.backupset bs
    LEFT OUTER JOIN msdb.dbo.backupmediafamily bf
        ON bs.[media_set_id] = bf.[media_set_id]
    INNER JOIN msdb.dbo.backupmediaset bms
        ON bs.[media_set_id] = bms.[media_set_id]
WHERE bs.backup_start_date > DATEADD(MONTH, -1, sysdatetime())
ORDER BY bs.database_name ASC,
         bs.Backup_Start_Date ASC;


-- 6. MSDB table informations

-- a. Backup tables
-- https://learn.microsoft.com/en-us/sql/relational-databases/system-tables/backupmediaset-transact-sql?view=sql-server-ver17
-- Contains one row for each backup media set.
Select * from msdb.dbo.backupmediaset;

-- https://learn.microsoft.com/en-us/sql/relational-databases/system-tables/backupmediafamily-transact-sql?view=sql-server-ver17
-- Contains one row for each media family.
Select * from msdb.dbo.backupmediafamily;

-- https://learn.microsoft.com/en-us/sql/relational-databases/system-tables/backupset-transact-sql?view=sql-server-ver17
-- Contains a row for each backup set.
Select * from msdb.dbo.backupset;

-- https://learn.microsoft.com/en-us/sql/relational-databases/system-tables/backupfile-transact-sql?view=sql-server-ver17
-- Contains one row for each data or log file of a database.
Select * from msdb.dbo.backupfile;

-- https://learn.microsoft.com/en-us/sql/relational-databases/system-tables/backupfilegroup-transact-sql?view=sql-server-ver17
-- Contains one row for each filegroup in a database at the time of backup.
Select * from msdb.dbo.backupfilegroup;


-- b. Restore tables

-- https://learn.microsoft.com/en-us/sql/relational-databases/system-tables/restorefile-transact-sql?view=sql-server-ver17
-- Contains one row for each restored file, including files restored indirectly by filegroup name. This table is stored in the msdb database.
Select * from msdb.dbo.restorefile;

-- https://learn.microsoft.com/en-us/sql/relational-databases/system-tables/restorefilegroup-transact-sql?view=sql-server-ver17
-- Contains one row for each restored filegroup. This table is stored in the msdb database.
Select * from msdb.dbo.restorefilegroup;

-- https://learn.microsoft.com/en-us/sql/relational-databases/system-tables/restorehistory-transact-sql?view=sql-server-ver17
-- Contains one row for each restore operation. This table is stored in the msdb database.
Select * from msdb.dbo.restorehistory;


-- 7. Other links
-- Backup Details: https://learn.microsoft.com/en-us/sql/t-sql/statements/backup-transact-sql?view=sql-server-ver17
-- Restore Details: https://learn.microsoft.com/en-us/sql/t-sql/statements/restore-statements-transact-sql?view=sql-server-ver17