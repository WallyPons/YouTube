-- From a database
-- 1. With access to the live database:
-- a. Query sysfiles (system catalog view)

USE [CorporateData_East1]
GO

Select name AS [LogicalName],
       filename AS [PhysicalName]
From sysfiles;

-- b. Use a pre-formated script, it will save some time on the restore
RESTORE DATABASE [CorporateData_East1] FROM DISK = N'Z:\MSSQL\BACKUP\CorporateData_East1_FULL.BAK'
WITH
MOVE '' TO '',
MOVE '' TO '',
STATS = 10

-- c. What if the database has multiple files?
USE [StackOverflow2010]
GO

Select 
      'MOVE '''+name+''' TO '''+ filename + ''','
From sysfiles;

-- d. Form the restore
RESTORE DATABASE [StackOverflow2010] FROM DISK = N'Z:\MSSQL\BACKUP\StackOverflow2010_Full.BAK'
WITH
MOVE '' TO '',
MOVE '' TO '',
STATS = 10

-- From a backup file only
-- 2. With only the backup file, no live database to query
RESTORE FILELISTONLY FROM DISK = N'Z:\MSSQL\BACKUP\CorporateData_East1_FULL.BAK' 

-- a. Form the restore using the backup file
RESTORE DATABASE [StackOverflow2010] FROM DISK = N'Z:\MSSQL\BACKUP\CorporateData_East1_FULL.BAK'
WITH
MOVE '' TO '',
MOVE '' TO '',
STATS = 10

-- 3. What if the backup has many files?

-- a. Too many files:
RESTORE FILELISTONLY FROM DISK = N'Z:\MSSQL\BACKUP\StackOverflow2010_Full.BAK' 

-- b. Solution:
-- Form the MOVE and TO for RESTORE FILELISTONLY

-- c. Drop table (if exists, no harm here)
DROP TABLE IF EXISTS #LogicalPhysical

-- d. Create table
CREATE TABLE #LogicalPhysical
(
    LogicalName NVARCHAR(128),
    PhysicalName NVARCHAR(260),
    Type CHAR(1),
    FileGroupName NVARCHAR(128),
    Size NUMERIC(20, 0),
    MaxSize NUMERIC(20, 0),
    FileID BIGINT,
    CreateLSN NUMERIC(25, 0),
    DropLSN NUMERIC(25, 0),
    UniqueID UNIQUEIDENTIFIER,
    ReadOnlyLSN NUMERIC(25, 0),
    ReadWriteLSN NUMERIC(25, 0),
    BackupSizeInBytes NUMERIC(20, 0),
    SourceBlockSize INT,
    FileGroupID INT,
    LogGroupGUID UNIQUEIDENTIFIER,
    DifferentialBaseLSN NUMERIC(25, 0),
    DifferentialBaseGUID UNIQUEIDENTIFIER,
    IsReadOnly BIT,
    IsPresent BIT,
    TDEThumbprint VARBINARY(32),
    SnapshotUrl NVARCHAR(368)
)

-- e. Insert the results
INSERT INTO #LogicalPhysical
EXEC('RESTORE FILELISTONLY FROM DISK = N''Z:\MSSQL\BACKUP\StackOverflow2010_Full.BAK''')

-- f. Query using the "MOVE" and "TO"
Select 'MOVE ''' + LogicalName + ''' TO ''' + PhysicalName + ''','
From #LogicalPhysical

-- g. Form the restore using the backup file
RESTORE DATABASE [StackOverflow2010] FROM DISK = N'Z:\MSSQL\BACKUP\CorporateData_East1_FULL.BAK'
WITH
MOVE '' TO '',
MOVE '' TO '',
STATS = 10